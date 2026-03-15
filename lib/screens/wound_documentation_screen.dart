import 'package:flutter/material.dart';

import '../features/wound/presentation/wound_hygiene_card.dart';
import '../ui/ui.dart';

// ── Data models ──────────────────────────────────────────────────────────────

class _WoundEntry {
  _WoundEntry({
    required this.date,
    required this.dayOffset,
    required this.description,
    required this.checklist,
  });

  final String date;
  final int dayOffset;
  final String description;
  final Map<String, bool> checklist;

  int get flagCount => checklist.values.where((v) => v).length;
  bool get hasFlags => flagCount > 0;
}

// ─────────────────────────────────────────────────────────────────────────────

class WoundDocumentationScreen extends StatefulWidget {
  const WoundDocumentationScreen({super.key});

  @override
  State<WoundDocumentationScreen> createState() =>
      _WoundDocumentationScreenState();
}

class _WoundDocumentationScreenState extends State<WoundDocumentationScreen> {
  int _selectedIndex = 0;

  final _entries = <_WoundEntry>[
    _WoundEntry(
      date: '26. April 2026',
      dayOffset: 2,
      description:
          'Wunde sieht sauber aus. Leichte Rötung um die Naht. '
          'Kein Sekret sichtbar. Verband gewechselt.',
      checklist: {
        'Rötung': true,
        'Schwellung': false,
        'Sekret': false,
        'Geruch': false,
      },
    ),
    _WoundEntry(
      date: '25. April 2026',
      dayOffset: 1,
      description:
          'Erster Verbandwechsel. Wundränder adaptiert. '
          'Minimale Schwellung im OP‑Gebiet.',
      checklist: {
        'Rötung': true,
        'Schwellung': true,
        'Sekret': false,
        'Geruch': false,
      },
    ),
    _WoundEntry(
      date: '24. April 2026',
      dayOffset: 0,
      description: 'OP‑Tag. Wunde frisch versorgt, steriler Verband angelegt.',
      checklist: {
        'Rötung': false,
        'Schwellung': false,
        'Sekret': false,
        'Geruch': false,
      },
    ),
  ];

  _WoundEntry get _current => _entries[_selectedIndex];

