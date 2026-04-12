import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../../../ui/ui.dart';
import '../data/staff_management_service.dart';
import '../domain/staff_member.dart';
import '../domain/staff_permissions.dart';
import 'create_staff_sheet.dart';
import 'edit_staff_sheet.dart';
import 'staff_permissions_sheet.dart';
import 'staff_profile_sheet.dart';
import '../../../l10n/app_localizations.dart';

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
  StaffManagementService? _service;
  String? _orgId;
  String? _currentDoctorUid;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _initService();
  }

  Future<void> _initService() async {
    final uid = widget.doctorUid ?? FirebaseAuth.instance.currentUser?.uid;
    _currentDoctorUid = uid;

    if (uid != null && !widget.isStaff) {
      // Check if this doctor belongs to an org.
      final userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(uid)
          .get();
      final orgId = userDoc.data()?['orgId'] as String?;

      if (orgId != null && orgId.isNotEmpty) {
        _orgId = orgId;
        _service = StaffManagementService(
          collectionPrefix: 'organisations',
          overrideDoctorUid: orgId,
        );
      } else {
        _service = StaffManagementService();
      }
    } else {
      _service = StaffManagementService(
        overrideDoctorUid: widget.isStaff ? widget.doctorUid : null,
      );
    }

    if (mounted) setState(() => _loading = false);
  }

  /// Whether the current doctor can edit (manage) this staff member.
  /// If the doctor belongs to an org, they can only edit staff they created.
  bool _canEdit(StaffMember member) {
    if (_orgId == null) return true;
    return member.createdByDoctor == _currentDoctorUid;
  }

  /// Org-doctors must not create staff – only the organisation itself may.
  bool get _canCreateStaff => _orgId == null;

  Future<void> _showCreateSheet() async {
    final created = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => CreateStaffSheet(isStaff: widget.isStaff),
    );
    if (created == true && mounted) {
      final l = AppLocalizations.of(context)!;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l.staffCreated)),
      );
    }
  }

  void _showProfileSheet(StaffMember member) {
    final canEdit = _canEdit(member);
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => StaffProfileSheet(
        member: member,
        isStaff: widget.isStaff,
        readOnly: !canEdit,
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
      final l = AppLocalizations.of(context)!;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l.staffUpdated)),
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
        await _service!.updatePermissions(member.uid, updated);
        if (mounted) {
          final l = AppLocalizations.of(context)!;
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(l.permissionsUpdated)),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(userFacingError(e))),
          );
        }
      }
    }
  }

  Future<void> _showResetPasswordDialog(StaffMember member) async {
    final l = AppLocalizations.of(context)!;
    final passwordCtrl = TextEditingController();
    final confirmCtrl = TextEditingController();
    final formKey = GlobalKey<FormState>();

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l.passwordReset),
        content: Form(
          key: formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(l.neuesPasswortFuer(member.displayName)),
              const SizedBox(height: AppSpacing.md),
              TextFormField(
                controller: passwordCtrl,
                decoration: InputDecoration(
                  labelText: l.neuesPasswort,
                ),
                obscureText: true,
                validator: (v) {
                  if (v == null || v.length < 8) {
                    return l.passwordMin8Chars;
                  }
                  return null;
                },
              ),
              const SizedBox(height: AppSpacing.sm),
              TextFormField(
                controller: confirmCtrl,
                decoration: InputDecoration(
                  labelText: l.passwordConfirm,
                ),
                obscureText: true,
                validator: (v) {
                  if (v != passwordCtrl.text) {
                    return l.passwoerterStimmenNichtUeberein;
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
            child: Text(l.cancel),
          ),
          FilledButton(
            onPressed: () {
              if (formKey.currentState!.validate()) {
                Navigator.pop(ctx, true);
              }
            },
            child: Text(l.reset),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      try {
        await _service!.resetStaffPassword(
          staffUid: member.uid,
          newPassword: passwordCtrl.text,
        );
        if (mounted) {
          final l = AppLocalizations.of(context)!;
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(l.passwordResetDone)),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(userFacingError(e))),
          );
        }
      }
    }
    passwordCtrl.dispose();
    confirmCtrl.dispose();
  }

  Future<void> _toggleDisabled(StaffMember member) async {
    final l = AppLocalizations.of(context)!;
    final isDisabled = member.status == StaffStatus.disabled;

    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l.mitarbeiterAction(isDisabled ? l.activate.toLowerCase() : l.deactivate.toLowerCase())),
        content: Text(
          isDisabled
              ? l.staffActivateConfirmBody(member.displayName)
              : l.staffDeactivateConfirmBody(member.displayName),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(l.cancel),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(isDisabled ? l.activate : l.deactivate),
          ),
        ],
      ),
    );
    if (confirm == true && mounted) {
      try {
        await _service!.toggleStaffDisabled(
          staffUid: member.uid,
          disabled: !isDisabled,
        );
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                isDisabled
                    ? l.staffActivated(member.displayName)
                    : l.staffDeactivated(member.displayName),
              ),
            ),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(userFacingError(e))),
          );
        }
      }
    }
  }

  Future<void> _confirmRemove(StaffMember member) async {
    final l = AppLocalizations.of(context)!;
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l.staffRemove),
        content: Text(
          l.staffRemoveConfirmBody(member.displayName),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(l.cancel),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: AppColors.error,
            ),
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(l.remove),
          ),
        ],
      ),
    );
    if (confirm == true && mounted) {
      try {
        await _service!.removeStaff(member.uid);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(l.mitarbeiterEntfernt(member.displayName)),
            ),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(userFacingError(e))),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final theme = Theme.of(context);

    if (_loading || _service == null) {
      return const Center(child: CircularProgressIndicator());
    }

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
                    if (Navigator.of(context).canPop())
                      Padding(
                        padding: const EdgeInsets.only(right: AppSpacing.sm),
                        child: IconButton(
                          onPressed: () => Navigator.of(context).pop(),
                          icon: const Icon(Icons.arrow_back_ios_rounded, size: 20),
                        ),
                      ),
                    Expanded(
                      child: Text(
                        l.teamHeader,
                        style: theme.textTheme.headlineMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    if (_canCreateStaff)
                      FilledButton.icon(
                        onPressed: _showCreateSheet,
                        icon: const Icon(Icons.person_add_rounded, size: 18),
                        label: Text(l.create),
                      ),
                  ],
                ),
              ),
            ),

            // ── Staff list ──────────────────────────────────────
            SliverToBoxAdapter(
              child: StreamBuilder<List<StaffMember>>(
                stream: _service!.watchMyStaff(),
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
                          l.staffLoadError,
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
                    return _EmptyStaffState(
                      onCreate: _showCreateSheet,
                      canCreate: _canCreateStaff,
                    );
                  }

                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        l.staffCountLabel(staff.length),
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
                              canEdit: _canEdit(member),
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
    this.canEdit = true,
    required this.onTap,
    required this.onEdit,
    required this.onPermissions,
    required this.onResetPassword,
    required this.onToggleDisabled,
    required this.onRemove,
  });

  final StaffMember member;
  final bool isStaff;
  final bool canEdit;
  final VoidCallback onTap;
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
                                l.statusDisabled,
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
                      if (member.staffRole != null &&
                          member.staffRole!.isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.only(top: 2),
                          child: Text(
                            member.staffRole!,
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: AppColors.primary,
                              fontWeight: FontWeight.w500,
                              fontSize: 11,
                            ),
                          ),
                        ),
                      const SizedBox(height: 2),
                      Text(
                        l.staffPermissionsSummary(readCount, writeCount),
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: AppColors.textSecondary,
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ),
                ),

                // Context menu (hidden when viewer cannot edit)
                if (isStaff && member.permissions.canRead('manageStaff'))
                  Tooltip(
                    message: l.nurVomArztVerwaltbar,
                    child: Icon(
                      Icons.admin_panel_settings_rounded,
                      size: 20,
                      color: AppColors.textSecondary,
                    ),
                  )
                else if (!canEdit)
                  Tooltip(
                    message: 'Nur ansehen',
                    child: Icon(
                      Icons.visibility_rounded,
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
                    PopupMenuItem(
                      value: _StaffAction.edit,
                      child: ListTile(
                        leading: Icon(Icons.edit_rounded),
                        title: Text(l.edit),
                        dense: true,
                        contentPadding: EdgeInsets.zero,
                      ),
                    ),
                    PopupMenuItem(
                      value: _StaffAction.permissions,
                      child: ListTile(
                        leading: Icon(Icons.tune_rounded),
                        title: Text(l.permissions),
                        dense: true,
                        contentPadding: EdgeInsets.zero,
                      ),
                    ),
                    PopupMenuItem(
                      value: _StaffAction.resetPassword,
                      child: ListTile(
                        leading: Icon(Icons.lock_reset_rounded),
                        title: Text(l.passwordReset),
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
                          isDisabled ? l.activate : l.deactivate,
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
                          l.remove,
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
  const _EmptyStaffState({required this.onCreate, this.canCreate = true});
  final VoidCallback onCreate;
  final bool canCreate;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
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
              l.noStaffYet,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              l.noStaffYetSubtitle,
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
            if (canCreate) ...[
              const SizedBox(height: AppSpacing.xl),
              FilledButton.icon(
                onPressed: onCreate,
                icon: const Icon(Icons.person_add_rounded, size: 18),
                label: Text(l.staffCreate),
              ),
            ] else ...[
              const SizedBox(height: AppSpacing.md),
              Text(
                'Mitarbeiter können nur über die Organisation erstellt werden.',
                textAlign: TextAlign.center,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
