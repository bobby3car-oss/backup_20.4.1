import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../../../auth/auth_service.dart';
import '../../../firebase/firebase_paths.dart';
import '../../../ui/ui.dart';
import '../../observations/data/observation_repository.dart';
import '../../observations/domain/observation_entry.dart';
import '../data/family_repository.dart';
import '../domain/linked_family_patient.dart';
import 'family_message_screen.dart';
import 'family_patient_detail_screen.dart';

/// Dashboard / overview tab shown to family member accounts.
///
/// Renders a rich status card per linked patient showing the OP countdown,
/// a recovery-progress bar (post-OP), any active red-flag alerts, and
/// quick-action buttons (message / observation / full details).
class FamilyOverviewTab extends StatelessWidget {
  const FamilyOverviewTab({super.key});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    final firstName = (user?.displayName ?? '').split(' ').first;
    final hour = DateTime.now().hour;
    final greeting =
        hour < 12 ? 'Guten Morgen' : (hour < 18 ? 'Hallo' : 'Guten Abend');
    final title = firstName.isEmpty ? greeting : '$greeting, $firstName';

    return GlassPage(
      title: title,
      titleEmoji: '🤝',
      titleColor: AppColors.primary,
      showBackButton: false,
      horizontalPadding: AppSpacing.lg,
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            icon: const Icon(Icons.person_add_rounded),
            tooltip: 'Patient hinzufügen',
            onPressed: () => _showAddPatientDialog(context),
          ),
          IconButton(
            icon: const Icon(Icons.logout_rounded),
            tooltip: 'Abmelden',
            onPressed: () async => AuthService().signOut(),
          ),
        ],
      ),
      children: [
        StreamBuilder<List<LinkedFamilyPatient>>(
          stream: FamilyRepository().watchLinkedPatients(),
          builder: (context, snap) {
            if (snap.connectionState == ConnectionState.waiting) {
              return const Padding(
                padding: EdgeInsets.only(top: 80),
                child: Center(child: CircularProgressIndicator()),
              );
            }
            if (snap.hasError) {
              return _ErrorCard(message: '${snap.error}');
            }
            final patients = snap.data ?? [];
            if (patients.isEmpty) {
              return _EmptyState(onAdd: () => _showAddPatientDialog(context));
            }
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  patients.length == 1
                      ? 'Du begleitest 1 Person'
                      : 'Du begleitest ${patients.length} Personen',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppColors.textSecondary,
                      ),
                ),
                const SizedBox(height: AppSpacing.lg),
                for (int i = 0; i < patients.length; i++) ...[
                  FadeSlideIn(
                    delay: Duration(milliseconds: 80 + i * 100),
                    child: _PatientStatusCard(
                      patient: patients[i],
                      onDetailsTap: () =>
                          _navigateToDetail(context, patients[i]),
                      onMessageTap: () =>
                          _navigateToMessage(context, patients[i]),
                      onObservationTap: () => _showObservationDialog(
                          context, patients[i].patientId),
                    ),
                  ),
                  if (i < patients.length - 1)
                    const SizedBox(height: AppSpacing.lg),
                ],
                const SizedBox(height: AppSpacing.xxl),
                GlassButton(
                  onPressed: () => _showAddPatientDialog(context),
                  label: 'Weiteren Patienten hinzufügen',
                  icon: Icons.person_add_rounded,
                  variant: GlassButtonVariant.secondary,
                  expand: true,
                ),
                const SizedBox(height: 100),
              ],
            );
          },
        ),
      ],
    );
  }

  void _navigateToDetail(BuildContext context, LinkedFamilyPatient patient) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => FamilyPatientDetailScreen(patient: patient),
      ),
    );
  }

  void _navigateToMessage(BuildContext context, LinkedFamilyPatient patient) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => FamilyMessageScreen(patient: patient),
      ),
    );
  }

  void _showObservationDialog(BuildContext context, String patientId) {
    final textCtrl = TextEditingController();
    var severity = ObservationSeverity.info;

    showDialog<void>(
      context: context,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: const Text('Beobachtung erfassen'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: textCtrl,
                    maxLines: 4,
                    decoration: const InputDecoration(
                      labelText: 'Was hast du beobachtet?',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 12),
                  SegmentedButton<ObservationSeverity>(
                    segments: const [
                      ButtonSegment(
                        value: ObservationSeverity.info,
                        label: Text('Info'),
                        icon: Icon(Icons.info_outline),
                      ),
                      ButtonSegment(
                        value: ObservationSeverity.warning,
                        label: Text('Warnung'),
                        icon: Icon(Icons.warning_amber),
                      ),
                      ButtonSegment(
                        value: ObservationSeverity.critical,
                        label: Text('Kritisch'),
                        icon: Icon(Icons.error_outline),
                      ),
                    ],
                    selected: {severity},
                    onSelectionChanged: (s) =>
                        setDialogState(() => severity = s.first),
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(ctx).pop(),
                  child: const Text('Abbrechen'),
                ),
                FilledButton(
                  onPressed: () async {
                    final text = textCtrl.text.trim();
                    if (text.isEmpty) return;
                    await ObservationRepository().addObservation(
                      patientId: patientId,
                      text: text,
                      severity: severity,
                    );
                    if (ctx.mounted) Navigator.of(ctx).pop();
                  },
                  child: const Text('Speichern'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _showAddPatientDialog(BuildContext context) {
    final codeCtrl = TextEditingController();
    bool busy = false;

    showDialog<void>(
      context: context,
      builder: (dialogCtx) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: const Text('Patient hinzufügen'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    'Gib den Einladungscode ein, den du vom '
                    'Patienten erhalten hast.',
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: codeCtrl,
                    textCapitalization: TextCapitalization.characters,
                    decoration: const InputDecoration(
                      labelText: 'Einladungscode',
                      hintText: 'z.B. A1B2C3D4E5F6',
                      prefixIcon: Icon(Icons.vpn_key_outlined),
                      border: OutlineInputBorder(),
                    ),
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed:
                      busy ? null : () => Navigator.of(dialogCtx).pop(),
                  child: const Text('Abbrechen'),
                ),
                FilledButton(
                  onPressed: busy
                      ? null
                      : () async {
                          final code = codeCtrl.text.trim().toUpperCase();
                          if (code.isEmpty) return;
                          setDialogState(() => busy = true);
                          try {
                            await FirebaseFunctions.instance
                                .httpsCallable('acceptInvite')
                                .call<Map<String, dynamic>>({'code': code});
                            if (dialogCtx.mounted) {
                              Navigator.of(dialogCtx).pop();
                            }
                          } catch (e) {
                            setDialogState(() => busy = false);
                            if (dialogCtx.mounted) {
                              ScaffoldMessenger.of(dialogCtx).showSnackBar(
                                SnackBar(content: Text('Fehler: $e')),
                              );
                            }
                          }
                        },
                  child: busy
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Text('Verbinden'),
                ),
              ],
            );
          },
        );
      },
    );
  }
}

