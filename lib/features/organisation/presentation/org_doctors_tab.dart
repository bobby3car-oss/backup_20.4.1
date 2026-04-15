import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../ui/ui.dart';
import '../data/organisation_service.dart';
import '../domain/org_doctor.dart';
import '../domain/org_join_request.dart';
import '../domain/org_patient.dart';
import '../../doctor_staff/data/staff_management_service.dart';
import '../../doctor_staff/domain/staff_member.dart';
import '../../doctor_staff/domain/staff_permissions.dart';
import '../../doctor_staff/presentation/create_staff_sheet.dart';
import '../../doctor_staff/presentation/edit_staff_sheet.dart';
import '../../doctor_staff/presentation/staff_permissions_sheet.dart';
import '../../doctor_staff/presentation/staff_profile_sheet.dart';
import '../../../l10n/app_localizations.dart';

/// Breakpoint above which the master–detail side-by-side layout is used.
const _kDesktopBreakpoint = 900.0;

/// Which sub-page is selected in the Team tab.
enum _TeamSection { doctors, staff }

/// Tab that lists all doctors and staff belonging to the organisation.
class OrgDoctorsTab extends StatefulWidget {
  const OrgDoctorsTab({super.key});

  @override
  State<OrgDoctorsTab> createState() => _OrgDoctorsTabState();
}

class _OrgDoctorsTabState extends State<OrgDoctorsTab> {
  final _service = OrganisationService();
  late final StaffManagementService _staffService;
  String? _inviteCode;
  String? _codeError;
  bool _loadingCode = false;

  _TeamSection _section = _TeamSection.doctors;

  // ── Master-detail selection ──────────────────────────────────
  OrgDoctor? _selectedDoctor;

  @override
  void initState() {
    super.initState();
    _staffService = StaffManagementService(
      collectionPrefix: 'organisations',
    );
    _loadInviteCode();
  }

  Future<void> _loadInviteCode() async {
    setState(() {
      _loadingCode = true;
      _codeError = null;
    });
    try {
      final code = await _service.getInviteCode();
      if (mounted) setState(() => _inviteCode = code);
    } catch (e) {
      if (mounted) setState(() => _codeError = userFacingError(e));
    } finally {
      if (mounted) setState(() => _loadingCode = false);
    }
  }

