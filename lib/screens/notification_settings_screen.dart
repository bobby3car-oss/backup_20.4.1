import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../notifications/notification_preferences.dart';
import '../notifications/notification_repository.dart';
import '../ui/ui.dart';
import 'notification_center_screen.dart';

// ── Category metadata ────────────────────────────────────────────────────────

class _Category {
  const _Category({
    required this.label,
    required this.subtitle,
    required this.icon,
    required this.color,
    required this.getter,
    required this.setter,
  });

  final String label;
  final String subtitle;
  final IconData icon;
  final Color color;
  final bool Function(NotificationPreferences) getter;
  final void Function(NotificationPreferences, bool) setter;
}

final _categories = <_Category>[
  _Category(
    label: 'Aufgaben & Timeline',
    subtitle: 'Fällige und erledigte Aufgaben',
    icon: Icons.checklist_rounded,
    color: AppColors.primary,
    getter: (p) => p.taskReminders,
    setter: (p, v) => p.setTaskReminders(v),
  ),
  _Category(
    label: 'Termine',
    subtitle: 'Bevorstehende Arzt- und Kliniktermine',
    icon: Icons.calendar_month_rounded,
    color: AppColors.accent,
    getter: (p) => p.appointmentReminders,
    setter: (p, v) => p.setAppointmentReminders(v),
  ),
  _Category(
    label: 'Medikamente',
    subtitle: 'Erinnerungen an Medikamenteneinnahme',
    icon: Icons.medication_rounded,
    color: AppColors.warning,
    getter: (p) => p.medicationReminders,
    setter: (p, v) => p.setMedicationReminders(v),
  ),
  _Category(
    label: 'Wundalarme',
    subtitle: 'Warnungen bei kritischen Wundkontroll-Ergebnissen',
    icon: Icons.healing_rounded,
    color: AppColors.error,
    getter: (p) => p.woundWarnings,
    setter: (p, v) => p.setWoundWarnings(v),
  ),
  _Category(
    label: 'Beobachtungen',
    subtitle: 'Neue Beobachtungen von Ärzten & Begleitern',
    icon: Icons.visibility_rounded,
    color: AppColors.success,
    getter: (p) => p.observations,
    setter: (p, v) => p.setObservations(v),
  ),
  _Category(
    label: 'System',
    subtitle: 'Updates, Pro-Status & App-Hinweise',
    icon: Icons.info_outline_rounded,
    color: AppColors.grey500,
    getter: (p) => p.systemNotifications,
    setter: (p, v) => p.setSystemNotifications(v),
  ),
];

// ─────────────────────────────────────────────────────────────────────────────

class NotificationSettingsScreen extends StatefulWidget {
  const NotificationSettingsScreen({super.key});

  @override
  State<NotificationSettingsScreen> createState() =>
      _NotificationSettingsScreenState();
}

