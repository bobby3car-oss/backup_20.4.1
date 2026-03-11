import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../../main.dart';
import '../../../ui/ui.dart';
import '../../pro/domain/trigger_context.dart';
import '../../pro/presentation/pro_feature_gate_view.dart';
import '../../pro/presentation/smart_paywall.dart';
import '../data/rehab_session_repository_sync.dart';
import '../domain/rehab_catalog.dart';
import '../domain/rehab_exercise.dart';
import '../domain/rehab_session.dart';
import 'rehab_exercise_detail_screen.dart';
import 'widgets/exercise_category_chip.dart';
import 'widgets/rehab_stats_banner.dart';
import '../../../ui/theme/app_icons.dart';

class RehabScreen extends StatefulWidget {
  const RehabScreen({super.key});

  @override
  State<RehabScreen> createState() => _RehabScreenState();
}

class _RehabScreenState extends State<RehabScreen> {
  static final RehabSessionRepositorySync _repository =
      RehabSessionRepositorySync.instance;

  RehabCategory? _selectedCategory;
  String? _selectedOpType;
  String _searchQuery = '';

  final _searchController = TextEditingController();

  bool get _isPro =>
      ProServices.maybeOf(context)?.entitlementService.isPro ?? false;

  @override
  void initState() {
    super.initState();
    _bootstrap();
  }

  Future<void> _bootstrap() async {
    await _repository.loadFromDisk();
    await _repository.pullLatest();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<RehabExercise> get _filteredExercises {
    var list = RehabCatalog.exercises;

    if (_selectedCategory != null) {
      list = list.where((e) => e.category == _selectedCategory).toList();
    }

    if (_selectedOpType != null) {
      list = list
          .where((e) => e.isGeneral || e.opTypes.contains(_selectedOpType))
          .toList();
    }

    if (_searchQuery.isNotEmpty) {
      final q = _searchQuery.toLowerCase();
      list = list
          .where((e) =>
              e.title.toLowerCase().contains(q) ||
              e.description.toLowerCase().contains(q))
          .toList();
    }

    return list;
  }

  void _openExercise(RehabExercise exercise) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => RehabExerciseDetailScreen(exercise: exercise),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (!_isPro) {
      return ProFeatureGateView(
        pageTitle: 'Rehabilitation',
        pageIcon: AppIcons.rehab,
        pageColor: const Color(0xFF34C759),
        heroIcon: AppIcons.progress,
        heroTitle: 'Deine Genesung verdient einen Plan',
        heroSubtitle:
            'Nach der OP entscheidet Konstanz über deinen Heilungserfolg. '
            'Mit dem Reha-System bekommst du Übungen, Timer und Struktur – '
            'damit du jeden Tag weißt, was zu tun ist.',
        primaryCta: '3 Tage kostenlos testen',
        onPrimaryTap: () {
          SmartPaywall.trigger(
            context: context,
            triggerContext: TriggerContext.rehabFeature,
          );
        },
        benefits: const <(String, String)>[
          (
            'Übungen für deine OP',
            'Filtere nach OP-Bereich, Schwierigkeit und Reha-Phase – passend zu deinem Stand.',
          ),
          (
            'Timer, der dich begleitet',
            'Keine Unsicherheit bei Dauer und Wiederholungen. Der Timer führt dich durch jede Einheit.',
          ),
          (
            'Sichtbarer Fortschritt',
            'Jede dokumentierte Einheit ist ein Beweis: Du tust etwas für deine Genesung.',
          ),
        ],
        preview: const _RehabLockedPreview(),
      );
    }

    final exercises = _filteredExercises;

    return GlassPage(
      title: 'Rehabilitation',
      titleIcon: AppIcons.rehab,
      titleColor: const Color(0xFF34C759),
      horizontalPadding: AppSpacing.lg,
      children: [
        // ── Stats Banner ──
        StreamBuilder<List<RehabSession>>(
          stream: _repository.watchAll(),
          builder: (context, snapshot) {
            final sessions = snapshot.data ?? [];
            return RehabStatsBanner(sessions: sessions);
          },
        ),
        const SizedBox(height: AppSpacing.xl),

        // ── Search ──
        GlassContainer(
          padding: EdgeInsets.zero,
          child: TextField(
            controller: _searchController,
            onChanged: (value) => setState(() => _searchQuery = value),
            style: const TextStyle(fontSize: 15, color: AppColors.textPrimary),
            decoration: InputDecoration(
              hintText: 'Übung suchen…',
              hintStyle: TextStyle(
                color: AppColors.textSecondary.withValues(alpha: 0.6),
                fontSize: 15,
              ),
              prefixIcon: const Icon(Icons.search_rounded, size: 20),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.md,
                vertical: AppSpacing.md,
              ),
            ),
          ),
        ),
        const SizedBox(height: AppSpacing.md),

        // ── Category Chips ──
        SizedBox(
          height: 40,
          child: ListView(
            scrollDirection: Axis.horizontal,
            physics: adaptiveScrollPhysics,
            children: [
              _FilterChip(
                label: 'Alle',
                isSelected: _selectedCategory == null,
                onTap: () => setState(() => _selectedCategory = null),
              ),
              ...RehabCategory.values.map((cat) => _FilterChip(
                    label: _categoryLabel(cat),
                    isSelected: _selectedCategory == cat,
                    onTap: () => setState(() {
                      _selectedCategory =
                          _selectedCategory == cat ? null : cat;
                    }),
                  )),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.sm),

        // ── Op Type Chips ──
        SizedBox(
          height: 36,
          child: ListView(
            scrollDirection: Axis.horizontal,
            physics: adaptiveScrollPhysics,
            children: [
              _OpChip(
                label: 'Allgemein',
                icon: AppIcons.hospital,
                    iconColor: AppIcons.hospitalColor,
                isSelected: _selectedOpType == null,
                onTap: () => setState(() => _selectedOpType = null),
              ),
              _OpChip(
                label: 'Knie',
                icon: AppIcons.kneeOp,
                    iconColor: AppIcons.kneeOpColor,
                isSelected: _selectedOpType == 'knee',
                onTap: () => setState(() {
                  _selectedOpType =
                      _selectedOpType == 'knee' ? null : 'knee';
                }),
              ),
              _OpChip(
                label: 'Hüfte',
                icon: AppIcons.hipOp,
                    iconColor: AppIcons.hipOpColor,
                isSelected: _selectedOpType == 'hip',
                onTap: () => setState(() {
                  _selectedOpType =
                      _selectedOpType == 'hip' ? null : 'hip';
                }),
              ),
              _OpChip(
                label: 'Schulter',
                icon: AppIcons.progress,
                    iconColor: AppIcons.progressColor,
                isSelected: _selectedOpType == 'shoulder',
                onTap: () => setState(() {
                  _selectedOpType =
                      _selectedOpType == 'shoulder' ? null : 'shoulder';
                }),
              ),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.xl),

        // ── Exercise Count ──
        Padding(
          padding: const EdgeInsets.only(left: AppSpacing.xs),
          child: Text(
            '${exercises.length} Übungen',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: AppColors.textSecondary,
                  fontWeight: FontWeight.w500,
                ),
          ),
        ),
        const SizedBox(height: AppSpacing.sm),

        // ── Exercise List ──
        ...exercises.map((exercise) => Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.sm),
              child: _ExerciseCard(
                exercise: exercise,
                onTap: () => _openExercise(exercise),
              ),
            )),
        const SizedBox(height: AppSpacing.massive),
      ],
    );
  }

