import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';

import '../navigation/timeline_routes.dart';
import '../ui/ui.dart';

// ── Phase enum ───────────────────────────────────────────────────────────────

enum TimelinePhase { preOp, opTag, postOp, reha }

extension TimelinePhaseStyle on TimelinePhase {
  Color get tint => switch (this) {
        TimelinePhase.preOp => AppColors.primary,
        TimelinePhase.opTag => AppColors.error,
        TimelinePhase.postOp => AppColors.success,
        TimelinePhase.reha => AppColors.accent,
      };

  String? get badge => switch (this) {
        TimelinePhase.opTag => 'OP‑TAG',
        _ => null,
      };
}

// ── Models ───────────────────────────────────────────────────────────────────

class TimelineTask {
  TimelineTask({
    required this.id,
    required this.emoji,
    required this.title,
    this.subtitle,
    this.routeKey,
    this.isDone = false,
  });

  final String id;
  final String emoji;
  final String title;
  final String? subtitle;
  final String? routeKey;
  bool isDone;
}

class TimelineSection {
  TimelineSection({
    required this.offsetLabel,
    required this.dateLabel,
    required this.tasks,
    this.phase = TimelinePhase.preOp,
  });

  final String offsetLabel;
  final String dateLabel;
  final TimelinePhase phase;
  final List<TimelineTask> tasks;

  Color get tint => phase.tint;
  String? get phaseBadge => phase.badge;
  bool get isHighlighted => phase == TimelinePhase.opTag;

  int get completedCount => tasks.where((t) => t.isDone).length;
  int get totalCount => tasks.length;
}

// ── Dummy data ───────────────────────────────────────────────────────────────

List<TimelineSection> _buildSampleTimeline() => [
      TimelineSection(
        offsetLabel: '−14 Tage',
        dateLabel: 'Do. 10. Apr.',
        phase: TimelinePhase.preOp,
        tasks: [
          TimelineTask(
            id: 't1',
            emoji: '📋',
            title: 'Unterlagen sammeln',
            subtitle: 'Versichertenkarte, Überweisungen, Befunde',
            routeKey: 'documents_upload',
            isDone: true,
          ),
          TimelineTask(
            id: 't2',
            emoji: '💊',
            title: 'Medikamentenliste erstellen',
            subtitle: 'Aktuelle Medikation dokumentieren',
            routeKey: 'medication',
            isDone: true,
          ),
        ],
      ),
      TimelineSection(
        offsetLabel: '−7 Tage',
        dateLabel: 'Do. 17. Apr.',
        phase: TimelinePhase.preOp,
        tasks: [
          TimelineTask(
            id: 't3',
            emoji: '🚗',
            title: 'Transport organisieren',
            subtitle: 'Hin- und Rückfahrt planen',
            routeKey: 'transport',
          ),
          TimelineTask(
            id: 't4',
            emoji: '❓',
            title: 'Fragen notieren',
            subtitle: 'Fragen an den Chirurgen aufschreiben',
            routeKey: 'questions_notes',
          ),
        ],
      ),
      TimelineSection(
        offsetLabel: '−3 Tage',
        dateLabel: 'Mo. 21. Apr.',
        phase: TimelinePhase.preOp,
        tasks: [
          TimelineTask(
            id: 't5',
            emoji: '🏠',
            title: 'Haushalt vorbereiten',
            subtitle: 'Einkäufe, Kühlschrank auffüllen',
            routeKey: 'checklist',
          ),
          TimelineTask(
            id: 't6',
            emoji: '👕',
            title: 'Kleidung bereitlegen',
            subtitle: 'Bequeme Kleidung & Tasche packen',
            routeKey: 'checklist',
          ),
        ],
      ),
      TimelineSection(
        offsetLabel: 'Morgen',
        dateLabel: 'Mi. 23. Apr.',
        phase: TimelinePhase.preOp,
        tasks: [
          TimelineTask(
            id: 't7',
            emoji: '🍽️',
            title: 'Nüchtern ab 22 Uhr',
            subtitle: 'Nichts essen oder trinken',
            routeKey: 'checklist',
          ),
        ],
      ),
      TimelineSection(
        offsetLabel: 'OP‑TAG',
        dateLabel: 'Do. 24. Apr.',
        phase: TimelinePhase.opTag,
        tasks: [
          TimelineTask(
            id: 't8',
            emoji: '⏰',
            title: 'Pünktlich ankommen',
            subtitle: '07:30 Uhr · Aufnahme Station 3B',
            routeKey: 'transport',
          ),
          TimelineTask(
            id: 't9',
            emoji: '💍',
            title: 'Schmuck ablegen',
            subtitle: 'Ringe, Ketten, Piercings entfernen',
            routeKey: 'checklist',
          ),
        ],
      ),
      TimelineSection(
        offsetLabel: '+1 nach OP',
        dateLabel: 'Fr. 25. Apr.',
        phase: TimelinePhase.postOp,
        tasks: [
          TimelineTask(
            id: 't10',
            emoji: '🛌',
            title: 'Schonung einhalten',
            subtitle: 'Bein hochlagern, Ruhe bewahren',
            routeKey: 'checklist',
          ),
          TimelineTask(
            id: 't11',
            emoji: '💧',
            title: 'Flüssigkeit aufnehmen',
            subtitle: 'Mindestens 2 Liter trinken',
            routeKey: 'vitals',
          ),
        ],
      ),
      TimelineSection(
        offsetLabel: '+2 nach OP',
        dateLabel: 'Sa. 26. Apr.',
        phase: TimelinePhase.postOp,
        tasks: [
          TimelineTask(
            id: 't12',
            emoji: '📝',
            title: 'Schmerzlevel dokumentieren',
            subtitle: 'Skala 1–10 im Tagebuch festhalten',
            routeKey: 'pain_log',
          ),
          TimelineTask(
            id: 't13',
            emoji: '📸',
            title: 'Wundfoto machen',
            subtitle: 'Täglich Verlauf fotografieren',
            routeKey: 'wounds_photo',
          ),
          TimelineTask(
            id: 't14',
            emoji: '💊',
            title: 'Medikamente einnehmen',
            subtitle: 'Laut Entlassplan vom Arzt',
            routeKey: 'medication',
          ),
        ],
      ),
    ];

