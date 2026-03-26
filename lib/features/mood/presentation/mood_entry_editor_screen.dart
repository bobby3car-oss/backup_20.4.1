import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../auth/guest_data_migration_service.dart';
import '../../../ui/ui.dart';
import '../data/mood_repository_sync.dart';
import '../domain/mood_entry.dart';
import '../../../l10n/app_localizations.dart';

class MoodEntryEditorScreen extends StatefulWidget {
  const MoodEntryEditorScreen({super.key, this.initialEntry, this.entryId});

  final MoodEntry? initialEntry;
  final String? entryId;

  @override
  State<MoodEntryEditorScreen> createState() => _MoodEntryEditorScreenState();
}

class _MoodEntryEditorScreenState extends State<MoodEntryEditorScreen> {
  static final MoodRepositorySync _repository = MoodRepositorySync.instance;

  final _noteController = TextEditingController();

  MoodEntry? _editing;
  bool _loading = true;
  bool _saving = false;

  MoodLevel _moodLevel = MoodLevel.neutral;
  List<MoodCategory> _categories = [];
  double _sleepHours = 7.0;
  bool _trackSleep = false;
  int _sleepQuality = 3;

  bool get _isEditMode => _editing != null;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _bootstrap());
  }

  @override
  void dispose() {
    _noteController.dispose();
    super.dispose();
  }

  Future<void> _bootstrap() async {
    final routeArgs = ModalRoute.of(context)?.settings.arguments;
    MoodEntry? initial = widget.initialEntry;
    String? entryId = widget.entryId;

    if (routeArgs is MoodEntry) {
      initial = routeArgs;
    } else if (routeArgs is Map) {
      if (routeArgs['entry'] is MoodEntry) {
        initial = routeArgs['entry'] as MoodEntry;
      }
      entryId ??= routeArgs['entryId']?.toString();
    } else if (routeArgs is String && routeArgs.trim().isNotEmpty) {
      entryId ??= routeArgs.trim();
    }

    if (initial == null && entryId != null) {
      initial = await _repository.getById(entryId);
    }

    _editing = initial;
    if (initial != null) {
      _fillFrom(initial);
    }

    if (!mounted) return;
    setState(() => _loading = false);
  }

  void _fillFrom(MoodEntry entry) {
    _moodLevel = entry.moodLevel;
    _categories = List<MoodCategory>.of(entry.categories);
    _noteController.text = entry.note ?? '';
    if (entry.sleepHours != null) {
      _trackSleep = true;
      _sleepHours = entry.sleepHours!;
      _sleepQuality = entry.sleepQuality ?? 3;
    }
  }

  Color _colorForLevel(MoodLevel level) {
    return switch (level) {
      MoodLevel.veryBad => const Color(0xFFFF3B30),
      MoodLevel.bad => const Color(0xFFFF9500),
      MoodLevel.neutral => const Color(0xFFFFCC00),
      MoodLevel.good => const Color(0xFF34C759),
      MoodLevel.veryGood => const Color(0xFF30D158),
    };
  }

  // ── Save ──────────────────────────────────────────────────────────────────

  Future<void> _save() async {
    final shouldContinue = await GuestDataMigrationService.requireAuth(context);
    if (!shouldContinue || !mounted) return;

    if (_saving) return;
    setState(() => _saving = true);
    HapticFeedback.mediumImpact();

    try {
      final l = AppLocalizations.of(context)!;
      final now = DateTime.now();
      final uid = FirebaseAuth.instance.currentUser?.uid ?? '';
      final noteText = _noteController.text.trim();

      final entry = (_editing ?? _defaultEntry(uid, now)).copyWith(
        moodLevel: _moodLevel,
        categories: _categories,
        note: noteText.isEmpty ? null : noteText,
        clearNote: noteText.isEmpty,
        sleepHours: _trackSleep ? _sleepHours : null,
        clearSleepHours: !_trackSleep,
        sleepQuality: _trackSleep ? _sleepQuality : null,
        clearSleepQuality: !_trackSleep,
        updatedAt: now,
      );

      await _repository.upsert(entry);

      if (!mounted) return;
      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              Text(_moodLevel.emoji, style: const TextStyle(fontSize: 18)),
              const SizedBox(width: 8),
              Text(_isEditMode
                  ? 'Eintrag aktualisiert'
                  : l.moodSaved),
            ],
          ),
          behavior: SnackBarBehavior.floating,
          duration: const Duration(milliseconds: 1400),
        ),
      );
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  MoodEntry _defaultEntry(String uid, DateTime now) {
    return MoodEntry(
      id: 'mood_${now.millisecondsSinceEpoch}',
      ownerId: uid,
      moodLevel: _moodLevel,
      createdAt: now,
      updatedAt: now,
      metadata: const <String, dynamic>{'source': 'mood_editor'},
    );
  }

  Future<void> _delete() async {
    final l = AppLocalizations.of(context)!;
    if (_editing == null) return;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l.entryDeleteConfirm),
        content: Text(l.moodDeleteConfirm),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: Text(l.cancel),
          ),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: Text(l.delete,
                style: TextStyle(color: Color(0xFFFF3B30))),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;
    await _repository.delete(_editing!.id);
    if (!mounted) return;
    Navigator.of(context).pop();
  }

  // ── Build ─────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    return GlassPage(
      title: _isEditMode ? 'Eintrag bearbeiten' : 'Neue Stimmung',
      titleIcon: Icons.sentiment_satisfied_rounded,
      titleColor: AppColors.accent,
      scrollableBody: (headerHeight) {
        if (_loading) {
          return const Center(child: CircularProgressIndicator());
        }

        return ListView(
          padding: EdgeInsets.only(
            top: headerHeight + 8,
            left: 16,
            right: 16,
            bottom: 100,
          ),
          children: [
            // ── Mood Level ──
            _EditorCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const _SectionHeader(
                    icon: Icons.sentiment_satisfied_rounded,
                    label: 'Wie geht es dir?',
                  ),
                  const SizedBox(height: 16),
                  // Large emoji selector
                  Center(
                    child: Text(
                      _moodLevel.emoji,
                      style: const TextStyle(fontSize: 64),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Center(
                    child: Text(
                      _moodLevel.label,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: _colorForLevel(_moodLevel),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  // Emoji row
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: MoodLevel.values.map((level) {
                      final selected = _moodLevel == level;
                      return GestureDetector(
                        onTap: () {
                          HapticFeedback.selectionClick();
                          setState(() => _moodLevel = level);
                        },
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          width: 52,
                          height: 52,
                          decoration: BoxDecoration(
                            color: selected
                                ? _colorForLevel(level)
                                    .withValues(alpha: 0.18)
                                : const Color(0xFFF2F2F7),
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: selected
                                  ? _colorForLevel(level)
                                  : Colors.transparent,
                              width: 2.5,
                            ),
                          ),
                          child: Center(
                            child: Text(
                              level.emoji,
                              style: TextStyle(
                                  fontSize: selected ? 28 : 22),
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),

            // ── Categories ──
            _EditorCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const _SectionHeader(
                    icon: Icons.category_rounded,
                    label: 'Was beschreibt deine Stimmung?',
                  ),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: MoodCategory.values.map((cat) {
                      final selected = _categories.contains(cat);
                      return GestureDetector(
                        onTap: () {
                          HapticFeedback.selectionClick();
                          setState(() {
                            if (selected) {
                              _categories.remove(cat);
                            } else {
                              _categories.add(cat);
                            }
                          });
                        },
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            color: selected
                                ? AppColors.accent.withValues(alpha: 0.12)
                                : const Color(0xFFF2F2F7),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: selected
                                  ? AppColors.accent.withValues(alpha: 0.4)
                                  : const Color(0xFFE5E5EA),
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(cat.emoji,
                                  style: const TextStyle(fontSize: 16)),
                              const SizedBox(width: 6),
                              Text(
                                cat.label,
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: selected
                                      ? FontWeight.w700
                                      : FontWeight.w500,
                                  color: selected
                                      ? AppColors.accent
                                      : const Color(0xFF3C3C43),
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),

            // ── Note ──
            _EditorCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const _SectionHeader(
                    icon: Icons.edit_note_rounded,
                    label: 'Notiz (optional)',
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _noteController,
                    maxLines: 3,
                    decoration: InputDecoration(
                      hintText: 'Was beschäftigt dich gerade?',
                      hintStyle: const TextStyle(
                        color: Color(0xFFAEAEB2),
                        fontSize: 14,
                      ),
                      filled: true,
                      fillColor: const Color(0xFFF2F2F7),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                      contentPadding: const EdgeInsets.all(14),
                    ),
                    style: const TextStyle(fontSize: 14),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),

            // ── Sleep ──
            _EditorCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const _SectionHeader(
                        icon: Icons.bedtime_rounded,
                        label: 'Schlaf (optional)',
                      ),
                      const Spacer(),
                      Switch.adaptive(
                        value: _trackSleep,
                        onChanged: (v) => setState(() => _trackSleep = v),
                        activeTrackColor: AppColors.accent,
                      ),
                    ],
                  ),
                  if (_trackSleep) ...[
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        const Text(
                          '😴  Stunden:',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF3C3C43),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          _sleepHours.toStringAsFixed(1),
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w800,
                            color: Color(0xFF1C1C1E),
                          ),
                        ),
                      ],
                    ),
                    Slider(
                      value: _sleepHours,
                      min: 0,
                      max: 14,
                      divisions: 28,
                      label: '${_sleepHours.toStringAsFixed(1)} h',
                      activeColor: AppColors.accent,
                      onChanged: (v) => setState(() => _sleepHours = v),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Schlafqualität:',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF3C3C43),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: List.generate(5, (i) {
                        final q = i + 1;
                        final selected = _sleepQuality == q;
                        final labels = ['Sehr schlecht', 'Schlecht', 'Okay', 'Gut', 'Sehr gut'];
                        return GestureDetector(
                          onTap: () {
                            HapticFeedback.selectionClick();
                            setState(() => _sleepQuality = q);
                          },
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            width: 56,
                            padding: const EdgeInsets.symmetric(vertical: 8),
                            decoration: BoxDecoration(
                              color: selected
                                  ? AppColors.accent.withValues(alpha: 0.15)
                                  : const Color(0xFFF2F2F7),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: selected
                                    ? AppColors.accent
                                    : const Color(0xFFE5E5EA),
                                width: selected ? 2 : 1,
                              ),
                            ),
                            child: Column(
                              children: [
                                Text(
                                  '$q',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w700,
                                    color: selected
                                        ? AppColors.accent
                                        : const Color(0xFF8E8E93),
                                  ),
                                ),
                                Text(
                                  labels[i],
                                  style: TextStyle(
                                    fontSize: 8,
                                    color: selected
                                        ? AppColors.accent
                                        : const Color(0xFFAEAEB2),
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ],
                            ),
                          ),
                        );
                      }),
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 24),

            // ── Save button ──
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _saving ? null : _save,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF0A74FF),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                child: _saving
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : Text(
                        _isEditMode ? l.save : 'Eintrag erstellen',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
              ),
            ),

            // ── Delete button ──
            if (_isEditMode) ...[
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: TextButton(
                  onPressed: _delete,
                  child: const Text(
                    'Eintrag löschen',
                    style: TextStyle(
                      color: Color(0xFFFF3B30),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ],
          ],
        );
      },
    );
  }
}

// ═════════════════════════════════════════════════════════════════════════════
// Private widgets
// ═════════════════════════════════════════════════════════════════════════════

class _EditorCard extends StatelessWidget {
  const _EditorCard({required this.child});
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0A000000),
            blurRadius: 12,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: child,
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.icon, required this.label});
  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 16, color: const Color(0xFF8E8E93)),
        const SizedBox(width: 8),
        Text(
          label,
          style: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w700,
            color: Color(0xFF1C1C1E),
          ),
        ),
      ],
    );
  }
}