  @override
  Widget build(BuildContext context) {
    final topPadding = MediaQuery.of(context).padding.top;

    return Scaffold(
      backgroundColor: AppColors.grey100,
      body: SingleChildScrollView(
        padding: EdgeInsets.only(
          left: AppSpacing.xl,
          right: AppSpacing.xl,
          top: topPadding + AppSpacing.sm,
          bottom: AppSpacing.huge,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildAppBar(context),
            const SizedBox(height: AppSpacing.xxl),
            _buildPhotoGallery(context),
            const SizedBox(height: AppSpacing.lg),
            _buildDaySelector(context),
            const SizedBox(height: AppSpacing.xxl),
            _buildDescriptionCard(context),
            const SizedBox(height: AppSpacing.lg),
            _buildInfectionChecklist(context),
            const SizedBox(height: AppSpacing.lg),
            const WoundHygieneCard(),
            const SizedBox(height: AppSpacing.xxl),
            _sectionTitle(context, 'Verlauf'),
            const SizedBox(height: AppSpacing.md),
            _buildProgressTimeline(context),
            const SizedBox(height: AppSpacing.xxl),
            _buildUploadButton(context),
          ],
        ),
      ),
    );
  }

  // ── App bar ──────────────────────────────────────────────────────────────

  Widget _buildAppBar(BuildContext context) {
    return Row(
      children: [
        GestureDetector(
          onTap: () => Navigator.of(context).pop(),
          child: GlassContainer(
            padding: const EdgeInsets.all(AppSpacing.sm),
            borderRadius: AppRadius.borderRadiusMd,
            child: const Icon(
              Icons.arrow_back_ios_new_rounded,
              size: 18,
              color: AppColors.primary,
            ),
          ),
        ),
        const SizedBox(width: AppSpacing.md),
        Expanded(
          child: Text(
            'Wunddokumentation',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
        ),
        GlassContainer(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.md,
            vertical: AppSpacing.sm,
          ),
          borderRadius: AppRadius.borderRadiusPill,
          child: Text(
            '${_entries.length} Einträge',
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: AppColors.primary,
            ),
          ),
        ),
      ],
    );
  }

  // ── Photo gallery with zoom ────────────────────────────────────────────

  Widget _buildPhotoGallery(BuildContext context) {
    return GlassContainer(
      padding: EdgeInsets.zero,
      borderRadius: AppRadius.borderRadiusXl,
      child: Column(
        children: [
          // ── Main photo area ──────────────────────────────────
          GestureDetector(
            onTap: () => _openZoom(context),
            child: Container(
              height: 240,
              width: double.infinity,
              decoration: const BoxDecoration(
                color: AppColors.grey100,
                borderRadius: BorderRadius.vertical(
                  top: Radius.circular(AppRadius.xl),
                ),
              ),
              child: Stack(
                children: [
                  Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 64,
                          height: 64,
                          decoration: BoxDecoration(
                            color: AppColors.primary.withValues(alpha: 0.08),
                            borderRadius: AppRadius.borderRadiusXxl,
                          ),
                          child: const Icon(
                            Icons.camera_alt_rounded,
                            size: 32,
                            color: AppColors.primary,
                          ),
                        ),
                        const SizedBox(height: AppSpacing.md),
                        Text(
                          'Foto vom ${_current.date}',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        const SizedBox(height: AppSpacing.xs),
                        Text(
                          'Tippen zum Vergrößern',
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ],
                    ),
                  ),

                  // ── Day badge ────────────────────────────────
                  Positioned(
                    top: AppSpacing.lg,
                    left: AppSpacing.lg,
                    child: _DayBadge(dayOffset: _current.dayOffset),
                  ),

                  // ── Zoom icon ────────────────────────────────
                  Positioned(
                    top: AppSpacing.lg,
                    right: AppSpacing.lg,
                    child: Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        color: AppColors.black.withValues(alpha: 0.35),
                        borderRadius: AppRadius.borderRadiusSm,
                      ),
                      child: const Icon(
                        Icons.zoom_in_rounded,
                        size: 20,
                        color: AppColors.white,
                      ),
                    ),
                  ),

                  // ── Infection flag ───────────────────────────
                  if (_current.hasFlags)
                    Positioned(
                      bottom: AppSpacing.lg,
                      right: AppSpacing.lg,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppSpacing.md,
                          vertical: AppSpacing.xs,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.error.withValues(alpha: 0.90),
                          borderRadius: AppRadius.borderRadiusPill,
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons.warning_amber_rounded,
                              size: 14,
                              color: AppColors.white,
                            ),
                            const SizedBox(width: AppSpacing.xs),
                            Text(
                              '${_current.flagCount} ${_current.flagCount == 1 ? 'Auffälligkeit' : 'Auffälligkeiten'}',
                              style: const TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                                color: AppColors.white,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),

          // ── Thumbnail strip ─────────────────────────────────
          Padding(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: SizedBox(
              height: 60,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: _entries.length,
                separatorBuilder: (_, index) =>
                    const SizedBox(width: AppSpacing.sm),
                itemBuilder: (context, i) {
                  final selected = i == _selectedIndex;
                  final entry = _entries[i];
                  return GestureDetector(
                    onTap: () => setState(() => _selectedIndex = i),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      width: 60,
                      decoration: BoxDecoration(
                        color: AppColors.grey100,
                        borderRadius: AppRadius.borderRadiusMd,
                        border: Border.all(
                          color: selected
                              ? AppColors.primary
                              : AppColors.grey200,
                          width: selected ? 2 : 1,
                        ),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.camera_alt_outlined,
                            size: 18,
                            color: selected
                                ? AppColors.primary
                                : AppColors.grey400,
                          ),
                          const SizedBox(height: AppSpacing.xxs),
                          Text(
                            'Tag ${entry.dayOffset >= 0 ? '+' : ''}${entry.dayOffset}',
                            style: TextStyle(
                              fontSize: 9,
                              fontWeight: FontWeight.w600,
                              color: selected
                                  ? AppColors.primary
                                  : AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── Day selector ───────────────────────────────────────────────────────

  Widget _buildDaySelector(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        IconButton(
          onPressed: _selectedIndex < _entries.length - 1
              ? () => setState(() => _selectedIndex++)
              : null,
          icon: const Icon(Icons.chevron_left_rounded),
          color: AppColors.primary,
          disabledColor: AppColors.grey300,
        ),
        GlassContainer(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.xl,
            vertical: AppSpacing.sm,
          ),
          borderRadius: AppRadius.borderRadiusPill,
          child: Text(
            _current.date,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
        ),
        IconButton(
          onPressed: _selectedIndex > 0
              ? () => setState(() => _selectedIndex--)
              : null,
          icon: const Icon(Icons.chevron_right_rounded),
          color: AppColors.primary,
          disabledColor: AppColors.grey300,
        ),
      ],
    );
  }

  // ── Description card ───────────────────────────────────────────────────

  Widget _buildDescriptionCard(BuildContext context) {
    return GlassContainer(
      padding: const EdgeInsets.all(AppSpacing.xl),
      borderRadius: AppRadius.borderRadiusXl,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.10),
                  borderRadius: AppRadius.borderRadiusMd,
                ),
                child: const Icon(
                  Icons.edit_note_rounded,
                  size: 20,
                  color: AppColors.primary,
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Text(
                'Beschreibung',
                style: Theme.of(context).textTheme.titleMedium,
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.lg),
          Text(
            _current.description,
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(height: 1.55),
          ),
        ],
      ),
    );
  }

  // ── Infection checklist ────────────────────────────────────────────────

  Widget _buildInfectionChecklist(BuildContext context) {
    final items = _current.checklist.entries.toList();

    return GlassContainer(
      padding: const EdgeInsets.all(AppSpacing.xl),
      borderRadius: AppRadius.borderRadiusXl,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: AppColors.error.withValues(alpha: 0.10),
                  borderRadius: AppRadius.borderRadiusMd,
                ),
                child: const Icon(
                  Icons.medical_information_outlined,
                  size: 20,
                  color: AppColors.error,
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Text(
                  'Infektions‑Checkliste',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ),
              if (_current.hasFlags)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.sm,
                    vertical: AppSpacing.xxs,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.error.withValues(alpha: 0.10),
                    borderRadius: AppRadius.borderRadiusPill,
                  ),
                  child: Text(
                    '${_current.flagCount} aktiv',
                    style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: AppColors.error,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: AppSpacing.lg),
          for (var i = 0; i < items.length; i++) ...[
            _InfectionItem(
              label: items[i].key,
              active: items[i].value,
              icon: _iconFor(items[i].key),
            ),
            if (i < items.length - 1)
              Divider(
                height: 1,
                thickness: 0.5,
                color: AppColors.grey200.withValues(alpha: 0.5),
              ),
          ],
        ],
      ),
    );
  }

  static IconData _iconFor(String label) => switch (label) {
    'Rötung' => Icons.circle,
    'Schwellung' => Icons.swap_vert_circle_outlined,
    'Sekret' => Icons.water_drop_outlined,
    'Geruch' => Icons.air_rounded,
    _ => Icons.help_outline,
  };

  // ── Progress timeline ──────────────────────────────────────────────────

  Widget _buildProgressTimeline(BuildContext context) {
    return GlassContainer(
      padding: const EdgeInsets.all(AppSpacing.xl),
      borderRadius: AppRadius.borderRadiusXl,
      child: Column(
        children: [
          for (var i = 0; i < _entries.length; i++) ...[
            _TimelineRow(
              entry: _entries[i],
              isLast: i == _entries.length - 1,
              isSelected: i == _selectedIndex,
              onTap: () => setState(() => _selectedIndex = i),
            ),
          ],
        ],
      ),
    );
  }

  // ── Upload button ──────────────────────────────────────────────────────

  Widget _buildUploadButton(BuildContext context) {
    return GlassButton(
      onPressed: () {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Kamera wird geöffnet…')),
        );
      },
      label: 'Neues Foto aufnehmen',
      icon: Icons.camera_alt_rounded,
      expand: true,
    );
  }

  // ── Zoom overlay ───────────────────────────────────────────────────────

  void _openZoom(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        fullscreenDialog: true,
        builder: (_) => _ZoomScreen(entry: _current),
      ),
    );
  }

  Widget _sectionTitle(BuildContext context, String title) {
    return Padding(
      padding: const EdgeInsets.only(left: AppSpacing.xs),
      child: Text(title, style: Theme.of(context).textTheme.titleLarge),
    );
  }
}

