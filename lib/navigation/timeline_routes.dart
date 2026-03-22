import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../domain/task_orchestrator_sync.dart';
import '../domain/timeline_engine.dart';
import '../features/appointments/presentation/appointments_screen.dart';
import '../features/medication/presentation/medication_screen.dart';
import '../features/nutrition/presentation/nutrition_screen.dart';
import '../features/mood/presentation/mood_screen.dart';
import '../features/pain/presentation/pain_screen.dart';
import '../features/rehab/presentation/rehab_screen.dart';
import '../features/sleep/presentation/sleep_diary_screen.dart';
import '../features/questions/presentation/doctor_questions_screen.dart';
import '../features/vitals/presentation/vitals_screen.dart';
import '../features/wound/presentation/wound_hub_screen.dart';
import '../screens/screens.dart';
import '../ui/ui.dart';
import '../ui/theme/app_icons.dart';

// ── Route entry ──────────────────────────────────────────────────────────────

class _RouteEntry {
  const _RouteEntry({
    required this.title,
    required this.icon,
    this.builder,
    this.description,
  });

  final String title;
  final IconData icon;
  final String? description;
  final WidgetBuilder? builder;

  bool get isImplemented => builder != null;
}

// ── Registry ─────────────────────────────────────────────────────────────────

final Map<String, _RouteEntry> _registry = {
  'wounds_photo': _RouteEntry(
    title: 'Wunddokumentation',
    icon: Icons.camera_alt_rounded,
    builder: (_) => const WoundHubScreen(),
  ),
  'pain_log': _RouteEntry(
    title: 'Schmerztagebuch',
    icon: Icons.edit_note_rounded,
    builder: (_) => const PainScreen(),
    description:
        'Hier kannst du dein Schmerzlevel auf einer Skala von 1–10 dokumentieren.',
  ),
  'mood_log': _RouteEntry(
    title: 'Stimmungstagebuch',
    icon: Icons.sentiment_satisfied_rounded,
    builder: (_) => const MoodScreen(),
    description:
        'Erfasse deine Stimmung und erkenne Muster in deinem emotionalen Wohlbefinden.',
  ),
  'vitals': _RouteEntry(
    title: 'Vitalwerte',
    icon: Icons.monitor_heart_outlined,
    builder: (_) => const VitalsScreen(),
  ),
  'sleep_log': _RouteEntry(
    title: 'Schlaftagebuch',
    icon: Icons.bedtime_rounded,
    builder: (_) => const SleepDiaryScreen(),
    description:
        'Hier kannst du deine Schlafdauer und -qualität dokumentieren.',
  ),
  'medication': _RouteEntry(
    title: 'Medikamente',
    icon: Icons.medication_rounded,
    builder: (_) => const MedicationScreen(),
  ),
  'nutrition_log': _RouteEntry(
    title: 'Ernährungstagebuch',
    icon: Icons.restaurant_rounded,
    builder: (_) => const NutritionScreen(),
    description:
        'Hier kannst du deine Mahlzeiten dokumentieren und Ernährungsempfehlungen erhalten.',
  ),
  'documents_upload': _RouteEntry(
    title: 'Dokumente hochladen',
    icon: Icons.upload_file_rounded,
    builder: (_) => const DokumenteScreen(),
  ),
  'questions_notes': _RouteEntry(
    title: 'Fragen & Notizen',
    icon: Icons.sticky_note_2_rounded,
    builder: (_) => const DoctorQuestionsScreen(),
    description:
        'Halte Fragen an deinen Chirurgen und persönliche Notizen fest.',
  ),
  'transport': _RouteEntry(
    title: 'Transport',
    icon: Icons.directions_car_rounded,
    builder: (_) => const _TransportPlanScreen(),
    description: 'Plane Hin- und Rückfahrt zur Klinik.',
  ),

  'symptom_check': _RouteEntry(
    title: 'Symptom-Check',
    icon: Icons.health_and_safety_rounded,
    builder: (_) => const SymptomCheckerScreen(),
  ),
  'rehab_session': _RouteEntry(
    title: 'Reha',
    icon: Icons.fitness_center_rounded,
    builder: (_) => const RehabScreen(),
    description: 'Öffnet die Reha-Übersicht für Übungen und Fortschritt.',
  ),
  'red_flag_check': _RouteEntry(
    title: 'Red-Flag Cockpit',
    icon: Icons.warning_amber_rounded,
    builder: (_) => const AlertScreen(),
    description: 'Aktive Warnungen und Notfallaktionen prüfen.',
  ),
  'appointment': _RouteEntry(
    title: 'Termin hinzufügen',
    icon: Icons.calendar_month_rounded,
    builder: (_) => const AppointmentsScreen(),
    description: 'Erstelle und verwalte deine OP-bezogenen Termine.',
  ),
  'task_add': _RouteEntry(
    title: 'Aufgabe hinzufügen',
    icon: Icons.add_task_rounded,
    builder: (_) => const _AddTaskScreen(),
    description: 'Erstelle eine eigene Aufgabe für deine OP-Vorbereitung.',
  ),
  'note_add': _RouteEntry(
    title: 'Notiz erstellen',
    icon: Icons.sticky_note_2_rounded,
    builder: (_) => const _AddNoteScreen(),
    description: 'Halte einen freien Eintrag in deiner Timeline fest.',
  ),
};

