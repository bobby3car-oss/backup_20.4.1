import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../../../features/appointments/domain/appointment.dart';
import '../../../features/appointments/domain/appointment_enums.dart';
import '../../../ui/ui.dart';
import '../../doctor_patients/data/doctor_patient_repository.dart';
import '../../doctor_patients/domain/linked_patient.dart';
import '../data/doctor_event_repository.dart';
import '../../../l10n/app_localizations.dart';

import '../domain/doctor_event.dart';

/// View modes for the calendar tab.
enum _CalendarViewMode { weekView, dayView, monthView }

/// Calendar tab showing doctor-created patient appointments and
/// practice-internal events.
/// Supports month, week, and day views, plus create / edit / delete.
class DoctorCalendarTab extends StatefulWidget {
  const DoctorCalendarTab({super.key, this.doctorUid});

  /// Doctor UID override for staff mode.
  final String? doctorUid;

  @override
  State<DoctorCalendarTab> createState() => _DoctorCalendarTabState();
}

class _DoctorCalendarTabState extends State<DoctorCalendarTab> {
  late final DoctorPatientRepository _repo;
  late final DoctorEventRepository _eventRepo;
  DateTime _selectedDate = DateTime.now();
  _CalendarViewMode _viewMode = _CalendarViewMode.weekView;

  // Data
  List<PatientAppointment> _appointments = [];
  List<DoctorEvent> _events = [];
  Map<DateTime, int> _monthCounts = {};
  Map<DateTime, List<_CalendarEntry>> _weekEntries = {};
  bool _loadingAppointments = true;

  @override
  void initState() {
    super.initState();
    _repo = DoctorPatientRepository(overrideDoctorUid: widget.doctorUid);
    _eventRepo = DoctorEventRepository(overrideDoctorUid: widget.doctorUid);
    _refreshAppointments();
    _refreshMonthCounts();
  }

  Future<void> _refreshAppointments() async {
    if (!mounted) return;
    setState(() => _loadingAppointments = true);
    try {
      final apptsFuture = _repo.getAppointmentsForDate(_selectedDate);
      final eventsFuture = _eventRepo.getEventsForDate(_selectedDate);
      final appts = await apptsFuture;
      final events = await eventsFuture;
      if (mounted) {
        setState(() {
          _appointments = appts;
          _events = events;
          _loadingAppointments = false;
        });
      }
    } catch (_) {
      if (mounted) setState(() => _loadingAppointments = false);
    }
  }

  Future<void> _refreshMonthCounts() async {
    try {
      final apptCountsFuture = _repo.getMonthAppointmentCounts(
          _selectedDate.year, _selectedDate.month);
      final eventCountsFuture = _eventRepo.getMonthEventCounts(
          _selectedDate.year, _selectedDate.month);
      final apptCounts = await apptCountsFuture;
      final eventCounts = await eventCountsFuture;
      if (mounted) {
        final merged = <DateTime, int>{...apptCounts};
        for (final entry in eventCounts.entries) {
          merged[entry.key] = (merged[entry.key] ?? 0) + entry.value;
        }
        setState(() => _monthCounts = merged);
      }
    } catch (_) {}
  }

  Future<void> _refreshWeekEntries() async {
    final startOfWeek =
        _selectedDate.subtract(Duration(days: _selectedDate.weekday - 1));
    final entries = <DateTime, List<_CalendarEntry>>{};

    final futures = List.generate(7, (i) async {
      final day = startOfWeek.add(Duration(days: i));
      final dayKey = DateTime(day.year, day.month, day.day);
      final appts = await _repo.getAppointmentsForDate(day);
      final events = await _eventRepo.getEventsForDate(day);

      final dayEntries = <_CalendarEntry>[];
      for (final a in appts) {
        dayEntries.add(_CalendarEntry(
          startAt: a.appointment.startAt,
          appointment: a,
        ));
      }
      for (final e in events) {
        dayEntries.add(_CalendarEntry(startAt: e.startAt, event: e));
      }
      dayEntries.sort((a, b) => a.startAt.compareTo(b.startAt));
      entries[dayKey] = dayEntries;
    });

    await Future.wait(futures);
    if (mounted) setState(() => _weekEntries = entries);
  }

