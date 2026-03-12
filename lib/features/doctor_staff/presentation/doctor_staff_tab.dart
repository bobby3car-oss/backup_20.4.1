import 'package:flutter/material.dart';

import '../../../ui/ui.dart';
import '../data/staff_management_service.dart';
import '../domain/staff_member.dart';
import '../domain/staff_permissions.dart';
import 'create_staff_sheet.dart';
import 'edit_staff_sheet.dart';
import 'staff_permissions_sheet.dart';
import 'staff_profile_sheet.dart';

/// Fifth tab in the doctor dashboard (only visible to doctors, not staff).
///
/// Lists current staff and lets the doctor create and manage staff accounts.
class DoctorStaffTab extends StatefulWidget {
  const DoctorStaffTab({
    super.key,
    this.isStaff = false,
    this.doctorUid,
  });

  /// Whether the current user is a staff member (not the doctor).
  final bool isStaff;

  /// Doctor UID for staff managers; null for actual doctors.
  final String? doctorUid;

  @override
  State<DoctorStaffTab> createState() => _DoctorStaffTabState();
}

class _DoctorStaffTabState extends State<DoctorStaffTab> {
  late final StaffManagementService _service;

  @override
  void initState() {
    super.initState();
    _service = StaffManagementService(
      overrideDoctorUid: widget.isStaff ? widget.doctorUid : null,
    );
  }