// ── Navigation helper ────────────────────────────────────────────────────────

/// Navigates to the screen registered for [routeKey].
/// Falls back to a placeholder if the screen isn't implemented yet.
void navigateToRoute(BuildContext context, String routeKey, {NavigatorState? navigator}) {
  Haptic.light();

  final entry = _registry[routeKey];
  if (entry == null) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Diese Seite konnte nicht geöffnet werden.'),
        duration: Duration(milliseconds: 1400),
      ),
    );
    return;
  }
  final Widget destination;

  if (entry.isImplemented) {
    destination = entry.builder!(context);
  } else {
    destination = PlaceholderScreen(
      title: entry.title,
      icon: entry.icon,
      description:
          entry.description ?? 'Diese Seite konnte nicht geladen werden.',
    );
  }

  final nav = navigator ?? Navigator.of(context);
  nav.push(
    PageRouteBuilder<void>(
      transitionDuration: const Duration(milliseconds: 340),
      reverseTransitionDuration: const Duration(milliseconds: 280),
      pageBuilder: (ctx, a1, a2) => destination,
      transitionsBuilder: (ctx, animation, secondaryAnimation, child) {
        final curved = CurvedAnimation(
          parent: animation,
          curve: MotionCurve.standard,
          reverseCurve: Curves.easeIn,
        );
        return SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(1.0, 0.0),
            end: Offset.zero,
          ).animate(curved),
          child: FadeTransition(
            opacity: CurvedAnimation(
              parent: animation,
              curve: const Interval(0.0, 0.6),
            ),
            child: child,
          ),
        );
      },
    ),
  );
}

// ── Placeholder screen ───────────────────────────────────────────────────────

class PlaceholderScreen extends StatelessWidget {
  const PlaceholderScreen({
    super.key,
    required this.title,
    required this.icon,
    this.description,
  });

