import 'dart:math' as math;

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../domain/task_orchestrator.dart';
import '../../../ui/ui.dart';
import '../data/meal_template_repository.dart';
import '../data/nutrition_repository_sync.dart';
import '../domain/meal_template.dart';
import '../domain/nutrition_entry.dart';
import '../domain/nutrition_recommendation_service.dart';
import 'nutrition_diary_screen.dart';
import 'nutrition_entry_editor_screen.dart';
import '../../../ui/theme/app_icons.dart';

/// Quick-entry nutrition screen with meal type chips, description field,
/// optional macros/hydration/symptoms, recommendations and recent entries.
class NutritionScreen extends StatefulWidget {
  const NutritionScreen({super.key});

  @override
  State<NutritionScreen> createState() => _NutritionScreenState();
}

class _NutritionScreenState extends State<NutritionScreen> {
  static final NutritionRepositorySync _repository =
      NutritionRepositorySync.instance;

  final _orchestrator = TaskOrchestrator(autoSeed: false);

  final _descriptionController = TextEditingController();
  final _caloriesController = TextEditingController();
  final _proteinController = TextEditingController();
  final _carbsController = TextEditingController();
  final _fatController = TextEditingController();
  final _waterController = TextEditingController();

  MealType _mealType = MealType.mittagessen;
  int? _tolerability;
  final Set<NutritionSymptom> _symptoms = {};
  bool _saving = false;
  bool _showMacros = false;

  // ── Profile data for personalized recommendations ─────────────────
  List<String> _allergies = const [];
  double? _weight;

  // ── Meal templates ────────────────────────────────────────────────
  static final MealTemplateRepository _templateRepo =
      MealTemplateRepository.instance;

  // ── Configurable daily targets ────────────────────────────────────
  static const _kCalTarget = 'nutrition_target_cal';
  static const _kProteinTarget = 'nutrition_target_protein';
  static const _kWaterTarget = 'nutrition_target_water';

  int _calTarget = 2000;
  int _proteinTarget = 60;
  int _waterTarget = 1500;

  @override
  void initState() {
    super.initState();
    _guessMealType();
    _bootstrap();
  }

  @override
  void dispose() {
    _descriptionController.dispose();
    _caloriesController.dispose();
    _proteinController.dispose();
    _carbsController.dispose();
    _fatController.dispose();
    _waterController.dispose();
    super.dispose();
  }

  void _guessMealType() {
    final hour = DateTime.now().hour;
    if (hour < 10) {
      _mealType = MealType.fruehstueck;
    } else if (hour < 14) {
      _mealType = MealType.mittagessen;
    } else if (hour < 18) {
      _mealType = MealType.snack;
    } else {
      _mealType = MealType.abendessen;
    }
  }

  Future<void> _bootstrap() async {
    await _orchestrator.ready;
    await _repository.loadFromDisk();
    await _repository.pullLatest();
    await _templateRepo.load();
    _loadProfile();
    _loadTargets();
  }

