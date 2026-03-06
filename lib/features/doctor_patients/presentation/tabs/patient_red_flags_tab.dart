import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../../../../features/red_flags/domain/red_flag.dart';
import '../../../../firebase/firebase_paths.dart';
import '../../../../ui/ui.dart';

/// Doctor-facing tab showing a patient's active and resolved red flags
/// with triage actions (acknowledge, escalate, resolve).
class PatientRedFlagsTab extends StatefulWidget {
  const PatientRedFlagsTab({super.key, required this.patientId});

  final String patientId;

  @override
  State<PatientRedFlagsTab> createState() => _PatientRedFlagsTabState();
}

class _PatientRedFlagsTabState extends State<PatientRedFlagsTab>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  Stream<List<RedFlag>> _watchFlags() {
    return FirebaseFirestore.instance
        .collection(FirestorePaths.redFlagsCollection(widget.patientId))
        .orderBy('createdAt', descending: true)
        .limit(50)
        .snapshots()
        .map((snap) => snap.docs
            .map((d) => RedFlag.fromJson({...d.data(), 'id': d.id}))
            .toList());
  }

  Future<void> _updateStatus(
      String flagId, RedFlagStatus status) async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    final updates = <String, dynamic>{
      'status': status.name,
      'updatedAt': DateTime.now().toIso8601String(),
    };
    if (status == RedFlagStatus.resolved) {
      updates['resolvedAt'] = DateTime.now().toIso8601String();
    }
    if (uid != null) {
      updates['resolvedBy'] = uid;
    }
    await FirebaseFirestore.instance
        .collection(FirestorePaths.redFlagsCollection(widget.patientId))
        .doc(flagId)
        .update(updates);
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return StreamBuilder<List<RedFlag>>(
      stream: _watchFlags(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting &&
            !snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        final flags = snapshot.data ?? [];
        if (flags.isEmpty) {
          return Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.shield_rounded,
                    size: 48, color: AppColors.success.withValues(alpha: 0.5)),
                const SizedBox(height: AppSpacing.md),
                Text(
                  'Keine Red Flags',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: AppColors.textSecondary,
                      ),
                ),
              ],
            ),
          );
        }

        final active = flags.where((f) => f.status.isActive).toList();
        final resolved = flags.where((f) => !f.status.isActive).toList();

        return ListView(
          padding: const EdgeInsets.all(AppSpacing.lg),
          children: [
            if (active.isNotEmpty) ...[
              _SectionLabel('Aktiv (${active.length})'),
              const SizedBox(height: AppSpacing.sm),
              for (final flag in active) ...[
                _DoctorFlagCard(
                  flag: flag,
                  onAcknowledge: flag.status == RedFlagStatus.open
                      ? () =>
                          _updateStatus(flag.id, RedFlagStatus.acknowledged)
                      : null,
                  onEscalate: () =>
                      _updateStatus(flag.id, RedFlagStatus.escalated),
                  onResolve: () =>
                      _updateStatus(flag.id, RedFlagStatus.resolved),
                ),
                const SizedBox(height: AppSpacing.sm),
              ],
            ],
            if (resolved.isNotEmpty) ...[
              const SizedBox(height: AppSpacing.lg),
              _SectionLabel('Verlauf (${resolved.length})'),
              const SizedBox(height: AppSpacing.sm),
              for (final flag in resolved) ...[
                _ResolvedFlagRow(flag: flag),
                const SizedBox(height: AppSpacing.xs),
              ],
            ],
          ],
        );
      },
    );
  }
}

// ── Section label ────────────────────────────────────────────────────────────

class _SectionLabel extends StatelessWidget {
  const _SectionLabel(this.text);
  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: Theme.of(context)
          .textTheme
          .labelLarge
          ?.copyWith(color: AppColors.textSecondary),
    );
  }
}

// ── Doctor flag card with triage actions ──────────────────────────────────────

class _DoctorFlagCard extends StatelessWidget {
  const _DoctorFlagCard({
    required this.flag,
    this.onAcknowledge,
    this.onEscalate,
    this.onResolve,
  });

  final RedFlag flag;
  final VoidCallback? onAcknowledge;
  final VoidCallback? onEscalate;
  final VoidCallback? onResolve;