  void _selectDate(DateTime date) {
    Haptic.selection();
    final monthChanged = date.month != _selectedDate.month ||
        date.year != _selectedDate.year;
    setState(() => _selectedDate = date);
    _refreshAppointments();
    if (monthChanged) _refreshMonthCounts();
    if (_viewMode == _CalendarViewMode.weekView) _refreshWeekEntries();
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
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
                    if (Navigator.of(context).canPop())
                      Padding(
                        padding: const EdgeInsets.only(right: AppSpacing.sm),
                        child: IconButton(
                          onPressed: () => Navigator.of(context).pop(),
                          icon: const Icon(Icons.arrow_back_ios_rounded, size: 20),
                        ),
                      ),
                    Text(
                      l.calendarTitle,
                      style: theme.textTheme.headlineSmall
                          ?.copyWith(fontWeight: FontWeight.bold),
                    ),
                    const Spacer(),
                    // View mode toggle (week → day → month → week)
                    PressableScale(
                      onTap: () {
                        Haptic.light();
                        setState(() {
                          switch (_viewMode) {
                            case _CalendarViewMode.weekView:
                              _viewMode = _CalendarViewMode.dayView;
                            case _CalendarViewMode.dayView:
                              _viewMode = _CalendarViewMode.monthView;
                            case _CalendarViewMode.monthView:
                              _viewMode = _CalendarViewMode.weekView;
                          }
                        });
                        if (_viewMode == _CalendarViewMode.weekView) {
                          _refreshWeekEntries();
                        }
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
                              switch (_viewMode) {
                                _CalendarViewMode.weekView =>
                                  Icons.view_day_rounded,
                                _CalendarViewMode.dayView =>
                                  Icons.calendar_view_month_rounded,
                                _CalendarViewMode.monthView =>
                                  Icons.view_week_rounded,
                              },
                              size: 16,
                              color: AppColors.primary,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              switch (_viewMode) {
                                _CalendarViewMode.weekView => l.calendarDay,
                                _CalendarViewMode.dayView =>
                                  l.calendarMonth,
                                _CalendarViewMode.monthView =>
                                  l.calendarWeek,
                              },
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
                      tooltip: l.appointmentCreate,
                      onPressed: () => _showAddMenu(context),
                    ),
                  ],
                ),
              ),

              // ── Month name ───────────────────────────────────
              _MonthHeader(
                date: _selectedDate,
                onPrev: () => _selectDate(
                  switch (_viewMode) {
                    _CalendarViewMode.monthView => DateTime(
                        _selectedDate.year,
                        _selectedDate.month - 1,
                        _selectedDate.day),
                    _CalendarViewMode.weekView =>
                      _selectedDate.subtract(const Duration(days: 7)),
                    _CalendarViewMode.dayView =>
                      _selectedDate.subtract(const Duration(days: 1)),
                  },
                ),
                onNext: () => _selectDate(
                  switch (_viewMode) {
                    _CalendarViewMode.monthView => DateTime(
                        _selectedDate.year,
                        _selectedDate.month + 1,
                        _selectedDate.day),
                    _CalendarViewMode.weekView =>
                      _selectedDate.add(const Duration(days: 7)),
                    _CalendarViewMode.dayView =>
                      _selectedDate.add(const Duration(days: 1)),
                  },
                ),
                onToday: () => _selectDate(DateTime.now()),
              ),

              const SizedBox(height: AppSpacing.xs),

              // ── Calendar view ──────────────────────────────────
              Expanded(
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    final isDesktop = constraints.maxWidth >= 900;

                    // Desktop day / week views
                    if (isDesktop &&
                        _viewMode == _CalendarViewMode.dayView) {
                      return _buildDesktopDayView(l);
                    }
                    if (isDesktop &&
                        _viewMode == _CalendarViewMode.weekView) {
                      return _buildDesktopWeekView(l);
                    }

                    // Mobile (all modes) or desktop month view
                    return Column(
                      children: [
                        if (_viewMode == _CalendarViewMode.monthView)
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
                        Expanded(
                          child: _loadingAppointments
                              ? const Center(
                                  child: CircularProgressIndicator())
                              : _buildEntryList(l),
                        ),
                      ],
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

  // ── Desktop day view (hour grid) ──────────────────────────────

  static const _kStartHour = 6;
  static const _kEndHour = 22;
  static const _kHourHeight = 60.0;
  static const _kTotalHeight = (_kEndHour - _kStartHour) * _kHourHeight;

  Widget _buildDesktopDayView(AppLocalizations l) {
    final entries = <_CalendarEntry>[];
    for (final a in _appointments) {
      entries.add(_CalendarEntry(
        startAt: a.appointment.startAt,
        appointment: a,
      ));
    }
    for (final e in _events) {
      entries.add(_CalendarEntry(startAt: e.startAt, event: e));
    }

    if (_loadingAppointments) {
      return const Center(child: CircularProgressIndicator());
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
      child: SizedBox(
        height: _kTotalHeight,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Time labels
            SizedBox(
              width: 56,
              height: _kTotalHeight,
              child: Stack(
                children: List.generate(
                  _kEndHour - _kStartHour + 1,
                  (i) {
                    final hour = _kStartHour + i;
                    return Positioned(
                      top: i * _kHourHeight - 6,
                      left: 0,
                      right: 0,
                      child: Text(
                        '${hour.toString().padLeft(2, '0')}:00',
                        style: TextStyle(
                          fontSize: 11,
                          color: AppColors.textSecondary,
                        ),
                        textAlign: TextAlign.right,
                      ),
                    );
                  },
                ),
              ),
            ),
            const SizedBox(width: 8),
            // Grid + appointments
            Expanded(
              child: Stack(
                children: [
                  _buildHourGridLines(),
                  _buildNowIndicator(),
                  ...entries.map((e) => _buildPositionedBlock(e)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Desktop week view (7 columns) ──────────────────────────────

  Widget _buildDesktopWeekView(AppLocalizations l) {
    final startOfWeek =
        _selectedDate.subtract(Duration(days: _selectedDate.weekday - 1));
    final days =
        List.generate(7, (i) => startOfWeek.add(Duration(days: i)));
    final weekdays = [l.weekdayShortMon, l.weekdayShortTue, l.weekdayShortWed, l.weekdayShortThu, l.weekdayShortFri, l.weekdayShortSat, l.weekdayShortSun];
    final today = DateTime.now();

    return Column(
      children: [
        // Day headers
        Padding(
          padding: const EdgeInsets.only(left: 64),
          child: Row(
            children: days.asMap().entries.map((e) {
              final i = e.key;
              final day = e.value;
              final isToday = _isSameDay(day, today);
              final isSelected = _isSameDay(day, _selectedDate);
              return Expanded(
                child: GestureDetector(
                  onTap: () => _selectDate(day),
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? AppColors.primary.withValues(alpha: 0.1)
                          : null,
                      borderRadius: AppRadius.borderRadiusSm,
                    ),
                    child: Column(
                      children: [
                        Text(
                          weekdays[i],
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w500,
                            color: AppColors.textSecondary,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Container(
                          width: 28,
                          height: 28,
                          decoration: BoxDecoration(
                            color:
                                isToday ? AppColors.primary : null,
                            shape: BoxShape.circle,
                          ),
                          alignment: Alignment.center,
                          child: Text(
                            '${day.day}',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: isToday || isSelected
                                  ? FontWeight.bold
                                  : FontWeight.w400,
                              color: isToday
                                  ? AppColors.white
                                  : AppColors.textPrimary,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }).toList(growable: false),
          ),
        ),
        const Divider(height: 1),
        // Scrollable hour grid
        Expanded(
          child: SingleChildScrollView(
            child: SizedBox(
              height: _kTotalHeight,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Time labels
                  SizedBox(
                    width: 56,
                    height: _kTotalHeight,
                    child: Stack(
                      children: List.generate(
                        _kEndHour - _kStartHour + 1,
                        (i) {
                          final hour = _kStartHour + i;
                          return Positioned(
                            top: i * _kHourHeight - 6,
                            left: 0,
                            right: 0,
                            child: Text(
                              '${hour.toString().padLeft(2, '0')}:00',
                              style: TextStyle(
                                fontSize: 11,
                                color: AppColors.textSecondary,
                              ),
                              textAlign: TextAlign.right,
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  // 7 day columns
                  ...days.map((day) {
                    final dayKey =
                        DateTime(day.year, day.month, day.day);
                    final dayEntries = _weekEntries[dayKey] ?? [];
                    return Expanded(
                      child: Container(
                        decoration: BoxDecoration(
                          border: Border(
                            left: BorderSide(
                              color: AppColors.grey200,
                              width: 0.5,
                            ),
                          ),
                        ),
                        child: Stack(
                          children: [
                            _buildHourGridLines(),
                            if (_isSameDay(day, today))
                              _buildNowIndicator(),
                            ...dayEntries.map(
                                (e) => _buildPositionedBlock(e)),
                          ],
                        ),
                      ),
                    );
                  }),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  // ── Shared hour-grid helpers ───────────────────────────────────

  Widget _buildHourGridLines() {
    return SizedBox(
      height: _kTotalHeight,
      child: Stack(
        children: List.generate(
          (_kEndHour - _kStartHour) * 2 + 1,
          (i) {
            final isHourLine = i.isEven;
            return Positioned(
              top: i * (_kHourHeight / 2),
              left: 0,
              right: 0,
              child: Container(
                height: 1,
                color: isHourLine
                    ? AppColors.grey300
                    : AppColors.grey200,
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildNowIndicator() {
    final now = DateTime.now();
    if (!_isSameDay(now, _selectedDate) &&
        _viewMode != _CalendarViewMode.weekView) {
      return const SizedBox.shrink();
    }
    final minutes = (now.hour - _kStartHour) * 60 + now.minute;
    if (minutes < 0 || minutes > (_kEndHour - _kStartHour) * 60) {
      return const SizedBox.shrink();
    }
    final top = minutes * _kHourHeight / 60;
    return Positioned(
      top: top,
      left: 0,
      right: 0,
      child: Row(
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: const BoxDecoration(
              color: AppColors.error,
              shape: BoxShape.circle,
            ),
          ),
          Expanded(
            child: Container(height: 1.5, color: AppColors.error),
          ),
        ],
      ),
    );
  }

  Widget _buildPositionedBlock(_CalendarEntry entry) {
    final l = AppLocalizations.of(context)!;
    final start = entry.startAt;
    final startMinutes = (start.hour - _kStartHour) * 60 + start.minute;
    if (startMinutes < 0) return const SizedBox.shrink();
    final top = startMinutes * _kHourHeight / 60;

    Duration duration;
    if (entry.appointment != null) {
      final endAt = entry.appointment!.appointment.endAt;
      duration = endAt != null
          ? endAt.difference(start)
          : const Duration(minutes: 30);
    } else {
      final endAt = entry.event!.endAt;
      duration = endAt != null
          ? endAt.difference(start)
          : const Duration(minutes: 30);
    }

    final height =
        (duration.inMinutes * _kHourHeight / 60).clamp(15.0, 240.0);

    final color = entry.appointment != null
        ? entry.appointment!.appointment.type.color
        : AppColors.accent;
    final title = entry.appointment != null
        ? entry.appointment!.appointment.title
        : entry.event!.title;
    final subtitle = entry.appointment != null
        ? entry.appointment!.patient.displayName
        : l.practiceAppointment;

    return Positioned(
      top: top,
      left: 2,
      right: 2,
      height: height,
      child: GestureDetector(
        onTap: () {
          if (entry.appointment != null) {
            _showAppointmentSheet(context, existing: entry.appointment!);
          } else {
            _showEventSheet(context, existing: entry.event!);
          }
        },
        child: Container(
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.15),
            border: Border(
              left: BorderSide(color: color, width: 3),
            ),
            borderRadius: AppRadius.borderRadiusSm,
          ),
          padding: const EdgeInsets.symmetric(
              horizontal: 8, vertical: 4),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: color,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              if (height > 30)
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 10,
                    color: AppColors.textSecondary,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
            ],
          ),
        ),
      ),
    );
  }

  bool _isSameDay(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;

  // ── Merged entry list ──────────────────────────────────────────

  /// A unified entry is either a PatientAppointment or a DoctorEvent.
  Widget _buildEntryList(AppLocalizations l) {
    // Build sort-able entries: (startAt, isEvent, index)
    final entries = <_CalendarEntry>[];
    for (var i = 0; i < _appointments.length; i++) {
      entries.add(_CalendarEntry(
        startAt: _appointments[i].appointment.startAt,
        appointment: _appointments[i],
      ));
    }
    for (var i = 0; i < _events.length; i++) {
      entries.add(_CalendarEntry(
        startAt: _events[i].startAt,
        event: _events[i],
      ));
    }
    entries.sort((a, b) => a.startAt.compareTo(b.startAt));

    if (entries.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.event_available_rounded,
                size: 48, color: AppColors.grey400),
            const SizedBox(height: AppSpacing.md),
            Text(
              l.calendarNoEvents,
              style: TextStyle(color: AppColors.textSecondary),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.xl,
        vertical: AppSpacing.sm,
      ),
      itemCount: entries.length,
      itemBuilder: (context, index) {
        final entry = entries[index];
        if (entry.appointment != null) {
          return FadeSlideIn(
            delay: Duration(milliseconds: 40 * index),
            child: _AppointmentCard(
              pa: entry.appointment!,
              onEdit: () => _showAppointmentSheet(
                context,
                existing: entry.appointment!,
              ),
              onDelete: () => _confirmDelete(entry.appointment!),
            ),
          );
        }
        return FadeSlideIn(
          delay: Duration(milliseconds: 40 * index),
          child: _DoctorEventCard(
            event: entry.event!,
            onEdit: () => _showEventSheet(context, existing: entry.event!),
            onDelete: () => _confirmDeleteEvent(entry.event!),
          ),
        );
      },
    );
  }

  // ── Add menu ──────────────────────────────────────────────────

  void _showAddMenu(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.background,
      shape: const RoundedRectangleBorder(
        borderRadius:
            BorderRadius.vertical(top: Radius.circular(AppRadius.xl)),
      ),
      builder: (ctx) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.xl),
          child: Column(
            mainAxisSize: MainAxisSize.min,
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
                l.appointmentCreate,
                style: Theme.of(ctx).textTheme.titleLarge,
              ),
              const SizedBox(height: AppSpacing.lg),
              ListTile(
                leading: CircleAvatar(
                  backgroundColor: AppColors.primary.withValues(alpha: 0.1),
                  child: const Icon(Icons.person_rounded,
                      color: AppColors.primary),
                ),
                title: Text(l.patientAppointment),
                subtitle: Text(l.appointmentForPatient('')),
                onTap: () {
                  Navigator.pop(ctx);
                  _showAppointmentSheet(context);
                },
              ),
              const SizedBox(height: AppSpacing.sm),
              ListTile(
                leading: CircleAvatar(
                  backgroundColor:
                      AppColors.accent.withValues(alpha: 0.1),
                  child: const Icon(Icons.business_rounded,
                      color: AppColors.accent),
                ),
                title: Text(l.practiceAppointment),
                subtitle: Text(l.practiceAppointmentOwn),
                onTap: () {
                  Navigator.pop(ctx);
                  _showEventSheet(context);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ── Patient appointment sheet ─────────────────────────────────

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

  // ── Doctor event sheet ────────────────────────────────────────

  void _showEventSheet(BuildContext context, {DoctorEvent? existing}) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.background,
      shape: const RoundedRectangleBorder(
        borderRadius:
            BorderRadius.vertical(top: Radius.circular(AppRadius.xl)),
      ),
      builder: (_) => _DoctorEventFormSheet(
        repository: _eventRepo,
        existing: existing,
        initialDate: _selectedDate,
        onSaved: () {
          _refreshAppointments();
          _refreshMonthCounts();
        },
      ),
    );
  }

  // ── Delete confirmations ──────────────────────────────────────

  void _confirmDelete(PatientAppointment pa) {
    final l = AppLocalizations.of(context)!;
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l.appointmentDeleteConfirm),
        content: Text(
          l.appointmentDeleteMessage(pa.appointment.title, pa.patient.displayName),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(l.cancel),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: AppColors.error,
            ),
            onPressed: () async {
              Navigator.pop(ctx);
              try {
                await _repo.deleteAppointmentForPatient(
                    pa.patient.uid, pa.appointment.id);
              } catch (e) {
                debugPrint('Error deleting appointment: $e');
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(l.appointmentDeleteError)),
                  );
                }
              }
              _refreshAppointments();
              _refreshMonthCounts();
            },
            child: Text(l.delete),
          ),
        ],
      ),
    );
  }

  void _confirmDeleteEvent(DoctorEvent event) {
    final l = AppLocalizations.of(context)!;
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l.practiceAppointmentDeleteConfirm),
        content: Text(
          l.eventDeleteMessage(event.title),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(l.cancel),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: AppColors.error,
            ),
            onPressed: () async {
              Navigator.pop(ctx);
              try {
                await _eventRepo.deleteEvent(event.id);
              } catch (e) {
                debugPrint('Error deleting event: $e');
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(l.appointmentDeleteError)),
                  );
                }
              }
              _refreshAppointments();
              _refreshMonthCounts();
            },
            child: Text(l.delete),
          ),
        ],
      ),
    );
  }
}

// ── Calendar entry wrapper ─────────────────────────────────────────────

class _CalendarEntry {
  const _CalendarEntry({
    required this.startAt,
    this.appointment,
    this.event,
  });

  final DateTime startAt;
  final PatientAppointment? appointment;
  final DoctorEvent? event;
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

  static List<String> _months(AppLocalizations l) => [
    l.monthJanuary, l.monthFebruary, l.monthMarch, l.monthApril, l.monthMay, l.monthJune,
    l.monthJuly, l.monthAugust, l.monthSeptember, l.monthOctober, l.monthNovember, l.monthDecember,
  ];

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
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
                '${_months(l)[date.month - 1]} ${date.year}',
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

  static List<String> _weekdays(AppLocalizations l) => [l.weekdayShortMon, l.weekdayShortTue, l.weekdayShortWed, l.weekdayShortThu, l.weekdayShortFri, l.weekdayShortSat, l.weekdayShortSun];

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
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
                      _weekdays(l)[day.weekday - 1],
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

  static List<String> _weekdays(AppLocalizations l) => [l.weekdayShortMon, l.weekdayShortTue, l.weekdayShortWed, l.weekdayShortThu, l.weekdayShortFri, l.weekdayShortSat, l.weekdayShortSun];

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
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
            children: _weekdays(l)
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
        // Use the effective doctor UID so that staff-created appointments
        // are attributed to the doctor and appear in filtered queries.
        final creatorUid = widget.repository.overrideDoctorUid ??
            FirebaseAuth.instance.currentUser?.uid ??
            '';
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
          createdBy: creatorUid,
        );
        await widget.repository
            .createAppointmentForPatient(patient.uid, appointment);
      }
      widget.onSaved();
      if (mounted) Navigator.pop(context);
    } catch (e) {
      if (kDebugMode) debugPrint('[DoctorCalendarTab] error: $e');
      if (mounted) {
        final l = AppLocalizations.of(context)!;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text(l.appointmentSaveError)),
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
    try {
      await widget.repository
          .deleteAppointmentForPatient(pa.patient.uid, pa.appointment.id);
    } catch (e) {
      debugPrint('[DoctorCalendarTab] _delete failed: $e');
      return;
    }
    widget.onSaved();
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
                      _isEditing ? l.appointmentEdit : l.appointmentCreate,
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                  ),
                  if (_isEditing)
                    IconButton(
                      icon:
                          const Icon(Icons.delete_rounded, color: AppColors.error),
                      tooltip: l.delete,
                      onPressed: () {
                        showDialog(
                          context: context,
                          builder: (ctx) => AlertDialog(
                            title: Text(l.appointmentDeleteConfirm),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.pop(ctx),
                                child: Text(l.cancel),
                              ),
                              FilledButton(
                                style: FilledButton.styleFrom(
                                    backgroundColor: AppColors.error),
                                onPressed: () {
                                  Navigator.pop(ctx);
                                  _delete();
                                },
                                child: Text(l.delete),
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
                      InputDecoration(labelText: l.patientAuswaehlen),
                ),

              const SizedBox(height: AppSpacing.md),

              TextField(
                controller: _titleController,
                decoration: InputDecoration(labelText: l.title),
              ),

              const SizedBox(height: AppSpacing.md),

              TextField(
                controller: _notesController,
                decoration: InputDecoration(labelText: l.notes),
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
                decoration: InputDecoration(labelText: l.type),
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
                    ? l.saving
                    : _isEditing
                        ? l.aenderungenSpeichern
                        : l.appointmentCreate),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Doctor Event Card ──────────────────────────────────────────────────────

class _DoctorEventCard extends StatelessWidget {
  const _DoctorEventCard({
    required this.event,
    required this.onEdit,
    required this.onDelete,
  });

  final DoctorEvent event;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final time =
        '${event.startAt.hour.toString().padLeft(2, '0')}:${event.startAt.minute.toString().padLeft(2, '0')}';

    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: Dismissible(
        key: ValueKey(event.id),
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
          return false;
        },
        child: GlassCard(
          onTap: onEdit,
          child: Row(
            children: [
              // Colored indicator — secondary color for practice events
              Container(
                width: 4,
                height: 48,
                decoration: BoxDecoration(
                  color: AppColors.accent,
                  borderRadius: AppRadius.borderRadiusPill,
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              // Time badge
              Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.accent.withValues(alpha: 0.1),
                  borderRadius: AppRadius.borderRadiusSm,
                ),
                child: Text(
                  time,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: AppColors.accent,
                  ),
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      event.title,
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
                          l.practiceAppointment,
                          style: TextStyle(
                            fontSize: 12,
                            color: AppColors.accent,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        if (event.notes.isNotEmpty) ...[
                          Text(
                            '  •  ',
                            style: TextStyle(
                                fontSize: 12,
                                color: AppColors.textSecondary),
                          ),
                          Flexible(
                            child: Text(
                              event.notes,
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
              const Icon(Icons.business_rounded,
                  size: 18, color: AppColors.accent),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Create / Edit doctor event sheet ───────────────────────────────────────

class _DoctorEventFormSheet extends StatefulWidget {
  const _DoctorEventFormSheet({
    required this.repository,
    this.existing,
    required this.initialDate,
    required this.onSaved,
  });

  final DoctorEventRepository repository;
  final DoctorEvent? existing;
  final DateTime initialDate;
  final VoidCallback onSaved;

  @override
  State<_DoctorEventFormSheet> createState() => _DoctorEventFormSheetState();
}

class _DoctorEventFormSheetState extends State<_DoctorEventFormSheet> {
  final _titleController = TextEditingController();
  final _notesController = TextEditingController();
  late DateTime _startAt;
  bool _busy = false;

  bool get _isEditing => widget.existing != null;

  @override
  void initState() {
    super.initState();
    if (_isEditing) {
      final e = widget.existing!;
      _titleController.text = e.title;
      _notesController.text = e.notes;
      _startAt = e.startAt;
    } else {
      _startAt = DateTime(
        widget.initialDate.year,
        widget.initialDate.month,
        widget.initialDate.day,
        DateTime.now().hour + 1,
      );
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final title = _titleController.text.trim();
    if (title.isEmpty) return;

    setState(() => _busy = true);
    try {
      final now = DateTime.now();
      if (_isEditing) {
        final updated = widget.existing!.copyWith(
          title: title,
          notes: _notesController.text.trim(),
          startAt: _startAt,
          updatedAt: now,
        );
        await widget.repository.updateEvent(updated);
      } else {
        final event = DoctorEvent(
          id: 'evt_${now.millisecondsSinceEpoch}',
          title: title,
          notes: _notesController.text.trim(),
          startAt: _startAt,
          createdAt: now,
          updatedAt: now,
        );
        await widget.repository.createEvent(event);
      }
      widget.onSaved();
      if (mounted) Navigator.pop(context);
    } catch (e) {
      if (kDebugMode) debugPrint('[DoctorEventForm] error: $e');
      if (mounted) {
        final l = AppLocalizations.of(context)!;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content:
                  Text(l.practiceAppointmentSaveError)),
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
                      _isEditing
                          ? l.practiceAppointmentEdit
                          : l.practiceAppointmentCreate,
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                  ),
                  if (_isEditing)
                    IconButton(
                      icon: const Icon(Icons.delete_rounded,
                          color: AppColors.error),
                      tooltip: l.delete,
                      onPressed: () {
                        showDialog(
                          context: context,
                          builder: (ctx) => AlertDialog(
                            title: Text(l.practiceAppointmentDeleteConfirm),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.pop(ctx),
                                child: Text(l.cancel),
                              ),
                              FilledButton(
                                style: FilledButton.styleFrom(
                                    backgroundColor: AppColors.error),
                                onPressed: () async {
                                  Navigator.pop(ctx);
                                  Navigator.pop(context);
                                  try {
                                    await widget.repository
                                        .deleteEvent(widget.existing!.id);
                                  } catch (e) {
                                    debugPrint('Error deleting event: $e');
                                  }
                                  widget.onSaved();
                                },
                                child: Text(l.delete),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                ],
              ),
              const SizedBox(height: AppSpacing.lg),

              TextField(
                controller: _titleController,
                decoration: InputDecoration(labelText: l.title),
              ),

              const SizedBox(height: AppSpacing.md),

              TextField(
                controller: _notesController,
                decoration: InputDecoration(labelText: l.notes),
                maxLines: 2,
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
                    ? l.saving
                    : _isEditing
                        ? l.aenderungenSpeichern
                        : l.practiceAppointmentCreate),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