// ── Day badge ────────────────────────────────────────────────────────────────

class _DayBadge extends StatelessWidget {
  const _DayBadge({required this.dayOffset});

  final int dayOffset;

  @override
  Widget build(BuildContext context) {
    final String text;
    final Color bg;
    final Color fg;

    if (dayOffset < 0) {
      text = 'Tag $dayOffset';
      bg = AppColors.primary;
      fg = AppColors.white;
    } else if (dayOffset == 0) {
      text = 'OP‑Tag';
      bg = AppColors.warning;
      fg = AppColors.white;
    } else {
      text = 'Tag +$dayOffset';
      bg = AppColors.success;
      fg = AppColors.white;
    }

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.xs,
      ),
      decoration: BoxDecoration(
        color: bg.withValues(alpha: 0.90),
        borderRadius: AppRadius.borderRadiusPill,
      ),
      child: Text(
        text,
        style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: fg),
      ),
    );
  }
}

// ── Infection checklist item ─────────────────────────────────────────────────

class _InfectionItem extends StatelessWidget {
  const _InfectionItem({
    required this.label,
    required this.active,
    required this.icon,
  });

  final String label;
  final bool active;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
      child: Row(
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: active
                  ? AppColors.error.withValues(alpha: 0.12)
                  : AppColors.grey100,
              borderRadius: AppRadius.borderRadiusSm,
            ),
            child: Icon(
              icon,
              size: 16,
              color: active ? AppColors.error : AppColors.grey400,
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Text(
              label,
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w500,
                color: active ? AppColors.textPrimary : AppColors.textSecondary,
              ),
            ),
          ),
          AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            width: 24,
            height: 24,
            decoration: BoxDecoration(
              color: active
                  ? AppColors.error.withValues(alpha: 0.14)
                  : Colors.transparent,
              borderRadius: AppRadius.borderRadiusXs,
              border: Border.all(
                color: active ? AppColors.error : AppColors.grey300,
                width: active ? 1.5 : 1,
              ),
            ),
            child: active
                ? const Icon(
                    Icons.check_rounded,
                    size: 16,
                    color: AppColors.error,
                  )
                : null,
          ),
        ],
      ),
    );
  }
}

