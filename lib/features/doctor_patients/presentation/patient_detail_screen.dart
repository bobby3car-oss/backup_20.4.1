import 'dart:ui';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../../../l10n/app_localizations.dart';

import '../../../domain/timeline_engine.dart';
import '../../../features/appointments/domain/appointment.dart';
import '../../../features/appointments/domain/appointment_enums.dart';
import '../../../features/doctor_report/doctor_report_builder.dart';
import '../../../features/doctor_templates/data/doctor_template_repository.dart';
import '../../../features/doctor_templates/data/system_template_repository.dart';
import '../../../features/doctor_templates/domain/care_plan_template.dart';
import '../../../features/doctor_notes/presentation/doctor_notes_tab.dart';
import '../../../firebase/firebase_paths.dart';
import '../../../ui/ui.dart';
import '../data/doctor_patient_repository.dart';
import '../domain/doctor_permissions.dart';
import '../domain/linked_patient.dart';
import 'tabs/patient_documents_tab.dart';
import 'tabs/doctor_medication_tab.dart';
import 'tabs/patient_pain_tab.dart';
import 'tabs/patient_report_tab.dart';
import 'tabs/patient_red_flags_tab.dart';
import 'tabs/patient_questions_tab.dart';
import 'tabs/patient_wounds_tab.dart';

/// Detail screen for a single patient, showing feature tabs based on
/// the doctor's per-feature permissions.
class PatientDetailScreen extends StatefulWidget {
  const PatientDetailScreen({
    super.key,
    required this.patient,
  });

  final LinkedPatient patient;

  @override
  State<PatientDetailScreen> createState() => _PatientDetailScreenState();
}

class _PatientDetailScreenState extends State<PatientDetailScreen> {
  DoctorPermissions _permissions = DoctorPermissions.noAccess;
  bool _permissionsLoaded = false;

  @override
  void initState() {
    super.initState();
    _loadPermissions();
  }

  Future<void> _loadPermissions() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;

