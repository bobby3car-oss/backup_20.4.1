import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../../../firebase/firebase_paths.dart';
import '../../../ui/ui.dart';
import '../../observations/data/observation_repository.dart';
import '../../observations/domain/observation_entry.dart';
import '../data/family_repository.dart';
import '../domain/linked_family_patient.dart';
import 'family_message_screen.dart';
import 'family_patient_detail_screen.dart';
import '../../../l10n/app_localizations.dart';

/// Dashboard / overview tab shown to family member accounts.
///
/// Modelled after the doctor overview tab: greeting, stats row, alert
/// patients, patient cards with search, and quick actions.
class FamilyOverviewTab extends StatefulWidget {
  const FamilyOverviewTab({super.key});

  @override
  State<FamilyOverviewTab> createState() => _FamilyOverviewTabState();
}

class _FamilyOverviewTabState extends State<FamilyOverviewTab> {
  final _repo = FamilyRepository();
  String _searchQuery = '';

  String get _greeting {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Guten Morgen';
    if (hour < 18) return 'Hallo';
    return 'Guten Abend';
  }

  String get _todayFormatted {
    final now = DateTime.now();
    const weekdays = [
      'Montag', 'Dienstag', 'Mittwoch', 'Donnerstag',
      'Freitag', 'Samstag', 'Sonntag',
    ];
    const months = [
      'Januar', 'Februar', 'März', 'April', 'Mai', 'Juni',
      'Juli', 'August', 'September', 'Oktober', 'November', 'Dezember',
    ];
    return '${weekdays[now.weekday - 1]}, ${now.day}. ${months[now.month - 1]} ${now.year}';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final user = FirebaseAuth.instance.currentUser;
    final firstName = (user?.displayName ?? '').split(' ').first;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: AppBackground(
        child: SafeArea(
          child: StreamBuilder<List<LinkedFamilyPatient>>(
            stream: _repo.watchLinkedPatients(),
            builder: (context, snap) {
              if (snap.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }
              if (snap.hasError) {
                return Center(child: _ErrorCard(message: '${snap.error}'));
              }
              final patients = snap.data ?? [];
              if (patients.isEmpty) {
                return _EmptyState(
                    onAdd: () => _showAddPatientDialog(context));
              }

              // Calculate stats
              final redFlagPatients = patients.where(
                  (p) => p.visibility.redFlags).toList();
              final postOpCount = patients.where((p) {
                if (p.opDate == null) return false;
                return p.opDate!.isBefore(DateTime.now());
              }).length;
              final preOpCount = patients.length - postOpCount;

              // Search filter
              final filtered = _searchQuery.isEmpty
                  ? patients
                  : patients.where((p) => p.patientName
                      .toLowerCase()
                      .contains(_searchQuery.toLowerCase())).toList();

              return ListView(
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.xl,
                  AppSpacing.lg,
                  AppSpacing.xl,
                  120,
                ),
                children: [
                  // ── Greeting ─────────────────────────────────
                  FadeSlideIn(
                    child: Text(
                      firstName.isNotEmpty
                          ? '$_greeting, $firstName'
                          : _greeting,
                      style: theme.textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  FadeSlideIn(
                    delay: const Duration(milliseconds: 60),
                    child: Text(
                      _todayFormatted,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ),

                  const SizedBox(height: AppSpacing.xxl),

                  // ── Stats row ────────────────────────────────
                  FadeSlideIn(
                    delay: const Duration(milliseconds: 120),
                    child: Row(
                      children: [
                        Expanded(
                          child: _StatCard(
                            icon: Icons.people_rounded,
                            label: 'Patienten',
                            value: '${patients.length}',
                            color: AppColors.primary,
                          ),
                        ),
                        const SizedBox(width: AppSpacing.sm),
                        Expanded(
                          child: _StatCard(
                            icon: Icons.schedule_rounded,
                            label: 'Prä-OP',
                            value: '$preOpCount',
                            color: AppColors.accent,
                          ),
                        ),
                        const SizedBox(width: AppSpacing.sm),
                        Expanded(
                          child: _StatCard(
                            icon: Icons.favorite_rounded,
                            label: 'Post-OP',
                            value: '$postOpCount',
                            color: AppColors.success,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: AppSpacing.xl),

                  // ── Alert patients ───────────────────────────
                  if (redFlagPatients.isNotEmpty) ...[
                    FadeSlideIn(
                      delay: const Duration(milliseconds: 180),
                      child: _SectionHeader(
                        icon: Icons.warning_amber_rounded,
                        title: 'Aufmerksamkeit erforderlich',
                      ),
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    ...redFlagPatients.indexed.map((e) => FadeSlideIn(
                          delay: Duration(milliseconds: 240 + e.$1 * 60),
                          child: _AlertPatientCard(
                            patient: e.$2,
                            onTap: () =>
                                _navigateToDetail(context, e.$2),
                          ),
                        )),
                    const SizedBox(height: AppSpacing.xl),
                  ],

                  // ── Patient list header ──────────────────────
                  FadeSlideIn(
                    delay: const Duration(milliseconds: 300),
                    child: Row(
                      children: [
                        _SectionHeader(
                          icon: Icons.people_rounded,
                          title: 'Meine Patienten',
                        ),
                        const Spacer(),
                        PressableScale(
                          onTap: () {
                            Haptic.light();
                            _showAddPatientDialog(context);
                          },
                          child: Container(
                            width: 36,
                            height: 36,
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                colors: [
                                  AppColors.primary,
                                  AppColors.accent,
                                ],
                              ),
                              borderRadius: AppRadius.borderRadiusSm,
                            ),
                            child: const Icon(
                              Icons.person_add_rounded,
                              color: Colors.white,
                              size: 18,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: AppSpacing.md),

                  // ── Search bar ───────────────────────────────
                  if (patients.length > 1)
                    FadeSlideIn(
                      delay: const Duration(milliseconds: 360),
                      child: GlassTextField(
                        hint: 'Patient suchen…',
                        prefixIcon: Icons.search_rounded,
                        onChanged: (val) =>
                            setState(() => _searchQuery = val),
                      ),
                    ),
                  if (patients.length > 1)
                    const SizedBox(height: AppSpacing.md),

                  // ── Patient cards ────────────────────────────
                  for (int i = 0; i < filtered.length; i++) ...[
                    FadeSlideIn(
                      delay: Duration(milliseconds: 400 + i * 80),
                      child: _PatientCard(
                        patient: filtered[i],
                        onTap: () =>
                            _navigateToDetail(context, filtered[i]),
                        onMessageTap: () =>
                            _navigateToMessage(context, filtered[i]),
                        onObservationTap: () => _showObservationDialog(
                            context, filtered[i].patientId),
                      ),
                    ),
                    if (i < filtered.length - 1)
                      const SizedBox(height: AppSpacing.md),
                  ],

                  if (filtered.isEmpty && _searchQuery.isNotEmpty)
                    FadeSlideIn(
                      delay: const Duration(milliseconds: 400),
                      child: GlassCard(
                        child: Center(
                          child: Padding(
                            padding:
                                const EdgeInsets.all(AppSpacing.xl),
                            child: Text(
                              'Kein Patient gefunden.',
                              style: theme.textTheme.bodyMedium
                                  ?.copyWith(
                                      color: AppColors.textSecondary),
                            ),
                          ),
                        ),
                      ),
                    ),

                  const SizedBox(height: AppSpacing.xl),

                  // ── Quick actions ────────────────────────────
                  FadeSlideIn(
                    delay: const Duration(milliseconds: 480),
                    child: _SectionHeader(
                      icon: Icons.bolt_rounded,
                      title: 'Schnellaktionen',
                    ),
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  FadeSlideIn(
                    delay: const Duration(milliseconds: 540),
                    child: Wrap(
                      spacing: AppSpacing.sm,
                      runSpacing: AppSpacing.sm,
                      children: [
                        _QuickActionCard(
                          icon: Icons.person_add_rounded,
                          label: 'Patient\nhinzufügen',
                          color: AppColors.primary,
                          onTap: () => _showAddPatientDialog(context),
                        ),
                        if (patients.length == 1)
                          _QuickActionCard(
                            icon: Icons.chat_bubble_outline_rounded,
                            label: 'Nachricht\nsenden',
                            color: AppColors.accent,
                            onTap: () => _navigateToMessage(
                                context, patients.first),
                          ),
                        if (patients.length == 1)
                          _QuickActionCard(
                            icon: Icons.add_comment_outlined,
                            label: 'Beobachtung\nerfassen',
                            color: AppColors.success,
                            onTap: () => _showObservationDialog(
                                context, patients.first.patientId),
                          ),
                      ],
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
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
            final l = AppLocalizations.of(context)!;
            return AlertDialog(
              title: Text(l.observation),
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
                  SizedBox(height: 12),
                  SegmentedButton<ObservationSeverity>(
                    segments: [
                      ButtonSegment(
                        value: ObservationSeverity.info,
                        label: Text(l.info),
                        icon: Icon(Icons.info_outline),
                      ),
                      ButtonSegment(
                        value: ObservationSeverity.warning,
                        label: Text(l.warning),
                        icon: Icon(Icons.warning_amber),
                      ),
                      ButtonSegment(
                        value: ObservationSeverity.critical,
                        label: Text(l.critical),
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
                  child: Text(l.cancel),
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
                  child: Text(l.save),
                ),
              ],
            );
          },
        );
      },
    ).then((_) => textCtrl.dispose());
  }

  void _showAddPatientDialog(BuildContext context) {
    final codeCtrl = TextEditingController();
    bool busy = false;

    showDialog<void>(
      context: context,
      builder: (dialogCtx) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            final l = AppLocalizations.of(context)!;
            return AlertDialog(
              title: Text(l.patientAdd),
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
                  child: Text(l.cancel),
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
                                SnackBar(content: Text(userFacingError(e))),
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
                      : Text(l.connect),
                ),
              ],
            );
          },
        );
      },
    ).then((_) => codeCtrl.dispose());
  }
}

// ═════════════════════════════════════════════════════════════════════════════
// Op data helper model
// ═════════════════════════════════════════════════════════════════════════════

class _OpData {
  const _OpData({required this.daysOffset, required this.opDate});

  final int daysOffset;
  final DateTime opDate;

  bool get isPreOp => daysOffset > 0;
  bool get isToday => daysOffset == 0;
  bool get isPostOp => daysOffset < 0;
  int get daysSinceOp => -daysOffset;

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
          : 'Noch $daysOffset Tage bis zur OP';
    }
    if (daysSinceOp == 1) return 'Tag 1 der Genesung';
    return 'Tag $daysSinceOp der Genesung';
  }

  String get phaseLabel {
    if (isToday) return 'OP-Tag';
    if (isPreOp) return 'Prä-OP';
    return 'Post-OP';
  }
}

// ═════════════════════════════════════════════════════════════════════════════
// Section Header (matches doctor style)
// ═════════════════════════════════════════════════════════════════════════════

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.icon, required this.title});

  final IconData icon;
  final String title;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 28,
          height: 28,
          decoration: BoxDecoration(
            color: AppColors.primary.withValues(alpha: 0.10),
            borderRadius: AppRadius.borderRadiusSm,
          ),
          child: Icon(icon, size: 16, color: AppColors.primary),
        ),
        const SizedBox(width: AppSpacing.sm),
        Text(
          title,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w700,
              ),
        ),
      ],
    );
  }
}

// ═════════════════════════════════════════════════════════════════════════════
// Stat Card (matches doctor _StatCard)
// ═════════════════════════════════════════════════════════════════════════════

class _StatCard extends StatelessWidget {
  const _StatCard({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  final IconData icon;
  final String label;
  final String value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;
    return GlassCard(
      child: Column(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.12),
              borderRadius: AppRadius.borderRadiusSm,
            ),
            child: Icon(icon, size: 18, color: color),
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            value,
            style: tt.headlineSmall?.copyWith(
              fontWeight: FontWeight.w800,
              color: color,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: tt.labelSmall?.copyWith(color: AppColors.textSecondary),
          ),
        ],
      ),
    );
  }
}

