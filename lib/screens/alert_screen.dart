import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../features/pain/data/pain_repository_sync.dart';
import '../features/pain/domain/pain_entry.dart';
import '../features/pro/domain/trigger_context.dart';
import '../features/pro/presentation/smart_paywall.dart';
import '../main.dart';
import '../features/observations/data/observation_repository.dart';
import '../features/observations/domain/observation_entry.dart';
import '../features/red_flags/data/red_flag_repository_sync.dart';
import '../features/red_flags/domain/red_flag.dart';
import '../features/red_flags/domain/red_flag_engine.dart';
import '../security/app_route_guard.dart';
import '../features/vitals/data/vital_repository_sync.dart';
import '../features/vitals/domain/vital_entry.dart';
import '../features/warnings/data/warnings_repository_sync.dart';
import '../ui/ui.dart';
import '../ui/theme/app_icons.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Alert Screen — Red-Flag Cockpit
// ─────────────────────────────────────────────────────────────────────────────

class AlertScreen extends StatefulWidget {
  const AlertScreen({super.key});

  @override
  State<AlertScreen> createState() => _AlertScreenState();
}

class _AlertScreenState extends State<AlertScreen> {
  final RedFlagRepositorySync _repo = RedFlagRepositorySync.instance;
  StreamSubscription<List<RedFlag>>? _sub;
  List<RedFlag> _flags = const [];
  bool _loading = true;
  bool _isPro = false;

  @override
  void initState() {
    super.initState();
    _init();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final pro = ProServices.maybeOf(context);
    _isPro = pro?.entitlementService.isPro ?? false;
  }

  Future<void> _init() async {
    await _repo.loadFromDisk();
    await _repo.pullLatest();
    _sub = _repo.watchAll().listen((flags) {
      if (!mounted) return;
      setState(() {
        _flags = flags;
        _loading = false;
      });
    });
    // Run engine to check for new flags (Pro only).
    // Read Pro status here because didChangeDependencies runs after initState.
    if (!mounted) return;
    final isPro = ProServices.maybeOf(context)?.entitlementService.isPro ?? false;
    _isPro = isPro;
    if (isPro) {
      await _runEngine();
    }
  }

