import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../../../auth/auth_service.dart';
import '../../../domain/timeline_engine.dart';
import '../../../features/appointments/domain/appointment_enums.dart';
import '../../../features/doctor_patients/data/doctor_patient_repository.dart';
import '../../../features/doctor_patients/domain/linked_patient.dart';
import '../../../features/doctor_invite/presentation/invite_sheet.dart';
import '../../../features/doctor_report/doctor_report_builder.dart';
import '../../../features/doctor_staff/domain/staff_permissions.dart';
import '../../../features/doctor_templates/presentation/template_management_screen.dart';
import '../../../features/doctor_notifications/data/doctor_notification_repository.dart';
import '../../../features/doctor_notifications/presentation/doctor_notification_screen.dart';
import '../../../features/doctor_report/presentation/doctor_aggregate_report_screen.dart';
import '../../../features/red_flags/domain/red_flag.dart';
import '../../../ui/ui.dart';
import '../../doctor_patients/presentation/patient_detail_screen.dart';
import 'doctor_stats_card.dart';
import '../../../l10n/app_localizations.dart';

/// First tab of the doctor dashboard – overview / Übersicht.
class DoctorOverviewTab extends StatefulWidget {
  const DoctorOverviewTab({super.key, this.isStaff = false, this.doctorUid, this.onNavigateToCalendar});

  /// Whether the current user is a staff member viewing the doctor dashboard.
  final bool isStaff;

  /// Doctor UID override for staff mode.
  final String? doctorUid;

  /// Callback to switch to the calendar tab in the parent [DoctorHome].
  final VoidCallback? onNavigateToCalendar;

  @override
  State<DoctorOverviewTab> createState() => _DoctorOverviewTabState();
}

class _DoctorOverviewTabState extends State<DoctorOverviewTab> {
  late final DoctorPatientRepository _repo;
  late final DoctorNotificationRepository _notificationRepo;

  String _doctorName = '';
  List<LinkedPatient> _patients = [];
  List<PatientAppointment> _todayAppointments = [];
  DoctorStatsData? _statsData;
  bool _loading = true;
  StaffPermissions? _staffPermissions;

  @override
  void initState() {
    super.initState();
    _repo = DoctorPatientRepository(overrideDoctorUid: widget.doctorUid);
    _notificationRepo = DoctorNotificationRepository(
      overrideDoctorUid: widget.doctorUid,
    );
    _loadData();
  }

  Future<void> _loadData() async {
    try {
      await AuthService.waitForWebSessionReady();

      final name = await _repo.getDoctorDisplayName();
      final patients = await _repo.getLinkedPatientsOnce();

      // Load staff permissions when in staff mode.
      StaffPermissions? perms;
      if (widget.isStaff) {
        final uid = FirebaseAuth.instance.currentUser?.uid;
        if (uid != null) {
          final doc = await FirebaseFirestore.instance
              .doc('users/$uid')
              .get();
          final data = doc.data();
          if (data != null && data['staffPermissions'] != null) {
            perms = StaffPermissions.fromMap(
              Map<String, dynamic>.from(data['staffPermissions'] as Map),
            );
          }
        }
      }

      // Enrich all patients with warn status
      final enriched = <LinkedPatient>[];
      for (final p in patients) {
        try {
          enriched.add(await _repo.enrichPatient(p));
        } catch (_) {
          enriched.add(p);
        }
      }

      final today = DateTime.now();
      final appointments = await _repo.getAppointmentsForDate(today);

      // Compute aggregated stats
      DoctorStatsData? stats;
      try {
        stats = await computeDoctorStats(
          enriched,
          FirebaseFirestore.instance,
        );
      } catch (_) {}

      if (mounted) {
        setState(() {
          _doctorName = name;
          _patients = enriched;
          _todayAppointments = appointments;
          _statsData = stats;
          _staffPermissions = perms;
          _loading = false;
        });
      }
    } catch (_) {
      if (mounted) setState(() => _loading = false);
    }
  }

  String _greeting(AppLocalizations l) {
    final hour = DateTime.now().hour;
    if (hour < 12) return l.greetingMorning;
    if (hour < 18) return l.greetingDay;
    return l.greetingEvening;
  }

