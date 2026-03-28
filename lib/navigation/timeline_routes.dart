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
import '../l10n/app_localizations.dart';

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

Map<String, _RouteEntry> _registry(AppLocalizations l) => {
  'wounds_photo': _RouteEntry(
    title: l.timelineRouteWoundDoc,
    icon: Icons.camera_alt_rounded,
    builder: (_) => const WoundHubScreen(),
  ),
  'pain_log': _RouteEntry(
    title: l.timelineRoutePainLog,
    icon: Icons.edit_note_rounded,
    builder: (_) => const PainScreen(),
    description: l.timelineRoutePainLogDesc,
  ),
  'mood_log': _RouteEntry(
    title: l.timelineRouteMoodLog,
    icon: Icons.sentiment_satisfied_rounded,
    builder: (_) => const MoodScreen(),
    description: l.timelineRouteMoodLogDesc,
  ),
  'vitals': _RouteEntry(
    title: l.timelineRouteVitals,
    icon: Icons.monitor_heart_outlined,
    builder: (_) => const VitalsScreen(),
  ),
  'sleep_log': _RouteEntry(
    title: l.timelineRouteSleepLog,
    icon: Icons.bedtime_rounded,
    builder: (_) => const SleepDiaryScreen(),
    description: l.timelineRouteSleepLogDesc,
  ),
  'medication': _RouteEntry(
    title: l.timelineRouteMedication,
    icon: Icons.medication_rounded,
    builder: (_) => const MedicationScreen(),
  ),
  'nutrition_log': _RouteEntry(
    title: l.timelineRouteNutrition,
    icon: Icons.restaurant_rounded,
    builder: (_) => const NutritionScreen(),
    description: l.timelineRouteNutritionDesc,
  ),
  'documents_upload': _RouteEntry(
    title: l.timelineRouteDocuments,
    icon: Icons.upload_file_rounded,
    builder: (_) => const DokumenteScreen(),
  ),
  'questions_notes': _RouteEntry(
    title: l.timelineRouteQuestions,
    icon: Icons.sticky_note_2_rounded,
    builder: (_) => const DoctorQuestionsScreen(),
    description: l.timelineRouteQuestionsDesc,
  ),
  'transport': _RouteEntry(
    title: l.timelineRouteTransport,
    icon: Icons.directions_car_rounded,
    builder: (_) => const _TransportPlanScreen(),
    description: l.timelineRouteTransportDesc,
  ),

  'symptom_check': _RouteEntry(
    title: l.timelineRouteSymptomCheck,
    icon: Icons.health_and_safety_rounded,
    builder: (_) => const SymptomCheckerScreen(),
  ),
  'rehab_session': _RouteEntry(
    title: l.timelineRouteRehab,
    icon: Icons.fitness_center_rounded,
    builder: (_) => const RehabScreen(),
    description: l.timelineRouteRehabDesc,
  ),
  'red_flag_check': _RouteEntry(
    title: l.timelineRouteRedFlag,
    icon: Icons.warning_amber_rounded,
    builder: (_) => const AlertScreen(),
    description: l.timelineRouteRedFlagDesc,
  ),
  'appointment': _RouteEntry(
    title: l.timelineRouteAppointment,
    icon: Icons.calendar_month_rounded,
    builder: (_) => const AppointmentsScreen(),
    description: l.timelineRouteAppointmentDesc,
  ),
  'task_add': _RouteEntry(
    title: l.timelineRouteTaskAdd,
    icon: Icons.add_task_rounded,
    builder: (_) => const _AddTaskScreen(),
    description: l.timelineRouteTaskAddDesc,
  ),
  'note_add': _RouteEntry(
    title: l.timelineRouteNoteAdd,
    icon: Icons.sticky_note_2_rounded,
    builder: (_) => const _AddNoteScreen(),
    description: l.timelineRouteNoteAddDesc,
  ),
};

// ── Navigation helper ────────────────────────────────────────────────────────

