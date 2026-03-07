import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../../../features/appointments/domain/appointment.dart';
import '../../../features/appointments/domain/appointment_enums.dart';
import '../../../ui/ui.dart';
import '../../doctor_patients/data/doctor_patient_repository.dart';
import '../../doctor_patients/domain/linked_patient.dart';

/// Calendar tab showing all linked patients' appointments.
/// Supports month and week views, plus create / edit / delete.
class DoctorCalendarTab extends StatefulWidget {
  const DoctorCalendarTab({super.key});

  @override
  State<DoctorCalendarTab> createState() => _DoctorCalendarTabState();
}

class _DoctorCalendarTabState extends State<DoctorCalendarTab> {
  final _repo = DoctorPatientRepository();
  DateTime _selectedDate = DateTime.now();
  bool _showMonthView = false;

  // Data
  List<PatientAppointment> _appointments = [];
  Map<DateTime, int> _monthCounts = {};
  bool _loadingAppointments = true;

  @override
  void initState() {
    super.initState();
    _refreshAppointments();
    _refreshMonthCounts();
  }

  Future<void> _refreshAppointments() async {
    if (!mounted) return;
    setState(() => _loadingAppointments = true);
    try {
      final appts = await _repo.getAppointmentsForDate(_selectedDate);
      if (mounted) {
        setState(() {
          _appointments = appts;
          _loadingAppointments = false;
        });
      }
    } catch (_) {
      if (mounted) setState(() => _loadingAppointments = false);
    }
  }

  Future<void> _refreshMonthCounts() async {
    try {
      final counts = await _repo.getMonthAppointmentCounts(
          _selectedDate.year, _selectedDate.month);
      if (mounted) setState(() => _monthCounts = counts);
    } catch (_) {}
  }

  void _selectDate(DateTime date) {
    Haptic.selection();
    final monthChanged = date.month != _selectedDate.month ||
        date.year != _selectedDate.year;
    setState(() => _selectedDate = date);
    _refreshAppointments();
    if (monthChanged) _refreshMonthCounts();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: AppBackground(
        child: SafeArea(
          child: Column(
            children: [
              // ── Header ─────────────────────────────────────────
              Padding(
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.xl, AppSpacing.lg, AppSpacing.xl, AppSpacing.sm,
                ),
                child: Row(
                  children: [
                    Text(
                      'Kalender',
                      style: theme.textTheme.headlineSmall
                          ?.copyWith(fontWeight: FontWeight.bold),
                    ),
                    const Spacer(),
                    // Month / Week toggle
                    PressableScale(
                      onTap: () {
                        Haptic.light();
                        setState(() => _showMonthView = !_showMonthView);
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withValues(alpha: 0.1),
                          borderRadius: AppRadius.borderRadiusPill,
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              _showMonthView
                                  ? Icons.view_week_rounded
                                  : Icons.calendar_view_month_rounded,
                              size: 16,
                              color: AppColors.primary,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              _showMonthView ? 'Woche' : 'Monat',
                              style: TextStyle(
                                fontSize: 12,
                                color: AppColors.primary,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    IconButton(
                      icon: const Icon(Icons.add_rounded),
                      tooltip: 'Termin erstellen',
                      onPressed: () => _showAppointmentSheet(context),
                    ),
                  ],
                ),
              ),

              // ── Month name ───────────────────────────────────
              _MonthHeader(
                date: _selectedDate,
                onPrev: () => _selectDate(
                  _showMonthView
                      ? DateTime(_selectedDate.year, _selectedDate.month - 1,
                          _selectedDate.day)
                      : _selectedDate.subtract(const Duration(days: 7)),
                ),
                onNext: () => _selectDate(
                  _showMonthView
                      ? DateTime(_selectedDate.year, _selectedDate.month + 1,
                          _selectedDate.day)
                      : _selectedDate.add(const Duration(days: 7)),
                ),
                onToday: () => _selectDate(DateTime.now()),
              ),

              const SizedBox(height: AppSpacing.xs),

              // ── Calendar view ──────────────────────────────────
              if (_showMonthView)
                _MonthGrid(
                  selectedDate: _selectedDate,
                  appointmentCounts: _monthCounts,
                  onDateSelected: _selectDate,
                )
              else
                _WeekStrip(
                  selectedDate: _selectedDate,
                  appointmentCounts: _monthCounts,
                  onDateSelected: _selectDate,
                ),

              const SizedBox(height: AppSpacing.sm),

              // ── Appointments list ──────────────────────────────
              Expanded(
                child: _loadingAppointments
                    ? const Center(child: CircularProgressIndicator())
                    : _appointments.isEmpty
                        ? Center(
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.event_available_rounded,
                                    size: 48, color: AppColors.grey400),
                                const SizedBox(height: AppSpacing.md),
                                Text(
                                  'Keine Termine an diesem Tag',
                                  style: TextStyle(
                                      color: AppColors.textSecondary),
                                ),
                              ],
                            ),
                          )
                        : ListView.builder(
                            padding: const EdgeInsets.symmetric(
                              horizontal: AppSpacing.xl,
                              vertical: AppSpacing.sm,
                            ),
                            itemCount: _appointments.length,
                            itemBuilder: (context, index) {
                              return FadeSlideIn(
                                delay: Duration(
                                    milliseconds: 40 * index),
                                child: _AppointmentCard(
                                pa: _appointments[index],
                                onEdit: () => _showAppointmentSheet(
                                  context,
                                  existing: _appointments[index],
                                ),
                                onDelete: () =>
                                    _confirmDelete(_appointments[index]),
                              ),
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

  void _showAppointmentSheet(BuildContext context,
      {PatientAppointment? existing}) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.background,
      shape: const RoundedRectangleBorder(
        borderRadius:
            BorderRadius.vertical(top: Radius.circular(AppRadius.xl)),
      ),
      builder: (_) => _AppointmentFormSheet(
        repository: _repo,
        existing: existing,
        initialDate: _selectedDate,
        onSaved: () {
          _refreshAppointments();
          _refreshMonthCounts();
        },
      ),
    );
  }

  void _confirmDelete(PatientAppointment pa) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Termin löschen?'),
        content: Text(
          '„${pa.appointment.title}" für ${pa.patient.displayName} wird unwiderruflich gelöscht.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Abbrechen'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: AppColors.error,
            ),
            onPressed: () async {
              Navigator.pop(ctx);
              await _repo.deleteAppointmentForPatient(
                  pa.patient.uid, pa.appointment.id);
              _refreshAppointments();
              _refreshMonthCounts();
            },
            child: const Text('Löschen'),
          ),
        ],
      ),
    );
  }
}

// ── Month Header ───────────────────────────────────────────────────────────

class _MonthHeader extends StatelessWidget {
  const _MonthHeader({
    required this.date,
    required this.onPrev,
    required this.onNext,
    required this.onToday,
  });