// ── Quick actions ─────────────────────────────────────────────────────────────

class _QuickAction {
  const _QuickAction({
    required this.label,
    required this.emoji,
    required this.routeKey,
  });

  final String label;
  final String emoji;
  final String routeKey;
}

const _quickActions = <_QuickAction>[
  _QuickAction(label: 'Wundfoto', emoji: '📸', routeKey: 'wounds_photo'),
  _QuickAction(label: 'Schmerzlevel', emoji: '📊', routeKey: 'pain_log'),
  _QuickAction(label: 'Vitalwerte', emoji: '❤️', routeKey: 'vitals'),
  _QuickAction(label: 'Dokument', emoji: '⬆️', routeKey: 'documents_upload'),
];

/// Ensures the OP-TAG milestone pulse fires only once per app session.
bool _opTagMilestoneShown = false;

// ── Screen ───────────────────────────────────────────────────────────────────

class TimelineFeedScreen extends StatefulWidget {
  const TimelineFeedScreen({super.key});

  @override
  State<TimelineFeedScreen> createState() => _TimelineFeedScreenState();
}

class _TimelineFeedScreenState extends State<TimelineFeedScreen> {
  List<TimelineSection> _sections = const [];
  bool _didSeedDemoData = false;

  @override
  void initState() {
    super.initState();
    _seedDemoDataIfEmpty();
    if (kDebugMode) {
      debugPrint(
        '[TimelineFeedScreen] init sections=${_sections.length}',
      );
    }
  }

  void _seedDemoDataIfEmpty() {
    if (_didSeedDemoData || _sections.isNotEmpty) return;
    _didSeedDemoData = true;
    _sections = _buildSampleTimeline();
  }

