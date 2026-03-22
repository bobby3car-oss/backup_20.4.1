import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

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
      // On error, grant full access so the doctor isn't locked out.
      if (mounted) {
        setState(() {
          _permissions = const DoctorPermissions();
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
        appBar: AppBar(title: Text(patient.displayName)),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

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
        backgroundColor: AppColors.background,
        floatingActionButton: _PatientFabMenu(
          onAppointment: () => _showCreateAppointment(context),
          onTask: () => _showCreateTask(context),
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.startFloat,
        appBar: AppBar(
          elevation: 0,
          flexibleSpace: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  ampel.withValues(alpha: 0.15),
                  AppColors.background,
                ],
              ),
            ),
          ),
          title: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Flexible(
                    child: Text(
                      patient.displayName,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    width: 10,
                    height: 10,
                    decoration: BoxDecoration(
                      color: ampel,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: ampel.withValues(alpha: 0.4),
                          blurRadius: 6,
                          spreadRadius: 1,
                        ),
                      ],
                    ),
                  ),
                ],
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
                      _phaseLabel(patient.phase),
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                        color: AppColors.primary,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'OP: ${_formatDate(patient.opDate)}',
                    style: TextStyle(
                      fontSize: 11,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: ClipRRect(
                      borderRadius: AppRadius.borderRadiusPill,
                      child: LinearProgressIndicator(
                        value: patient.progressPercent,
                        minHeight: 4,
                        backgroundColor:
                            AppColors.grey300.withValues(alpha: 0.5),
                        valueColor: AlwaysStoppedAnimation<Color>(
                            AppColors.primary),
                      ),
                    ),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    '${(patient.progressPercent * 100).round()}%',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ],
          ),
          actions: [
            PopupMenuButton<String>(
              onSelected: (value) async {
                if (value == 'unlink') {
                  final confirm = await showDialog<bool>(
                    context: context,
                    builder: (ctx) => AlertDialog(
                      title: const Text('Verbindung trennen?'),
                      content: Text(
                        'Möchten Sie die Verbindung zu ${patient.displayName} wirklich trennen?',
                      ),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(ctx, false),
                          child: const Text('Abbrechen'),
                        ),
                        FilledButton(
                          onPressed: () => Navigator.pop(ctx, true),
                          child: const Text('Trennen'),
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
                }
              },
              itemBuilder: (_) => [
                const PopupMenuItem(
                  value: 'template',
                  child: Row(
                    children: [
                      Icon(Icons.playlist_add_rounded,
                          color: AppColors.primary),
                      SizedBox(width: 8),
                      Text('Vorlage anwenden'),
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
          ],
          bottom: TabBar(
            isScrollable: true,
            tabs: tabs,
          ),
        ),
        body: TabBarView(
          children: tabViews,
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
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('Termin konnte nicht erstellt werden.')),
        );
      }
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
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
                    Text(_busy ? 'Erstelle...' : 'Termin erstellen'),
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
        const PopupMenuItem(
          value: 'appointment',
          child: Row(
            children: [
              Icon(Icons.event_rounded, color: AppColors.primary),
              SizedBox(width: 12),
              Text('Termin erstellen'),
            ],
          ),
        ),
        const PopupMenuItem(
          value: 'task',
          child: Row(
            children: [
              Icon(Icons.task_alt_rounded, color: AppColors.success),
              SizedBox(width: 12),
              Text('Aufgabe zuweisen'),
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
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('Aufgabe konnte nicht erstellt werden.')),
        );
      }
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
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
                    const InputDecoration(labelText: 'Beschreibung (optional)'),
                maxLines: 2,
              ),
              const SizedBox(height: AppSpacing.md),

              DropdownButtonFormField<TaskType>(
                initialValue: _type,
                items: const [
                  DropdownMenuItem(
                      value: TaskType.checklist, child: Text('Checkliste')),
                  DropdownMenuItem(
                      value: TaskType.wound, child: Text('Wunddoku')),
                  DropdownMenuItem(
                      value: TaskType.meds, child: Text('Medikament')),
                  DropdownMenuItem(
                      value: TaskType.custom, child: Text('Sonstige')),
                ],
                onChanged: (v) {
                  if (v != null) setState(() => _type = v);
                },
                decoration: const InputDecoration(labelText: 'Typ'),
              ),
              const SizedBox(height: AppSpacing.md),

              DropdownButtonFormField<TaskPriority>(
                initialValue: _priority,
                items: const [
                  DropdownMenuItem(
                      value: TaskPriority.low, child: Text('Niedrig')),
                  DropdownMenuItem(
                      value: TaskPriority.normal, child: Text('Normal')),
                  DropdownMenuItem(
                      value: TaskPriority.high, child: Text('Hoch')),
                  DropdownMenuItem(
                      value: TaskPriority.critical, child: Text('Kritisch')),
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
                    _busy ? 'Erstelle...' : 'Aufgabe zuweisen'),
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

  // Step 2 state
  CarePlanTemplate? _selectedTemplate;
  late DateTime _startDate;

  @override
  void initState() {
    super.initState();
    _startDate = DateTime.now();
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
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: _selectedTemplate == null
            ? _buildStep1(context)
            : _buildStep2(context),
      ),
    );
  }

  // ── Step 1: Template selection ─────────────────────────────────
  Widget _buildStep1(BuildContext context) {
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
          'Vorlage anwenden',
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
            final templates = snap.data ?? [];
            if (snap.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (templates.isNotEmpty) ...[
                  Text('Eigene Vorlagen',
                    style: Theme.of(context).textTheme.labelLarge?.copyWith(
                      color: AppColors.textSecondary,
                    )),
                  const SizedBox(height: AppSpacing.sm),
                  for (final t in templates) ...[
                    _TemplateListTile(
                      template: t,
                      onTap: () => setState(() => _selectedTemplate = t),
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
            final templates = snap.data ?? [];
            if (templates.isEmpty) return const SizedBox.shrink();
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Systemvorlagen',
                  style: Theme.of(context).textTheme.labelLarge?.copyWith(
                    color: AppColors.textSecondary,
                  )),
                const SizedBox(height: AppSpacing.sm),
                for (final t in templates) ...[
                  _TemplateListTile(
                    template: t,
                    onTap: () => setState(() => _selectedTemplate = t),
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

  // ── Step 2: Preview + Date picker ──────────────────────────────
  Widget _buildStep2(BuildContext context) {
    final template = _selectedTemplate!;
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Back + title
        Row(
          children: [
            IconButton(
              onPressed: () => setState(() => _selectedTemplate = null),
              icon: const Icon(Icons.arrow_back_rounded),
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(),
            ),
            const SizedBox(width: AppSpacing.sm),
            Expanded(
              child: Text(
                template.name,
                style: Theme.of(context).textTheme.titleLarge,
              ),
            ),
          ],
        ),
        if (template.description.isNotEmpty) ...[
          const SizedBox(height: AppSpacing.xs),
          Text(
            template.description,
            style: const TextStyle(
              fontSize: 13,
              color: AppColors.textSecondary,
            ),
          ),
        ],
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
                    const Text('Startdatum (z.B. OP-Datum)',
                      style: TextStyle(
                        fontSize: 12,
                        color: AppColors.textSecondary,
                      )),
                    Text(
                      _formatDate(_startDate),
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ],
                ),
                const Spacer(),
                const Icon(Icons.edit_calendar_rounded,
                    size: 18, color: AppColors.primary),
              ],
            ),
          ),
        ),
        const SizedBox(height: AppSpacing.lg),

        // Task preview
        Text(
          '${template.tasks.length} Aufgabe${template.tasks.length == 1 ? '' : 'n'}:',
          style: Theme.of(context).textTheme.titleSmall,
        ),
        const SizedBox(height: AppSpacing.sm),
        for (final task in template.tasks) ...[
          _TaskPreviewTile(task: task, startDate: _startDate),
          const SizedBox(height: AppSpacing.xs),
        ],

        const SizedBox(height: AppSpacing.xl),

        // Apply button
        FilledButton.icon(
          onPressed: _applying ? null : _apply,
          icon: _applying
              ? const SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(
                      strokeWidth: 2, color: Colors.white),
                )
              : const Icon(Icons.check_rounded),
          label: Text(_applying ? 'Wird zugewiesen...' : 'Vorlage anwenden'),
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
                Text(
                  task.title,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                    color: AppColors.textPrimary,
                  ),
                ),
                Text(
                  '${_formatDate(scheduled)} · Tag +${task.relativeDayOffset}',
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