    try {
      final linkDoc = await FirebaseFirestore.instance
          .doc('${FirestorePaths.linksCollection(widget.patient.uid)}/${uid}_doctor')
          .get();
      if (!mounted) return;

      final data = linkDoc.data();
      final rawPerms = data?['featurePermissions'] as Map<String, dynamic>?;
      setState(() {
        _permissions = DoctorPermissions.fromMap(rawPerms);
        _permissionsLoaded = true;
      });
    } catch (_) {
      // On error, deny access (fail-secure).
      if (mounted) {
        setState(() {
          _permissions = DoctorPermissions.noAccess;
          _permissionsLoaded = true;
        });
      }
    }
  }

  LinkedPatient get patient => widget.patient;

  Color _ampelColor(ReportLight status) => switch (status) {
        ReportLight.green => AppColors.success,
        ReportLight.yellow => AppColors.warning,
        ReportLight.red => AppColors.error,
        ReportLight.unknown => AppColors.grey400,
      };

  String _phaseLabel(PatientPhase phase) => switch (phase) {
        PatientPhase.preOp => 'Prä-OP',
        PatientPhase.opDay => 'OP-Tag',
        PatientPhase.postOp => 'Post-OP',
        PatientPhase.discharged => 'Entlassen',
      };

  String _formatDate(DateTime? dt) {
    if (dt == null) return '–';
    return '${dt.day}.${dt.month}.${dt.year}';
  }

  @override
  Widget build(BuildContext context) {
    if (!_permissionsLoaded) {
      return Scaffold(
        backgroundColor: AppColors.background,
        body: AppBackground(child: const Center(child: CircularProgressIndicator())),
      );
    }

    final l = AppLocalizations.of(context)!;
    final ampel = _ampelColor(patient.warnStatus);

    // Build tabs based on permissions
    final tabs = <Tab>[];
    final tabViews = <Widget>[];

    // Report tab always shown (summary)
    tabs.add(const Tab(
      icon: Icon(Icons.summarize_rounded, size: 20),
      text: 'Report',
    ));
    tabViews.add(PatientReportTab(patient: patient));

    // Red Flags
    if (_permissions.redFlags.canRead) {
      tabs.add(const Tab(
        icon: Icon(Icons.warning_amber_rounded, size: 20),
        text: 'Red Flags',
      ));
      tabViews.add(PatientRedFlagsTab(patientId: patient.uid));
    }

    // Wounds
    if (_permissions.wounds.canRead) {
      tabs.add(const Tab(
        icon: Icon(Icons.healing_rounded, size: 20),
        text: 'Wunde',
      ));
      tabViews.add(PatientWoundsTab(patientId: patient.uid));
    }

    // Pain
    if (_permissions.pain.canRead) {
      tabs.add(const Tab(
        icon: Icon(Icons.speed_rounded, size: 20),
        text: 'Schmerz',
      ));
      tabViews.add(PatientPainTab(patientId: patient.uid));
    }

    // Documents
    if (_permissions.documents.canRead) {
      tabs.add(const Tab(
        icon: Icon(Icons.folder_rounded, size: 20),
        text: 'Dokumente',
      ));
      tabViews.add(PatientDocumentsTab(
        patientId: patient.uid,
        canWrite: _permissions.documents.canWrite,
      ));
    }

    // Medications
    if (_permissions.medications.canRead) {
      tabs.add(const Tab(
        icon: Icon(Icons.medication_rounded, size: 20),
        text: 'Medikamente',
      ));
      tabViews.add(DoctorMedicationTab(patientId: patient.uid));
    }

    // Patient questions
    tabs.add(const Tab(
      icon: Icon(Icons.quiz_rounded, size: 20),
      text: 'Fragen',
    ));
    tabViews.add(PatientQuestionsTab(patientId: patient.uid));

    // Doctor notes (always shown — private to doctor)
    tabs.add(const Tab(
      icon: Icon(Icons.note_alt_rounded, size: 20),
      text: 'Notizen',
    ));
    tabViews.add(DoctorNotesTab(patientId: patient.uid));

    return DefaultTabController(
      length: tabs.length,
      child: Scaffold(
        backgroundColor: Colors.transparent,
        floatingActionButton: _PatientFabMenu(
          onAppointment: () => _showCreateAppointment(context),
          onTask: () => _showCreateTask(context),
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.startFloat,
        body: AppBackground(
          child: Column(
            children: [
              // ── Frosted glass header ─────────────────────────
              _PatientGlassHeader(
                name: patient.displayName,
                ampelColor: ampel,
                phaseLabel: _phaseLabel(patient.phase),
                opDateLabel: 'OP: ${_formatDate(patient.opDate)}',
                progress: patient.progressPercent,
                tabs: tabs,
                onBack: () => Navigator.of(context).pop(),
                trailing: PopupMenuButton<String>(
                  onSelected: (value) async {
                    if (value == 'unlink') {
                      final confirm = await showDialog<bool>(
                        context: context,
                        builder: (ctx) => AlertDialog(
                          title: Text(l.disconnectConfirm),
                          content: Text(
                            'Möchten Sie die Verbindung zu ${patient.displayName} wirklich trennen?',
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
                          await DoctorPatientRepository()
                              .unlinkPatient(patient.uid);
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
                    } else if (value == 'template') {
                      _showApplyTemplate(context);
                    } else if (value == 'save_template') {
                      _showSaveAsTemplate(context);
                    }
                  },
                  itemBuilder: (_) => [
                    PopupMenuItem(
                      value: 'template',
                      child: Row(
                        children: [
                          Icon(Icons.playlist_add_rounded,
                              color: AppColors.primary),
                          SizedBox(width: 8),
                          Text(l.templateApply),
                        ],
                      ),
                    ),
                    PopupMenuItem(
                      value: 'save_template',
                      child: Row(
                        children: [
                          Icon(Icons.save_alt_rounded,
                              color: AppColors.accent),
                          SizedBox(width: 8),
                          Text(l.templateFromTasks),
                        ],
                      ),
                    ),
                    const PopupMenuItem(
                      value: 'unlink',
                      child: Row(
                        children: [
                          Icon(Icons.link_off, color: AppColors.error),
                          SizedBox(width: 8),
                          Text('Verbindung trennen'),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              // ── Tab body ────────────────────────────────────
              Expanded(
                child: TabBarView(
                  children: tabViews,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showCreateAppointment(BuildContext context) {
    final repo = DoctorPatientRepository();
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

  void _showCreateTask(BuildContext context) {
    final repo = DoctorPatientRepository();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.background,
      shape: const RoundedRectangleBorder(
        borderRadius:
            BorderRadius.vertical(top: Radius.circular(AppRadius.xl)),
      ),
      builder: (_) => _QuickTaskSheet(
        patient: patient,
        repository: repo,
      ),
    );
  }

  void _showApplyTemplate(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.background,
      shape: const RoundedRectangleBorder(
        borderRadius:
            BorderRadius.vertical(top: Radius.circular(AppRadius.xl)),
      ),
      builder: (_) => _ApplyTemplateSheet(patient: patient),
    );
  }

  void _showSaveAsTemplate(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.background,
      shape: const RoundedRectangleBorder(
        borderRadius:
            BorderRadius.vertical(top: Radius.circular(AppRadius.xl)),
      ),
      builder: (_) => _SaveAsTemplateSheet(patientId: patient.uid),
    );
  }
}

/// Simplified appointment creation sheet for a specific patient.
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
      final doctorName =
          await widget.repository.getDoctorDisplayName();
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
      // Send push notification to patient via Cloud Function.
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
          SnackBar(
              content: Text(l.appointmentCreateError)),
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
                'Termin für ${widget.patient.displayName}',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: AppSpacing.lg),

              TextField(
                controller: _titleController,
                decoration: const InputDecoration(labelText: 'Titel'),
              ),
              const SizedBox(height: AppSpacing.md),

              TextField(
                controller: _notesController,
                decoration: const InputDecoration(labelText: 'Notizen'),
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
                decoration: const InputDecoration(labelText: 'Typ'),
              ),
              const SizedBox(height: AppSpacing.md),

              Builder(
                builder: (ctx) => OutlinedButton.icon(
                  onPressed: () async {
                    final date = await showDatePicker(
                      context: ctx,
                      initialDate: _startAt,
                      firstDate: DateTime.now()
                          .subtract(const Duration(days: 30)),
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
                child:
                    Text(_busy ? 'Erstelle...' : l.appointmentCreate),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── FAB with speed-dial menu ─────────────────────────────────────────────────

class _PatientFabMenu extends StatelessWidget {
  const _PatientFabMenu({
    required this.onAppointment,
    required this.onTask,
  });

  final VoidCallback onAppointment;
  final VoidCallback onTask;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    return PopupMenuButton<String>(
      onSelected: (value) {
        switch (value) {
          case 'appointment':
            onAppointment();
          case 'task':
            onTask();
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
          value: 'task',
          child: Row(
            children: [
              Icon(Icons.task_alt_rounded, color: AppColors.success),
              SizedBox(width: 12),
              Text(l.taskAssign),
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

// ── Quick task creation sheet ────────────────────────────────────────────────

class _QuickTaskSheet extends StatefulWidget {
  const _QuickTaskSheet({
    required this.patient,
    required this.repository,
  });

  final LinkedPatient patient;
  final DoctorPatientRepository repository;

  @override
  State<_QuickTaskSheet> createState() => _QuickTaskSheetState();
}

class _QuickTaskSheetState extends State<_QuickTaskSheet> {
  final _titleCtrl = TextEditingController();
  final _subtitleCtrl = TextEditingController();
  TaskType _type = TaskType.checklist;
  TaskPriority _priority = TaskPriority.normal;
  DateTime _scheduledAt = DateTime.now();
  bool _busy = false;

  @override
  void dispose() {
    _titleCtrl.dispose();
    _subtitleCtrl.dispose();
    super.dispose();
  }

  Future<void> _create() async {
    final title = _titleCtrl.text.trim();
    if (title.isEmpty) return;

    setState(() => _busy = true);
    try {
      final now = DateTime.now();
      final task = TimelineItem(
        id: 'doc_task_${now.millisecondsSinceEpoch}',
        type: _type,
        title: title,
        subtitle: _subtitleCtrl.text.trim(),
        scheduledAt: _scheduledAt,
        dueAt: _scheduledAt.add(const Duration(hours: 24)),
        priority: _priority,
        state: TaskState.planned,
        deeplinkRoute: '',
        metadata: const <String, dynamic>{
          'assignedByDoctor': true,
        },
        createdAt: now,
        updatedAt: now,
      );
      await widget.repository.addTaskForPatient(widget.patient.uid, task);
      if (mounted) Navigator.pop(context);
    } catch (_) {
      if (mounted) {
        final l = AppLocalizations.of(context)!;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text(l.taskCreateError)),
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
                'Aufgabe für ${widget.patient.displayName}',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: AppSpacing.lg),

              TextField(
                controller: _titleCtrl,
                decoration: const InputDecoration(labelText: 'Titel'),
              ),
              const SizedBox(height: AppSpacing.md),
              TextField(
                controller: _subtitleCtrl,
                decoration:
                    InputDecoration(labelText: 'Beschreibung (optional)'),
                maxLines: 2,
              ),
              SizedBox(height: AppSpacing.md),

              DropdownButtonFormField<TaskType>(
                initialValue: _type,
                items: [
                  DropdownMenuItem(
                      value: TaskType.checklist, child: Text(l.checklists)),
                  DropdownMenuItem(
                      value: TaskType.wound, child: Text(l.woundDoc)),
                  DropdownMenuItem(
                      value: TaskType.meds, child: Text(l.medication)),
                  DropdownMenuItem(
                      value: TaskType.custom, child: Text('Sonstige')),
                ],
                onChanged: (v) {
                  if (v != null) setState(() => _type = v);
                },
                decoration: InputDecoration(labelText: 'Typ'),
              ),
              SizedBox(height: AppSpacing.md),

              DropdownButtonFormField<TaskPriority>(
                initialValue: _priority,
                items: [
                  DropdownMenuItem(
                      value: TaskPriority.low, child: Text(l.low)),
                  DropdownMenuItem(
                      value: TaskPriority.normal, child: Text(l.normal)),
                  DropdownMenuItem(
                      value: TaskPriority.high, child: Text(l.high)),
                  DropdownMenuItem(
                      value: TaskPriority.critical, child: Text(l.critical)),
                ],
                onChanged: (v) {
                  if (v != null) setState(() => _priority = v);
                },
                decoration: const InputDecoration(labelText: 'Priorität'),
              ),
              const SizedBox(height: AppSpacing.md),

              Builder(
                builder: (ctx) => OutlinedButton.icon(
                  onPressed: () async {
                    final date = await showDatePicker(
                      context: ctx,
                      initialDate: _scheduledAt,
                      firstDate:
                          DateTime.now().subtract(const Duration(days: 1)),
                      lastDate:
                          DateTime.now().add(const Duration(days: 365)),
                    );
                    if (date == null || !ctx.mounted) return;
                    final time = await showTimePicker(
                      context: ctx,
                      initialTime: TimeOfDay.fromDateTime(_scheduledAt),
                    );
                    if (time == null || !ctx.mounted) return;
                    setState(() {
                      _scheduledAt = DateTime(date.year, date.month,
                          date.day, time.hour, time.minute);
                    });
                  },
                  icon: const Icon(Icons.calendar_today),
                  label: Text(
                    '${_scheduledAt.day}.${_scheduledAt.month}.${_scheduledAt.year}  '
                    '${_scheduledAt.hour.toString().padLeft(2, '0')}:'
                    '${_scheduledAt.minute.toString().padLeft(2, '0')}',
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.xl),

              FilledButton(
                onPressed: _busy ? null : _create,
                child: Text(
                    _busy ? 'Erstelle...' : l.taskAssign),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Apply template sheet ────────────────────────────────────────────────────

class _ApplyTemplateSheet extends StatefulWidget {
  const _ApplyTemplateSheet({required this.patient});

  final LinkedPatient patient;

  @override
  State<_ApplyTemplateSheet> createState() => _ApplyTemplateSheetState();
}

class _ApplyTemplateSheetState extends State<_ApplyTemplateSheet> {
  final _templateRepo = DoctorTemplateRepository();
  final _systemRepo = SystemTemplateRepository();
  final _patientRepo = DoctorPatientRepository();
  bool _applying = false;

  // Step tracking: 1=select template, 2=select tasks, 3=date+apply
  int _step = 1;
  CarePlanTemplate? _selectedTemplate;
  late Set<int> _selectedTaskIndices;
  late DateTime _startDate;

  @override
  void initState() {
    super.initState();
    _startDate = DateTime.now();
    _selectedTaskIndices = {};
  }

  void _selectTemplate(CarePlanTemplate t) {
    setState(() {
      _selectedTemplate = t;
      _selectedTaskIndices = Set<int>.from(
        List.generate(t.tasks.length, (i) => i),
      );
      _step = 2;
    });
  }

  Future<void> _apply() async {
    final template = _selectedTemplate;
    if (template == null) return;
    setState(() => _applying = true);
    try {
      final count = await _patientRepo.applyTemplate(
        patientId: widget.patient.uid,
        template: template,
        startDate: _startDate,
        selectedTaskIndices: _selectedTaskIndices,
      );
      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
                '${template.name}: $count Aufgabe${count == 1 ? '' : 'n'} zugewiesen'),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(userFacingError(e))),
        );
      }
    } finally {
      if (mounted) setState(() => _applying = false);
    }
  }

  Future<void> _pickStartDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _startDate,
      firstDate: DateTime.now().subtract(const Duration(days: 30)),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      helpText: 'Startdatum wählen (z.B. OP-Datum)',
    );
    if (picked != null) {
      setState(() => _startDate = picked);
    }
  }

  String _formatDate(DateTime d) =>
      '${d.day.toString().padLeft(2, '0')}.${d.month.toString().padLeft(2, '0')}.${d.year}';

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: switch (_step) {
          1 => _buildStep1(context),
          2 => _buildStep2(context),
          _ => _buildStep3(context),
        },
      ),
    );
  }

  // ── Step 1: Template selection ─────────────────────────────────
  Widget _buildStep1(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    return Column(
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
          l.templateApply,
          style: Theme.of(context).textTheme.titleLarge,
        ),
        const SizedBox(height: AppSpacing.sm),
        Text(
          'Wählen Sie eine Vorlage für ${widget.patient.displayName}:',
          style: const TextStyle(color: AppColors.textSecondary),
        ),
        const SizedBox(height: AppSpacing.lg),

        // Own templates
        StreamBuilder<List<CarePlanTemplate>>(
          stream: _templateRepo.watchAll(),
          builder: (context, snap) {
            final l = AppLocalizations.of(context)!;
            final templates = snap.data ?? [];
            if (snap.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (templates.isNotEmpty) ...[
                  Text(l.templateOwnTemplates,
                    style: Theme.of(context).textTheme.labelLarge?.copyWith(
                      color: AppColors.textSecondary,
                    )),
                  const SizedBox(height: AppSpacing.sm),
                  for (final t in templates) ...[
                    _TemplateListTile(
                      template: t,
                      onTap: () => _selectTemplate(t),
                    ),
                    const Divider(height: 1),
                  ],
                  const SizedBox(height: AppSpacing.lg),
                ],
              ],
            );
          },
        ),

        // System templates
        StreamBuilder<List<CarePlanTemplate>>(
          stream: _systemRepo.watchAll(),
          builder: (context, snap) {
            final l = AppLocalizations.of(context)!;
            final templates = snap.data ?? [];
            if (templates.isEmpty) return const SizedBox.shrink();
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(l.systemTemplates,
                  style: Theme.of(context).textTheme.labelLarge?.copyWith(
                    color: AppColors.textSecondary,
                  )),
                const SizedBox(height: AppSpacing.sm),
                for (final t in templates) ...[
                  _TemplateListTile(
                    template: t,
                    onTap: () => _selectTemplate(t),
                    isSystem: true,
                  ),
                  const Divider(height: 1),
                ],
              ],
            );
          },
        ),
      ],
    );
  }

  // ── Step 2: Select tasks via checkboxes ────────────────────────
  Widget _buildStep2(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final template = _selectedTemplate!;
    final allSelected = _selectedTaskIndices.length == template.tasks.length;
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            IconButton(
              onPressed: () => setState(() { _step = 1; _selectedTemplate = null; }),
              icon: const Icon(Icons.arrow_back_rounded),
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(),
            ),
            const SizedBox(width: AppSpacing.sm),
            Expanded(
              child: Text(template.name, style: Theme.of(context).textTheme.titleLarge),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.sm),
        Text(l.tasksSelectToApply,
          style: TextStyle(color: AppColors.textSecondary, fontSize: 13)),
        const SizedBox(height: AppSpacing.sm),

        // Select all toggle
        InkWell(
          onTap: () {
            setState(() {
              if (allSelected) {
                _selectedTaskIndices.clear();
              } else {
                _selectedTaskIndices = Set<int>.from(
                  List.generate(template.tasks.length, (i) => i),
                );
              }
            });
          },
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: AppSpacing.xs),
            child: Row(
              children: [
                Icon(allSelected ? Icons.check_box_rounded : Icons.check_box_outline_blank_rounded,
                  color: AppColors.primary),
                const SizedBox(width: AppSpacing.sm),
                Text(allSelected ? 'Alle abwählen' : 'Alle auswählen',
                  style: const TextStyle(fontWeight: FontWeight.w600, color: AppColors.primary)),
              ],
            ),
          ),
        ),
        const Divider(),

        // Task checkboxes
        for (var i = 0; i < template.tasks.length; i++)
          CheckboxListTile(
            value: _selectedTaskIndices.contains(i),
            onChanged: (v) {
              setState(() {
                if (v == true) {
                  _selectedTaskIndices.add(i);
                } else {
                  _selectedTaskIndices.remove(i);
                }
              });
            },
            title: Text(template.tasks[i].title,
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
            subtitle: Text(
              'Tag ${template.tasks[i].relativeDayOffset >= 0 ? '+' : ''}${template.tasks[i].relativeDayOffset}'
              '${template.tasks[i].timeOfDay != null ? ' · ${template.tasks[i].timeOfDay!.label}' : ''}',
              style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
            ),
            dense: true,
            contentPadding: EdgeInsets.zero,
            controlAffinity: ListTileControlAffinity.leading,
          ),

        const SizedBox(height: AppSpacing.lg),
        FilledButton(
          onPressed: _selectedTaskIndices.isNotEmpty
              ? () => setState(() => _step = 3)
              : null,
          child: Text('${_selectedTaskIndices.length} Aufgabe${_selectedTaskIndices.length == 1 ? '' : 'n'} weiter'),
        ),
      ],
    );
  }

  // ── Step 3: Date picker + Preview + Apply ──────────────────────
  Widget _buildStep3(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final template = _selectedTemplate!;
    final selectedTasks = [
      for (var i = 0; i < template.tasks.length; i++)
        if (_selectedTaskIndices.contains(i)) template.tasks[i],
    ];
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            IconButton(
              onPressed: () => setState(() => _step = 2),
              icon: const Icon(Icons.arrow_back_rounded),
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(),
            ),
            const SizedBox(width: AppSpacing.sm),
            Expanded(
              child: Text(template.name, style: Theme.of(context).textTheme.titleLarge),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.lg),

        // Date picker row
        InkWell(
          onTap: _pickStartDate,
          borderRadius: BorderRadius.circular(AppRadius.md),
          child: Container(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.lg,
              vertical: AppSpacing.md,
            ),
            decoration: BoxDecoration(
              border: Border.all(color: AppColors.primary.withValues(alpha: 0.4)),
              borderRadius: BorderRadius.circular(AppRadius.md),
            ),
            child: Row(
              children: [
                const Icon(Icons.calendar_today_rounded,
                    size: 20, color: AppColors.primary),
                const SizedBox(width: AppSpacing.md),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(l.startDateOpDate,
                      style: TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                    Text(_formatDate(_startDate),
                      style: const TextStyle(
                          fontSize: 16, fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
                  ],
                ),
                const Spacer(),
                const Icon(Icons.edit_calendar_rounded, size: 18, color: AppColors.primary),
              ],
            ),
          ),
        ),
        const SizedBox(height: AppSpacing.lg),

        // Task preview
        Text(
          '${selectedTasks.length} Aufgabe${selectedTasks.length == 1 ? '' : 'n'}:',
          style: Theme.of(context).textTheme.titleSmall,
        ),
        const SizedBox(height: AppSpacing.sm),
        for (final task in selectedTasks) ...[
          _TaskPreviewTile(task: task, startDate: _startDate),
          const SizedBox(height: AppSpacing.xs),
        ],

        const SizedBox(height: AppSpacing.xl),

        // Apply button
        FilledButton.icon(
          onPressed: _applying ? null : _apply,
          icon: _applying
              ? const SizedBox(
                  width: 18, height: 18,
                  child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                )
              : const Icon(Icons.check_rounded),
          label: Text(_applying ? 'Wird zugewiesen...' : l.templateApply),
          style: FilledButton.styleFrom(
            padding: const EdgeInsets.symmetric(vertical: 14),
          ),
        ),
      ],
    );
  }
}

class _TemplateListTile extends StatelessWidget {
  const _TemplateListTile({
    required this.template,
    required this.onTap,
    this.isSystem = false,
  });

  final CarePlanTemplate template;
  final VoidCallback onTap;
  final bool isSystem;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(
        isSystem ? Icons.library_books_rounded : Icons.playlist_add_check_rounded,
        color: isSystem ? AppColors.accent : AppColors.primary,
      ),
      title: Text(template.name),
      subtitle: Text(
        '${template.tasks.length} Aufgabe${template.tasks.length == 1 ? '' : 'n'}',
      ),
      trailing: const Icon(Icons.chevron_right_rounded),
      onTap: onTap,
    );
  }
}

class _TaskPreviewTile extends StatelessWidget {
  const _TaskPreviewTile({required this.task, required this.startDate});

  final TemplateTask task;
  final DateTime startDate;

  String _formatDate(DateTime d) =>
      '${d.day.toString().padLeft(2, '0')}.${d.month.toString().padLeft(2, '0')}.${d.year}';

  @override
  Widget build(BuildContext context) {
    final scheduled = startDate.add(Duration(days: task.relativeDayOffset));
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.sm,
      ),
      decoration: BoxDecoration(
        color: AppColors.textSecondary.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(AppRadius.sm),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(task.title,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600, fontSize: 14, color: AppColors.textPrimary)),
                Row(
                  children: [
                    Text('${_formatDate(scheduled)} · Tag +${task.relativeDayOffset}',
                      style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                    if (task.timeOfDay != null)
                      Text(' · ${task.timeOfDay!.label}',
                        style: const TextStyle(fontSize: 12, color: AppColors.accent)),
                  ],
                ),
                if (task.recurrence != null)
                  Text(
                    _recurrencePreviewLabel(task.recurrence!),
                    style: const TextStyle(fontSize: 11, color: AppColors.accent),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

String _recurrencePreviewLabel(TaskRecurrence r) => switch (r.type) {
      RecurrenceType.daily => 'Täglich, ${r.count}x',
      RecurrenceType.weekdays => 'Werktags, ${r.count}x',
      RecurrenceType.everyNDays => 'Alle ${r.intervalDays} Tage, ${r.count}x',
    };

// ── Save tasks as template ──────────────────────────────────────────────────

class _SaveAsTemplateSheet extends StatefulWidget {
  const _SaveAsTemplateSheet({required this.patientId});
  final String patientId;

  @override
  State<_SaveAsTemplateSheet> createState() => _SaveAsTemplateSheetState();
}

class _SaveAsTemplateSheetState extends State<_SaveAsTemplateSheet> {
  final _repo = DoctorPatientRepository();
  final _templateRepo = DoctorTemplateRepository();
  final _nameCtrl = TextEditingController();
  final _descCtrl = TextEditingController();
  final Set<int> _selected = {};
  List<TimelineItem>? _tasks;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _nameCtrl.addListener(() => setState(() {}));
    _loadTasks();
  }

  Future<void> _loadTasks() async {
    final snap = await _repo.watchPatientTasks(widget.patientId).first;
    if (mounted) setState(() => _tasks = snap);
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _descCtrl.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final name = _nameCtrl.text.trim();
    if (name.isEmpty || _selected.isEmpty || _tasks == null) return;
    setState(() => _saving = true);
    try {
      final now = DateTime.now();
      // Find earliest task date as base reference
      final selectedItems = [
        for (final i in _selected) _tasks![i],
      ];
      final earliest = selectedItems
          .map((t) => t.scheduledAt)
          .reduce((a, b) => a.isBefore(b) ? a : b);

      final templateTasks = selectedItems.map((item) {
        final dayOffset = item.scheduledAt.difference(earliest).inDays;
        return TemplateTask(
          title: item.title,
          subtitle: item.subtitle,
          type: item.type,
          priority: item.priority,
          relativeDayOffset: dayOffset,
          dueHours: item.dueAt != null
              ? item.dueAt!.difference(item.scheduledAt).inHours.clamp(1, 168)
              : 24,
        );
      }).toList();

      final template = CarePlanTemplate(
        id: 'tpl_${now.millisecondsSinceEpoch}',
        doctorUid: '',
        name: name,
        description: _descCtrl.text.trim(),
        tasks: templateTasks,
        createdAt: now,
        updatedAt: now,
      );
      await _templateRepo.upsert(template);
      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Vorlage "$name" erstellt')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(userFacingError(e))),
        );
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  String _formatDate(DateTime d) =>
      '${d.day.toString().padLeft(2, '0')}.${d.month.toString().padLeft(2, '0')}.${d.year}';

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
                  width: 36, height: 4,
                  decoration: BoxDecoration(
                    color: AppColors.grey400,
                    borderRadius: AppRadius.borderRadiusPill,
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.lg),
              Text(l.templateFromTasksCreate,
                style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: AppSpacing.lg),

              TextField(
                controller: _nameCtrl,
                decoration: const InputDecoration(labelText: 'Name der Vorlage'),
              ),
              const SizedBox(height: AppSpacing.md),
              TextField(
                controller: _descCtrl,
                decoration: const InputDecoration(labelText: 'Beschreibung (optional)'),
              ),
              const SizedBox(height: AppSpacing.lg),

              if (_tasks == null)
                const Center(child: CircularProgressIndicator())
              else if (_tasks!.isEmpty)
                Text(l.tasksNoneAssigned,
                  style: TextStyle(color: AppColors.textSecondary))
              else ...[
                Text('Aufgaben auswählen (${_selected.length}/${_tasks!.length}):',
                  style: Theme.of(context).textTheme.titleSmall),
                const SizedBox(height: AppSpacing.sm),
                for (var i = 0; i < _tasks!.length; i++)
                  CheckboxListTile(
                    value: _selected.contains(i),
                    onChanged: (v) {
                      setState(() {
                        if (v == true) {
                          _selected.add(i);
                        } else {
                          _selected.remove(i);
                        }
                      });
                    },
                    title: Text(_tasks![i].title,
                      style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
                    subtitle: Text(_formatDate(_tasks![i].scheduledAt),
                      style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                    dense: true,
                    contentPadding: EdgeInsets.zero,
                    controlAffinity: ListTileControlAffinity.leading,
                  ),
              ],

              const SizedBox(height: AppSpacing.xl),
              FilledButton(
                onPressed: _nameCtrl.text.trim().isNotEmpty && _selected.isNotEmpty && !_saving
                    ? _save
                    : null,
                child: Text(_saving ? 'Speichere...' : 'Vorlage erstellen'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Frosted-glass tab header matching GlassPage style
// ─────────────────────────────────────────────────────────────────────────────

class _PatientGlassHeader extends StatelessWidget {
  const _PatientGlassHeader({
    required this.name,
    required this.ampelColor,
    required this.phaseLabel,
    required this.opDateLabel,
    required this.progress,
    required this.tabs,
    required this.onBack,
    this.trailing,
  });

  final String name;
  final Color ampelColor;
  final String phaseLabel;
  final String opDateLabel;
  final double progress;
  final List<Tab> tabs;
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
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Title row
              SizedBox(
                height: 56,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
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
                              color: AppColors.white.withValues(alpha: 0.80),
                              width: 0.5,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: AppColors.black.withValues(alpha: 0.06),
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

                      // Status dot
                      Container(
                        width: 10,
                        height: 10,
                        decoration: BoxDecoration(
                          color: ampelColor,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: ampelColor.withValues(alpha: 0.4),
                              blurRadius: 6,
                              spreadRadius: 1,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),

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
                                    color: AppColors.primary.withValues(alpha: 0.1),
                                    borderRadius: AppRadius.borderRadiusPill,
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
                                const SizedBox(width: 8),
                                Text(
                                  opDateLabel,
                                  style: const TextStyle(
                                    fontSize: 11,
                                    color: AppColors.textSecondary,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: ClipRRect(
                                    borderRadius: AppRadius.borderRadiusPill,
                                    child: LinearProgressIndicator(
                                      value: progress,
                                      minHeight: 4,
                                      backgroundColor:
                                          AppColors.grey300.withValues(alpha: 0.5),
                                      valueColor: const AlwaysStoppedAnimation<Color>(
                                          AppColors.primary),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  '${(progress * 100).round()}%',
                                  style: const TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.textSecondary,
                                  ),
                                ),
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

              // Tab bar
              TabBar(
                isScrollable: true,
                tabs: tabs,
                labelColor: AppColors.primary,
                unselectedLabelColor: AppColors.textSecondary,
                indicatorColor: AppColors.primary,
                indicatorSize: TabBarIndicatorSize.label,
                dividerColor: Colors.transparent,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
