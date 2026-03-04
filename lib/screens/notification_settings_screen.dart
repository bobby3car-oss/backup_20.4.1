import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../ui/ui.dart';

// ── Data models ──────────────────────────────────────────────────────────────

enum _ReminderCategory { medication, fasting, appointment, repeating }

extension on _ReminderCategory {
  String get label => switch (this) {
        _ReminderCategory.medication => 'Medikamente',
        _ReminderCategory.fasting => 'Nüchternheit',
        _ReminderCategory.appointment => 'Termine',
        _ReminderCategory.repeating => 'Wiederholend',
      };

  String get subtitle => switch (this) {
        _ReminderCategory.medication =>
          'Erinnerungen an Medikamenteneinnahme',
        _ReminderCategory.fasting =>
          'Nüchtern-Phasen vor Operationen',
        _ReminderCategory.appointment =>
          'Bevorstehende Arzt- und Kliniktermine',
        _ReminderCategory.repeating =>
          'Regelmäßige Gesundheits-Checks',
      };

  IconData get icon => switch (this) {
        _ReminderCategory.medication => Icons.medication_rounded,
        _ReminderCategory.fasting => Icons.no_food_rounded,
        _ReminderCategory.appointment => Icons.calendar_month_rounded,
        _ReminderCategory.repeating => Icons.repeat_rounded,
      };

  Color get color => switch (this) {
        _ReminderCategory.medication => AppColors.primary,
        _ReminderCategory.fasting => AppColors.warning,
        _ReminderCategory.appointment => AppColors.accent,
        _ReminderCategory.repeating => AppColors.success,
      };
}

class _ReminderItem {
  _ReminderItem({
    required this.title,
    required this.subtitle,
    required this.category,
    required this.time,
    this.enabled = true,
  });

  final String title;
  final String subtitle;
  final _ReminderCategory category;
  final String time;
  bool enabled;
}

// ─────────────────────────────────────────────────────────────────────────────

class NotificationSettingsScreen extends StatefulWidget {
  const NotificationSettingsScreen({super.key});

  @override
  State<NotificationSettingsScreen> createState() =>
      _NotificationSettingsScreenState();
}

