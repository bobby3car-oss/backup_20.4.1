import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../ui/ui.dart';
import '../data/doctor_notes_repository.dart';
import '../domain/doctor_note.dart';
import '../../../l10n/app_localizations.dart';

/// Available tags for categorizing doctor notes.
const _availableTags = ['Befund', 'Verlauf', 'TODO', 'Wichtig', 'Medikation'];

/// Tab shown inside PatientDetailScreen for private doctor notes.
class DoctorNotesTab extends StatefulWidget {
  const DoctorNotesTab({super.key, required this.patientId});

  final String patientId;

  @override
  State<DoctorNotesTab> createState() => _DoctorNotesTabState();
}

class _DoctorNotesTabState extends State<DoctorNotesTab> {
  final _repo = DoctorNotesRepository();

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    return StreamBuilder<List<DoctorNote>>(
      stream: _repo.watchNotes(widget.patientId),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        final notes = snapshot.data ?? [];

        if (notes.isEmpty) {
          return _EmptyState(onAdd: () => _showEditor(context));
        }

        return Stack(
          children: [
            ListView.builder(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.lg,
                AppSpacing.md,
                AppSpacing.lg,
                100,
              ),
              itemCount: notes.length,
              itemBuilder: (context, index) {
                final note = notes[index];
                return FadeSlideIn(
                  delay: Duration(milliseconds: 40 * index),
                  child: _NoteCard(
                    note: note,
                    onTap: () => _showEditor(context, note: note),
                    onTogglePin: () async {
                      try {
                        await _repo.togglePin(note.id, !note.pinned);
                      } catch (e) {
                        debugPrint('Error toggling pin: $e');
                        if (mounted) {
                          ScaffoldMessenger.of(this.context).showSnackBar(
                            SnackBar(content: Text(l.pinError)),
                          );
                        }
                      }
                    },
                    onDelete: () => _confirmDelete(note),
                  ),
                );
              },
            ),
            Positioned(
              left: AppSpacing.xl,
              bottom: AppSpacing.xl,
              child: PressableScale(
                child: FloatingActionButton(
                  onPressed: () => _showEditor(context),
                  backgroundColor: AppColors.primary,
                  child: const Icon(Icons.add, color: Colors.white),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Future<void> _showEditor(BuildContext context, {DoctorNote? note}) async {
    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _NoteEditorSheet(
        patientId: widget.patientId,
        note: note,
        repo: _repo,
      ),
    );
  }

  Future<void> _confirmDelete(DoctorNote note) async {
    final l = AppLocalizations.of(context)!;
    HapticFeedback.mediumImpact();
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l.noteDelete),
        content: Text('„${note.title}" wirklich löschen?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(l.cancel),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: FilledButton.styleFrom(backgroundColor: AppColors.error),
            child: Text(l.delete),
          ),
        ],
      ),
    );
    if (confirmed == true) {
      try {
        await _repo.deleteNote(note.id);
      } catch (e) {
        debugPrint('Error deleting note: $e');
        if (mounted) {
          final l = AppLocalizations.of(context)!;
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(l.noteDeleteError)),
          );
        }
      }
    }
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Note Card
// ─────────────────────────────────────────────────────────────────────────────

class _NoteCard extends StatelessWidget {
  const _NoteCard({
    required this.note,
    required this.onTap,
    required this.onTogglePin,
    required this.onDelete,
  });

