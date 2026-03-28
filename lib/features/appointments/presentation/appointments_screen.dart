import 'dart:ui';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../../../ui/ui.dart';
import '../../calendar/calendar_service.dart';
import '../data/appointments_repository_sync.dart';
import '../domain/appointment.dart';
import '../domain/appointment_enums.dart';
import '../domain/appointment_utils.dart';
import 'appointment_calendar_view.dart';
import 'appointment_card.dart';
import 'appointment_detail_dialog.dart';
import 'appointment_editor_sheet.dart';
import 'appointment_empty_state.dart';
import 'appointment_filter_bar.dart';
import '../../../ui/theme/app_icons.dart';
import '../../../l10n/app_localizations.dart';

class AppointmentsScreen extends StatefulWidget {
  const AppointmentsScreen({super.key});

  @override
  State<AppointmentsScreen> createState() => _AppointmentsScreenState();
}

class _AppointmentsScreenState extends State<AppointmentsScreen> {
  static final AppointmentsRepositorySync _repository =
      AppointmentsRepositorySync.instance;

  bool _listMode = true;

  // Filter state
  String _query = '';
  Set<AppointmentType> _selectedTypes = {};
  Set<AppointmentStatus> _selectedStatuses = {};

  // Scroll
  final _scrollController = ScrollController();

  // Calendar view key for goToToday
  final _calendarKey = GlobalKey<AppointmentCalendarViewState>();