class _NotificationSettingsScreenState
    extends State<NotificationSettingsScreen> {
  bool _globalEnabled = true;

  final _reminders = <_ReminderItem>[
    // Medication
    _ReminderItem(
      title: 'Ibuprofen 400 mg',
      subtitle: 'Morgens nach dem Frühstück',
      category: _ReminderCategory.medication,
      time: '08:00',
    ),
    _ReminderItem(
      title: 'Pantoprazol 20 mg',
      subtitle: 'Abends vor dem Essen',
      category: _ReminderCategory.medication,
      time: '18:00',
    ),
    _ReminderItem(
      title: 'Thrombose-Spritze',
      subtitle: 'Täglich abends',
      category: _ReminderCategory.medication,
      time: '21:00',
    ),

    // Fasting
    _ReminderItem(
      title: 'Nüchtern ab Mitternacht',
      subtitle: '12 h vor OP – nichts essen oder trinken',
      category: _ReminderCategory.fasting,
      time: '00:00',
    ),
    _ReminderItem(
      title: 'Letzte Mahlzeit',
      subtitle: 'Erinnerung 2 h vor Nüchtern-Beginn',
      category: _ReminderCategory.fasting,
      time: '22:00',
    ),

    // Appointment
    _ReminderItem(
      title: 'Voruntersuchung',
      subtitle: 'Klinikum Süd – Dr. Weber',
      category: _ReminderCategory.appointment,
      time: '14:30',
    ),
    _ReminderItem(
      title: 'OP-Termin',
      subtitle: '1 Tag vorher erinnern',
      category: _ReminderCategory.appointment,
      time: '07:00',
    ),

    // Repeating
    _ReminderItem(
      title: 'Wundfoto machen',
      subtitle: 'Täglich zur Dokumentation',
      category: _ReminderCategory.repeating,
      time: '09:00',
    ),
    _ReminderItem(
      title: 'Vitalwerte eintragen',
      subtitle: 'Morgens und abends',
      category: _ReminderCategory.repeating,
      time: '08:00',
    ),
    _ReminderItem(
      title: 'Schmerztagebuch',
      subtitle: 'Alle 4 Stunden',
      category: _ReminderCategory.repeating,
      time: '12:00',
      enabled: false,
    ),
  ];

  Map<_ReminderCategory, List<_ReminderItem>> get _grouped {
    final map = <_ReminderCategory, List<_ReminderItem>>{};
    for (final cat in _ReminderCategory.values) {
      map[cat] = _reminders.where((r) => r.category == cat).toList();
    }
    return map;
  }

  int get _activeCount => _reminders.where((r) => r.enabled).length;

  @override
  Widget build(BuildContext context) {
    final topPadding = MediaQuery.of(context).padding.top;
    final grouped = _grouped;

    return Scaffold(
      backgroundColor: AppColors.grey100,
      body: SingleChildScrollView(
        padding: EdgeInsets.only(
          left: AppSpacing.xl,
          right: AppSpacing.xl,
          top: topPadding + AppSpacing.sm,
          bottom: AppSpacing.huge,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildAppBar(context),
            const SizedBox(height: AppSpacing.xxl),
            _GlobalToggleCard(
              enabled: _globalEnabled,
              activeCount: _activeCount,
              totalCount: _reminders.length,
              onChanged: (v) {
                setState(() {
                  _globalEnabled = v;
                  for (final r in _reminders) {
                    r.enabled = v;
                  }
                });
              },
            ),
            const SizedBox(height: AppSpacing.xxl),
            for (final cat in _ReminderCategory.values) ...[
              _CategoryHeader(category: cat),
              const SizedBox(height: AppSpacing.md),
              _CategoryGroup(
                items: grouped[cat]!,
                globalEnabled: _globalEnabled,
                onToggle: (index, value) {
                  setState(() {
                    grouped[cat]![index].enabled = value;
                    _globalEnabled = _reminders.every((r) => r.enabled);
                  });
                },
              ),
              const SizedBox(height: AppSpacing.xxl),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildAppBar(BuildContext context) {
    return Row(
      children: [
        GestureDetector(
          onTap: () => Navigator.of(context).pop(),
          child: GlassContainer(
            padding: const EdgeInsets.all(AppSpacing.sm),
            borderRadius: AppRadius.borderRadiusMd,
            child: const Icon(
              Icons.arrow_back_ios_new_rounded,
              size: 18,
              color: AppColors.primary,
            ),
          ),
        ),
        const SizedBox(width: AppSpacing.md),
        Expanded(
          child: Text(
            'Benachrichtigungen',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
        ),
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
                  '$activeCount von $totalCount Erinnerungen aktiv',
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

// ── Category header ──────────────────────────────────────────────────────────

class _CategoryHeader extends StatelessWidget {
  const _CategoryHeader({required this.category});

  final _ReminderCategory category;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: AppSpacing.xs),
      child: Row(
        children: [
          Container(
            width: 28,
            height: 28,
            decoration: BoxDecoration(
              color: category.color.withValues(alpha: 0.12),
              borderRadius: AppRadius.borderRadiusSm,
            ),
            child: Icon(category.icon, size: 16, color: category.color),
          ),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  category.label,
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                Text(
                  category.subtitle,
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ── Category group ───────────────────────────────────────────────────────────

class _CategoryGroup extends StatelessWidget {
  const _CategoryGroup({
    required this.items,
    required this.globalEnabled,
    required this.onToggle,
  });

  final List<_ReminderItem> items;
  final bool globalEnabled;
  final void Function(int index, bool value) onToggle;

  @override
  Widget build(BuildContext context) {
    return GlassContainer(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.xs),
      borderRadius: AppRadius.borderRadiusXl,
      child: Column(
        children: [
          for (var i = 0; i < items.length; i++) ...[
            _ReminderRow(
              item: items[i],
              onToggle: (v) => onToggle(i, v),
            ),
            if (i < items.length - 1)
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.lg,
                ),
                child: Container(height: 1, color: AppColors.grey200),
              ),
          ],
        ],
      ),
    );
  }
}

// ── Reminder row ─────────────────────────────────────────────────────────────

class _ReminderRow extends StatelessWidget {
  const _ReminderRow({
    required this.item,
    required this.onToggle,
  });

  final _ReminderItem item;
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
          // Time badge
          Container(
            width: 52,
            padding: const EdgeInsets.symmetric(
              vertical: AppSpacing.xs,
            ),
            decoration: BoxDecoration(
              color: item.enabled
                  ? item.category.color.withValues(alpha: 0.10)
                  : AppColors.grey100,
              borderRadius: AppRadius.borderRadiusSm,
            ),
            child: Center(
              child: Text(
                item.time,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  fontFeatures: const [FontFeature.tabularFigures()],
                  color: item.enabled
                      ? item.category.color
                      : AppColors.grey400,
                ),
              ),
            ),
          ),
          const SizedBox(width: AppSpacing.md),

          // Content
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.title,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: item.enabled
                        ? AppColors.textPrimary
                        : AppColors.grey400,
                  ),
                ),
                const SizedBox(height: AppSpacing.xxs),
                Text(
                  item.subtitle,
                  style: TextStyle(
                    fontSize: 12,
                    color: item.enabled
                        ? AppColors.textSecondary
                        : AppColors.grey300,
                  ),
                ),
              ],
            ),
          ),

          // Toggle
          CupertinoSwitch(
            value: item.enabled,
            activeTrackColor: item.category.color,
            onChanged: onToggle,
          ),
        ],
      ),
    );
  }
}
