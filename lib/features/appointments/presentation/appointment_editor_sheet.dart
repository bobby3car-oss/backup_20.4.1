import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../../../auth/guest_data_migration_service.dart';
import '../../../ui/ui.dart';
import '../data/appointments_repository_sync.dart';
import '../domain/appointment.dart';
import '../domain/appointment_enums.dart';
import '../domain/appointment_utils.dart';
import '../domain/appointments_l10n.dart';
import '../../../l10n/app_localizations.dart';

/// Opens the appointment editor as a draggable bottom sheet.
///
/// Returns the saved [Appointment] (or `null` if dismissed / deleted).
Future<Appointment?> showAppointmentEditorSheet(
  BuildContext context, {
  Appointment? appointment,
  DateTime? initialDate,
}) {
  return showModalBottomSheet<Appointment>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    useSafeArea: true,
    builder: (_) => _AppointmentEditorSheet(
      initial: appointment,
      initialDate: initialDate,
    ),
  );
}

// ─────────────────────────────────────────────────────────────────────────────

class _AppointmentEditorSheet extends StatefulWidget {
  const _AppointmentEditorSheet({this.initial, this.initialDate});

  final Appointment? initial;
  final DateTime? initialDate;

  @override
  State<_AppointmentEditorSheet> createState() =>
      _AppointmentEditorSheetState();
}

class _AppointmentEditorSheetState extends State<_AppointmentEditorSheet> {
  static final _repository = AppointmentsRepositorySync.instance;

  final _titleCtrl = TextEditingController();
  final _notesCtrl = TextEditingController();
  final _locationCtrl = TextEditingController();
  final _locationDetailsCtrl = TextEditingController();
  final _customReminderCtrl = TextEditingController();
  final _doctorCtrl = TextEditingController();
  final _preparationCtrl = TextEditingController();

  late AppointmentType _type;
  late AppointmentStatus _status;
  late ReminderPreset _reminder;
  late RepeatRule _repeat;
  late AppointmentPriority _priority;
  late bool _allDay;
  late DateTime _startAt;
  DateTime? _endAt;
  DateTime? _repeatUntil;
  bool _hasEndTime = true;
  bool _hasRepeatUntil = false;
  bool _saving = false;
  /// Additional reminders (multi-select).
  Set<ReminderPreset> _extraReminders = {};

  bool get _isEdit => widget.initial != null;

  @override
  void initState() {
    super.initState();
    final a = widget.initial;
    if (a != null) {
      _fillFrom(a);
    } else {
      _fillDefaults();
    }
  }

  void _fillDefaults() {
    final now = DateTime.now();
    _type = AppointmentType.followUp;
    _status = AppointmentStatus.planned;
    _reminder = ReminderPreset.min30;
    _repeat = RepeatRule.none;
    _priority = AppointmentPriority.medium;
    _allDay = false;
    if (widget.initialDate != null) {
      final d = widget.initialDate!;
      _startAt = DateTime(d.year, d.month, d.day, 9);
      _endAt = DateTime(d.year, d.month, d.day, 10);
    } else {
      _startAt = now.add(const Duration(hours: 1));
      _endAt = now.add(const Duration(hours: 2));
    }
    _hasEndTime = true;
    _hasRepeatUntil = false;
    _customReminderCtrl.text = '45';
    _extraReminders = {};
  }

  void _fillFrom(Appointment a) {
    _titleCtrl.text = a.title;
    _notesCtrl.text = a.notes;
    _locationCtrl.text = a.locationName ?? '';
    _locationDetailsCtrl.text = a.locationDetails ?? '';
    _customReminderCtrl.text = (a.reminderMinutes ?? 45).toString();
    _doctorCtrl.text = a.doctorName ?? '';
    _preparationCtrl.text = a.preparation ?? '';
    _type = a.type;
    _status = a.status;
    _reminder = a.reminderPreset;
    _repeat = a.repeatRule;
    _priority = a.priority;
    _allDay = a.allDay;
    _startAt = a.startAt;
    _endAt = a.endAt;
    _hasEndTime = a.endAt != null;
    _repeatUntil = a.repeatUntil;
    _hasRepeatUntil = a.repeatUntil != null;
    _extraReminders = a.reminderPresets.toSet();
  }

