import 'package:flutter/material.dart';

import '../../../ui/ui.dart';
import '../domain/appointment.dart';
import '../domain/appointment_enums.dart';

/// A centred modal dialog showing full read-only details of an [Appointment].
///
/// Includes:
/// - Typ icon + colour accent at the top
/// - Title, date/time, location, notes, reminder, repeat rule
/// - "Bearbeiten" and "Schließen" action buttons
class AppointmentDetailDialog extends StatelessWidget {
  const AppointmentDetailDialog({
    super.key,
    required this.appointment,
    required this.onEdit,
  });

  final Appointment appointment;
  final VoidCallback onEdit;

  /// Show the dialog and return whether the user chose to edit.
  static Future<bool?> show(
    BuildContext context, {
    required Appointment appointment,
    required VoidCallback onEdit,
  }) {
    return showDialog<bool>(
      context: context,
      builder: (_) => AppointmentDetailDialog(
        appointment: appointment,
        onEdit: onEdit,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final typeColor = appointment.type.color;

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 48),
      child: GlassContainer(
        borderRadius: AppRadius.borderRadiusLg,
        variant: GlassVariant.thick,
        elevation: GlassElevation.high,
        padding: EdgeInsets.zero,
        child: ClipRRect(
          borderRadius: AppRadius.borderRadiusLg,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // ── Colour header ────────────────────────────────
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 24),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        typeColor.withValues(alpha: 0.22),
                        typeColor.withValues(alpha: 0.06),
                      ],
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                    ),
                  ),
                  child: Column(
                    children: [
                      Container(
                        width: 54,
                        height: 54,
                        decoration: BoxDecoration(
                          color: typeColor.withValues(alpha: 0.15),
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: typeColor.withValues(alpha: 0.3),
                            width: 1.5,
                          ),
                        ),
                        child: Icon(
                          appointment.type.icon,
                          size: 26,
                          color: typeColor,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: Text(
                          appointment.title,
                          textAlign: TextAlign.center,
                          style: theme.textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.w800,
                            letterSpacing: -0.3,
                          ),
                        ),
                      ),
                      const SizedBox(height: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 3),
                        decoration: BoxDecoration(
                          color: typeColor.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          appointment.type.label,
                          style: TextStyle(
                            color: typeColor,
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                // ── Detail rows ──────────────────────────────────
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
                  child: Column(
                    children: [
                      // Status
                      _DetailRow(
                        icon: appointment.status.icon,
                        iconColor: appointment.status.color,
                        label: 'Status',
                        value: appointment.status.label,
                      ),

                      const Divider(height: 24),

                      // Date + time
                      _DetailRow(
                        icon: Icons.calendar_today_rounded,
                        iconColor: AppColors.primary,
                        label: 'Datum',
                        value: _formatDateLong(appointment.startAt),
                      ),
                      const SizedBox(height: 10),
                      _DetailRow(
                        icon: Icons.access_time_rounded,
                        iconColor: AppColors.primary,
                        label: 'Uhrzeit',
                        value: _timeString,
                      ),

                      // Location
                      if (_hasLocation) ...[
                        const Divider(height: 24),
                        _DetailRow(
                          icon: Icons.location_on_outlined,
                          iconColor: AppColors.accent,
                          label: 'Ort',
                          value: appointment.locationName!.trim(),
                        ),
                        if ((appointment.locationDetails ?? '')
                            .trim()
                            .isNotEmpty)
                          Padding(
                            padding: const EdgeInsets.only(left: 38, top: 4),
                            child: Align(
                              alignment: Alignment.centerLeft,
                              child: Text(
                                appointment.locationDetails!.trim(),
                                style: TextStyle(
                                  color: AppColors.textSecondary,
                                  fontSize: 13,
                                ),
                              ),
                            ),
                          ),
                      ],

                      // Note
                      if (_hasNote) ...[
                        const Divider(height: 24),
                        _DetailRow(
                          icon: Icons.notes_rounded,
                          iconColor: AppColors.grey600,
                          label: 'Notiz',
                          value: appointment.notes.trim(),
                          multiLine: true,
                        ),
                      ],

                      // Reminder
                      if (appointment.reminderPreset != ReminderPreset.none) ...[
                        const Divider(height: 24),
                        _DetailRow(
                          icon: Icons.notifications_active_outlined,
                          iconColor: AppColors.warning,
                          label: 'Erinnerung',
                          value: _reminderString,
                        ),
                      ],

                      // Repeat
                      if (appointment.repeatRule != RepeatRule.none) ...[
                        const Divider(height: 24),
                        _DetailRow(
                          icon: Icons.repeat_rounded,
                          iconColor: AppColors.primaryDark,
                          label: 'Wiederholung',
                          value: _repeatString,
                        ),
                      ],

                      // Priority
                      const Divider(height: 24),
                      _DetailRow(
                        icon: appointment.priority.icon,
                        iconColor: appointment.priority.color,
                        label: 'Priorität',
                        value: appointment.priority.label,
                      ),

                      // Doctor
                      if ((appointment.doctorName ?? '').trim().isNotEmpty) ...[
                        const Divider(height: 24),
                        _DetailRow(
                          icon: Icons.person_outline_rounded,
                          iconColor: AppColors.primary,
                          label: 'Arzt / Behandler',
                          value: appointment.doctorName!.trim(),
                        ),
                      ],

                      // Preparation
                      if ((appointment.preparation ?? '').trim().isNotEmpty) ...[
                        const Divider(height: 24),
                        _DetailRow(
                          icon: Icons.checklist_rounded,
                          iconColor: AppColors.warning,
                          label: 'Vorbereitung',
                          value: appointment.preparation!.trim(),
                          multiLine: true,
                        ),
                      ],
                    ],
                  ),
                ),

                // ── Action buttons ───────────────────────────────
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
                  child: Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () => Navigator.pop(context),
                          child: const Text('Schließen'),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: FilledButton.icon(
                          onPressed: () {
                            Navigator.pop(context);
                            onEdit();
                          },
                          icon: const Icon(Icons.edit_outlined, size: 18),
                          label: const Text('Bearbeiten'),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ── helpers ────────────────────────────────────────────────────────────────

  String get _timeString {
    if (appointment.allDay) return 'Ganztägig';
    final start = _fmtTime(appointment.startAt);
    if (appointment.endAt != null) {
      return '$start – ${_fmtTime(appointment.endAt!)}';
    }
    return start;
  }

  bool get _hasLocation =>
      (appointment.locationName ?? '').trim().isNotEmpty;

  bool get _hasNote => appointment.notes.trim().isNotEmpty;

  String get _reminderString {
    if (appointment.reminderPreset == ReminderPreset.custom) {
      final m = appointment.reminderMinutes ?? 0;
      return '$m Min. vorher';
    }
    return appointment.reminderPreset.label;
  }

  String get _repeatString {
    final base = appointment.repeatRule.label;
    if (appointment.repeatUntil != null) {
      return '$base (bis ${_formatDateShort(appointment.repeatUntil!)})';
    }
    return base;
  }

  static String _fmtTime(DateTime dt) {
    final hh = dt.hour.toString().padLeft(2, '0');
    final mm = dt.minute.toString().padLeft(2, '0');
    return '$hh:$mm';
  }

  static String _formatDateLong(DateTime dt) {
    const weekdays = [
      'Montag', 'Dienstag', 'Mittwoch', 'Donnerstag',
      'Freitag', 'Samstag', 'Sonntag',
    ];
    const months = [
      'Januar', 'Februar', 'März', 'April', 'Mai', 'Juni',
      'Juli', 'August', 'September', 'Oktober', 'November', 'Dezember',
    ];
    return '${weekdays[dt.weekday - 1]}, ${dt.day}. ${months[dt.month - 1]} ${dt.year}';
  }

  static String _formatDateShort(DateTime dt) {
    final dd = dt.day.toString().padLeft(2, '0');
    final mm = dt.month.toString().padLeft(2, '0');
    return '$dd.$mm.${dt.year}';
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// _DetailRow
// ─────────────────────────────────────────────────────────────────────────────

class _DetailRow extends StatelessWidget {
  const _DetailRow({
    required this.icon,
    required this.iconColor,
    required this.label,
    required this.value,
    this.multiLine = false,
  });

  final IconData icon;
  final Color iconColor;
  final String label;
  final String value;
  final bool multiLine;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      crossAxisAlignment:
          multiLine ? CrossAxisAlignment.start : CrossAxisAlignment.center,
      children: [
        Container(
          width: 30,
          height: 30,
          decoration: BoxDecoration(
            color: iconColor.withValues(alpha: 0.10),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, size: 16, color: iconColor),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 1),
              Text(
                value,
                maxLines: multiLine ? 10 : 2,
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
