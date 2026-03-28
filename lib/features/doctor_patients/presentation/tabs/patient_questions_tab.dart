import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../../../../features/doctor_patients/data/doctor_patient_repository.dart';
import '../../../../features/questions/domain/doctor_question.dart';
import '../../../../firebase/firebase_paths.dart';
import '../../../../ui/ui.dart';
import '../../../../l10n/app_localizations.dart';

/// Tab shown inside [PatientDetailScreen] that lets the doctor view and
/// answer the patient's questions.
class PatientQuestionsTab extends StatefulWidget {
  const PatientQuestionsTab({
    super.key,
    required this.patientId,
  });

  final String patientId;

  @override
  State<PatientQuestionsTab> createState() => _PatientQuestionsTabState();
}

class _PatientQuestionsTabState extends State<PatientQuestionsTab> {
  final _firestore = FirebaseFirestore.instance;
  late final Stream<List<DoctorQuestion>> _stream;

  @override
  void initState() {
    super.initState();
    _stream = _firestore
        .collection(FirestorePaths.questionsCollection(widget.patientId))
        .snapshots()
        .map((snap) {
      final questions = snap.docs
          .map((doc) => DoctorQuestion.fromJson(<String, dynamic>{
                ...doc.data(),
                'id': doc.id,
              }))
          .toList();
      // Open first, then asked, then answered; newest first per group.
      questions.sort((a, b) {
        final sp = _statusPriority(a.status)
            .compareTo(_statusPriority(b.status));
        if (sp != 0) return sp;
        return b.updatedAt.compareTo(a.updatedAt);
      });
      return questions;
    });
  }