  final String title;
  final IconData icon;
  final String? description;

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: AppBackground(
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: Column(
              children: [
                // ── Top bar ──────────────────────────────────
                Row(
                  children: [
                    PressableScale(
                      onTap: () {
                        Haptic.light();
                        Navigator.of(context).pop();
                      },
                      scaleFactor: 0.90,
                      child: GlassContainer(
                        padding: const EdgeInsets.all(AppSpacing.sm + 2),
                        borderRadius: AppRadius.borderRadiusMd,
                        variant: GlassVariant.thin,
                        elevation: GlassElevation.low,
                        child: const Icon(
                          Icons.arrow_back_ios_new_rounded,
                          size: 18,
                          color: AppColors.grey700,
                        ),
                      ),
                    ),
                    const SizedBox(width: AppSpacing.md),
                    Expanded(
                      child: Text(
                        title,
                        style: tt.titleLarge,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),

                // ── Center content ───────────────────────────
                const Spacer(),
                FadeSlideIn(
                  child: GlassContainer(
                    padding: const EdgeInsets.all(AppSpacing.xxxl),
                    borderRadius: AppRadius.borderRadiusXxl,
                    variant: GlassVariant.medium,
                    elevation: GlassElevation.medium,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 72,
                          height: 72,
                          decoration: BoxDecoration(
                            gradient: AppColors.primaryGradient,
                            borderRadius: AppRadius.borderRadiusLg,
                            boxShadow: [
                              BoxShadow(
                                color: AppColors.primary.withValues(
                                  alpha: 0.25,
                                ),
                                blurRadius: 20,
                                offset: const Offset(0, 6),
                              ),
                            ],
                          ),
                          child: Icon(icon, size: 32, color: AppColors.white),
                        ),
                        const SizedBox(height: AppSpacing.xxl),
                        Text(
                          title,
                          style: tt.headlineMedium,
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: AppSpacing.md),
                        Text(
                          description ??
                              'Diese Seite ist derzeit nicht verfügbar.',
                          style: tt.bodyMedium?.copyWith(
                            color: AppColors.textSecondary,
                            height: 1.5,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: AppSpacing.xxl),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: AppSpacing.lg,
                            vertical: AppSpacing.xs + 1,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.warning.withValues(alpha: 0.10),
                            borderRadius: AppRadius.borderRadiusPill,
                            border: Border.all(
                              color: AppColors.warning.withValues(alpha: 0.20),
                            ),
                          ),
                          child: const Text(
                            'Wird geladen…',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: AppColors.warning,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const Spacer(),

                // ── Back button ──────────────────────────────
                GlassButton(
                  onPressed: () => Navigator.of(context).pop(),
                  label: 'Zurück zur Timeline',
                  icon: Icons.arrow_back_rounded,
                  expand: true,
                ),
                const SizedBox(height: AppSpacing.lg),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ── "+ Neu" bottom sheet ─────────────────────────────────────────────────────

class _SheetAction {
  const _SheetAction({
    required this.label,
    required this.icon,
    required this.routeKey,
  });

  final String label;
  final IconData icon;
  final String routeKey;
}

const _sheetActions = <_SheetAction>[
  _SheetAction(
    label: 'Aufgabe hinzufügen',
    icon: Icons.add_task_rounded,
    routeKey: 'task_add',
  ),
  _SheetAction(
    label: 'Notiz erstellen',
    icon: Icons.sticky_note_2_rounded,
    routeKey: 'note_add',
  ),
  _SheetAction(
    label: 'Termin hinzufügen',
    icon: Icons.calendar_month_rounded,
    routeKey: 'appointment',
  ),
  _SheetAction(
    label: 'Dokument hochladen',
    icon: Icons.upload_file_rounded,
    routeKey: 'documents_upload',
  ),
  _SheetAction(
    label: 'Wundfoto',
    icon: Icons.camera_alt_rounded,
    routeKey: 'wounds_photo',
  ),
  _SheetAction(
    label: 'Vitalwerte',
    icon: Icons.monitor_heart_outlined,
    routeKey: 'vitals',
  ),
  _SheetAction(
    label: 'Schmerzlevel',
    icon: Icons.edit_note_rounded,
    routeKey: 'pain_log',
  ),
];

/// Shows the "+ Neu" glass bottom sheet with quick-action items.
void showNewEntrySheet(BuildContext context) {
  Haptic.light();
  showModalBottomSheet<void>(
    context: context,
    backgroundColor: Colors.transparent,
    isScrollControlled: true,
    builder: (ctx) => const _NewEntrySheet(),
  );
}

class _NewEntrySheet extends StatelessWidget {
  const _NewEntrySheet();

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;
    final bottomPadding = MediaQuery.of(context).padding.bottom;

    return Container(
      margin: const EdgeInsets.all(AppSpacing.md),
      child: GlassContainer(
        padding: EdgeInsets.only(
          top: AppSpacing.xxl,
          left: AppSpacing.lg,
          right: AppSpacing.lg,
          bottom: bottomPadding + AppSpacing.lg,
        ),
        borderRadius: AppRadius.borderRadiusXxl,
        variant: GlassVariant.thick,
        elevation: GlassElevation.high,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Handle
            Container(
              width: 36,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.grey400,
                borderRadius: AppRadius.borderRadiusPill,
              ),
            ),
            const SizedBox(height: AppSpacing.xl),
            Text('Neuer Eintrag', style: tt.headlineMedium),
            const SizedBox(height: AppSpacing.xxl),

            for (var i = 0; i < _sheetActions.length; i++) ...[
              _SheetActionTile(action: _sheetActions[i]),
              if (i < _sheetActions.length - 1)
                Padding(
                  padding: const EdgeInsets.only(left: 56),
                  child: Container(
                    height: 0.5,
                    color: AppColors.grey200.withValues(alpha: 0.5),
                  ),
                ),
            ],
          ],
        ),
      ),
    );
  }
}

class _SheetActionTile extends StatelessWidget {
  const _SheetActionTile({required this.action});

  final _SheetAction action;

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;

    return PressableScale(
      onTap: () {
        final nav = Navigator.of(context);
        nav.pop();
        navigateToRoute(context, action.routeKey, navigator: nav);
      },
      scaleFactor: 0.97,
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.xs,
          vertical: AppSpacing.md,
        ),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.06),
                borderRadius: AppRadius.borderRadiusSm,
              ),
              child: Center(
                child: Icon(action.icon, size: 22, color: AppColors.primary),
              ),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(child: Text(action.label, style: tt.titleSmall)),
            Icon(
              Icons.chevron_right_rounded,
              size: 20,
              color: AppColors.grey400,
            ),
          ],
        ),
      ),
    );
  }
}