  String _todayFormatted(AppLocalizations l) {
    final now = DateTime.now();
    final weekdays = [
      l.weekdayMonday, l.weekdayTuesday, l.weekdayWednesday, l.weekdayThursday,
      l.weekdayFriday, l.weekdaySaturday, l.weekdaySunday,
    ];
    final months = [
      l.monthJanuary, l.monthFebruary, l.monthMarch, l.monthApril, l.monthMay, l.monthJune,
      l.monthJuly, l.monthAugust, l.monthSeptember, l.monthOctober, l.monthNovember, l.monthDecember,
    ];
    return '${weekdays[now.weekday - 1]}, ${now.day}. ${months[now.month - 1]} ${now.year}';
  }

  /// Breakpoint above which the desktop 2-column layout is used.
  static const _kDesktopBreakpoint = 900.0;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: AppBackground(
        child: SafeArea(
          child: _loading
              ? const _OverviewShimmer()
              : RefreshIndicator(
                  onRefresh: _loadData,
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      final isWide =
                          constraints.maxWidth >= _kDesktopBreakpoint;
                      return isWide
                          ? _buildWideLayout(theme)
                          : _buildNarrowLayout(theme);
                    },
                  ),
                ),
        ),
      ),
    );
  }

  // ── Narrow (mobile) layout – unchanged linear ListView ──────────
  Widget _buildNarrowLayout(ThemeData theme) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.xl,
        AppSpacing.lg,
        AppSpacing.xl,
        120,
      ),
      children: [
        ..._buildGreeting(theme),
        const SizedBox(height: AppSpacing.xxl),
        ..._buildStatsSection(theme),
        const SizedBox(height: AppSpacing.xl),
        ..._buildTodaySection(theme),
        const SizedBox(height: AppSpacing.xl),
        FadeSlideIn(
          delay: const Duration(milliseconds: 360),
          child: _buildAlertSection(theme),
        ),
        const SizedBox(height: AppSpacing.xl),
        ..._buildQuickActionsSection(context),
      ],
    );
  }

  // ── Wide (desktop) layout – 2-column grid ──────────────────────
  Widget _buildWideLayout(ThemeData theme) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.xl,
        AppSpacing.lg,
        AppSpacing.xl,
        120,
      ),
      children: [
        ..._buildGreeting(theme),
        const SizedBox(height: AppSpacing.xxl),

        // Stats cards in a row
        ..._buildStatsSection(theme),

        const SizedBox(height: AppSpacing.xl),

        // Two-column row: left = today's appointments, right = alerts
        IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: _buildTodaySection(theme),
                ),
              ),
              const SizedBox(width: AppSpacing.xl),
              Expanded(
                child: FadeSlideIn(
                  delay: const Duration(milliseconds: 360),
                  child: _buildAlertSection(theme),
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: AppSpacing.xl),

        // Quick actions as horizontal row
        ..._buildQuickActionsSection(context),
      ],
    );
  }

  // ── Shared section builders ─────────────────────────────────────

  List<Widget> _buildGreeting(ThemeData theme) {
    final l = AppLocalizations.of(context)!;
    return [
      FadeSlideIn(
        child: Row(
          children: [
            Expanded(
              child: Text(
                _doctorName.isNotEmpty
                    ? widget.isStaff
                        ? l.practiceOf(_doctorName)
                        : '${_greeting(l)}, $_doctorName'
                    : _greeting(l),
                style: theme.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            _NotificationBell(
              repo: _notificationRepo,
              doctorUid: widget.doctorUid,
            ),
          ],
        ),
      ),
      const SizedBox(height: AppSpacing.xs),
      FadeSlideIn(
        delay: const Duration(milliseconds: 60),
        child: Text(
          _todayFormatted(l),
          style: theme.textTheme.bodyMedium?.copyWith(
            color: AppColors.textSecondary,
          ),
        ),
      ),
    ];
  }

  List<Widget> _buildStatsSection(ThemeData theme) {
    return [
      if (_statsData != null)
        FadeSlideIn(
          delay: const Duration(milliseconds: 120),
          child: DoctorStatsCard(stats: _statsData!),
        ),
      const SizedBox(height: AppSpacing.lg),
      FadeSlideIn(
        delay: const Duration(milliseconds: 180),
        child: _StatsRow(patients: _patients),
      ),
    ];
  }

  List<Widget> _buildTodaySection(ThemeData theme) {
    final l = AppLocalizations.of(context)!;
    return [
      FadeSlideIn(
        delay: const Duration(milliseconds: 180),
        child: _SectionHeader(
          icon: Icons.today_rounded,
          title: l.today,
          trailing: Text(
            l.appointmentCount(_todayAppointments.length),
            style: theme.textTheme.labelMedium?.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
        ),
      ),
      const SizedBox(height: AppSpacing.sm),
      if (_todayAppointments.isEmpty)
        FadeSlideIn(
          delay: const Duration(milliseconds: 240),
          child: GlassCard(
            child: Row(
              children: [
                Icon(Icons.event_available_rounded,
                    color: AppColors.success, size: 28),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Text(
                    l.noAppointmentsFreeDay,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                ),
              ],
            ),
          ),
        )
      else
        ...(_todayAppointments.take(3).indexed.map((e) =>
            FadeSlideIn(
              delay: Duration(milliseconds: 240 + e.$1 * 60),
              child: _AppointmentRow(pa: e.$2),
            ))),
      if (_todayAppointments.length > 3) ...[
        const SizedBox(height: AppSpacing.sm),
        Center(
          child: TextButton(
            onPressed: () {
              widget.onNavigateToCalendar?.call();
            },
            child: Text(
              l.showAllAppointmentsCount(_todayAppointments.length),
              style: TextStyle(color: AppColors.primary),
            ),
          ),
        ),
      ],
    ];
  }

  List<Widget> _buildQuickActionsSection(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    return [
      FadeSlideIn(
        delay: const Duration(milliseconds: 420),
        child: _SectionHeader(
          icon: Icons.bolt_rounded,
          title: l.quickActions,
        ),
      ),
      const SizedBox(height: AppSpacing.sm),
      FadeSlideIn(
        delay: const Duration(milliseconds: 480),
        child: _buildQuickActions(context),
      ),
    ];
  }

  Widget _buildQuickActions(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final p = _staffPermissions;

    // For doctors (not staff), show all actions. For staff, filter by permissions.
    final showInvite = !widget.isStaff || (p != null && p.canWrite('invites'));
    final showAppointment =
        !widget.isStaff || (p != null && p.canWrite('appointments'));
    final showBroadcast =
        !widget.isStaff || (p != null && p.canWrite('timeline'));
    final showTemplates =
        !widget.isStaff || (p != null && p.canRead('templates'));

    final actions = <Widget>[];

    if (showInvite) {
      actions.add(_QuickActionCard(
        icon: Icons.person_add_rounded,
        label: l.patientInvite,
        color: AppColors.primary,
        onTap: () {
          Haptic.light();
          _showInviteSheet(context);
        },
      ));
    }

    if (showAppointment) {
      actions.add(_QuickActionCard(
        icon: Icons.add_circle_outline_rounded,
        label: l.appointmentCreate,
        color: AppColors.success,
        onTap: () {
          Haptic.light();
        },
      ));
    }

    if (showBroadcast) {
      actions.add(_QuickActionCard(
        icon: Icons.campaign_rounded,
        label: l.broadcastSenden,
        color: AppColors.warning,
        onTap: () {
          Haptic.light();
          _showBroadcastSheet(context);
        },
      ));
    }

    if (showTemplates) {
      actions.add(_QuickActionCard(
        icon: Icons.playlist_add_rounded,
        label: l.templates,
        color: AppColors.accent,
        onTap: () {
          Haptic.light();
          _openTemplates(context);
        },
      ));
    }

    // Monthly aggregate report — always visible for doctors, read permission for staff.
    if (!widget.isStaff || (p != null && p.canRead('reports'))) {
      actions.add(_QuickActionCard(
        icon: Icons.assessment_rounded,
        label: l.monthlyReport,
        color: const Color(0xFF00C7BE),
        onTap: () {
          Haptic.light();
          Navigator.of(context).push(
            MaterialPageRoute<void>(
              builder: (_) => DoctorAggregateReportScreen(
                overrideDoctorUid: widget.doctorUid,
              ),
            ),
          );
        },
      ));
    }

    if (actions.isEmpty) return const SizedBox.shrink();

    // Arrange actions in rows of 2.
    final rows = <Widget>[];
    for (int i = 0; i < actions.length; i += 2) {
      final rowChildren = <Widget>[Expanded(child: actions[i])];
      if (i + 1 < actions.length) {
        rowChildren.add(const SizedBox(width: AppSpacing.md));
        rowChildren.add(Expanded(child: actions[i + 1]));
      } else {
        rowChildren.add(const SizedBox(width: AppSpacing.md));
        rowChildren.add(const Expanded(child: SizedBox.shrink()));
      }
      if (rows.isNotEmpty) {
        rows.add(const SizedBox(height: AppSpacing.md));
      }
      rows.add(Row(children: rowChildren));
    }

    return Column(children: rows);
  }

  Widget _buildAlertSection(ThemeData theme) {
    final alertPatients = _patients
        .where((p) =>
            p.warnStatus == ReportLight.red ||
            p.warnStatus == ReportLight.yellow ||
            p.redFlagCount > 0)
        .toList(growable: false);

    final l = AppLocalizations.of(context)!;

    if (alertPatients.isEmpty) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _SectionHeader(
            icon: Icons.shield_rounded,
            title: l.patientStatus,
          ),
          const SizedBox(height: AppSpacing.sm),
          GlassCard(
            child: Row(
              children: [
                Icon(Icons.check_circle_rounded,
                    color: AppColors.success, size: 28),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Text(
                    l.allPatientsGreen,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      );
    }

    // Sort: highest red flag severity first, then by warnStatus
    alertPatients.sort((a, b) {
      final sevCmp = b.maxRedFlagSeverity.index
          .compareTo(a.maxRedFlagSeverity.index);
      if (sevCmp != 0) return sevCmp;
      return b.warnStatus.index.compareTo(a.warnStatus.index);
    });

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _SectionHeader(
          icon: Icons.warning_amber_rounded,
          title: l.attentionRequired,
          trailing: Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            decoration: BoxDecoration(
              color: AppColors.error.withValues(alpha: 0.1),
              borderRadius: AppRadius.borderRadiusPill,
            ),
            child: Text(
              '${alertPatients.length}',
              style: theme.textTheme.labelSmall?.copyWith(
                color: AppColors.error,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        ...alertPatients.map((p) => _AlertPatientCard(
              patient: p,
              onTap: () {
                Haptic.medium();
                Navigator.of(context).push(
                  MaterialPageRoute<void>(
                    builder: (_) => PatientDetailScreen(
                      patient: p,
                      doctorUid: widget.doctorUid,
                    ),
                  ),
                );
              },
            )),
      ],
    );
  }

  void _showInviteSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.background,
      shape: const RoundedRectangleBorder(
        borderRadius:
            BorderRadius.vertical(top: Radius.circular(AppRadius.xl)),
      ),
      builder: (_) => const InviteSheet(),
    );
  }

  void _showBroadcastSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.background,
      shape: const RoundedRectangleBorder(
        borderRadius:
            BorderRadius.vertical(top: Radius.circular(AppRadius.xl)),
      ),
      builder: (_) => _BroadcastSheet(
        patientCount: _patients.length,
        doctorUid: widget.doctorUid,
      ),
    );
  }

  void _openTemplates(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => const TemplateManagementScreen(),
      ),
    );
  }
}