// ═════════════════════════════════════════════════════════════════════════════
// Alert Patient Card (red-flag patients, matches doctor _AlertPatientCard)
// ═════════════════════════════════════════════════════════════════════════════

class _AlertPatientCard extends StatelessWidget {
  const _AlertPatientCard({required this.patient, required this.onTap});

  final LinkedFamilyPatient patient;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: GestureDetector(
        onTap: onTap,
        child: GlassCard(
          child: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
            stream: FirebaseFirestore.instance
                .collection(
                  '${FirestorePaths.patientDoc(patient.patientId)}/red_flags',
                )
                .snapshots(),
            builder: (context, snap) {
              final count = snap.data?.docs.length ?? 0;
              return Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: AppColors.error.withValues(alpha: 0.12),
                      borderRadius: AppRadius.borderRadiusSm,
                    ),
                    child: const Icon(Icons.warning_amber_rounded,
                        color: AppColors.error, size: 20),
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          patient.patientName,
                          style: Theme.of(context)
                              .textTheme
                              .titleSmall
                              ?.copyWith(fontWeight: FontWeight.w700),
                        ),
                        if (count > 0)
                          Text(
                            '$count Warnhinweis${count > 1 ? 'e' : ''}',
                            style:
                                Theme.of(context).textTheme.bodySmall?.copyWith(
                                      color: AppColors.error,
                                    ),
                          ),
                      ],
                    ),
                  ),
                  const Icon(Icons.chevron_right_rounded,
                      color: AppColors.textSecondary),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}

