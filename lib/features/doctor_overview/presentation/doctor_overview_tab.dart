import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../../l10n/app_localizations.dart';
import '../../../ui/ui.dart';
import '../../aftercare/presentation/aftercare_template_list_screen.dart';
import '../../aftercare/presentation/assign_plan_screen.dart';
import '../../aftercare/data/aftercare_template_service.dart';
import '../../aftercare/data/patient_aftercare_plan_service.dart';
import '../../doctor_invite/presentation/invite_sheet.dart';
import '../../doctor_patients/data/doctor_patient_repository.dart';

/// Simplified doctor dashboard showing greeting, upcoming appointments,
/// active plan count, and quick actions.
class DoctorOverviewTab extends StatefulWidget {
  const DoctorOverviewTab({
    super.key,
    this.isStaff = false,
    this.doctorUid,
    this.onNavigateToCalendar,
  });

  final bool isStaff;
  final String? doctorUid;
  final VoidCallback? onNavigateToCalendar;

  @override
  State<DoctorOverviewTab> createState() => _DoctorOverviewTabState();
}

class _DoctorOverviewTabState extends State<DoctorOverviewTab> {
  late final DoctorPatientRepository _repository;
  String _doctorName = '';
  int _patientCount = 0;
  List<PatientAppointment> _todayAppointments = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _repository = DoctorPatientRepository(overrideDoctorUid: widget.doctorUid);
    _loadData();
  }

  Future<void> _loadData() async {
    try {
      final name = await _repository.getDoctorDisplayName();
      final patients = await _repository.getLinkedPatientsOnce();
      final today = DateTime.now();
      final appointments = await _repository.getAppointmentsForDate(today);

      if (mounted) {
        setState(() {
          _doctorName = name;
          _patientCount = patients.length;
          _todayAppointments = appointments.take(3).toList();
          _loading = false;
        });
      }
    } catch (_) {
      if (mounted) setState(() => _loading = false);
    }
  }

  String _greeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Guten Morgen';
    if (hour < 18) return 'Guten Tag';
    return 'Guten Abend';
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: AppBackground(
        child: SafeArea(
          child: _loading
              ? const Center(child: CircularProgressIndicator())
              : ListView(
                  physics: adaptiveScrollPhysics,
                  padding: const EdgeInsets.fromLTRB(
                    AppSpacing.xl,
                    AppSpacing.xl,
                    AppSpacing.xl,
                    120,
                  ),
                  children: [
                    // ── Greeting ──────────────────────────────
                    FadeSlideIn(
                      child: Text(
                        '${_greeting()},',
                        style: theme.textTheme.headlineSmall?.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ),
                    FadeSlideIn(
                      delay: const Duration(milliseconds: 50),
                      child: Text(
                        _doctorName.isNotEmpty ? _doctorName : l.doctor,
                        style: theme.textTheme.headlineMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(height: AppSpacing.xxl),

                    // ── Stats row ────────────────────────────
                    FadeSlideIn(
                      delay: const Duration(milliseconds: 100),
                      child: Row(
                        children: [
                          Expanded(
                            child: _StatCard(
                              icon: Icons.people_rounded,
                              label: l.patienten,
                              value: '$_patientCount',
                            ),
                          ),
                          const SizedBox(width: AppSpacing.md),
                          Expanded(
                            child: _StatCard(
                              icon: Icons.calendar_today_rounded,
                              label: 'Termine heute',
                              value: '${_todayAppointments.length}',
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: AppSpacing.xxl),

                    // ── Today's appointments ─────────────────
                    FadeSlideIn(
                      delay: const Duration(milliseconds: 150),
                      child: _SectionHeader(
                        title: 'Termine heute',
                        onShowAll: widget.onNavigateToCalendar,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    if (_todayAppointments.isEmpty)
                      FadeSlideIn(
                        delay: const Duration(milliseconds: 200),
                        child: GlassCard(
                          child: Center(
                            child: Padding(
                              padding: const EdgeInsets.all(AppSpacing.xl),
                              child: Text(
                                'Keine Termine heute',
                                style: theme.textTheme.bodyMedium?.copyWith(
                                  color: AppColors.textSecondary,
                                ),
                              ),
                            ),
                          ),
                        ),
                      )
                    else
                      ...List.generate(_todayAppointments.length, (i) {
                        final pa = _todayAppointments[i];
                        return FadeSlideIn(
                          delay: Duration(milliseconds: 200 + i * 50),
                          child: GlassCard(
                            child: ListTile(
                              leading: Icon(
                                Icons.event_rounded,
                                color: AppColors.primary,
                              ),
                              title: Text(pa.appointment.title),
                              subtitle: Text(pa.patient.displayName),
                              trailing: Text(
                                _formatTime(pa.appointment.startAt),
                                style: theme.textTheme.labelMedium?.copyWith(
                                  color: AppColors.primary,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ),
                        );
                      }),

                    const SizedBox(height: AppSpacing.xxl),

                    // ── Quick Actions ────────────────────────
                    FadeSlideIn(
                      delay: const Duration(milliseconds: 300),
                      child: _SectionHeader(title: 'Schnellaktionen'),
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    FadeSlideIn(
                      delay: const Duration(milliseconds: 350),
                      child: Row(
                        children: [
                          Expanded(
                            child: _QuickActionCard(
                              icon: Icons.person_add_rounded,
                              label: l.patientInvite,
                              onTap: () => _showInviteSheet(context),
                            ),
                          ),
                          const SizedBox(width: AppSpacing.md),
                          Expanded(
                            child: _QuickActionCard(
                              icon: Icons.medical_information_rounded,
                              label: l.vorlagenTitle,
                              onTap: () => _openTemplates(context),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: AppSpacing.md),
                    FadeSlideIn(
                      delay: const Duration(milliseconds: 400),
                      child: Row(
                        children: [
                          Expanded(
                            child: _QuickActionCard(
                              icon: Icons.assignment_turned_in_rounded,
                              label: 'Plan zuweisen',
                              onTap: () => _openAssignPlan(context),
                            ),
                          ),
                          const SizedBox(width: AppSpacing.md),
                          Expanded(
                            child: _QuickActionCard(
                              icon: Icons.calendar_month_rounded,
                              label: l.kalender,
                              onTap: widget.onNavigateToCalendar,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
        ),
      ),
    );
  }

  String _formatTime(DateTime dt) {
    return '${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
  }

  void _showInviteSheet(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.background,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(AppRadius.xl)),
      ),
      builder: (_) => const InviteSheet(),
    );
  }

  void _openTemplates(BuildContext context) {
    Navigator.of(context).push(
      CupertinoPageRoute<void>(
        builder: (_) => AftercareTemplateListScreen(
          doctorUid: widget.doctorUid,
        ),
      ),
    );
  }

  void _openAssignPlan(BuildContext context) {
    final currentUid = FirebaseAuth.instance.currentUser?.uid;
    final doctorUid = widget.doctorUid ?? currentUid;
    Navigator.of(context).push(
      CupertinoPageRoute<void>(
        builder: (_) => AssignPlanScreen(
          templateService: AftercareTemplateService(
            overrideDoctorUid: doctorUid,
          ),
          planService: PatientAftercarePlanService(
            overrideDoctorUid: doctorUid,
          ),
          doctorUid: doctorUid,
        ),
      ),
    );
  }
}

// ── Stat Card ─────────────────────────────────────────────────────────────

class _StatCard extends StatelessWidget {
  const _StatCard({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return GlassCard(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: AppColors.primary, size: 24),
            const SizedBox(height: AppSpacing.sm),
            Text(
              value,
              style: theme.textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: AppColors.primary,
              ),
            ),
            const SizedBox(height: AppSpacing.xs),
            Text(
              label,
              style: theme.textTheme.bodySmall?.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Section Header ────────────────────────────────────────────────────────

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.title, this.onShowAll});

  final String title;
  final VoidCallback? onShowAll;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    return Row(
      children: [
        Text(
          title,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        const Spacer(),
        if (onShowAll != null)
          TextButton(
            onPressed: onShowAll,
            child: Text(l.alleAnzeigen),
          ),
      ],
    );
  }
}

// ── Quick Action Card ─────────────────────────────────────────────────────

class _QuickActionCard extends StatelessWidget {
  const _QuickActionCard({
    required this.icon,
    required this.label,
    this.onTap,
  });

  final IconData icon;
  final String label;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return PressableScale(
      onTap: () {
        Haptic.selection();
        onTap?.call();
      },
      child: GlassCard(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Column(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: AppColors.primary, size: 22),
              ),
              const SizedBox(height: AppSpacing.sm),
              Text(
                label,
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.labelMedium?.copyWith(
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