// ── Stats Row ──────────────────────────────────────────────────────────────

class _StatsRow extends StatelessWidget {
  const _StatsRow({required this.patients});

  final List<LinkedPatient> patients;

  @override
  Widget build(BuildContext context) {
    final preOp =
        patients.where((p) => p.phase == PatientPhase.preOp).length;
    final postOp = patients
        .where((p) {
          return p.phase == PatientPhase.postOp ||
            p.phase == PatientPhase.opDay;
        })
        .length;
    final l = AppLocalizations.of(context)!;
    final discharged =
        patients.where((p) => p.phase == PatientPhase.discharged).length;

    return Row(
      children: [
        Expanded(
          child: _StatCard(
            value: '${patients.length}',
            label: l.totalLabel,
            icon: Icons.people_rounded,
            color: AppColors.primary,
          ),
        ),
        const SizedBox(width: AppSpacing.sm),
        Expanded(
          child: _StatCard(
            value: '$preOp',
            label: l.phasePreOp,
            icon: Icons.schedule_rounded,
            color: AppColors.warning,
          ),
        ),
        const SizedBox(width: AppSpacing.sm),
        Expanded(
          child: _StatCard(
            value: '$postOp',
            label: l.phasePostOp,
            icon: Icons.healing_rounded,
            color: AppColors.success,
          ),
        ),
        const SizedBox(width: AppSpacing.sm),
        Expanded(
          child: _StatCard(
            value: '$discharged',
            label: l.phaseDischarged,
            icon: Icons.check_circle_outline_rounded,
            color: AppColors.accent,
          ),
        ),
      ],
    );
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard({
    required this.value,
    required this.label,
    required this.icon,
    required this.color,
  });

  final String value;
  final String label;
  final IconData icon;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final numValue = int.tryParse(value) ?? 0;

    return GlassContainer(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: AppSpacing.md,
      ),
      child: Column(
        children: [
          TweenAnimationBuilder<double>(
            tween: Tween(begin: 0, end: 1),
            duration: const Duration(milliseconds: 600),
            curve: Curves.easeOutBack,
            builder: (_, scale, child) => Transform.scale(
              scale: scale,
              child: child,
            ),
            child: Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.12),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: color, size: 18),
            ),
          ),
          const SizedBox(height: AppSpacing.xs),
          TweenAnimationBuilder<int>(
            tween: IntTween(begin: 0, end: numValue),
            duration: const Duration(milliseconds: 800),
            curve: Curves.easeOutCubic,
            builder: (_, val, _) => Text(
              '$val',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
            ),
          ),
          const SizedBox(height: AppSpacing.xxs),
          Text(
            label,
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: AppColors.textSecondary,
                ),
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}

