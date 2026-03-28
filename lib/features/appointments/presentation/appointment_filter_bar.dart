import 'package:flutter/material.dart';

import '../../../ui/ui.dart';
import '../domain/appointment.dart';
import '../domain/appointment_enums.dart';
import '../domain/appointments_l10n.dart';
import '../../../l10n/app_localizations.dart';

/// Filter bar with search field and horizontal chip rows for type & status.
class AppointmentFilterBar extends StatelessWidget {
  const AppointmentFilterBar({
    super.key,
    required this.query,
    required this.selectedTypes,
    required this.selectedStatuses,
    required this.onQueryChanged,
    required this.onTypesChanged,
    required this.onStatusesChanged,
    required this.onTodayTap,
  });

  final String query;
  final Set<AppointmentType> selectedTypes;
  final Set<AppointmentStatus> selectedStatuses;
  final ValueChanged<String> onQueryChanged;
  final ValueChanged<Set<AppointmentType>> onTypesChanged;
  final ValueChanged<Set<AppointmentStatus>> onStatusesChanged;
  final VoidCallback onTodayTap;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    return Padding(
      padding: const EdgeInsets.fromLTRB(14, 4, 14, 4),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // ── Search row + Today button ──────────────────────────
          Row(
            children: [
              Expanded(
                child: Container(
                  height: 40,
                  decoration: BoxDecoration(
                    color: AppColors.white.withValues(alpha: 0.55),
                    borderRadius: AppRadius.borderRadiusSm,
                    border: Border.all(
                      color: AppColors.glassBorder,
                      width: 0.5,
                    ),
                  ),
                  child: TextField(
                    onChanged: onQueryChanged,
                    style: const TextStyle(fontSize: 14),
                    decoration: InputDecoration(
                      hintText: AppLocalizations.of(context)!.sucheNachTitelOderOrt,
                      hintStyle: TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 13,
                      ),
                      prefixIcon: const Icon(Icons.search_rounded, size: 20),
                      suffixIcon: query.isNotEmpty
                          ? GestureDetector(
                              onTap: () => onQueryChanged(''),
                              child: const Icon(Icons.close_rounded, size: 18),
                            )
                          : null,
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(
                        vertical: 10,
                        horizontal: 0,
                      ),
                      isDense: true,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              PressableScale(
                onTap: () {
                  Haptic.light();
                  onTodayTap();
                },
                child: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.12),
                    borderRadius: AppRadius.borderRadiusSm,
                    border: Border.all(
                      color: AppColors.primary.withValues(alpha: 0.3),
                      width: 0.5,
                    ),
                  ),
                  child: const Icon(
                    Icons.today_rounded,
                    size: 20,
                    color: AppColors.primary,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 8),

          // ── Type chips ─────────────────────────────────────────
          SizedBox(
            height: 34,
            child: ListView(
              scrollDirection: Axis.horizontal,
              children: [
                for (final type in AppointmentType.values) ...[
                  _FilterChip(
                    label: localizedAppointmentType(l, type),
                    color: type.color,
                    icon: type.icon,
                    selected: selectedTypes.contains(type),
                    onTap: () {
                      final copy = Set<AppointmentType>.from(selectedTypes);
                      copy.contains(type) ? copy.remove(type) : copy.add(type);
                      onTypesChanged(copy);
                    },
                  ),
                  const SizedBox(width: 6),
                ],
              ],
            ),
          ),

          const SizedBox(height: 6),

          // ── Status chips ───────────────────────────────────────
          SizedBox(
            height: 34,
            child: ListView(
              scrollDirection: Axis.horizontal,
              children: [
                for (final status in AppointmentStatus.values) ...[
                  _FilterChip(
                    label: localizedAppointmentStatus(l, status),
                    color: status.color,
                    icon: status.icon,
                    selected: selectedStatuses.contains(status),
                    onTap: () {
                      final copy =
                          Set<AppointmentStatus>.from(selectedStatuses);
                      copy.contains(status)
                          ? copy.remove(status)
                          : copy.add(status);
                      onStatusesChanged(copy);
                    },
                  ),
                  const SizedBox(width: 6),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Pure filter function — no UI dependency
// ─────────────────────────────────────────────────────────────────────────────

/// Filter a list of appointments by [query], [types], and [statuses].
/// Returns a new list; does not mutate the input.
List<Appointment> filterAppointments(
  List<Appointment> source, {
  String query = '',
  Set<AppointmentType> types = const {},
  Set<AppointmentStatus> statuses = const {},
}) {
  var result = source;

  if (types.isNotEmpty) {
    result = result.where((a) => types.contains(a.type)).toList();
  }

  if (statuses.isNotEmpty) {
    result = result.where((a) => statuses.contains(a.status)).toList();
  }

  final q = query.trim().toLowerCase();
  if (q.isNotEmpty) {
    result = result.where((a) {
      final titleMatch = a.title.toLowerCase().contains(q);
      final locationMatch =
          (a.locationName ?? '').toLowerCase().contains(q);
      return titleMatch || locationMatch;
    }).toList();
  }

  return result;
}

// ─────────────────────────────────────────────────────────────────────────────
// _FilterChip
// ─────────────────────────────────────────────────────────────────────────────

class _FilterChip extends StatelessWidget {
  const _FilterChip({
    required this.label,
    required this.color,
    required this.icon,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final Color color;
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
          color: selected ? color.withValues(alpha: 0.18) : AppColors.white.withValues(alpha: 0.45),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: selected ? color.withValues(alpha: 0.5) : AppColors.grey300,
            width: selected ? 1.2 : 0.6,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 14, color: selected ? color : AppColors.textSecondary),
            const SizedBox(width: 4),
            Text(
              label,
              style: TextStyle(
                color: selected ? color : AppColors.textSecondary,
                fontSize: 12,
                fontWeight: selected ? FontWeight.w600 : FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
