import 'package:flutter/material.dart';

import '../ui/ui.dart';

// ── Alert level model ────────────────────────────────────────────────────────

enum AlertLevel { green, yellow, orange, red }

extension AlertLevelMeta on AlertLevel {
  String get label => switch (this) {
        AlertLevel.green => 'Grün',
        AlertLevel.yellow => 'Gelb',
        AlertLevel.orange => 'Orange',
        AlertLevel.red => 'Rot',
      };

  String get title => switch (this) {
        AlertLevel.green => 'Alles in Ordnung',
        AlertLevel.yellow => 'Leichte Auffälligkeit',
        AlertLevel.orange => 'Erhöhtes Risiko',
        AlertLevel.red => 'Sofort handeln',
      };

  String get description => switch (this) {
        AlertLevel.green => 'Ihre Werte sind im Normalbereich. Weiter so!',
        AlertLevel.yellow =>
          'Einzelne Werte leicht außerhalb des Normalbereichs. Bitte beobachten.',
        AlertLevel.orange =>
          'Mehrere Werte auffällig. Kontaktieren Sie Ihren Arzt zeitnah.',
        AlertLevel.red =>
          'Kritische Werte erkannt. Sofortige ärztliche Hilfe empfohlen.',
      };

  Color get color => switch (this) {
        AlertLevel.green => AppColors.success,
        AlertLevel.yellow => const Color(0xFFFFCC00),
        AlertLevel.orange => AppColors.warning,
        AlertLevel.red => AppColors.error,
      };

  IconData get icon => switch (this) {
        AlertLevel.green => Icons.check_circle_rounded,
        AlertLevel.yellow => Icons.info_rounded,
        AlertLevel.orange => Icons.warning_amber_rounded,
        AlertLevel.red => Icons.error_rounded,
      };
}

// ── Alert trigger model ──────────────────────────────────────────────────────

class _AlertTrigger {
  const _AlertTrigger({
    required this.label,
    required this.condition,
    required this.currentValue,
    required this.level,
    required this.icon,
    this.triggered = false,
  });

  final String label;
  final String condition;
  final String currentValue;
  final AlertLevel level;
  final IconData icon;
  final bool triggered;
}

// ─────────────────────────────────────────────────────────────────────────────

class AlertScreen extends StatelessWidget {
  const AlertScreen({super.key});

  static const _triggers = <_AlertTrigger>[
    _AlertTrigger(
      label: 'Temperatur',
      condition: '> 39.5 °C',
      currentValue: '36.7 °C',
      level: AlertLevel.green,
      icon: Icons.thermostat_outlined,
    ),
    _AlertTrigger(
      label: 'Schmerzlevel',
      condition: '> 9 / 10',
      currentValue: '3 / 10',
      level: AlertLevel.green,
      icon: Icons.sentiment_very_dissatisfied_rounded,
    ),
    _AlertTrigger(
      label: 'Blutdruck systolisch',
      condition: '> 180 mmHg',
      currentValue: '142 mmHg',
      level: AlertLevel.yellow,
      icon: Icons.monitor_heart_outlined,
      triggered: true,
    ),
    _AlertTrigger(
      label: 'Puls',
      condition: '> 120 bpm',
      currentValue: '98 bpm',
      level: AlertLevel.green,
      icon: Icons.favorite_outline_rounded,
    ),
    _AlertTrigger(
      label: 'SpO2',
      condition: '< 92 %',
      currentValue: '99 %',
      level: AlertLevel.green,
      icon: Icons.air_rounded,
    ),
    _AlertTrigger(
      label: 'Wundinfektion',
      condition: '≥ 3 Symptome',
      currentValue: '1 Symptom',
      level: AlertLevel.yellow,
      icon: Icons.healing_rounded,
      triggered: true,
    ),
  ];

  AlertLevel get _currentLevel {
    final triggered = _triggers.where((t) => t.triggered).toList();
    if (triggered.isEmpty) return AlertLevel.green;
    return triggered
        .map((t) => t.level)
        .reduce((a, b) => a.index > b.index ? a : b);
  }

