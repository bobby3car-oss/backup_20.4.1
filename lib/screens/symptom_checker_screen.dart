import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../features/warnings/data/symptom_check_service.dart';
import '../features/warnings/domain/symptom_check_result.dart';
import '../notifications/local_notifications.dart';
import '../ui/ui.dart';
import '../ui/theme/app_icons.dart';
import '../l10n/app_localizations.dart';

// ── Data models ──────────────────────────────────────────────────────────────

enum _Severity { none, mild, moderate, severe }

extension on _Severity {
  int get weight => switch (this) {
    _Severity.none => 0,
    _Severity.mild => 1,
    _Severity.moderate => 2,
    _Severity.severe => 3,
  };
}

enum _TrafficLight { green, yellow, red }

extension on _TrafficLight {
  Color get color => switch (this) {
    _TrafficLight.green => AppColors.success,
    _TrafficLight.yellow => const Color(0xFFFFCC00),
    _TrafficLight.red => AppColors.error,
  };

  IconData get icon => switch (this) {
    _TrafficLight.green => Icons.check_circle_rounded,
    _TrafficLight.yellow => Icons.warning_rounded,
    _TrafficLight.red => Icons.error_rounded,
  };
}

String _severityLabel(AppLocalizations l, _Severity s) => switch (s) {
  _Severity.none => l.scSeverityNone,
  _Severity.mild => l.scSeverityMild,
  _Severity.moderate => l.scSeverityModerate,
  _Severity.severe => l.scSeveritySevere,
};

String _trafficLightLabel(AppLocalizations l, _TrafficLight t) => switch (t) {
  _TrafficLight.green => l.scLevelGreen,
  _TrafficLight.yellow => l.scLevelYellow,
  _TrafficLight.red => l.scLevelRed,
};

String _trafficLightTitle(AppLocalizations l, _TrafficLight t) => switch (t) {
  _TrafficLight.green => l.allesImGruenenBereich,
  _TrafficLight.yellow => l.scLevelTitleYellow,
  _TrafficLight.red => l.aerztlichenRatEinholen,
};

String _trafficLightRecommendation(AppLocalizations l, _TrafficLight t) =>
    switch (t) {
      _TrafficLight.green => l.scRecommendGreen,
      _TrafficLight.yellow => l.scRecommendYellow,
      _TrafficLight.red => l.scRecommendRed,
    };

class _SymptomQuestion {
  _SymptomQuestion({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.color,
  });

  final String id;
  final String title;
  final String subtitle;
  final IconData icon;
  final Color color;
  _Severity severity = _Severity.none;
}

// ─────────────────────────────────────────────────────────────────────────────

class SymptomCheckerScreen extends StatefulWidget {
  const SymptomCheckerScreen({super.key});

  @override
  State<SymptomCheckerScreen> createState() => _SymptomCheckerScreenState();
}

class _SymptomCheckerScreenState extends State<SymptomCheckerScreen> {
  bool _showResult = false;
  bool _saving = false;
  bool _saved = false;
  TimeOfDay? _reminderTime;
  bool _reminderSaving = false;
  bool _questionsBuilt = false;

  static const _prefKeyHour = 'symptom_checker_reminder_hour';
  static const _prefKeyMinute = 'symptom_checker_reminder_minute';