  String _categoryLabel(RehabCategory cat) {
    return switch (cat) {
      RehabCategory.mobilization => 'Mobilisation',
      RehabCategory.strengthening => 'Kräftigung',
      RehabCategory.stretching => 'Dehnung',
      RehabCategory.breathing => 'Atmung',
    };
  }
}

class _RehabLockedPreview extends StatelessWidget {
  const _RehabLockedPreview();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          children: const [
            Expanded(
              child: _LockedStageCard(
                icon: AppIcons.vitals,
                iconColor: AppIcons.vitalsColor,
                title: 'Vor der OP',
                subtitle: 'Atmung & Mobilität',
              ),
            ),
            SizedBox(width: AppSpacing.sm),
            Expanded(
              child: _LockedStageCard(
                icon: AppIcons.kneeOp,
                    iconColor: AppIcons.kneeOpColor,
                title: 'Woche 1',
                subtitle: 'Beweglichkeit',
              ),
            ),
            SizedBox(width: AppSpacing.sm),
            Expanded(
              child: _LockedStageCard(
                icon: CupertinoIcons.flag_fill,
                iconColor: AppColors.primary,
                title: 'Follow-up',
                subtitle: 'Aufbau & Routine',
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.md),
        GlassContainer(
          variant: GlassVariant.thin,
          borderRadius: AppRadius.borderRadiusLg,
          padding: const EdgeInsets.all(AppSpacing.md),
          child: Row(
            children: [
              Icon(
                Icons.timer_rounded,
                color: AppColors.success,
                size: 20,
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: Text(
                  'Mit Pro startest du Übungen direkt mit Timer und speicherst jede absolvierte Session.',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppColors.textSecondary,
                        height: 1.4,
                      ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _LockedStageCard extends StatelessWidget {
  const _LockedStageCard({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.subtitle,
  });

  final IconData icon;


  final Color iconColor;
  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return GlassContainer(
      variant: GlassVariant.thin,
      borderRadius: AppRadius.borderRadiusLg,
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Column(
        children: [
          GlassIcon(icon: icon, color: iconColor, size: 22),
          const SizedBox(height: AppSpacing.sm),
          Text(
            title,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.w700,
                ),
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            subtitle,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: AppColors.textSecondary,
                ),
          ),
        ],
      ),
    );
  }
}

// ============================================================================
// _FilterChip
// ============================================================================

class _FilterChip extends StatelessWidget {
  const _FilterChip({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: AppSpacing.sm),
      child: PressableScale(
        onTap: () {
          Haptic.selection();
          onTap();
        },
        child: AnimatedContainer(
          duration: MotionDuration.fast,
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.md,
            vertical: AppSpacing.sm,
          ),
          decoration: BoxDecoration(
            color: isSelected
                ? AppColors.primary.withValues(alpha: 0.15)
                : AppColors.glassFillLight,
            borderRadius: AppRadius.borderRadiusPill,
            border: Border.all(
              color: isSelected
                  ? AppColors.primary.withValues(alpha: 0.3)
                  : AppColors.glassBorder,
              width: 0.5,
            ),
          ),
          child: Text(
            label,
            style: TextStyle(
              fontSize: 13,
              fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
              color: isSelected ? AppColors.primary : AppColors.textSecondary,
            ),
          ),
        ),
      ),
    );
  }
}

// ============================================================================
// _OpChip
// ============================================================================

class _OpChip extends StatelessWidget {
  const _OpChip({
    required this.label,
    required this.icon,
    required this.iconColor,
    required this.isSelected,
    required this.onTap,
  });

  final String label;
  final IconData icon;

  final Color iconColor;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: AppSpacing.sm),
      child: PressableScale(
        onTap: () {
          Haptic.selection();
          onTap();
        },
        child: AnimatedContainer(
          duration: MotionDuration.fast,
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.md,
            vertical: AppSpacing.xs,
          ),
          decoration: BoxDecoration(
            color: isSelected
                ? AppColors.success.withValues(alpha: 0.12)
                : Colors.transparent,
            borderRadius: AppRadius.borderRadiusPill,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              GlassIcon(icon: icon, color: iconColor, size: 14),
              const SizedBox(width: 4),
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                  color:
                      isSelected ? AppColors.success : AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ============================================================================
// _ExerciseCard
// ============================================================================

class _ExerciseCard extends StatelessWidget {
  const _ExerciseCard({required this.exercise, required this.onTap});

  final RehabExercise exercise;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final color = ExerciseCategoryChip.categoryColor(exercise.category);

    return GlassCard(
      onTap: onTap,
      child: Padding(
        padding: AppSpacing.cardPadding,
        child: Row(
          children: [
            // Emoji bubble
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.12),
                borderRadius: AppRadius.borderRadiusMd,
              ),
              child: Center(
                child: GlassIcon(
                  icon: exercise.exerciseIcon,
                  color: exercise.exerciseIconColor,
                  size: 36,
                ),
              ),
            ),
            const SizedBox(width: AppSpacing.md),

            // Title + meta
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    exercise.title,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                      letterSpacing: -0.2,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      ExerciseCategoryChip(category: exercise.category),
                      const SizedBox(width: AppSpacing.sm),
                      _DifficultyDots(difficulty: exercise.difficulty),
                      const SizedBox(width: AppSpacing.sm),
                      Text(
                        '${exercise.sets}×${exercise.durationSeconds}s',
                        style: TextStyle(
                          fontSize: 11,
                          color: AppColors.textSecondary
                              .withValues(alpha: 0.7),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Arrow
            Container(
              width: 28,
              height: 28,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.08),
                borderRadius: AppRadius.borderRadiusXs,
              ),
              child: Icon(
                Icons.play_arrow_rounded,
                size: 18,
                color: color.withValues(alpha: 0.7),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ============================================================================
// _DifficultyDots
// ============================================================================

class _DifficultyDots extends StatelessWidget {
  const _DifficultyDots({required this.difficulty});
  final RehabDifficulty difficulty;

  @override
  Widget build(BuildContext context) {
    final filled = switch (difficulty) {
      RehabDifficulty.easy => 1,
      RehabDifficulty.medium => 2,
      RehabDifficulty.hard => 3,
    };

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(3, (i) {
        final active = i < filled;
        return Container(
          width: 6,
          height: 6,
          margin: const EdgeInsets.only(right: 2),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: active
                ? AppColors.warning.withValues(alpha: 0.8)
                : AppColors.grey300.withValues(alpha: 0.4),
          ),
        );
      }),
    );
  }
}