// ── Section Header ─────────────────────────────────────────────────────────

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({
    required this.icon,
    required this.title,
    this.trailing,
  });

  final IconData icon;
  final String title;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 18, color: AppColors.textSecondary),
        const SizedBox(width: AppSpacing.sm),
        Expanded(
          child: Text(
            title,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
          ),
        ),
        ?trailing,
      ],
    );
  }
}

// ── Appointment Row ────────────────────────────────────────────────────────

class _AppointmentRow extends StatelessWidget {
  const _AppointmentRow({required this.pa});

  final PatientAppointment pa;

  @override
  Widget build(BuildContext context) {
    final a = pa.appointment;
    final time =
        '${a.startAt.hour.toString().padLeft(2, '0')}:${a.startAt.minute.toString().padLeft(2, '0')}';

    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: GlassCard(
        child: Row(
          children: [
            // Time column
            Container(
              width: 52,
              padding: const EdgeInsets.symmetric(
                  horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: a.type.color.withValues(alpha: 0.1),
                borderRadius: AppRadius.borderRadiusSm,
              ),
              child: Center(
                child: Text(
                  time,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: a.type.color,
                  ),
                ),
              ),
            ),
            const SizedBox(width: AppSpacing.md),
            // Details
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    a.title,
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    pa.patient.displayName,
                    style: TextStyle(
                        fontSize: 12, color: AppColors.textSecondary),
                  ),
                ],
              ),
            ),
            // Type icon
            Icon(a.type.icon, size: 18, color: a.type.color),
          ],
        ),
      ),
    );
  }
}