  Future<void> _copyCode() async {
    if (_inviteCode == null) return;
    await Clipboard.setData(ClipboardData(text: _inviteCode!));
    if (mounted) {
      final l = AppLocalizations.of(context)!;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l.codeCopied)),
      );
    }
  }

  Future<void> _approveRequest(OrgJoinRequest request) async {
    final l = AppLocalizations.of(context)!;
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l.doctorConfirm),
        content: Text(
          l.confirmAddDoctorToOrg(request.doctorName),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(l.cancel),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(l.confirm),
          ),
        ],
      ),
    );
    if (confirm != true || !mounted) return;
    try {
      await _service.resolveJoinRequest(request.id, approved: true);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l.doctorHinzugefuegt(request.doctorName))),
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

  Future<void> _rejectRequest(OrgJoinRequest request) async {
    final l = AppLocalizations.of(context)!;
    final reasonCtrl = TextEditingController();
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l.declineRequest),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(l.anfrageAblehnenBestaetigung(request.doctorName)),
            const SizedBox(height: AppSpacing.md),
            TextField(
              controller: reasonCtrl,
              decoration: InputDecoration(
                labelText: l.grundOptional,
                border: OutlineInputBorder(),
              ),
              maxLines: 2,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(l.cancel),
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: AppColors.error),
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(l.decline),
          ),
        ],
      ),
    );
    if (confirm != true || !mounted) return;
    try {
      await _service.resolveJoinRequest(
        request.id,
        approved: false,
        rejectionReason:
            reasonCtrl.text.trim().isEmpty ? null : reasonCtrl.text.trim(),
      );
      if (mounted) {
        final l = AppLocalizations.of(context)!;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l.requestDeclined)),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(userFacingError(e))),
        );
      }
    }
    reasonCtrl.dispose();
  }

  Future<void> _showCreateSheet() async {
    final created = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const _CreateOrgDoctorSheet(),
    );
    if (created == true && mounted) {
      final l = AppLocalizations.of(context)!;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l.doctorCreated)),
      );
    }
  }

  Future<void> _confirmRemoveDoctor(OrgDoctor doctor) async {
    final l = AppLocalizations.of(context)!;
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l.doctorRemove),
        content: Text(
          l.confirmRemoveDoctorFromOrg(doctor.name),
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
        await _service.removeDoctor(doctor.uid);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(l.doctorEntfernt(doctor.name))),
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

  void _onDoctorTap(OrgDoctor doctor) {
    final width = MediaQuery.of(context).size.width;
    if (width >= _kDesktopBreakpoint) {
      setState(() => _selectedDoctor = doctor);
    }
    // On mobile there's no navigation target yet – tap does nothing extra.
  }

  // ── Staff management ────────────────────────────────────────

  Future<void> _showCreateStaffSheet() async {
    final created = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const CreateStaffSheet(collectionPrefix: 'organisations'),
    );
    if (created == true && mounted) {
      final l = AppLocalizations.of(context)!;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l.staffCreated)),
      );
    }
  }

  void _showStaffProfileSheet(StaffMember member) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => StaffProfileSheet(
        member: member,
        isStaff: false,
        onEdit: () => _showEditStaffSheet(member),
        onPermissions: () => _showStaffPermissionsSheet(member),
        onResetPassword: () => _showResetStaffPasswordDialog(member),
        onToggleDisabled: () => _toggleStaffDisabled(member),
        onRemove: () => _confirmRemoveStaff(member),
      ),
    );
  }

  Future<void> _showEditStaffSheet(StaffMember member) async {
    final updated = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => EditStaffSheet(
        member: member,
        collectionPrefix: 'organisations',
      ),
    );
    if (updated == true && mounted) {
      final l = AppLocalizations.of(context)!;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l.staffUpdated)),
      );
    }
  }

  Future<void> _showStaffPermissionsSheet(StaffMember member) async {
    final updated = await showModalBottomSheet<StaffPermissions>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => StaffPermissionsSheet(member: member, isStaff: false),
    );
    if (updated != null && mounted) {
      try {
        await _staffService.updatePermissions(member.uid, updated);
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

  Future<void> _showResetStaffPasswordDialog(StaffMember member) async {
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
        await _staffService.resetStaffPassword(
          staffUid: member.uid,
          newPassword: passwordCtrl.text,
        );
        if (mounted) {
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

  Future<void> _toggleStaffDisabled(StaffMember member) async {
    final l = AppLocalizations.of(context)!;
    final isDisabled = member.status == StaffStatus.disabled;
    final action = isDisabled ? l.actionActivate : l.actionDeactivate;

    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l.mitarbeiterAction(action)),
        content: Text(
          isDisabled
              ? l.staffConfirmActivateBody(member.displayName)
              : l.staffConfirmDeactivateBody(member.displayName),
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
        await _staffService.toggleStaffDisabled(
          staffUid: member.uid,
          disabled: !isDisabled,
        );
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                isDisabled
                    ? l.staffWasActivated(member.displayName)
                    : l.staffWasDeactivated(member.displayName),
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

  Future<void> _confirmRemoveStaff(StaffMember member) async {
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
        await _staffService.removeStaff(member.uid);
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

    // ── Build the selected sub-page ──────────────────────────
    Widget content;
    if (_section == _TeamSection.doctors) {
      content = _DoctorsSubPage(
        service: _service,
        inviteCode: _inviteCode,
        codeError: _codeError,
        loadingCode: _loadingCode,
        onCopy: _copyCode,
        selectedDoctor: _selectedDoctor,
        onDoctorTap: _onDoctorTap,
        onCreateDoctor: _showCreateSheet,
        onRemoveDoctor: _confirmRemoveDoctor,
        onApproveRequest: _approveRequest,
        onRejectRequest: _rejectRequest,
      );
    } else {
      content = _StaffSubPage(
        staffService: _staffService,
        onCreateStaff: _showCreateStaffSheet,
        onStaffProfile: _showStaffProfileSheet,
      );
    }

    final master = SafeArea(
      bottom: false,
      child: Column(
        children: [
          // ── Header + Segment ──────────────────────────────
          Padding(
            padding: AppSpacing.screenPadding.copyWith(
              top: AppSpacing.xl,
              bottom: 0,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ── Title row ───────────────────────────────
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        l.teamHeader,
                        style: theme.textTheme.headlineMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    // ── Add button context-aware ─────────────
                    FilledButton.icon(
                      onPressed: _section == _TeamSection.doctors
                          ? _showCreateSheet
                          : _showCreateStaffSheet,
                      icon: const Icon(Icons.person_add_rounded, size: 18),
                      label: Text(
                        _section == _TeamSection.doctors
                            ? l.doctorAdd
                            : l.create,
                      ),
                      style: FilledButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppSpacing.lg,
                          vertical: AppSpacing.sm,
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: AppSpacing.xl),

                // ── Segmented Control ───────────────────────
                SizedBox(
                  width: double.infinity,
                  child: CupertinoSlidingSegmentedControl<_TeamSection>(
                    groupValue: _section,
                    backgroundColor: AppColors.primary.withValues(alpha: 0.06),
                    thumbColor: theme.brightness == Brightness.dark
                        ? const Color(0xFF2C2C2E)
                        : Colors.white,
                    children: {
                      _TeamSection.doctors: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppSpacing.lg,
                          vertical: AppSpacing.sm,
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.medical_services_rounded,
                              size: 16,
                              color: _section == _TeamSection.doctors
                                  ? AppColors.primary
                                  : AppColors.textSecondary,
                            ),
                            const SizedBox(width: AppSpacing.xs),
                            Text(
                              l.tabDoctors,
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: _section == _TeamSection.doctors
                                    ? AppColors.primary
                                    : AppColors.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ),
                      _TeamSection.staff: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppSpacing.lg,
                          vertical: AppSpacing.sm,
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.badge_rounded,
                              size: 16,
                              color: _section == _TeamSection.staff
                                  ? AppColors.primary
                                  : AppColors.textSecondary,
                            ),
                            const SizedBox(width: AppSpacing.xs),
                            Text(
                              l.staffSectionTitle,
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: _section == _TeamSection.staff
                                    ? AppColors.primary
                                    : AppColors.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ),
                    },
                    onValueChanged: (v) {
                      if (v != null) {
                        Haptic.selection();
                        setState(() {
                          _section = v;
                          _selectedDoctor = null;
                        });
                      }
                    },
                  ),
                ),

                const SizedBox(height: AppSpacing.lg),
              ],
            ),
          ),

          // ── Content ────────────────────────────────────────
          Expanded(child: content),
        ],
      ),
    );

    // On the doctor sub-page we support master-detail
    if (_section == _TeamSection.doctors) {
      return MasterDetailLayout(
        masterWidget: master,
        detailWidget: _selectedDoctor != null
            ? _OrgDoctorDetailPanel(
                key: ValueKey(_selectedDoctor!.uid),
                doctor: _selectedDoctor!,
                onRemove: () => _confirmRemoveDoctor(_selectedDoctor!),
              )
            : null,
        detailSelected: _selectedDoctor != null,
        onBackFromDetail: () => setState(() => _selectedDoctor = null),
        emptyIcon: Icons.medical_services_outlined,
        emptyText: l.selectDoctorForDetails,
      );
    }

    return master;
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Doctors Sub-Page
// ─────────────────────────────────────────────────────────────────────────────

class _DoctorsSubPage extends StatelessWidget {
  const _DoctorsSubPage({
    required this.service,
    required this.inviteCode,
    this.codeError,
    required this.loadingCode,
    required this.onCopy,
    required this.selectedDoctor,
    required this.onDoctorTap,
    required this.onCreateDoctor,
    required this.onRemoveDoctor,
    required this.onApproveRequest,
    required this.onRejectRequest,
  });

  final OrganisationService service;
  final String? inviteCode;
  final String? codeError;
  final bool loadingCode;
  final VoidCallback onCopy;
  final OrgDoctor? selectedDoctor;
  final ValueChanged<OrgDoctor> onDoctorTap;
  final VoidCallback onCreateDoctor;
  final ValueChanged<OrgDoctor> onRemoveDoctor;
  final ValueChanged<OrgJoinRequest> onApproveRequest;
  final ValueChanged<OrgJoinRequest> onRejectRequest;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;

    return ListView(
      padding: AppSpacing.screenPadding.copyWith(bottom: 120, top: 0),
      children: [
        // ── Invite Code ──────────────────────────────────────
        _InviteCodeSection(
          code: inviteCode,
          loading: loadingCode,
          error: codeError,
          onCopy: onCopy,
        ),
        const SizedBox(height: AppSpacing.lg),

        // ── Join Requests ────────────────────────────────────
        _JoinRequestsSection(
          stream: service.watchJoinRequests(),
          onApprove: onApproveRequest,
          onReject: onRejectRequest,
        ),

        // ── Doctor List ──────────────────────────────────────
        StreamBuilder<List<OrgDoctor>>(
          stream: service.watchDoctors(),
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
              return _ErrorCard(
                message: l.errorLoadingDoctors,
                icon: Icons.error_outline_rounded,
              );
            }

            final doctors = snap.data ?? [];

            // ── Stats bar ──────────────────────────
            final active = doctors.where((d) => d.isActive).length;

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ── Stats row ─────────────────────────────────
                if (doctors.isNotEmpty) ...[
                  Row(
                    children: [
                      _StatChip(
                        icon: Icons.people_rounded,
                        label: '${doctors.length}',
                        subtitle: l.tabDoctors,
                        color: AppColors.primary,
                      ),
                      const SizedBox(width: AppSpacing.sm),
                      _StatChip(
                        icon: Icons.check_circle_rounded,
                        label: '$active',
                        subtitle: l.statusActive,
                        color: AppColors.success,
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.lg),
                ],

                if (doctors.isEmpty)
                  _EmptyDoctorsState(onCreate: onCreateDoctor)
                else
                  ...doctors.map((doctor) => Padding(
                        padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                        child: _DoctorCard(
                          doctor: doctor,
                          onRemove: () => onRemoveDoctor(doctor),
                          onTap: () => onDoctorTap(doctor),
                          isSelected: selectedDoctor?.uid == doctor.uid,
                        ),
                      )),
              ],
            );
          },
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Staff Sub-Page
// ─────────────────────────────────────────────────────────────────────────────

class _StaffSubPage extends StatelessWidget {
  const _StaffSubPage({
    required this.staffService,
    required this.onCreateStaff,
    required this.onStaffProfile,
  });

  final StaffManagementService staffService;
  final VoidCallback onCreateStaff;
  final ValueChanged<StaffMember> onStaffProfile;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;

    return StreamBuilder<List<StaffMember>>(
      stream: staffService.watchMyStaff(),
      builder: (context, snap) {
        if (snap.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snap.hasError) {
          return Padding(
            padding: AppSpacing.screenPadding,
            child: _ErrorCard(
              message: l.staffLoadError,
              icon: Icons.error_outline_rounded,
            ),
          );
        }

        final staff = snap.data ?? [];

        if (staff.isEmpty) {
          return Padding(
            padding: AppSpacing.screenPadding,
            child: _EmptyStaffState(onCreate: onCreateStaff),
          );
        }

        final active = staff.where((s) => s.isActive).length;
        final disabled = staff.length - active;

        return ListView(
          padding: AppSpacing.screenPadding.copyWith(bottom: 120, top: 0),
          children: [
            // ── Stats row ─────────────────────────────────────
            Row(
              children: [
                _StatChip(
                  icon: Icons.badge_rounded,
                  label: '${staff.length}',
                  subtitle: l.staffSectionTitle,
                  color: AppColors.primary,
                ),
                const SizedBox(width: AppSpacing.sm),
                _StatChip(
                  icon: Icons.check_circle_rounded,
                  label: '$active',
                  subtitle: l.statusActive,
                  color: AppColors.success,
                ),
                if (disabled > 0) ...[
                  const SizedBox(width: AppSpacing.sm),
                  _StatChip(
                    icon: Icons.block_rounded,
                    label: '$disabled',
                    subtitle: l.statusDisabled,
                    color: AppColors.textSecondary,
                  ),
                ],
              ],
            ),
            const SizedBox(height: AppSpacing.lg),

            // ── Staff list ────────────────────────────────────
            ...staff.map((member) => Padding(
                  padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                  child: _OrgStaffCard(
                    member: member,
                    onTap: () => onStaffProfile(member),
                  ),
                )),
          ],
        );
      },
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Stat Chip
// ─────────────────────────────────────────────────────────────────────────────

class _StatChip extends StatelessWidget {
  const _StatChip({
    required this.icon,
    required this.label,
    required this.subtitle,
    required this.color,
  });

  final IconData icon;
  final String label;
  final String subtitle;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Expanded(
      child: GlassContainer(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.md,
        ),
        borderRadius: AppRadius.borderRadiusMd,
        variant: GlassVariant.thin,
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(AppSpacing.sm),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.12),
                borderRadius: AppRadius.borderRadiusSm,
              ),
              child: Icon(icon, size: 18, color: color),
            ),
            const SizedBox(width: AppSpacing.md),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
                Text(
                  subtitle,
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Error Card
// ─────────────────────────────────────────────────────────────────────────────

class _ErrorCard extends StatelessWidget {
  const _ErrorCard({required this.message, required this.icon});

  final String message;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return GlassCard(
      child: Row(
        children: [
          Icon(icon, color: AppColors.error, size: 24),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Text(
              message,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: AppColors.error,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Doctor Card
// ─────────────────────────────────────────────────────────────────────────────

class _DoctorCard extends StatelessWidget {
  const _DoctorCard({
    required this.doctor,
    required this.onRemove,
    this.onTap,
    this.isSelected = false,
  });

  final OrgDoctor doctor;
  final VoidCallback onRemove;
  final VoidCallback? onTap;
  final bool isSelected;

  String get _initials {
    if (doctor.name.isEmpty) return '?';
    final parts = doctor.name.split(' ').where((s) => s.isNotEmpty).toList();
    if (parts.length >= 2) {
      return '${parts.first[0]}${parts.last[0]}'.toUpperCase();
    }
    return parts.first[0].toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final theme = Theme.of(context);

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        decoration: isSelected
            ? BoxDecoration(
                borderRadius: AppRadius.borderRadiusLg,
                border: Border.all(color: AppColors.primary, width: 2),
              )
            : null,
        child: GlassCard(
      child: Row(
        children: [
          CircleAvatar(
            radius: 22,
            backgroundColor: AppColors.primary.withValues(alpha: 0.12),
            child: Text(
              _initials,
              style: TextStyle(
                color: AppColors.primary,
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
                  doctor.name,
                  style: theme.textTheme.bodyLarge?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: AppSpacing.xxs),
                Text(
                  doctor.email,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
                if (doctor.specialty.isNotEmpty) ...[
                  const SizedBox(height: AppSpacing.xxs),
                  Text(
                    doctor.specialty,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: AppColors.primary,
                    ),
                  ),
                ],
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.sm,
              vertical: AppSpacing.xxs,
            ),
            decoration: BoxDecoration(
              color: doctor.isActive
                  ? AppColors.success.withValues(alpha: 0.12)
                  : AppColors.textSecondary.withValues(alpha: 0.12),
              borderRadius: AppRadius.borderRadiusSm,
            ),
            child: Text(
              doctor.isActive ? l.statusActive : doctor.status,
              style: theme.textTheme.labelSmall?.copyWith(
                color: doctor.isActive
                    ? AppColors.success
                    : AppColors.textSecondary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          PopupMenuButton<String>(
            onSelected: (value) {
              if (value == 'remove') onRemove();
            },
            itemBuilder: (_) => [
              PopupMenuItem(
                value: 'remove',
                child: Row(
                  children: [
                    Icon(Icons.person_remove_rounded,
                        size: 18, color: Colors.red),
                    SizedBox(width: AppSpacing.sm),
                    Text(l.remove),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Doctor Detail Panel (desktop right-side)
// ─────────────────────────────────────────────────────────────────────────────

class _OrgDoctorDetailPanel extends StatelessWidget {
  const _OrgDoctorDetailPanel({
    super.key,
    required this.doctor,
    required this.onRemove,
  });

  final OrgDoctor doctor;
  final VoidCallback onRemove;

  String get _initials {
    if (doctor.name.isEmpty) return '?';
    final parts = doctor.name.split(' ').where((s) => s.isNotEmpty).toList();
    if (parts.length >= 2) {
      return '${parts.first[0]}${parts.last[0]}'.toUpperCase();
    }
    return parts.first[0].toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l = AppLocalizations.of(context)!;

    return SafeArea(
      bottom: false,
      child: ListView(
        padding: const EdgeInsets.all(AppSpacing.xl),
        children: [
          // ── Doctor header ────────────────────────────────
          GlassCard(
            child: Column(
              children: [
                CircleAvatar(
                  radius: 36,
                  backgroundColor: AppColors.primary.withValues(alpha: 0.12),
                  child: Text(
                    _initials,
                    style: TextStyle(
                      color: AppColors.primary,
                      fontWeight: FontWeight.w700,
                      fontSize: 22,
                    ),
                  ),
                ),
                const SizedBox(height: AppSpacing.md),
                Text(
                  doctor.name,
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                if (doctor.specialty.isNotEmpty) ...[
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    doctor.specialty,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: AppColors.primary,
                    ),
                  ),
                ],
                const SizedBox(height: AppSpacing.md),
                // ── Info rows ───────────────────────────────
                _InfoRow(icon: Icons.email_outlined, label: doctor.email),
                _InfoRow(
                  icon: Icons.circle,
                  iconSize: 10,
                  label: doctor.isActive ? l.statusActive : doctor.status,
                  labelColor:
                      doctor.isActive ? AppColors.success : AppColors.textSecondary,
                ),
                if (doctor.addedAt != null)
                  _InfoRow(
                    icon: Icons.calendar_today_outlined,
                    label:
                        l.joinedOn('${doctor.addedAt!.day}.${doctor.addedAt!.month}.${doctor.addedAt!.year}'),
                  ),
              ],
            ),
          ),

          const SizedBox(height: AppSpacing.lg),

          // ── Patients section ─────────────────────────────
          Text(
            l.sectionPatients,
            style: theme.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          _DoctorPatientsList(doctorUid: doctor.uid),

          const SizedBox(height: AppSpacing.xxl),

          // ── Remove button ────────────────────────────────
          OutlinedButton.icon(
            onPressed: onRemove,
            icon: const Icon(Icons.person_remove_rounded, size: 18),
            label: Text(l.remove),
            style: OutlinedButton.styleFrom(
              foregroundColor: AppColors.error,
              side: BorderSide(color: AppColors.error.withValues(alpha: 0.5)),
            ),
          ),
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({
    required this.icon,
    required this.label,
    this.iconSize = 16,
    this.labelColor,
  });

  final IconData icon;
  final String label;
  final double iconSize;
  final Color? labelColor;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.xs),
      child: Row(
        children: [
          Icon(icon, size: iconSize, color: AppColors.textSecondary),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Text(
              label,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: labelColor ?? AppColors.textPrimary,
                  ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Loads patients linked to a specific doctor via Cloud Function.
class _DoctorPatientsList extends StatefulWidget {
  const _DoctorPatientsList({required this.doctorUid});

  final String doctorUid;

  @override
  State<_DoctorPatientsList> createState() => _DoctorPatientsListState();
}

class _DoctorPatientsListState extends State<_DoctorPatientsList> {
  final _service = OrganisationService();
  late Future<List<OrgPatient>> _future;

  @override
  void initState() {
    super.initState();
    _future = _loadPatients();
  }

  Future<List<OrgPatient>> _loadPatients() async {
    final all = await _service.fetchAllOrgPatients();
    return all.where((p) => p.doctorId == widget.doctorUid).toList();
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final theme = Theme.of(context);

    return FutureBuilder<List<OrgPatient>>(
      future: _future,
      builder: (context, snap) {
        if (snap.connectionState == ConnectionState.waiting) {
          return const Padding(
            padding: EdgeInsets.all(AppSpacing.xl),
            child: Center(
              child: SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            ),
          );
        }

        final patients = snap.data ?? [];
        if (patients.isEmpty) {
          return Padding(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: Text(
              l.noPatientsLinked,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          );
        }

        return Column(
          children: [
            for (final p in patients)
              Padding(
                padding: const EdgeInsets.only(bottom: AppSpacing.xs),
                child: GlassCard(
                  child: Row(
                    children: [
                      CircleAvatar(
                        radius: 18,
                        backgroundColor:
                            AppColors.primary.withValues(alpha: 0.10),
                        child: Text(
                          p.patientName.isNotEmpty
                              ? p.patientName[0].toUpperCase()
                              : '?',
                          style: TextStyle(
                            color: AppColors.primary,
                            fontWeight: FontWeight.w600,
                            fontSize: 13,
                          ),
                        ),
                      ),
                      const SizedBox(width: AppSpacing.md),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              p.patientName.isNotEmpty
                                  ? p.patientName
                                  : p.patientEmail,
                              style: theme.textTheme.bodyMedium?.copyWith(
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            if (p.diagnosis != null &&
                                p.diagnosis!.isNotEmpty)
                              Text(
                                p.diagnosis!,
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: AppColors.textSecondary,
                                ),
                              ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
          ],
        );
      },
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Invite Code Section
// ─────────────────────────────────────────────────────────────────────────────

class _InviteCodeSection extends StatelessWidget {
  const _InviteCodeSection({
    required this.code,
    required this.loading,
    this.error,
    required this.onCopy,
  });

  final String? code;
  final bool loading;
  final String? error;
  final VoidCallback onCopy;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final theme = Theme.of(context);

    return GlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.link_rounded, size: 20, color: AppColors.primary),
              const SizedBox(width: AppSpacing.sm),
              Text(
                l.inviteCode,
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            l.inviteCodeDescription,
            style: theme.textTheme.bodySmall?.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          if (loading)
            const Center(
              child: Padding(
                padding: EdgeInsets.all(AppSpacing.md),
                child: SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
              ),
            )
          else if (code != null)
            Row(
              children: [
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.md,
                      vertical: AppSpacing.sm,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.08),
                      borderRadius: AppRadius.borderRadiusSm,
                      border: Border.all(
                        color: AppColors.primary.withValues(alpha: 0.2),
                      ),
                    ),
                    child: Text(
                      code!,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        letterSpacing: 2,
                        fontFamily: 'monospace',
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                IconButton.filled(
                  onPressed: onCopy,
                  icon: const Icon(Icons.copy_rounded, size: 18),
                  tooltip: l.codeCopy,
                ),
              ],
            )
          else
            Text(
              error ?? l.inviteCodeLoadError,
              style: theme.textTheme.bodySmall?.copyWith(
                color: AppColors.error,
              ),
            ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Join Requests Section
// ─────────────────────────────────────────────────────────────────────────────

class _JoinRequestsSection extends StatelessWidget {
  const _JoinRequestsSection({
    required this.stream,
    required this.onApprove,
    required this.onReject,
  });

  final Stream<List<OrgJoinRequest>> stream;
  final ValueChanged<OrgJoinRequest> onApprove;
  final ValueChanged<OrgJoinRequest> onReject;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final theme = Theme.of(context);

    return StreamBuilder<List<OrgJoinRequest>>(
      stream: stream,
      builder: (context, snap) {
        if (snap.connectionState == ConnectionState.waiting) {
          return const SizedBox.shrink();
        }

        final all = snap.data ?? [];
        final pending = all.where((r) => r.isPending).toList();

        if (pending.isEmpty) return const SizedBox.shrink();

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.person_add_alt_1_rounded,
                    size: 20, color: AppColors.warning),
                const SizedBox(width: AppSpacing.sm),
                Text(
                  l.joinRequestsCountLabel(pending.length),
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.sm),
            ...pending.map((req) => Padding(
                  padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                  child: _JoinRequestCard(
                    request: req,
                    onApprove: () => onApprove(req),
                    onReject: () => onReject(req),
                  ),
                )),
            const SizedBox(height: AppSpacing.md),
          ],
        );
      },
    );
  }
}

class _JoinRequestCard extends StatelessWidget {
  const _JoinRequestCard({
    required this.request,
    required this.onApprove,
    required this.onReject,
  });

  final OrgJoinRequest request;
  final VoidCallback onApprove;
  final VoidCallback onReject;

  String get _initials {
    if (request.doctorName.isEmpty) return '?';
    final parts =
        request.doctorName.split(' ').where((s) => s.isNotEmpty).toList();
    if (parts.length >= 2) {
      return '${parts.first[0]}${parts.last[0]}'.toUpperCase();
    }
    return parts.first[0].toUpperCase();
  }

  String _timeAgo(AppLocalizations l) {
    final diff = DateTime.now().difference(request.requestedAt);
    if (diff.inMinutes < 60) return l.timeAgoMinutes(diff.inMinutes);
    if (diff.inHours < 24) return l.timeAgoHours(diff.inHours);
    return l.timeAgoDays(diff.inDays);
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final theme = Theme.of(context);

    return GlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 22,
                backgroundColor: AppColors.warning.withValues(alpha: 0.12),
                child: Text(
                  _initials,
                  style: TextStyle(
                    color: AppColors.warning,
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
                      request.doctorName,
                      style: theme.textTheme.bodyLarge?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.xxs),
                    Text(
                      request.doctorEmail,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                    if (request.doctorSpecialty.isNotEmpty) ...[
                      const SizedBox(height: AppSpacing.xxs),
                      Text(
                        request.doctorSpecialty,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: AppColors.primary,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              Text(
                _timeAgo(l),
                style: theme.textTheme.labelSmall?.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              OutlinedButton.icon(
                onPressed: onReject,
                icon: const Icon(Icons.close_rounded, size: 18),
                label: Text(l.decline),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.error,
                  side: BorderSide(
                    color: AppColors.error.withValues(alpha: 0.5),
                  ),
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              FilledButton.icon(
                onPressed: onApprove,
                icon: const Icon(Icons.check_rounded, size: 18),
                label: Text(l.accept),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Empty state
// ─────────────────────────────────────────────────────────────────────────────

class _EmptyDoctorsState extends StatelessWidget {
  const _EmptyDoctorsState({required this.onCreate});

  final VoidCallback onCreate;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    return GlassContainer(
      padding: const EdgeInsets.all(AppSpacing.xxl),
      borderRadius: AppRadius.borderRadiusLg,
      child: Column(
        children: [
          Icon(Icons.medical_services_outlined,
              size: 48, color: AppColors.textSecondary),
          const SizedBox(height: AppSpacing.lg),
          Text(
            l.noDoctorsYet,
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            l.addDoctorsToOrg,
            textAlign: TextAlign.center,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: AppSpacing.xl),
          FilledButton.icon(
            onPressed: onCreate,
            icon: const Icon(Icons.person_add_rounded, size: 18),
            label: Text(l.doctorAdd),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Create Doctor Sheet
// ─────────────────────────────────────────────────────────────────────────────

class _CreateOrgDoctorSheet extends StatefulWidget {
  const _CreateOrgDoctorSheet();

  @override
  State<_CreateOrgDoctorSheet> createState() => _CreateOrgDoctorSheetState();
}

class _CreateOrgDoctorSheetState extends State<_CreateOrgDoctorSheet> {
  static List<String> _specialties(AppLocalizations l) => [
    l.specialtyGeneralSurgery,
    l.specialtyOrthopedics,
    l.specialtyVisceralSurgery,
    l.specialtyCardiacSurgery,
    l.specialtyNeurosurgery,
    l.specialtyVascularSurgery,
    l.specialtyPlasticSurgery,
    l.specialtyUrology,
    l.specialtyGynecology,
    l.specialtyEnt,
    l.specialtyOphthalmology,
    l.specialtyInternalMedicine,
    l.specialtyAnesthesiology,
    l.specialtyOther,
  ];

  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  final _confirmCtrl = TextEditingController();
  final _practiceNameCtrl = TextEditingController();
  final _service = OrganisationService();

  String? _selectedSpecialty;
  var _loading = false;
  var _obscurePassword = true;
  var _obscureConfirm = true;

  @override
  void dispose() {
    _nameCtrl.dispose();
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
    _confirmCtrl.dispose();
    _practiceNameCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedSpecialty == null) {
      final l = AppLocalizations.of(context)!;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l.selectSpecialty)),
      );
      return;
    }

    setState(() => _loading = true);
    try {
      await _service.registerDoctor(
        name: _nameCtrl.text.trim(),
        email: _emailCtrl.text.trim(),
        password: _passwordCtrl.text,
        specialty: _selectedSpecialty!,
        practiceName: _practiceNameCtrl.text.trim(),
      );
      if (mounted) Navigator.pop(context, true);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(userFacingError(e))),
        );
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: SafeArea(
        child: DraggableScrollableSheet(
          initialChildSize: 0.9,
          minChildSize: 0.5,
          maxChildSize: 0.95,
          expand: false,
          builder: (context, scrollController) {
            final l = AppLocalizations.of(context)!;
            return GlassContainer(
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(24),
              ),
              padding: const EdgeInsets.all(AppSpacing.xl),
              child: Form(
                key: _formKey,
                child: ListView(
                  controller: scrollController,
                  children: [
                    // ── Handle ──────────────────────────────
                    Center(
                      child: Container(
                        width: 40,
                        height: 4,
                        decoration: BoxDecoration(
                          color: AppColors.textSecondary.withValues(alpha: 0.3),
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ),
                    const SizedBox(height: AppSpacing.lg),

                    Text(
                      l.createNewDoctor,
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.xxl),

                    // ── Name ────────────────────────────────
                    TextFormField(
                      controller: _nameCtrl,
                      decoration: InputDecoration(
                        labelText: l.fieldFullName,
                        prefixIcon: Icon(Icons.person_rounded),
                      ),
                      textCapitalization: TextCapitalization.words,
                      validator: (v) =>
                          (v == null || v.trim().isEmpty) ? l.validationRequired : null,
                    ),
                    const SizedBox(height: AppSpacing.md),

                    // ── Email ───────────────────────────────
                    TextFormField(
                      controller: _emailCtrl,
                      decoration: InputDecoration(
                        labelText: l.fieldEmail,
                        prefixIcon: Icon(Icons.email_rounded),
                      ),
                      keyboardType: TextInputType.emailAddress,
                      validator: (v) {
                        if (v == null || v.trim().isEmpty) return l.validationRequired;
                        if (!v.contains('@')) return l.validationInvalidEmail;
                        return null;
                      },
                    ),
                    const SizedBox(height: AppSpacing.md),

                    // ── Password ────────────────────────────
                    TextFormField(
                      controller: _passwordCtrl,
                      decoration: InputDecoration(
                        labelText: l.fieldPassword,
                        prefixIcon: const Icon(Icons.lock_rounded),
                        suffixIcon: IconButton(
                          icon: Icon(_obscurePassword
                              ? Icons.visibility_off_rounded
                              : Icons.visibility_rounded),
                          onPressed: () => setState(
                              () => _obscurePassword = !_obscurePassword),
                        ),
                      ),
                      obscureText: _obscurePassword,
                      validator: (v) {
                        if (v == null || v.length < 8) {
                          return l.validationMinChars8;
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: AppSpacing.md),

                    // ── Confirm Password ────────────────────
                    TextFormField(
                      controller: _confirmCtrl,
                      decoration: InputDecoration(
                        labelText: l.passwordConfirm,
                        prefixIcon: const Icon(Icons.lock_rounded),
                        suffixIcon: IconButton(
                          icon: Icon(_obscureConfirm
                              ? Icons.visibility_off_rounded
                              : Icons.visibility_rounded),
                          onPressed: () => setState(
                              () => _obscureConfirm = !_obscureConfirm),
                        ),
                      ),
                      obscureText: _obscureConfirm,
                      validator: (v) {
                        if (v != _passwordCtrl.text) {
                          final l = AppLocalizations.of(context)!;
                          return l.passwordsMismatch;
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: AppSpacing.md),

                    // ── Specialty ───────────────────────────
                    DropdownButtonFormField<String>(
                      initialValue: _selectedSpecialty,
                      decoration: InputDecoration(
                        labelText: l.doctorRegSpecialty,
                        prefixIcon: Icon(Icons.medical_services_rounded),
                      ),
                      items: _specialties(l)
                          .map((s) =>
                              DropdownMenuItem(value: s, child: Text(s)))
                          .toList(),
                      onChanged: (v) =>
                          setState(() => _selectedSpecialty = v),
                      validator: (v) =>
                          v == null ? l.bitteAuswaehlen : null,
                    ),
                    const SizedBox(height: AppSpacing.md),

                    // ── Practice Name (optional) ────────────
                    TextFormField(
                      controller: _practiceNameCtrl,
                      decoration: InputDecoration(
                        labelText: l.praxisnameOptional,
                        prefixIcon: Icon(Icons.local_hospital_rounded),
                      ),
                    ),
                    const SizedBox(height: AppSpacing.xxl),

                    // ── Submit ──────────────────────────────
                    GlassButton(
                      onPressed: _loading ? null : _submit,
                      label: _loading ? l.creating : l.createDoctor,
                      icon: Icons.person_add_rounded,
                      expand: true,
                    ),
                    const SizedBox(height: AppSpacing.lg),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Staff Card (for org view)
// ─────────────────────────────────────────────────────────────────────────────

class _OrgStaffCard extends StatelessWidget {
  const _OrgStaffCard({required this.member, required this.onTap});

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
    final l = AppLocalizations.of(context)!;
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
                member.isActive ? l.statusActive : l.statusDisabled,
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
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Empty Staff State
// ─────────────────────────────────────────────────────────────────────────────

class _EmptyStaffState extends StatelessWidget {
  const _EmptyStaffState({required this.onCreate});

  final VoidCallback onCreate;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final theme = Theme.of(context);

    return GlassCard(
      child: Column(
        children: [
          Icon(
            Icons.group_outlined,
            size: 48,
            color: AppColors.textSecondary.withValues(alpha: 0.5),
          ),
          const SizedBox(height: AppSpacing.md),
          Text(
            l.staffCreate,
            style: theme.textTheme.titleSmall?.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          FilledButton.icon(
            onPressed: onCreate,
            icon: const Icon(Icons.person_add_rounded, size: 18),
            label: Text(l.create),
          ),
        ],
      ),
    );
  }
}