  Future<void> _runEngine() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null || uid.trim().isEmpty) return;

    final warningCheck = await WarningsRepositorySync.instance.loadLatest();
    if (!mounted) return;

    List<PainEntry> painEntries = [];
    try {
      await PainRepositorySync.instance.loadFromDisk();
      painEntries = await PainRepositorySync.instance.watchAll().first;
    } catch (e) {
      debugPrint('[AlertScreen] Failed to load pain entries: $e');
    }
    if (!mounted) return;

    List<VitalEntry> vitalEntries = [];
    try {
      await VitalRepositorySync.instance.loadFromDisk();
      vitalEntries = await VitalRepositorySync.instance.watchAll().first;
    } catch (e) {
      debugPrint('[AlertScreen] Failed to load vital entries: $e');
    }
    if (!mounted) return;

    List<ObservationEntry> observations = [];
    try {
      observations = await ObservationRepository()
          .watchObservations(uid)
          .first;
    } catch (e) {
      debugPrint('[AlertScreen] Failed to load observations: $e');
    }
    if (!mounted) return;

    final input = RedFlagEvalInput(
      latestWarningCheck: warningCheck,
      recentPainEntries: painEntries,
      recentVitalEntries: vitalEntries,
      recentObservations: observations,
    );

    final newFlags = evaluateRedFlags(ownerId: uid, input: input);

    // Deduplicate: only create flags for sources that don't already
    // have an active flag.
    final activeSources = _flags
        .where((f) => f.status.isActive)
        .map((f) => f.source)
        .toSet();

    final toAdd = newFlags.where((f) => !activeSources.contains(f.source));
    if (toAdd.isNotEmpty) {
      try {
        await _repo.upsertAll(toAdd.toList());
      } catch (e) {
        debugPrint('[AlertScreen] Failed to upsert flags: $e');
      }
    }
  }

  @override
  void dispose() {
    _sub?.cancel();
    super.dispose();
  }

  RedFlagSeverity get _currentLevel => overallSeverity(_flags);

  List<RedFlag> get _activeFlags =>
      _flags.where((f) => f.status.isActive).toList();

  List<RedFlag> get _resolvedFlags =>
      _flags.where((f) => !f.status.isActive).toList();

  @override
  Widget build(BuildContext context) {
    return GlassPage(
      title: 'Red\u2011Flag System',
      titleIcon: AppIcons.redFlags,
      titleColor: AppColors.error,
      children: [
        if (_loading)
          const Padding(
            padding: EdgeInsets.all(AppSpacing.huge),
            child: Center(child: CircularProgressIndicator.adaptive()),
          )
        else ...[
          _StatusBanner(level: _currentLevel, activeCount: _activeFlags.length),
          const SizedBox(height: AppSpacing.xl),
          _SeverityIndicator(currentLevel: _currentLevel),
          const SizedBox(height: AppSpacing.xxl),

          // ── Active flags ──────────────────────────────────────────
          if (_activeFlags.isNotEmpty) ...[
            _sectionTitle(context, 'Aktive Warnungen'),
            const SizedBox(height: AppSpacing.md),
            for (final flag in _activeFlags) ...[
              _RedFlagCard(
                flag: flag,
                onResolve: () => _resolveFlag(flag),
                onNavigate: flag.actions.isNotEmpty
                    ? () => _navigateAction(flag.actions.first)
                    : null,
              ),
              const SizedBox(height: AppSpacing.md),
            ],
            const SizedBox(height: AppSpacing.lg),
          ],

          // ── Pro upsell for automated monitoring ────────────────
          if (!_isPro) ...[
            GlassContainer(
              padding: const EdgeInsets.all(AppSpacing.lg),
              borderRadius: AppRadius.borderRadiusXl,
              child: Row(
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFF007AFF), Color(0xFF5856D6)],
                      ),
                      borderRadius: AppRadius.borderRadiusMd,
                    ),
                    child: const Icon(
                      Icons.auto_awesome_rounded,
                      size: 24,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Automatische Überwachung',
                          style: Theme.of(context).textTheme.titleSmall
                              ?.copyWith(fontWeight: FontWeight.w600),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'Mit Pro erkennt das System kritische Werte '
                          'automatisch aus Schmerz, Vitaldaten & mehr.',
                          style: Theme.of(context).textTheme.bodySmall
                              ?.copyWith(
                                color: AppColors.textSecondary,
                                height: 1.3,
                              ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  GlassButton(
                    onPressed: () {
                      SmartPaywall.trigger(
                        context: context,
                        triggerContext: TriggerContext.redFlagFeature,
                      );
                    },
                    label: 'Pro',
                    icon: Icons.star_rounded,
                    variant: GlassButtonVariant.primary,
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
          ],

          // ── Quick actions ─────────────────────────────────────────
          _sectionTitle(context, 'Aktionen'),
          const SizedBox(height: AppSpacing.md),
          _ActionCard(
            icon: Icons.checklist_rounded,
            color: AppColors.warning,
            title: 'Warnzeichen-Check',
            subtitle:
                'Schnellprüfung der wichtigsten Symptome – dauert nur '
                '30 Sekunden.',
            buttonLabel: 'Check starten',
            buttonIcon: Icons.play_arrow_rounded,
            onPressed: () {
              Navigator.of(context).pushNamed('/warnings');
            },
          ),
          const SizedBox(height: AppSpacing.md),
          _ActionCard(
            icon: Icons.phone_rounded,
            color: AppColors.primary,
            title: 'Arzt kontaktieren',
            subtitle:
                'Rufen Sie Ihren behandelnden Arzt an oder '
                'nutzen Sie den Notruf.',
            buttonLabel: 'Notfallkontakt',
            buttonIcon: Icons.call_rounded,
            onPressed: () => _showEmergencySheet(context),
          ),
          const SizedBox(height: AppSpacing.md),
          _ActionCard(
            icon: Icons.local_hospital_rounded,
            color: AppColors.error,
            title: 'Notfallanweisungen',
            subtitle:
                'Sofortmaßnahmen bei Atemnot, Bewusstlosigkeit oder '
                'starker Blutung.',
            buttonLabel: 'Anweisungen öffnen',
            buttonIcon: Icons.open_in_new_rounded,
            variant: GlassButtonVariant.ghost,
            onPressed: () => _showEmergencySheet(context),
          ),

          // ── Resolved history ──────────────────────────────────────
          if (_resolvedFlags.isNotEmpty) ...[
            const SizedBox(height: AppSpacing.xxl),
            _sectionTitle(context, 'Verlauf'),
            const SizedBox(height: AppSpacing.md),
            for (final flag in _resolvedFlags.take(10)) ...[
              _ResolvedFlagTile(flag: flag),
              const SizedBox(height: AppSpacing.sm),
            ],
          ],

          // ── Empty state ───────────────────────────────────────────
          if (_activeFlags.isEmpty && _resolvedFlags.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: AppSpacing.huge),
              child: Column(
                children: [
                  Container(
                    width: 64,
                    height: 64,
                    decoration: BoxDecoration(
                      color: AppColors.success.withValues(alpha: 0.12),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.check_circle_rounded,
                      size: 36,
                      color: AppColors.success,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  Text(
                    'Alles im grünen Bereich',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    'Keine aktiven Warnungen. Weiter so!',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
        ],
      ],
    );
  }

  Widget _sectionTitle(BuildContext context, String title) {
    return Padding(
      padding: const EdgeInsets.only(left: AppSpacing.xs),
      child: Text(title, style: Theme.of(context).textTheme.titleLarge),
    );
  }

  Future<void> _resolveFlag(RedFlag flag) async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    try {
      await _repo.resolve(flag.id, byUid: uid);
    } catch (e) {
      debugPrint('[AlertScreen] Failed to resolve flag: $e');
    }
  }

  Future<void> _navigateAction(RedFlagAction action) async {
    final route = action.route;
    if (route == null) return;
    if (route.startsWith('tel:')) {
      final uri = Uri.tryParse(route);
      if (uri == null) return;
      try {
        await launchUrl(uri);
      } catch (_) {
        // Device may not support tel: links
      }
      return;
    }
    final safeRoute = sanitizeExternalRoute(route);
    if (safeRoute == null) return;
    Navigator.of(context).pushNamed(safeRoute);
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

// ═══════════════════════════════════════════════════════════════════════════════
// Sub-widgets
// ═══════════════════════════════════════════════════════════════════════════════

extension _SeverityMeta on RedFlagSeverity {
  Color get color => switch (this) {
    RedFlagSeverity.green => AppColors.success,
    RedFlagSeverity.yellow => const Color(0xFFFFCC00),
    RedFlagSeverity.orange => AppColors.warning,
    RedFlagSeverity.red => AppColors.error,
  };

  IconData get icon => switch (this) {
    RedFlagSeverity.green => Icons.check_circle_rounded,
    RedFlagSeverity.yellow => Icons.info_rounded,
    RedFlagSeverity.orange => Icons.warning_amber_rounded,
    RedFlagSeverity.red => Icons.error_rounded,
  };

  String get title => switch (this) {
    RedFlagSeverity.green => 'Alles in Ordnung',
    RedFlagSeverity.yellow => 'Leichte Auffälligkeit',
    RedFlagSeverity.orange => 'Erhöhtes Risiko',
    RedFlagSeverity.red => 'Sofort handeln',
  };

  String get description => switch (this) {
    RedFlagSeverity.green => 'Ihre Werte sind im Normalbereich. Weiter so!',
    RedFlagSeverity.yellow =>
      'Einzelne Werte leicht außerhalb des Normalbereichs. Bitte beobachten.',
    RedFlagSeverity.orange =>
      'Mehrere Werte auffällig. Kontaktieren Sie Ihren Arzt zeitnah.',
    RedFlagSeverity.red =>
      'Kritische Werte erkannt. Sofortige ärztliche Hilfe empfohlen.',
  };
}

// ── Status banner ────────────────────────────────────────────────────────────

class _StatusBanner extends StatelessWidget {
  const _StatusBanner({required this.level, required this.activeCount});

  final RedFlagSeverity level;
  final int activeCount;

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
                    if (activeCount > 0) ...[
                      const SizedBox(width: AppSpacing.sm),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppSpacing.sm,
                          vertical: AppSpacing.xxs,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.error.withValues(alpha: 0.10),
                          borderRadius: AppRadius.borderRadiusPill,
                        ),
                        child: Text(
                          '$activeCount aktiv',
                          style: const TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                            color: AppColors.error,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: AppSpacing.sm),
                Text(
                  level.title,
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: AppSpacing.xxs),
                Text(
                  level.description,
                  style: Theme.of(
                    context,
                  ).textTheme.bodySmall?.copyWith(height: 1.4),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ── Severity indicator (4 dots) ──────────────────────────────────────────────

class _SeverityIndicator extends StatelessWidget {
  const _SeverityIndicator({required this.currentLevel});

  final RedFlagSeverity currentLevel;

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
          for (var i = 0; i < RedFlagSeverity.values.length; i++) ...[
            if (i > 0)
              Expanded(
                child: Container(
                  height: 3,
                  decoration: BoxDecoration(
                    color: i <= currentLevel.index
                        ? RedFlagSeverity.values[i].color.withValues(
                            alpha: 0.40,
                          )
                        : AppColors.grey200,
                    borderRadius: BorderRadius.circular(1.5),
                  ),
                ),
              ),
            _LevelDot(
              level: RedFlagSeverity.values[i],
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

  final RedFlagSeverity level;
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

// ── Red flag card ────────────────────────────────────────────────────────────

class _RedFlagCard extends StatelessWidget {
  const _RedFlagCard({required this.flag, this.onResolve, this.onNavigate});

  final RedFlag flag;
  final VoidCallback? onResolve;
  final VoidCallback? onNavigate;

  @override
  Widget build(BuildContext context) {
    return GlassContainer(
      padding: const EdgeInsets.all(AppSpacing.lg),
      borderRadius: AppRadius.borderRadiusXl,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: flag.severity.color.withValues(alpha: 0.12),
                  borderRadius: AppRadius.borderRadiusMd,
                ),
                child: Center(
                  child: GlassIcon(
                    icon: flag.source.icon,
                    color: flag.source.iconColor,
                    size: 28,
                  ),
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      flag.title,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.xxs),
                    Text(
                      flag.source.label,
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.sm,
                  vertical: AppSpacing.xxs,
                ),
                decoration: BoxDecoration(
                  color: flag.severity.color.withValues(alpha: 0.12),
                  borderRadius: AppRadius.borderRadiusPill,
                ),
                child: Text(
                  flag.severity.label,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: flag.severity.color,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),

          // Summary
          Text(
            flag.summary,
            style: const TextStyle(
              fontSize: 14,
              color: AppColors.textPrimary,
              height: 1.4,
            ),
          ),
          const SizedBox(height: AppSpacing.md),

          // Recommended action
          Container(
            padding: const EdgeInsets.all(AppSpacing.md),
            decoration: BoxDecoration(
              color: flag.severity.color.withValues(alpha: 0.06),
              borderRadius: AppRadius.borderRadiusMd,
              border: Border.all(
                color: flag.severity.color.withValues(alpha: 0.15),
              ),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.lightbulb_outline_rounded,
                  size: 18,
                  color: flag.severity.color,
                ),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: Text(
                    flag.recommendedAction,
                    style: TextStyle(
                      fontSize: 13,
                      color: flag.severity.color,
                      fontWeight: FontWeight.w500,
                      height: 1.35,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.lg),

          // Action buttons
          Row(
            children: [
              if (onNavigate != null)
                Expanded(
                  child: GlassButton(
                    onPressed: onNavigate!,
                    label: flag.actions.isNotEmpty
                        ? flag.actions.first.label
                        : 'Öffnen',
                    icon: Icons.open_in_new_rounded,
                    variant: GlassButtonVariant.primary,
                    expand: true,
                  ),
                ),
              if (onNavigate != null) const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: GlassButton(
                  onPressed: onResolve ?? () {},
                  label: 'Erledigt',
                  icon: Icons.check_rounded,
                  variant: GlassButtonVariant.ghost,
                  expand: true,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ── Resolved flag tile ───────────────────────────────────────────────────────

class _ResolvedFlagTile extends StatelessWidget {
  const _ResolvedFlagTile({required this.flag});

  final RedFlag flag;

  @override
  Widget build(BuildContext context) {
    final date = flag.resolvedAt ?? flag.updatedAt;
    final dateStr =
        '${date.day.toString().padLeft(2, '0')}.${date.month.toString().padLeft(2, '0')}.'
        '${date.year}';
    return GlassContainer(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.lg,
        vertical: AppSpacing.md,
      ),
      borderRadius: AppRadius.borderRadiusMd,
      child: Row(
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: AppColors.grey100,
              borderRadius: AppRadius.borderRadiusSm,
            ),
            child: Center(
              child: GlassIcon(
                icon: flag.source.icon,
                color: flag.source.iconColor,
                size: 16,
              ),
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  flag.title,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: AppColors.textSecondary,
                    decoration: TextDecoration.lineThrough,
                  ),
                ),
                Text(
                  '${flag.status.label} · $dateStr',
                  style: const TextStyle(
                    fontSize: 11,
                    color: AppColors.grey500,
                  ),
                ),
              ],
            ),
          ),
          const Icon(
            Icons.check_circle_rounded,
            size: 20,
            color: AppColors.success,
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
      description:
          'Rufen Sie Ihren Arzt oder die Klinik an und schildern '
          'Sie die Symptome.',
    ),
    _EmergencyStep(
      number: '4',
      title: 'Notruf 112',
      description:
          'Bei Atemnot, Bewusstlosigkeit oder starker Blutung '
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
              _EmergencyStepRow(
                step: _steps[i],
                isLast: i == _steps.length - 1,
              ),
            ],
            const SizedBox(height: AppSpacing.xxl),
            GlassButton(
              onPressed: () async {
                Navigator.of(context).pop();
                final uri = Uri.parse('tel:112');
                if (await canLaunchUrl(uri)) {
                  await launchUrl(uri);
                }
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
              padding: EdgeInsets.only(bottom: isLast ? 0 : AppSpacing.xl),
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
