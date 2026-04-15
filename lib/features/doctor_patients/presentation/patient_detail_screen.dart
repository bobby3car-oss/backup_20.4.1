import 'dart:ui';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../../../l10n/app_localizations.dart';

import '../../../features/appointments/domain/appointment.dart';
import '../../../features/appointments/domain/appointment_enums.dart';
import '../../../features/doctor_staff/domain/staff_permissions.dart';
import '../../../firebase/firebase_paths.dart';
import '../../../ui/ui.dart';
import '../data/doctor_patient_repository.dart';
import '../domain/linked_patient.dart';
import '../../aftercare/data/aftercare_template_service.dart';
import '../../aftercare/data/patient_aftercare_plan_service.dart';
import '../../aftercare/presentation/assign_plan_screen.dart';
import '../../aftercare/presentation/patient_aftercare_plan_tab.dart';

/// Detail screen for a single patient, showing the aftercare plan tab
/// and quick-action buttons.
class PatientDetailScreen extends StatefulWidget {
  const PatientDetailScreen({
    super.key,
    required this.patient,
    this.doctorUid,
    this.staffPermissions,
  });

  final LinkedPatient patient;

  /// Doctor UID override for staff mode.
  final String? doctorUid;

  /// Per-feature staff permissions. When set, access is further restricted
  /// to the intersection of doctor link permissions and staff permissions.
  final StaffPermissions? staffPermissions;

  @override
  State<PatientDetailScreen> createState() => _PatientDetailScreenState();
}

class _PatientDetailScreenState extends State<PatientDetailScreen> {
  bool _permissionsLoaded = false;
  String? _orgId;

  @override
  void initState() {
    super.initState();
    _loadPermissions();
    _loadOrgId();
  }

  Future<void> _loadOrgId() async {
    final uid = widget.doctorUid ?? FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;
    try {
      final userDoc =
          await FirebaseFirestore.instance.collection('users').doc(uid).get();
      final data = userDoc.data() ?? {};
      final orgId = data['orgId'] as String?;
      if (orgId != null && orgId.isNotEmpty && mounted) {
        setState(() => _orgId = orgId);
      }
    } catch (_) {
      // Best effort — orgId is optional.
    }
  }

  Future<void> _loadPermissions() async {
    final currentUid = FirebaseAuth.instance.currentUser?.uid;
    final doctorUid = widget.doctorUid ?? currentUid;
    if (doctorUid == null) return;

    try {
      // Verify that a link doc exists (validates the doctor-patient link).
      final linkLookupUid = widget.patient.linkedDoctorUid ?? doctorUid;
      await FirebaseFirestore.instance
          .doc('${FirestorePaths.linksCollection(widget.patient.uid)}/${linkLookupUid}_doctor')
          .get();
      if (!mounted) return;

      setState(() {
        _permissionsLoaded = true;
      });
    } catch (_) {
      if (mounted) {
        setState(() {
          _permissionsLoaded = true;
        });
      }
    }
  }

  LinkedPatient get patient => widget.patient;

  String _phaseLabel(PatientPhase phase) {
    final l = AppLocalizations.of(context)!;
    return switch (phase) {
        PatientPhase.preOp => l.praeOp,
        PatientPhase.opDay => l.timelinePhaseOpday,
        PatientPhase.postOp => l.phasePostOp,
        PatientPhase.discharged => l.phaseEntlassen,
      };
  }