// ── Timeline row ─────────────────────────────────────────────────────────────

class _TimelineRow extends StatelessWidget {
  const _TimelineRow({
    required this.entry,
    required this.isLast,
    required this.isSelected,
    required this.onTap,
  });

  final _WoundEntry entry;
  final bool isLast;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final hasFlags = entry.hasFlags;

    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Rail ─────────────────────────────────────────
            SizedBox(
              width: 32,
              child: Column(
                children: [
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    width: 28,
                    height: 28,
                    decoration: BoxDecoration(
                      color: isSelected
                          ? AppColors.primary.withValues(alpha: 0.14)
                          : hasFlags
                          ? AppColors.error.withValues(alpha: 0.10)
                          : AppColors.success.withValues(alpha: 0.10),
                      shape: BoxShape.circle,
                      border: isSelected
                          ? Border.all(color: AppColors.primary, width: 2)
                          : null,
                    ),
                    child: Icon(
                      hasFlags
                          ? Icons.warning_amber_rounded
                          : Icons.check_rounded,
                      size: 14,
                      color: isSelected
                          ? AppColors.primary
                          : hasFlags
                          ? AppColors.error
                          : AppColors.success,
                    ),
                  ),
                  if (!isLast)
                    Expanded(
                      child: Container(
                        width: 2,
                        margin: const EdgeInsets.symmetric(
                          vertical: AppSpacing.xxs,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.grey200,
                          borderRadius: BorderRadius.circular(1),
                        ),
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(width: AppSpacing.md),

            // ── Content ──────────────────────────────────────
            Expanded(
              child: Padding(
                padding: EdgeInsets.only(bottom: isLast ? 0 : AppSpacing.xl),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            entry.date,
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: isSelected
                                  ? FontWeight.w600
                                  : FontWeight.w500,
                              color: AppColors.textPrimary,
                            ),
                          ),
                        ),
                        _DayBadge(dayOffset: entry.dayOffset),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    Text(
                      entry.description,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 13,
                        color: AppColors.textSecondary,
                        height: 1.4,
                      ),
                    ),
                    if (hasFlags) ...[
                      const SizedBox(height: AppSpacing.sm),
                      Wrap(
                        spacing: AppSpacing.xs,
                        children: entry.checklist.entries
                            .where((e) => e.value)
                            .map(
                              (e) => Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: AppSpacing.sm,
                                  vertical: AppSpacing.xxs,
                                ),
                                decoration: BoxDecoration(
                                  color: AppColors.error.withValues(
                                    alpha: 0.08,
                                  ),
                                  borderRadius: AppRadius.borderRadiusPill,
                                ),
                                child: Text(
                                  e.key,
                                  style: const TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.error,
                                  ),
                                ),
                              ),
                            )
                            .toList(),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Zoom screen ──────────────────────────────────────────────────────────────

class _ZoomScreen extends StatelessWidget {
  const _ZoomScreen({required this.entry});

  final _WoundEntry entry;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.black,
      body: Stack(
        children: [
          // ── Zoomable area ────────────────────────────────────
          Center(
            child: InteractiveViewer(
              minScale: 1.0,
              maxScale: 4.0,
              child: Container(
                width: double.infinity,
                height: 400,
                color: AppColors.grey900,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.camera_alt_rounded,
                      size: 56,
                      color: AppColors.grey600,
                    ),
                    const SizedBox(height: AppSpacing.lg),
                    Text(
                      'Foto vom ${entry.date}',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        color: AppColors.grey400,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    const Text(
                      'Zum Zoomen pinchen',
                      style: TextStyle(fontSize: 13, color: AppColors.grey600),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // ── Close button ─────────────────────────────────────
          Positioned(
            top: MediaQuery.of(context).padding.top + AppSpacing.md,
            right: AppSpacing.xl,
            child: GestureDetector(
              onTap: () => Navigator.of(context).pop(),
              child: Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: AppColors.white.withValues(alpha: 0.15),
                  borderRadius: AppRadius.borderRadiusLg,
                ),
                child: const Icon(
                  Icons.close_rounded,
                  size: 22,
                  color: AppColors.white,
                ),
              ),
            ),
          ),

          // ── Day badge ────────────────────────────────────────
          Positioned(
            top: MediaQuery.of(context).padding.top + AppSpacing.md,
            left: AppSpacing.xl,
            child: _DayBadge(dayOffset: entry.dayOffset),
          ),

          // ── Bottom info ──────────────────────────────────────
          Positioned(
            bottom: MediaQuery.of(context).padding.bottom + AppSpacing.xxl,
            left: AppSpacing.xl,
            right: AppSpacing.xl,
            child: Container(
              padding: const EdgeInsets.all(AppSpacing.lg),
              decoration: BoxDecoration(
                color: AppColors.white.withValues(alpha: 0.10),
                borderRadius: AppRadius.borderRadiusLg,
                border: Border.all(
                  color: AppColors.white.withValues(alpha: 0.12),
                  width: 0.5,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    entry.date,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: AppColors.white,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    entry.description,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 13,
                      color: AppColors.white.withValues(alpha: 0.7),
                      height: 1.4,
                    ),
                  ),
                  if (entry.hasFlags) ...[
                    const SizedBox(height: AppSpacing.sm),
                    Wrap(
                      spacing: AppSpacing.xs,
                      children: entry.checklist.entries
                          .where((e) => e.value)
                          .map(
                            (e) => Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: AppSpacing.sm,
                                vertical: AppSpacing.xxs,
                              ),
                              decoration: BoxDecoration(
                                color: AppColors.error.withValues(alpha: 0.80),
                                borderRadius: AppRadius.borderRadiusPill,
                              ),
                              child: Text(
                                e.key,
                                style: const TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.white,
                                ),
                              ),
                            ),
                          )
                          .toList(),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