  Future<void> _loadProfile() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;
    try {
      final snap =
          await FirebaseFirestore.instance.doc('users/$uid').get();
      if (!snap.exists || !mounted) return;
      final data = snap.data()!;
      final rawAllergies = data['allergies'];
      if (rawAllergies is List) {
        _allergies = rawAllergies.cast<String>();
      }
      final rawWeight = data['weight'];
      if (rawWeight is num) {
        _weight = rawWeight.toDouble();
      }
      // Derive smarter targets from profile weight if user hasn't customised.
      _applyProfileTargets();
      if (mounted) setState(() {});
    } catch (_) {
      // Profile fetch is best-effort; recommendations degrade gracefully.
    }
  }

  Future<void> _loadTargets() async {
    final prefs = await SharedPreferences.getInstance();
    final cal = prefs.getInt(_kCalTarget);
    final pro = prefs.getInt(_kProteinTarget);
    final wat = prefs.getInt(_kWaterTarget);
    if (cal != null) _calTarget = cal;
    if (pro != null) _proteinTarget = pro;
    if (wat != null) _waterTarget = wat;
    if (mounted) setState(() {});
  }

  Future<void> _saveTargets() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_kCalTarget, _calTarget);
    await prefs.setInt(_kProteinTarget, _proteinTarget);
    await prefs.setInt(_kWaterTarget, _waterTarget);
  }

  /// Adjust default targets based on profile weight if never customised.
  void _applyProfileTargets() {
    // Only auto-set when user hasn't manually edited targets.
    // We detect "never customised" by checking SharedPreferences are empty.
    SharedPreferences.getInstance().then((prefs) {
      if (prefs.containsKey(_kCalTarget)) return; // user chose custom values
      if (_weight != null && _weight! > 0) {
        // Harris-Benedict rough estimate: ~30 kcal/kg for recovery patients
        _calTarget = (_weight! * 30).round().clamp(1200, 3500);
        _proteinTarget = (_weight! * 1.0).round().clamp(40, 200);
        if (mounted) setState(() {});
      }
    });
  }

  Future<void> _showTargetSettings() async {
    var cal = _calTarget;
    var pro = _proteinTarget;
    var wat = _waterTarget;

    final saved = await showDialog<bool>(
      context: context,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (ctx, setInner) {
            return AlertDialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              title: const Row(
                children: [
                  GlassIcon(icon: AppIcons.progress, color: AppIcons.progressColor, size: 14),
                  SizedBox(width: 8),
                  Text('Tagesziele'),
                ],
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (_weight != null)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: Text(
                        'Basierend auf ${_weight!.round()} kg Körpergewicht',
                        style: const TextStyle(
                          fontSize: 12,
                          color: Color(0xFF8E8E93),
                        ),
                      ),
                    ),
                  _TargetRow(
                    icon: AppIcons.calories,
                    iconColor: AppIcons.caloriesColor,
                    label: 'Kalorien (kcal)',
                    value: cal,
                    min: 800,
                    max: 4000,
                    step: 100,
                    onChanged: (v) => setInner(() => cal = v),
                  ),
                  const SizedBox(height: 12),
                  _TargetRow(
                    icon: AppIcons.protein,
                    iconColor: AppIcons.proteinColor,
                    label: 'Protein (g)',
                    value: pro,
                    min: 20,
                    max: 250,
                    step: 5,
                    onChanged: (v) => setInner(() => pro = v),
                  ),
                  const SizedBox(height: 12),
                  _TargetRow(
                    icon: AppIcons.water,
                    iconColor: AppIcons.waterColor,
                    label: 'Wasser (ml)',
                    value: wat,
                    min: 500,
                    max: 4000,
                    step: 100,
                    onChanged: (v) => setInner(() => wat = v),
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(ctx, false),
                  child: const Text('Abbrechen'),
                ),
                FilledButton(
                  onPressed: () => Navigator.pop(ctx, true),
                  child: const Text('Speichern'),
                ),
              ],
            );
          },
        );
      },
    );

    if (saved == true && mounted) {
      setState(() {
        _calTarget = cal;
        _proteinTarget = pro;
        _waterTarget = wat;
      });
      _saveTargets();
    }
  }

  void _applyTemplate(MealTemplate t) {
    HapticFeedback.selectionClick();
    setState(() {
      _mealType = t.mealType;
      _descriptionController.text = t.description;
      if (t.calories != null) _caloriesController.text = t.calories.toString();
      if (t.protein != null) _proteinController.text = t.protein.toString();
      if (t.carbs != null) _carbsController.text = t.carbs.toString();
      if (t.fat != null) _fatController.text = t.fat.toString();
      if (t.waterMl != null) _waterController.text = t.waterMl.toString();
      _showMacros = t.calories != null ||
          t.protein != null ||
          t.carbs != null ||
          t.fat != null;
    });
    Scrollable.ensureVisible(context,
        duration: const Duration(milliseconds: 300));
  }

  Future<void> _saveAsTemplate() async {
    final desc = _descriptionController.text.trim();
    if (desc.isEmpty) return;
    final name = await showDialog<String>(
      context: context,
      builder: (ctx) {
        final controller = TextEditingController(text: desc);
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: const Row(
            children: [
              GlassIcon(icon: AppIcons.clipboard, color: AppIcons.clipboardColor, size: 14),
              SizedBox(width: 8),
              Text('Vorlage speichern'),
            ],
          ),
          content: TextField(
            controller: controller,
            autofocus: true,
            decoration: const InputDecoration(
              labelText: 'Name der Vorlage',
              hintText: 'z. B. Haferbrei mit Beeren',
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Abbrechen'),
            ),
            FilledButton(
              onPressed: () {
                final value = controller.text.trim();
                Navigator.pop(ctx, value.isEmpty ? null : value);
              },
              child: const Text('Speichern'),
            ),
          ],
        );
      },
    );
    if (name == null || name.isEmpty) return;

    final template = MealTemplate(
      id: DateTime.now().microsecondsSinceEpoch.toRadixString(36),
      name: name,
      mealType: _mealType,
      description: desc,
      calories: _parseIntField(_caloriesController.text),
      protein: _parseIntField(_proteinController.text),
      carbs: _parseIntField(_carbsController.text),
      fat: _parseIntField(_fatController.text),
      waterMl: _parseIntField(_waterController.text),
      symptoms: _symptoms.toList(),
      tolerability: _tolerability,
      createdAt: DateTime.now(),
    );
    await _templateRepo.add(template);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Row(
            children: [
              GlassIcon(icon: AppIcons.clipboard, color: AppIcons.clipboardColor, size: 14),
              SizedBox(width: 8),
              Text('Vorlage gespeichert'),
            ],
          ),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12)),
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  /// Pre-fill form fields from a previous entry for quick re-logging.
  void _prefillFromEntry(NutritionEntry entry) {
    HapticFeedback.selectionClick();
    setState(() {
      _mealType = entry.mealType;
      _descriptionController.text = entry.description;
      if (entry.calories != null) {
        _caloriesController.text = entry.calories.toString();
      }
      if (entry.protein != null) {
        _proteinController.text = entry.protein.toString();
      }
      if (entry.carbs != null) {
        _carbsController.text = entry.carbs.toString();
      }
      if (entry.fat != null) {
        _fatController.text = entry.fat.toString();
      }
      if (entry.waterMl != null) {
        _waterController.text = entry.waterMl.toString();
      }
      _showMacros = entry.calories != null ||
          entry.protein != null ||
          entry.carbs != null ||
          entry.fat != null;
    });
    // Scroll to top so user sees the pre-filled form.
    Scrollable.ensureVisible(context, duration: const Duration(milliseconds: 300));
  }

  // ── Save ──────────────────────────────────────────────────────────────
  Future<void> _save() async {
    final desc = _descriptionController.text.trim();
    if (desc.isEmpty || _saving) return;
    setState(() => _saving = true);
    HapticFeedback.mediumImpact();
    try {
      final now = DateTime.now();
      final id = 'nutrition_${now.millisecondsSinceEpoch}';
      final uid = FirebaseAuth.instance.currentUser?.uid ?? '';
      final entry = NutritionEntry(
        id: id,
        ownerId: uid,
        occurredAt: now,
        mealType: _mealType,
        description: desc,
        calories: _parseIntField(_caloriesController.text),
        protein: _parseIntField(_proteinController.text),
        carbs: _parseIntField(_carbsController.text),
        fat: _parseIntField(_fatController.text),
        waterMl: _parseIntField(_waterController.text),
        symptoms: _symptoms.toList(),
        tolerability: _tolerability,
        createdAt: now,
        updatedAt: now,
        metadata: const <String, dynamic>{'source': 'nutrition_screen'},
      );
      await _repository.upsert(entry);
      if (!mounted) return;
      _descriptionController.clear();
      _caloriesController.clear();
      _proteinController.clear();
      _carbsController.clear();
      _fatController.clear();
      _waterController.clear();
      _symptoms.clear();
      _tolerability = null;
      _showMacros = false;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              GlassIcon(icon: _mealType.icon, color: _mealType.iconColor, size: 20),
              const SizedBox(width: 8),
              const Expanded(child: Text('Mahlzeit gespeichert')),
              GestureDetector(
                onTap: _saveAsTemplate,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Text(
                    'Vorlage',
                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
                  ),
                ),
              ),
            ],
          ),
          behavior: SnackBarBehavior.floating,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          duration: const Duration(seconds: 4),
        ),
      );
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  int? _parseIntField(String text) {
    final trimmed = text.trim();
    if (trimmed.isEmpty) return null;
    return int.tryParse(trimmed);
  }

  // ── Helpers ───────────────────────────────────────────────────────────
  String _formatRelative(DateTime d) {
    final now = DateTime.now();
    final diff = now.difference(d);
    if (diff.inMinutes < 1) return 'Gerade eben';
    if (diff.inMinutes < 60) return 'vor ${diff.inMinutes} Min.';
    if (diff.inHours < 24) return 'vor ${diff.inHours} Std.';
    if (diff.inDays == 1) return 'Gestern';
    if (diff.inDays < 7) return 'vor ${diff.inDays} Tagen';
    final dd = d.day.toString().padLeft(2, '0');
    final mm = d.month.toString().padLeft(2, '0');
    return '$dd.$mm.${d.year}';
  }

  Color get _mealColor => switch (_mealType) {
        MealType.fruehstueck => const Color(0xFFFF9500),
        MealType.mittagessen => const Color(0xFF34C759),
        MealType.abendessen => const Color(0xFF5856D6),
        MealType.snack => const Color(0xFFFF2D55),
      };

  // ── Build ─────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    return GlassPage(
      title: 'Ernährungstagebuch',
      titleIcon: AppIcons.nutrition,
      titleColor: const Color(0xFF34C759),
      horizontalPadding: AppSpacing.lg,
      children: [
        const SizedBox(height: AppSpacing.lg),

        // ── Card 1: Meal Type ────────────────────────────────
        _AnimatedCard(
          borderColor: _mealColor.withValues(alpha: 0.3),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Row(
                children: [
                  GlassIcon(icon: AppIcons.nutrition, color: AppIcons.nutritionColor, size: 14),
                  SizedBox(width: 8),
                  Text(
                    'Mahlzeit',
                    style: TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF1C1C1E),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: MealType.values.map((type) {
                  final selected = _mealType == type;
                  return _SelectChip(
                    label: type.label,
                    selected: selected,
                    color: selected ? _mealColor : null,
                    onTap: () => setState(() => _mealType = type),
                  );
                }).toList(),
              ),
            ],
          ),
        ),

        const SizedBox(height: AppSpacing.md),

        // ── Card 2: Description ──────────────────────────────
        _AnimatedCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Row(
                children: [
                  GlassIcon(icon: AppIcons.notes, color: AppIcons.notesColor, size: 14),
                  SizedBox(width: 8),
                  Text(
                    'Was hast du gegessen?',
                    style: TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF1C1C1E),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _descriptionController,
                maxLines: 2,
                textCapitalization: TextCapitalization.sentences,
                decoration: InputDecoration(
                  hintText: 'z. B. Vollkornbrot mit Quark und Tomaten',
                  hintStyle: const TextStyle(
                    fontSize: 15,
                    color: Color(0xFFAEAEB2),
                  ),
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
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: AppSpacing.md),

        // ── Card 3: Hydration ────────────────────────────────
        _AnimatedCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Row(
                children: [
                  GlassIcon(icon: AppIcons.water, color: AppIcons.waterColor, size: 14),
                  SizedBox(width: 8),
                  Text(
                    'Getrunken (ml)',
                    style: TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF1C1C1E),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              const Text(
                'Optional – Wasser, Tee, etc.',
                style: TextStyle(fontSize: 13, color: Color(0xFF8E8E93)),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  for (final ml in [100, 200, 250, 500])
                    Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: _QuickChip(
                        label: '${ml}ml',
                        onTap: () {
                          final current =
                              int.tryParse(_waterController.text) ?? 0;
                          _waterController.text = '${current + ml}';
                          setState(() {});
                        },
                      ),
                    ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: SizedBox(
                      height: 36,
                      child: TextField(
                        controller: _waterController,
                        keyboardType: TextInputType.number,
                        style: const TextStyle(fontSize: 14),
                        decoration: InputDecoration(
                          hintText: 'ml',
                          hintStyle: const TextStyle(
                            fontSize: 13,
                            color: Color(0xFFAEAEB2),
                          ),
                          filled: true,
                          fillColor: const Color(0xFFF2F2F7),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: BorderSide.none,
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 8,
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

        const SizedBox(height: AppSpacing.md),

        // ── Card 4: Tolerability ─────────────────────────────
        _AnimatedCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Row(
                children: [
                  GlassIcon(icon: AppIcons.done, color: AppIcons.doneColor, size: 14),
                  SizedBox(width: 8),
                  Text(
                    'Verträglichkeit',
                    style: TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF1C1C1E),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              const Text(
                'Optional – wie hast du das Essen vertragen?',
                style: TextStyle(fontSize: 13, color: Color(0xFF8E8E93)),
              ),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: List.generate(5, (i) {
                  final level = i + 1;
                  final emojis = ['😫', '😣', '😐', '🙂', '😊'];
                  final selected = _tolerability == level;
                  return GestureDetector(
                    onTap: () {
                      HapticFeedback.selectionClick();
                      setState(() {
                        _tolerability = selected ? null : level;
                      });
                    },
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: selected
                            ? _mealColor.withValues(alpha: 0.15)
                            : const Color(0xFFF2F2F7),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: selected
                              ? _mealColor
                              : Colors.transparent,
                          width: 2,
                        ),
                      ),
                      child: Text(
                        emojis[i],
                        style: TextStyle(fontSize: selected ? 28 : 22),
                      ),
                    ),
                  );
                }),
              ),
            ],
          ),
        ),

        const SizedBox(height: AppSpacing.md),

        // ── Card 5: Symptoms ─────────────────────────────────
        _AnimatedCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Row(
                children: [
                  Text('🤒', style: TextStyle(fontSize: 18)),
                  SizedBox(width: 8),
                  Text(
                    'Symptome nach dem Essen',
                    style: TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF1C1C1E),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              const Text(
                'Optional – tippe auf zutreffende Symptome',
                style: TextStyle(fontSize: 13, color: Color(0xFF8E8E93)),
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: NutritionSymptom.values.map((symptom) {
                  final selected = _symptoms.contains(symptom);
                  return _SelectChip(
                    label: symptom.label,
                    selected: selected,
                    color: selected ? const Color(0xFFFF3B30) : null,
                    onTap: () => setState(() {
                      if (selected) {
                        _symptoms.remove(symptom);
                      } else {
                        _symptoms.add(symptom);
                      }
                    }),
                  );
                }).toList(),
              ),
            ],
          ),
        ),

        const SizedBox(height: AppSpacing.md),

        // ── Card 6: Macros (expandable) ──────────────────────
        _AnimatedCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              GestureDetector(
                onTap: () => setState(() => _showMacros = !_showMacros),
                child: Row(
                  children: [
                    GlassIcon(icon: AppIcons.analytics, color: AppIcons.analyticsColor, size: 14),
                    const SizedBox(width: 8),
                    const Expanded(
                      child: Text(
                        'Nährwerte',
                        style: TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF1C1C1E),
                        ),
                      ),
                    ),
                    Icon(
                      _showMacros
                          ? Icons.keyboard_arrow_up_rounded
                          : Icons.keyboard_arrow_down_rounded,
                      color: const Color(0xFF8E8E93),
                    ),
                  ],
                ),
              ),
              if (!_showMacros)
                const Padding(
                  padding: EdgeInsets.only(top: 4),
                  child: Text(
                    'Optional – Kalorien, Protein, Kohlenhydrate, Fett',
                    style: TextStyle(fontSize: 13, color: Color(0xFF8E8E93)),
                  ),
                ),
              if (_showMacros) ...[
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: _MacroField(
                        controller: _caloriesController,
                        label: 'kcal',
                        icon: AppIcons.calories,
                    iconColor: AppIcons.caloriesColor,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: _MacroField(
                        controller: _proteinController,
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
                        controller: _carbsController,
                        label: 'Kohlenh. (g)',
                        icon: AppIcons.carbs,
                    iconColor: AppIcons.carbsColor,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: _MacroField(
                        controller: _fatController,
                        label: 'Fett (g)',
                        icon: AppIcons.fat,
                        iconColor: AppIcons.fatColor,
                      ),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),

        const SizedBox(height: AppSpacing.md),

        // ── Templates ────────────────────────────────────
        StreamBuilder<List<MealTemplate>>(
          stream: _templateRepo.watchAll(),
          builder: (context, snap) {
            final templates = snap.data ?? const <MealTemplate>[];
            if (templates.isEmpty) return const SizedBox.shrink();
            return Column(
              children: [
                _AnimatedCard(
                  borderColor: const Color(0xFF007AFF).withValues(alpha: 0.2),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Row(
                        children: [
                          GlassIcon(icon: AppIcons.clipboard, color: AppIcons.clipboardColor, size: 14),
                          SizedBox(width: 8),
                          Text(
                            'Vorlagen',
                            style: TextStyle(
                              fontSize: 17,
                              fontWeight: FontWeight.w700,
                              color: Color(0xFF1C1C1E),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: templates.map((t) {
                          return GestureDetector(
                            onTap: () => _applyTemplate(t),
                            onLongPress: () async {
                              final delete = await showDialog<bool>(
                                context: context,
                                builder: (ctx) => AlertDialog(
                                  title: const Text('Vorlage löschen?'),
                                  content: Text('"${t.name}" wird entfernt.'),
                                  actions: [
                                    TextButton(
                                      onPressed: () =>
                                          Navigator.pop(ctx, false),
                                      child: const Text('Abbrechen'),
                                    ),
                                    TextButton(
                                      onPressed: () =>
                                          Navigator.pop(ctx, true),
                                      child: const Text('Löschen',
                                          style:
                                              TextStyle(color: Colors.red)),
                                    ),
                                  ],
                                ),
                              );
                              if (delete == true) {
                                _templateRepo.remove(t.id);
                              }
                            },
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 12, vertical: 8),
                              decoration: BoxDecoration(
                                color: const Color(0xFF007AFF)
                                    .withValues(alpha: 0.08),
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(
                                  color: const Color(0xFF007AFF)
                                      .withValues(alpha: 0.3),
                                ),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  GlassIcon(icon: t.mealType.icon, color: t.mealType.iconColor, size: 14),
                                  const SizedBox(width: 6),
                                  Text(
                                    t.name,
                                    style: const TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w600,
                                      color: Color(0xFF007AFF),
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
                const SizedBox(height: AppSpacing.md),
              ],
            );
          },
        ),

        const SizedBox(height: AppSpacing.lg),

        // ── Save button ──────────────────────────────────
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4),
          child: SizedBox(
            width: double.infinity,
            height: 54,
            child: ElevatedButton(
              onPressed: _saving ? null : _save,
              style: ElevatedButton.styleFrom(
                backgroundColor: _mealColor,
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
                  : Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        GlassIcon(icon: _mealType.icon, color: _mealType.iconColor, size: 20),
                        const SizedBox(width: 8),
                        const Text('Speichern'),
                      ],
                    ),
            ),
          ),
        ),

        const SizedBox(height: AppSpacing.xxl),

        // ── Recommendations ──────────────────────────────
        StreamBuilder<List<NutritionEntry>>(
          stream: _repository.watchAll(),
          builder: (context, snapshot) {
            final items = snapshot.data ?? const <NutritionEntry>[];

            String? opPhase;
            final opDate = _orchestrator.operationDate;
            if (opDate != null) {
              final daysSinceOp =
                  DateTime.now().difference(opDate).inDays;
              if (daysSinceOp < 0) {
                opPhase = 'preop';
              } else if (daysSinceOp == 0) {
                opPhase = 'opday';
              } else if (daysSinceOp <= 7) {
                opPhase = 'week1';
              } else if (daysSinceOp <= 14) {
                opPhase = 'week2';
              } else {
                opPhase = 'followup';
              }
            }

            final recService = const NutritionRecommendationService();
            final recommendations = recService.compute(
              entries: items,
              opPhase: opPhase,
              allergies: _allergies,
              weight: _weight,
            );

            return Column(
              children: [
                if (recommendations.isNotEmpty) ...[
                  _buildRecommendations(recommendations),
                  const SizedBox(height: AppSpacing.md),
                ],
                if (items.isNotEmpty) ...[
                  _buildDailyProgress(items),
                  const SizedBox(height: AppSpacing.md),
                  _buildRecentEntries(items),
                  const SizedBox(height: AppSpacing.lg),
                  _buildDiaryCta(),
                ],
                const SizedBox(height: AppSpacing.xxxl),
              ],
            );
          },
        ),
      ],
    );
  }

  // ── Recommendations card ──────────────────────────────────────────
  Widget _buildRecommendations(List<NutritionRecommendation> recs) {
    return _AnimatedCard(
      borderColor: const Color(0xFF34C759).withValues(alpha: 0.3),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              GlassIcon(icon: AppIcons.info, color: AppIcons.infoColor, size: 14),
              SizedBox(width: 8),
              Text(
                'Empfehlungen',
                style: TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF1C1C1E),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ...recs.take(3).map((rec) => Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    GlassIcon(icon: rec.icon, color: rec.iconColor, size: 20),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            rec.title,
                            style: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF1C1C1E),
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            rec.body,
                            style: const TextStyle(
                              fontSize: 13,
                              color: Color(0xFF636366),
                              height: 1.4,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              )),
        ],
      ),
    );
  }

  // ── Daily progress rings ──────────────────────────────────────────────
  Widget _buildDailyProgress(List<NutritionEntry> items) {
    final now = DateTime.now();
    final today =
        items.where((e) => _isSameDay(e.occurredAt, now)).toList();
    final todayCals = today
        .where((e) => e.calories != null)
        .fold<int>(0, (s, e) => s + e.calories!);
    final todayProtein = today
        .where((e) => e.protein != null)
        .fold<int>(0, (s, e) => s + e.protein!);
    final todayWater = today
        .where((e) => e.waterMl != null)
        .fold<int>(0, (s, e) => s + e.waterMl!);

    final calTarget = _calTarget;
    final proteinTarget = _proteinTarget;
    final waterTarget = _waterTarget;

    return _AnimatedCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              GlassIcon(icon: AppIcons.analytics, color: AppIcons.analyticsColor, size: 14),
              const SizedBox(width: 8),
              const Expanded(
                child: Text(
                  'Heute',
                  style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF1C1C1E),
                  ),
                ),
              ),
              Text(
                '${today.length} Mahlzeit${today.length != 1 ? "en" : ""}',
                style: const TextStyle(
                  fontSize: 13,
                  color: Color(0xFF8E8E93),
                ),
              ),
              const SizedBox(width: 8),
              GestureDetector(
                onTap: _showTargetSettings,
                child: const Icon(
                  Icons.tune_rounded,
                  size: 18,
                  color: Color(0xFF8E8E93),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _ProgressRing(
                value: todayCals,
                target: calTarget,
                label: 'kcal',
                color: const Color(0xFFFF9500),
              ),
              _ProgressRing(
                value: todayProtein,
                target: proteinTarget,
                label: 'Protein',
                unit: 'g',
                color: const Color(0xFF34C759),
              ),
              _ProgressRing(
                value: todayWater,
                target: waterTarget,
                label: 'Wasser',
                unit: 'ml',
                color: const Color(0xFF5AC8FA),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Center(
            child: Text(
              '${items.length} Einträge insgesamt',
              style: const TextStyle(fontSize: 12, color: Color(0xFF8E8E93)),
            ),
          ),
        ],
      ),
    );
  }

  // ── Recent entries ──────────────────────────────────────────────────
  Widget _buildRecentEntries(List<NutritionEntry> items) {
    final recent = items.take(5).toList();
    return _AnimatedCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              GlassIcon(icon: AppIcons.timer, color: AppIcons.timerColor, size: 14),
              const SizedBox(width: 8),
              const Expanded(
                child: Text(
                  'Letzte Einträge',
                  style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF1C1C1E),
                  ),
                ),
              ),
              GestureDetector(
                onTap: () => Navigator.of(context).push(
                  MaterialPageRoute<void>(
                    builder: (_) => const NutritionDiaryScreen(),
                  ),
                ),
                child: const Text(
                  'Alle →',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF007AFF),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ...recent.map((entry) => GestureDetector(
                onTap: () => Navigator.of(context).push(
                  MaterialPageRoute<void>(
                    builder: (_) =>
                        NutritionEntryEditorScreen(initialEntry: entry),
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: Row(
                    children: [
                      GlassIcon(icon: entry.mealType.icon, color: entry.mealType.iconColor, size: 22),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              entry.description.isEmpty
                                  ? entry.mealType.label
                                  : entry.description,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w600,
                                color: Color(0xFF1C1C1E),
                              ),
                            ),
                            Text(
                              '${entry.mealType.label} · ${_formatRelative(entry.occurredAt)}'
                              '${entry.calories != null ? " · ${entry.calories} kcal" : ""}',
                              style: const TextStyle(
                                fontSize: 12,
                                color: Color(0xFF8E8E93),
                              ),
                            ),
                          ],
                        ),
                      ),
                      if (entry.symptoms.isNotEmpty)
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color:
                                const Color(0xFFFF3B30).withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            '${entry.symptoms.length} Symptom${entry.symptoms.length > 1 ? "e" : ""}',
                            style: const TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFFFF3B30),
                            ),
                          ),
                        ),
                      const SizedBox(width: 6),
                      GestureDetector(
                        onTap: () => _prefillFromEntry(entry),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFF007AFF)
                                .withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.replay_rounded,
                                  size: 14, color: Color(0xFF007AFF)),
                              SizedBox(width: 3),
                              Text(
                                'Nochmal',
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                  color: Color(0xFF007AFF),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              )),
        ],
      ),
    );
  }

  // ── Diary CTA ──────────────────────────────────────────────────────
  Widget _buildDiaryCta() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: SizedBox(
        width: double.infinity,
        child: OutlinedButton.icon(
          onPressed: () => Navigator.of(context).push(
            MaterialPageRoute<void>(
              builder: (_) => const NutritionDiaryScreen(),
            ),
          ),
          icon: const Icon(Icons.book_rounded, size: 18),
          label: const Text('Vollständiges Tagebuch öffnen'),
          style: OutlinedButton.styleFrom(
            foregroundColor: const Color(0xFF007AFF),
            side: const BorderSide(color: Color(0xFF007AFF)),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
            ),
            padding: const EdgeInsets.symmetric(vertical: 12),
          ),
        ),
      ),
    );
  }

  bool _isSameDay(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;
}

