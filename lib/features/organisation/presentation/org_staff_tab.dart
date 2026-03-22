import 'package:flutter/material.dart';

import '../../../ui/ui.dart';
import '../../doctor_staff/data/staff_management_service.dart';
import '../../doctor_staff/domain/staff_member.dart';
import '../../doctor_staff/presentation/create_staff_sheet.dart';
import '../../doctor_staff/presentation/edit_staff_sheet.dart';
import '../../doctor_staff/presentation/staff_permissions_sheet.dart';
import '../../doctor_staff/presentation/staff_profile_sheet.dart';
import '../../doctor_staff/domain/staff_permissions.dart';

/// Staff tab for the organisation dashboard.
///
/// Reuses the existing staff UI components but with
/// `collectionPrefix: 'organisations'` so queries hit
/// `organisations/{orgUid}/staff` instead of `doctors/{uid}/staff`.
class OrgStaffTab extends StatefulWidget {
  const OrgStaffTab({super.key});

  @override
  State<OrgStaffTab> createState() => _OrgStaffTabState();
}

class _OrgStaffTabState extends State<OrgStaffTab> {
  late final StaffManagementService _service;

  @override
  void initState() {
    super.initState();
    _service = StaffManagementService(
      collectionPrefix: 'organisations',
    );
  }

  Future<void> _showCreateSheet() async {
    final created = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const CreateStaffSheet(),
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
        isStaff: false,
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
      builder: (_) => StaffPermissionsSheet(member: member, isStaff: false),
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
            SnackBar(content: Text(userFacingError(e))),
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
            SnackBar(content: Text(userFacingError(e))),
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
            SnackBar(content: Text(userFacingError(e))),
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
            SnackBar(content: Text(userFacingError(e))),
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
        padding: AppSpacing.screenPadding.copyWith(bottom: 120),
        child: CustomScrollView(
          slivers: [
            // ── Header ──────────────────────────────────────
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

            // ── Staff list ──────────────────────────────────
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
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: AppColors.error,
                          ),
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
                            padding:
                                const EdgeInsets.only(bottom: AppSpacing.sm),
                            child: _StaffCard(
                              member: member,
                              onTap: () => _showProfileSheet(member),
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
// Staff Card
// ─────────────────────────────────────────────────────────────────────────────

class _StaffCard extends StatelessWidget {
  const _StaffCard({required this.member, required this.onTap});

  final StaffMember member;
  final VoidCallback onTap;

  String get _initials {
    final name = member.displayName;
    if (name.isEmpty) return '?';
    final parts = name.split(' ').where((s) => s.isNotEmpty).toList();
    if (parts.length >= 2) {
      return '${parts.first[0]}${parts.last[0]}'.toUpperCase();
    }
    return parts.first[0].toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDisabled = member.status == StaffStatus.disabled;

    return GestureDetector(
      onTap: onTap,
      child: GlassCard(
        child: Row(
          children: [
            CircleAvatar(
              radius: 22,
              backgroundColor: isDisabled
                  ? AppColors.textSecondary.withValues(alpha: 0.12)
                  : AppColors.primary.withValues(alpha: 0.12),
              child: Text(
                _initials,
                style: TextStyle(
                  color:
                      isDisabled ? AppColors.textSecondary : AppColors.primary,
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                ),
              ),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    member.displayName,
                    style: theme.textTheme.bodyLarge?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: isDisabled ? AppColors.textSecondary : null,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xxs),
                  Text(
                    member.email,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.sm,
                vertical: AppSpacing.xxs,
              ),
              decoration: BoxDecoration(
                color: member.isActive
                    ? AppColors.success.withValues(alpha: 0.12)
                    : AppColors.textSecondary.withValues(alpha: 0.12),
                borderRadius: AppRadius.borderRadiusSm,
              ),
              child: Text(
                member.isActive ? 'Aktiv' : 'Deaktiviert',
                style: theme.textTheme.labelSmall?.copyWith(
                  color: member.isActive
                      ? AppColors.success
                      : AppColors.textSecondary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            const SizedBox(width: AppSpacing.xs),
            Icon(
              Icons.chevron_right_rounded,
              color: AppColors.textSecondary,
              size: 20,
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Empty state
// ─────────────────────────────────────────────────────────────────────────────

class _EmptyStaffState extends StatelessWidget {
  const _EmptyStaffState({required this.onCreate});

  final VoidCallback onCreate;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return GlassContainer(
      padding: const EdgeInsets.all(AppSpacing.xxl),
      borderRadius: AppRadius.borderRadiusLg,
      child: Column(
        children: [
          Icon(Icons.people_outline_rounded,
              size: 48, color: AppColors.textSecondary),
          const SizedBox(height: AppSpacing.lg),
          Text(
            'Noch keine Mitarbeiter',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            'Erstellen Sie Mitarbeiter-Accounts für Ihr Team.',
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
    );
  }
}
