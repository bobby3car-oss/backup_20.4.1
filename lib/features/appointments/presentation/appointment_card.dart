import 'package:flutter/material.dart';

import '../../../ui/ui.dart';
import '../domain/appointment.dart';
import '../domain/appointment_enums.dart';

/// A premium hero-card for a single [Appointment].
///
/// Features:
/// - Left colour stripe per [AppointmentType]
/// - Status icon (top-right)
/// - Quick-action icons (edit, toggle status)
/// - Swipe-to-done (left) and swipe-to-delete (right)
/// - Long-press context menu
class AppointmentCard extends StatelessWidget {
  const AppointmentCard({
    super.key,
    required this.appointment,
    this.onTap,
    this.onEdit,
    this.onToggleDone,
    this.onCancel,
    this.onDelete,
  });

  final Appointment appointment;
  final VoidCallback? onTap;
  final VoidCallback? onEdit;
  final VoidCallback? onToggleDone;
  final VoidCallback? onCancel;
  final VoidCallback? onDelete;

  // ── build ──────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final typeColor = appointment.type.color;
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 5),
      child: Dismissible(
        key: ValueKey(appointment.id),
        background: _swipeBackground(
          alignment: Alignment.centerLeft,
          color: AppColors.success,
          icon: Icons.check_circle_rounded,
          label: 'Erledigt',
        ),
        secondaryBackground: _swipeBackground(
          alignment: Alignment.centerRight,
          color: AppColors.error,
          icon: Icons.delete_rounded,
          label: 'Löschen',
        ),
        confirmDismiss: (direction) async {
          Haptic.light();
          if (direction == DismissDirection.startToEnd) {
            onToggleDone?.call();
            return false; // don't remove — status change handled externally
          } else {
            return await _confirmDelete(context);
          }
        },
        onDismissed: (_) => onDelete?.call(),
        child: GestureDetector(
          onLongPress: () => _showContextMenu(context),
          child: PressableScale(
            onTap: () {
              Haptic.light();
              onTap?.call();
            },
            child: GlassContainer(
              padding: EdgeInsets.zero,
              borderRadius: AppRadius.borderRadiusMd,
              variant: GlassVariant.thick,
              elevation: GlassElevation.low,
              child: ClipRRect(
                borderRadius: AppRadius.borderRadiusMd,
                child: IntrinsicHeight(
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // ── Colour stripe ──────────────────────
                      Container(width: 4.5, color: typeColor),

                      // ── Content ────────────────────────────
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.fromLTRB(14, 12, 10, 12),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Row 1: title + type badge + status icon
                              Row(
                                children: [
                                  Expanded(
                                    child: Text(
                                      appointment.title,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style:
                                          theme.textTheme.titleSmall?.copyWith(
                                        fontWeight: FontWeight.w700,
                                        letterSpacing: -0.2,
                                        decoration: appointment.status ==
                                                AppointmentStatus.canceled
                                            ? TextDecoration.lineThrough
                                            : null,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  _TypeBadge(type: appointment.type),
                                  const SizedBox(width: 6),
                                  Icon(
                                    appointment.status.icon,
                                    size: 18,
                                    color: appointment.status.color,
                                  ),
                                ],
                              ),

                              const SizedBox(height: 6),

                              // Row 2: date/time + location
                              Row(
                                children: [
                                  Icon(
                                    Icons.access_time_rounded,
                                    size: 14,
                                    color: AppColors.textSecondary,
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    _timeString,
                                    style: theme.textTheme.bodySmall?.copyWith(
                                      color: AppColors.textSecondary,
                                    ),
                                  ),
                                  if (_hasLocation) ...[
                                    const SizedBox(width: 12),
                                    Icon(
                                      Icons.location_on_outlined,
                                      size: 14,
                                      color: AppColors.textSecondary,
                                    ),
                                    const SizedBox(width: 3),
                                    Expanded(
                                      child: Text(
                                        appointment.locationName!.trim(),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: theme.textTheme.bodySmall
                                            ?.copyWith(
                                          color: AppColors.textSecondary,
                                        ),
                                      ),
                                    ),
                                  ] else
                                    const Spacer(),
                                ],
                              ),

                              // Row 3: truncated note (if any)
                              if (_hasNote) ...[
                                const SizedBox(height: 4),
                                Text(
                                  appointment.notes.trim(),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: theme.textTheme.bodySmall?.copyWith(
                                    color: AppColors.textSecondary
                                        .withValues(alpha: 0.7),
                                    fontStyle: FontStyle.italic,
                                  ),
                                ),
                              ],

                              // Row 4: priority + doctor
                              if (appointment.priority !=
                                      AppointmentPriority.medium ||
                                  (appointment.doctorName ?? '')
                                      .trim()
                                      .isNotEmpty) ...[
                                const SizedBox(height: 4),
                                Row(
                                  children: [
                                    if (appointment.priority !=
                                        AppointmentPriority.medium) ...[
                                      Icon(appointment.priority.icon,
                                          size: 14,
                                          color: appointment.priority.color),
                                      const SizedBox(width: 3),
                                      Text(
                                        appointment.priority.label,
                                        style: TextStyle(
                                          fontSize: 12,
                                          fontWeight: FontWeight.w600,
                                          color: appointment.priority.color,
                                        ),
                                      ),
                                      const SizedBox(width: 10),
                                    ],
                                    if ((appointment.doctorName ?? '')
                                        .trim()
                                        .isNotEmpty) ...[
                                      Icon(Icons.person_outline_rounded,
                                          size: 14,
                                          color: AppColors.grey500),
                                      const SizedBox(width: 3),
                                      Expanded(
                                        child: Text(
                                          appointment.doctorName!.trim(),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                          style: TextStyle(
                                            fontSize: 12,
                                            color: AppColors.grey600,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ],
                                ),
                              ],

                              // Pending confirmation banner
                              if (appointment.isFromDoctor &&
                                  appointment.status.needsConfirmation) ...[
                                const SizedBox(height: 6),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 8, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: AppColors.warning.withValues(alpha: 0.12),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(Icons.hourglass_top_rounded,
                                          size: 14, color: AppColors.warning),
                                      const SizedBox(width: 4),
                                      Text(
                                        'Bestätigung ausstehend',
                                        style: TextStyle(
                                          fontSize: 11,
                                          fontWeight: FontWeight.w600,
                                          color: AppColors.warning,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],

                              // Quick-action row
                              const SizedBox(height: 6),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  _QuickActionIcon(
                                    icon: appointment.status ==
                                            AppointmentStatus.done
                                        ? Icons.replay_rounded
                                        : Icons.check_rounded,
                                    tooltip: appointment.status ==
                                            AppointmentStatus.done
                                        ? 'Zurücksetzen'
                                        : 'Erledigt',
                                    color: AppColors.success,
                                    onTap: () {
                                      Haptic.light();
                                      onToggleDone?.call();
                                    },
                                  ),
                                  const SizedBox(width: 4),
                                  _QuickActionIcon(
                                    icon: Icons.edit_outlined,
                                    tooltip: 'Bearbeiten',
                                    color: AppColors.primary,
                                    onTap: () {
                                      Haptic.light();
                                      onEdit?.call();
                                    },
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
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
      final end = _fmtTime(appointment.endAt!);
      return '$start – $end';
    }
    return start;
  }

  bool get _hasLocation =>
      (appointment.locationName ?? '').trim().isNotEmpty;

  bool get _hasNote => appointment.notes.trim().isNotEmpty;

  static String _fmtTime(DateTime dt) {
    final hh = dt.hour.toString().padLeft(2, '0');
    final mm = dt.minute.toString().padLeft(2, '0');
    return '$hh:$mm';
  }

  // ── swipe background ──────────────────────────────────────────────────────

  Widget _swipeBackground({
    required Alignment alignment,
    required Color color,
    required IconData icon,
    required String label,
  }) {
    return Container(
      alignment: alignment,
      margin: const EdgeInsets.symmetric(horizontal: 14, vertical: 5),
      padding: const EdgeInsets.symmetric(horizontal: 20),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: AppRadius.borderRadiusMd,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (alignment == Alignment.centerRight) ...[
            Text(label,
                style: TextStyle(
                    color: color, fontWeight: FontWeight.w600, fontSize: 13)),
            const SizedBox(width: 6),
          ],
          Icon(icon, color: color, size: 22),
          if (alignment == Alignment.centerLeft) ...[
            const SizedBox(width: 6),
            Text(label,
                style: TextStyle(
                    color: color, fontWeight: FontWeight.w600, fontSize: 13)),
          ],
        ],
      ),
    );
  }

  // ── delete confirmation ────────────────────────────────────────────────────

  Future<bool> _confirmDelete(BuildContext context) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Termin löschen?'),
        content: Text(
            'Möchtest du „${appointment.title}" wirklich unwiderruflich löschen?'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('Abbrechen')),
          FilledButton(
              onPressed: () => Navigator.pop(ctx, true),
              style: FilledButton.styleFrom(
                  backgroundColor: AppColors.error),
              child: const Text('Löschen')),
        ],
      ),
    );
    return result ?? false;
  }

  // ── long-press context menu ────────────────────────────────────────────────

  void _showContextMenu(BuildContext context) {
    Haptic.medium();
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) => SafeArea(
        child: Container(
          margin: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: AppColors.background,
            borderRadius: AppRadius.borderRadiusLg,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 8),
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.grey400,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 12),
              Text(
                appointment.title,
                style: Theme.of(context)
                    .textTheme
                    .titleMedium
                    ?.copyWith(fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 8),
              const Divider(height: 1),
              _ContextMenuItem(
                icon: Icons.edit_outlined,
                label: 'Bearbeiten',
                color: AppColors.primary,
                onTap: () {
                  Navigator.pop(ctx);
                  onEdit?.call();
                },
              ),
              _ContextMenuItem(
                icon: appointment.status == AppointmentStatus.done
                    ? Icons.replay_rounded
                    : Icons.check_circle_outline_rounded,
                label: appointment.status == AppointmentStatus.done
                    ? 'Als geplant markieren'
                    : 'Als erledigt markieren',
                color: AppColors.success,
                onTap: () {
                  Navigator.pop(ctx);
                  onToggleDone?.call();
                },
              ),
              if (appointment.status != AppointmentStatus.canceled)
                _ContextMenuItem(
                  icon: Icons.cancel_outlined,
                  label: 'Absagen',
                  color: AppColors.warning,
                  onTap: () {
                    Navigator.pop(ctx);
                    onCancel?.call();
                  },
                ),
              _ContextMenuItem(
                icon: Icons.delete_outline_rounded,
                label: 'Löschen',
                color: AppColors.error,
                onTap: () async {
                  Navigator.pop(ctx);
                  final confirmed = await _confirmDelete(context);
                  if (confirmed) onDelete?.call();
                },
              ),
              const SizedBox(height: 12),
            ],
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// _TypeBadge
// ─────────────────────────────────────────────────────────────────────────────

class _TypeBadge extends StatelessWidget {
  const _TypeBadge({required this.type});

  final AppointmentType type;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: type.tint,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: type.color.withValues(alpha: 0.25), width: 0.5),
      ),
      child: Text(
        type.label,
        style: TextStyle(
          color: type.color,
          fontSize: 11,
          fontWeight: FontWeight.w600,
          letterSpacing: -0.1,
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// _QuickActionIcon
// ─────────────────────────────────────────────────────────────────────────────

class _QuickActionIcon extends StatelessWidget {
  const _QuickActionIcon({
    required this.icon,
    required this.tooltip,
    required this.color,
    required this.onTap,
  });

  final IconData icon;
  final String tooltip;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      child: PressableScale(
        onTap: onTap,
        child: Container(
          width: 30,
          height: 30,
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, size: 16, color: color),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// _ContextMenuItem
// ─────────────────────────────────────────────────────────────────────────────

class _ContextMenuItem extends StatelessWidget {
  const _ContextMenuItem({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon, color: color),
      title: Text(label, style: TextStyle(color: color, fontWeight: FontWeight.w500)),
      onTap: onTap,
    );
  }
}