// ── Reusable private widgets ──────────────────────────────────────────────

class _AnimatedCard extends StatelessWidget {
  const _AnimatedCard({required this.child, this.borderColor});
  final Widget child;
  final Color? borderColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: borderColor != null
            ? Border.all(color: borderColor!, width: 1.5)
            : null,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 12,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: child,
    );
  }
}

class _SelectChip extends StatelessWidget {
  const _SelectChip({
    required this.label,
    required this.selected,
    required this.onTap,
    this.color,
  });
  final String label;
  final bool selected;
  final VoidCallback onTap;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final chipColor = color ?? const Color(0xFF007AFF);
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: selected
              ? chipColor.withValues(alpha: 0.12)
              : const Color(0xFFF2F2F7),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: selected ? chipColor : const Color(0xFFE5E5EA),
            width: selected ? 1.5 : 1,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 14,
            fontWeight: selected ? FontWeight.w600 : FontWeight.w500,
            color: selected ? chipColor : const Color(0xFF636366),
          ),
        ),
      ),
    );
  }
}

class _QuickChip extends StatelessWidget {
  const _QuickChip({required this.label, required this.onTap});
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: const Color(0xFF5AC8FA).withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: const Color(0xFF5AC8FA).withValues(alpha: 0.4),
          ),
        ),
        child: Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: Color(0xFF5AC8FA),
          ),
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