  Future<void> _showCreateSheet() async {
    final created = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => CreateStaffSheet(isStaff: widget.isStaff),
    );
    if (created == true && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Mitarbeiter wurde erstellt')),
      );
    }
  }

  void _showProfileSheet(StaffMember member) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => StaffProfileSheet(
        member: member,
        isStaff: widget.isStaff,
        onEdit: () => _showEditSheet(member),
        onPermissions: () => _showPermissionsSheet(member),
        onResetPassword: () => _showResetPasswordDialog(member),
        onToggleDisabled: () => _toggleDisabled(member),
        onRemove: () => _confirmRemove(member),
      ),
    );
  }

  Future<void> _showEditSheet(StaffMember member) async {
    final updated = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => EditStaffSheet(member: member),
    );
    if (updated == true && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Mitarbeiter aktualisiert')),
      );
    }
  }

  Future<void> _showPermissionsSheet(StaffMember member) async {
    final updated = await showModalBottomSheet<StaffPermissions>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => StaffPermissionsSheet(
        member: member,
        isStaff: widget.isStaff,
      ),
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

  Future<void> _showResetPasswordDialog(StaffMember member) async {
    final passwordCtrl = TextEditingController();
    final confirmCtrl = TextEditingController();
    final formKey = GlobalKey<FormState>();

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Passwort zurücksetzen'),
        content: Form(
          key: formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Neues Passwort für ${member.displayName}'),
              const SizedBox(height: AppSpacing.md),
              TextFormField(
                controller: passwordCtrl,
                decoration: const InputDecoration(
                  labelText: 'Neues Passwort',
                ),
                obscureText: true,
                validator: (v) {
                  if (v == null || v.length < 8) {
                    return 'Mindestens 8 Zeichen.';
                  }
                  return null;
                },
              ),
              const SizedBox(height: AppSpacing.sm),
              TextFormField(
                controller: confirmCtrl,
                decoration: const InputDecoration(
                  labelText: 'Passwort bestätigen',
                ),
                obscureText: true,
                validator: (v) {
                  if (v != passwordCtrl.text) {
                    return 'Passwörter stimmen nicht überein.';
                  }
                  return null;
                },
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Abbrechen'),
          ),
          FilledButton(
            onPressed: () {
              if (formKey.currentState!.validate()) {
                Navigator.pop(ctx, true);
              }
            },
            child: const Text('Zurücksetzen'),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      try {
        await _service.resetStaffPassword(
          staffUid: member.uid,
          newPassword: passwordCtrl.text,
        );
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Passwort wurde zurückgesetzt')),
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
    passwordCtrl.dispose();
    confirmCtrl.dispose();
  }

  Future<void> _toggleDisabled(StaffMember member) async {
    final isDisabled = member.status == StaffStatus.disabled;
    final action = isDisabled ? 'aktivieren' : 'deaktivieren';

    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Mitarbeiter $action'),
        content: Text(
          isDisabled
              ? 'Möchten Sie ${member.displayName} wieder aktivieren? '
                'Der Login wird wieder möglich.'
              : 'Möchten Sie ${member.displayName} deaktivieren? '
                'Der Login wird gesperrt.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Abbrechen'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(isDisabled ? 'Aktivieren' : 'Deaktivieren'),
          ),
        ],
      ),
    );
    if (confirm == true && mounted) {
      try {
        await _service.toggleStaffDisabled(
          staffUid: member.uid,
          disabled: !isDisabled,
        );
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                isDisabled
                    ? '${member.displayName} wurde aktiviert'
                    : '${member.displayName} wurde deaktiviert',
              ),
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

  Future<void> _confirmRemove(StaffMember member) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Mitarbeiter entfernen'),
        content: Text(
          'Möchten Sie ${member.displayName} wirklich entfernen? '
          'Der Zugang wird sofort widerrufen und der Account deaktiviert.',
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
                      onPressed: _showCreateSheet,
                      icon: const Icon(Icons.person_add_rounded, size: 18),
                      label: const Text('Erstellen'),
                    ),
                  ],
                ),
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

                  if (snap.hasError) {
                    return Center(
                      child: Padding(
                        padding: const EdgeInsets.all(AppSpacing.xxl),
                        child: Text(
                          'Fehler beim Laden der Mitarbeiter.',
                          style: Theme.of(context)
                              .textTheme
                              .bodyMedium
                              ?.copyWith(color: AppColors.error),
                        ),
                      ),
                    );
                  }

                  final staff = snap.data ?? [];
                  if (staff.isEmpty) {
                    return _EmptyStaffState(onCreate: _showCreateSheet);
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
                              isStaff: widget.isStaff,
                              onTap: () => _showProfileSheet(member),
                              onEdit: () => _showEditSheet(member),
                              onPermissions: () =>
                                  _showPermissionsSheet(member),
                              onResetPassword: () =>
                                  _showResetPasswordDialog(member),
                              onToggleDisabled: () =>
                                  _toggleDisabled(member),
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
}

// ─────────────────────────────────────────────────────────────────────────────

class _StaffCard extends StatelessWidget {
  const _StaffCard({
    required this.member,
    this.isStaff = false,
    required this.onTap,
    required this.onEdit,
    required this.onPermissions,
    required this.onResetPassword,
    required this.onToggleDisabled,
    required this.onRemove,
  });

  final StaffMember member;
  final bool isStaff;
  final VoidCallback onTap;
  final VoidCallback onEdit;
  final VoidCallback onPermissions;
  final VoidCallback onResetPassword;
  final VoidCallback onToggleDisabled;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDisabled = member.status == StaffStatus.disabled;
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

    return Opacity(
      opacity: isDisabled ? 0.5 : 1.0,
      child: GlassCard(
        onTap: onTap,
        child: Column(
          children: [
            Row(
              children: [
                // Avatar
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(
                      colors: isDisabled
                          ? [
                              AppColors.grey400,
                              AppColors.grey400,
                            ]
                          : [
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

                // Name + Email + Status
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Flexible(
                            child: Text(
                              member.displayName.isNotEmpty
                                  ? member.displayName
                                  : member.email,
                              style: theme.textTheme.bodyLarge?.copyWith(
                                fontWeight: FontWeight.w600,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          if (isDisabled) ...[
                            const SizedBox(width: AppSpacing.xs),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 6,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: AppColors.warning.withValues(
                                  alpha: 0.15,
                                ),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                'Deaktiviert',
                                style: theme.textTheme.labelSmall?.copyWith(
                                  color: AppColors.warning,
                                  fontWeight: FontWeight.w600,
                                  fontSize: 10,
                                ),
                              ),
                            ),
                          ],
                        ],
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

                // Context menu (hidden for privileged staff when viewer is staff)
                if (isStaff && member.permissions.canRead('manageStaff'))
                  Tooltip(
                    message: 'Nur vom Arzt verwaltbar',
                    child: Icon(
                      Icons.admin_panel_settings_rounded,
                      size: 20,
                      color: AppColors.textSecondary,
                    ),
                  )
                else
                PopupMenuButton<_StaffAction>(
                  icon: const Icon(Icons.more_vert_rounded, size: 20),
                  onSelected: (action) {
                    switch (action) {
                      case _StaffAction.edit:
                        onEdit();
                      case _StaffAction.permissions:
                        onPermissions();
                      case _StaffAction.resetPassword:
                        onResetPassword();
                      case _StaffAction.toggleDisabled:
                        onToggleDisabled();
                      case _StaffAction.remove:
                        onRemove();
                    }
                  },
                  itemBuilder: (_) => [
                    const PopupMenuItem(
                      value: _StaffAction.edit,
                      child: ListTile(
                        leading: Icon(Icons.edit_rounded),
                        title: Text('Bearbeiten'),
                        dense: true,
                        contentPadding: EdgeInsets.zero,
                      ),
                    ),
                    const PopupMenuItem(
                      value: _StaffAction.permissions,
                      child: ListTile(
                        leading: Icon(Icons.tune_rounded),
                        title: Text('Berechtigungen'),
                        dense: true,
                        contentPadding: EdgeInsets.zero,
                      ),
                    ),
                    const PopupMenuItem(
                      value: _StaffAction.resetPassword,
                      child: ListTile(
                        leading: Icon(Icons.lock_reset_rounded),
                        title: Text('Passwort zurücksetzen'),
                        dense: true,
                        contentPadding: EdgeInsets.zero,
                      ),
                    ),
                    PopupMenuItem(
                      value: _StaffAction.toggleDisabled,
                      child: ListTile(
                        leading: Icon(
                          isDisabled
                              ? Icons.check_circle_outline_rounded
                              : Icons.block_rounded,
                        ),
                        title: Text(
                          isDisabled ? 'Aktivieren' : 'Deaktivieren',
                        ),
                        dense: true,
                        contentPadding: EdgeInsets.zero,
                      ),
                    ),
                    PopupMenuItem(
                      value: _StaffAction.remove,
                      child: ListTile(
                        leading: Icon(
                          Icons.person_remove_rounded,
                          color: AppColors.error,
                        ),
                        title: Text(
                          'Entfernen',
                          style: TextStyle(color: AppColors.error),
                        ),
                        dense: true,
                        contentPadding: EdgeInsets.zero,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

enum _StaffAction {
  edit,
  permissions,
  resetPassword,
  toggleDisabled,
  remove,
}

class _EmptyStaffState extends StatelessWidget {
  const _EmptyStaffState({required this.onCreate});
  final VoidCallback onCreate;

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
              'Erstellen Sie Accounts für Ihr Praxisteam,\n'
              'um gemeinsam Patienten zu betreuen.',
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: AppSpacing.xl),
            FilledButton.icon(
              onPressed: onCreate,
              icon: const Icon(Icons.person_add_rounded, size: 18),
              label: const Text('Mitarbeiter erstellen'),
            ),
          ],
        ),
      ),
    );
  }
}
