import 'package:flutter/material.dart';

import '../features/medication/presentation/medication_screen.dart';
import '../features/vitals/presentation/vitals_screen.dart';
import '../screens/screens.dart';
import '../ui/ui.dart';

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
    builder: (_) => const WoundDocumentationScreen(),
  ),
  'pain_log': _RouteEntry(
    title: 'Schmerztagebuch',
    icon: Icons.edit_note_rounded,
    description:
        'Hier kannst du dein Schmerzlevel auf einer Skala von 1–10 dokumentieren.',
  ),
  'vitals': _RouteEntry(
    title: 'Vitalwerte',
    icon: Icons.monitor_heart_outlined,
    builder: (_) => const VitalsScreen(),
  ),
  'medication': _RouteEntry(
    title: 'Medikamente',
    icon: Icons.medication_rounded,
    builder: (_) => const MedicationScreen(),
  ),
  'documents_upload': _RouteEntry(
    title: 'Dokumente hochladen',
    icon: Icons.upload_file_rounded,
    builder: (_) => const DokumenteScreen(),
  ),
  'questions_notes': _RouteEntry(
    title: 'Fragen & Notizen',
    icon: Icons.sticky_note_2_rounded,
    description:
        'Halte Fragen an deinen Chirurgen und persönliche Notizen fest.',
  ),
  'transport': _RouteEntry(
    title: 'Transport',
    icon: Icons.directions_car_rounded,
    description: 'Plane Hin- und Rückfahrt zur Klinik.',
  ),
  'checklist': _RouteEntry(
    title: 'OP-Checkliste',
    icon: Icons.checklist_rounded,
    builder: (_) => const OperationTimelineScreen(),
  ),
  'symptom_check': _RouteEntry(
    title: 'Symptom-Check',
    icon: Icons.health_and_safety_rounded,
    builder: (_) => const SymptomCheckerScreen(),
  ),
  'appointment': _RouteEntry(
    title: 'Termin hinzufügen',
    icon: Icons.calendar_month_rounded,
    description: 'Erstelle und verwalte deine OP-bezogenen Termine.',
  ),
  'task_add': _RouteEntry(
    title: 'Aufgabe hinzufügen',
    icon: Icons.add_task_rounded,
    description: 'Erstelle eine eigene Aufgabe für deine OP-Vorbereitung.',
  ),
};

// ── Navigation helper ────────────────────────────────────────────────────────

/// Navigates to the screen registered for [routeKey].
/// Falls back to a placeholder if the screen isn't implemented yet.
void navigateToRoute(BuildContext context, String routeKey) {
  Haptic.light();

  final entry = _registry[routeKey];
  if (entry == null) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Kommt gleich'),
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
          entry.description ?? 'Dieses Feature wird bald verfügbar sein.',
    );
  }

  Navigator.of(context).push(
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
                              'Dieses Feature wird bald verfügbar sein.',
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
                            'Coming soon',
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
    this.emoji,
  });

  final String label;
  final IconData icon;
  final String routeKey;
  final String? emoji;
}

const _sheetActions = <_SheetAction>[
  _SheetAction(
    label: 'Aufgabe hinzufügen',
    icon: Icons.add_task_rounded,
    routeKey: 'task_add',
    emoji: '✅',
  ),
  _SheetAction(
    label: 'Termin hinzufügen',
    icon: Icons.calendar_month_rounded,
    routeKey: 'appointment',
    emoji: '📅',
  ),
  _SheetAction(
    label: 'Dokument hochladen',
    icon: Icons.upload_file_rounded,
    routeKey: 'documents_upload',
    emoji: '📄',
  ),
  _SheetAction(
    label: 'Wundfoto',
    icon: Icons.camera_alt_rounded,
    routeKey: 'wounds_photo',
    emoji: '📸',
  ),
  _SheetAction(
    label: 'Vitalwerte',
    icon: Icons.monitor_heart_outlined,
    routeKey: 'vitals',
    emoji: '❤️',
  ),
  _SheetAction(
    label: 'Schmerzlevel',
    icon: Icons.edit_note_rounded,
    routeKey: 'pain_log',
    emoji: '📝',
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
        Navigator.of(context).pop();
        navigateToRoute(context, action.routeKey);
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
                child: action.emoji != null
                    ? Text(action.emoji!, style: const TextStyle(fontSize: 20))
                    : Icon(action.icon, size: 22, color: AppColors.primary),
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