  @override
  void initState() {
    super.initState();
    _loadReminderTime();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_questionsBuilt) {
      final l = AppLocalizations.of(context)!;
      _questions = [
        _SymptomQuestion(
          id: 'pain',
          title: l.scSymPain,
          subtitle: l.scSymPainSub,
          icon: Icons.flash_on_rounded,
          color: AppColors.error,
        ),
        _SymptomQuestion(
          id: 'nausea',
          title: l.scSymNausea,
          subtitle: l.scSymNauseaSub,
          icon: Icons.sick_rounded,
          color: AppColors.warning,
        ),
        _SymptomQuestion(
          id: 'breathing',
          title: l.scSymBreathing,
          subtitle: l.scSymBreathingSub,
          icon: Icons.air_rounded,
          color: AppColors.primary,
        ),
        _SymptomQuestion(
          id: 'dizziness',
          title: l.scSymDizziness,
          subtitle: l.scSymDizzinessSub,
          icon: Icons.rotate_right_rounded,
          color: AppColors.accent,
        ),
        _SymptomQuestion(
          id: 'wound',
          title: l.scSymWound,
          subtitle: l.scSymWoundSub,
          icon: Icons.healing_rounded,
          color: AppColors.success,
        ),
      ];
      _questionsBuilt = true;
    }
  }

  Future<void> _loadReminderTime() async {
    final prefs = await SharedPreferences.getInstance();
    final hour = prefs.getInt(_prefKeyHour);
    final minute = prefs.getInt(_prefKeyMinute);
    if (hour != null && minute != null && mounted) {
      setState(() => _reminderTime = TimeOfDay(hour: hour, minute: minute));
    }
  }

  Future<void> _scheduleReminder(TimeOfDay time) async {
    setState(() => _reminderSaving = true);
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt(_prefKeyHour, time.hour);
      await prefs.setInt(_prefKeyMinute, time.minute);
      await LocalNotifications.scheduleSymptomCheckerReminder(time);
      if (!mounted) return;
      setState(() {
        _reminderTime = time;
        _reminderSaving = false;
      });
      final l = AppLocalizations.of(context)!;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l.scReminderSet(time.format(context)))),
      );
    } catch (_) {
      if (!mounted) return;
      setState(() => _reminderSaving = false);
    }
  }

  Future<void> _pickAndScheduleReminder() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: _reminderTime ?? const TimeOfDay(hour: 9, minute: 0),
    );
    if (picked == null || !mounted) return;
    await _scheduleReminder(picked);
  }

  late final List<_SymptomQuestion> _questions;

  _TrafficLight get _result {
    final total = _questions.fold<int>(0, (sum, q) => sum + q.severity.weight);
    if (total >= 8) return _TrafficLight.red;
    if (total >= 4) return _TrafficLight.yellow;
    return _TrafficLight.green;
  }

  int get _answeredCount =>
      _questions.where((q) => q.severity != _Severity.none).length;

  Future<void> _saveResult() async {
    if (_saving || _saved) return;
    setState(() => _saving = true);
    try {
      final l = AppLocalizations.of(context)!;
      final answers = <String, SymptomSeverity>{
        for (final q in _questions)
          q.id: switch (q.severity) {
            _Severity.none => SymptomSeverity.none,
            _Severity.mild => SymptomSeverity.mild,
            _Severity.moderate => SymptomSeverity.moderate,
            _Severity.severe => SymptomSeverity.severe,
          },
      };
      final level = switch (_result) {
        _TrafficLight.green => SymptomCheckLevel.green,
        _TrafficLight.yellow => SymptomCheckLevel.yellow,
        _TrafficLight.red => SymptomCheckLevel.red,
      };
      await SymptomCheckService.submit(
        answers: answers,
        level: level,
        recommendation: _trafficLightRecommendation(l, _result),
      );
      if (!mounted) return;
      setState(() {
        _saving = false;
        _saved = true;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l.resultSaved)),
      );
    } catch (e) {
      final l = AppLocalizations.of(context)!;
      if (!mounted) return;
      setState(() => _saving = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l.saveFailed)),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    return GlassPage(
      title: l.scTitle,
      titleIcon: AppIcons.info,
      titleColor: AppColors.primary,
      trailing: _showResult
          ? PressableScale(
              onTap: () => setState(() {
                _showResult = false;
                for (final q in _questions) {
                  q.severity = _Severity.none;
                }
                _saved = false;
              }),
              scaleFactor: 0.90,
              child: Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: AppColors.white.withValues(alpha: 0.65),
                  borderRadius: AppRadius.borderRadiusMd,
                  border: Border.all(
                    color: AppColors.white.withValues(alpha: 0.80),
                    width: 0.5,
                  ),
                ),
                child: const Icon(
                  Icons.restart_alt_rounded,
                  size: 18,
                  color: AppColors.primary,
                ),
              ),
            )
          : null,
      children: [
        if (!_showResult) ...[
          _IntroCard(
            answeredCount: _answeredCount,
            totalCount: _questions.length,
          ),
          const SizedBox(height: AppSpacing.xxl),
          _sectionTitle(context, l.scSymptomsSection),
          const SizedBox(height: AppSpacing.md),
          for (var i = 0; i < _questions.length; i++) ...[
            _QuestionCard(
              question: _questions[i],
              onChanged: (severity) {
                setState(() => _questions[i].severity = severity);
              },
            ),
            if (i < _questions.length - 1)
              const SizedBox(height: AppSpacing.md),
          ],
          const SizedBox(height: AppSpacing.xxl),
          GlassButton(
            onPressed: () => setState(() => _showResult = true),
            label: l.auswertungAnzeigen,
            icon: Icons.assessment_rounded,
            expand: true,
          ),
        ] else ...[
          _ResultCard(result: _result),
          const SizedBox(height: AppSpacing.xxl),
          _sectionTitle(context, l.scYourInputs),
          const SizedBox(height: AppSpacing.md),
          _SummaryCard(questions: _questions),
          const SizedBox(height: AppSpacing.xxl),
          _ActionsCard(
            result: _result,
            onSave: _saveResult,
            saving: _saving,
            saved: _saved,
          ),
          const SizedBox(height: AppSpacing.xxl),
          GlassButton(
            onPressed: _reminderSaving ? null : _pickAndScheduleReminder,
            label: _reminderTime != null
                ? l.scReminderActive(_reminderTime!.format(context))
                : l.scSetDailyReminder,
            icon: Icons.alarm_add_rounded,
            variant: GlassButtonVariant.secondary,
            expand: true,
          ),
          const SizedBox(height: AppSpacing.md),
          GlassButton(
            onPressed: () => setState(() => _showResult = false),
            label: l.erneutPruefen,
            icon: Icons.refresh_rounded,
            variant: GlassButtonVariant.ghost,
            expand: true,
          ),
        ],
      ],
    );
  }

  Widget _sectionTitle(BuildContext context, String title) {
    return Padding(
      padding: const EdgeInsets.only(left: AppSpacing.xs),
      child: Text(title, style: Theme.of(context).textTheme.titleLarge),
    );
  }
}

