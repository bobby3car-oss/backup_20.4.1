import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../ui/ui.dart';
import '../data/nutrition_repository_sync.dart';
import '../domain/nutrition_entry.dart';
import '../../../ui/theme/app_icons.dart';

/// Full create / edit form for a [NutritionEntry].
class NutritionEntryEditorScreen extends StatefulWidget {
  const NutritionEntryEditorScreen({super.key, this.initialEntry});

  /// If non-null, we are editing an existing entry.
  final NutritionEntry? initialEntry;

  @override
  State<NutritionEntryEditorScreen> createState() =>
      _NutritionEntryEditorScreenState();
}

class _NutritionEntryEditorScreenState
    extends State<NutritionEntryEditorScreen> {
  static final NutritionRepositorySync _repository =
      NutritionRepositorySync.instance;

  bool get _isEditing => widget.initialEntry != null;

  final _descriptionCtl = TextEditingController();
  final _caloriesCtl = TextEditingController();
  final _proteinCtl = TextEditingController();
  final _carbsCtl = TextEditingController();
  final _fatCtl = TextEditingController();
  final _waterCtl = TextEditingController();
  final _symptomNoteCtl = TextEditingController();

  late MealType _mealType;
  late DateTime _date;
  late TimeOfDay _time;
  int? _tolerability;
  final Set<NutritionSymptom> _symptoms = {};
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    final e = widget.initialEntry;
    if (e != null) {
      _descriptionCtl.text = e.description;
      _caloriesCtl.text = e.calories?.toString() ?? '';
      _proteinCtl.text = e.protein?.toString() ?? '';
      _carbsCtl.text = e.carbs?.toString() ?? '';
      _fatCtl.text = e.fat?.toString() ?? '';
      _waterCtl.text = e.waterMl?.toString() ?? '';
      _symptomNoteCtl.text = e.symptomNote ?? '';
      _mealType = e.mealType;
      _date = DateTime(e.occurredAt.year, e.occurredAt.month, e.occurredAt.day);
      _time = TimeOfDay.fromDateTime(e.occurredAt);
      _tolerability = e.tolerability;
      _symptoms.addAll(e.symptoms);
    } else {
      _mealType = _guessMealType();
      final now = DateTime.now();
      _date = DateTime(now.year, now.month, now.day);
      _time = TimeOfDay.fromDateTime(now);
    }
  }

  @override
  void dispose() {
    _descriptionCtl.dispose();
    _caloriesCtl.dispose();
    _proteinCtl.dispose();
    _carbsCtl.dispose();
    _fatCtl.dispose();
    _waterCtl.dispose();
    _symptomNoteCtl.dispose();
    super.dispose();
  }

  MealType _guessMealType() {
    final hour = DateTime.now().hour;
    if (hour < 10) return MealType.fruehstueck;
    if (hour < 14) return MealType.mittagessen;
    if (hour < 18) return MealType.snack;
    return MealType.abendessen;
  }

  // ── Date / time pickers ──────────────────────────────────────────────
  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _date,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      locale: const Locale('de'),
    );
    if (picked != null) setState(() => _date = picked);
  }

  Future<void> _pickTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: _time,
    );
    if (picked != null) setState(() => _time = picked);
  }

  // ── Save / Delete ────────────────────────────────────────────────────
  Future<void> _save() async {
    if (_saving) return;
    final desc = _descriptionCtl.text.trim();
    if (desc.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Bitte beschreibe deine Mahlzeit'),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12)),
        ),
      );
      return;
    }
    setState(() => _saving = true);
    HapticFeedback.mediumImpact();
    try {
      final now = DateTime.now();
      final occurredAt = DateTime(
        _date.year,
        _date.month,
        _date.day,
        _time.hour,
        _time.minute,
      );
      final existing = widget.initialEntry;
      final entry = NutritionEntry(
        id: existing?.id ?? 'nutrition_${now.millisecondsSinceEpoch}',
        ownerId: existing?.ownerId ??
            FirebaseAuth.instance.currentUser?.uid ??
            '',
        occurredAt: occurredAt,
        mealType: _mealType,
        description: desc,
        calories: _parseInt(_caloriesCtl.text),
        protein: _parseInt(_proteinCtl.text),
        carbs: _parseInt(_carbsCtl.text),
        fat: _parseInt(_fatCtl.text),
        waterMl: _parseInt(_waterCtl.text),
        symptoms: _symptoms.toList(),
        symptomNote: _symptomNoteCtl.text.trim().isEmpty
            ? null
            : _symptomNoteCtl.text.trim(),
        tolerability: _tolerability,
        createdAt: existing?.createdAt ?? now,
        updatedAt: now,
        metadata: existing?.metadata ??
            const <String, dynamic>{'source': 'nutrition_editor'},
      );
      await _repository.upsert(entry);
      if (!mounted) return;
      Navigator.of(context).pop();
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  Future<void> _delete() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Eintrag löschen?'),
        content:
            const Text('Dieser Eintrag wird unwiderruflich gelöscht.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Abbrechen'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Löschen',
                style: TextStyle(color: Color(0xFFFF3B30))),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;
    await _repository.delete(widget.initialEntry!.id);
    if (!mounted) return;
    Navigator.of(context).pop();
  }

  int? _parseInt(String text) {
    final t = text.trim();
    if (t.isEmpty) return null;
    return int.tryParse(t);
  }

  // ── Build ─────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    return GlassPage(
      title: _isEditing ? 'Eintrag bearbeiten' : 'Neue Mahlzeit',
      titleIcon: _isEditing ? AppIcons.edit : AppIcons.dining,
      titleColor: const Color(0xFF34C759),
      horizontalPadding: AppSpacing.lg,
      children: [
        const SizedBox(height: AppSpacing.lg),

        // ── Date & Time ──────────────────────────────────
        _EditorCard(
          child: Row(
            children: [
              Expanded(
                child: _FieldButton(
                  icon: AppIcons.appointments,
                    iconColor: AppIcons.appointmentsColor,
                  label: _formatDate(_date),
                  onTap: _pickDate,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _FieldButton(
                  icon: AppIcons.timer,
                  iconColor: AppIcons.timerColor,
                  label: _time.format(context),
                  onTap: _pickTime,
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: AppSpacing.md),

        // ── Meal type ────────────────────────────────────
        _EditorCard(
          title: 'Mahlzeit',
          icon: AppIcons.dining,
                    iconColor: AppIcons.diningColor,
          child: Wrap(
            spacing: 8,
            runSpacing: 8,
            children: MealType.values.map((type) {
              final sel = _mealType == type;
              return GestureDetector(
                onTap: () => setState(() => _mealType = type),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: const EdgeInsets.symmetric(
                      horizontal: 14, vertical: 8),
                  decoration: BoxDecoration(
                    color: sel
                        ? const Color(0xFF34C759).withValues(alpha: 0.15)
                        : const Color(0xFFF2F2F7),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: sel
                          ? const Color(0xFF34C759)
                          : const Color(0xFFE5E5EA),
                      width: sel ? 1.5 : 1,
                    ),
                  ),
                  child: Text(
                    type.label,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: sel ? FontWeight.w600 : FontWeight.w500,
                      color: sel
                          ? const Color(0xFF34C759)
                          : const Color(0xFF636366),
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ),

        const SizedBox(height: AppSpacing.md),

        // ── Description ──────────────────────────────────
        _EditorCard(
          title: 'Beschreibung',
          icon: AppIcons.notes,
                    iconColor: AppIcons.notesColor,
          child: TextField(
            controller: _descriptionCtl,
            maxLines: 3,
            textCapitalization: TextCapitalization.sentences,
            decoration: _inputDecoration(
              'z. B. Vollkornbrot mit Quark und Tomaten',
            ),
          ),
        ),

        const SizedBox(height: AppSpacing.md),

        // ── Macros ───────────────────────────────────────
        _EditorCard(
          title: 'Nährwerte (optional)',
          icon: AppIcons.analytics,
          iconColor: AppIcons.analyticsColor,
          child: Column(
            children: [
              Row(
                children: [
                  Expanded(
                    child: _MacroField(
                      controller: _caloriesCtl,
                      label: 'kcal',
                      icon: AppIcons.calories,
                    iconColor: AppIcons.caloriesColor,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _MacroField(
                      controller: _proteinCtl,
                      label: 'Protein (g)',
                      icon: AppIcons.protein,
                    iconColor: AppIcons.proteinColor,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: _MacroField(
                      controller: _carbsCtl,
                      label: 'Kohlenh. (g)',
                      icon: AppIcons.carbs,
                    iconColor: AppIcons.carbsColor,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _MacroField(
                      controller: _fatCtl,
                      label: 'Fett (g)',
                      icon: AppIcons.fat,
                      iconColor: AppIcons.fatColor,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),

        const SizedBox(height: AppSpacing.md),

        // ── Hydration ────────────────────────────────────
        _EditorCard(
          title: 'Getrunken (ml)',
          icon: AppIcons.water,
                    iconColor: AppIcons.waterColor,
          child: TextField(
            controller: _waterCtl,
            keyboardType: TextInputType.number,
            decoration: _inputDecoration('z. B. 250'),
          ),
        ),

        const SizedBox(height: AppSpacing.md),

        // ── Tolerability ─────────────────────────────────
        _EditorCard(
          title: 'Verträglichkeit',
          icon: AppIcons.done,
          iconColor: AppIcons.doneColor,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: List.generate(5, (i) {
              final level = i + 1;
              const emojis = ['😫', '😣', '😐', '🙂', '😊'];
              final sel = _tolerability == level;
              return GestureDetector(
                onTap: () {
                  HapticFeedback.selectionClick();
                  setState(() {
                    _tolerability = sel ? null : level;
                  });
                },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: sel
                        ? const Color(0xFF34C759).withValues(alpha: 0.15)
                        : const Color(0xFFF2F2F7),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: sel
                          ? const Color(0xFF34C759)
                          : Colors.transparent,
                      width: 2,
                    ),
                  ),
                  child: Text(
                    emojis[i],
                    style: TextStyle(fontSize: sel ? 28 : 22),
                  ),
                ),
              );
            }),
          ),
        ),

        const SizedBox(height: AppSpacing.md),

        // ── Symptoms ─────────────────────────────────────
        _EditorCard(
          title: 'Symptome',
          icon: AppIcons.warnings,
          iconColor: AppIcons.warningsColor,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: NutritionSymptom.values.map((symptom) {
                  final sel = _symptoms.contains(symptom);
                  return GestureDetector(
                    onTap: () => setState(() {
                      sel
                          ? _symptoms.remove(symptom)
                          : _symptoms.add(symptom);
                    }),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 8),
                      decoration: BoxDecoration(
                        color: sel
                            ? const Color(0xFFFF3B30)
                                .withValues(alpha: 0.12)
                            : const Color(0xFFF2F2F7),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: sel
                              ? const Color(0xFFFF3B30)
                              : const Color(0xFFE5E5EA),
                          width: sel ? 1.5 : 1,
                        ),
                      ),
                      child: Text(
                        symptom.label,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight:
                              sel ? FontWeight.w600 : FontWeight.w500,
                          color: sel
                              ? const Color(0xFFFF3B30)
                              : const Color(0xFF636366),
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
              if (_symptoms.isNotEmpty) ...[
                const SizedBox(height: 12),
                TextField(
                  controller: _symptomNoteCtl,
                  maxLines: 2,
                  textCapitalization: TextCapitalization.sentences,
                  decoration: _inputDecoration(
                    'Notiz zu den Symptomen (optional)',
                  ),
                ),
              ],
            ],
          ),
        ),

        const SizedBox(height: AppSpacing.xl),

        // ── Save button ──────────────────────────────────
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4),
          child: SizedBox(
            width: double.infinity,
            height: 54,
            child: ElevatedButton(
              onPressed: _saving ? null : _save,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF34C759),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                elevation: 0,
                textStyle: const TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w700,
                ),
              ),
              child: _saving
                  ? const SizedBox(
                      width: 22,
                      height: 22,
                      child: CircularProgressIndicator(
                        strokeWidth: 2.5,
                        color: Colors.white,
                      ),
                    )
                  : Text(_isEditing ? 'Speichern' : 'Mahlzeit speichern'),
            ),
          ),
        ),

        // ── Delete button ────────────────────────────────
        if (_isEditing) ...[
          const SizedBox(height: AppSpacing.md),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: SizedBox(
              width: double.infinity,
              child: TextButton(
                onPressed: _delete,
                style: TextButton.styleFrom(
                  foregroundColor: const Color(0xFFFF3B30),
                ),
                child: const Text(
                  'Eintrag löschen',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ),
        ],

        const SizedBox(height: AppSpacing.xxxl),
      ],
    );
  }

  InputDecoration _inputDecoration(String hint) {
    return InputDecoration(
      hintText: hint,
      hintStyle: const TextStyle(fontSize: 14, color: Color(0xFFAEAEB2)),
      filled: true,
      fillColor: const Color(0xFFF2F2F7),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
      contentPadding: const EdgeInsets.symmetric(
        horizontal: 14,
        vertical: 12,
      ),
    );
  }

  String _formatDate(DateTime d) {
    const months = [
      '',
      'Jan',
      'Feb',
      'Mär',
      'Apr',
      'Mai',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Okt',
      'Nov',
      'Dez',
    ];
    final now = DateTime.now();
    if (d.year == now.year && d.month == now.month && d.day == now.day) {
      return 'Heute';
    }
    return '${d.day}. ${months[d.month]} ${d.year}';
  }
}

// ── Private widgets ──────────────────────────────────────────────────────────

class _EditorCard extends StatelessWidget {
  const _EditorCard({
    required this.child,
    this.title,
    this.icon,

    this.iconColor,
  });
  final Widget child;
  final String? title;
  final IconData? icon;

  final Color? iconColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 12,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (title != null) ...[
            Row(
              children: [
                if (icon != null) ...[
                  GlassIcon(icon: icon!, color: iconColor!, size: 18),
                  const SizedBox(width: 8),
                ],
                Text(
                  title!,
                  style: const TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF1C1C1E),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
          ],
          child,
        ],
      ),
    );
  }
}

class _FieldButton extends StatelessWidget {
  const _FieldButton({
    required this.icon,
    required this.iconColor,
    required this.label,
    required this.onTap,
  });
  final IconData icon;

  final Color iconColor;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: const Color(0xFFF2F2F7),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            GlassIcon(icon: icon, color: iconColor, size: 16),
            const SizedBox(width: 8),
            Text(
              label,
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: Color(0xFF1C1C1E),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MacroField extends StatelessWidget {
  const _MacroField({
    required this.controller,
    required this.label,
    required this.icon,
    required this.iconColor,
  });
  final TextEditingController controller;
  final String label;
  final IconData icon;

  final Color iconColor;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      keyboardType: TextInputType.number,
      style: const TextStyle(fontSize: 14),
      decoration: InputDecoration(
        hintText: label,
        prefixIcon: Padding(
          padding: const EdgeInsets.only(left: 8),
          child: GlassIcon(icon: icon, color: iconColor, size: 14),
        ),
        prefixIconConstraints: const BoxConstraints(minWidth: 30, minHeight: 14),
        hintStyle: const TextStyle(fontSize: 13, color: Color(0xFFAEAEB2)),
        filled: true,
        fillColor: const Color(0xFFF2F2F7),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide.none,
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 12,
          vertical: 10,
        ),
      ),
    );
  }
}