  // Keep a search controller so we can clear it
  final _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _bootstrap();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _bootstrap() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    await _repository.switchUser(uid);
    try {
      await _repository.pullLatest();
    } catch (e) {
      debugPrint('[AppointmentsScreen] pullLatest failed (offline?): $e');
    }
  }

  // ── build ──────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final bottomPadding = MediaQuery.of(context).padding.bottom;

    return Stack(
      children: [
        GlassPage(
          title: l.tabAppointments,
          titleIcon: AppIcons.appointments,
          titleColor: AppColors.primary,
          trailing: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: _ViewToggle(
              listMode: _listMode,
              onChanged: (v) => setState(() => _listMode = v),
            ),
          ),
          scrollableBody: (headerHeight) => StreamBuilder<List<Appointment>>(
        stream: _repository.watchAll(),
        builder: (context, snapshot) {
          final allItems = snapshot.data ?? const <Appointment>[];
          final filtered = filterAppointments(
            allItems,
            query: _query,
            types: _selectedTypes,
            statuses: _selectedStatuses,
          );

          return Column(
            children: [
              SizedBox(height: headerHeight),

              // ── Filter bar ─────────────────────────────────────
              AppointmentFilterBar(
                query: _query,
                selectedTypes: _selectedTypes,
                selectedStatuses: _selectedStatuses,
                onQueryChanged: (q) => setState(() => _query = q),
                onTypesChanged: (t) => setState(() => _selectedTypes = t),
                onStatusesChanged: (s) =>
                    setState(() => _selectedStatuses = s),
                onTodayTap: _scrollToToday,
              ),

              const Divider(height: 1),

              // ── Content ────────────────────────────────────────
              Expanded(
                child: _listMode
                    ? _buildListView(filtered, allItems.isEmpty)
                    : AppointmentCalendarView(
                        key: _calendarKey,
                        appointments: filtered,
                        onTap: _showDetail,
                        onEdit: _openEditor,
                        onToggleDone: _toggleDone,
                        onCancel: _cancelAppointment,
                        onDelete: _deleteAppointment,
                        onAddForDay: (day) => _openEditor(null, day),
                      ),
              ),
            ],
          );
        },
      ),
    ),

        // ── FAB above the bottom navigation bar ──────────────────
        Positioned(
          left: 16,
          bottom: bottomPadding + 96,
          child: SizedBox(
            width: 64,
            height: 64,
            child: FloatingActionButton(
              heroTag: 'appointments_fab',
              onPressed: () => _openEditor(),
              backgroundColor: AppColors.primary,
              elevation: 6,
              shape: const CircleBorder(),
              child: const Icon(Icons.add_rounded, size: 32, color: Colors.white),
            ),
          ),
        ),
      ],
    );
  }

  // ── list view ──────────────────────────────────────────────────────────────

  Widget _buildListView(List<Appointment> items, bool noDataAtAll) {
    if (items.isEmpty) {
      return AppointmentEmptyState(isFiltered: !noDataAtAll);
    }

    final grouped = _groupByDay(items);

    return ListView.builder(
      controller: _scrollController,
      physics: adaptiveScrollPhysics,
      padding: const EdgeInsets.fromLTRB(0, 4, 0, 120),
      itemCount: _flattenedCount(grouped),
      itemBuilder: (context, index) =>
          _buildFlattenedItem(grouped, index),
    );
  }

  // Flatten grouped map into headers + cards for ListView.builder
  int _flattenedCount(Map<String, List<Appointment>> grouped) {
    var count = 0;
    for (final entry in grouped.entries) {
      count++; // header
      count += entry.value.length;
    }
    return count;
  }

  Widget _buildFlattenedItem(
      Map<String, List<Appointment>> grouped, int index) {
    var cursor = 0;
    for (final entry in grouped.entries) {
      if (cursor == index) {
        return _DaySectionHeader(
          keyDay: entry.key,
          appointments: entry.value,
        );
      }
      cursor++;
      for (var i = 0; i < entry.value.length; i++) {
        if (cursor == index) {
          final appointment = entry.value[i];
          return AppointmentCard(
            appointment: appointment,
            onTap: () => _showDetail(appointment),
            onEdit: () => _openEditor(appointment),
            onToggleDone: () => _toggleDone(appointment),
            onCancel: () => _cancelAppointment(appointment),
            onDelete: () => _deleteAppointment(appointment),
          );
        }
        cursor++;
      }
    }
    return const SizedBox.shrink();
  }

  Map<String, List<Appointment>> _groupByDay(List<Appointment> items) {
    final grouped = <String, List<Appointment>>{};
    for (final item in items) {
      final key = formatDayKey(item.startAt);
      grouped.putIfAbsent(key, () => <Appointment>[]).add(item);
    }
    final sortedKeys = grouped.keys.toList(growable: false)..sort();
    return <String, List<Appointment>>{
      for (final key in sortedKeys) key: grouped[key]!,
    };
  }

  // ── actions ────────────────────────────────────────────────────────────────

  void _showDetail(Appointment appointment) {
    AppointmentDetailDialog.show(
      context,
      appointment: appointment,
      onEdit: () => _openEditor(appointment),
      onConfirm: appointment.status.needsConfirmation
          ? () => _confirmAppointment(appointment)
          : null,
      onDecline: appointment.status.needsConfirmation
          ? () => _declineAppointment(appointment)
          : null,
    );
  }

  Future<void> _openEditor([Appointment? existing, DateTime? initialDate]) async {
    final result = await showAppointmentEditorSheet(
      context,
      appointment: existing,
      initialDate: initialDate,
    );
    if (result != null) {
      // Offer to add to device calendar after creating a new appointment.
      if (existing == null && mounted) {
        CalendarService.showAddToCalendarDialog(context, result);
      }
      await _repository.pullLatest();
    }
  }

  Future<void> _confirmAppointment(Appointment a) async {
    final l = AppLocalizations.of(context)!;
    try {
      await _repository.upsert(
        a.copyWith(status: AppointmentStatus.confirmed, updatedAt: DateTime.now()),
      );
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l.appointmentConfirmed)),
        );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(userFacingError(e))),
      );
    }
  }

  Future<void> _declineAppointment(Appointment a) async {
    try {
      await _repository.upsert(
        a.copyWith(status: AppointmentStatus.declined, updatedAt: DateTime.now()),
      );
      if (mounted) {
        final l = AppLocalizations.of(context)!;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l.appointmentDeclined)),
        );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(userFacingError(e))),
      );
    }
  }

  Future<void> _toggleDone(Appointment a) async {
    final newStatus = (a.status == AppointmentStatus.done || a.status == AppointmentStatus.completed)
        ? AppointmentStatus.planned
        : AppointmentStatus.done;
    try {
      await _repository.upsert(
        a.copyWith(status: newStatus, updatedAt: DateTime.now()),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(userFacingError(e))),
      );
    }
  }

  Future<void> _cancelAppointment(Appointment a) async {
    try {
      await _repository.upsert(
        a.copyWith(
            status: AppointmentStatus.canceled, updatedAt: DateTime.now()),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(userFacingError(e))),
      );
    }
  }

  Future<void> _deleteAppointment(Appointment a) async {
    try {
      await _repository.delete(a.id);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(userFacingError(e))),
      );
    }
  }

  void _scrollToToday() {
    if (!_listMode) {
      _calendarKey.currentState?.goToToday();
      return;
    }
    // In list mode, just scroll to top (today is usually the first section)
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        0,
        duration: MotionDuration.medium,
        curve: MotionCurve.standard,
      );
    }
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// _ViewToggle
// ─────────────────────────────────────────────────────────────────────────────

