import 'package:flutter/material.dart';

import '../../../features/appointments/domain/appointment.dart';
import '../../../features/appointments/domain/appointment_enums.dart';
import '../../../ui/ui.dart';
import '../../doctor_patients/data/doctor_patient_repository.dart';
import '../../doctor_patients/domain/linked_patient.dart';

/// Calendar tab showing all linked patients' appointments.
/// The doctor can also create new appointments for patients.
class DoctorCalendarTab extends StatefulWidget {
  const DoctorCalendarTab({super.key});

  @override
  State<DoctorCalendarTab> createState() => _DoctorCalendarTabState();
}

class _DoctorCalendarTabState extends State<DoctorCalendarTab> {
  final _repo = DoctorPatientRepository();
  DateTime _selectedDate = DateTime.now();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: AppBackground(
        child: SafeArea(
          child: Column(
            children: [
              // ── Header ─────────────────────────────────────────
              Padding(
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.xl,
                  AppSpacing.lg,
                  AppSpacing.xl,
                  AppSpacing.sm,
                ),
                child: Row(
                  children: [
                    Text(
                      'Kalender',
                      style: Theme.of(context)
                          .textTheme
                          .headlineSmall
                          ?.copyWith(fontWeight: FontWeight.bold),
                    ),
                    const Spacer(),
                    IconButton(
                      icon: const Icon(Icons.add_rounded),
                      tooltip: 'Termin erstellen',
                      onPressed: () => _showCreateAppointmentDialog(context),
                    ),
                  ],
                ),
              ),

              // ── Simple week strip ──────────────────────────────
              _WeekStrip(
                selectedDate: _selectedDate,
                onDateSelected: (date) =>
                    setState(() => _selectedDate = date),
              ),

              const SizedBox(height: AppSpacing.sm),

              // ── Appointments for all patients ──────────────────
              Expanded(
                child: StreamBuilder<List<LinkedPatient>>(
                  stream: _repo.watchLinkedPatients(),
                  builder: (context, patientSnap) {
                    if (!patientSnap.hasData) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    final patients = patientSnap.data!;
                    if (patients.isEmpty) {
                      return Center(
                        child: Text(
                          'Keine Patienten verknüpft',
                          style: TextStyle(color: AppColors.textSecondary),
                        ),
                      );
                    }

                    return _AppointmentsForDate(
                      patients: patients,
                      date: _selectedDate,
                      repository: _repo,
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showCreateAppointmentDialog(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.background,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(AppRadius.xl)),
      ),
      builder: (_) => _CreateAppointmentSheet(repository: _repo),
    );
  }
}

// ── Week strip ─────────────────────────────────────────────────────────────

class _WeekStrip extends StatelessWidget {
  const _WeekStrip({
    required this.selectedDate,
    required this.onDateSelected,
  });

  final DateTime selectedDate;
  final ValueChanged<DateTime> onDateSelected;

  static const _weekdays = ['Mo', 'Di', 'Mi', 'Do', 'Fr', 'Sa', 'So'];

  @override
  Widget build(BuildContext context) {
    final today = DateTime.now();
    final startOfWeek =
        selectedDate.subtract(Duration(days: selectedDate.weekday - 1));
    final days = List.generate(
      7,
      (i) => startOfWeek.add(Duration(days: i)),
    );

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            icon: const Icon(Icons.chevron_left_rounded),
            onPressed: () =>
                onDateSelected(selectedDate.subtract(const Duration(days: 7))),
          ),
          ...days.map((day) {
            final isSelected = day.day == selectedDate.day &&
                day.month == selectedDate.month &&
                day.year == selectedDate.year;
            final isToday = day.day == today.day &&
                day.month == today.month &&
                day.year == today.year;

            return GestureDetector(
              onTap: () => onDateSelected(day),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                width: 36,
                padding: const EdgeInsets.symmetric(vertical: 6),
                decoration: BoxDecoration(
                  color: isSelected
                      ? AppColors.primary
                      : isToday
                          ? AppColors.primary.withValues(alpha: 0.1)
                          : Colors.transparent,
                  borderRadius: AppRadius.borderRadiusSm,
                ),
                child: Column(
                  children: [
                    Text(
                      _weekdays[day.weekday - 1],
                      style: TextStyle(
                        fontSize: 10,
                        color: isSelected
                            ? AppColors.white
                            : AppColors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${day.day}',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight:
                            isSelected ? FontWeight.bold : FontWeight.w500,
                        color: isSelected
                            ? AppColors.white
                            : AppColors.textPrimary,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }),
          IconButton(
            icon: const Icon(Icons.chevron_right_rounded),
            onPressed: () =>
                onDateSelected(selectedDate.add(const Duration(days: 7))),
          ),
        ],
      ),
    );
  }
}

// ── Appointments for a date across all patients ────────────────────────────

class _AppointmentsForDate extends StatelessWidget {
  const _AppointmentsForDate({
    required this.patients,
    required this.date,
    required this.repository,
  });

  final List<LinkedPatient> patients;
  final DateTime date;
  final DoctorPatientRepository repository;

  @override
  Widget build(BuildContext context) {
    // Merge streams from all patients
    final streams = patients.map(
      (p) => repository.watchPatientAppointments(p.uid).map(
            (list) => list
                .where((a) => _isSameDay(a.startAt, date))
                .map((a) => _PatientAppointment(patient: p, appointment: a))
                .toList(growable: false),
          ),
    );

    return StreamBuilder<List<List<_PatientAppointment>>>(
      stream: _combineStreams(streams.toList()),
      builder: (context, snapshot) {
        final allAppts =
            (snapshot.data ?? []).expand((l) => l).toList(growable: false);
        allAppts.sort(
            (a, b) => a.appointment.startAt.compareTo(b.appointment.startAt));

        if (allAppts.isEmpty) {
          return Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.event_available_rounded,
                    size: 48, color: AppColors.grey400),
                const SizedBox(height: AppSpacing.md),
                Text(
                  'Keine Termine an diesem Tag',
                  style: TextStyle(color: AppColors.textSecondary),
                ),
              ],
            ),
          );
        }

        return ListView.builder(
          padding: AppSpacing.screenPadding,
          itemCount: allAppts.length,
          itemBuilder: (context, index) {
            final item = allAppts[index];
            final a = item.appointment;
            return GlassCard(
              child: Row(
                children: [
                  Container(
                    width: 4,
                    height: 44,
                    decoration: BoxDecoration(
                      color: AppColors.primary,
                      borderRadius: AppRadius.borderRadiusPill,
                    ),
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          a.title,
                          style: Theme.of(context)
                              .textTheme
                              .titleSmall
                              ?.copyWith(fontWeight: FontWeight.w600),
                        ),
                        Text(
                          '${item.patient.displayName}  •  ${a.startAt.hour.toString().padLeft(2, '0')}:${a.startAt.minute.toString().padLeft(2, '0')}',
                          style: TextStyle(
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
          },
        );
      },
    );
  }

  bool _isSameDay(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;

  /// Combines multiple streams of lists into a single stream of list of lists.
  Stream<List<List<_PatientAppointment>>> _combineStreams(
    List<Stream<List<_PatientAppointment>>> streams,
  ) async* {
    if (streams.isEmpty) {
      yield [];
      return;
    }

    // Simplified: just fetch all once then yield.
    final results = <List<_PatientAppointment>>[];
    for (final stream in streams) {
      await for (final list in stream) {
        results.add(list);
        break; // Take first emission.
      }
    }
    yield results;
  }
}

class _PatientAppointment {
  const _PatientAppointment({
    required this.patient,
    required this.appointment,
  });

  final LinkedPatient patient;
  final Appointment appointment;
}

// ── Create appointment sheet ───────────────────────────────────────────────

class _CreateAppointmentSheet extends StatefulWidget {
  const _CreateAppointmentSheet({required this.repository});

  final DoctorPatientRepository repository;

  @override
  State<_CreateAppointmentSheet> createState() =>
      _CreateAppointmentSheetState();
}

class _CreateAppointmentSheetState extends State<_CreateAppointmentSheet> {
  final _titleController = TextEditingController();
  final _notesController = TextEditingController();
  DateTime _startAt = DateTime.now().add(const Duration(hours: 1));
  LinkedPatient? _selectedPatient;
  List<LinkedPatient> _patients = [];
  bool _busy = false;
  bool _loaded = false;

  @override
  void initState() {
    super.initState();
    _loadPatients();
  }

  Future<void> _loadPatients() async {
    await for (final patients in widget.repository.watchLinkedPatients()) {
      if (mounted) {
        setState(() {
          _patients = patients;
          _loaded = true;
          if (patients.isNotEmpty) _selectedPatient = patients.first;
        });
      }
      break; // Take first emission.
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _create() async {
    final patient = _selectedPatient;
    if (patient == null) return;
    final title = _titleController.text.trim();
    if (title.isEmpty) return;

    setState(() => _busy = true);
    try {
      final now = DateTime.now();
      final appointment = Appointment(
        id: 'appt_${now.millisecondsSinceEpoch}',
        ownerId: patient.uid,
        title: title,
        notes: _notesController.text.trim(),
        type: AppointmentType.followUp,
        status: AppointmentStatus.planned,
        startAt: _startAt,
        allDay: false,
        reminderPreset: ReminderPreset.hour1,
        repeatRule: RepeatRule.none,
        createdAt: now,
        updatedAt: now,
      );
      await widget.repository
          .createAppointmentForPatient(patient.uid, appointment);
      if (mounted) Navigator.pop(context);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Fehler: $e')),
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
              'Termin erstellen',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: AppSpacing.lg),

            // Patient picker
            if (!_loaded)
              const LinearProgressIndicator()
            else
              DropdownButtonFormField<LinkedPatient>(
                initialValue: _selectedPatient,
                items: _patients
                    .map((p) => DropdownMenuItem(
                          value: p,
                          child: Text(p.displayName),
                        ))
                    .toList(growable: false),
                onChanged: (v) => setState(() => _selectedPatient = v),
                decoration:
                    const InputDecoration(labelText: 'Patient auswählen'),
              ),

            const SizedBox(height: AppSpacing.md),

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

            // Date/time picker
            Builder(builder: (ctx) => OutlinedButton.icon(
              onPressed: () async {
                final date = await showDatePicker(
                  context: ctx,
                  initialDate: _startAt,
                  firstDate: DateTime.now(),
                  lastDate: DateTime.now().add(const Duration(days: 365)),
                );
                if (date == null || !ctx.mounted) return;
                final time = await showTimePicker(
                  context: ctx,
                  initialTime: TimeOfDay.fromDateTime(_startAt),
                );
                if (time == null || !ctx.mounted) return;
                setState(() {
                  _startAt = DateTime(
                      date.year, date.month, date.day, time.hour, time.minute);
                });
              },
              icon: const Icon(Icons.calendar_today),
              label: Text(
                '${_startAt.day}.${_startAt.month}.${_startAt.year}  ${_startAt.hour.toString().padLeft(2, '0')}:${_startAt.minute.toString().padLeft(2, '0')}',
              ),
            )),

            const SizedBox(height: AppSpacing.xl),

            FilledButton(
              onPressed: _busy ? null : _create,
              child: Text(_busy ? 'Erstelle...' : 'Termin erstellen'),
            ),
          ],
        ),
      ),
    );
  }
}