// ── Intro card ───────────────────────────────────────────────────────────────

class _IntroCard extends StatelessWidget {
  const _IntroCard({required this.answeredCount, required this.totalCount});

  final int answeredCount;
  final int totalCount;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    return GlassContainer(
      padding: const EdgeInsets.all(AppSpacing.xl),
      borderRadius: AppRadius.borderRadiusXl,
      child: Row(
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.10),
              borderRadius: AppRadius.borderRadiusLg,
            ),
            child: const Icon(
              Icons.fact_check_rounded,
              size: 26,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(width: AppSpacing.lg),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l.wieFuehlenSieSich,
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  l.scIntroBody,
                  style: Theme.of(
                    context,
                  ).textTheme.bodySmall?.copyWith(height: 1.4),
                ),
                const SizedBox(height: AppSpacing.sm),
                // Progress
                Row(
                  children: [
                    Expanded(
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(3),
                        child: LinearProgressIndicator(
                          value: totalCount > 0
                              ? answeredCount / totalCount
                              : 0,
                          minHeight: 6,
                          backgroundColor: AppColors.grey200,
                          valueColor: const AlwaysStoppedAnimation(
                            AppColors.primary,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    Text(
                      '$answeredCount / $totalCount',
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ── Question card ────────────────────────────────────────────────────────────

class _QuestionCard extends StatelessWidget {
  const _QuestionCard({required this.question, required this.onChanged});

  final _SymptomQuestion question;
  final ValueChanged<_Severity> onChanged;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    return GlassContainer(
      padding: const EdgeInsets.all(AppSpacing.lg),
      borderRadius: AppRadius.borderRadiusXl,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: question.color.withValues(alpha: 0.10),
                  borderRadius: AppRadius.borderRadiusMd,
                ),
                child: Icon(question.icon, size: 22, color: question.color),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      question.title,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.xxs),
                    Text(
                      question.subtitle,
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.textSecondary,
                        height: 1.3,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.lg),
          Row(
            children: _Severity.values.map((s) {
              final selected = question.severity == s;
              return Expanded(
                child: Padding(
                  padding: EdgeInsets.only(
                    right: s != _Severity.severe ? AppSpacing.sm : 0,
                  ),
                  child: GestureDetector(
                    onTap: () => onChanged(s),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      padding: const EdgeInsets.symmetric(
                        vertical: AppSpacing.sm,
                      ),
                      decoration: BoxDecoration(
                        color: selected
                            ? _colorForSeverity(s).withValues(alpha: 0.14)
                            : AppColors.grey100,
                        borderRadius: AppRadius.borderRadiusSm,
                        border: Border.all(
                          color: selected
                              ? _colorForSeverity(s).withValues(alpha: 0.40)
                              : AppColors.grey200,
                          width: selected ? 1.5 : 1,
                        ),
                      ),
                      child: Column(
                        children: [
                          Icon(
                            _iconForSeverity(s),
                            size: 20,
                            color: selected
                                ? _colorForSeverity(s)
                                : AppColors.grey400,
                          ),
                          const SizedBox(height: AppSpacing.xxs),
                          Text(
                            _severityLabel(l, s),
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: selected
                                  ? FontWeight.w700
                                  : FontWeight.w500,
                              color: selected
                                  ? _colorForSeverity(s)
                                  : AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  static Color _colorForSeverity(_Severity s) => switch (s) {
    _Severity.none => AppColors.success,
    _Severity.mild => const Color(0xFFFFCC00),
    _Severity.moderate => AppColors.warning,
    _Severity.severe => AppColors.error,
  };

  static IconData _iconForSeverity(_Severity s) => switch (s) {
    _Severity.none => Icons.sentiment_very_satisfied_rounded,
    _Severity.mild => Icons.sentiment_satisfied_rounded,
    _Severity.moderate => Icons.sentiment_dissatisfied_rounded,
    _Severity.severe => Icons.sentiment_very_dissatisfied_rounded,
  };
}

// ── Result card (traffic light) ──────────────────────────────────────────────

class _ResultCard extends StatelessWidget {
  const _ResultCard({required this.result});

  final _TrafficLight result;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    return GlassContainer(
      padding: const EdgeInsets.all(AppSpacing.xl),
      borderRadius: AppRadius.borderRadiusXl,
      child: Column(
        children: [
          // Traffic light
          const SizedBox(height: AppSpacing.sm),
          _TrafficLightWidget(active: result),
          const SizedBox(height: AppSpacing.xl),

          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.md,
              vertical: AppSpacing.xs,
            ),
            decoration: BoxDecoration(
              color: result.color.withValues(alpha: 0.12),
              borderRadius: AppRadius.borderRadiusPill,
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(result.icon, size: 14, color: result.color),
                const SizedBox(width: AppSpacing.xs),
                Text(
                  l.scResultBadge(_trafficLightLabel(l, result)),
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: result.color,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          Text(
            _trafficLightTitle(l, result),
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            _trafficLightRecommendation(l, result),
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(height: 1.5),
          ),
          const SizedBox(height: AppSpacing.sm),
        ],
      ),
    );
  }
}

class _TrafficLightWidget extends StatelessWidget {
  const _TrafficLightWidget({required this.active});

  final _TrafficLight active;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.xl,
        vertical: AppSpacing.lg,
      ),
      decoration: BoxDecoration(
        color: AppColors.grey900,
        borderRadius: AppRadius.borderRadiusXl,
        boxShadow: [
          BoxShadow(
            color: active.color.withValues(alpha: 0.30),
            blurRadius: 24,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          for (final light in _TrafficLight.values)
            Padding(
              padding: EdgeInsets.only(
                left: light != _TrafficLight.green ? AppSpacing.lg : 0,
              ),
              child: _LightBulb(color: light.color, active: light == active),
            ),
        ],
      ),
    );
  }
}

class _LightBulb extends StatelessWidget {
  const _LightBulb({required this.color, required this.active});

  final Color color;
  final bool active;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 48,
      height: 48,
      decoration: BoxDecoration(
        color: active ? color : color.withValues(alpha: 0.12),
        shape: BoxShape.circle,
        border: Border.all(color: active ? color : AppColors.grey700, width: 2),
        boxShadow: active
            ? [
                BoxShadow(
                  color: color.withValues(alpha: 0.60),
                  blurRadius: 20,
                  spreadRadius: 2,
                ),
                BoxShadow(
                  color: color.withValues(alpha: 0.30),
                  blurRadius: 40,
                  spreadRadius: 4,
                ),
              ]
            : null,
      ),
      child: active ? CustomPaint(painter: _GlarePainter(color: color)) : null,
    );
  }
}

class _GlarePainter extends CustomPainter {
  _GlarePainter({required this.color});
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width * 0.38, size.height * 0.38);
    canvas.drawCircle(
      center,
      size.width * 0.16,
      Paint()
        ..color = Colors.white.withValues(alpha: 0.55)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4),
    );
  }

  @override
  bool shouldRepaint(covariant _GlarePainter old) => old.color != color;
}

// ── Summary card ─────────────────────────────────────────────────────────────

class _SummaryCard extends StatelessWidget {
  const _SummaryCard({required this.questions});

  final List<_SymptomQuestion> questions;

  @override
  Widget build(BuildContext context) {
    return GlassContainer(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.xs),
      borderRadius: AppRadius.borderRadiusXl,
      child: Column(
        children: [
          for (var i = 0; i < questions.length; i++) ...[
            _SummaryRow(question: questions[i]),
            if (i < questions.length - 1)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
                child: Container(height: 1, color: AppColors.grey200),
              ),
          ],
        ],
      ),
    );
  }
}

class _SummaryRow extends StatelessWidget {
  const _SummaryRow({required this.question});

  final _SymptomQuestion question;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final severityColor = _colorForSeverity(question.severity);

    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.lg,
        vertical: AppSpacing.md,
      ),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: question.color.withValues(alpha: 0.10),
              borderRadius: AppRadius.borderRadiusSm,
            ),
            child: Icon(question.icon, size: 18, color: question.color),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Text(
              question.title,
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.sm,
              vertical: AppSpacing.xxs,
            ),
            decoration: BoxDecoration(
              color: severityColor.withValues(alpha: 0.12),
              borderRadius: AppRadius.borderRadiusPill,
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: severityColor,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: AppSpacing.xs),
                Text(
                  _severityLabel(l, question.severity),
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: severityColor,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  static Color _colorForSeverity(_Severity s) => switch (s) {
    _Severity.none => AppColors.success,
    _Severity.mild => const Color(0xFFFFCC00),
    _Severity.moderate => AppColors.warning,
    _Severity.severe => AppColors.error,
  };
}

// ── Actions card ─────────────────────────────────────────────────────────────

class _ActionsCard extends StatelessWidget {
  const _ActionsCard({
    required this.result,
    required this.onSave,
    this.saving = false,
    this.saved = false,
  });

  final _TrafficLight result;
  final VoidCallback onSave;
  final bool saving;
  final bool saved;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    return GlassContainer(
      padding: const EdgeInsets.all(AppSpacing.xl),
      borderRadius: AppRadius.borderRadiusXl,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l.scActionsTitle,
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: AppSpacing.lg),
          if (result == _TrafficLight.green) ...[
            _ActionRow(
              icon: Icons.check_circle_outline_rounded,
              color: AppColors.success,
              title: l.weiterDokumentieren,
              subtitle: l.haltenSieIhreTaeglicheRoutineBei,
            ),
          ],
          if (result == _TrafficLight.yellow) ...[
            _ActionRow(
              icon: Icons.schedule_rounded,
              color: AppColors.warning,
              title: l.in24HErneutPruefen,
              subtitle: l.beobachtenSieDieSymptomeGenau,
            ),
            const SizedBox(height: AppSpacing.md),
            _ActionRow(
              icon: Icons.phone_rounded,
              color: AppColors.primary,
              title: l.beiVerschlechterungAnrufen,
              subtitle: l.kontaktierenSieIhrenArzt,
            ),
          ],
          if (result == _TrafficLight.red) ...[
            _ActionRow(
              icon: Icons.phone_rounded,
              color: AppColors.error,
              title: l.arztSofortKontaktieren,
              subtitle: l.beschreibenSieIhreSymptome,
            ),
            const SizedBox(height: AppSpacing.md),
            _ActionRow(
              icon: Icons.local_hospital_rounded,
              color: AppColors.error,
              title: l.notaufnahmeAufsuchen,
              subtitle: l.beiAkuterVerschlechterung,
            ),
          ],
          const SizedBox(height: AppSpacing.lg),
          GlassButton(
            onPressed: saving || saved ? null : onSave,
            label: saved ? l.scSaved : (saving ? l.scSaving : l.scSaveResult),
            icon: saved ? Icons.check_rounded : Icons.save_rounded,
            variant: GlassButtonVariant.secondary,
            expand: true,
          ),
        ],
      ),
    );
  }
}

class _ActionRow extends StatelessWidget {
  const _ActionRow({
    required this.icon,
    required this.color,
    required this.title,
    required this.subtitle,
  });

  final IconData icon;
  final Color color;
  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.10),
            borderRadius: AppRadius.borderRadiusMd,
          ),
          child: Icon(icon, size: 20, color: color),
        ),
        const SizedBox(width: AppSpacing.md),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
              Text(
                subtitle,
                style: const TextStyle(
                  fontSize: 12,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