// ── Transport plan screen ────────────────────────────────────────────────────

class _TransportPlanScreen extends StatefulWidget {
  const _TransportPlanScreen();

  @override
  State<_TransportPlanScreen> createState() => _TransportPlanScreenState();
}

class _TransportPlanScreenState extends State<_TransportPlanScreen> {
  static const _keyDriver = 'transport_driver';
  static const _keyPickup = 'transport_pickup';
  static const _keyReturn = 'transport_return';
  static const _keyNotes = 'transport_notes';

  final _driverCtrl = TextEditingController();
  final _pickupCtrl = TextEditingController();
  final _returnCtrl = TextEditingController();
  final _notesCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    _driverCtrl.dispose();
    _pickupCtrl.dispose();
    _returnCtrl.dispose();
    _notesCtrl.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    if (!mounted) return;
    _driverCtrl.text = prefs.getString(_keyDriver) ?? '';
    _pickupCtrl.text = prefs.getString(_keyPickup) ?? '';
    _returnCtrl.text = prefs.getString(_keyReturn) ?? '';
    _notesCtrl.text = prefs.getString(_keyNotes) ?? '';
  }

  Future<void> _save() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyDriver, _driverCtrl.text);
    await prefs.setString(_keyPickup, _pickupCtrl.text);
    await prefs.setString(_keyReturn, _returnCtrl.text);
    await prefs.setString(_keyNotes, _notesCtrl.text);
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Transportplanung gespeichert')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return GlassPage(
      title: 'Transport',
      titleIcon: AppIcons.ambulant,
      titleColor: AppColors.primary,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Plane deine Hin- und Rückfahrt zur Klinik.',
                style: TextStyle(fontSize: 15, color: AppColors.textSecondary),
              ),
              const SizedBox(height: AppSpacing.xl),
              _field('Fahrer/in', Icons.person_rounded, _driverCtrl),
              const SizedBox(height: AppSpacing.md),
              _field('Hinfahrt (Uhrzeit / Treffpunkt)', Icons.departure_board_rounded, _pickupCtrl),
              const SizedBox(height: AppSpacing.md),
              _field('Rückfahrt (Uhrzeit / Treffpunkt)', Icons.home_rounded, _returnCtrl),
              const SizedBox(height: AppSpacing.md),
              _field('Notizen', Icons.notes_rounded, _notesCtrl, maxLines: 3),
              const SizedBox(height: AppSpacing.xl),
              SizedBox(
                width: double.infinity,
                child: FilledButton.icon(
                  onPressed: _save,
                  icon: const Icon(Icons.save_rounded),
                  label: const Text('Speichern'),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _field(String label, IconData icon, TextEditingController ctrl,
      {int maxLines = 1}) {
    return TextField(
      controller: ctrl,
      maxLines: maxLines,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon),
        border: const OutlineInputBorder(),
      ),
    );
  }
}

// ── Add custom task screen ───────────────────────────────────────────────────

class _AddTaskScreen extends StatefulWidget {
  const _AddTaskScreen();

  @override
  State<_AddTaskScreen> createState() => _AddTaskScreenState();
}

class _AddTaskScreenState extends State<_AddTaskScreen> {
  final _titleCtrl = TextEditingController();
  final _subtitleCtrl = TextEditingController();
  DateTime _dueDate = DateTime.now().add(const Duration(days: 1));