class _ProgressRing extends StatelessWidget {
  const _ProgressRing({
    required this.value,
    required this.target,
    required this.label,
    required this.color,
    this.unit,
  });
  final int value;
  final int target;
  final String label;
  final Color color;
  final String? unit;

  @override
  Widget build(BuildContext context) {
    final progress = target > 0 ? (value / target).clamp(0.0, 1.0) : 0.0;
    return SizedBox(
      width: 90,
      child: Column(
        children: [
          SizedBox(
            width: 64,
            height: 64,
            child: CustomPaint(
              painter: _RingPainter(progress: progress, color: color),
              child: Center(
                child: Text(
                  '$value',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    color: color,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            unit != null ? '$label ($unit)' : label,
            style: const TextStyle(fontSize: 11, color: Color(0xFF8E8E93)),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

class _RingPainter extends CustomPainter {
  _RingPainter({required this.progress, required this.color});
  final double progress;
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    const strokeWidth = 6.0;
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width - strokeWidth) / 2;

    // Background ring
    canvas.drawCircle(
      center,
      radius,
      Paint()
        ..color = color.withValues(alpha: 0.15)
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeWidth,
    );

    // Progress arc
    if (progress > 0) {
      final rect = Rect.fromCircle(center: center, radius: radius);
      canvas.drawArc(
        rect,
        -math.pi / 2,
        2 * math.pi * progress,
        false,
        Paint()
          ..color = color
          ..style = PaintingStyle.stroke
          ..strokeWidth = strokeWidth
          ..strokeCap = StrokeCap.round,
      );
    }
  }

  @override
  bool shouldRepaint(_RingPainter oldDelegate) =>
      oldDelegate.progress != progress || oldDelegate.color != color;
}

class _TargetRow extends StatelessWidget {
  const _TargetRow({
    required this.icon,
    required this.iconColor,
    required this.label,
    required this.value,
    required this.min,
    required this.max,
    required this.step,
    required this.onChanged,
  });
  final IconData icon;

  final Color iconColor;
  final String label;
  final int value;
  final int min;
  final int max;
  final int step;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        GlassIcon(icon: icon, color: iconColor, size: 18),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label,
                  style: const TextStyle(
                      fontSize: 13, fontWeight: FontWeight.w600)),
              Text('$value',
                  style: const TextStyle(
                      fontSize: 12, color: Color(0xFF8E8E93))),
            ],
          ),
        ),
        IconButton(
          icon: const Icon(Icons.remove_circle_outline_rounded, size: 22),
          onPressed: value > min
              ? () => onChanged((value - step).clamp(min, max))
              : null,
        ),
        IconButton(
          icon: const Icon(Icons.add_circle_outline_rounded, size: 22),
          onPressed: value < max
              ? () => onChanged((value + step).clamp(min, max))
              : null,
        ),
      ],
    );
  }
}