// ── Alert Patient Card ─────────────────────────────────────────────────────

class _AlertPatientCard extends StatelessWidget {
  const _AlertPatientCard({
    required this.patient,
    required this.onTap,
  });

  final LinkedPatient patient;
  final VoidCallback onTap;

  Color _severityColor() {
    if (patient.redFlagCount > 0) {
      return switch (patient.maxRedFlagSeverity) {
        RedFlagSeverity.red => AppColors.error,
        RedFlagSeverity.orange => AppColors.warning,
        RedFlagSeverity.yellow => const Color(0xFFFFCC00),
        RedFlagSeverity.green => AppColors.success,
      };
    }
    return switch (patient.warnStatus) {
      ReportLight.red => AppColors.error,
      ReportLight.yellow => AppColors.warning,
      ReportLight.green => AppColors.success,
      ReportLight.unknown => AppColors.grey400,
    };
  }

  IconData _severityIcon() {
    if (patient.redFlagCount > 0) {
      return switch (patient.maxRedFlagSeverity) {
        RedFlagSeverity.red => Icons.error_rounded,
        RedFlagSeverity.orange => Icons.warning_amber_rounded,
        RedFlagSeverity.yellow => Icons.info_rounded,
        RedFlagSeverity.green => Icons.check_circle_rounded,
      };
    }
    return switch (patient.warnStatus) {
      ReportLight.red => Icons.error_rounded,
      ReportLight.yellow => Icons.warning_rounded,
      ReportLight.green => Icons.check_circle_rounded,
      ReportLight.unknown => Icons.help_outline_rounded,
    };
  }