  int get _totalTasks =>
      _sections.fold(0, (sum, s) => sum + s.totalCount);

  int get _doneTasks =>
      _sections.fold(0, (sum, s) => sum + s.completedCount);

  HeroBannerData get _bannerData => HeroBannerData(
        opTypeLabel: 'Knie-Arthroskopie',
        locationLabel: 'Stationär',
        dayLabel: 'Tag 18 nach OP',
        encouragementText: 'Weiterhin gute Genesung! 💪',
        dateLabel: '14.02.26',
        doneCount: _doneTasks,
        totalCount: _totalTasks,
      );

  void _toggleTask(int sectionIndex, int taskIndex) {
    Haptic.selection();
    setState(() {
      _sections[sectionIndex].tasks[taskIndex].isDone =
          !_sections[sectionIndex].tasks[taskIndex].isDone;
    });
  }

  @override
  Widget build(BuildContext context) {
    _seedDemoDataIfEmpty();
    final topPadding = MediaQuery.of(context).padding.top;

    if (_sections.isEmpty) {
      return _EmptyTimelineState(
        onLoadDemoData: () {
          if (!mounted) return;
          setState(() {
            _sections = _buildSampleTimeline();
            _didSeedDemoData = true;
          });
        },
      );
    }

    return CustomScrollView(
      physics: adaptiveScrollPhysics,
      slivers: [
        // ── App header ──────────────────────────────────────
        SliverToBoxAdapter(
          child: Padding(
            padding: EdgeInsets.only(
              left: AppSpacing.lg,
              right: AppSpacing.lg,
              top: topPadding + AppSpacing.lg,
            ),
            child: _AppHeader(),
          ),
        ),
        const SliverToBoxAdapter(
          child: SizedBox(height: AppSpacing.xl),
        ),

        // ── Hero banner ─────────────────────────────────────
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.lg,
            ),
            child: TimelineHeroBanner(
              data: _bannerData,
              onTap: () => navigateToRoute(context, 'checklist'),
            ),
          ),
        ),

        // ── Quick actions ─────────────────────────────────────
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.only(
              left: AppSpacing.lg,
              top: AppSpacing.lg,
            ),
            child: const _QuickActionsRow(),
          ),
        ),

        // ── Sticky "Timeline" + "+ Neu" header ──────────────
        SliverPersistentHeader(
          pinned: true,
          delegate: _StickyTimelineHeaderDelegate(
            onNewEntry: () => showNewEntrySheet(context),
          ),
        ),

        // ── Day sections ────────────────────────────────────
        SliverPadding(
          padding: const EdgeInsets.only(
            left: AppSpacing.lg,
            right: AppSpacing.lg,
            top: AppSpacing.lg,
            bottom: 120,
          ),
          sliver: SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, index) {
                if (index.isOdd) {
                  return const SizedBox(height: AppSpacing.xxl);
                }
                final si = index ~/ 2;
                return _DaySection(
                  section: _sections[si],
                  sectionIndex: si,
                  onToggle: (ti) => _toggleTask(si, ti),
                  onNavigate: (ti) {
                    final key = _sections[si].tasks[ti].routeKey;
                    if (key != null) navigateToRoute(context, key);
                  },
                );
              },
              childCount: _sections.length * 2 - 1,
            ),
          ),
        ),
      ],
    );
  }
}

// ── App header ───────────────────────────────────────────────────────────────

class _AppHeader extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;

    return Row(
      children: [
        Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            gradient: AppColors.primaryGradient,
            borderRadius: AppRadius.borderRadiusMd,
            boxShadow: [
              BoxShadow(
                color: AppColors.primary.withValues(alpha: 0.22),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: const Center(
            child: Icon(
              Icons.monitor_heart_outlined,
              size: 22,
              color: AppColors.white,
            ),
          ),
        ),
        const SizedBox(width: AppSpacing.md),
        Text('Operationsbegleiter', style: tt.titleLarge),
        const Spacer(),
        PressableScale(
          onTap: () {},
          scaleFactor: 0.90,
          child: GlassContainer(
            padding: const EdgeInsets.all(AppSpacing.sm + 2),
            borderRadius: AppRadius.borderRadiusMd,
            variant: GlassVariant.thin,
            elevation: GlassElevation.low,
            child: const Icon(
              Icons.notifications_none_rounded,
              size: 22,
              color: AppColors.grey700,
            ),
          ),
        ),
      ],
    );
  }
}