// ═════════════════════════════════════════════════════════════════════════════
// Op data helper model
// ═════════════════════════════════════════════════════════════════════════════

class _OpData {
  const _OpData({required this.daysOffset, required this.opDate});

  /// Positive = days until OP, 0 = today, negative = days since OP.
  final int daysOffset;
  final DateTime opDate;

  bool get isPreOp => daysOffset > 0;
  bool get isToday => daysOffset == 0;
  bool get isPostOp => daysOffset < 0;
  int get daysSinceOp => -daysOffset;

  /// Standard 42-day (6-week) recovery window.
  double get recoveryProgress =>
      isPostOp ? (daysSinceOp / 42.0).clamp(0.0, 1.0) : 0.0;

  Color get statusColor {
    if (isToday) return AppColors.warning;
    if (isPreOp) return AppColors.primary;
    return AppColors.success;
  }

  String get label {
    if (isToday) return 'Heute ist der OP-Tag!';
    if (isPreOp) {
      return daysOffset == 1
          ? 'Morgen ist die Operation'
          : 'Noch $daysOffset Tage bis zur Operation';
    }
    if (daysSinceOp == 1) return 'Tag 1 der Genesung';
    return 'Tag $daysSinceOp der Genesung';
  }

  IconData get icon {
    if (isToday) return Icons.local_hospital_rounded;
    if (isPreOp) return Icons.schedule_rounded;
    return Icons.favorite_outline_rounded;
  }
}

