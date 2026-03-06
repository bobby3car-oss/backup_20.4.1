import 'package:flutter/material.dart';

import '../../../ui/ui.dart';
import '../domain/appointment.dart';
import '../domain/appointment_enums.dart';
import '../domain/appointment_utils.dart';
import 'appointment_card.dart';
import 'appointment_empty_state.dart';

/// iOS-style calendar view: collapsible month grid on top, day appointment list
/// on the bottom. No external packages — pure Flutter.
class AppointmentCalendarView extends StatefulWidget {
  const AppointmentCalendarView({
    super.key,
    required this.appointments,
    this.onTap,
    this.onEdit,
    this.onToggleDone,
    this.onCancel,
    this.onDelete,
    this.onAddForDay,
  });

  final List<Appointment> appointments;
  final void Function(Appointment)? onTap;
  final void Function(Appointment)? onEdit;
  final void Function(Appointment)? onToggleDone;
  final void Function(Appointment)? onCancel;
  final void Function(Appointment)? onDelete;
  final void Function(DateTime day)? onAddForDay;

  @override
  State<AppointmentCalendarView> createState() =>
      AppointmentCalendarViewState();
}

class AppointmentCalendarViewState extends State<AppointmentCalendarView> {
  late DateTime _focusedMonth;
  late DateTime _selectedDay;
  bool _monthExpanded = true;

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _focusedMonth = DateTime(now.year, now.month);
    _selectedDay = DateTime(now.year, now.month, now.day);
  }

  /// Jump to today.
  void goToToday() {
    final now = DateTime.now();
    setState(() {
      _focusedMonth = DateTime(now.year, now.month);
      _selectedDay = DateTime(now.year, now.month, now.day);
    });
  }

  // ── appointment lookup helpers ─────────────────────────────────────────────

  /// Map of day-key → list of appointments for current month.
  Map<String, List<Appointment>> get _monthMap {
    final map = <String, List<Appointment>>{};
    for (final a in widget.appointments) {
      final key = formatDayKey(a.startAt);
      map.putIfAbsent(key, () => []).add(a);
    }
    return map;
  }

  List<Appointment> _appointmentsForDay(DateTime day) {
    final key = formatDayKey(day);
    return _monthMap[key] ?? const [];
  }

  // ── build ──────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final dayAppointments = _appointmentsForDay(_selectedDay);

    return Column(
      children: [
        // ── Month header ─────────────────────────────────────────
        _MonthHeader(
          month: _focusedMonth,
          expanded: _monthExpanded,
          onToggle: () => setState(() => _monthExpanded = !_monthExpanded),
          onPrevious: _previousMonth,
          onNext: _nextMonth,
        ),

        // ── Month grid ───────────────────────────────────────────
        AnimatedCrossFade(
          duration: MotionDuration.medium,
          crossFadeState: _monthExpanded
              ? CrossFadeState.showFirst
              : CrossFadeState.showSecond,
          firstChild: _MonthGrid(
            month: _focusedMonth,
            selectedDay: _selectedDay,
            appointmentMap: _monthMap,
            onDaySelected: (day) => setState(() => _selectedDay = day),
          ),
          secondChild: const SizedBox(height: 4),
        ),

        const Divider(height: 1),

        // ── Selected day label ───────────────────────────────────
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 10, 16, 4),
          child: Row(
            children: [
              Text(
                _dayLabel(_selectedDay),
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
              const Spacer(),
              Text(
                '${dayAppointments.length} Termin${dayAppointments.length == 1 ? '' : 'e'}',
                style: TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),

        // ── Day appointment list ─────────────────────────────────
        Expanded(
          child: dayAppointments.isEmpty
              ? AppointmentEmptyState(
                  isFiltered: true,
                  onAdd: widget.onAddForDay != null
                      ? () => widget.onAddForDay!(_selectedDay)
                      : null,
                )
              : ListView.builder(
                  physics: adaptiveScrollPhysics,
                  padding: const EdgeInsets.only(bottom: 100),
                  itemCount: dayAppointments.length,
                  itemBuilder: (_, i) {
                    final a = dayAppointments[i];
                    return AppointmentCard(
                      appointment: a,
                      onTap: () => widget.onTap?.call(a),
                      onEdit: () => widget.onEdit?.call(a),
                      onToggleDone: () => widget.onToggleDone?.call(a),
                      onCancel: () => widget.onCancel?.call(a),
                      onDelete: () => widget.onDelete?.call(a),
                    );
                  },
                ),
        ),
      ],
    );
  }

  void _previousMonth() {
    setState(() {
      _focusedMonth = DateTime(
        _focusedMonth.year,
        _focusedMonth.month - 1,
      );
    });
  }

  void _nextMonth() {
    setState(() {
      _focusedMonth = DateTime(
        _focusedMonth.year,
        _focusedMonth.month + 1,
      );
    });
  }

  static String _dayLabel(DateTime day) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final target = DateTime(day.year, day.month, day.day);
    final delta = target.difference(today).inDays;

    const weekdays = [
      'Montag', 'Dienstag', 'Mittwoch', 'Donnerstag',
      'Freitag', 'Samstag', 'Sonntag',
    ];

    String prefix;
    if (delta == 0) {
      prefix = 'Heute';
    } else if (delta == 1) {
      prefix = 'Morgen';
    } else if (delta == -1) {
      prefix = 'Gestern';
    } else {
      prefix = weekdays[day.weekday - 1];
    }

    final dd = day.day.toString().padLeft(2, '0');
    final mm = day.month.toString().padLeft(2, '0');
    return '$prefix, $dd.$mm.${day.year}';
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// _MonthHeader
// ─────────────────────────────────────────────────────────────────────────────

class _MonthHeader extends StatelessWidget {
  const _MonthHeader({
    required this.month,
    required this.expanded,
    required this.onToggle,
    required this.onPrevious,
    required this.onNext,
  });

  final DateTime month;
  final bool expanded;
  final VoidCallback onToggle;
  final VoidCallback onPrevious;
  final VoidCallback onNext;

  @override
  Widget build(BuildContext context) {
    const months = [
      'Januar', 'Februar', 'März', 'April', 'Mai', 'Juni',
      'Juli', 'August', 'September', 'Oktober', 'November', 'Dezember',
    ];

    return Padding(
      padding: const EdgeInsets.fromLTRB(6, 4, 6, 0),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.chevron_left_rounded),
            onPressed: onPrevious,
            visualDensity: VisualDensity.compact,
          ),
          Expanded(
            child: GestureDetector(
              onTap: onToggle,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    '${months[month.month - 1]} ${month.year}',
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(width: 4),
                  AnimatedRotation(
                    turns: expanded ? 0 : -0.25,
                    duration: MotionDuration.fast,
                    child: const Icon(
                      Icons.keyboard_arrow_down_rounded,
                      size: 20,
                    ),
                  ),
                ],
              ),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.chevron_right_rounded),
            onPressed: onNext,
            visualDensity: VisualDensity.compact,
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// _MonthGrid
// ─────────────────────────────────────────────────────────────────────────────

class _MonthGrid extends StatelessWidget {
  const _MonthGrid({
    required this.month,
    required this.selectedDay,
    required this.appointmentMap,
    required this.onDaySelected,
  });

  final DateTime month;
  final DateTime selectedDay;
  final Map<String, List<Appointment>> appointmentMap;
  final ValueChanged<DateTime> onDaySelected;

  @override
  Widget build(BuildContext context) {
    final firstDayOfMonth = DateTime(month.year, month.month, 1);
    final daysInMonth = DateUtils.getDaysInMonth(month.year, month.month);

    // Monday = 1, Sunday = 7 → offset so that Mo is column 0
    final startWeekday = (firstDayOfMonth.weekday - 1) % 7;

    const dayLabels = ['Mo', 'Di', 'Mi', 'Do', 'Fr', 'Sa', 'So'];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Weekday labels
          Row(
            children: [
              for (final label in dayLabels)
                Expanded(
                  child: Center(
                    child: Text(
                      label,
                      style: TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 4),

          // Day cells
          ..._buildWeeks(startWeekday, daysInMonth, context),
        ],
      ),
    );
  }

  List<Widget> _buildWeeks(
    int startWeekday,
    int daysInMonth,
    BuildContext context,
  ) {
    final weeks = <Widget>[];
    var day = 1;
    final totalCells = startWeekday + daysInMonth;
    final rowCount = (totalCells / 7).ceil();

    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final selNorm = DateTime(selectedDay.year, selectedDay.month, selectedDay.day);

    for (var week = 0; week < rowCount; week++) {
      final cells = <Widget>[];
      for (var col = 0; col < 7; col++) {
        final index = week * 7 + col;
        if (index < startWeekday || day > daysInMonth) {
          cells.add(const Expanded(child: SizedBox(height: 40)));
          continue;
        }

        final date = DateTime(month.year, month.month, day);
        final dateNorm = DateTime(date.year, date.month, date.day);
        final key = formatDayKey(date);
        final appointments = appointmentMap[key] ?? const [];
        final isToday = dateNorm == today;
        final isSelected = dateNorm == selNorm;

        cells.add(
          Expanded(
            child: GestureDetector(
              onTap: () => onDaySelected(date),
              child: _DayCell(
                day: day,
                isToday: isToday,
                isSelected: isSelected,
                dotColors: appointments
                    .take(3)
                    .map((a) => a.type.color)
                    .toList(),
              ),
            ),
          ),
        );
        day++;
      }
      weeks.add(
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 1),
          child: Row(children: cells),
        ),
      );
    }
    return weeks;
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// _DayCell
// ─────────────────────────────────────────────────────────────────────────────

class _DayCell extends StatelessWidget {
  const _DayCell({
    required this.day,
    required this.isToday,
    required this.isSelected,
    required this.dotColors,
  });

  final int day;
  final bool isToday;
  final bool isSelected;
  final List<Color> dotColors;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 40,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 30,
            height: 30,
            decoration: BoxDecoration(
              color: isSelected
                  ? AppColors.primary
                  : isToday
                      ? AppColors.primary.withValues(alpha: 0.12)
                      : Colors.transparent,
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                '$day',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight:
                      (isToday || isSelected) ? FontWeight.w700 : FontWeight.w500,
                  color: isSelected
                      ? Colors.white
                      : isToday
                          ? AppColors.primary
                          : AppColors.textPrimary,
                ),
              ),
            ),
          ),
          // Appointment indicator dots
          if (dotColors.isNotEmpty)
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                for (var i = 0; i < dotColors.length; i++) ...[
                  if (i > 0) const SizedBox(width: 2),
                  Container(
                    width: 4,
                    height: 4,
                    decoration: BoxDecoration(
                      color: isSelected ? AppColors.primary.withValues(alpha: 0.5) : dotColors[i],
                      shape: BoxShape.circle,
                    ),
                  ),
                ],
              ],
            )
          else
            const SizedBox(height: 4),
        ],
      ),
    );
  }
}