// ── Quick actions row ─────────────────────────────────────────────────────────

class _QuickActionsRow extends StatelessWidget {
  const _QuickActionsRow();

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      physics: adaptiveScrollPhysics,
      clipBehavior: Clip.none,
      child: Row(
        children: [
          for (var i = 0; i < _quickActions.length; i++) ...[
            _QuickActionChip(action: _quickActions[i]),
            if (i < _quickActions.length - 1)
              const SizedBox(width: AppSpacing.sm),
          ],
          const SizedBox(width: AppSpacing.lg),
        ],
      ),
    );
  }
}

class _QuickActionChip extends StatelessWidget {
  const _QuickActionChip({required this.action});

  final _QuickAction action;

  @override
  Widget build(BuildContext context) {
    return PressableScale(
      onTap: () => navigateToRoute(context, action.routeKey),
      scaleFactor: 0.94,
      child: GlassContainer(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.sm,
        ),
        borderRadius: AppRadius.borderRadiusPill,
        variant: GlassVariant.thin,
        elevation: GlassElevation.low,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(action.emoji, style: const TextStyle(fontSize: 14)),
            const SizedBox(width: AppSpacing.xs + 2),
            Text(
              action.label,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: AppColors.textPrimary,
                letterSpacing: 0.1,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Sticky header delegate ───────────────────────────────────────────────────

class _StickyTimelineHeaderDelegate extends SliverPersistentHeaderDelegate {
  _StickyTimelineHeaderDelegate({
    required this.onNewEntry,
  });

  final VoidCallback onNewEntry;

  static const double _contentHeight = 56.0;

  @override
  double get maxExtent => _contentHeight;

  @override
  double get minExtent => _contentHeight;

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    return _StickyTimelineHeader(
      isPinned: overlapsContent || shrinkOffset > 0,
      height: _contentHeight,
      onNewEntry: onNewEntry,
    );
  }

  @override
  bool shouldRebuild(covariant _StickyTimelineHeaderDelegate old) => false;
}

class _StickyTimelineHeader extends StatelessWidget {
  const _StickyTimelineHeader({
    required this.isPinned,
    required this.height,
    required this.onNewEntry,
  });

  final bool isPinned;
  final double height;
  final VoidCallback onNewEntry;

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;

    Widget content = Container(
      height: height,
      decoration: BoxDecoration(
        color: isPinned
            ? AppColors.background.withValues(alpha: 0.92)
            : Colors.transparent,
        border: Border(
          bottom: BorderSide(
            color: isPinned
                ? AppColors.grey300.withValues(alpha: 0.45)
                : Colors.transparent,
            width: 0.5,
          ),
        ),
      ),
      padding: EdgeInsets.only(
        left: AppSpacing.lg,
        right: AppSpacing.lg,
        top: AppSpacing.sm,
        bottom: AppSpacing.sm,
      ),
      child: Row(
        children: [
          Text('Timeline', style: tt.headlineLarge),
          const Spacer(),
          PressableScale(
            onTap: onNewEntry,
            scaleFactor: 0.93,
            child: GlassContainer(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.lg,
                vertical: AppSpacing.sm,
              ),
              borderRadius: AppRadius.borderRadiusPill,
              variant: GlassVariant.thin,
              elevation: GlassElevation.low,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.add_rounded,
                      size: 18, color: AppColors.primary),
                  const SizedBox(width: AppSpacing.xs),
                  Text(
                    'Neu',
                    style: tt.titleSmall
                        ?.copyWith(color: AppColors.primary),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );

    if (!isPinned) return content;

    return content;
  }
}

// ── Day section ──────────────────────────────────────────────────────────────

class _DaySection extends StatelessWidget {
  const _DaySection({
    required this.section,
    required this.sectionIndex,
    required this.onToggle,
    required this.onNavigate,
  });

  final TimelineSection section;
  final int sectionIndex;
  final ValueChanged<int> onToggle;
  final ValueChanged<int> onNavigate;

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;
    final tint = section.tint;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ── Day header with subtle phase wash ────────────────
        Container(
          padding: const EdgeInsets.only(
            left: AppSpacing.sm,
            right: AppSpacing.sm,
            top: AppSpacing.sm,
            bottom: AppSpacing.sm + 2,
          ),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
              colors: [
                tint.withValues(alpha: 0.04),
                tint.withValues(alpha: 0.0),
              ],
            ),
            borderRadius: const BorderRadius.vertical(
              top: Radius.circular(AppRadius.md),
            ),
          ),
          child: Row(
            children: [
              _OffsetBadge(
                label: section.offsetLabel,
                tint: tint,
                isHighlighted: section.isHighlighted,
              ),
              const SizedBox(width: AppSpacing.md),
              Text(section.dateLabel, style: tt.bodySmall),
              const Spacer(),
              Text(
                '${section.completedCount}/${section.totalCount} erledigt',
                style: tt.labelSmall?.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
              if (section.phaseBadge != null) ...[
                const SizedBox(width: AppSpacing.sm),
                _PhaseBadge(label: section.phaseBadge!, tint: tint),
              ],
            ],
          ),
        ),

        // ── Task card ────────────────────────────────────────
        _TaskCard(
          section: section,
          sectionIndex: sectionIndex,
          tintColor: section.isHighlighted ? tint : null,
          phaseTint: tint,
          onToggle: onToggle,
          onNavigate: onNavigate,
        ),
      ],
    );
  }
}

// ── Offset badge pill ────────────────────────────────────────────────────────

class _OffsetBadge extends StatelessWidget {
  const _OffsetBadge({
    required this.label,
    required this.tint,
    required this.isHighlighted,
  });