  @override
  Widget build(BuildContext context) {
    if (!_permissionsLoaded) {
      return Scaffold(
        backgroundColor: AppColors.background,
        body: AppBackground(
            child: const Center(child: CircularProgressIndicator())),
      );
    }

    final l = AppLocalizations.of(context)!;
    final currentUid = FirebaseAuth.instance.currentUser?.uid;
    final doctorUid = widget.doctorUid ?? currentUid;
    final isDoctor = currentUid == doctorUid;

    return Scaffold(
      backgroundColor: Colors.transparent,
      floatingActionButton: _PatientFabMenu(
        onAppointment: () => _showCreateAppointment(context),
        onAftercarePlan: () => _openAssignPlan(context),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.startFloat,
      body: AppBackground(
        child: Column(
          children: [
            _PatientGlassHeader(
              name: patient.displayName,
              phaseLabel: _phaseLabel(patient.phase),
              ageLabel: patient.age != null ? '${patient.age} Jahre' : null,
              onBack: () => Navigator.of(context).pop(),
              trailing: PopupMenuButton<String>(
                onSelected: (value) async {
                  if (value == 'unlink') {
                    final confirm = await showDialog<bool>(
                      context: context,
                      builder: (ctx) => AlertDialog(
                        title: Text(l.disconnectConfirm),
                        content: Text(
                          l.disconnectConfirmBody(patient.displayName),
                        ),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(ctx, false),
                            child: Text(l.cancel),
                          ),
                          FilledButton(
                            onPressed: () => Navigator.pop(ctx, true),
                            child: Text(l.disconnect),
                          ),
                        ],
                      ),
                    );
                    if (confirm == true && context.mounted) {
                      try {
                        await DoctorPatientRepository(
                          overrideDoctorUid: widget.doctorUid,
                        ).unlinkPatient(patient.uid);
                      } catch (e) {
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text(userFacingError(e))),
                          );
                        }
                        return;
                      }
                      if (context.mounted) Navigator.pop(context);
                    }
                  }
                },
                itemBuilder: (_) => [
                  PopupMenuItem(
                    value: 'unlink',
                    child: Row(
                      children: [
                        const Icon(Icons.link_off, color: AppColors.error),
                        const SizedBox(width: 8),
                        Text(l.verbindungTrennen),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            Expanded(
              child: PatientAftercarePlanTab(
                patientId: patient.uid,
                doctorUid: widget.doctorUid,
                organizationId: _orgId,
                isDoctor: isDoctor,
                isStaff: !isDoctor,
                patientDisplayName: patient.displayName,
                patientAge: patient.age,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _openAssignPlan(BuildContext context) {
    final currentUid = FirebaseAuth.instance.currentUser?.uid;
    final doctorUid = widget.doctorUid ?? currentUid;
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => AssignPlanScreen(
          templateService: AftercareTemplateService(
            overrideDoctorUid: doctorUid,
          ),
          planService: PatientAftercarePlanService(
            overrideDoctorUid: doctorUid,
          ),
          doctorUid: doctorUid,
          organizationId: _orgId,
          preselectedPatient: LinkedPatient(
            uid: patient.uid,
            displayName: patient.displayName,
          ),
        ),
      ),
    );
  }

  void _showCreateAppointment(BuildContext context) {
    final repo = DoctorPatientRepository(
      overrideDoctorUid: widget.doctorUid,
    );
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.background,
      shape: const RoundedRectangleBorder(
        borderRadius:
            BorderRadius.vertical(top: Radius.circular(AppRadius.xl)),
      ),
      builder: (_) => _QuickAppointmentSheet(
        patient: patient,
        repository: repo,
      ),
    );
  }
}

// Quick appointment creation sheet

class _QuickAppointmentSheet extends StatefulWidget {
  const _QuickAppointmentSheet({
    required this.patient,
    required this.repository,
  });

  final LinkedPatient patient;
  final DoctorPatientRepository repository;

  @override
  State<_QuickAppointmentSheet> createState() =>
      _QuickAppointmentSheetState();
}

class _QuickAppointmentSheetState extends State<_QuickAppointmentSheet> {
  final _titleController = TextEditingController();
  final _notesController = TextEditingController();
  DateTime _startAt = DateTime.now().add(const Duration(hours: 1));
  AppointmentType _type = AppointmentType.followUp;
  bool _busy = false;

  @override
  void dispose() {
    _titleController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _create() async {
    final title = _titleController.text.trim();
    if (title.isEmpty) return;

    setState(() => _busy = true);
    try {
      final now = DateTime.now();
      final doctorUid = FirebaseAuth.instance.currentUser?.uid;
      final doctorName = await widget.repository.getDoctorDisplayName();
      final appointment = Appointment(
        id: 'appt_${now.millisecondsSinceEpoch}',
        ownerId: widget.patient.uid,
        title: title,
        notes: _notesController.text.trim(),
        type: _type,
        status: AppointmentStatus.pending,
        startAt: _startAt,
        allDay: false,
        reminderPreset: ReminderPreset.hour1,
        repeatRule: RepeatRule.none,
        createdAt: now,
        updatedAt: now,
        createdBy: doctorUid,
        doctorName: doctorName.isNotEmpty ? doctorName : null,
      );
      await widget.repository
          .createAppointmentForPatient(widget.patient.uid, appointment);
      await widget.repository.notifyPatientNewAppointment(
        patientId: widget.patient.uid,
        title: title,
        startAt: _startAt,
        doctorName: doctorName,
      );
      if (mounted) Navigator.pop(context);
    } catch (_) {
      if (mounted) {
        final l = AppLocalizations.of(context)!;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l.appointmentCreateError)),
        );
      }
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    return SafeArea(
      child: Padding(
        padding: EdgeInsets.only(
          left: AppSpacing.xl,
          right: AppSpacing.xl,
          top: AppSpacing.lg,
          bottom: MediaQuery.of(context).viewInsets.bottom + AppSpacing.lg,
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
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
              const SizedBox(height: AppSpacing.lg),
              Text(
                l.terminFuerPatient(widget.patient.displayName),
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: AppSpacing.lg),
              TextField(
                controller: _titleController,
                decoration: InputDecoration(labelText: l.labelTitle),
              ),
              const SizedBox(height: AppSpacing.md),
              TextField(
                controller: _notesController,
                decoration: InputDecoration(labelText: l.pdTabNotes),
                maxLines: 2,
              ),
              const SizedBox(height: AppSpacing.md),
              DropdownButtonFormField<AppointmentType>(
                initialValue: _type,
                items: AppointmentType.values
                    .map((t) => DropdownMenuItem(
                          value: t,
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(t.icon, size: 18, color: t.color),
                              const SizedBox(width: 8),
                              Text(t.label),
                            ],
                          ),
                        ))
                    .toList(growable: false),
                onChanged: (v) {
                  if (v != null) setState(() => _type = v);
                },
                decoration: InputDecoration(labelText: l.labelType),
              ),
              const SizedBox(height: AppSpacing.md),
              Builder(
                builder: (ctx) => OutlinedButton.icon(
                  onPressed: () async {
                    final date = await showDatePicker(
                      context: ctx,
                      initialDate: _startAt,
                      firstDate:
                          DateTime.now().subtract(const Duration(days: 30)),
                      lastDate:
                          DateTime.now().add(const Duration(days: 365)),
                    );
                    if (date == null || !ctx.mounted) return;
                    final time = await showTimePicker(
                      context: ctx,
                      initialTime: TimeOfDay.fromDateTime(_startAt),
                    );
                    if (time == null || !ctx.mounted) return;
                    setState(() {
                      _startAt = DateTime(date.year, date.month, date.day,
                          time.hour, time.minute);
                    });
                  },
                  icon: const Icon(Icons.calendar_today),
                  label: Text(
                    '${_startAt.day}.${_startAt.month}.${_startAt.year}  '
                    '${_startAt.hour.toString().padLeft(2, '0')}:'
                    '${_startAt.minute.toString().padLeft(2, '0')}',
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.xl),
              FilledButton(
                onPressed: _busy ? null : _create,
                child: Text(_busy ? l.erstelle : l.appointmentCreate),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// FAB with speed-dial menu

class _PatientFabMenu extends StatelessWidget {
  const _PatientFabMenu({
    required this.onAppointment,
    required this.onAftercarePlan,
  });

  final VoidCallback onAppointment;
  final VoidCallback onAftercarePlan;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    return PopupMenuButton<String>(
      onSelected: (value) {
        switch (value) {
          case 'appointment':
            onAppointment();
          case 'aftercare':
            onAftercarePlan();
        }
      },
      offset: const Offset(0, -120),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadius.lg),
      ),
      itemBuilder: (_) => [
        PopupMenuItem(
          value: 'appointment',
          child: Row(
            children: [
              Icon(Icons.event_rounded, color: AppColors.primary),
              SizedBox(width: 12),
              Text(l.appointmentCreate),
            ],
          ),
        ),
        PopupMenuItem(
          value: 'aftercare',
          child: Row(
            children: [
              Icon(Icons.assignment_add, color: AppColors.accent),
              SizedBox(width: 12),
              Text('Plan zuweisen'),
            ],
          ),
        ),
      ],
      child: FloatingActionButton.small(
        heroTag: 'patient_detail_fab',
        onPressed: null,
        backgroundColor: AppColors.primary,
        child: const Icon(Icons.add_rounded, color: AppColors.white),
      ),
    );
  }
}

// Frosted-glass header matching GlassPage style

class _PatientGlassHeader extends StatelessWidget {
  const _PatientGlassHeader({
    required this.name,
    required this.phaseLabel,
    this.ageLabel,
    required this.onBack,
    this.trailing,
  });

  final String name;
  final String phaseLabel;
  final String? ageLabel;
  final VoidCallback onBack;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    final topPadding = MediaQuery.of(context).padding.top;
    final tt = Theme.of(context).textTheme;

    return ClipRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 28, sigmaY: 28),
        child: Container(
          padding: EdgeInsets.only(top: topPadding),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                AppColors.background.withValues(alpha: 0.92),
                AppColors.background.withValues(alpha: 0.78),
              ],
            ),
            border: Border(
              bottom: BorderSide(
                color: AppColors.white.withValues(alpha: 0.45),
                width: 0.5,
              ),
            ),
            boxShadow: [
              BoxShadow(
                color: AppColors.black.withValues(alpha: 0.04),
                blurRadius: 12,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: SizedBox(
            height: 56,
            child: Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
              child: Row(
                children: [
                  // Back button
                  PressableScale(
                    onTap: () {
                      Haptic.light();
                      onBack();
                    },
                    scaleFactor: 0.90,
                    child: Container(
                      width: 38,
                      height: 38,
                      decoration: BoxDecoration(
                        color: AppColors.white.withValues(alpha: 0.65),
                        borderRadius: AppRadius.borderRadiusMd,
                        border: Border.all(
                          color:
                              AppColors.white.withValues(alpha: 0.80),
                          width: 0.5,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.black
                                .withValues(alpha: 0.06),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.arrow_back_ios_new_rounded,
                        size: 16,
                        color: AppColors.primary,
                      ),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.md),

                  // Name + meta
                  Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          name,
                          style: tt.titleLarge?.copyWith(
                            fontWeight: FontWeight.w700,
                            fontSize: 18,
                            letterSpacing: -0.3,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 2),
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 6, vertical: 1),
                              decoration: BoxDecoration(
                                color: AppColors.primary
                                    .withValues(alpha: 0.1),
                                borderRadius:
                                    AppRadius.borderRadiusPill,
                              ),
                              child: Text(
                                phaseLabel,
                                style: const TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.primary,
                                ),
                              ),
                            ),
                            if (ageLabel != null) ...[
                              const SizedBox(width: 8),
                              Text(
                                ageLabel!,
                                style: const TextStyle(
                                  fontSize: 11,
                                  color: AppColors.textSecondary,
                                ),
                              ),
                            ],
                          ],
                        ),
                      ],
                    ),
                  ),

                  ?trailing,
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