  @override
  Widget build(BuildContext context) {
    final topPadding = MediaQuery.of(context).padding.top;
    final level = _currentLevel;

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
            _StatusBanner(level: level),
            const SizedBox(height: AppSpacing.xxl),
            _LevelIndicator(currentLevel: level),
            const SizedBox(height: AppSpacing.xxl),
            _sectionTitle(context, 'Überwachte Regeln'),
            const SizedBox(height: AppSpacing.md),
            for (final t in _triggers) ...[
              _TriggerCard(trigger: t),
              const SizedBox(height: AppSpacing.md),
            ],
            const SizedBox(height: AppSpacing.lg),
            _sectionTitle(context, 'Aktionen'),
            const SizedBox(height: AppSpacing.md),
            _ActionCard(
              icon: Icons.phone_rounded,
              color: AppColors.primary,
              title: 'Arzt kontaktieren',
              subtitle: 'Rufen Sie Ihren behandelnden Arzt an oder '
                  'senden Sie eine Nachricht.',
              buttonLabel: 'Jetzt anrufen',
              buttonIcon: Icons.call_rounded,
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Anruf – kommt bald')),
                );
              },
            ),
            const SizedBox(height: AppSpacing.md),
            _ActionCard(
              icon: Icons.local_hospital_rounded,
              color: AppColors.error,
              title: 'Notfallanweisungen',
              subtitle: 'Sofortmaßnahmen bei kritischen Werten. '
                  'Bei Atemnot oder Bewusstlosigkeit: 112 anrufen.',
              buttonLabel: 'Anweisungen öffnen',
              buttonIcon: Icons.open_in_new_rounded,
              variant: GlassButtonVariant.ghost,
              onPressed: () {
                _showEmergencySheet(context);
              },
            ),
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
            'Red‑Flag System',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
        ),
      ],
    );
  }

  Widget _sectionTitle(BuildContext context, String title) {
    return Padding(
      padding: const EdgeInsets.only(left: AppSpacing.xs),
      child: Text(title, style: Theme.of(context).textTheme.titleLarge),
    );
  }

  void _showEmergencySheet(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const _EmergencySheet(),
    );
  }
}

// ── Status banner ────────────────────────────────────────────────────────────

class _StatusBanner extends StatelessWidget {
  const _StatusBanner({required this.level});

  final AlertLevel level;

  @override
  Widget build(BuildContext context) {
    return GlassContainer(
      padding: const EdgeInsets.all(AppSpacing.xl),
      borderRadius: AppRadius.borderRadiusXl,
      child: Row(
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: level.color.withValues(alpha: 0.14),
              borderRadius: AppRadius.borderRadiusLg,
              border: Border.all(
                color: level.color.withValues(alpha: 0.30),
                width: 1.5,
              ),
            ),
            child: Icon(level.icon, size: 32, color: level.color),
          ),
          const SizedBox(width: AppSpacing.lg),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.sm,
                        vertical: AppSpacing.xxs,
                      ),
                      decoration: BoxDecoration(
                        color: level.color.withValues(alpha: 0.14),
                        borderRadius: AppRadius.borderRadiusPill,
                      ),
                      child: Text(
                        'Stufe: ${level.label}',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: level.color,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.sm),
                Text(
                  level.title,
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  level.description,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        height: 1.4,
                      ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ── Level indicator (4 dots) ─────────────────────────────────────────────────

class _LevelIndicator extends StatelessWidget {
  const _LevelIndicator({required this.currentLevel});

  final AlertLevel currentLevel;

  @override
  Widget build(BuildContext context) {
    return GlassContainer(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.xl,
        vertical: AppSpacing.lg,
      ),
      borderRadius: AppRadius.borderRadiusXl,
      child: Row(
        children: [
          for (var i = 0; i < AlertLevel.values.length; i++) ...[
            if (i > 0)
              Expanded(
                child: Container(
                  height: 3,
                  decoration: BoxDecoration(
                    color: i <= currentLevel.index
                        ? AlertLevel.values[i].color.withValues(alpha: 0.40)
                        : AppColors.grey200,
                    borderRadius: BorderRadius.circular(1.5),
                  ),
                ),
              ),
            _LevelDot(
              level: AlertLevel.values[i],
              active: i <= currentLevel.index,
              isCurrent: i == currentLevel.index,
            ),
          ],
        ],
      ),
    );
  }
}

class _LevelDot extends StatelessWidget {
  const _LevelDot({
    required this.level,
    required this.active,
    required this.isCurrent,
  });