  final DateTime date;
  final VoidCallback onPrev;
  final VoidCallback onNext;
  final VoidCallback onToday;

  static const _months = [
    'Januar', 'Februar', 'März', 'April', 'Mai', 'Juni',
    'Juli', 'August', 'September', 'Oktober', 'November', 'Dezember',
  ];

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.chevron_left_rounded),
            onPressed: onPrev,
          ),
          Expanded(
            child: GestureDetector(
              onTap: onToday,
              child: Text(
                '${_months[date.month - 1]} ${date.year}',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
              ),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.chevron_right_rounded),
            onPressed: onNext,
          ),
        ],
      ),
    );
  }
}

// ── Week strip with dots ───────────────────────────────────────────────────

class _WeekStrip extends StatelessWidget {
  const _WeekStrip({
    required this.selectedDate,
    required this.appointmentCounts,
    required this.onDateSelected,
  });

  final DateTime selectedDate;
  final Map<DateTime, int> appointmentCounts;
  final ValueChanged<DateTime> onDateSelected;

  static const _weekdays = ['Mo', 'Di', 'Mi', 'Do', 'Fr', 'Sa', 'So'];

  @override
  Widget build(BuildContext context) {
    final today = DateTime.now();
    final startOfWeek =
        selectedDate.subtract(Duration(days: selectedDate.weekday - 1));
    final days = List.generate(7, (i) => startOfWeek.add(Duration(days: i)));

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: days.map((day) {
          final isSelected = _isSameDay(day, selectedDate);
          final isToday = _isSameDay(day, today);
          final dayKey = DateTime(day.year, day.month, day.day);
          final hasAppts = (appointmentCounts[dayKey] ?? 0) > 0;

          return Expanded(
            child: GestureDetector(
              onTap: () => onDateSelected(day),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                margin: const EdgeInsets.symmetric(horizontal: 2),
                padding: const EdgeInsets.symmetric(vertical: 8),
                decoration: BoxDecoration(
                  color: isSelected
                      ? AppColors.primary
                      : isToday
                          ? AppColors.primary.withValues(alpha: 0.08)
                          : Colors.transparent,
                  borderRadius: AppRadius.borderRadiusMd,
                ),
                child: Column(
                  children: [
                    Text(
                      _weekdays[day.weekday - 1],
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w500,
                        color: isSelected
                            ? AppColors.white
                            : AppColors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${day.day}',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight:
                            isSelected ? FontWeight.bold : FontWeight.w500,
                        color:
                            isSelected ? AppColors.white : AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    // Appointment dot
                    Container(
                      width: 5,
                      height: 5,
                      decoration: BoxDecoration(
                        color: hasAppts
                            ? (isSelected
                                ? AppColors.white
                                : AppColors.primary)
                            : Colors.transparent,
                        shape: BoxShape.circle,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }).toList(growable: false),
      ),
    );
  }

  bool _isSameDay(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;
}

// ── Month grid ─────────────────────────────────────────────────────────────

class _MonthGrid extends StatelessWidget {
  const _MonthGrid({
    required this.selectedDate,
    required this.appointmentCounts,
    required this.onDateSelected,
  });

  final DateTime selectedDate;
  final Map<DateTime, int> appointmentCounts;
  final ValueChanged<DateTime> onDateSelected;

  static const _weekdays = ['Mo', 'Di', 'Mi', 'Do', 'Fr', 'Sa', 'So'];

  @override
  Widget build(BuildContext context) {
    final today = DateTime.now();
    final firstOfMonth =
        DateTime(selectedDate.year, selectedDate.month, 1);
    final daysInMonth =
        DateTime(selectedDate.year, selectedDate.month + 1, 0).day;
    // Monday = 1
    final startWeekday = firstOfMonth.weekday;
    final leadingBlanks = startWeekday - 1;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
      child: Column(
        children: [
          // Weekday header
          Row(
            children: _weekdays
                .map((d) => Expanded(
                      child: Center(
                        child: Text(
                          d,
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ),
                    ))
                .toList(growable: false),
          ),
          const SizedBox(height: AppSpacing.xs),
          // Day cells
          ...List.generate(
            ((leadingBlanks + daysInMonth) / 7).ceil(),
            (weekRow) {
              return Row(
                children: List.generate(7, (col) {
                  final dayIndex =
                      weekRow * 7 + col - leadingBlanks + 1;
                  if (dayIndex < 1 || dayIndex > daysInMonth) {
                    return const Expanded(child: SizedBox(height: 40));
                  }

                  final day = DateTime(
                      selectedDate.year, selectedDate.month, dayIndex);
                  final isSelected = _isSameDay(day, selectedDate);
                  final isToday = _isSameDay(day, today);
                  final dayKey =
                      DateTime(day.year, day.month, day.day);
                  final count = appointmentCounts[dayKey] ?? 0;

                  return Expanded(
                    child: GestureDetector(
                      onTap: () => onDateSelected(day),
                      child: Container(
                        height: 40,
                        margin: const EdgeInsets.all(1),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? AppColors.primary
                              : isToday
                                  ? AppColors.primary
                                      .withValues(alpha: 0.08)
                                  : Colors.transparent,
                          borderRadius: AppRadius.borderRadiusSm,
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              '$dayIndex',
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: isSelected
                                    ? FontWeight.bold
                                    : FontWeight.w400,
                                color: isSelected
                                    ? AppColors.white
                                    : AppColors.textPrimary,
                              ),
                            ),
                            if (count > 0) ...[
                              const SizedBox(height: 2),
                              Container(
                                width: 5,
                                height: 5,
                                decoration: BoxDecoration(
                                  color: isSelected
                                      ? AppColors.white
                                      : AppColors.primary,
                                  shape: BoxShape.circle,
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                    ),
                  );
                }),
              );
            },
          ),
        ],
      ),
    );
  }

  bool _isSameDay(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;
}

// ── Appointment Card with edit/delete ─────────────────────────────────────

class _AppointmentCard extends StatelessWidget {
  const _AppointmentCard({
    required this.pa,
    required this.onEdit,
    required this.onDelete,
  });

  final PatientAppointment pa;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final a = pa.appointment;
    final time =
        '${a.startAt.hour.toString().padLeft(2, '0')}:${a.startAt.minute.toString().padLeft(2, '0')}';

    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: Dismissible(
        key: ValueKey(a.id),
        direction: DismissDirection.endToStart,
        background: Container(
          alignment: Alignment.centerRight,
          padding: const EdgeInsets.only(right: AppSpacing.xl),
          decoration: BoxDecoration(
            color: AppColors.error.withValues(alpha: 0.15),
            borderRadius: AppRadius.borderRadiusLg,
          ),
          child: const Icon(Icons.delete_rounded, color: AppColors.error),
        ),
        confirmDismiss: (_) async {
          onDelete();
          return false; // We handle deletion in the dialog
        },
        child: GlassCard(
          onTap: onEdit,
          child: Row(
            children: [
              // Colored type indicator
              Container(
                width: 4,
                height: 48,
                decoration: BoxDecoration(
                  color: a.type.color,
                  borderRadius: AppRadius.borderRadiusPill,
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              // Time badge
              Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: a.type.color.withValues(alpha: 0.1),
                  borderRadius: AppRadius.borderRadiusSm,
                ),
                child: Text(
                  time,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: a.type.color,
                  ),
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
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Row(
                      children: [
                        Text(
                          pa.patient.displayName,
                          style: TextStyle(
                            fontSize: 12,
                            color: AppColors.textSecondary,
                          ),
                        ),
                        if (a.notes.isNotEmpty) ...[
                          Text(
                            '  •  ',
                            style: TextStyle(
                                fontSize: 12,
                                color: AppColors.textSecondary),
                          ),
                          Flexible(
                            child: Text(
                              a.notes,
                              style: TextStyle(
                                fontSize: 12,
                                color: AppColors.textSecondary,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ),
              Icon(a.type.icon, size: 18, color: a.type.color),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Create / Edit appointment sheet ────────────────────────────────────────

class _AppointmentFormSheet extends StatefulWidget {
  const _AppointmentFormSheet({
    required this.repository,
    this.existing,
    required this.initialDate,
    required this.onSaved,
  });

  final DoctorPatientRepository repository;
  final PatientAppointment? existing;
  final DateTime initialDate;
  final VoidCallback onSaved;

  @override
  State<_AppointmentFormSheet> createState() => _AppointmentFormSheetState();
}

class _AppointmentFormSheetState extends State<_AppointmentFormSheet> {
  final _titleController = TextEditingController();
  final _notesController = TextEditingController();
  late DateTime _startAt;
  late AppointmentType _type;
  LinkedPatient? _selectedPatient;
  List<LinkedPatient> _patients = [];
  bool _busy = false;
  bool _loaded = false;

  bool get _isEditing => widget.existing != null;

  @override
  void initState() {
    super.initState();
    if (_isEditing) {
      final a = widget.existing!.appointment;
      _titleController.text = a.title;
      _notesController.text = a.notes;
      _startAt = a.startAt;
      _type = a.type;
    } else {
      _startAt = DateTime(
        widget.initialDate.year,
        widget.initialDate.month,
        widget.initialDate.day,
        DateTime.now().hour + 1,
      );
      _type = AppointmentType.followUp;
    }
    _loadPatients();
  }

  Future<void> _loadPatients() async {
    try {
      final patients = await widget.repository.getLinkedPatientsOnce();
      if (mounted) {
        setState(() {
          _patients = patients;
          _loaded = true;
          if (_isEditing) {
            _selectedPatient = patients
                .where((p) => p.uid == widget.existing!.patient.uid)
                .firstOrNull;
          } else if (patients.isNotEmpty) {
            _selectedPatient = patients.first;
          }
        });
      }
    } catch (_) {
      if (mounted) setState(() => _loaded = true);
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final patient = _selectedPatient;
    if (patient == null) return;
    final title = _titleController.text.trim();
    if (title.isEmpty) return;

    setState(() => _busy = true);
    try {
      final now = DateTime.now();
      if (_isEditing) {
        final updated = widget.existing!.appointment.copyWith(
          title: title,
          notes: _notesController.text.trim(),
          startAt: _startAt,
          type: _type,
          updatedAt: now,
        );
        await widget.repository
            .updateAppointmentForPatient(patient.uid, updated);
      } else {
        final appointment = Appointment(
          id: 'appt_${now.millisecondsSinceEpoch}',
          ownerId: patient.uid,
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
            .createAppointmentForPatient(patient.uid, appointment);
      }
      widget.onSaved();
      if (mounted) Navigator.pop(context);
    } catch (e) {
      if (kDebugMode) debugPrint('[DoctorCalendarTab] error: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('Termin konnte nicht gespeichert werden.')),
        );
      }
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _delete() async {
    if (!_isEditing) return;
    Navigator.pop(context);
    // Delete via parent
    final pa = widget.existing!;
    await widget.repository
        .deleteAppointmentForPatient(pa.patient.uid, pa.appointment.id);
    widget.onSaved();
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
              // Drag handle
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

              // Title
              Row(
                children: [
                  Expanded(
                    child: Text(
                      _isEditing ? 'Termin bearbeiten' : 'Termin erstellen',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                  ),
                  if (_isEditing)
                    IconButton(
                      icon:
                          const Icon(Icons.delete_rounded, color: AppColors.error),
                      tooltip: 'Löschen',
                      onPressed: () {
                        showDialog(
                          context: context,
                          builder: (ctx) => AlertDialog(
                            title: const Text('Termin löschen?'),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.pop(ctx),
                                child: const Text('Abbrechen'),
                              ),
                              FilledButton(
                                style: FilledButton.styleFrom(
                                    backgroundColor: AppColors.error),
                                onPressed: () {
                                  Navigator.pop(ctx);
                                  _delete();
                                },
                                child: const Text('Löschen'),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                ],
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
                  onChanged: _isEditing
                      ? null
                      : (v) => setState(() => _selectedPatient = v),
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

              // Type picker
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

              // Date/time picker
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
                onPressed: _busy ? null : _save,
                child: Text(_busy
                    ? 'Speichern...'
                    : _isEditing
                        ? 'Änderungen speichern'
                        : 'Termin erstellen'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