  final DoctorNote note;
  final VoidCallback onTap;
  final VoidCallback onTogglePin;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: PressableScale(
        child: GlassCard(
          onTap: onTap,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  if (note.pinned)
                    Padding(
                      padding: const EdgeInsets.only(right: 6),
                      child: Icon(Icons.push_pin_rounded,
                          size: 14, color: AppColors.warning),
                    ),
                  Expanded(
                    child: Text(
                      note.title,
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  PopupMenuButton<String>(
                    iconSize: 18,
                    padding: EdgeInsets.zero,
                    onSelected: (v) {
                      if (v == 'pin') onTogglePin();
                      if (v == 'delete') onDelete();
                    },
                    itemBuilder: (_) => [
                      PopupMenuItem(
                        value: 'pin',
                        child: Text(
                            note.pinned ? 'Lospinnen' : 'Anpinnen'),
                      ),
                      PopupMenuItem(
                        value: 'delete',
                        child: Text(l.delete,
                            style: TextStyle(color: AppColors.error)),
                      ),
                    ],
                  ),
                ],
              ),
              if (note.content.isNotEmpty) ...[
                const SizedBox(height: 4),
                Text(
                  note.content,
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: AppColors.textSecondary,
                    height: 1.4,
                  ),
                ),
              ],
              if (note.tags.isNotEmpty) ...[
                const SizedBox(height: 8),
                Wrap(
                  spacing: 4,
                  runSpacing: 4,
                  children: note.tags.map((tag) {
                    final color = _tagColor(tag);
                    return Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: color.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        tag,
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: color,
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ],
              const SizedBox(height: 6),
              Text(
                _formatDate(note.updatedAt),
                style: theme.textTheme.labelSmall?.copyWith(
                  color: AppColors.grey400,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Color _tagColor(String tag) => switch (tag) {
        'Befund' => AppColors.primary,
        'Verlauf' => AppColors.success,
        'TODO' => AppColors.warning,
        'Wichtig' => AppColors.error,
        'Medikation' => AppColors.accent,
        _ => AppColors.grey500,
      };

  String _formatDate(DateTime d) {
    return '${d.day.toString().padLeft(2, '0')}.'
        '${d.month.toString().padLeft(2, '0')}.'
        '${d.year} – '
        '${d.hour.toString().padLeft(2, '0')}:'
        '${d.minute.toString().padLeft(2, '0')}';
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Editor Bottom Sheet
// ─────────────────────────────────────────────────────────────────────────────

class _NoteEditorSheet extends StatefulWidget {
  const _NoteEditorSheet({
    required this.patientId,
    required this.repo,
    this.note,
  });

  final String patientId;
  final DoctorNotesRepository repo;
  final DoctorNote? note;

  @override
  State<_NoteEditorSheet> createState() => _NoteEditorSheetState();
}

class _NoteEditorSheetState extends State<_NoteEditorSheet> {
  late final TextEditingController _titleCtrl;
  late final TextEditingController _contentCtrl;
  late final Set<String> _selectedTags;
  bool _saving = false;

  bool get _isEditing => widget.note != null;

  @override
  void initState() {
    super.initState();
    _titleCtrl = TextEditingController(text: widget.note?.title ?? '');
    _contentCtrl = TextEditingController(text: widget.note?.content ?? '');
    _selectedTags = Set.from(widget.note?.tags ?? []);
  }

  @override
  void dispose() {
    _titleCtrl.dispose();
    _contentCtrl.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final title = _titleCtrl.text.trim();
    if (title.isEmpty) return;
    setState(() => _saving = true);

    try {
      if (_isEditing) {
        await widget.repo.updateNote(
          noteId: widget.note!.id,
          title: title,
          content: _contentCtrl.text.trim(),
          tags: _selectedTags.toList(),
        );
      } else {
        await widget.repo.createNote(
          patientId: widget.patientId,
          title: title,
          content: _contentCtrl.text.trim(),
          tags: _selectedTags.toList(),
        );
      }
      if (mounted) Navigator.pop(context);
    } catch (_) {
      if (mounted) {
        final l = AppLocalizations.of(context)!;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l.saveFailed)),
        );
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;

    return Container(
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: const BorderRadius.vertical(
          top: Radius.circular(AppSpacing.xxl),
        ),
      ),
      padding: EdgeInsets.fromLTRB(
        AppSpacing.xl,
        AppSpacing.lg,
        AppSpacing.xl,
        bottomInset + AppSpacing.xl,
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Handle bar
            Center(
              child: Container(
                width: 36,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.grey300,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.lg),

            Text(
              _isEditing ? 'Notiz bearbeiten' : 'Neue Notiz',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: AppSpacing.lg),

            GlassTextField(
              controller: _titleCtrl,
              label: 'Titel',
              prefixIcon: Icons.title_rounded,
              textInputAction: TextInputAction.next,
            ),
            const SizedBox(height: AppSpacing.md),

            GlassTextField(
              controller: _contentCtrl,
              label: 'Inhalt',
              prefixIcon: Icons.notes_rounded,
              maxLines: 5,
              textInputAction: TextInputAction.newline,
            ),
            const SizedBox(height: AppSpacing.lg),

            // Tags
            Text(l.categories,
                style: theme.textTheme.labelMedium?.copyWith(
                  color: AppColors.textSecondary,
                )),
            const SizedBox(height: AppSpacing.sm),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _availableTags.map((tag) {
                final selected = _selectedTags.contains(tag);
                return GestureDetector(
                  onTap: () {
                    HapticFeedback.selectionClick();
                    setState(() {
                      if (selected) {
                        _selectedTags.remove(tag);
                      } else {
                        _selectedTags.add(tag);
                      }
                    });
                  },
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 14, vertical: 8),
                    decoration: BoxDecoration(
                      color: selected
                          ? AppColors.primary.withValues(alpha: 0.15)
                          : AppColors.grey100,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: selected
                            ? AppColors.primary
                            : AppColors.grey300,
                      ),
                    ),
                    child: Text(
                      tag,
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: selected
                            ? AppColors.primary
                            : AppColors.textSecondary,
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: AppSpacing.xxl),

            GlassButton(
              onPressed: _saving ? null : _save,
              label: _saving ? 'Speichern …' : l.save,
              icon: Icons.check_rounded,
              expand: true,
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────

class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.onAdd});
  final VoidCallback onAdd;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.note_add_outlined,
              size: 48, color: AppColors.grey400),
          const SizedBox(height: AppSpacing.md),
          Text(
            'Noch keine Notizen',
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  color: AppColors.textSecondary,
                ),
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            'Private Notizen zu diesem Patienten\nsind nur für Sie sichtbar.',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: AppColors.grey400,
                ),
          ),
          const SizedBox(height: AppSpacing.xl),
          GlassButton(
            onPressed: onAdd,
            label: 'Erste Notiz erstellen',
            icon: Icons.add_rounded,
          ),
        ],
      ),
    );
  }
}
