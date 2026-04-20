import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../domain/task_orchestrator_sync.dart';
import '../../../security/guest_profile_store.dart';
import '../../../ui/ui.dart';
import '../data/questionnaire_repository.dart';
import '../domain/questionnaire_data.dart';
import 'pages/clinic_page.dart';
import 'pages/emergency_summary_page.dart';
import 'pages/health_profile_page.dart';
import 'pages/op_date_modus_page.dart';
import 'pages/op_info_page.dart';
import '../../../l10n/app_localizations.dart';

/// Multi-page onboarding questionnaire shown once after registration.
///
/// Collects surgery details, clinic info, health profile, and emergency
/// contact. On completion the data is saved to Firestore and the timeline
/// is auto-generated from the OP date.
class OnboardingQuestionnaireScreen extends StatefulWidget {
  const OnboardingQuestionnaireScreen({super.key, required this.onComplete});

  /// Called after the questionnaire is saved and the timeline has been
  /// generated. The parent gate uses this to transition to MainNavigation.
  final VoidCallback onComplete;

  @override
  State<OnboardingQuestionnaireScreen> createState() =>
      _OnboardingQuestionnaireScreenState();
}

class _OnboardingQuestionnaireScreenState
    extends State<OnboardingQuestionnaireScreen> {
  static const _pageCount = 5;
  final _pageCtrl = PageController();
  int _currentPage = 0;
  bool _isSaving = false;

  // ── Page 1 state ──
  String? _selectedOpType;
  final _customOpTypeCtrl = TextEditingController();
  DateTime? _opDate;
  bool _opDateUnknown = false;
  String? _opModus;

  // ── Page 2 state ──
  final _hospitalCtrl = TextEditingController();
  final _doctorCtrl = TextEditingController();

  // ── Page 3 state ──
  final List<String> _conditions = [];
  final List<String> _allergies = [];
  final List<String> _medications = [];
  final _weightCtrl = TextEditingController();
  final _heightCtrl = TextEditingController();
  String? _smokerStatus;

  // ── Page 4 state ──
  final _emergencyNameCtrl = TextEditingController();
  final _emergencyPhoneCtrl = TextEditingController();

  @override
  void dispose() {
    _pageCtrl.dispose();
    _customOpTypeCtrl.dispose();
    _hospitalCtrl.dispose();
    _doctorCtrl.dispose();
    _weightCtrl.dispose();
    _heightCtrl.dispose();
    _emergencyNameCtrl.dispose();
    _emergencyPhoneCtrl.dispose();
    super.dispose();
  }

  // ── Navigation ──

  bool get _canAdvance {
    if (_currentPage == 0) {
      // OP type must be selected (and custom text filled in if "Sonstiges").
      final hasOpType = _selectedOpType != null &&
          (_selectedOpType != 'Sonstiges' ||
              _customOpTypeCtrl.text.trim().isNotEmpty);
      return hasOpType;
    }
    if (_currentPage == 1) {
      // Date (or "unknown" checkbox) + modus are mandatory.
      return (_opDate != null || _opDateUnknown) && _opModus != null;
    }
    // Pages 2–4 have no mandatory fields.
    return true;
  }

  void _goNext() {
    if (_currentPage < _pageCount - 1) {
      _pageCtrl.nextPage(
        duration: MotionDuration.slow,
        curve: MotionCurve.standard,
      );
    }
  }

  void _goBack() {
    if (_currentPage > 0) {
      _pageCtrl.previousPage(
        duration: MotionDuration.slow,
        curve: MotionCurve.standard,
      );
    }
  }

  // ── Submit ──

  Future<void> _submit() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;

    setState(() => _isSaving = true);
    try {
      final resolvedOpType = _selectedOpType == 'Sonstiges'
          ? _customOpTypeCtrl.text.trim()
          : _selectedOpType!;

      final data = QuestionnaireData(
        opDate: _opDate,
        opType: resolvedOpType,
        opModus: _opModus!,
        hospitalName: _hospitalCtrl.text.trim(),
        doctorName: _doctorCtrl.text.trim(),
        preExistingConditions: List.unmodifiable(_conditions),
        allergies: List.unmodifiable(_allergies),
        currentMedications: List.unmodifiable(_medications),
        weight: double.tryParse(_weightCtrl.text.trim()),
        height: double.tryParse(_heightCtrl.text.trim()),
        smokerStatus: _smokerStatus,
        emergencyContactName: _emergencyNameCtrl.text.trim(),
        emergencyContactPhone: _emergencyPhoneCtrl.text.trim(),
      );

      if (uid != null) {
        // Authenticated user: save to Firestore.
        await QuestionnaireRepository().saveQuestionnaire(uid, data);
      } else {
        // Guest user: save locally.
        // toFirestore() contains FieldValue.serverTimestamp() which is not
        // JSON-serializable, so replace it with a plain ISO-8601 string.
        final localData = Map<String, dynamic>.from(data.toFirestore(uid: uid))
          ..['updatedAt'] = DateTime.now().toIso8601String();
        await GuestProfileStore().save(localData);
        final prefs = await SharedPreferences.getInstance();
        await prefs.setBool('guest_questionnaire_complete', true);
      }

      // Auto-generate the timeline from the OP date (only if known).
      // Non-critical: if this fails the timeline can still be generated
      // later via the profile settings screen.
      if (_opDate != null) {
        try {
          await TaskOrchestratorSync.instance.setOperationDate(
            _opDate!,
            opType: resolvedOpType,
            opModus: _opModus,
          );
        } catch (e) {
          debugPrint('[Questionnaire] setOperationDate failed: $e');
        }
      }

      // Always transition to the main app after saving.
      if (mounted) widget.onComplete();
    } catch (e) {
      if (mounted) {
        final l = AppLocalizations.of(context)!;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(userFacingError(e,
                fallback: l.fehlerSpeichernErneut)),
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  // ── Date picker ──

  Future<void> _pickOpDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _opDate ?? now,
      firstDate: now.subtract(const Duration(days: 30)),
      lastDate: now.add(const Duration(days: 365)),
      locale: const Locale('de'),
    );
    if (picked != null && mounted) {
      setState(() => _opDate = picked);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final topPadding = MediaQuery.of(context).padding.top;
    final bottomPadding = MediaQuery.of(context).padding.bottom;

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: AppBackground(
        child: Column(
          children: [
            SizedBox(height: topPadding + AppSpacing.md),

            // ── Progress bar ──
            Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Schritt ${_currentPage + 1} von $_pageCount',
                        style: Theme.of(context)
                            .textTheme
                            .bodySmall
                            ?.copyWith(color: AppColors.textSecondary),
                      ),
                      Text(
                        _pageTitles[_currentPage],
                        style: Theme.of(context)
                            .textTheme
                            .bodySmall
                            ?.copyWith(
                              fontWeight: FontWeight.w600,
                              color: AppColors.primary,
                            ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  ClipRRect(
                    borderRadius: AppRadius.borderRadiusPill,
                    child: LinearProgressIndicator(
                      value: (_currentPage + 1) / _pageCount,
                      minHeight: 6,
                      backgroundColor: AppColors.grey200,
                      valueColor: const AlwaysStoppedAnimation<Color>(
                        AppColors.primary,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.sm),

            // ── Pages ──
            Expanded(
              child: PageView(
                controller: _pageCtrl,
                physics: const NeverScrollableScrollPhysics(),
                onPageChanged: (i) => setState(() => _currentPage = i),
                children: [
                  OpInfoPage(
                    selectedOpType: _selectedOpType,
                    customOpType: _customOpTypeCtrl,
                    onOpTypeSelected: (t) =>
                        setState(() => _selectedOpType = t),
                    onCustomOpTypeChanged: (_) => setState(() {}),
                  ),
                  OpDateModusPage(
                    opDate: _opDate,
                    opDateUnknown: _opDateUnknown,
                    opModus: _opModus,
                    onPickDate: _pickOpDate,
                    onDateUnknownChanged: (v) => setState(() {
                      _opDateUnknown = v;
                      if (v) {
                        _opDate = null;
                        _opModus ??= l.stationaer2;
                      }
                    }),
                    onModusChanged: (m) =>
                        setState(() => _opModus = m),
                  ),
                  ClinicPage(
                    hospitalCtrl: _hospitalCtrl,
                    doctorCtrl: _doctorCtrl,
                  ),
                  HealthProfilePage(
                    conditions: _conditions,
                    allergies: _allergies,
                    medications: _medications,
                    weightCtrl: _weightCtrl,
                    heightCtrl: _heightCtrl,
                    smokerStatus: _smokerStatus,
                    onAddCondition: (v) =>
                        setState(() => _conditions.add(v)),
                    onRemoveCondition: (v) =>
                        setState(() => _conditions.remove(v)),
                    onAddAllergy: (v) =>
                        setState(() => _allergies.add(v)),
                    onRemoveAllergy: (v) =>
                        setState(() => _allergies.remove(v)),
                    onAddMedication: (v) =>
                        setState(() => _medications.add(v)),
                    onRemoveMedication: (v) =>
                        setState(() => _medications.remove(v)),
                    onSmokerChanged: (v) =>
                        setState(() => _smokerStatus = v),
                  ),
                  EmergencySummaryPage(
                    emergencyNameCtrl: _emergencyNameCtrl,
                    emergencyPhoneCtrl: _emergencyPhoneCtrl,
                    opType: _resolvedOpType,
                    opDate: _opDate,
                    opModus: _opModus ?? '',
                    hospitalName: _hospitalCtrl.text.trim(),
                    doctorName: _doctorCtrl.text.trim(),
                    conditions: _conditions,
                    allergies: _allergies,
                    medications: _medications,
                    weight: _weightCtrl.text.trim(),
                    height: _heightCtrl.text.trim(),
                    smokerStatus: _smokerStatus,
                  ),
                ],
              ),
            ),

            // ── Bottom bar ──
            Container(
              padding: EdgeInsets.only(
                left: AppSpacing.xl,
                right: AppSpacing.xl,
                top: AppSpacing.lg,
                bottom: bottomPadding + AppSpacing.md,
              ),
              child: Builder(builder: (context) {
                final isFirst = _currentPage == 0;
                final isLast = _currentPage == _pageCount - 1;
                // Action button: full-width (Expanded) when it's the only button
                // on screen (first page), or natural-size when paired with Zurück.
                final Widget actionBtn = isFirst
                    ? Expanded(
                        child: GlassButton(
                          onPressed: isLast
                              ? (_isSaving ? null : _submit)
                              : (_canAdvance ? _goNext : null),
                          label: isLast ? l.done : l.next,
                          icon: isLast
                              ? Icons.check_rounded
                              : Icons.arrow_forward_rounded,
                          isLoading: isLast && _isSaving,
                          expand: true,
                        ),
                      )
                    : GlassButton(
                        onPressed: isLast
                            ? (_isSaving ? null : _submit)
                            : (_canAdvance ? _goNext : null),
                        label: isLast ? l.done : l.next,
                        icon: isLast
                            ? Icons.check_rounded
                            : Icons.arrow_forward_rounded,
                        isLoading: isLast && _isSaving,
                      );
                return Row(
                  children: [
                    if (!isFirst) ...[
                      GlassButton(
                        onPressed: _goBack,
                        label: l.back,
                        icon: Icons.arrow_back_rounded,
                        variant: GlassButtonVariant.ghost,
                      ),
                      const Spacer(),
                    ],
                    actionBtn,
                  ],
                );
              }),
            ),
          ],
        ),
      ),
    );
  }

  String get _resolvedOpType {
    if (_selectedOpType == 'Sonstiges') {
      return _customOpTypeCtrl.text.trim();
    }
    return _selectedOpType ?? '';
  }

  static const _pageTitles = [
    'OP-Art',
    'OP-Datum',
    'Klinik & Arzt',
    'Gesundheit',
    'Zusammenfassung',
  ];
}