  String _phaseLabel(PatientPhase phase, AppLocalizations l) => switch (phase) {
        PatientPhase.preOp => l.phasePreOp,
        PatientPhase.opDay => l.phaseOpDay,
        PatientPhase.postOp => l.phasePostOp,
        PatientPhase.discharged => l.phaseDischarged,
      };

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final color = _severityColor();

    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: GlassCard(
        onTap: onTap,
        child: Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.12),
                shape: BoxShape.circle,
              ),
              child: Icon(
                _severityIcon(),
                color: color,
                size: 20,
              ),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    patient.displayName,
                    style: Theme.of(context)
                        .textTheme
                        .titleSmall
                        ?.copyWith(fontWeight: FontWeight.w600),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Row(
                    children: [
                      Text(
                        _phaseLabel(patient.phase, l),
                        style: const TextStyle(
                          fontSize: 12,
                          color: AppColors.textSecondary,
                        ),
                      ),
                      if (patient.redFlagCount > 0) ...[
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 1,
                          ),
                          decoration: BoxDecoration(
                            color: color.withValues(alpha: 0.10),
                            borderRadius: AppRadius.borderRadiusPill,
                          ),
                          child: Text(
                            l.redFlagCountLabel(patient.redFlagCount),
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w700,
                              color: color,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),
            Icon(Icons.chevron_right_rounded,
                color: AppColors.grey400, size: 20),
          ],
        ),
      ),
    );
  }
}

// ── Quick Action Card ──────────────────────────────────────────────────────

class _QuickActionCard extends StatelessWidget {
  const _QuickActionCard({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return PressableScale(
      onTap: onTap,
      child: GlassContainer(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.lg,
        ),
        child: Column(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    color.withValues(alpha: 0.15),
                    color.withValues(alpha: 0.05),
                  ],
                ),
                shape: BoxShape.circle,
                border: Border.all(
                  color: color.withValues(alpha: 0.2),
                ),
              ),
              child: Icon(icon, color: color, size: 22),
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              label,
              style: Theme.of(context).textTheme.labelMedium?.copyWith(
                    fontWeight: FontWeight.w500,
                  ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

// ── Shimmer skeleton loading ───────────────────────────────────────────────

class _OverviewShimmer extends StatefulWidget {
  const _OverviewShimmer();

  @override
  State<_OverviewShimmer> createState() => _OverviewShimmerState();
}

class _OverviewShimmerState extends State<_OverviewShimmer>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _ctrl,
      builder: (_, _) {
        final shimmerColor = ColorTween(
          begin: AppColors.grey200.withValues(alpha: 0.3),
          end: AppColors.grey200.withValues(alpha: 0.8),
        ).evaluate(CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut))!;

        return ListView(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.xl, AppSpacing.lg, AppSpacing.xl, 120,
          ),
          children: [
            // Greeting skeleton
            _shimmerBox(shimmerColor, 200, 24),
            const SizedBox(height: AppSpacing.xs),
            _shimmerBox(shimmerColor, 160, 14),
            const SizedBox(height: AppSpacing.xxl),

            // Stats row skeleton
            Row(
              children: List.generate(
                4,
                (i) => Expanded(
                  child: Padding(
                    padding: EdgeInsets.only(left: i > 0 ? AppSpacing.sm : 0),
                    child: _shimmerBox(shimmerColor, double.infinity, 72,
                        borderRadius: AppRadius.borderRadiusLg),
                  ),
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.xl),

            // Section header skeleton
            _shimmerBox(shimmerColor, 120, 18),
            const SizedBox(height: AppSpacing.md),

            // Cards skeleton
            for (int i = 0; i < 3; i++) ...[
              _shimmerBox(shimmerColor, double.infinity, 60,
                  borderRadius: AppRadius.borderRadiusLg),
              const SizedBox(height: AppSpacing.sm),
            ],
          ],
        );
      },
    );
  }

  Widget _shimmerBox(Color color, double width, double height,
      {BorderRadius? borderRadius}) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: color,
        borderRadius: borderRadius ?? BorderRadius.circular(6),
      ),
    );
  }
}

// ── Broadcast sheet ─────────────────────────────────────────────────────────

class _BroadcastSheet extends StatefulWidget {
  const _BroadcastSheet({required this.patientCount, this.doctorUid});

  final int patientCount;
  final String? doctorUid;

  @override
  State<_BroadcastSheet> createState() => _BroadcastSheetState();
}