  static int _statusPriority(QuestionStatus s) => switch (s) {
        QuestionStatus.open => 0,
        QuestionStatus.asked => 1,
        QuestionStatus.answered => 2,
      };

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<DoctorQuestion>>(
      stream: _stream,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        final questions = snapshot.data ?? const <DoctorQuestion>[];

        if (questions.isEmpty) {
          return Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.quiz_outlined, size: 48, color: AppColors.grey400),
                const SizedBox(height: AppSpacing.md),
                Text(
                  'Noch keine Fragen vom Patienten.',
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: AppColors.textSecondary,
                      ),
                ),
              ],
            ),
          );
        }

        final openCount =
            questions.where((q) => q.status != QuestionStatus.answered).length;

        return ListView(
          padding: const EdgeInsets.all(AppSpacing.lg),
          children: [
            // Summary header
            GlassContainer(
              variant: GlassVariant.thin,
              borderRadius: AppRadius.borderRadiusMd,
              padding: const EdgeInsets.all(AppSpacing.md),
              child: Row(
                children: [
                  Icon(Icons.quiz_rounded, color: const Color(0xFF0A84FF)),
                  const SizedBox(width: AppSpacing.sm),
                  Text(
                    '$openCount offene Frage${openCount == 1 ? '' : 'n'}',
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w800,
                        ),
                  ),
                  const Spacer(),
                  Text(
                    '${questions.length} gesamt',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppColors.textSecondary,
                        ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            ...questions.map(
              (q) => Padding(
                padding: const EdgeInsets.only(bottom: AppSpacing.md),
                child: _DoctorQuestionCard(
                  question: q,
                  patientId: widget.patientId,
                  onAnswered: () => setState(() {}),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}

// ── Individual question card with answer capability ──────────────────────────

class _DoctorQuestionCard extends StatefulWidget {
  const _DoctorQuestionCard({
    required this.question,
    required this.patientId,
    required this.onAnswered,
  });

  final DoctorQuestion question;
  final String patientId;
  final VoidCallback onAnswered;

  @override
  State<_DoctorQuestionCard> createState() => _DoctorQuestionCardState();
}

class _DoctorQuestionCardState extends State<_DoctorQuestionCard> {
  bool _showAnswerField = false;
  final _answerController = TextEditingController();
  bool _busy = false;

  @override
  void dispose() {
    _answerController.dispose();
    super.dispose();
  }

  Color get _statusColor => switch (widget.question.status) {
        QuestionStatus.open => AppColors.warning,
        QuestionStatus.asked => const Color(0xFF0A84FF),
        QuestionStatus.answered => AppColors.success,
      };

  Future<void> _submitAnswer() async {
    final text = _answerController.text.trim();
    if (text.isEmpty) return;

    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;

    setState(() => _busy = true);
    try {
      final now = DateTime.now();
      await FirebaseFirestore.instance
          .collection(
              FirestorePaths.questionsCollection(widget.patientId))
          .doc(widget.question.id)
          .update(<String, dynamic>{
        'answer': text,
        'answeredBy': uid,
        'answeredAt': now.toIso8601String(),
        'status': QuestionStatus.answered.name,
        'updatedAt': now.toIso8601String(),
      });

      // Send push notification to the patient.
      final doctorName = await DoctorPatientRepository().getDoctorDisplayName();
      await _notifyPatientQuestionAnswered(
        patientId: widget.patientId,
        doctorName: doctorName.isNotEmpty ? doctorName : 'Ihr Arzt',
        questionText: widget.question.text,
      );

      if (mounted) {
        setState(() {
          _showAnswerField = false;
          _answerController.clear();
        });
        widget.onAnswered();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(userFacingError(e))),
        );
      }
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _notifyPatientQuestionAnswered({
    required String patientId,
    required String doctorName,
    required String questionText,
  }) async {
    try {
      final callable = FirebaseFunctions.instance.httpsCallable(
        'notifyQuestionAnswered',
      );
      await callable.call<dynamic>({
        'patientId': patientId,
        'doctorName': doctorName,
        'questionText': questionText,
      });
    } catch (e) {
      debugPrint('[PatientQuestionsTab] push notification failed: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final q = widget.question;
    final isAnswered = q.status == QuestionStatus.answered;

    return GlassContainer(
      variant: GlassVariant.medium,
      elevation: GlassElevation.low,
      borderRadius: AppRadius.borderRadiusXl,
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Status + category row
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.sm,
                  vertical: AppSpacing.xs + 2,
                ),
                decoration: BoxDecoration(
                  color: _statusColor.withValues(alpha: 0.13),
                  borderRadius: AppRadius.borderRadiusPill,
                ),
                child: Text(
                  q.status.label,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                    color: _statusColor,
                  ),
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.sm,
                  vertical: AppSpacing.xs + 2,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFF0A84FF).withValues(alpha: 0.10),
                  borderRadius: AppRadius.borderRadiusPill,
                ),
                child: Text(
                  q.category.label,
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF0A84FF),
                  ),
                ),
              ),
              const Spacer(),
              if (q.favorite)
                Icon(Icons.star_rounded, size: 18, color: AppColors.warning),
            ],
          ),
          const SizedBox(height: AppSpacing.md),

          // Question text
          Text(
            q.text,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                  height: 1.35,
                ),
          ),

          // Existing answer
          if (isAnswered && q.answer != null && q.answer!.trim().isNotEmpty) ...[
            const SizedBox(height: AppSpacing.sm),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(AppSpacing.md),
              decoration: BoxDecoration(
                color: AppColors.success.withValues(alpha: 0.08),
                borderRadius: AppRadius.borderRadiusMd,
                border: Border.all(
                  color: AppColors.success.withValues(alpha: 0.18),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.question_answer_rounded,
                          size: 14, color: AppColors.success),
                      const SizedBox(width: AppSpacing.xs),
                      Text(
                        'Ihre Antwort',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w800,
                          color: AppColors.success,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    q.answer!,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: AppColors.textPrimary,
                          height: 1.4,
                        ),
                  ),
                ],
              ),
            ),
          ],

          // Answer input toggle
          if (!isAnswered) ...[
            const SizedBox(height: AppSpacing.md),
            if (!_showAnswerField)
              PressableScale(
                onTap: () => setState(() => _showAnswerField = true),
                scaleFactor: 0.97,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.md,
                    vertical: AppSpacing.sm,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFF0A84FF).withValues(alpha: 0.08),
                    borderRadius: AppRadius.borderRadiusPill,
                    border: Border.all(
                      color: const Color(0xFF0A84FF).withValues(alpha: 0.16),
                    ),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.reply_rounded,
                          size: 16, color: Color(0xFF0A84FF)),
                      SizedBox(width: AppSpacing.xs),
                      Text(
                        'Antworten',
                        style: TextStyle(
                          color: Color(0xFF0A84FF),
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),
              )
            else
              Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  TextField(
                    controller: _answerController,
                    autofocus: true,
                    maxLines: 4,
                    minLines: 2,
                    decoration: InputDecoration(
                      hintText: l.ihreAntwortEingeben,
                      border: OutlineInputBorder(
                        borderRadius: AppRadius.borderRadiusMd,
                      ),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton(
                        onPressed: _busy
                            ? null
                            : () =>
                                setState(() => _showAnswerField = false),
                        child: Text(l.cancel),
                      ),
                      const SizedBox(width: AppSpacing.sm),
                      FilledButton.icon(
                        onPressed: _busy ? null : _submitAnswer,
                        icon: _busy
                            ? const SizedBox(
                                width: 16,
                                height: 16,
                                child:
                                    CircularProgressIndicator(strokeWidth: 2),
                              )
                            : const Icon(Icons.send_rounded, size: 16),
                        label: Text(l.send),
                      ),
                    ],
                  ),
                ],
              ),
          ],
        ],
      ),
    );
  }
}