/// Navigates to the screen registered for [routeKey].
/// Falls back to a placeholder if the screen isn't implemented yet.
void navigateToRoute(BuildContext context, String routeKey, {NavigatorState? navigator}) {
  Haptic.light();

  final l = AppLocalizations.of(context)!;
  final entry = _registry(l)[routeKey];
  if (entry == null) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(l.pageOpenError),
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
          entry.description ?? l.pageOpenError,
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
    final l = AppLocalizations.of(context)!;
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
                          child: Text(
                            l.placeholderLoading,
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
                  label: l.zurueckZurTimeline,
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
  _SheetAction({
    required this.label,
    required this.icon,
    required this.routeKey,
  });

  final String label;
  final IconData icon;
  final String routeKey;
}

List<_SheetAction> _sheetActions(AppLocalizations l) => <_SheetAction>[
  _SheetAction(
    label: l.timelineRouteTaskAdd,
    icon: Icons.add_task_rounded,
    routeKey: 'task_add',
  ),
  _SheetAction(
    label: l.timelineRouteNoteAdd,
    icon: Icons.sticky_note_2_rounded,
    routeKey: 'note_add',
  ),
  _SheetAction(
    label: l.timelineRouteAppointment,
    icon: Icons.calendar_month_rounded,
    routeKey: 'appointment',
  ),
  _SheetAction(
    label: l.timelineSheetDocUpload,
    icon: Icons.upload_file_rounded,
    routeKey: 'documents_upload',
  ),
  _SheetAction(
    label: l.timelineSheetWoundPhoto,
    icon: Icons.camera_alt_rounded,
    routeKey: 'wounds_photo',
  ),
  _SheetAction(
    label: l.timelineRouteVitals,
    icon: Icons.monitor_heart_outlined,
    routeKey: 'vitals',
  ),
  _SheetAction(
    label: l.timelineSheetPainLevel,
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
    final l = AppLocalizations.of(context)!;
    final tt = Theme.of(context).textTheme;
    final bottomPadding = MediaQuery.of(context).padding.bottom;

    final actions = _sheetActions(l);

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
            Text(l.entryNew, style: tt.headlineMedium),
            const SizedBox(height: AppSpacing.xxl),

            for (var i = 0; i < actions.length; i++) ...[
              _SheetActionTile(action: actions[i]),
              if (i < actions.length - 1)
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
    final l = AppLocalizations.of(context)!;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyDriver, _driverCtrl.text);
    await prefs.setString(_keyPickup, _pickupCtrl.text);
    await prefs.setString(_keyReturn, _returnCtrl.text);
    await prefs.setString(_keyNotes, _notesCtrl.text);
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(l.transportPlanSaved)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    return GlassPage(
      title: l.timelineRouteTransport,
      titleIcon: AppIcons.ambulant,
      titleColor: AppColors.primary,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                l.timelineTransportHint,
                style: TextStyle(fontSize: 15, color: AppColors.textSecondary),
              ),
              const SizedBox(height: AppSpacing.xl),
              _field(l.timelineTransportDriver, Icons.person_rounded, _driverCtrl),
              const SizedBox(height: AppSpacing.md),
              _field(l.timelineTransportOutbound, Icons.departure_board_rounded, _pickupCtrl),
              const SizedBox(height: AppSpacing.md),
              _field(l.timelineTransportReturn, Icons.home_rounded, _returnCtrl),
              const SizedBox(height: AppSpacing.md),
              _field(l.timelineTransportNotes, Icons.notes_rounded, _notesCtrl, maxLines: 3),
              const SizedBox(height: AppSpacing.xl),
              SizedBox(
                width: double.infinity,
                child: FilledButton.icon(
                  onPressed: _save,
                  icon: const Icon(Icons.save_rounded),
                  label: Text(l.save),
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
      final l = AppLocalizations.of(context)!;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l.titleRequired)),
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
      final l = AppLocalizations.of(context)!;
      debugPrint('Error saving task: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l.taskSaveError)),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final dd = _dueDate.day.toString().padLeft(2, '0');
    final mm = _dueDate.month.toString().padLeft(2, '0');
    final hh = _dueDate.hour.toString().padLeft(2, '0');
    final min = _dueDate.minute.toString().padLeft(2, '0');

    return GlassPage(
      title: l.taskCreate,
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
                decoration: InputDecoration(
                  labelText: l.timelineAddTaskTitle,
                  prefixIcon: Icon(Icons.title_rounded),
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              TextField(
                controller: _subtitleCtrl,
                maxLines: 2,
                decoration: InputDecoration(
                  labelText: l.timelineAddTaskDescription,
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
                  label: Text(l.taskCreate),
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
      final l = AppLocalizations.of(context)!;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l.titleRequired)),
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
        final l = AppLocalizations.of(context)!;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l.noteSaveError)),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    return GlassPage(
      title: l.timelineRoutesNotizErstellen854,
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
                decoration: InputDecoration(
                  labelText: l.timelineAddTaskTitle,
                  prefixIcon: Icon(Icons.title_rounded),
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              TextField(
                controller: _bodyCtrl,
                maxLines: 5,
                decoration: InputDecoration(
                  labelText: l.timelineAddNoteContent,
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
                  label: Text(l.noteSave),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
