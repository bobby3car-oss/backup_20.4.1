import 'package:flutter/material.dart';

import '../../../screens/caregiver_screen.dart';
import '../../../ui/ui.dart';
import '../domain/packing_list.dart';

/// Bottom sheet for managing sharing and collaboration on a packing list.
///
/// Shows current members, roles, and allows inviting new people.
/// Leverages the existing patient-scoped invite/family system.
class PackingShareSheet extends StatelessWidget {
  const PackingShareSheet({super.key, required this.list});

  final PackingList list;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.xl,
            AppSpacing.md,
            AppSpacing.xl,
            AppSpacing.xl,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // ── Handle ───────────────────────────────────────
              Center(
                child: Container(
                  width: 36,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppColors.grey300,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.lg),

              // ── Title ────────────────────────────────────────
              Text(
                'Liste teilen',
                style: Theme.of(context)
                    .textTheme
                    .titleLarge
                    ?.copyWith(fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: AppSpacing.xs),
              Text(
                'Packt gemeinsam – jeder sieht den Fortschritt',
                style: Theme.of(context)
                    .textTheme
                    .bodyMedium
                    ?.copyWith(color: AppColors.textSecondary),
              ),
              const SizedBox(height: AppSpacing.xl),

              // ── Current members ──────────────────────────────
              if (list.members.isNotEmpty) ...[
                Text(
                  'Mitglieder',
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                ),
                const SizedBox(height: AppSpacing.sm),
                GlassContainer(
                  padding: EdgeInsets.zero,
                  borderRadius: AppRadius.borderRadiusMd,
                  variant: GlassVariant.thin,
                  elevation: GlassElevation.flat,
                  child: Column(
                    children: [
                      for (var i = 0; i < list.members.length; i++) ...[
                        _MemberTile(member: list.members[i]),
                        if (i < list.members.length - 1)
                          Divider(
                            height: 0.5,
                            thickness: 0.5,
                            indent: 56,
                            color: AppColors.grey200.withValues(alpha: 0.5),
                          ),
                      ],
                    ],
                  ),
                ),
                const SizedBox(height: AppSpacing.xl),
              ],

              // ── How sharing works ────────────────────────────
              GlassContainer(
                padding: const EdgeInsets.all(AppSpacing.lg),
                borderRadius: AppRadius.borderRadiusMd,
                variant: GlassVariant.thin,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'So funktioniert das Teilen',
                      style:
                          Theme.of(context).textTheme.titleSmall?.copyWith(
                                fontWeight: FontWeight.w600,
                              ),
                    ),
                    const SizedBox(height: AppSpacing.md),
                    _InfoRow(
                      icon: Icons.link_rounded,
                      text:
                          'Verknüpfte Angehörige sehen automatisch deine Packlisten.',
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    _InfoRow(
                      icon: Icons.edit_rounded,
                      text:
                          'Bearbeiter können Items abhaken und neue hinzufügen.',
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    _InfoRow(
                      icon: Icons.sync_rounded,
                      text:
                          'Änderungen werden in Echtzeit synchronisiert.',
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.xl),

              // ── Invite CTA ───────────────────────────────────
              GlassButton(
                onPressed: () {
                  // Navigate to the existing family/invite flow.
                  Navigator.of(context).pop();
                  Navigator.of(context).push(
                    MaterialPageRoute<void>(builder: (_) => const CaregiverScreen()),
                  );
                },
                label: 'Angehörige einladen',
                icon: Icons.person_add_rounded,
                expand: true,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────
// ── Member tile ─────────────────────────────────────────────────
// ─────────────────────────────────────────────────────────────────

class _MemberTile extends StatelessWidget {
  const _MemberTile({required this.member});

  final PackingListMember member;

  @override
  Widget build(BuildContext context) {
    final isOwner = member.role == PackingListRole.owner;

    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.lg,
        vertical: AppSpacing.md,
      ),
      child: Row(
        children: [
          // Avatar
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: isOwner
                    ? [const Color(0xFF5856D6), const Color(0xFF007AFF)]
                    : [AppColors.grey300, AppColors.grey200],
              ),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                _initials(member.displayName),
                style: TextStyle(
                  color: isOwner ? Colors.white : AppColors.textSecondary,
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  member.displayName ?? 'Unbenannt',
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Text(
                  member.role.label,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppColors.textSecondary,
                      ),
                ),
              ],
            ),
          ),
          if (isOwner)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: AppColors.accent.withValues(alpha: 0.10),
                borderRadius: AppRadius.borderRadiusSm,
              ),
              child: const Text(
                'Besitzer',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: AppColors.accent,
                ),
              ),
            ),
        ],
      ),
    );
  }

  String _initials(String? name) {
    if (name == null || name.isEmpty) return '?';
    final parts = name.trim().split(' ');
    if (parts.length >= 2) {
      return '${parts.first[0]}${parts.last[0]}'.toUpperCase();
    }
    return parts.first[0].toUpperCase();
  }
}

// ─────────────────────────────────────────────────────────────────
// ── Info row ────────────────────────────────────────────────────
// ─────────────────────────────────────────────────────────────────

class _InfoRow extends StatelessWidget {
  const _InfoRow({required this.icon, required this.text});

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(
          icon,
          size: 18,
          color: AppColors.primary.withValues(alpha: 0.7),
        ),
        const SizedBox(width: AppSpacing.sm),
        Expanded(
          child: Text(
            text,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: AppColors.textSecondary,
                  height: 1.3,
                ),
          ),
        ),
      ],
    );
  }
}
