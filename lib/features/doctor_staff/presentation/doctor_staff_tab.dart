import 'package:flutter/material.dart';

import '../../../ui/ui.dart';
import '../data/staff_management_service.dart';
import '../domain/staff_invite.dart';
import '../domain/staff_member.dart';
import '../domain/staff_permissions.dart';
import 'staff_invite_sheet.dart';
import 'staff_permissions_sheet.dart';

/// Fifth tab in the doctor dashboard (only visible to doctors, not staff).
///
/// Lists current staff, allows inviting new staff and managing permissions.
class DoctorStaffTab extends StatefulWidget {
  const DoctorStaffTab({super.key});

  @override
  State<DoctorStaffTab> createState() => _DoctorStaffTabState();
}

class _DoctorStaffTabState extends State<DoctorStaffTab> {
  final _service = StaffManagementService();

  Future<void> _showInviteSheet() async {
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const StaffInviteSheet(),
    );
  }

  Future<void> _showPermissionsSheet(StaffMember member) async {
    final updated = await showModalBottomSheet<StaffPermissions>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => StaffPermissionsSheet(member: member),
    );
    if (updated != null && mounted) {
      try {
        await _service.updatePermissions(member.uid, updated);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Berechtigungen aktualisiert')),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Fehler: $e')),
          );
        }
      }
    }
  }

  Future<void> _confirmRemove(StaffMember member) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Mitarbeiter entfernen'),
        content: Text(
          'Möchten Sie ${member.displayName} wirklich entfernen? '
          'Der Zugang wird sofort widerrufen.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Abbrechen'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: AppColors.error,
            ),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Entfernen'),
          ),
        ],
      ),
    );
    if (confirm == true && mounted) {
      try {
        await _service.removeStaff(member.uid);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('${member.displayName} wurde entfernt'),
            ),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Fehler: $e')),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return SafeArea(
      bottom: false,
      child: Padding(
        padding: AppSpacing.screenPadding.copyWith(
          bottom: 120,
        ),
        child: CustomScrollView(
          slivers: [
            // ── Header ──────────────────────────────────────────
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.only(
                  top: AppSpacing.xl,
                  bottom: AppSpacing.lg,
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        'Team',
                        style: theme.textTheme.headlineMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    FilledButton.icon(
                      onPressed: _showInviteSheet,
                      icon: const Icon(Icons.person_add_rounded, size: 18),
                      label: const Text('Einladen'),
                    ),
                  ],
                ),
              ),
            ),

            // ── Pending invites ─────────────────────────────────
            SliverToBoxAdapter(
              child: StreamBuilder<List<StaffInvite>>(
                stream: _service.watchMyInvites(),
                builder: (context, snap) {
                  final invites = snap.data ?? [];
                  final activeInvites =
                      invites.where((i) => i.isActive).toList();
                  if (activeInvites.isEmpty) {
                    return const SizedBox.shrink();
                  }
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Offene Einladungen',
                        style: theme.textTheme.titleSmall?.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.sm),
                      ...activeInvites.map((invite) => Padding(
                            padding: const EdgeInsets.only(
                              bottom: AppSpacing.sm,
                            ),
                            child: GlassCard(
                              child: Row(
                                children: [
                                  Icon(
                                    Icons.mail_outline_rounded,
                                    color: AppColors.warning,
                                    size: 20,
                                  ),
                                  const SizedBox(width: AppSpacing.md),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          'Code: ${invite.code}',
                                          style: theme.textTheme.bodyMedium
                                              ?.copyWith(
                                            fontFamily: 'monospace',
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                        Text(
                                          'Gültig bis ${_formatDate(invite.expiresAt)}',
                                          style: theme.textTheme.bodySmall
                                              ?.copyWith(
                                            color: AppColors.textSecondary,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          )),
                      const SizedBox(height: AppSpacing.lg),
                    ],
                  );
                },
              ),
            ),

            // ── Staff list ──────────────────────────────────────
            SliverToBoxAdapter(
              child: StreamBuilder<List<StaffMember>>(
                stream: _service.watchMyStaff(),
                builder: (context, snap) {
                  if (snap.connectionState == ConnectionState.waiting) {
                    return const Center(
                      child: Padding(
                        padding: EdgeInsets.all(AppSpacing.xxl),
                        child: CircularProgressIndicator(),
                      ),
                    );
                  }

                  final staff = snap.data ?? [];
                  if (staff.isEmpty) {
                    return _EmptyStaffState(onInvite: _showInviteSheet);
                  }

                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Mitarbeitende (${staff.length})',
                        style: theme.textTheme.titleSmall?.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.sm),
                      ...staff.map((member) => Padding(
                            padding: const EdgeInsets.only(
                              bottom: AppSpacing.sm,
                            ),
                            child: _StaffCard(
                              member: member,
                              onEdit: () => _showPermissionsSheet(member),
                              onRemove: () => _confirmRemove(member),
                            ),
                          )),
                    ],
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}.${date.month}.${date.year}';
  }
}

// ─────────────────────────────────────────────────────────────────────────────

class _StaffCard extends StatelessWidget {
  const _StaffCard({
    required this.member,
    required this.onEdit,
    required this.onRemove,
  });

  final StaffMember member;
  final VoidCallback onEdit;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final initials = member.displayName.isNotEmpty
        ? member.displayName
            .split(' ')
            .take(2)
            .map((w) => w.isNotEmpty ? w[0].toUpperCase() : '')
            .join()
        : '?';

    final writeCount = StaffPermissions.featureLabels.keys
        .where((f) => member.permissions.canWrite(f))
        .length;
    final readCount = StaffPermissions.featureLabels.keys
        .where((f) => member.permissions.canRead(f))
        .length;

    return GlassCard(
      onTap: onEdit,
      child: Row(
        children: [
          // Avatar
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                colors: [
                  AppColors.primary.withValues(alpha: 0.8),
                  AppColors.accent.withValues(alpha: 0.8),
                ],
              ),
            ),
            alignment: Alignment.center,
            child: Text(
              initials,
              style: theme.textTheme.titleSmall?.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(width: AppSpacing.md),

          // Name + Email
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  member.displayName.isNotEmpty
                      ? member.displayName
                      : member.email,
                  style: theme.textTheme.bodyLarge?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                if (member.email.isNotEmpty)
                  Text(
                    member.email,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: AppColors.textSecondary,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                const SizedBox(height: 2),
                Text(
                  '$readCount Lesen · $writeCount Schreiben',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: AppColors.textSecondary,
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ),

          // Actions
          IconButton(
            icon: const Icon(Icons.tune_rounded, size: 20),
            tooltip: 'Berechtigungen',
            onPressed: onEdit,
          ),
          IconButton(
            icon: Icon(
              Icons.person_remove_rounded,
              size: 20,
              color: AppColors.error,
            ),
            tooltip: 'Entfernen',
            onPressed: onRemove,
          ),
        ],
      ),
    );
  }
}

class _EmptyStaffState extends StatelessWidget {
  const _EmptyStaffState({required this.onInvite});
  final VoidCallback onInvite;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: AppSpacing.xxl),
        child: Column(
          children: [
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.08),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.group_add_rounded,
                color: AppColors.primary,
                size: 32,
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            Text(
              'Noch keine Mitarbeitenden',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              'Laden Sie Ihr Praxisteam ein, um gemeinsam\n'
              'Patienten zu betreuen.',
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: AppSpacing.xl),
            FilledButton.icon(
              onPressed: onInvite,
              icon: const Icon(Icons.person_add_rounded, size: 18),
              label: const Text('Mitarbeiter einladen'),
            ),
          ],
        ),
      ),
    );
  }
}
