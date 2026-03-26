import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../../../auth/guest_data_migration_service.dart';
import '../../../ui/ui.dart';
import '../data/appointments_repository_sync.dart';
import '../domain/appointment.dart';
import '../domain/appointment_enums.dart';
import '../domain/appointment_utils.dart';
import '../../../ui/theme/app_icons.dart';
import '../../../l10n/app_localizations.dart';

class AppointmentEditorScreen extends StatefulWidget {
  const AppointmentEditorScreen({
    super.key,
    this.initialAppointment,
    this.appointmentId,
  });

  final Appointment? initialAppointment;
  final String? appointmentId;

  @override
  State<AppointmentEditorScreen> createState() =>
      _AppointmentEditorScreenState();
}

class _AppointmentEditorScreenState extends State<AppointmentEditorScreen> {
  static final AppointmentsRepositorySync _repository =
      AppointmentsRepositorySync.instance;

  final _titleController = TextEditingController();
  final _notesController = TextEditingController();
  final _locationNameController = TextEditingController();
  final _locationDetailsController = TextEditingController();
  final _customReminderController = TextEditingController();

  Appointment? _editing;
  bool _loading = true;
  bool _saving = false;
  bool _hasEndTime = true;
  bool _hasRepeatUntil = false;

  AppointmentType _type = AppointmentType.followUp;
  AppointmentStatus _status = AppointmentStatus.planned;
  ReminderPreset _reminderPreset = ReminderPreset.none;
  RepeatRule _repeatRule = RepeatRule.none;
  bool _allDay = false;
  DateTime _startAt = DateTime.now().add(const Duration(hours: 1));
  DateTime? _endAt = DateTime.now().add(const Duration(hours: 2));
  DateTime? _repeatUntil;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _bootstrap();
    });
  }

  @override
  void dispose() {
    _titleController.dispose();
    _notesController.dispose();
    _locationNameController.dispose();
    _locationDetailsController.dispose();
    _customReminderController.dispose();
    super.dispose();
  }

  Future<void> _bootstrap() async {
    final routeArgs = ModalRoute.of(context)?.settings.arguments;
    Appointment? initial = widget.initialAppointment;
    String? appointmentId = widget.appointmentId;

    if (routeArgs is Appointment) {
      initial = routeArgs;
    } else if (routeArgs is Map) {
      if (routeArgs['appointment'] is Appointment) {
        initial = routeArgs['appointment'] as Appointment;
      }
      appointmentId ??= routeArgs['appointmentId']?.toString();
    } else if (routeArgs is String && routeArgs.trim().isNotEmpty) {
      appointmentId ??= routeArgs.trim();
    }

    if (initial == null && appointmentId != null) {
      initial = await _repository.getById(appointmentId);
    }

    _editing = initial;
    if (initial != null) {
      _fillFrom(initial);
    } else {
      _fillDefaults();
    }

    if (!mounted) return;
    setState(() => _loading = false);
  }

  void _fillDefaults() {
    final now = DateTime.now();
    _titleController.text = '';
    _notesController.text = '';
    _locationNameController.text = '';
    _locationDetailsController.text = '';
    _customReminderController.text = '45';
    _type = AppointmentType.followUp;
    _status = AppointmentStatus.planned;
    _reminderPreset = ReminderPreset.min30;
    _repeatRule = RepeatRule.none;
    _allDay = false;
    _startAt = now.add(const Duration(hours: 1));
    _endAt = now.add(const Duration(hours: 2));
    _hasEndTime = true;
    _hasRepeatUntil = false;
    _repeatUntil = null;
  }

  void _fillFrom(Appointment appointment) {
    _titleController.text = appointment.title;
    _notesController.text = appointment.notes;
    _locationNameController.text = appointment.locationName ?? '';
    _locationDetailsController.text = appointment.locationDetails ?? '';
    _customReminderController.text = (appointment.reminderMinutes ?? 45)
        .toString();
    _type = appointment.type;
    _status = appointment.status;
    _reminderPreset = appointment.reminderPreset;
    _repeatRule = appointment.repeatRule;
    _allDay = appointment.allDay;
    _startAt = appointment.startAt;
    _endAt = appointment.endAt;
    _hasEndTime = appointment.endAt != null;
    _repeatUntil = appointment.repeatUntil;
    _hasRepeatUntil = appointment.repeatUntil != null;
  }

  bool get _isEditMode => _editing != null;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    if (_loading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return GlassPage(
      title: _isEditMode ? 'Termin bearbeiten' : l.appointmentCreate,
      titleIcon: AppIcons.appointments,
      titleColor: AppColors.primary,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
          child: Column(
            children: [
              TextField(
                controller: _titleController,
                decoration: const InputDecoration(labelText: 'Titel *'),
              ),
              const SizedBox(height: 10),
              DropdownButtonFormField<AppointmentType>(
                initialValue: _type,
                items: AppointmentType.values
                    .map(
                      (type) => DropdownMenuItem(
                        value: type,
                        child: Text(_typeLabel(type)),
                      ),
                    )
                    .toList(growable: false),
                onChanged: (value) {
                  if (value == null) return;
                  setState(() => _type = value);
                },
                decoration: const InputDecoration(labelText: 'Typ'),
              ),
              const SizedBox(height: 10),
              _DateTimeRow(
                label: 'Datum',
                value: _formatDate(_startAt),
                onTap: _pickDate,
              ),
              const SizedBox(height: 10),
              _DateTimeRow(
                label: 'Startzeit',
                value: _allDay ? l.allDay : _formatTime(_startAt),
                onTap: _allDay ? null : _pickStartTime,
              ),
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                title: Text(l.allDay),
                value: _allDay,
                onChanged: (value) {
                  setState(() {
                    _allDay = value;
                  });
                },
              ),
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                title: Text(l.endTimeSet),
                value: _hasEndTime && !_allDay,
                onChanged: _allDay
                    ? null
                    : (value) {
                        setState(() {
                          _hasEndTime = value;
                          _endAt ??= _startAt.add(const Duration(hours: 1));
                        });
                      },
              ),
              if (_hasEndTime && !_allDay)
                _DateTimeRow(
                  label: 'Endzeit',
                  value: _formatTime(_endAt ?? _startAt),
                  onTap: _pickEndTime,
                ),
              const SizedBox(height: 10),
              TextField(
                controller: _locationNameController,
                decoration: const InputDecoration(labelText: 'Ort'),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: _locationDetailsController,
                decoration: const InputDecoration(labelText: 'Ort Details'),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: _notesController,
                minLines: 3,
                maxLines: 5,
                decoration: const InputDecoration(labelText: 'Notiz'),
              ),
              const SizedBox(height: 10),
              DropdownButtonFormField<ReminderPreset>(
                initialValue: _reminderPreset,
                items: _reminderPresets
                    .map(
                      (preset) => DropdownMenuItem(
                        value: preset,
                        child: Text(_reminderLabel(preset)),
                      ),
                    )
                    .toList(growable: false),
                onChanged: (value) {
                  if (value == null) return;
                  setState(() => _reminderPreset = value);
                },
                decoration: const InputDecoration(labelText: 'Erinnerung'),
              ),
              if (_reminderPreset == ReminderPreset.custom) ...[
                const SizedBox(height: 10),
                TextField(
                  controller: _customReminderController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'Custom Minuten',
                  ),
                ),
              ],
              const SizedBox(height: 10),
              DropdownButtonFormField<RepeatRule>(
                initialValue: _repeatRule,
                items: RepeatRule.values
                    .map(
                      (rule) => DropdownMenuItem(
                        value: rule,
                        child: Text(_repeatLabel(rule)),
                      ),
                    )
                    .toList(growable: false),
                onChanged: (value) {
                  if (value == null) return;
                  setState(() {
                    _repeatRule = value;
                    if (_repeatRule == RepeatRule.none) {
                      _hasRepeatUntil = false;
                      _repeatUntil = null;
                    }
                  });
                },
                decoration: InputDecoration(labelText: l.repetition),
              ),
              if (_repeatRule != RepeatRule.none) ...[
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text(l.repeatUntil),
                  value: _hasRepeatUntil,
                  onChanged: (value) {
                    setState(() {
                      _hasRepeatUntil = value;
                      _repeatUntil ??= _startAt.add(const Duration(days: 30));
                    });
                  },
                ),
                if (_hasRepeatUntil)
                  _DateTimeRow(
                    label: 'Repeat until',
                    value: _formatDate(_repeatUntil ?? _startAt),
                    onTap: _pickRepeatUntilDate,
                  ),
              ],
              if (_isEditMode) ...[
                const SizedBox(height: 10),
                DropdownButtonFormField<AppointmentStatus>(
                  initialValue: _status,
                  items: AppointmentStatus.values
                      .map(
                        (status) => DropdownMenuItem(
                          value: status,
                          child: Text(_statusLabel(status)),
                        ),
                      )
                      .toList(growable: false),
                  onChanged: (value) {
                    if (value == null) return;
                    setState(() => _status = value);
                  },
                  decoration: InputDecoration(labelText: l.status),
                ),
              ],
              const SizedBox(height: 18),
              FilledButton(
                onPressed: _saving ? null : _save,
                child: Text(_saving ? 'Speichert...' : l.save),
              ),
              if (_isEditMode) ...[
                const SizedBox(height: 10),
                OutlinedButton(
                  onPressed: _saving ? null : _delete,
                  child: Text(l.delete),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }

  List<ReminderPreset> get _reminderPresets => <ReminderPreset>[
    ReminderPreset.none,
    ReminderPreset.min15,
    ReminderPreset.min30,
    ReminderPreset.hour1,
    ReminderPreset.day1,
    ReminderPreset.custom,
  ];

  Future<void> _pickDate() async {
    final selected = await showDatePicker(
      context: context,
      initialDate: _startAt,
      firstDate: DateTime.now().subtract(const Duration(days: 3650)),
      lastDate: DateTime.now().add(const Duration(days: 3650)),
    );
    if (selected == null || !mounted) return;
    setState(() {
      _startAt = DateTime(
        selected.year,
        selected.month,
        selected.day,
        _startAt.hour,
        _startAt.minute,
      );
      if (_endAt != null) {
        _endAt = DateTime(
          selected.year,
          selected.month,
          selected.day,
          _endAt!.hour,
          _endAt!.minute,
        );
      }
    });
  }

  Future<void> _pickStartTime() async {
    final selected = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(_startAt),
    );
    if (selected == null || !mounted) return;
    setState(() {
      _startAt = DateTime(
        _startAt.year,
        _startAt.month,
        _startAt.day,
        selected.hour,
        selected.minute,
      );
      if (_endAt != null && _endAt!.isBefore(_startAt)) {
        _endAt = _startAt.add(const Duration(hours: 1));
      }
    });
  }

  Future<void> _pickEndTime() async {
    final baseline = _endAt ?? _startAt.add(const Duration(hours: 1));
    final selected = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(baseline),
    );
    if (selected == null || !mounted) return;
    setState(() {
      _endAt = DateTime(
        _startAt.year,
        _startAt.month,
        _startAt.day,
        selected.hour,
        selected.minute,
      );
    });
  }

  Future<void> _pickRepeatUntilDate() async {
    final initial = _repeatUntil ?? _startAt;
    final selected = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: _startAt,
      lastDate: _startAt.add(const Duration(days: 3650)),
    );
    if (selected == null || !mounted) return;
    setState(() => _repeatUntil = selected);
  }

  Future<void> _save() async {
    if (_saving) return;
    final title = _titleController.text.trim();
    if (title.isEmpty) {
      _showError('Titel ist erforderlich.');
      return;
    }

    if (!await GuestDataMigrationService.requireAuth(context)) return;
    if (!mounted) return;

    setState(() => _saving = true);
    try {
      final now = DateTime.now();
      final uid = FirebaseAuth.instance.currentUser!.uid;
      final base = _editing;
      final normalized = normalizeAllDay(
        startAt: _startAt,
        endAt: (_hasEndTime && !_allDay) ? _endAt : null,
        allDay: _allDay,
      );

      final reminderMinutes = _reminderPreset == ReminderPreset.custom
          ? int.tryParse(_customReminderController.text.trim())
          : null;

      final appointment = Appointment(
        id: base?.id ?? 'appointment_${now.microsecondsSinceEpoch}',
        ownerId: base?.ownerId ?? uid,
        title: title,
        notes: _notesController.text.trim(),
        type: _type,
        status: _isEditMode ? _status : AppointmentStatus.planned,
        startAt: normalized.startAt,
        endAt: normalized.endAt,
        allDay: _allDay,
        locationName: _locationNameController.text.trim().isEmpty
            ? null
            : _locationNameController.text.trim(),
        locationDetails: _locationDetailsController.text.trim().isEmpty
            ? null
            : _locationDetailsController.text.trim(),
        reminderPreset: _reminderPreset,
        reminderMinutes: reminderMinutes,
        reminderPresets: base?.reminderPresets ?? const <ReminderPreset>[],
        repeatRule: _repeatRule,
        repeatUntil: (_repeatRule != RepeatRule.none && _hasRepeatUntil)
            ? _repeatUntil
            : null,
        createdAt: base?.createdAt ?? now,
        updatedAt: now,
        metadata: base?.metadata ?? const <String, dynamic>{},
        priority: base?.priority ?? AppointmentPriority.medium,
        doctorName: base?.doctorName,
        preparation: base?.preparation,
        createdBy: base?.createdBy,
      );

      final errors = validate(appointment);
      if (errors.isNotEmpty) {
        _showError(errors.first);
        return;
      }

      await _repository.upsert(appointment);
      if (!mounted) return;
      Navigator.of(context).pop(true);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(userFacingError(e))));
      }
    } finally {
      if (mounted) {
        setState(() => _saving = false);
      }
    }
  }

  Future<void> _delete() async {
    final target = _editing;
    if (target == null) return;
    setState(() => _saving = true);
    try {
      await _repository.delete(target.id);
      if (!mounted) return;
      Navigator.of(context).pop(true);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(userFacingError(e))));
      }
    } finally {
      if (mounted) {
        setState(() => _saving = false);
      }
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  String _formatDate(DateTime value) {
    final dd = value.day.toString().padLeft(2, '0');
    final mm = value.month.toString().padLeft(2, '0');
    return '$dd.$mm.${value.year}';
  }

  String _formatTime(DateTime value) {
    final hh = value.hour.toString().padLeft(2, '0');
    final mm = value.minute.toString().padLeft(2, '0');
    return '$hh:$mm';
  }

  String _typeLabel(AppointmentType value) => value.label;

  String _repeatLabel(RepeatRule value) => value.label;

  String _statusLabel(AppointmentStatus value) => value.label;

  String _reminderLabel(ReminderPreset value) => value.label;
}

class _DateTimeRow extends StatelessWidget {
  const _DateTimeRow({required this.label, required this.value, this.onTap});

  final String label;
  final String value;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      title: Text(label),
      subtitle: Text(value),
      trailing: const Icon(Icons.edit_calendar_outlined),
      onTap: onTap,
    );
  }
}
