import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../../../ui/ui.dart';
import '../data/questions_repository_sync.dart';
import '../domain/doctor_question.dart';
import '../domain/suggested_questions.dart';
import 'question_editor.dart';
import '../../../ui/theme/app_icons.dart';

enum _QuestionFilter { all, open, answered, favorites }

class DoctorQuestionsScreen extends StatefulWidget {
  const DoctorQuestionsScreen({super.key});

  @override
  State<DoctorQuestionsScreen> createState() => _DoctorQuestionsScreenState();
}

class _DoctorQuestionsScreenState extends State<DoctorQuestionsScreen> {
  static final QuestionsRepositorySync _repository =
      QuestionsRepositorySync.instance;

  QuestionCategory _selectedCategory = QuestionCategory.surgeon;
  _QuestionFilter _activeFilter = _QuestionFilter.all;
  bool _sortFavoritesFirst = true;

  @override
  void initState() {
    super.initState();
    _bootstrap();
  }

  Future<void> _bootstrap() async {
    await _repository.loadFromDisk();
    await _repository.seedDefaultsIfEmpty();
    await _repository.pullLatest();
  }

  @override
  Widget build(BuildContext context) {
    return GlassPage(
      title: 'Fragen für den Arzt',
      titleIcon: AppIcons.questions,
      titleColor: const Color(0xFF0A84FF),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _addQuestion,
        icon: const Icon(Icons.add_rounded),
        label: const Text('Frage hinzufügen'),
      ),
      body: StreamBuilder<List<DoctorQuestion>>(
        stream: _repository.watchAll(),
        builder: (context, snapshot) {
          final all = (snapshot.data ?? const <DoctorQuestion>[]).toList();
          final surgeon = _questionsForCategory(
            all,
            QuestionCategory.surgeon,
          );
          final anesthetist = _questionsForCategory(
            all,
            QuestionCategory.anesthetist,
          );
          final selected = _selectedCategory == QuestionCategory.surgeon
              ? surgeon
              : anesthetist;

          final openCount = selected
              .where((question) => question.status == QuestionStatus.open)
              .length;
          final askedCount = selected
              .where((question) => question.status == QuestionStatus.asked)
              .length;
          final answeredCount = selected
              .where((question) => question.status == QuestionStatus.answered)
              .length;
          final favoriteCount = selected
              .where((question) => question.favorite)
              .length;

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _QuestionsHeroCard(
                category: _selectedCategory,
                totalCount: selected.length,
                favoriteCount: favoriteCount,
                onAdd: _addQuestion,
              ),
              const SizedBox(height: AppSpacing.lg),
              _CategorySwitcher(
                selectedCategory: _selectedCategory,
                surgeonCount: surgeon.length,
                anesthetistCount: anesthetist.length,
                onChanged: (category) {
                  if (_selectedCategory == category) return;
                  setState(() => _selectedCategory = category);
                },
              ),
              const SizedBox(height: AppSpacing.lg),
              Row(
                children: [
                  Expanded(
                    child: _StatCard(
                      label: 'Offen',
                      value: '$openCount',
                      color: AppColors.warning,
                      icon: Icons.radio_button_unchecked_rounded,
                    ),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Expanded(
                    child: _StatCard(
                      label: 'Gestellt',
                      value: '$askedCount',
                      color: const Color(0xFF0A84FF),
                      icon: Icons.chat_bubble_outline_rounded,
                    ),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Expanded(
                    child: _StatCard(
                      label: 'Beantwortet',
                      value: '$answeredCount',
                      color: AppColors.success,
                      icon: Icons.check_circle_outline_rounded,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.lg),
              _FilterChips(
                activeFilter: _activeFilter,
                onChanged: (f) => setState(() => _activeFilter = f),
                sortFavoritesFirst: _sortFavoritesFirst,
                onSortToggle: () => setState(
                  () => _sortFavoritesFirst = !_sortFavoritesFirst,
                ),
              ),
              const SizedBox(height: AppSpacing.xl),
              Text(
                _selectedCategory == QuestionCategory.surgeon
                    ? 'Für das Gespräch mit dem Operateur'
                    : 'Für das Gespräch mit dem Anästhesisten',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w800,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: AppSpacing.xs),
              Text(
                selected.isEmpty
                    ? 'Noch keine Fragen gespeichert.'
                    : '${selected.length} Frage${selected.length == 1 ? '' : 'n'} vorbereitet.',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              // ── Suggested questions ─────────────────────────────
              _SuggestedQuestionsSection(
                existingTexts:
                    selected.map((q) => q.text).toSet(),
                onPick: (text) => _addFromSuggestion(text),
              ),
              const SizedBox(height: AppSpacing.lg),
              if (_filtered(selected).isEmpty)
                _EmptyQuestionsState(
                  category: _selectedCategory,
                  onAdd: _addQuestion,
                )
              else
                ..._filtered(selected).map(
                  (item) => Padding(
                    padding: const EdgeInsets.only(bottom: AppSpacing.md),
                    child: _QuestionCard(
                      item: item,
                      onFavorite: () => _toggleFavorite(item),
                      onStatus: () => _cycleStatus(item),
                      onEdit: () => _editQuestion(item),
                      onDelete: item.isDefault ? null : () => _delete(item),
                    ),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }

  List<DoctorQuestion> _questionsForCategory(
    List<DoctorQuestion> all,
    QuestionCategory category,
  ) {
    final filtered = all
        .where((question) => question.category == category)
        .toList(growable: false);
    filtered.sort(_compareQuestions);
    return filtered;
  }

  /// Applies the active filter chip to the already-sorted list.
  List<DoctorQuestion> _filtered(List<DoctorQuestion> items) {
    return switch (_activeFilter) {
      _QuestionFilter.all => items,
      _QuestionFilter.open =>
        items.where((q) => q.status == QuestionStatus.open).toList(),
      _QuestionFilter.answered =>
        items.where((q) => q.status == QuestionStatus.answered).toList(),
      _QuestionFilter.favorites =>
        items.where((q) => q.favorite).toList(),
    };
  }

  int _compareQuestions(DoctorQuestion a, DoctorQuestion b) {
    if (_sortFavoritesFirst) {
      final favoriteCompare =
          (b.favorite ? 1 : 0).compareTo(a.favorite ? 1 : 0);
      if (favoriteCompare != 0) return favoriteCompare;
    }

    final statusCompare =
        _statusPriority(a.status).compareTo(_statusPriority(b.status));
    if (statusCompare != 0) return statusCompare;

    return b.updatedAt.compareTo(a.updatedAt);
  }

  int _statusPriority(QuestionStatus status) {
    return switch (status) {
      QuestionStatus.open => 0,
      QuestionStatus.asked => 1,
      QuestionStatus.answered => 2,
    };
  }

  Future<void> _addQuestion() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null || uid.trim().isEmpty) {
      _showSignedOutMessage();
      return;
    }

    final result = await showDialog<QuestionEditorResult>(
      context: context,
      builder: (context) => QuestionEditorDialog(
        initialCategory: _selectedCategory,
      ),
    );

    if (result == null) return;

    final now = DateTime.now();
    try {
      await _repository.upsert(
        DoctorQuestion(
          id: 'question_${now.microsecondsSinceEpoch}',
          ownerId: uid,
          text: result.text,
          category: result.category,
          status: QuestionStatus.open,
          favorite: false,
          createdAt: now,
          updatedAt: now,
          isDefault: false,
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(userFacingError(e))),
      );
      return;
    }

    if (mounted && _selectedCategory != result.category) {
      setState(() => _selectedCategory = result.category);
    }
  }

  /// Adds a question from the suggested-questions list directly.
  Future<void> _addFromSuggestion(String text) async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null || uid.trim().isEmpty) {
      _showSignedOutMessage();
      return;
    }

    final now = DateTime.now();
    try {
      await _repository.upsert(
        DoctorQuestion(
          id: 'question_${now.microsecondsSinceEpoch}',
          ownerId: uid,
          text: text,
          category: _selectedCategory,
          status: QuestionStatus.open,
          favorite: false,
          createdAt: now,
          updatedAt: now,
          isDefault: false,
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(userFacingError(e))),
      );
    }
  }

  Future<void> _editQuestion(DoctorQuestion question) async {
    final result = await showDialog<QuestionEditorResult>(
      context: context,
      builder: (context) => QuestionEditorDialog(
        title: 'Frage bearbeiten',
        initialText: question.text,
        initialCategory: question.category,
      ),
    );

    if (result == null) return;

    try {
      await _repository.upsert(
        question.copyWith(
          text: result.text,
          category: result.category,
          updatedAt: DateTime.now(),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(userFacingError(e))),
      );
      return;
    }

    if (mounted && _selectedCategory != result.category) {
      setState(() => _selectedCategory = result.category);
    }
  }

  Future<void> _toggleFavorite(DoctorQuestion question) async {
    try {
      await _repository.upsert(
        question.copyWith(
          favorite: !question.favorite,
          updatedAt: DateTime.now(),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(userFacingError(e))),
      );
    }
  }

  Future<void> _cycleStatus(DoctorQuestion question) async {
    final next = switch (question.status) {
      QuestionStatus.open => QuestionStatus.asked,
      QuestionStatus.asked => QuestionStatus.answered,
      QuestionStatus.answered => QuestionStatus.open,
    };

    try {
      await _repository.upsert(
        question.copyWith(
          status: next,
          updatedAt: DateTime.now(),
          clearAnswer: next == QuestionStatus.open,
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(userFacingError(e))),
      );
    }
  }

  Future<void> _delete(DoctorQuestion question) async {
    if (question.isDefault) return;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Frage löschen?'),
        content: Text(
          '"${question.text}" wird aus deiner Liste entfernt.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Abbrechen'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: AppColors.error,
              foregroundColor: Colors.white,
            ),
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Löschen'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    try {
      await _repository.delete(question.id);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(userFacingError(e))),
      );
    }
  }

  void _showSignedOutMessage() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Bitte melde dich an, um Fragen zu speichern.'),
      ),
    );
  }
}

