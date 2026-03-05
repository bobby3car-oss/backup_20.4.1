import 'package:flutter/material.dart';

import '../../../features/appointments/domain/appointment.dart';
import '../../../features/appointments/domain/appointment_enums.dart';
import '../../../features/doctor_report/doctor_report_builder.dart';
import '../../../ui/ui.dart';
import '../data/doctor_patient_repository.dart';
import '../domain/linked_patient.dart';
import 'tabs/patient_documents_tab.dart';
import 'tabs/patient_pain_tab.dart';
import 'tabs/patient_report_tab.dart';
import 'tabs/patient_wounds_tab.dart';

/// Detail screen for a single patient, showing 4 tabs:
/// Report | Wunde | Schmerz | Dokumente
class PatientDetailScreen extends StatelessWidget {
  const PatientDetailScreen({
    super.key,
    required this.patient,
  });

  final LinkedPatient patient;

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
    final ampel = _ampelColor(patient.warnStatus);

    return DefaultTabController(
      length: 4,
      child: Scaffold(
        backgroundColor: AppColors.background,
        floatingActionButton: FloatingActionButton.small(
          heroTag: 'patient_detail_fab',
          onPressed: () => _showCreateAppointment(context),
          backgroundColor: AppColors.primary,
          child: const Icon(Icons.add_rounded, color: AppColors.white),
        ),
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
                    await DoctorPatientRepository()
                        .unlinkPatient(patient.uid);
                    if (context.mounted) Navigator.pop(context);
                  }
                }
              },
              itemBuilder: (_) => [
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
          bottom: const TabBar(
            tabs: [
              Tab(
                icon: Icon(Icons.summarize_rounded, size: 20),
                text: 'Report',
              ),
              Tab(
                icon: Icon(Icons.healing_rounded, size: 20),
                text: 'Wunde',
              ),
              Tab(
                icon: Icon(Icons.speed_rounded, size: 20),
                text: 'Schmerz',
              ),
              Tab(
                icon: Icon(Icons.folder_rounded, size: 20),
                text: 'Dokumente',
              ),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            PatientReportTab(patient: patient),
            PatientWoundsTab(patientId: patient.uid),
            PatientPainTab(patientId: patient.uid),
            PatientDocumentsTab(patientId: patient.uid),
          ],
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
      final appointment = Appointment(
        id: 'appt_${now.millisecondsSinceEpoch}',
        ownerId: widget.patient.uid,
        title: title,
        notes: _notesController.text.trim(),
        type: _type,
        status: AppointmentStatus.planned,
        startAt: _startAt,
        allDay: false,
        reminderPreset: ReminderPreset.hour1,
        repeatRule: RepeatRule.none,
        createdAt: now,
        updatedAt: now,
      );
      await widget.repository
          .createAppointmentForPatient(widget.patient.uid, appointment);
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
