import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../ui/ui.dart';
import '../../doctor_patients/data/doctor_patient_repository.dart';
import '../../doctor_patients/domain/linked_patient.dart';
import '../data/organisation_service.dart';
import '../domain/org_doctor.dart';
import '../domain/org_join_request.dart';
import '../../../l10n/app_localizations.dart';

/// Breakpoint above which the master–detail side-by-side layout is used.
const _kDesktopBreakpoint = 900.0;

/// Tab that lists all doctors belonging to the organisation.
class OrgDoctorsTab extends StatefulWidget {
  const OrgDoctorsTab({super.key});

  @override
  State<OrgDoctorsTab> createState() => _OrgDoctorsTabState();
}

class _OrgDoctorsTabState extends State<OrgDoctorsTab> {
  final _service = OrganisationService();
  String? _inviteCode;
  bool _loadingCode = false;

  // ── Master-detail selection ──────────────────────────────────
  OrgDoctor? _selectedDoctor;

  @override
  void initState() {
    super.initState();
    _loadInviteCode();
  }

  Future<void> _loadInviteCode() async {
    setState(() => _loadingCode = true);
    try {
      final code = await _service.getInviteCode();
      if (mounted) setState(() => _inviteCode = code);
    } catch (_) {
      // Silently fail — org may not be verified yet.
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

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final theme = Theme.of(context);

    final master = SafeArea(
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
                        l.aerzte,
                        style: theme.textTheme.headlineMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    FilledButton.icon(
                      onPressed: _showCreateSheet,
                      icon: const Icon(Icons.person_add_rounded, size: 18),
                      label: Text(l.add),
                    ),
                  ],
                ),
              ),
            ),

            // ── Invite Code Section ──────────────────────
            SliverToBoxAdapter(
              child: _InviteCodeSection(
                code: _inviteCode,
                loading: _loadingCode,
                onCopy: _copyCode,
              ),
            ),
            const SliverToBoxAdapter(
              child: SizedBox(height: AppSpacing.lg),
            ),

            // ── Join Requests ───────────────────────────────
            SliverToBoxAdapter(
              child: _JoinRequestsSection(
                stream: _service.watchJoinRequests(),
                onApprove: _approveRequest,
                onReject: _rejectRequest,
              ),
            ),

            // ── Doctor list ─────────────────────────────────
            SliverToBoxAdapter(
              child: StreamBuilder<List<OrgDoctor>>(
                stream: _service.watchDoctors(),
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
                          l.errorLoadingDoctors,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: AppColors.error,
                          ),
                        ),
                      ),
                    );
                  }

                  final doctors = snap.data ?? [];
                  if (doctors.isEmpty) {
                    return _EmptyDoctorsState(onCreate: _showCreateSheet);
                  }

                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        l.doctorsCountLabel(doctors.length),
                        style: theme.textTheme.titleSmall?.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.sm),
                      ...doctors.map((doctor) => Padding(
                            padding:
                                const EdgeInsets.only(bottom: AppSpacing.sm),
                            child: _DoctorCard(
                              doctor: doctor,
                              onRemove: () => _confirmRemoveDoctor(doctor),
                              onTap: () => _onDoctorTap(doctor),
                              isSelected:
                                  _selectedDoctor?.uid == doctor.uid,
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

/// Streams patients linked to a specific doctor.
class _DoctorPatientsList extends StatefulWidget {
  const _DoctorPatientsList({required this.doctorUid});

  final String doctorUid;

  @override
  State<_DoctorPatientsList> createState() => _DoctorPatientsListState();
}

class _DoctorPatientsListState extends State<_DoctorPatientsList> {
  late final DoctorPatientRepository _repo;
  late final Stream<List<LinkedPatient>> _stream;

  @override
  void initState() {
    super.initState();
    _repo = DoctorPatientRepository(overrideDoctorUid: widget.doctorUid);
    _stream = _repo.watchLinkedPatients();
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final theme = Theme.of(context);

    return StreamBuilder<List<LinkedPatient>>(
      stream: _stream,
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
                          p.displayName.isNotEmpty
                              ? p.displayName[0].toUpperCase()
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
                              p.displayName,
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
    required this.onCopy,
  });

  final String? code;
  final bool loading;
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
              l.inviteCodeLoadError,
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
  final _approbationCtrl = TextEditingController();
  final _practiceNameCtrl = TextEditingController();
  final _kvNumberCtrl = TextEditingController();
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
    _approbationCtrl.dispose();
    _practiceNameCtrl.dispose();
    _kvNumberCtrl.dispose();
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
        approbationNumber: _approbationCtrl.text.trim(),
        practiceName: _practiceNameCtrl.text.trim(),
        kvNumber: _kvNumberCtrl.text.trim(),
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

                    // ── Approbation Number ──────────────────
                    TextFormField(
                      controller: _approbationCtrl,
                      decoration: InputDecoration(
                        labelText: l.doctorRegApprobation,
                        prefixIcon: Icon(Icons.badge_rounded),
                      ),
                      validator: (v) =>
                          (v == null || v.trim().isEmpty) ? l.validationRequired : null,
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
                    const SizedBox(height: AppSpacing.md),

                    // ── KV Number (optional) ────────────────
                    TextFormField(
                      controller: _kvNumberCtrl,
                      decoration: InputDecoration(
                        labelText: l.kVNummerOptional,
                        prefixIcon: Icon(Icons.numbers_rounded),
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
