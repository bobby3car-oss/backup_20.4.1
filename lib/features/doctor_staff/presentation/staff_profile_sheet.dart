import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../ui/ui.dart';
import '../domain/staff_member.dart';
import '../domain/staff_permissions.dart';
import '../../../l10n/app_localizations.dart';

/// Bottom sheet showing the full profile of a staff member.
class StaffProfileSheet extends StatelessWidget {
  const StaffProfileSheet({
    super.key,
    required this.member,
    this.isStaff = false,
    required this.onEdit,
    required this.onPermissions,
    required this.onResetPassword,
    required this.onToggleDisabled,
    required this.onRemove,
  });

  final StaffMember member;

  /// When true, the viewer is a staff manager (not the doctor).
  final bool isStaff;

  final VoidCallback onEdit;
  final VoidCallback onPermissions;
  final VoidCallback onResetPassword;
  final VoidCallback onToggleDisabled;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final isDisabled = member.status == StaffStatus.disabled;
    // Staff managers cannot manage privileged staff members.
    final targetIsPrivileged =
        member.permissions.canRead('manageStaff');
    final actionsBlocked = isStaff && targetIsPrivileged;
    final initials = member.displayName.isNotEmpty
        ? member.displayName
            .split(' ')
            .take(2)
            .map((w) => w.isNotEmpty ? w[0].toUpperCase() : '')
            .join()
        : '?';

    return SafeArea(
      child: DraggableScrollableSheet(
        initialChildSize: 0.65,
        minChildSize: 0.4,
        maxChildSize: 0.9,
        expand: false,
        builder: (context, scrollController) {
          return Container(
            decoration: BoxDecoration(
              color: theme.scaffoldBackgroundColor,
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(20),
              ),
            ),
            child: ListView(
              controller: scrollController,
              padding: AppSpacing.screenPadding.copyWith(
                top: AppSpacing.md,
              ),
              children: [
                // ── Handle ──
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
                const SizedBox(height: AppSpacing.xl),

                // ── Avatar + Name ──
                Center(
                  child: Container(
                    width: 72,
                    height: 72,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: LinearGradient(
                        colors: isDisabled
                            ? [AppColors.grey400, AppColors.grey400]
                            : [
                                AppColors.primary.withValues(alpha: 0.8),
                                AppColors.accent.withValues(alpha: 0.8),
                              ],
                      ),
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      initials,
                      style: theme.textTheme.headlineSmall?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: AppSpacing.md),
                Center(
                  child: Text(
                    member.displayName.isNotEmpty
                        ? member.displayName
                        : member.email,
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
                if (member.displayName.isNotEmpty &&
                    member.email.isNotEmpty)
                  Center(
                    child: Padding(
                      padding: const EdgeInsets.only(top: 4),
                      child: Text(
                        member.email,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ),
                  ),
                const SizedBox(height: AppSpacing.sm),

                // ── Status badge ──
                Center(
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: isDisabled
                          ? AppColors.warning.withValues(alpha: 0.15)
                          : AppColors.success.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      isDisabled ? 'Deaktiviert' : 'Aktiv',
                      style: theme.textTheme.labelMedium?.copyWith(
                        color: isDisabled
                            ? AppColors.warning
                            : AppColors.success,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),

                if (member.createdAt != null) ...[
                  const SizedBox(height: AppSpacing.xs),
                  Center(
                    child: Text(
                      'Erstellt am ${DateFormat('dd.MM.yyyy').format(member.createdAt!)}',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ),
                ],

                const SizedBox(height: AppSpacing.xl),

                // ── Permissions overview ──
                Text(
                  l.permissions,
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: AppSpacing.sm),
                ...StaffPermissions.featureLabels.entries.map((entry) {
                  final level = member.permissions[entry.key];
                  final label = StaffPermissions.accessLevelLabels[level] ??
                      l.noAccess;
                  final icon = switch (level) {
                    StaffAccessLevel.readWrite =>
                      Icons.edit_note_rounded,
                    StaffAccessLevel.read =>
                      Icons.visibility_rounded,
                    StaffAccessLevel.none =>
                      Icons.block_rounded,
                  };
                  final color = switch (level) {
                    StaffAccessLevel.readWrite => AppColors.primary,
                    StaffAccessLevel.read => AppColors.textSecondary,
                    StaffAccessLevel.none => AppColors.grey400,
                  };

                  return Padding(
                    padding: const EdgeInsets.only(bottom: 6),
                    child: Row(
                      children: [
                        Icon(icon, size: 18, color: color),
                        const SizedBox(width: AppSpacing.sm),
                        Expanded(
                          child: Text(
                            entry.value,
                            style: theme.textTheme.bodyMedium,
                          ),
                        ),
                        Text(
                          label,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: color,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  );
                }),

                const SizedBox(height: AppSpacing.xl),

                // ── Actions ──
                Text(
                  'Aktionen',
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: AppSpacing.sm),
                if (actionsBlocked)
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      vertical: AppSpacing.md,
                    ),
                    child: Text(
                      'Dieser Mitarbeiter hat Verwaltungsrechte und kann nur vom Arzt bearbeitet werden.',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  )
                else ...[
                  _ActionTile(
                    icon: Icons.edit_rounded,
                    label: l.edit,
                    onTap: () {
                      Navigator.pop(context);
                      onEdit();
                    },
                  ),
                  _ActionTile(
                    icon: Icons.tune_rounded,
                    label: l.berechtigungenAendern,
                    onTap: () {
                      Navigator.pop(context);
                      onPermissions();
                    },
                  ),
                  _ActionTile(
                    icon: Icons.lock_reset_rounded,
                    label: l.passwordReset,
                    onTap: () {
                      Navigator.pop(context);
                      onResetPassword();
                    },
                  ),
                  _ActionTile(
                    icon: isDisabled
                        ? Icons.check_circle_outline_rounded
                        : Icons.block_rounded,
                    label: isDisabled ? l.activate : l.deactivate,
                    onTap: () {
                      Navigator.pop(context);
                      onToggleDisabled();
                    },
                  ),
                  _ActionTile(
                    icon: Icons.person_remove_rounded,
                    label: l.remove,
                    color: AppColors.error,
                    onTap: () {
                      Navigator.pop(context);
                      onRemove();
                    },
                  ),
                ],
                const SizedBox(height: AppSpacing.lg),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _ActionTile extends StatelessWidget {
  const _ActionTile({
    required this.icon,
    required this.label,
    required this.onTap,
    this.color,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return InkWell(
      borderRadius: AppRadius.borderRadiusMd,
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(
          vertical: AppSpacing.sm,
          horizontal: AppSpacing.xs,
        ),
        child: Row(
          children: [
            Icon(icon, size: 20, color: color),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Text(
                label,
                style: theme.textTheme.bodyMedium?.copyWith(color: color),
              ),
            ),
            Icon(
              Icons.chevron_right_rounded,
              size: 20,
              color: AppColors.textSecondary,
            ),
          ],
        ),
      ),
    );
  }
}