class _BroadcastSheetState extends State<_BroadcastSheet> {
  final _titleCtrl = TextEditingController();
  final _bodyCtrl = TextEditingController();
  TaskPriority _priority = TaskPriority.normal;
  bool _sending = false;

  @override
  void dispose() {
    _titleCtrl.dispose();
    _bodyCtrl.dispose();
    super.dispose();
  }

  Future<void> _send() async {
    final l = AppLocalizations.of(context)!;
    final title = _titleCtrl.text.trim();
    final body = _bodyCtrl.text.trim();
    if (title.isEmpty) return;

    setState(() => _sending = true);
    try {
      final repo = DoctorPatientRepository(
        overrideDoctorUid: widget.doctorUid,
      );
      final count = await repo.broadcastMessage(
        title: title,
        body: body,
        priority: _priority,
      );
      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(l.broadcastSentCount(count)),
          ),
        );
      }
    } catch (e, stack) {
      debugPrint('[Broadcast] send failed: $e\n$stack');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(userFacingError(e))),
        );
      }
    } finally {
      if (mounted) setState(() => _sending = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    return SafeArea(
      child: Padding(
        padding: EdgeInsets.only(
          left: AppSpacing.xl,
          right: AppSpacing.xl,
          top: AppSpacing.lg,
          bottom: MediaQuery.of(context).viewInsets.bottom + AppSpacing.lg,
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Center(
                child: Container(
                  width: 36,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppColors.grey400,
                    borderRadius: AppRadius.borderRadiusPill,
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.lg),
              Text(
                l.broadcastToAllPatients,
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: AppSpacing.xs),
              Text(
                l.broadcastWillBeSentTo(widget.patientCount),
                style: const TextStyle(color: AppColors.textSecondary),
              ),
              const SizedBox(height: AppSpacing.lg),

              TextField(
                controller: _titleCtrl,
                decoration: InputDecoration(labelText: l.title),
              ),
              const SizedBox(height: AppSpacing.md),
              TextField(
                controller: _bodyCtrl,
                decoration: InputDecoration(labelText: l.message),
                maxLines: 3,
              ),
              SizedBox(height: AppSpacing.md),

              DropdownButtonFormField<TaskPriority>(
                value: _priority,
                items: [
                  DropdownMenuItem(
                      value: TaskPriority.low, child: Text(l.low)),
                  DropdownMenuItem(
                      value: TaskPriority.normal, child: Text(l.normal)),
                  DropdownMenuItem(
                      value: TaskPriority.high, child: Text(l.high)),
                  DropdownMenuItem(
                      value: TaskPriority.critical, child: Text(l.urgent)),
                ],
                onChanged: (v) {
                  if (v != null) setState(() => _priority = v);
                },
                decoration: InputDecoration(labelText: l.prioritaet),
              ),
              const SizedBox(height: AppSpacing.xl),

              FilledButton.icon(
                onPressed: _sending ? null : _send,
                icon: const Icon(Icons.campaign_rounded),
                label: Text(
                    _sending ? l.sending : l.broadcastSend),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Notification bell with unread badge
// ─────────────────────────────────────────────────────────────────────────────

class _NotificationBell extends StatelessWidget {
  const _NotificationBell({required this.repo, this.doctorUid});

  final DoctorNotificationRepository repo;
  final String? doctorUid;

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<int>(
      stream: repo.watchUnreadCount(),
      builder: (context, snap) {
        final l = AppLocalizations.of(context)!;
        final count = snap.data ?? 0;
        return Stack(
          clipBehavior: Clip.none,
          children: [
            IconButton(
              onPressed: () => Navigator.of(context).push(
                MaterialPageRoute<void>(
                  builder: (_) => DoctorNotificationScreen(
                    overrideDoctorUid: doctorUid,
                  ),
                ),
              ),
              icon: Icon(
                count > 0
                    ? Icons.notifications_rounded
                    : Icons.notifications_none_rounded,
                color: AppColors.primary,
              ),
              tooltip: l.notifications,
            ),
            if (count > 0)
              Positioned(
                right: 4,
                top: 4,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 5, vertical: 1),
                  decoration: BoxDecoration(
                    color: AppColors.error,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  constraints: const BoxConstraints(
                    minWidth: 18,
                    minHeight: 18,
                  ),
                  child: Text(
                    count > 99 ? '99+' : '$count',
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: AppColors.white,
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
          ],
        );
      },
    );
  }
}