  final String label;
  final Color tint;
  final bool isHighlighted;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.xs + 1,
      ),
      decoration: BoxDecoration(
        color: tint.withValues(alpha: isHighlighted ? 0.10 : 0.07),
        borderRadius: AppRadius.borderRadiusPill,
        border: Border.all(
          color: tint.withValues(alpha: isHighlighted ? 0.18 : 0.08),
          width: 0.5,
        ),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w700,
          color: tint,
          letterSpacing: 0.2,
        ),
      ),
    );
  }
}

// ── OP-TAG / phase badge pill ────────────────────────────────────────────────

class _PhaseBadge extends StatefulWidget {
  const _PhaseBadge({
    required this.label,
    required this.tint,
  });

  final String label;
  final Color tint;

  @override
  State<_PhaseBadge> createState() => _PhaseBadgeState();
}

class _PhaseBadgeState extends State<_PhaseBadge>
    with SingleTickerProviderStateMixin {
  AnimationController? _controller;
  Animation<double>? _pulse;

  @override
  void initState() {
    super.initState();
    if (!_opTagMilestoneShown) {
      _opTagMilestoneShown = true;
      _controller = AnimationController(
        duration: const Duration(milliseconds: 1400),
        vsync: this,
      );
      _pulse = TweenSequence<double>([
        TweenSequenceItem(
          tween: Tween(begin: 0.0, end: 1.0)
              .chain(CurveTween(curve: Curves.easeOut)),
          weight: 1,
        ),
        TweenSequenceItem(
          tween: Tween(begin: 1.0, end: 0.0)
              .chain(CurveTween(curve: Curves.easeIn)),
          weight: 1,
        ),
        TweenSequenceItem(
          tween: Tween(begin: 0.0, end: 0.7)
              .chain(CurveTween(curve: Curves.easeOut)),
          weight: 1,
        ),
        TweenSequenceItem(
          tween: Tween(begin: 0.7, end: 0.0)
              .chain(CurveTween(curve: Curves.easeIn)),
          weight: 1,
        ),
      ]).animate(_controller!);

      WidgetsBinding.instance.addPostFrameCallback((_) {
        Haptic.medium();
        _controller?.forward();
      });
    }
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final tint = widget.tint;

    Widget badge = Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm + 2,
        vertical: AppSpacing.xxs + 1,
      ),
      decoration: BoxDecoration(
        color: tint.withValues(alpha: 0.08),
        borderRadius: AppRadius.borderRadiusPill,
        border: Border.all(color: tint.withValues(alpha: 0.18), width: 0.5),
        boxShadow: [
          BoxShadow(
            color: tint.withValues(alpha: 0.10),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Text(
        widget.label,
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w800,
          color: tint,
          letterSpacing: 0.5,
        ),
      ),
    );

    if (_pulse == null) return badge;

    return AnimatedBuilder(
      animation: _pulse!,
      builder: (context, child) {
        final p = _pulse!.value;
        return Transform.scale(
          scale: 1.0 + 0.06 * p,
          child: DecoratedBox(
            decoration: BoxDecoration(
              borderRadius: AppRadius.borderRadiusPill,
              boxShadow: [
                BoxShadow(
                  color: tint.withValues(alpha: 0.25 * p),
                  blurRadius: 12 * p,
                  spreadRadius: 2 * p,
                ),
              ],
            ),
            child: child,
          ),
        );
      },
      child: badge,
    );
  }
}