  @override
  void dispose() {
    _titleCtrl.dispose();
    _notesCtrl.dispose();
    _locationCtrl.dispose();
    _locationDetailsCtrl.dispose();
    _customReminderCtrl.dispose();
    _doctorCtrl.dispose();
    _preparationCtrl.dispose();
    super.dispose();
  }

  // ── build ──────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final bottom = MediaQuery.of(context).viewInsets.bottom;

    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: DraggableScrollableSheet(
        initialChildSize: 0.92,
        minChildSize: 0.5,
        maxChildSize: 0.96,
        builder: (ctx, scrollCtrl) => Container(
          decoration: BoxDecoration(
            color: AppColors.background,
            borderRadius: const BorderRadius.vertical(
              top: Radius.circular(AppRadius.xl),
            ),
            boxShadow: [
              BoxShadow(
                color: AppColors.black.withValues(alpha: 0.12),
                blurRadius: 24,
                offset: const Offset(0, -4),
              ),
            ],
          ),
          child: Column(
            children: [
              // ── Handle + title ─────────────────────────────────
              Padding(
                padding: const EdgeInsets.only(top: 10, bottom: 4),
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppColors.grey400,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(
                    horizontal: 20, vertical: 8),
                child: Row(
                  children: [
                    Text(
                      _isEdit ? l.apptEditTitle : l.apptNewTitle,
                      style: Theme.of(context)
                          .textTheme
                          .titleMedium
                          ?.copyWith(fontWeight: FontWeight.w800),
                    ),
                    const Spacer(),
                    PressableScale(
                      onTap: () => Navigator.pop(context),
                      child: Container(
                        width: 32,
                        height: 32,
                        decoration: BoxDecoration(
                          color: AppColors.grey200,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.close_rounded, size: 18),
                      ),
                    ),
                  ],
                ),
              ),
              const Divider(height: 1),

              // ── Scrollable form ────────────────────────────────
              Expanded(
                child: ListView(
                  controller: scrollCtrl,
                  padding: EdgeInsets.fromLTRB(20, 12, 20, 20 + bottom),
                  children: [
                    // Title
                    _buildLabel(l.apptLabelTitleRequired),
                    const SizedBox(height: 4),
                    _GlassTextField(
                      controller: _titleCtrl,
                      hint: l.apptHintTitle,
                      autofocus: !_isEdit,
                    ),

                    const SizedBox(height: 16),

                    // Type chips
                    _buildLabel(l.apptLabelType),
                    const SizedBox(height: 6),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: AppointmentType.values.map((t) {
                        final selected = t == _type;
                        return GestureDetector(
                          onTap: () => setState(() => _type = t),
                          child: AnimatedContainer(
                            duration: MotionDuration.fast,
                            padding: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 8),
                            decoration: BoxDecoration(
                              color: selected
                                  ? t.color.withValues(alpha: 0.18)
                                  : AppColors.white.withValues(alpha: 0.5),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: selected
                                    ? t.color.withValues(alpha: 0.5)
                                    : AppColors.grey300,
                                width: selected ? 1.5 : 0.8,
                              ),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(t.icon,
                                    size: 16,
                                    color:
                                        selected ? t.color : AppColors.grey600),
                                const SizedBox(width: 6),
                                Text(
                                  localizedAppointmentType(l, t),
                                  style: TextStyle(
                                    color: selected
                                        ? t.color
                                        : AppColors.textSecondary,
                                    fontWeight: selected
                                        ? FontWeight.w600
                                        : FontWeight.w500,
                                    fontSize: 13,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      }).toList(),
                    ),

                    const SizedBox(height: 16),

                    // Date row
                    Row(
                      children: [
                        Expanded(
                          child: _TapField(
                            label: l.apptLabelDate,
                            value: _formatDate(_startAt),
                            icon: Icons.calendar_today_rounded,
                            onTap: _pickDate,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _TapField(
                            label: l.apptLabelStartTime,
                            value:
                                _allDay ? l.allDay : _formatTime(_startAt),
                            icon: Icons.access_time_rounded,
                            onTap: _allDay ? null : _pickStartTime,
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 12),

                    // All-day + end time toggles
                    _ToggleRow(
                      label: l.allDay,
                      value: _allDay,
                      onChanged: (v) => setState(() => _allDay = v),
                    ),
                    if (!_allDay)
                      _ToggleRow(
                        label: l.endTimeSet,
                        value: _hasEndTime,
                        onChanged: (v) {
                          setState(() {
                            _hasEndTime = v;
                            _endAt ??= _startAt.add(const Duration(hours: 1));
                          });
                        },
                      ),
                    if (_hasEndTime && !_allDay)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: _TapField(
                          label: l.apptLabelEndTime,
                          value: _formatTime(_endAt ?? _startAt),
                          icon: Icons.access_time_rounded,
                          onTap: _pickEndTime,
                        ),
                      ),

                    const SizedBox(height: 8),

                    // Location
                    _buildLabel(l.apptLabelLocation),
                    const SizedBox(height: 4),
                    _GlassTextField(
                      controller: _locationCtrl,
                      hint: l.apptHintLocation,
                    ),
                    const SizedBox(height: 8),
                    _GlassTextField(
                      controller: _locationDetailsCtrl,
                      hint: l.apptHintLocationDetails,
                    ),

                    const SizedBox(height: 16),

                    // Note
                    _buildLabel(l.apptLabelNote),
                    const SizedBox(height: 4),
                    _GlassTextField(
                      controller: _notesCtrl,
                      hint: l.apptHintNote,
                      maxLines: 4,
                    ),

                    const SizedBox(height: 20),

                    // ── Section: Weitere Details ────────
                    _buildSectionDivider(l.apptLabelFurtherDetails),
                    const SizedBox(height: 12),

                    // Priority chips
                    _buildLabel(l.apptLabelPriority),
                    const SizedBox(height: 6),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: AppointmentPriority.values.map((p) {
                        final selected = p == _priority;
                        return GestureDetector(
                          onTap: () => setState(() => _priority = p),
                          child: AnimatedContainer(
                            duration: MotionDuration.fast,
                            padding: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 8),
                            decoration: BoxDecoration(
                              color: selected
                                  ? p.color.withValues(alpha: 0.18)
                                  : AppColors.white.withValues(alpha: 0.5),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: selected
                                    ? p.color.withValues(alpha: 0.5)
                                    : AppColors.grey300,
                                width: selected ? 1.5 : 0.8,
                              ),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(p.icon,
                                    size: 16,
                                    color:
                                        selected ? p.color : AppColors.grey600),
                                const SizedBox(width: 6),
                                Text(
                                  localizedAppointmentPriority(l, p),
                                  style: TextStyle(
                                    color: selected
                                        ? p.color
                                        : AppColors.textSecondary,
                                    fontWeight: selected
                                        ? FontWeight.w600
                                        : FontWeight.w500,
                                    fontSize: 13,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      }).toList(),
                    ),

                    const SizedBox(height: 16),

                    // Doctor / Behandler
                    _buildLabel(l.apptLabelDoctor),
                    const SizedBox(height: 4),
                    _GlassTextField(
                      controller: _doctorCtrl,
                      hint: l.apptHintDoctor,
                    ),

                    const SizedBox(height: 16),

                    // Preparation
                    _buildLabel(l.onboardingSlide2Title),
                    const SizedBox(height: 4),
                    _GlassTextField(
                      controller: _preparationCtrl,
                      hint: 'z. B. Nüchtern erscheinen, Befunde mitbringen…',
                      maxLines: 3,
                    ),

                    const SizedBox(height: 16),

                    // Reminder
                    _buildLabel(l.apptLabelReminder),
                    const SizedBox(height: 6),
                    _buildDropdown<ReminderPreset>(
                      value: _reminder,
                      items: ReminderPreset.values
                          .map((r) => DropdownMenuItem(
                              value: r, child: Text(localizedReminderPreset(l, r))))
                          .toList(),
                      onChanged: (v) =>
                          setState(() => _reminder = v ?? _reminder),
                    ),
                    if (_reminder == ReminderPreset.custom) ...[
                      const SizedBox(height: 8),
                      _GlassTextField(
                        controller: _customReminderCtrl,
                        hint: l.apptHintCustomMinutes,
                        keyboardType: TextInputType.number,
                      ),
                    ],

                    // Additional reminders (multi-select)
                    const SizedBox(height: 10),
                    _buildLabel(l.apptLabelFurtherReminders),
                    const SizedBox(height: 6),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        ReminderPreset.day1,
                        ReminderPreset.hours2,
                        ReminderPreset.min30,
                      ].map((preset) {
                        final selected = _extraReminders.contains(preset);
                        return GestureDetector(
                          onTap: () {
                            setState(() {
                              if (selected) {
                                _extraReminders.remove(preset);
                              } else {
                                _extraReminders.add(preset);
                              }
                            });
                          },
                          child: AnimatedContainer(
                            duration: MotionDuration.fast,
                            padding: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 8),
                            decoration: BoxDecoration(
                              color: selected
                                  ? AppColors.primary.withValues(alpha: 0.18)
                                  : AppColors.white.withValues(alpha: 0.5),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: selected
                                    ? AppColors.primary.withValues(alpha: 0.5)
                                    : AppColors.grey300,
                                width: selected ? 1.5 : 0.8,
                              ),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  selected
                                      ? Icons.notifications_active_rounded
                                      : Icons.notifications_none_rounded,
                                  size: 16,
                                  color: selected
                                      ? AppColors.primary
                                      : AppColors.grey600,
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  localizedReminderPreset(l, preset),
                                  style: TextStyle(
                                    color: selected
                                        ? AppColors.primary
                                        : AppColors.textSecondary,
                                    fontWeight: selected
                                        ? FontWeight.w600
                                        : FontWeight.w500,
                                    fontSize: 13,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      }).toList(),
                    ),

                    const SizedBox(height: 16),

                    // Repeat
                    _buildLabel(l.repetition),
                    const SizedBox(height: 6),
                    _buildDropdown<RepeatRule>(
                      value: _repeat,
                      items: RepeatRule.values
                          .map((r) => DropdownMenuItem(
                              value: r, child: Text(localizedRepeatRule(l, r))))
                          .toList(),
                      onChanged: (v) {
                        setState(() {
                          _repeat = v ?? _repeat;
                          if (_repeat == RepeatRule.none) {
                            _hasRepeatUntil = false;
                            _repeatUntil = null;
                          }
                        });
                      },
                    ),
                    if (_repeat != RepeatRule.none) ...[
                      _ToggleRow(
                        label: l.repeatUntil,
                        value: _hasRepeatUntil,
                        onChanged: (v) {
                          setState(() {
                            _hasRepeatUntil = v;
                            _repeatUntil ??=
                                _startAt.add(const Duration(days: 30));
                          });
                        },
                      ),
                      if (_hasRepeatUntil)
                        _TapField(
                          label: l.apptLabelRepeatUntil,
                          value: _formatDate(_repeatUntil ?? _startAt),
                          icon: Icons.date_range_rounded,
                          onTap: _pickRepeatUntil,
                        ),
                    ],

                    // Status (edit only)
                    if (_isEdit) ...[
                      const SizedBox(height: 16),
                      _buildLabel(l.status),
                      const SizedBox(height: 6),
                      _buildDropdown<AppointmentStatus>(
                        value: _status,
                        items: AppointmentStatus.values
                            .map((s) => DropdownMenuItem(
                                value: s, child: Text(localizedAppointmentStatus(l, s))))
                            .toList(),
                        onChanged: (v) =>
                            setState(() => _status = v ?? _status),
                      ),
                    ],

                    const SizedBox(height: 28),

                    // Save button
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: FilledButton(
                        onPressed: _saving ? null : _save,
                        style: FilledButton.styleFrom(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                        child: Text(
                          _saving ? l.apptSaving : l.save,
                          style: const TextStyle(
                              fontSize: 16, fontWeight: FontWeight.w700),
                        ),
                      ),
                    ),

                    // Delete button (edit only)
                    if (_isEdit) ...[
                      const SizedBox(height: 10),
                      SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: OutlinedButton(
                          onPressed: _saving ? null : _delete,
                          style: OutlinedButton.styleFrom(
                            foregroundColor: AppColors.error,
                            side: BorderSide(
                              color: AppColors.error.withValues(alpha: 0.4),
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                          ),
                          child: Text(l.apptDeleteTitle,
                            style: TextStyle(
                                fontSize: 16, fontWeight: FontWeight.w600),
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ── tiny helper widgets ────────────────────────────────────────────────────

  Widget _buildLabel(String text) => Align(
        alignment: Alignment.centerLeft,
        child: Text(
          text,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: AppColors.textSecondary,
          ),
        ),
      );

  Widget _buildSectionDivider(String title) => Column(
        children: [
          const Divider(height: 1),
          const SizedBox(height: 10),
          Align(
            alignment: Alignment.centerLeft,
            child: Text(
              title,
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
            ),
          ),
        ],
      );

  Widget _buildDropdown<T>({
    required T value,
    required List<DropdownMenuItem<T>> items,
    required ValueChanged<T?> onChanged,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: AppColors.white.withValues(alpha: 0.55),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.grey300, width: 0.6),
      ),
      child: DropdownButtonFormField<T>(
        initialValue: value,
        items: items,
        onChanged: onChanged,
        decoration: const InputDecoration(
          border: InputBorder.none,
          isDense: true,
          contentPadding: EdgeInsets.symmetric(vertical: 10),
        ),
        style: TextStyle(fontSize: 14, color: AppColors.textPrimary),
        dropdownColor: AppColors.background,
      ),
    );
  }

  // ── pickers ────────────────────────────────────────────────────────────────

  Future<void> _pickDate() async {
    final result = await showDatePicker(
      context: context,
      initialDate: _startAt,
      firstDate: DateTime.now().subtract(const Duration(days: 3650)),
      lastDate: DateTime.now().add(const Duration(days: 3650)),
    );
    if (result == null || !mounted) return;
    setState(() {
      _startAt = DateTime(
          result.year, result.month, result.day, _startAt.hour, _startAt.minute);
      if (_endAt != null) {
        _endAt = DateTime(
            result.year, result.month, result.day, _endAt!.hour, _endAt!.minute);
      }
    });
  }

  Future<void> _pickStartTime() async {
    final result = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(_startAt),
    );
    if (result == null || !mounted) return;
    setState(() {
      _startAt = DateTime(
          _startAt.year, _startAt.month, _startAt.day, result.hour, result.minute);
      if (_endAt != null && _endAt!.isBefore(_startAt)) {
        _endAt = _startAt.add(const Duration(hours: 1));
      }
    });
  }

  Future<void> _pickEndTime() async {
    final baseline = _endAt ?? _startAt.add(const Duration(hours: 1));
    final result = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(baseline),
    );
    if (result == null || !mounted) return;
    setState(() {
      _endAt = DateTime(
          _startAt.year, _startAt.month, _startAt.day, result.hour, result.minute);
    });
  }

  Future<void> _pickRepeatUntil() async {
    final initial = _repeatUntil ?? _startAt;
    final result = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: _startAt,
      lastDate: _startAt.add(const Duration(days: 3650)),
    );
    if (result == null || !mounted) return;
    setState(() => _repeatUntil = result);
  }

  // ── save / delete ──────────────────────────────────────────────────────────

  Future<void> _save() async {
    if (_saving) return;
    final title = _titleCtrl.text.trim();
    if (title.isEmpty) {
      _showError(AppLocalizations.of(context)!.apptTitleRequired);
      return;
    }

    if (!await GuestDataMigrationService.requireAuth(context)) return;
    if (!mounted) return;

    setState(() => _saving = true);
    try {
      final now = DateTime.now();
      final uid = FirebaseAuth.instance.currentUser?.uid;
      if (uid == null) {
        if (mounted) setState(() => _saving = false);
        return;
      }
      final base = widget.initial;
      final normalized = normalizeAllDay(
        startAt: _startAt,
        endAt: (_hasEndTime && !_allDay) ? _endAt : null,
        allDay: _allDay,
      );
      final reminderMin = _reminder == ReminderPreset.custom
          ? int.tryParse(_customReminderCtrl.text.trim())
          : null;

      final appointment = Appointment(
        id: base?.id ?? 'appointment_${now.microsecondsSinceEpoch}',
        ownerId: base?.ownerId ?? uid,
        title: title,
        notes: _notesCtrl.text.trim(),
        type: _type,
        status: _isEdit ? _status : AppointmentStatus.planned,
        startAt: normalized.startAt,
        endAt: normalized.endAt,
        allDay: _allDay,
        locationName: _locationCtrl.text.trim().isEmpty
            ? null
            : _locationCtrl.text.trim(),
        locationDetails: _locationDetailsCtrl.text.trim().isEmpty
            ? null
            : _locationDetailsCtrl.text.trim(),
        reminderPreset: _reminder,
        reminderMinutes: reminderMin,
        reminderPresets: _extraReminders.toList(),
        repeatRule: _repeat,
        repeatUntil:
            (_repeat != RepeatRule.none && _hasRepeatUntil) ? _repeatUntil : null,
        createdAt: base?.createdAt ?? now,
        updatedAt: now,
        metadata: base?.metadata ?? const <String, dynamic>{},
        priority: _priority,
        doctorName: _doctorCtrl.text.trim().isEmpty
            ? null
            : _doctorCtrl.text.trim(),
        preparation: _preparationCtrl.text.trim().isEmpty
            ? null
            : _preparationCtrl.text.trim(),
      );

      final errors = validate(appointment);
      if (errors.isNotEmpty) {
        _showError(errors.join('\n'));
        return;
      }

      await _repository.upsert(appointment);
      if (!mounted) return;
      Navigator.pop(context, appointment);
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

  Future<void> _delete() async {
    final l = AppLocalizations.of(context)!;
    final target = widget.initial;
    if (target == null) return;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l.appointmentDeleteConfirm),
        content: Text(l.unwiderruflichLoeschen(target.title)),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: Text(l.cancel)),
          FilledButton(
              onPressed: () => Navigator.pop(ctx, true),
              style:
                  FilledButton.styleFrom(backgroundColor: AppColors.error),
              child: Text(l.delete)),
        ],
      ),
    );
    if (confirmed != true) return;
    if (!mounted) return;
    setState(() => _saving = true);
    try {
      await _repository.delete(target.id);
      if (!mounted) return;
      Navigator.pop(context, null);
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

  void _showError(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  // ── formatters ─────────────────────────────────────────────────────────────

  String _formatDate(DateTime dt) {
    final dd = dt.day.toString().padLeft(2, '0');
    final mm = dt.month.toString().padLeft(2, '0');
    return '$dd.$mm.${dt.year}';
  }

  String _formatTime(DateTime dt) {
    final hh = dt.hour.toString().padLeft(2, '0');
    final mm = dt.minute.toString().padLeft(2, '0');
    return '$hh:$mm';
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Small helper widgets
// ─────────────────────────────────────────────────────────────────────────────

class _GlassTextField extends StatelessWidget {
  const _GlassTextField({
    required this.controller,
    this.hint,
    this.maxLines = 1,
    this.autofocus = false,
    this.keyboardType,
  });

  final TextEditingController controller;
  final String? hint;
  final int maxLines;
  final bool autofocus;
  final TextInputType? keyboardType;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.white.withValues(alpha: 0.55),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.grey300, width: 0.6),
      ),
      child: TextField(
        controller: controller,
        autofocus: autofocus,
        maxLines: maxLines,
        keyboardType: keyboardType,
        style: const TextStyle(fontSize: 14),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: TextStyle(color: AppColors.textSecondary, fontSize: 13),
          border: InputBorder.none,
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          isDense: true,
        ),
      ),
    );
  }
}

class _TapField extends StatelessWidget {
  const _TapField({
    required this.label,
    required this.value,
    required this.icon,
    this.onTap,
  });

  final String label;
  final String value;
  final IconData icon;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: AppColors.white.withValues(alpha: 0.55),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.grey300, width: 0.6),
        ),
        child: Row(
          children: [
            Icon(icon, size: 18, color: AppColors.primary),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(label,
                      style: TextStyle(
                          fontSize: 11, color: AppColors.textSecondary)),
                  Text(value,
                      style: const TextStyle(
                          fontSize: 14, fontWeight: FontWeight.w600)),
                ],
              ),
            ),
            if (onTap != null)
              Icon(Icons.chevron_right_rounded,
                  size: 18, color: AppColors.grey400),
          ],
        ),
      ),
    );
  }
}

class _ToggleRow extends StatelessWidget {
  const _ToggleRow({
    required this.label,
    required this.value,
    required this.onChanged,
  });

  final String label;
  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Expanded(
            child: Text(label,
                style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
          ),
          Switch.adaptive(value: value, onChanged: onChanged),
        ],
      ),
    );
  }
}