// ═════════════════════════════════════════════════════════════════════════════
// Patient Card (matches doctor PatientCard style – GlassCard with info chips)
// ═════════════════════════════════════════════════════════════════════════════

class _PatientCard extends StatefulWidget {
  const _PatientCard({
    required this.patient,
    required this.onTap,
    required this.onMessageTap,
    required this.onObservationTap,
  });

  final LinkedFamilyPatient patient;
  final VoidCallback onTap;
  final VoidCallback onMessageTap;
  final VoidCallback onObservationTap;

  @override
  State<_PatientCard> createState() => _PatientCardState();
}

class _PatientCardState extends State<_PatientCard> {
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

  String _formatDate(DateTime? dt) {
    if (dt == null) return '–';
    return '${dt.day}.${dt.month}.${dt.year}';
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final p = widget.patient;
    final tt = Theme.of(context).textTheme;
    final opData = _opData;
    final statusColor = opData?.statusColor ?? AppColors.primary;

    return PressableScale(
      onTap: () {
        Haptic.light();
        widget.onTap();
      },
      child: GlassCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Header row: name + status dot ──────────────
            Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(
                      colors: [
                        statusColor,
                        statusColor.withValues(alpha: 0.7),
                      ],
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: statusColor.withValues(alpha: 0.3),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    p.avatarInitials,
                    style: tt.titleSmall?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Flexible(
                            child: Text(
                              p.patientName,
                              style: tt.titleSmall?.copyWith(
                                fontWeight: FontWeight.w700,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          const SizedBox(width: 6),
                          Container(
                            width: 8,
                            height: 8,
                            decoration: BoxDecoration(
                              color: statusColor,
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color:
                                      statusColor.withValues(alpha: 0.4),
                                  blurRadius: 4,
                                ),
                              ],
                            ),
                          ),
                        ],
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
                const Icon(Icons.chevron_right_rounded,
                    color: AppColors.textSecondary),
              ],
            ),

            const SizedBox(height: AppSpacing.md),

            // ── OP date + phase badge ──────────────────────
            if (opData != null) ...[
              Row(
                children: [
                  Text(
                    'OP: ${_formatDate(opData.opDate)}',
                    style: tt.bodySmall?.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: statusColor.withValues(alpha: 0.12),
                      borderRadius: AppRadius.borderRadiusPill,
                    ),
                    child: Text(
                      opData.phaseLabel,
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                        color: statusColor,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.sm),
            ],

            // ── Progress bar (post-OP only) ────────────────
            if (opData != null && opData.isPostOp) ...[
              Row(
                children: [
                  Expanded(
                    child: GlassProgressBar(
                      value: opData.recoveryProgress,
                      height: 6,
                      fillColor: statusColor,
                      gradient: LinearGradient(
                        colors: [
                          statusColor,
                          statusColor.withValues(alpha: 0.55),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Text(
                    '${(opData.recoveryProgress * 100).round()}%',
                    style: tt.labelSmall?.copyWith(
                      fontWeight: FontWeight.w700,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.sm),
            ],

            // ── Info chips row ─────────────────────────────
            Row(
              children: [
                _InfoChip(
                  icon: Icons.favorite_outline_rounded,
                  label: l.status,
                  value: opData?.label ?? 'Kein OP-Datum',
                ),
                if (_redFlagStream != null) ...[
                  const SizedBox(width: AppSpacing.sm),
                  StreamBuilder<int>(
                    stream: _redFlagStream,
                    builder: (context, snap) {
                      final count = snap.data ?? 0;
                      if (count == 0) return const SizedBox.shrink();
                      return _InfoChip(
                        icon: Icons.flag_rounded,
                        label: 'Warnungen',
                        value: '$count',
                        color: AppColors.error,
                      );
                    },
                  ),
                ],
              ],
            ),

            const SizedBox(height: AppSpacing.md),

            // ── Quick action buttons ───────────────────────
            Row(
              children: [
                _ActionChip(
                  icon: Icons.chat_bubble_outline_rounded,
                  label: l.message,
                  onTap: widget.onMessageTap,
                ),
                const SizedBox(width: AppSpacing.sm),
                _ActionChip(
                  icon: Icons.add_comment_outlined,
                  label: 'Beobachtung',
                  onTap: widget.onObservationTap,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// ═════════════════════════════════════════════════════════════════════════════
// Info Chip (matches doctor _InfoChip)
// ═════════════════════════════════════════════════════════════════════════════

class _InfoChip extends StatelessWidget {
  const _InfoChip({
    required this.icon,
    required this.label,
    required this.value,
    this.color,
  });

  final IconData icon;
  final String label;
  final String value;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final chipColor = color ?? AppColors.textSecondary;
    return Flexible(
      child: Container(
        padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.sm, vertical: 4),
        decoration: BoxDecoration(
          color: chipColor.withValues(alpha: 0.06),
          borderRadius: AppRadius.borderRadiusSm,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 12, color: chipColor),
            const SizedBox(width: 4),
            Flexible(
              child: Text(
                value,
                style: TextStyle(
                  fontSize: 10,
                  color: chipColor,
                  fontWeight: FontWeight.w500,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ═════════════════════════════════════════════════════════════════════════════
// Action Chip
// ═════════════════════════════════════════════════════════════════════════════

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
      onTap: () {
        Haptic.light();
        onTap();
      },
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

// ═════════════════════════════════════════════════════════════════════════════
// Quick Action Card (matches doctor _QuickActionCard)
// ═════════════════════════════════════════════════════════════════════════════

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
      onTap: () {
        Haptic.light();
        onTap();
      },
      child: SizedBox(
        width: 100,
        child: GlassCard(
          child: Column(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.12),
                  borderRadius: AppRadius.borderRadiusSm,
                ),
                child: Icon(icon, size: 20, color: color),
              ),
              const SizedBox(height: AppSpacing.sm),
              Text(
                label,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ═════════════════════════════════════════════════════════════════════════════
// Empty + Error states
// ═════════════════════════════════════════════════════════════════════════════

class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.onAdd});

  final VoidCallback onAdd;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 60, horizontal: AppSpacing.xl),
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
            label: l.codeEnter,
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