// ── Task card (grouped, iOS-like) ────────────────────────────────────────────

class _TaskCard extends StatelessWidget {
  const _TaskCard({
    required this.section,
    required this.sectionIndex,
    required this.onToggle,
    required this.onNavigate,
    required this.phaseTint,
    this.tintColor,
  });

  final TimelineSection section;
  final int sectionIndex;
  final ValueChanged<int> onToggle;
  final ValueChanged<int> onNavigate;
  final Color phaseTint;
  final Color? tintColor;

  @override
  Widget build(BuildContext context) {
    final isHighlighted = tintColor != null;

    return GlassContainer(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.xxs),
      borderRadius: AppRadius.borderRadiusLg,
      variant: isHighlighted ? GlassVariant.medium : GlassVariant.thin,
      elevation: isHighlighted ? GlassElevation.medium : GlassElevation.low,
      color: isHighlighted ? tintColor!.withValues(alpha: 0.03) : null,
      child: Column(
        children: [
          for (var i = 0; i < section.tasks.length; i++) ...[
            FadeSlideIn(
              delay: Duration(
                milliseconds: 80 + sectionIndex * 40 + i * 35,
              ),
              slideOffset: 6,
              duration: const Duration(milliseconds: 280),
              child: _TaskTile(
                task: section.tasks[i],
                accentColor: tintColor,
                onToggle: () => onToggle(i),
                onNavigate: () => onNavigate(i),
              ),
            ),
            if (i < section.tasks.length - 1) _separator(),
          ],
        ],
      ),
    );
  }

  Widget _separator() {
    final sepColor = tintColor ?? AppColors.grey300;
    return Padding(
      padding: const EdgeInsets.only(left: 72, right: AppSpacing.lg),
      child: Container(
        height: 0.33,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              sepColor.withValues(alpha: 0.0),
              sepColor.withValues(alpha: 0.14),
              sepColor.withValues(alpha: 0.0),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Task tile ────────────────────────────────────────────────────────────────

class _TaskTile extends StatelessWidget {
  const _TaskTile({
    required this.task,
    required this.onToggle,
    required this.onNavigate,
    this.accentColor,
  });

  final TimelineTask task;
  final VoidCallback onToggle;
  final VoidCallback onNavigate;
  final Color? accentColor;

  @override
  Widget build(BuildContext context) {
    final done = task.isDone;

    return PressableScale(
      onTap: onNavigate,
      scaleFactor: 0.988,
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.lg,
          vertical: AppSpacing.md,
        ),
        child: Row(
          children: [
            // ── Checkbox ─────────────────────────────────
            AnimatedCheckbox(
              value: done,
              onChanged: (_) => onToggle(),
              activeColor: accentColor ?? AppColors.success,
              size: 26,
            ),
            const SizedBox(width: AppSpacing.md),

            // ── Emoji icon ───────────────────────────────
            AnimatedContainer(
              duration: MotionDuration.medium,
              curve: MotionCurve.standard,
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                color: done
                    ? (accentColor ?? AppColors.primary)
                        .withValues(alpha: 0.03)
                    : (accentColor ?? AppColors.primary)
                        .withValues(alpha: 0.06),
                borderRadius: AppRadius.borderRadiusSm,
              ),
              child: Center(
                child: AnimatedOpacity(
                  duration: MotionDuration.medium,
                  opacity: done ? 0.5 : 1.0,
                  child: Text(
                    task.emoji,
                    style: const TextStyle(fontSize: 18),
                  ),
                ),
              ),
            ),
            const SizedBox(width: AppSpacing.md),

            // ── Title + subtitle ─────────────────────────
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  AnimatedDefaultTextStyle(
                    duration: MotionDuration.medium,
                    curve: MotionCurve.standard,
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: done ? FontWeight.w400 : FontWeight.w500,
                      color: done
                          ? AppColors.textSecondary.withValues(alpha: 0.55)
                          : AppColors.textPrimary,
                      decoration: done ? TextDecoration.lineThrough : null,
                      decorationColor:
                          AppColors.textSecondary.withValues(alpha: 0.30),
                      decorationThickness: 1.0,
                    ),
                    child: Text(task.title),
                  ),
                  if (task.subtitle != null) ...[
                    const SizedBox(height: 3),
                    AnimatedDefaultTextStyle(
                      duration: MotionDuration.medium,
                      curve: MotionCurve.standard,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w400,
                        color: done
                            ? AppColors.textSecondary.withValues(alpha: 0.40)
                            : AppColors.textSecondary,
                        height: 1.3,
                      ),
                      child: Text(
                        task.subtitle!,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(width: AppSpacing.sm),

            // ── Chevron ──────────────────────────────────
            AnimatedOpacity(
              duration: MotionDuration.medium,
              opacity: done ? 0.3 : 0.5,
              child: const Icon(
                Icons.chevron_right_rounded,
                size: 20,
                color: AppColors.grey400,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Empty state fallback ──────────────────────────────────────────────────────

class _EmptyTimelineState extends StatelessWidget {
  const _EmptyTimelineState({
    required this.onLoadDemoData,
  });

  final VoidCallback onLoadDemoData;

  @override
  Widget build(BuildContext context) {
    final topPadding = MediaQuery.of(context).padding.top;
    final tt = Theme.of(context).textTheme;

    return Padding(
      padding: EdgeInsets.only(
        left: AppSpacing.lg,
        right: AppSpacing.lg,
        top: topPadding + AppSpacing.huge,
      ),
      child: Column(
        children: [
          Container(
            width: 72,
            height: 72,
            decoration: BoxDecoration(
              gradient: AppColors.primaryGradient,
              borderRadius: AppRadius.borderRadiusLg,
              boxShadow: [
                BoxShadow(
                  color: AppColors.primary.withValues(alpha: 0.22),
                  blurRadius: 16,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: const Icon(
              Icons.timeline_rounded,
              size: 32,
              color: AppColors.white,
            ),
          ),
          const SizedBox(height: AppSpacing.xxl),
          Text(
            'Deine Timeline ist leer',
            style: tt.headlineMedium,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppSpacing.md),
          Text(
            'Sobald eine Operation angelegt wird,\nerscheinen hier deine Aufgaben.',
            style: tt.bodyMedium?.copyWith(
              color: AppColors.textSecondary,
              height: 1.5,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppSpacing.xxl),
          GlassButton(
            onPressed: onLoadDemoData,
            label: 'Demo-Daten laden',
            icon: Icons.auto_awesome_rounded,
          ),
        ],
      ),
    );
  }
}
