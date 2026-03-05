import 'package:flutter/material.dart';

import '../../../ui/ui.dart';
import '../data/rehab_session_repository_sync.dart';
import '../domain/rehab_catalog.dart';
import '../domain/rehab_exercise.dart';
import '../domain/rehab_session.dart';
import 'rehab_exercise_detail_screen.dart';
import 'widgets/exercise_category_chip.dart';
import 'widgets/rehab_stats_banner.dart';

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
    final exercises = _filteredExercises;

    return GlassPage(
      title: 'Rehabilitation',
      titleEmoji: '🏋️',
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
                emoji: '🏥',
                isSelected: _selectedOpType == null,
                onTap: () => setState(() => _selectedOpType = null),
              ),
              _OpChip(
                label: 'Knie',
                emoji: '🦵',
                isSelected: _selectedOpType == 'knee',
                onTap: () => setState(() {
                  _selectedOpType =
                      _selectedOpType == 'knee' ? null : 'knee';
                }),
              ),
              _OpChip(
                label: 'Hüfte',
                emoji: '🦴',
                isSelected: _selectedOpType == 'hip',
                onTap: () => setState(() {
                  _selectedOpType =
                      _selectedOpType == 'hip' ? null : 'hip';
                }),
              ),
              _OpChip(
                label: 'Schulter',
                emoji: '💪',
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
    required this.emoji,
    required this.isSelected,
    required this.onTap,
  });

  final String label;
  final String emoji;
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
              Text(emoji, style: const TextStyle(fontSize: 14)),
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
                child: Text(
                  exercise.emoji,
                  style: const TextStyle(fontSize: 22),
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