class _ViewToggle extends StatelessWidget {
  const _ViewToggle({required this.listMode, required this.onChanged});

  final bool listMode;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(3),
      decoration: BoxDecoration(
        color: AppColors.white.withValues(alpha: 0.45),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.glassBorder, width: 0.5),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _TogglePill(
            label: AppLocalizations.of(context)!.apptViewList,
            icon: Icons.view_list_rounded,
            selected: listMode,
            onTap: () => onChanged(true),
          ),
          const SizedBox(width: 2),
          _TogglePill(
            label: AppLocalizations.of(context)!.apptViewCalendar,
            icon: Icons.calendar_month_rounded,
            selected: !listMode,
            onTap: () => onChanged(false),
          ),
        ],
      ),
    );
  }
}

class _TogglePill extends StatelessWidget {
  const _TogglePill({
    required this.label,
    required this.icon,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: MotionDuration.fast,
        curve: MotionCurve.standard,
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: selected
              ? AppColors.primary.withValues(alpha: 0.15)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon,
                size: 14,
                color: selected ? AppColors.primary : AppColors.textSecondary),
            const SizedBox(width: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                color:
                    selected ? AppColors.primary : AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// _DaySectionHeader — sticky / glass-blur section header
// ─────────────────────────────────────────────────────────────────────────────

class _DaySectionHeader extends StatelessWidget {
  const _DaySectionHeader({required this.keyDay, required this.appointments});

  final String keyDay;
  final List<Appointment> appointments;

  @override
  Widget build(BuildContext context) {
    final date = DateTime.tryParse(keyDay) ?? DateTime.now();
    final total = appointments.length;
    final done =
        appointments.where((a) => a.status == AppointmentStatus.done || a.status == AppointmentStatus.completed).length;
    final l = AppLocalizations.of(context)!;
    final label = _humanLabel(l, date);
    final formattedDate = _formatDate(date);

    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final target = DateTime(date.year, date.month, date.day);
    final isToday = target == today;

    return ClipRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
        child: Container(
          padding: const EdgeInsets.fromLTRB(16, 14, 16, 10),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                AppColors.background.withValues(alpha: 0.88),
                AppColors.background.withValues(alpha: 0.72),
              ],
            ),
            border: Border(
              bottom: BorderSide(
                color: AppColors.white.withValues(alpha: 0.3),
                width: 0.5,
              ),
            ),
          ),
          child: Row(
            children: [
              // Day label
              Expanded(
                child: Row(
                  children: [
                    Text(
                      label,
                      style:
                          Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w800,
                        fontSize: 15,
                        letterSpacing: -0.2,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      formattedDate,
                      style: TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 13,
                      ),
                    ),
                    if (isToday) ...[
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 7, vertical: 2),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          l.timelineToday,
                          style: TextStyle(
                            color: AppColors.primary,
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),

              // Done counter chip
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: done == total && total > 0
                      ? AppColors.success.withValues(alpha: 0.12)
                      : AppColors.grey200,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  '$done / $total',
                  style: TextStyle(
                    color: done == total && total > 0
                        ? AppColors.success
                        : AppColors.textSecondary,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _humanLabel(AppLocalizations l, DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final target = DateTime(date.year, date.month, date.day);
    final delta = target.difference(today).inDays;
    if (delta == 0) return l.timelineToday;
    if (delta == 1) return l.timelineTomorrow;
    if (delta == -1) return l.apptYesterday;
    final weekdays = <String>[
      l.timelineMonday,
      l.timelineTuesday,
      l.timelineWednesday,
      l.timelineThursday,
      l.timelineFriday,
      l.timelineSaturday,
      l.timelineSunday,
    ];
    return weekdays[date.weekday - 1];
  }

  String _formatDate(DateTime date) {
    final dd = date.day.toString().padLeft(2, '0');
    final mm = date.month.toString().padLeft(2, '0');
    return '$dd.$mm.${date.year}';
  }
}
