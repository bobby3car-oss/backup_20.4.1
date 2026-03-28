import 'dart:io';

import 'package:flutter/material.dart';

import '../../../ui/ui.dart';
import '../../../ui/theme/app_icons.dart';
import '../data/wound_repository_local.dart';
import '../domain/wound_entry.dart';
import '../../../l10n/app_localizations.dart';

/// Visual before/after wound comparison screen.
///
/// Modes:
///  • **Slider** – swipe through all wound photos chronologically.
///  • **Vergleich** – pick two photos, view them side-by-side or in an
///    interactive overlay slider (drag a vertical divider across stacked
///    before/after images).
class WoundComparisonScreen extends StatefulWidget {
  const WoundComparisonScreen({super.key});

  @override
  State<WoundComparisonScreen> createState() => _WoundComparisonScreenState();
}

class _WoundComparisonScreenState extends State<WoundComparisonScreen> {
  List<WoundEntry> _photoEntries = const [];
  bool _loading = true;

  // Slider mode
  late final PageController _pageController;
  int _currentPage = 0;

  // Compare mode
  bool _compareMode = false;
  int? _pickA;
  int? _pickB;
  bool _overlayActive = false;
  double _sliderX = 0.5; // 0..1

  @override
  void initState() {
    super.initState();
    _pageController = PageController(viewportFraction: 0.85);
    _loadEntries();
  }

  Future<void> _loadEntries() async {
    final entries = await WoundRepositoryLocal.instance.watchAll().first;
    if (!mounted) return;
    final withPhotos = <WoundEntry>[];
    for (final e in entries) {
      final p = e.photoPath;
      if (p == null || p.trim().isEmpty) continue;
      if (await File(p.trim()).exists()) withPhotos.add(e);
    }
    withPhotos.sort((a, b) => a.createdAt.compareTo(b.createdAt));
    if (!mounted) return;
    setState(() {
      _photoEntries = withPhotos;
      _loading = false;
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  // ── Helpers ────────────────────────────────────────────────────────────

  void _toggleCompareMode() {
    setState(() {
      _compareMode = !_compareMode;
      _pickA = null;
      _pickB = null;
      _overlayActive = false;
    });
  }

  void _onThumbnailTap(int index) {
    if (!_compareMode) {
      _pageController.animateToPage(
        index,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
      return;
    }
    setState(() {
      if (_pickA == null) {
        _pickA = index;
      } else if (_pickB == null) {
        if (index == _pickA) return;
        _pickB = index;
      } else {
        // Reset selection
        _pickA = index;
        _pickB = null;
        _overlayActive = false;
      }
    });
  }

  static String _formatDate(DateTime dt) {
    final dd = dt.day.toString().padLeft(2, '0');
    final mm = dt.month.toString().padLeft(2, '0');
    final yyyy = dt.year.toString();
    return '$dd.$mm.$yyyy';
  }

  // ── Build ──────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    return GlassPage(
      title: l.woundCompareTitle,
      titleIcon: AppIcons.wound,
      titleColor: AppColors.accent,
      trailing: _photoEntries.length >= 2
          ? PressableScale(
              onTap: _toggleCompareMode,
              child: GlassContainer(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.md,
                  vertical: AppSpacing.sm,
                ),
                borderRadius: AppRadius.borderRadiusPill,
                child: Text(
                  _compareMode ? l.woundCompareSlider : l.woundCompareCompare,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: AppColors.accent,
                  ),
                ),
              ),
            )
          : null,
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _photoEntries.isEmpty
              ? _buildEmpty(context)
              : _compareMode
                  ? _buildCompareMode(context)
                  : _buildSliderMode(context),
    );
  }

  // ── Empty state ────────────────────────────────────────────────────────