class _NotificationSettingsScreenState
    extends State<NotificationSettingsScreen> {
  final _prefs = NotificationPreferences.instance;

  @override
  void initState() {
    super.initState();
    _prefs.addListener(_onPrefsChanged);
  }

  @override
  void dispose() {
    _prefs.removeListener(_onPrefsChanged);
    super.dispose();
  }

  void _onPrefsChanged() {
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return GlassPage(
      title: 'Benachrichtigungen',
      titleEmoji: '🔔',
      titleColor: AppColors.warning,
      children: [
        // ── Global toggle ──
        _GlobalToggleCard(
          enabled: _prefs.globalEnabled,
          activeCount: _prefs.enabledCount,
          totalCount: NotificationPreferences.totalCategories,
          onChanged: (v) {
            if (v) {
              _prefs.enableAll();
            } else {
              _prefs.setGlobalEnabled(false);
            }
          },
        ),
        const SizedBox(height: AppSpacing.xxl),

        // ── Quick link to notification center ──
        PressableScale(
          onTap: () {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) => const NotificationCenterScreen(),
              ),
            );
          },
          child: GlassContainer(
            padding: const EdgeInsets.all(AppSpacing.lg),
            borderRadius: AppRadius.borderRadiusLg,
            child: Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.10),
                    borderRadius: AppRadius.borderRadiusMd,
                  ),
                  child: StreamBuilder<int>(
                    stream: NotificationRepository.instance.watchUnreadCount(),
                    builder: (context, snapshot) {
                      final count = snapshot.data ?? 0;
                      return Stack(
                        clipBehavior: Clip.none,
                        children: [
                          const Center(
                            child: Icon(Icons.inbox_rounded,
                                size: 20, color: AppColors.primary),
                          ),
                          if (count > 0)
                            Positioned(
                              top: -4,
                              right: -4,
                              child: Container(
                                width: 16,
                                height: 16,
                                decoration: const BoxDecoration(
                                  color: AppColors.error,
                                  shape: BoxShape.circle,
                                ),
                                child: Center(
                                  child: Text(
                                    count > 9 ? '9+' : '$count',
                                    style: const TextStyle(
                                      fontSize: 9,
                                      fontWeight: FontWeight.w700,
                                      color: AppColors.white,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                        ],
                      );
                    },
                  ),
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Benachrichtigungszentrale',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      Text(
                        'Alle Benachrichtigungen anzeigen',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ],
                  ),
                ),
                const Icon(Icons.chevron_right_rounded,
                    color: AppColors.grey400),
              ],
            ),
          ),
        ),
        const SizedBox(height: AppSpacing.xxl),

        // ── Category toggles ──
        Padding(
          padding: const EdgeInsets.only(
            left: AppSpacing.xs,
            bottom: AppSpacing.md,
          ),
          child: Text(
            'Kategorien',
            style: Theme.of(context).textTheme.titleLarge,
          ),
        ),

        GlassContainer(
          padding: const EdgeInsets.symmetric(vertical: AppSpacing.xs),
          borderRadius: AppRadius.borderRadiusXl,
          child: Column(
            children: [
              for (var i = 0; i < _categories.length; i++) ...[
                _CategoryRow(
                  category: _categories[i],
                  enabled: _categories[i].getter(_prefs),
                  onToggle: (v) => _categories[i].setter(_prefs, v),
                ),
                if (i < _categories.length - 1)
                  Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.lg),
                    child: Container(height: 1, color: AppColors.grey200),
                  ),
              ],
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.xxl),
      ],
    );
  }
}

// ── Global toggle card ───────────────────────────────────────────────────────

class _GlobalToggleCard extends StatelessWidget {
  const _GlobalToggleCard({
    required this.enabled,
    required this.activeCount,
    required this.totalCount,
    required this.onChanged,
  });

  final bool enabled;
  final int activeCount;
  final int totalCount;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return GlassContainer(
      padding: const EdgeInsets.all(AppSpacing.xl),
      borderRadius: AppRadius.borderRadiusXl,
      child: Row(
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: (enabled ? AppColors.primary : AppColors.grey400)
                  .withValues(alpha: 0.12),
              borderRadius: AppRadius.borderRadiusLg,
            ),
            child: Icon(
              enabled
                  ? Icons.notifications_active_rounded
                  : Icons.notifications_off_rounded,
              size: 26,
              color: enabled ? AppColors.primary : AppColors.grey400,
            ),
          ),
          const SizedBox(width: AppSpacing.lg),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  enabled ? 'Benachrichtigungen aktiv' : 'Alle deaktiviert',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  '$activeCount von $totalCount Kategorien aktiv',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
          ),
          CupertinoSwitch(
            value: enabled,
            activeTrackColor: AppColors.primary,
            onChanged: onChanged,
          ),
        ],
      ),
    );
  }
}

// ── Category row ─────────────────────────────────────────────────────────────

class _CategoryRow extends StatelessWidget {
  const _CategoryRow({
    required this.category,
    required this.enabled,
    required this.onToggle,
  });

  final _Category category;
  final bool enabled;
  final ValueChanged<bool> onToggle;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.lg,
        vertical: AppSpacing.md,
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: (enabled ? category.color : AppColors.grey300)
                  .withValues(alpha: 0.12),
              borderRadius: AppRadius.borderRadiusMd,
            ),
            child: Icon(
              category.icon,
              size: 20,
              color: enabled ? category.color : AppColors.grey400,
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  category.label,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color:
                        enabled ? AppColors.textPrimary : AppColors.grey400,
                  ),
                ),
                const SizedBox(height: AppSpacing.xxs),
                Text(
                  category.subtitle,
                  style: TextStyle(
                    fontSize: 12,
                    color:
                        enabled ? AppColors.textSecondary : AppColors.grey300,
                  ),
                ),
              ],
            ),
          ),
          CupertinoSwitch(
            value: enabled,
            activeTrackColor: category.color,
            onChanged: onToggle,
          ),
        ],
      ),
    );
  }
}