  final AlertLevel level;
  final bool active;
  final bool isCurrent;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          width: isCurrent ? 40 : 28,
          height: isCurrent ? 40 : 28,
          decoration: BoxDecoration(
            color: active
                ? level.color.withValues(alpha: 0.16)
                : AppColors.grey100,
            shape: BoxShape.circle,
            border: Border.all(
              color: active ? level.color : AppColors.grey300,
              width: isCurrent ? 2.5 : 1,
            ),
            boxShadow: isCurrent
                ? [
                    BoxShadow(
                      color: level.color.withValues(alpha: 0.25),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ]
                : null,
          ),
          child: Icon(
            active ? level.icon : null,
            size: isCurrent ? 20 : 14,
            color: active ? level.color : AppColors.grey400,
          ),
        ),
        const SizedBox(height: AppSpacing.xs),
        Text(
          level.label,
          style: TextStyle(
            fontSize: 10,
            fontWeight: isCurrent ? FontWeight.w700 : FontWeight.w500,
            color: active ? level.color : AppColors.textSecondary,
          ),
        ),
      ],
    );
  }
}

// ── Trigger card ─────────────────────────────────────────────────────────────

class _TriggerCard extends StatelessWidget {
  const _TriggerCard({required this.trigger});

  final _AlertTrigger trigger;

  @override
  Widget build(BuildContext context) {
    return GlassContainer(
      padding: const EdgeInsets.all(AppSpacing.lg),
      borderRadius: AppRadius.borderRadiusLg,
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: trigger.triggered
                  ? trigger.level.color.withValues(alpha: 0.12)
                  : AppColors.grey100,
              borderRadius: AppRadius.borderRadiusMd,
            ),
            child: Icon(
              trigger.icon,
              size: 22,
              color: trigger.triggered
                  ? trigger.level.color
                  : AppColors.grey500,
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  trigger.label,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: AppSpacing.xxs),
                Text(
                  'Regel: ${trigger.condition}',
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                trigger.currentValue,
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: trigger.triggered
                      ? trigger.level.color
                      : AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: AppSpacing.xxs),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.sm,
                  vertical: AppSpacing.xxs,
                ),
                decoration: BoxDecoration(
                  color: trigger.triggered
                      ? trigger.level.color.withValues(alpha: 0.12)
                      : AppColors.success.withValues(alpha: 0.10),
                  borderRadius: AppRadius.borderRadiusPill,
                ),
                child: Text(
                  trigger.triggered ? 'Auffällig' : 'Normal',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    color: trigger.triggered
                        ? trigger.level.color
                        : AppColors.success,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ── Action card ──────────────────────────────────────────────────────────────

class _ActionCard extends StatelessWidget {
  const _ActionCard({
    required this.icon,
    required this.color,
    required this.title,
    required this.subtitle,
    required this.buttonLabel,
    required this.buttonIcon,
    required this.onPressed,
    this.variant = GlassButtonVariant.primary,
  });

  final IconData icon;
  final Color color;
  final String title;
  final String subtitle;
  final String buttonLabel;
  final IconData buttonIcon;
  final VoidCallback onPressed;
  final GlassButtonVariant variant;

  @override
  Widget build(BuildContext context) {
    return GlassContainer(
      padding: const EdgeInsets.all(AppSpacing.xl),
      borderRadius: AppRadius.borderRadiusXl,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.10),
                  borderRadius: AppRadius.borderRadiusMd,
                ),
                child: Icon(icon, size: 24, color: color),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Text(
                  title,
                  style: Theme.of(context).textTheme.titleLarge,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.lg),
          Text(
            subtitle,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppColors.textSecondary,
                  height: 1.45,
                ),
          ),
          const SizedBox(height: AppSpacing.xl),
          GlassButton(
            onPressed: onPressed,
            label: buttonLabel,
            icon: buttonIcon,
            variant: variant,
            expand: true,
          ),
        ],
      ),
    );
  }
}