  @override
  void dispose() {
    _titleCtrl.dispose();
    _subtitleCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _dueDate,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      locale: const Locale('de'),
    );
    if (picked != null && mounted) setState(() => _dueDate = picked);
  }

  Future<void> _pickTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(_dueDate),
    );
    if (picked != null && mounted) {
      setState(() {
        _dueDate = DateTime(
          _dueDate.year, _dueDate.month, _dueDate.day,
          picked.hour, picked.minute,
        );
      });
    }
  }

  Future<void> _save() async {
    final title = _titleCtrl.text.trim();
    if (title.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Bitte einen Titel eingeben')),
      );
      return;
    }

    final now = DateTime.now();
    final item = TimelineItem(
      id: 'custom_${now.millisecondsSinceEpoch}',
      type: TaskType.custom,
      title: title,
      subtitle: _subtitleCtrl.text.trim(),
      scheduledAt: _dueDate,
      dueAt: _dueDate,
      priority: TaskPriority.normal,
      state: TaskState.planned,
      deeplinkRoute: '',
      metadata: const <String, dynamic>{},
      createdAt: now,
      updatedAt: now,
    );

    try {
      await TaskOrchestratorSync.instance.upsert(item);
      if (mounted) Navigator.of(context).pop();
    } catch (e) {
      debugPrint('Error saving task: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Fehler beim Speichern der Aufgabe')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final dd = _dueDate.day.toString().padLeft(2, '0');
    final mm = _dueDate.month.toString().padLeft(2, '0');
    final hh = _dueDate.hour.toString().padLeft(2, '0');
    final min = _dueDate.minute.toString().padLeft(2, '0');

    return GlassPage(
      title: 'Aufgabe erstellen',
      titleIcon: AppIcons.edit,
      titleColor: AppColors.primary,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextField(
                controller: _titleCtrl,
                decoration: const InputDecoration(
                  labelText: 'Titel',
                  prefixIcon: Icon(Icons.title_rounded),
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              TextField(
                controller: _subtitleCtrl,
                maxLines: 2,
                decoration: const InputDecoration(
                  labelText: 'Beschreibung (optional)',
                  prefixIcon: Icon(Icons.notes_rounded),
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: AppSpacing.lg),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: _pickDate,
                      icon: const Icon(Icons.calendar_today_rounded),
                      label: Text('$dd.$mm.${_dueDate.year}'),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: _pickTime,
                      icon: const Icon(Icons.access_time_rounded),
                      label: Text('$hh:$min'),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.xl),
              SizedBox(
                width: double.infinity,
                child: FilledButton.icon(
                  onPressed: _save,
                  icon: const Icon(Icons.add_task_rounded),
                  label: const Text('Aufgabe erstellen'),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

// ── Add free note screen ─────────────────────────────────────────────────────

class _AddNoteScreen extends StatefulWidget {
  const _AddNoteScreen();

  @override
  State<_AddNoteScreen> createState() => _AddNoteScreenState();
}

class _AddNoteScreenState extends State<_AddNoteScreen> {
  final _titleCtrl = TextEditingController();
  final _bodyCtrl = TextEditingController();

  @override
  void dispose() {
    _titleCtrl.dispose();
    _bodyCtrl.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final title = _titleCtrl.text.trim();
    if (title.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Bitte einen Titel eingeben')),
      );
      return;
    }

    final now = DateTime.now();
    final item = TimelineItem(
      id: 'note_${now.millisecondsSinceEpoch}',
      type: TaskType.note,
      title: title,
      subtitle: _bodyCtrl.text.trim(),
      scheduledAt: now,
      priority: TaskPriority.normal,
      state: TaskState.done,
      deeplinkRoute: '',
      metadata: const <String, dynamic>{},
      createdAt: now,
      updatedAt: now,
      doneAt: now,
    );

    debugPrint('[_AddNoteScreen] _save – id=${item.id}, title="$title"');
    try {
      await TaskOrchestratorSync.instance.upsert(item);
      debugPrint('[_AddNoteScreen] upsert complete');
      if (mounted) Navigator.of(context).pop();
    } catch (e) {
      debugPrint('Error saving note: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Fehler beim Speichern der Notiz')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return GlassPage(
      title: 'Notiz erstellen',
      titleIcon: Icons.sticky_note_2_rounded,
      titleColor: AppColors.primary,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextField(
                controller: _titleCtrl,
                decoration: const InputDecoration(
                  labelText: 'Titel',
                  prefixIcon: Icon(Icons.title_rounded),
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              TextField(
                controller: _bodyCtrl,
                maxLines: 5,
                decoration: const InputDecoration(
                  labelText: 'Inhalt (optional)',
                  prefixIcon: Icon(Icons.notes_rounded),
                  border: OutlineInputBorder(),
                  alignLabelWithHint: true,
                ),
              ),
              const SizedBox(height: AppSpacing.xl),
              SizedBox(
                width: double.infinity,
                child: FilledButton.icon(
                  onPressed: _save,
                  icon: const Icon(Icons.sticky_note_2_rounded),
                  label: const Text('Notiz speichern'),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