  Color get _severityColor => switch (flag.severity) {
        RedFlagSeverity.red => AppColors.error,
        RedFlagSeverity.orange => AppColors.warning,
        RedFlagSeverity.yellow => const Color(0xFFFFCC00),
        RedFlagSeverity.green => AppColors.success,
      };

  String _formatDate(DateTime dt) =>
      '${dt.day.toString().padLeft(2, '0')}.${dt.month.toString().padLeft(2, '0')}.'
      '${dt.year}  ${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';

  String get _age {
    final diff = DateTime.now().difference(flag.createdAt);
    if (diff.inMinutes < 60) return 'vor ${diff.inMinutes} Min.';
    if (diff.inHours < 24) return 'vor ${diff.inHours} Std.';
    return 'vor ${diff.inDays} Tagen';
  }

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: _severityColor.withValues(alpha: 0.12),
                  borderRadius: AppRadius.borderRadiusSm,
                ),
                child: Center(
                  child: Text(flag.source.emoji,
                      style: const TextStyle(fontSize: 18)),
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      flag.title,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    Text(
                      '${flag.source.label} · $_age',
                      style: const TextStyle(
                        fontSize: 11,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: _severityColor.withValues(alpha: 0.12),
                  borderRadius: AppRadius.borderRadiusPill,
                ),
                child: Text(
                  flag.severity.label,
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    color: _severityColor,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            flag.summary,
            style: const TextStyle(
              fontSize: 13,
              color: AppColors.textPrimary,
              height: 1.4,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),

          // Status chip
          Row(
            children: [
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: AppColors.grey100,
                  borderRadius: AppRadius.borderRadiusPill,
                ),
                child: Text(
                  flag.status.label,
                  style: const TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textSecondary,
                  ),
                ),
              ),
              const SizedBox(width: 6),
              Text(
                _formatDate(flag.createdAt),
                style: const TextStyle(
                  fontSize: 10,
                  color: AppColors.grey500,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),

          // Triage actions
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              if (onAcknowledge != null)
                _ActionChip(
                  label: 'Bestätigen',
                  icon: Icons.visibility_rounded,
                  color: AppColors.primary,
                  onTap: onAcknowledge!,
                ),
              if (onAcknowledge != null)
                const SizedBox(width: AppSpacing.sm),
              if (onEscalate != null)
                _ActionChip(
                  label: 'Eskalieren',
                  icon: Icons.priority_high_rounded,
                  color: AppColors.warning,
                  onTap: onEscalate!,
                ),
              if (onEscalate != null) const SizedBox(width: AppSpacing.sm),
              if (onResolve != null)
                _ActionChip(
                  label: 'Erledigt',
                  icon: Icons.check_circle_outline_rounded,
                  color: AppColors.success,
                  onTap: onResolve!,
                ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ActionChip extends StatelessWidget {
  const _ActionChip({
    required this.label,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: AppRadius.borderRadiusPill,
        child: Container(
          padding:
              const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.08),
            borderRadius: AppRadius.borderRadiusPill,
            border: Border.all(color: color.withValues(alpha: 0.20)),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 14, color: color),
              const SizedBox(width: 4),
              Text(
                label,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: color,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Resolved flag row ────────────────────────────────────────────────────────

class _ResolvedFlagRow extends StatelessWidget {
  const _ResolvedFlagRow({required this.flag});
  final RedFlag flag;

  @override
  Widget build(BuildContext context) {
    final resolved = flag.resolvedAt ?? flag.updatedAt;
    final dateStr =
        '${resolved.day.toString().padLeft(2, '0')}.${resolved.month.toString().padLeft(2, '0')}.'
        '${resolved.year}';
    return GlassCard(
      child: Row(
        children: [
          Text(flag.source.emoji, style: const TextStyle(fontSize: 16)),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  flag.title,
                  style: const TextStyle(
                    fontSize: 13,
                    color: AppColors.textSecondary,
                    decoration: TextDecoration.lineThrough,
                  ),
                ),
                Text(
                  '${flag.status.label} · $dateStr',
                  style: const TextStyle(
                    fontSize: 10,
                    color: AppColors.grey500,
                  ),
                ),
              ],
            ),
          ),
          const Icon(
            Icons.check_circle_rounded,
            size: 18,
            color: AppColors.success,
          ),
        ],
      ),
    );
  }
}