// ═════════════════════════════════════════════════════════════════════════════
// Patient Status Card
// ═════════════════════════════════════════════════════════════════════════════

class _PatientStatusCard extends StatefulWidget {
  const _PatientStatusCard({
    required this.patient,
    required this.onDetailsTap,
    required this.onMessageTap,
    required this.onObservationTap,
  });

  final LinkedFamilyPatient patient;
  final VoidCallback onDetailsTap;
  final VoidCallback onMessageTap;
  final VoidCallback onObservationTap;

  @override
  State<_PatientStatusCard> createState() => _PatientStatusCardState();
}

class _PatientStatusCardState extends State<_PatientStatusCard> {
  Stream<int>? _redFlagStream;

  @override
  void initState() {
    super.initState();
    if (widget.patient.visibility.redFlags) {
      _redFlagStream = FirebaseFirestore.instance
          .collection(
            '${FirestorePaths.patientDoc(widget.patient.patientId)}/red_flags',
          )
          .snapshots()
          .map((s) => s.docs.length);
    }
  }

  _OpData? get _opData {
    final opDate = widget.patient.opDate;
    if (opDate == null) return null;
    final today = DateTime(
      DateTime.now().year,
      DateTime.now().month,
      DateTime.now().day,
    );
    final opDay = DateTime(opDate.year, opDate.month, opDate.day);
    return _OpData(
      daysOffset: opDay.difference(today).inDays,
      opDate: opDate,
    );
  }