  Widget _buildEmpty(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xxxl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.photo_library_outlined,
              size: 56,
              color: AppColors.grey400,
            ),
            const SizedBox(height: AppSpacing.lg),
            Text(
              l.emptyNoPhotos,
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              l.emptyWoundCompareHint,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppColors.textSecondary,
                    height: 1.5,
                  ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Slider mode ────────────────────────────────────────────────────────

  Widget _buildSliderMode(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    return Column(
      children: [
        const SizedBox(height: AppSpacing.lg),
        Expanded(
          child: PageView.builder(
            controller: _pageController,
            itemCount: _photoEntries.length,
            onPageChanged: (i) => setState(() => _currentPage = i),
            itemBuilder: (context, index) {
              final entry = _photoEntries[index];
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm),
                child: Column(
                  children: [
                    Expanded(
                      child: ClipRRect(
                        borderRadius:
                            BorderRadius.circular(AppRadius.xl),
                        child: Image.file(
                          File(entry.photoPath!.trim()),
                          fit: BoxFit.cover,
                          width: double.infinity,
                        ),
                      ),
                    ),
                    const SizedBox(height: AppSpacing.md),
                    Text(
                      _formatDate(entry.createdAt),
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    if (entry.bodyLocation != null &&
                        entry.bodyLocation!.trim().isNotEmpty)
                      Text(
                        entry.bodyLocation!,
                        style: const TextStyle(
                          fontSize: 12,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    Text(
                      l.schmerzScore(entry.pain),
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: _painColor(entry.pain),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
        const SizedBox(height: AppSpacing.md),
        // Page indicator dots
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(
            _photoEntries.length,
            (i) => AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              margin: const EdgeInsets.symmetric(horizontal: 3),
              width: i == _currentPage ? 20 : 8,
              height: 8,
              decoration: BoxDecoration(
                color: i == _currentPage
                    ? AppColors.accent
                    : AppColors.grey300,
                borderRadius: BorderRadius.circular(4),
              ),
            ),
          ),
        ),
        const SizedBox(height: AppSpacing.lg),
        // Thumbnail strip
        _buildThumbnailStrip(context),
        const SizedBox(height: AppSpacing.xl),
      ],
    );
  }

  // ── Compare mode ───────────────────────────────────────────────────────

  Widget _buildCompareMode(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final hasBoth = _pickA != null && _pickB != null;

    return Column(
      children: [
        const SizedBox(height: AppSpacing.md),
        // Instruction / toggle overlay
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  hasBoth
                      ? l.waehleEinenModusZumVergleichen
                      : l.woundComparePick2,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: AppColors.textSecondary,
                  ),
                ),
              ),
              if (hasBoth)
                PressableScale(
                  onTap: () =>
                      setState(() => _overlayActive = !_overlayActive),
                  child: GlassContainer(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.md,
                      vertical: AppSpacing.sm,
                    ),
                    borderRadius: AppRadius.borderRadiusPill,
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          _overlayActive
                              ? Icons.view_column_rounded
                              : Icons.compare_rounded,
                          size: 16,
                          color: AppColors.accent,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          _overlayActive ? l.woundModeSplit : l.woundModeOverlay,
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: AppColors.accent,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.md),
        // Comparison area
        Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
            child: hasBoth
                ? _overlayActive
                    ? _buildOverlayView(context)
                    : _buildSplitView(context)
                : _buildSelectionHint(context),
          ),
        ),
        const SizedBox(height: AppSpacing.md),
        // Thumbnail strip for picking
        _buildThumbnailStrip(context),
        const SizedBox(height: AppSpacing.xl),
      ],
    );
  }

  Widget _buildSelectionHint(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final countSelected = (_pickA != null ? 1 : 0) + (_pickB != null ? 1 : 0);
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.touch_app_rounded, size: 48, color: AppColors.grey400),
          const SizedBox(height: AppSpacing.md),
          Text(
            l.woundComparePhotosSelected(countSelected),
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            l.woundCompareTapInstruction,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 14,
              color: AppColors.textSecondary,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  // ── Split view ─────────────────────────────────────────────────────────

  Widget _buildSplitView(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final entryA = _photoEntries[_pickA!];
    final entryB = _photoEntries[_pickB!];

    return Column(
      children: [
        Expanded(
          child: Row(
            children: [
              Expanded(child: _ComparePanel(entry: entryA, label: l.before)),
              const SizedBox(width: AppSpacing.sm),
              Expanded(child: _ComparePanel(entry: entryB, label: l.after)),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.md),
        _buildScoreComparison(context, entryA, entryB),
      ],
    );
  }

  // ── Overlay slider ─────────────────────────────────────────────────────

  Widget _buildOverlayView(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final entryA = _photoEntries[_pickA!];
    final entryB = _photoEntries[_pickB!];

    return Column(
      children: [
        Expanded(
          child: LayoutBuilder(
            builder: (context, constraints) {
              final width = constraints.maxWidth;
              final height = constraints.maxHeight;

              return GestureDetector(
                onHorizontalDragUpdate: (details) {
                  setState(() {
                    _sliderX =
                        (details.localPosition.dx / width).clamp(0.0, 1.0);
                  });
                },
                onTapDown: (details) {
                  setState(() {
                    _sliderX =
                        (details.localPosition.dx / width).clamp(0.0, 1.0);
                  });
                },
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(AppRadius.xl),
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      // Background: "Nachher" photo (B)
                      Image.file(
                        File(entryB.photoPath!.trim()),
                        fit: BoxFit.cover,
                      ),
                      // Foreground: "Vorher" photo (A), clipped by slider
                      ClipRect(
                        clipper: _SliderClipper(_sliderX),
                        child: Image.file(
                          File(entryA.photoPath!.trim()),
                          fit: BoxFit.cover,
                        ),
                      ),
                      // Divider line
                      Positioned(
                        left: width * _sliderX - 1.5,
                        top: 0,
                        bottom: 0,
                        child: Container(
                          width: 3,
                          color: Colors.white,
                        ),
                      ),
                      // Drag handle
                      Positioned(
                        left: width * _sliderX - 18,
                        top: height / 2 - 18,
                        child: Container(
                          width: 36,
                          height: 36,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.25),
                                blurRadius: 8,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: const Icon(
                            Icons.drag_handle_rounded,
                            size: 20,
                            color: AppColors.textPrimary,
                          ),
                        ),
                      ),
                      // Labels
                      Positioned(
                        left: 12,
                        bottom: 12,
                        child: _OverlayLabel(text: l.before),
                      ),
                      Positioned(
                        right: 12,
                        bottom: 12,
                        child: _OverlayLabel(text: l.after),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
        const SizedBox(height: AppSpacing.md),
        // Date labels
        Row(
          children: [
            Text(
              _formatDate(entryA.createdAt),
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: AppColors.textSecondary,
              ),
            ),
            const Spacer(),
            Text(
              _formatDate(entryB.createdAt),
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.md),
        _buildScoreComparison(context, entryA, entryB),
      ],
    );
  }

  // ── Score comparison ───────────────────────────────────────────────────

  Widget _buildScoreComparison(
      BuildContext context, WoundEntry a, WoundEntry b) {
    final l = AppLocalizations.of(context)!;
    final diff = b.pain - a.pain;
    final diffLabel =
        diff == 0 ? l.unveraendert : diff > 0 ? '+$diff' : '$diff';
    final diffColor = diff == 0
        ? AppColors.textSecondary
        : diff < 0
            ? AppColors.success
            : AppColors.error;

    return GlassContainer(
      padding: const EdgeInsets.all(AppSpacing.lg),
      borderRadius: AppRadius.borderRadiusLg,
      child: Row(
        children: [
          Expanded(
            child: Column(
              children: [
                Text(
                  l.before,
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                  ),
                ),
                Text(
                  '${a.pain}/10',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: _painColor(a.pain),
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.md,
              vertical: AppSpacing.xs,
            ),
            decoration: BoxDecoration(
              color: diffColor.withValues(alpha: 0.10),
              borderRadius: AppRadius.borderRadiusPill,
            ),
            child: Text(
              diffLabel,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: diffColor,
              ),
            ),
          ),
          Expanded(
            child: Column(
              children: [
                Text(
                  l.after,
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                  ),
                ),
                Text(
                  '${b.pain}/10',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: _painColor(b.pain),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ── Thumbnail strip ────────────────────────────────────────────────────

  Widget _buildThumbnailStrip(BuildContext context) {
    return SizedBox(
      height: 76,
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
        scrollDirection: Axis.horizontal,
        itemCount: _photoEntries.length,
        separatorBuilder: (_, _) => const SizedBox(width: AppSpacing.sm),
        itemBuilder: (context, i) {
          final entry = _photoEntries[i];
          final isSelectedInSlider = !_compareMode && i == _currentPage;
          final isPickA = _compareMode && _pickA == i;
          final isPickB = _compareMode && _pickB == i;
          final isSelected = isSelectedInSlider || isPickA || isPickB;

          Color borderColor = AppColors.grey200;
          if (isPickA) borderColor = AppColors.primary;
          if (isPickB) borderColor = AppColors.accent;
          if (isSelectedInSlider) borderColor = AppColors.primary;

          return GestureDetector(
            onTap: () => _onThumbnailTap(i),
            child: Column(
              children: [
                AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  width: 52,
                  height: 52,
                  decoration: BoxDecoration(
                    borderRadius: AppRadius.borderRadiusMd,
                    border: Border.all(
                      color: borderColor,
                      width: isSelected ? 2.5 : 1,
                    ),
                  ),
                  child: Stack(
                    children: [
                      Positioned.fill(
                        child: ClipRRect(
                          borderRadius:
                              BorderRadius.circular(AppRadius.md - 2),
                          child: Image.file(
                            File(entry.photoPath!.trim()),
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                      if (isPickA || isPickB)
                        Positioned(
                          top: 2,
                          right: 2,
                          child: Container(
                            width: 18,
                            height: 18,
                            decoration: BoxDecoration(
                              color: isPickA
                                  ? AppColors.primary
                                  : AppColors.accent,
                              shape: BoxShape.circle,
                            ),
                            alignment: Alignment.center,
                            child: Text(
                              isPickA ? 'A' : 'B',
                              style: const TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w700,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${entry.createdAt.day}.${entry.createdAt.month}.',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                    color: isSelected
                        ? AppColors.textPrimary
                        : AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  static Color _painColor(int level) {
    if (level <= 3) return AppColors.success;
    if (level <= 6) return AppColors.warning;
    return AppColors.error;
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Private helper widgets
// ─────────────────────────────────────────────────────────────────────────────

class _SliderClipper extends CustomClipper<Rect> {
  _SliderClipper(this.fraction);

  final double fraction;

  @override
  Rect getClip(Size size) =>
      Rect.fromLTRB(0, 0, size.width * fraction, size.height);

  @override
  bool shouldReclip(_SliderClipper oldClipper) =>
      oldClipper.fraction != fraction;
}

class _ComparePanel extends StatelessWidget {
  const _ComparePanel({required this.entry, required this.label});

  final WoundEntry entry;
  final String label;

  @override
  Widget build(BuildContext context) {
    final path = entry.photoPath;
    final hasPhoto = path != null && path.trim().isNotEmpty;
    return Column(
      children: [
        Expanded(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(AppRadius.lg),
            child: hasPhoto
                ? Image.file(
                    File(path.trim()),
                    fit: BoxFit.cover,
                    width: double.infinity,
                    errorBuilder: (_, _, _) => const Center(
                      child: Icon(Icons.broken_image_outlined, size: 40),
                    ),
                  )
                : const Center(
                    child: Icon(Icons.image_not_supported_outlined, size: 40),
                  ),
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: AppColors.textSecondary,
          ),
        ),
        Text(
          _formatDate(entry.createdAt),
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
      ],
    );
  }

  static String _formatDate(DateTime dt) {
    final dd = dt.day.toString().padLeft(2, '0');
    final mm = dt.month.toString().padLeft(2, '0');
    final yyyy = dt.year.toString();
    return '$dd.$mm.$yyyy';
  }
}

class _OverlayLabel extends StatelessWidget {
  const _OverlayLabel({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.55),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: Colors.white,
        ),
      ),
    );
  }
}