class _QuestionsHeroCard extends StatelessWidget {
  const _QuestionsHeroCard({
    required this.category,
    required this.totalCount,
    required this.favoriteCount,
    required this.onAdd,
  });

  final QuestionCategory category;
  final int totalCount;
  final int favoriteCount;
  final VoidCallback onAdd;

  @override
  Widget build(BuildContext context) {
    final accentColor = _categoryColor(category);

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            accentColor.withValues(alpha: 0.18),
            AppColors.white.withValues(alpha: 0.78),
          ],
        ),
        borderRadius: AppRadius.borderRadiusXl,
        border: Border.all(color: accentColor.withValues(alpha: 0.12)),
        boxShadow: [
          BoxShadow(
            color: accentColor.withValues(alpha: 0.10),
            blurRadius: 22,
            offset: const Offset(0, 8),
            spreadRadius: -10,
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: accentColor.withValues(alpha: 0.14),
                    borderRadius: AppRadius.borderRadiusMd,
                  ),
                  child: Icon(
                    category == QuestionCategory.surgeon
                        ? Icons.medical_information_rounded
                        : Icons.air_rounded,
                    color: accentColor,
                  ),
                ),
                const Spacer(),
                _MiniInfoPill(
                  label: '$favoriteCount gemerkt',
                  color: AppColors.warning,
                  icon: Icons.star_rounded,
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.lg),
            Text(
              category == QuestionCategory.surgeon
                  ? 'Gut vorbereitet ins Operateur-Gespräch'
                  : 'Alle Punkte für das Narkosegespräch parat',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.w800,
                color: AppColors.textPrimary,
                letterSpacing: -0.4,
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              category == QuestionCategory.surgeon
                  ? 'Halte wichtige Fragen fest, markiere Favoriten und hake Antworten direkt nach dem Termin ab.'
                  : 'Sammle Fragen zu Narkose, Vorbereitung und Risiken an einer Stelle und verliere im Gespräch nichts mehr.',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                height: 1.45,
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            Row(
              children: [
                _HeroMetric(
                  label: 'Gesamt',
                  value: '$totalCount',
                  color: accentColor,
                ),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: Align(
                    alignment: Alignment.centerRight,
                    child: FilledButton.icon(
                      onPressed: onAdd,
                      icon: const Icon(Icons.add_rounded),
                      label: const Text('Neue Frage'),
                      style: FilledButton.styleFrom(
                        backgroundColor: accentColor,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppSpacing.lg,
                          vertical: AppSpacing.md,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: AppRadius.borderRadiusMd,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _CategorySwitcher extends StatelessWidget {
  const _CategorySwitcher({
    required this.selectedCategory,
    required this.surgeonCount,
    required this.anesthetistCount,
    required this.onChanged,
  });

  final QuestionCategory selectedCategory;
  final int surgeonCount;
  final int anesthetistCount;
  final ValueChanged<QuestionCategory> onChanged;

  @override
  Widget build(BuildContext context) {
    return GlassContainer(
      variant: GlassVariant.thin,
      borderRadius: AppRadius.borderRadiusLg,
      padding: const EdgeInsets.all(AppSpacing.xs),
      child: Row(
        children: [
          Expanded(
            child: _CategoryButton(
              category: QuestionCategory.surgeon,
              count: surgeonCount,
              selected: selectedCategory == QuestionCategory.surgeon,
              onTap: () => onChanged(QuestionCategory.surgeon),
            ),
          ),
          const SizedBox(width: AppSpacing.xs),
          Expanded(
            child: _CategoryButton(
              category: QuestionCategory.anesthetist,
              count: anesthetistCount,
              selected: selectedCategory == QuestionCategory.anesthetist,
              onTap: () => onChanged(QuestionCategory.anesthetist),
            ),
          ),
        ],
      ),
    );
  }
}

class _CategoryButton extends StatelessWidget {
  const _CategoryButton({
    required this.category,
    required this.count,
    required this.selected,
    required this.onTap,
  });

  final QuestionCategory category;
  final int count;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final color = _categoryColor(category);

    return PressableScale(
      onTap: onTap,
      scaleFactor: 0.98,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.md,
        ),
        decoration: BoxDecoration(
          color: selected ? color.withValues(alpha: 0.14) : Colors.transparent,
          borderRadius: AppRadius.borderRadiusMd,
          border: Border.all(
            color: selected
                ? color.withValues(alpha: 0.22)
                : AppColors.white.withValues(alpha: 0.26),
          ),
        ),
        child: Row(
          children: [
            Icon(
              category == QuestionCategory.surgeon
                  ? Icons.medical_services_rounded
                  : Icons.monitor_heart_outlined,
              size: 18,
              color: selected ? color : AppColors.textSecondary,
            ),
            const SizedBox(width: AppSpacing.sm),
            Expanded(
              child: Text(
                category.label,
                style: TextStyle(
                  fontWeight: FontWeight.w700,
                  color: selected
                      ? AppColors.textPrimary
                      : AppColors.textSecondary,
                ),
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.sm,
                vertical: AppSpacing.xs,
              ),
              decoration: BoxDecoration(
                color: color.withValues(alpha: selected ? 0.18 : 0.08),
                borderRadius: AppRadius.borderRadiusPill,
              ),
              child: Text(
                '$count',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w800,
                  color: color,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard({
    required this.label,
    required this.value,
    required this.color,
    required this.icon,
  });

  final String label;
  final String value;
  final Color color;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return GlassContainer(
      variant: GlassVariant.thin,
      elevation: GlassElevation.low,
      borderRadius: AppRadius.borderRadiusMd,
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 18, color: color),
          const SizedBox(height: AppSpacing.sm),
          Text(
            value,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w800,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            label,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}

class _EmptyQuestionsState extends StatelessWidget {
  const _EmptyQuestionsState({
    required this.category,
    required this.onAdd,
  });

  final QuestionCategory category;
  final VoidCallback onAdd;

  @override
  Widget build(BuildContext context) {
    final accentColor = _categoryColor(category);

    return GlassContainer(
      variant: GlassVariant.medium,
      borderRadius: AppRadius.borderRadiusXl,
      padding: const EdgeInsets.all(AppSpacing.xl),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: accentColor.withValues(alpha: 0.12),
              borderRadius: AppRadius.borderRadiusMd,
            ),
            child: Icon(
              Icons.playlist_add_check_circle_outlined,
              color: accentColor,
              size: 28,
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          Text(
            category == QuestionCategory.surgeon
                ? 'Lege deine erste Frage für den Operateur an'
                : 'Lege deine erste Frage für den Anästhesisten an',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w800,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            'So gehst du strukturierter ins Gespräch und kannst Antworten später direkt als erledigt markieren.',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: AppColors.textSecondary,
              height: 1.45,
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          OutlinedButton.icon(
            onPressed: onAdd,
            icon: const Icon(Icons.add_rounded),
            label: const Text('Frage anlegen'),
            style: OutlinedButton.styleFrom(
              foregroundColor: accentColor,
              side: BorderSide(color: accentColor.withValues(alpha: 0.24)),
              shape: RoundedRectangleBorder(
                borderRadius: AppRadius.borderRadiusMd,
              ),
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.lg,
                vertical: AppSpacing.md,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _QuestionCard extends StatelessWidget {
  const _QuestionCard({
    required this.item,
    required this.onFavorite,
    required this.onStatus,
    required this.onEdit,
    required this.onDelete,
  });

  final DoctorQuestion item;
  final VoidCallback onFavorite;
  final VoidCallback onStatus;
  final VoidCallback onEdit;
  final VoidCallback? onDelete;

  @override
  Widget build(BuildContext context) {
    final categoryColor = _categoryColor(item.category);
    final statusColor = _statusColor(item.status);

    return GlassContainer(
      variant: GlassVariant.medium,
      elevation: GlassElevation.low,
      borderRadius: AppRadius.borderRadiusXl,
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              _StatusChip(status: item.status),
              const SizedBox(width: AppSpacing.sm),
              _InlineTag(
                label: item.category.label,
                color: categoryColor,
                icon: item.category == QuestionCategory.surgeon
                    ? Icons.medical_services_rounded
                    : Icons.monitor_heart_outlined,
              ),
              const Spacer(),
              if (item.favorite)
                Icon(
                  Icons.star_rounded,
                  size: 18,
                  color: AppColors.warning,
                ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          Text(
            item.text,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
              height: 1.35,
            ),
          ),
          // Show the doctor's answer if present.
          if (item.answer != null && item.answer!.trim().isNotEmpty) ...[
            const SizedBox(height: AppSpacing.sm),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(AppSpacing.md),
              decoration: BoxDecoration(
                color: AppColors.success.withValues(alpha: 0.08),
                borderRadius: AppRadius.borderRadiusMd,
                border: Border.all(
                  color: AppColors.success.withValues(alpha: 0.18),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.question_answer_rounded,
                        size: 14,
                        color: AppColors.success,
                      ),
                      const SizedBox(width: AppSpacing.xs),
                      Text(
                        'Antwort',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w800,
                          color: AppColors.success,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    item.answer!,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppColors.textPrimary,
                      height: 1.4,
                    ),
                  ),
                ],
              ),
            ),
          ],
          const SizedBox(height: AppSpacing.md),
          Wrap(
            spacing: AppSpacing.sm,
            runSpacing: AppSpacing.sm,
            children: [
              if (item.isDefault)
                _InlineTag(
                  label: 'Vorlage',
                  color: AppColors.accent,
                  icon: Icons.auto_awesome_rounded,
                ),
              _InlineTag(
                label: _nextStatusLabel(item.status),
                color: statusColor,
                icon: Icons.loop_rounded,
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.lg),
          Wrap(
            spacing: AppSpacing.sm,
            runSpacing: AppSpacing.sm,
            children: [
              _QuestionActionButton(
                label: 'Bearbeiten',
                icon: Icons.edit_outlined,
                color: const Color(0xFF0A84FF),
                onTap: onEdit,
              ),
              _QuestionActionButton(
                label: _nextStatusLabel(item.status),
                icon: Icons.loop_rounded,
                color: statusColor,
                onTap: onStatus,
              ),
              _QuestionActionButton(
                label: item.favorite ? 'Merker raus' : 'Merken',
                icon: item.favorite
                    ? Icons.star_rounded
                    : Icons.star_border_rounded,
                color: AppColors.warning,
                onTap: onFavorite,
              ),
              if (onDelete != null)
                _QuestionActionButton(
                  label: 'Löschen',
                  icon: Icons.delete_outline_rounded,
                  color: AppColors.error,
                  onTap: onDelete!,
                ),
            ],
          ),
        ],
      ),
    );
  }
}

class _QuestionActionButton extends StatelessWidget {
  const _QuestionActionButton({
    required this.label,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return PressableScale(
      onTap: onTap,
      scaleFactor: 0.97,
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.sm,
        ),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.08),
          borderRadius: AppRadius.borderRadiusPill,
          border: Border.all(color: color.withValues(alpha: 0.16)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 16, color: color),
            const SizedBox(width: AppSpacing.xs),
            Text(
              label,
              style: TextStyle(
                color: color,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _HeroMetric extends StatelessWidget {
  const _HeroMetric({
    required this.label,
    required this.value,
    required this.color,
  });

  final String label;
  final String value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.sm,
      ),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.10),
        borderRadius: AppRadius.borderRadiusMd,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            value,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w800,
              color: color,
            ),
          ),
          Text(
            label,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}

class _MiniInfoPill extends StatelessWidget {
  const _MiniInfoPill({
    required this.label,
    required this.color,
    required this.icon,
  });

  final String label;
  final Color color;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: AppSpacing.sm,
      ),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.10),
        borderRadius: AppRadius.borderRadiusPill,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: AppSpacing.xs),
          Text(
            label,
            style: TextStyle(
              fontWeight: FontWeight.w700,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}

class _InlineTag extends StatelessWidget {
  const _InlineTag({
    required this.label,
    required this.color,
    required this.icon,
  });

  final String label;
  final Color color;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: AppSpacing.xs + 2,
      ),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.10),
        borderRadius: AppRadius.borderRadiusPill,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: AppSpacing.xs),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}

class _StatusChip extends StatelessWidget {
  const _StatusChip({required this.status});

  final QuestionStatus status;

  @override
  Widget build(BuildContext context) {
    final color = _statusColor(status);

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: AppSpacing.xs + 2,
      ),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.13),
        borderRadius: AppRadius.borderRadiusPill,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(_statusIcon(status), size: 14, color: color),
          const SizedBox(width: AppSpacing.xs),
          Text(
            status.label,
            style: TextStyle(
              color: color,
              fontSize: 11,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }
}

Color _categoryColor(QuestionCategory category) {
  return switch (category) {
    QuestionCategory.surgeon => const Color(0xFF0A84FF),
    QuestionCategory.anesthetist => const Color(0xFF5E5CE6),
  };
}

// ── Filter Chips ─────────────────────────────────────────────────────────────

class _FilterChips extends StatelessWidget {
  const _FilterChips({
    required this.activeFilter,
    required this.onChanged,
    required this.sortFavoritesFirst,
    required this.onSortToggle,
  });

  final _QuestionFilter activeFilter;
  final ValueChanged<_QuestionFilter> onChanged;
  final bool sortFavoritesFirst;
  final VoidCallback onSortToggle;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              _chip(context, _QuestionFilter.all, 'Alle', Icons.list_rounded),
              const SizedBox(width: AppSpacing.sm),
              _chip(context, _QuestionFilter.open, 'Offen',
                  Icons.radio_button_unchecked_rounded),
              const SizedBox(width: AppSpacing.sm),
              _chip(context, _QuestionFilter.answered, 'Beantwortet',
                  Icons.check_circle_outline_rounded),
              const SizedBox(width: AppSpacing.sm),
              _chip(context, _QuestionFilter.favorites, 'Favoriten',
                  Icons.star_rounded),
              const SizedBox(width: AppSpacing.md),
              ActionChip(
                avatar: Icon(
                  sortFavoritesFirst
                      ? Icons.star_rounded
                      : Icons.access_time_rounded,
                  size: 16,
                  color: AppColors.textSecondary,
                ),
                label: Text(
                  sortFavoritesFirst ? 'Favoriten zuerst' : 'Neueste zuerst',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textSecondary,
                  ),
                ),
                onPressed: onSortToggle,
                side: BorderSide(
                  color: AppColors.grey300.withValues(alpha: 0.5),
                ),
                shape: const StadiumBorder(),
                backgroundColor: Colors.transparent,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _chip(
    BuildContext context,
    _QuestionFilter filter,
    String label,
    IconData icon,
  ) {
    final selected = activeFilter == filter;
    final color = const Color(0xFF0A84FF);
    return FilterChip(
      selected: selected,
      showCheckmark: false,
      avatar: Icon(icon, size: 16, color: selected ? color : AppColors.textSecondary),
      label: Text(
        label,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w700,
          color: selected ? color : AppColors.textSecondary,
        ),
      ),
      selectedColor: color.withValues(alpha: 0.12),
      side: BorderSide(
        color: selected ? color.withValues(alpha: 0.3) : AppColors.grey300.withValues(alpha: 0.5),
      ),
      shape: const StadiumBorder(),
      backgroundColor: Colors.transparent,
      onSelected: (_) => onChanged(filter),
    );
  }
}

// ── Suggested Questions ──────────────────────────────────────────────────────

class _SuggestedQuestionsSection extends StatefulWidget {
  const _SuggestedQuestionsSection({
    required this.existingTexts,
    required this.onPick,
  });

  final Set<String> existingTexts;
  final ValueChanged<String> onPick;

  @override
  State<_SuggestedQuestionsSection> createState() =>
      _SuggestedQuestionsSectionState();
}

class _SuggestedQuestionsSectionState
    extends State<_SuggestedQuestionsSection> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    final suggestions = suggestedQuestionsFor(null);
    // Remove already-added questions.
    final available = suggestions
        .where((s) => !widget.existingTexts.contains(s))
        .toList(growable: false);

    if (available.isEmpty) return const SizedBox.shrink();

    final visible = _expanded ? available : available.take(3).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(Icons.auto_awesome_rounded, size: 18, color: AppColors.accent),
            const SizedBox(width: AppSpacing.xs),
            Text(
              'Vorgeschlagene Fragen',
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w800,
                color: AppColors.textPrimary,
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.sm),
        ...visible.map((text) => Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.sm),
              child: PressableScale(
                onTap: () => widget.onPick(text),
                scaleFactor: 0.98,
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.md,
                    vertical: AppSpacing.md,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.accent.withValues(alpha: 0.06),
                    borderRadius: AppRadius.borderRadiusMd,
                    border: Border.all(
                      color: AppColors.accent.withValues(alpha: 0.14),
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.add_circle_outline_rounded,
                        size: 18,
                        color: AppColors.accent,
                      ),
                      const SizedBox(width: AppSpacing.sm),
                      Expanded(
                        child: Text(
                          text,
                          style:
                              Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: AppColors.textPrimary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            )),
        if (available.length > 3)
          TextButton.icon(
            onPressed: () => setState(() => _expanded = !_expanded),
            icon: Icon(
              _expanded
                  ? Icons.expand_less_rounded
                  : Icons.expand_more_rounded,
              size: 18,
            ),
            label: Text(_expanded
                ? 'Weniger anzeigen'
                : '${available.length - 3} weitere Vorschläge'),
            style: TextButton.styleFrom(
              foregroundColor: AppColors.accent,
            ),
          ),
      ],
    );
  }
}

Color _statusColor(QuestionStatus status) {
  return switch (status) {
    QuestionStatus.open => AppColors.warning,
    QuestionStatus.asked => const Color(0xFF0A84FF),
    QuestionStatus.answered => AppColors.success,
  };
}

IconData _statusIcon(QuestionStatus status) {
  return switch (status) {
    QuestionStatus.open => Icons.radio_button_unchecked_rounded,
    QuestionStatus.asked => Icons.chat_bubble_outline_rounded,
    QuestionStatus.answered => Icons.check_circle_rounded,
  };
}

String _nextStatusLabel(QuestionStatus status) {
  return switch (status) {
    QuestionStatus.open => 'Als gestellt markieren',
    QuestionStatus.asked => 'Als beantwortet markieren',
    QuestionStatus.answered => 'Wieder öffnen',
  };
}
