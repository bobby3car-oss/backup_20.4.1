import 'package:flutter/material.dart';

import '../domain/appointment.dart';
import '../domain/appointment_enums.dart';
import '../../../l10n/app_localizations.dart';

class AppointmentTile extends StatelessWidget {
  const AppointmentTile({super.key, required this.appointment, this.onTap});

  final Appointment appointment;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final statusColor = switch (appointment.status) {
      AppointmentStatus.planned => Colors.blueAccent,
      AppointmentStatus.pending => Colors.orange,
      AppointmentStatus.confirmed => Colors.green,
      AppointmentStatus.declined => Colors.grey,
      AppointmentStatus.done => Colors.green,
      AppointmentStatus.canceled => Colors.redAccent,
      AppointmentStatus.completed => Colors.green,
    };

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      child: ListTile(
        onTap: onTap,
        leading: SizedBox(
          width: 72,
          child: Text(
            appointment.allDay ? l.allDay : _formatTime(appointment.startAt),
            textAlign: TextAlign.left,
            style: Theme.of(
              context,
            ).textTheme.bodySmall?.copyWith(fontWeight: FontWeight.w700),
          ),
        ),
        title: Row(
          children: [
            Expanded(
              child: Text(
                appointment.title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const SizedBox(width: 8),
            _TypeBadge(type: appointment.type),
          ],
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if ((appointment.locationName ?? '').trim().isNotEmpty)
              Text(appointment.locationName!.trim()),
            Row(
              children: [
                Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: statusColor,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 6),
                Text(_statusLabel(appointment.status)),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _formatTime(DateTime value) {
    final hh = value.hour.toString().padLeft(2, '0');
    final mm = value.minute.toString().padLeft(2, '0');
    return '$hh:$mm';
  }

  String _statusLabel(AppointmentStatus status) {
    return switch (status) {
      AppointmentStatus.planned => 'Geplant',
      AppointmentStatus.pending => 'Ausstehend',
      AppointmentStatus.confirmed => 'Bestätigt',
      AppointmentStatus.declined => 'Abgelehnt',
      AppointmentStatus.done => 'Erledigt',
      AppointmentStatus.canceled => 'Abgesagt',
      AppointmentStatus.completed => 'Abgeschlossen',
    };
  }
}

class _TypeBadge extends StatelessWidget {
  const _TypeBadge({required this.type});

  final AppointmentType type;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(_label(type), style: Theme.of(context).textTheme.labelSmall),
    );
  }

  String _label(AppointmentType value) {
    return switch (value) {
      AppointmentType.followUp => 'Nachsorge',
      AppointmentType.physio => 'Physio',
      AppointmentType.surgery => 'OP',
      AppointmentType.call => 'Telefon',
      AppointmentType.imaging => 'Bildgebung',
      AppointmentType.other => 'Sonstiges',
    };
  }
}