  @override
  Widget build(BuildContext context) {
    final p = widget.patient;
    final tt = Theme.of(context).textTheme;
    final opData = _opData;

    return ClipRRect(
      borderRadius: AppRadius.borderRadiusLg,
      child: GlassContainer(
        padding: EdgeInsets.zero,
        elevation: GlassElevation.medium,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Tappable top section ──────────────────────────────
            GestureDetector(
              onTap: widget.onDetailsTap,
              behavior: HitTestBehavior.opaque,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header row
                  Padding(
                    padding: const EdgeInsets.fromLTRB(
                      AppSpacing.lg,
                      AppSpacing.lg,
                      AppSpacing.md,
                      AppSpacing.lg,
                    ),
                    child: Row(
                      children: [
                        _AvatarCircle(
                          initials: p.avatarInitials,
                          color: opData?.statusColor ?? AppColors.primary,
                        ),
                        const SizedBox(width: AppSpacing.md),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                p.patientName,
                                style: tt.titleMedium?.copyWith(
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              if (p.opType != null)
                                Text(
                                  p.opType!,
                                  style: tt.bodySmall?.copyWith(
                                    color: AppColors.textSecondary,
                                  ),
                                ),
                            ],
                          ),
                        ),
                        const Icon(
                          Icons.chevron_right_rounded,
                          color: AppColors.textSecondary,
                        ),
                      ],
                    ),
                  ),

                  // Op status strip
                  if (opData != null) ...[
                    const Divider(
                      height: 1,
                      thickness: 0.5,
                      indent: AppSpacing.lg,
                      endIndent: AppSpacing.lg,
                    ),
                    _OpStatusStrip(opData: opData),
                  ],

                  // Red flag alert (streamed, only when granted)
                  if (_redFlagStream != null)
                    StreamBuilder<int>(
                      stream: _redFlagStream,
                      builder: (context, snap) {
                        final count = snap.data ?? 0;
                        if (count == 0) return const SizedBox.shrink();
                        return _RedFlagBanner(count: count);
                      },
                    ),
                ],
              ),
            ),

            // ── Action row ────────────────────────────────────────
            const Divider(height: 1, thickness: 0.5),
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.md,
                vertical: AppSpacing.sm,
              ),
              child: Row(
                children: [
                  _ActionChip(
                    icon: Icons.chat_bubble_outline_rounded,
                    label: 'Nachricht',
                    onTap: widget.onMessageTap,
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  _ActionChip(
                    icon: Icons.add_comment_outlined,
                    label: 'Beobachtung',
                    onTap: widget.onObservationTap,
                  ),
                  const Spacer(),
                  TextButton(
                    onPressed: widget.onDetailsTap,
                    style: TextButton.styleFrom(
                      foregroundColor: AppColors.primary,
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.md,
                        vertical: AppSpacing.xs,
                      ),
                      minimumSize: Size.zero,
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'Details',
                          style: Theme.of(context)
                              .textTheme
                              .labelMedium
                              ?.copyWith(
                                color: AppColors.primary,
                                fontWeight: FontWeight.w600,
                              ),
                        ),
                        const SizedBox(width: 2),
                        const Icon(
                          Icons.arrow_forward_ios_rounded,
                          size: 12,
                          color: AppColors.primary,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ═════════════════════════════════════════════════════════════════════════════
// Sub-widgets
// ═════════════════════════════════════════════════════════════════════════════

class _AvatarCircle extends StatelessWidget {
  const _AvatarCircle({required this.initials, required this.color});

  final String initials;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 52,
      height: 52,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(
          colors: [color, color.withValues(alpha: 0.7)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 0.3),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      alignment: Alignment.center,
      child: Text(
        initials,
        style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.w700,
            ),
      ),
    );
  }
}

class _OpStatusStrip extends StatelessWidget {
  const _OpStatusStrip({required this.opData});

  final _OpData opData;

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;
    final color = opData.statusColor;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.lg,
        vertical: AppSpacing.md,
      ),
      color: color.withValues(alpha: 0.07),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(opData.icon, size: 15, color: color),
              const SizedBox(width: AppSpacing.xs),
              Expanded(
                child: Text(
                  opData.label,
                  style: tt.bodySmall?.copyWith(
                    color: color,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              if (opData.isPostOp)
                Text(
                  '${(opData.recoveryProgress * 100).round()}%',
                  style: tt.labelSmall?.copyWith(
                    color: color,
                    fontWeight: FontWeight.w700,
                  ),
                ),
            ],
          ),
          if (opData.isPostOp) ...[
            const SizedBox(height: AppSpacing.sm),
            GlassProgressBar(
              value: opData.recoveryProgress,
              height: 6,
              fillColor: color,
              gradient: LinearGradient(
                colors: [color, color.withValues(alpha: 0.55)],
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _RedFlagBanner extends StatelessWidget {
  const _RedFlagBanner({required this.count});

  final int count;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.lg,
        vertical: AppSpacing.sm,
      ),
      color: AppColors.error.withValues(alpha: 0.08),
      child: Row(
        children: [
          const Icon(Icons.flag_rounded, size: 16, color: AppColors.error),
          const SizedBox(width: AppSpacing.sm),
          Text(
            count == 1
                ? '1 aktiver Warnhinweis'
                : '$count aktive Warnhinweise',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: AppColors.error,
                  fontWeight: FontWeight.w600,
                ),
          ),
        ],
      ),
    );
  }
}

class _ActionChip extends StatelessWidget {
  const _ActionChip({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.sm,
        ),
        decoration: BoxDecoration(
          color: AppColors.primary.withValues(alpha: 0.08),
          borderRadius: AppRadius.borderRadiusSm,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 15, color: AppColors.primary),
            const SizedBox(width: AppSpacing.xs),
            Text(
              label,
              style: Theme.of(context).textTheme.labelMedium?.copyWith(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w600,
                  ),
            ),
          ],
        ),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.onAdd});

  final VoidCallback onAdd;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 60),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Icons.group_add_rounded,
            size: 64,
            color: AppColors.grey400,
          ),
          const SizedBox(height: AppSpacing.lg),
          Text(
            'Noch keine Verknüpfung',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            'Lass dich über einen Einladungscode\n'
            'mit einem Patienten verbinden.',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppColors.textSecondary,
                ),
          ),
          const SizedBox(height: AppSpacing.xxl),
          GlassButton(
            onPressed: onAdd,
            label: 'Code eingeben',
            icon: Icons.vpn_key_rounded,
          ),
        ],
      ),
    );
  }
}

class _ErrorCard extends StatelessWidget {
  const _ErrorCard({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return GlassContainer(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Row(
        children: [
          const Icon(Icons.error_outline, color: AppColors.error),
          const SizedBox(width: AppSpacing.md),
          Expanded(child: Text(message)),
        ],
      ),
    );
  }
}