// ── Emergency instructions sheet ─────────────────────────────────────────────

class _EmergencySheet extends StatelessWidget {
  const _EmergencySheet();

  static const _steps = <_EmergencyStep>[
    _EmergencyStep(
      number: '1',
      title: 'Ruhe bewahren',
      description: 'Setzen oder legen Sie sich hin. Atmen Sie ruhig.',
    ),
    _EmergencyStep(
      number: '2',
      title: 'Symptome prüfen',
      description: 'Notieren Sie Ihre aktuellen Beschwerden und deren Stärke.',
    ),
    _EmergencyStep(
      number: '3',
      title: 'Arzt anrufen',
      description: 'Rufen Sie Ihren Arzt oder die Klinik an und schildern '
          'Sie die Symptome.',
    ),
    _EmergencyStep(
      number: '4',
      title: 'Notruf 112',
      description: 'Bei Atemnot, Bewusstlosigkeit oder starker Blutung '
          'sofort 112 anrufen.',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.grey100,
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(AppRadius.xxl),
        ),
      ),
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.xxl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 36,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.grey300,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: AppSpacing.xl),

            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: AppColors.error.withValues(alpha: 0.12),
                borderRadius: AppRadius.borderRadiusLg,
              ),
              child: const Icon(
                Icons.local_hospital_rounded,
                size: 28,
                color: AppColors.error,
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            Text(
              'Notfallanweisungen',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: AppSpacing.xs),
            Text(
              'Folgen Sie diesen Schritten der Reihe nach.',
              style: Theme.of(context).textTheme.bodySmall,
            ),
            const SizedBox(height: AppSpacing.xxl),

            for (var i = 0; i < _steps.length; i++) ...[
              _EmergencyStepRow(step: _steps[i], isLast: i == _steps.length - 1),
            ],

            const SizedBox(height: AppSpacing.xxl),
            GlassButton(
              onPressed: () {
                Navigator.of(context).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Notruf – kommt bald')),
                );
              },
              label: 'Notruf 112 anrufen',
              icon: Icons.call_rounded,
              expand: true,
            ),
            const SizedBox(height: AppSpacing.md),
            GlassButton(
              onPressed: () => Navigator.of(context).pop(),
              label: 'Schließen',
              variant: GlassButtonVariant.ghost,
              expand: true,
            ),
            const SizedBox(height: AppSpacing.lg),
          ],
        ),
      ),
    );
  }
}

class _EmergencyStep {
  const _EmergencyStep({
    required this.number,
    required this.title,
    required this.description,
  });
  final String number;
  final String title;
  final String description;
}

class _EmergencyStepRow extends StatelessWidget {
  const _EmergencyStepRow({required this.step, required this.isLast});

  final _EmergencyStep step;
  final bool isLast;

  @override
  Widget build(BuildContext context) {
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 36,
            child: Column(
              children: [
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: AppColors.error.withValues(alpha: 0.12),
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Text(
                      step.number,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: AppColors.error,
                      ),
                    ),
                  ),
                ),
                if (!isLast)
                  Expanded(
                    child: Container(
                      width: 2,
                      margin: const EdgeInsets.symmetric(
                        vertical: AppSpacing.xxs,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.error.withValues(alpha: 0.20),
                        borderRadius: BorderRadius.circular(1),
                      ),
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Padding(
              padding: EdgeInsets.only(
                bottom: isLast ? 0 : AppSpacing.xl,
              ),
              child: GlassContainer(
                padding: const EdgeInsets.all(AppSpacing.lg),
                borderRadius: AppRadius.borderRadiusLg,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      step.title,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    Text(
                      step.description,
                      style: const TextStyle(
                        fontSize: 13,
                        color: AppColors.textSecondary,
                        height: 1.45,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
