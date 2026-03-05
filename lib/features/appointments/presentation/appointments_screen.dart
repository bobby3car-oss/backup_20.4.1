import 'package:flutter/material.dart';

import '../../../ui/ui.dart';
import '../data/appointments_repository_sync.dart';
import '../domain/appointment.dart';
import '../domain/appointment_enums.dart';
import '../domain/appointment_utils.dart';
import 'appointment_editor_screen.dart';
import 'appointment_tile.dart';

class AppointmentsScreen extends StatefulWidget {
  const AppointmentsScreen({super.key});

  @override
  State<AppointmentsScreen> createState() => _AppointmentsScreenState();
}

class _AppointmentsScreenState extends State<AppointmentsScreen> {
  static final AppointmentsRepositorySync _repository =
      AppointmentsRepositorySync.instance;
  bool _listMode = true;

  @override
  void initState() {
    super.initState();
    _bootstrap();
  }

  Future<void> _bootstrap() async {
    await _repository.loadFromDisk();
    await _repository.seedDemoIfEmpty();
    await _repository.pullLatest();
  }

  @override
  Widget build(BuildContext context) {
    return GlassPage(
      title: 'Termine',
      titleEmoji: '📅',
      titleColor: AppColors.primary,
      trailing: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8),
        child: ToggleButtons(
          isSelected: <bool>[_listMode, !_listMode],
          onPressed: (index) {
            setState(() => _listMode = index == 0);
          },
          borderRadius: BorderRadius.circular(10),
          constraints: const BoxConstraints(minHeight: 34, minWidth: 70),
          children: const [Text('Liste'), Text('Kalender')],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _openEditor,
        icon: const Icon(Icons.add),
        label: const Text('Neu'),
      ),
      scrollableBody: (headerHeight) => _listMode
          ? StreamBuilder<List<Appointment>>(
              stream: _repository.watchAll(),
              builder: (context, snapshot) {
                final items = snapshot.data ?? const <Appointment>[];
                final grouped = _groupByDay(items);
                if (grouped.isEmpty) {
                  return Center(
                    child: Padding(
                      padding: EdgeInsets.only(top: headerHeight + 40),
                      child: const Text('Noch keine Termine.'),
                    ),
                  );
                }

                return ListView(
                  physics: adaptiveScrollPhysics,
                  padding: EdgeInsets.fromLTRB(0, headerHeight, 0, 100),
                  children: [
                    for (final entry in grouped.entries) ...[
                      _DaySectionHeader(
                        keyDay: entry.key,
                        appointments: entry.value,
                      ),
                      for (final appointment in entry.value)
                        AppointmentTile(
                          appointment: appointment,
                          onTap: () => _openEditor(existing: appointment),
                        ),
                    ],
                  ],
                );
              },
            )
          : Padding(
              padding: EdgeInsets.only(top: headerHeight),
              child: const Center(
                child: Text('Kalenderansicht kommt als naechstes.'),
              ),
            ),
    );
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

  Future<void> _openEditor({Appointment? existing}) async {
    final changed = await Navigator.of(context).push<bool>(
      MaterialPageRoute<bool>(
        builder: (_) => AppointmentEditorScreen(initialAppointment: existing),
      ),
    );
    if (changed == true) {
      await _repository.pullLatest();
    }
  }
}

class _DaySectionHeader extends StatelessWidget {
  const _DaySectionHeader({required this.keyDay, required this.appointments});

  final String keyDay;
  final List<Appointment> appointments;

  @override
  Widget build(BuildContext context) {
    final date = DateTime.tryParse(keyDay) ?? DateTime.now();
    final total = appointments.length;
    final done = appointments
        .where((a) => a.status == AppointmentStatus.done)
        .length;
    final label = _humanLabel(date);

    return Padding(
      padding: const EdgeInsets.fromLTRB(14, 18, 14, 6),
      child: Row(
        children: [
          Expanded(
            child: Text(
              '$label, ${_formatDate(date)}',
              style: Theme.of(context).textTheme.titleSmall,
            ),
          ),
          Text('$done/$total', style: Theme.of(context).textTheme.bodySmall),
        ],
      ),
    );
  }

  String _humanLabel(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final target = DateTime(date.year, date.month, date.day);
    final delta = target.difference(today).inDays;
    if (delta == 0) return 'Heute';
    if (delta == 1) return 'Morgen';
    const weekdays = <String>[
      'Montag',
      'Dienstag',
      'Mittwoch',
      'Donnerstag',
      'Freitag',
      'Samstag',
      'Sonntag',
    ];
    return weekdays[date.weekday - 1];
  }

  String _formatDate(DateTime date) {
    final dd = date.day.toString().padLeft(2, '0');
    final mm = date.month.toString().padLeft(2, '0');
    return '$dd.$mm.${date.year}';
  }
}
