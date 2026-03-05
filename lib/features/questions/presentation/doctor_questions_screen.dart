import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../../../ui/ui.dart';
import '../data/questions_repository_sync.dart';
import '../domain/doctor_question.dart';

class DoctorQuestionsScreen extends StatefulWidget {
  const DoctorQuestionsScreen({super.key});

  @override
  State<DoctorQuestionsScreen> createState() => _DoctorQuestionsScreenState();
}

class _DoctorQuestionsScreenState extends State<DoctorQuestionsScreen>
    with SingleTickerProviderStateMixin {
  static final QuestionsRepositorySync _repository =
      QuestionsRepositorySync.instance;
  late final TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _bootstrap();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
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
      titleEmoji: '❓',
      titleColor: AppColors.accent,
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _addQuestion,
        icon: const Icon(Icons.add),
        label: const Text('Frage hinzufügen'),
      ),
      scrollableBody: (headerHeight) => Column(
        children: [
          SizedBox(height: headerHeight),
          Material(
            color: Colors.transparent,
            child: TabBar(
              controller: _tabController,
              tabs: const [
                Tab(text: 'Operateur'),
                Tab(text: 'Anästhesist'),
              ],
            ),
          ),
          Expanded(
            child: StreamBuilder<List<DoctorQuestion>>(
              stream: _repository.watchAll(),
              builder: (context, snapshot) {
                final all = snapshot.data ?? const <DoctorQuestion>[];
                final surgeon = all
                    .where((q) => q.category == QuestionCategory.surgeon)
                    .toList(growable: false);
                final anesthetist = all
                    .where((q) => q.category == QuestionCategory.anesthetist)
                    .toList(growable: false);

                return TabBarView(
                  controller: _tabController,
                  children: [
                    _QuestionsList(
                      items: surgeon,
                      onFavorite: _toggleFavorite,
                      onStatus: _cycleStatus,
                      onDelete: _delete,
                    ),
                    _QuestionsList(
                      items: anesthetist,
                      onFavorite: _toggleFavorite,
                      onStatus: _cycleStatus,
                      onDelete: _delete,
                    ),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _addQuestion() async {
    final textController = TextEditingController();
    QuestionCategory category = _tabController.index == 0
        ? QuestionCategory.surgeon
        : QuestionCategory.anesthetist;

    final created = await showDialog<DoctorQuestion>(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: const Text('Neue Frage'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: textController,
                    decoration: const InputDecoration(labelText: 'Frage'),
                    autofocus: true,
                  ),
                  const SizedBox(height: 10),
                  DropdownButtonFormField<QuestionCategory>(
                    initialValue: category,
                    items: QuestionCategory.values
                        .map(
                          (c) =>
                              DropdownMenuItem(value: c, child: Text(c.label)),
                        )
                        .toList(growable: false),
                    onChanged: (value) {
                      if (value == null) return;
                      setDialogState(() => category = value);
                    },
                    decoration: const InputDecoration(labelText: 'Kategorie'),
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(dialogContext).pop(),
                  child: const Text('Abbrechen'),
                ),
                FilledButton(
                  onPressed: () {
                    final text = textController.text.trim();
                    if (text.isEmpty) return;
                    final uid = FirebaseAuth.instance.currentUser?.uid;
                    if (uid == null || uid.trim().isEmpty) {
                      Navigator.of(dialogContext).pop();
                      return;
                    }
                    final now = DateTime.now();
                    Navigator.of(dialogContext).pop(
                      DoctorQuestion(
                        id: 'question_${now.microsecondsSinceEpoch}',
                        ownerId: uid,
                        text: text,
                        category: category,
                        status: QuestionStatus.open,
                        favorite: false,
                        createdAt: now,
                        updatedAt: now,
                        isDefault: false,
                      ),
                    );
                  },
                  child: const Text('Speichern'),
                ),
              ],
            );
          },
        );
      },
    );
    textController.dispose();

    if (created == null) return;
    await _repository.upsert(created);
  }

  Future<void> _toggleFavorite(DoctorQuestion q) async {
    await _repository.upsert(
      q.copyWith(favorite: !q.favorite, updatedAt: DateTime.now()),
    );
  }

  Future<void> _cycleStatus(DoctorQuestion q) async {
    final next = switch (q.status) {
      QuestionStatus.open => QuestionStatus.asked,
      QuestionStatus.asked => QuestionStatus.answered,
      QuestionStatus.answered => QuestionStatus.open,
    };
    await _repository.upsert(
      q.copyWith(status: next, updatedAt: DateTime.now()),
    );
  }

  Future<void> _delete(DoctorQuestion q) async {
    if (q.isDefault) return;
    await _repository.delete(q.id);
  }
}

class _QuestionsList extends StatelessWidget {
  const _QuestionsList({
    required this.items,
    required this.onFavorite,
    required this.onStatus,
    required this.onDelete,
  });

  final List<DoctorQuestion> items;
  final ValueChanged<DoctorQuestion> onFavorite;
  final ValueChanged<DoctorQuestion> onStatus;
  final ValueChanged<DoctorQuestion> onDelete;

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) {
      return const Center(child: Text('Keine Fragen vorhanden.'));
    }
    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(12, 12, 12, 100),
      itemCount: items.length,
      itemBuilder: (context, index) {
        final item = items[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 8),
          child: ListTile(
            title: Text(item.text),
            subtitle: Row(
              children: [
                _StatusChip(status: item.status),
                const SizedBox(width: 8),
                Text(item.category.label),
              ],
            ),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  tooltip: 'Status weiter',
                  onPressed: () => onStatus(item),
                  icon: const Icon(Icons.loop_rounded),
                ),
                IconButton(
                  tooltip: item.favorite ? 'Favorit entfernen' : 'Favorit',
                  onPressed: () => onFavorite(item),
                  icon: Icon(
                    item.favorite
                        ? Icons.star_rounded
                        : Icons.star_border_rounded,
                  ),
                ),
                IconButton(
                  tooltip: 'Löschen',
                  onPressed: item.isDefault ? null : () => onDelete(item),
                  icon: const Icon(Icons.delete_outline_rounded),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _StatusChip extends StatelessWidget {
  const _StatusChip({required this.status});

  final QuestionStatus status;

  @override
  Widget build(BuildContext context) {
    final color = switch (status) {
      QuestionStatus.open => Colors.grey,
      QuestionStatus.asked => Colors.orange,
      QuestionStatus.answered => Colors.green,
    };
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.13),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        status.label,
        style: TextStyle(
          color: color,
          fontSize: 11,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}
