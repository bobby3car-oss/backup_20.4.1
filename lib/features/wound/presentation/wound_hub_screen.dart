import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';

import '../../../sync/connectivity_service.dart';
import '../../../ui/ui.dart';
import '../../assistant/presentation/bella_overlay_controller.dart';
import '../../pro/domain/trigger_context.dart';
import '../../pro/presentation/smart_paywall.dart';
import '../data/wound_repository_sync.dart';
import '../../onboarding_tutorial/data/feature_discovery_service.dart';
import '../domain/wound_entry.dart';
import 'wound_compare_screen.dart';
import 'wound_comparison_screen.dart';
import 'wound_entry_detail_screen.dart';
import 'wound_hygiene_card.dart';
import 'wound_screen.dart';
import '../../../l10n/app_localizations.dart';

// ─────────────────────────────────────────────────────────────────────────────
/// Central hub for the wound documentation system.
///
/// Shows real patient data from [WoundRepositorySync] and provides navigation
/// to the editor ([WoundScreen]), history, detail and compare screens.
// ─────────────────────────────────────────────────────────────────────────────

class WoundHubScreen extends StatefulWidget {
  const WoundHubScreen({super.key});

  @override
  State<WoundHubScreen> createState() => _WoundHubScreenState();
}

class _WoundHubScreenState extends State<WoundHubScreen> {
  static final WoundRepositorySync _repository = WoundRepositorySync.instance;

  List<WoundEntry> _entries = const [];
  StreamSubscription<List<WoundEntry>>? _sub;
  int _selectedIndex = 0;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    unawaited(_repository.pullLatest());
    WidgetsBinding.instance
        .addPostFrameCallback((_) => _showDiscoveryTip());
    _sub = _repository.watchAll().listen((data) {
      if (!mounted) return;
      final sorted = List<WoundEntry>.of(data)
        ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
      setState(() {
        _entries = sorted;
        _loading = false;
        if (_selectedIndex >= sorted.length) {
          _selectedIndex = sorted.isEmpty ? 0 : sorted.length - 1;
        }
      });
    });
  }

  Future<void> _showDiscoveryTip() async {
    final seen = await FeatureDiscoveryService.instance
        .hasSeenFeature('wound_hub');
    if (!seen && mounted) {
      await FeatureDiscoveryService.instance.markSeen('wound_hub');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Tipp: Fotografiere deine Wunde regelmäßig '
            '– so erkennst du Veränderungen auf einen Blick.',
          ),
          duration: Duration(seconds: 5),
        ),
      );
    }
  }

  @override
  void dispose() {
    _sub?.cancel();
    super.dispose();
  }

  WoundEntry? get _current =>
      _entries.isNotEmpty ? _entries[_selectedIndex] : null;

  // ── Navigation helpers ─────────────────────────────────────────────────

  Future<void> _openEditor() async {
    final result = await Navigator.of(context).push<bool>(
      MaterialPageRoute<bool>(builder: (_) => const WoundScreen()),
    );
    if (result == true) {
      unawaited(_repository.pullLatest());
    }
  }

  void _openDetail(WoundEntry entry) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => WoundEntryDetailScreen(entry: entry),
      ),
    );
  }

  Future<void> _openCompare() async {
    if (_entries.length < 2) {
      final l = AppLocalizations.of(context)!;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l.minTwoEntriesForComparison),
          duration: Duration(milliseconds: 1600),
        ),
      );
      return;
    }
    final entryA = _entries.length > 1 ? _entries[1] : _entries[0];
    final entryB = _entries[0];
    await Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => WoundCompareScreen(entryA: entryA, entryB: entryB),
      ),
    );
  }

  void _openHistory() {
    Navigator.of(context).pushNamed('/wound-history');
  }

  void _openComparison() async {
    int withPhotos = 0;
    for (final e in _entries) {
      final p = e.photoPath;
      if (p != null && p.trim().isNotEmpty && await File(p.trim()).exists()) {
        withPhotos++;
        if (withPhotos >= 2) break;
      }
    }
    if (!mounted) return;
    if (withPhotos < 2) {
      final l = AppLocalizations.of(context)!;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l.woundMinPhotos),
          duration: Duration(milliseconds: 1600),
        ),
      );
      return;
    }
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => const WoundComparisonScreen(),
      ),
    );
  }

  void _openBellaAnalysis(BuildContext context) {
    final bella = BellaOverlayController.instance;
    if (bella == null) return;
    if (!ConnectivityService.instance.isOnline.value) return;

    if (!bella.isPro) {
      SmartPaywall.trigger(
        context: context,
        triggerContext: TriggerContext.assistantFeature,
      );
      return;
    }

    if (_entries.isEmpty) return;

    // Collect up to 4 most recent photos
    final photoPaths = <String>[];
    for (final e in _entries) {
      if (photoPaths.length >= 4) break;
      final p = e.photoPath;
      if (p != null && p.trim().isNotEmpty) {
        final f = File(p.trim());
        if (f.existsSync()) photoPaths.add(p.trim());
      }
    }

    if (photoPaths.isEmpty) {
      final l = AppLocalizations.of(context)!;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l.woundNoPhotos),
          duration: Duration(milliseconds: 1600),
        ),
      );
      return;
    }

    bella.open();
    bella.sendWithImages(
      'Bitte analysiere meine aktuellen Wundfotos'
      '${photoPaths.length > 1 ? ' und vergleiche den Verlauf der ${photoPaths.length} Aufnahmen' : ''}.',
      photoPaths,
    );
  }

  // ── Build ──────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return GlassPage(
      title: 'Wunddokumentation',
      titleIcon: Icons.healing_rounded,
      trailing: _entries.isNotEmpty
          ? GlassContainer(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.md,
                vertical: AppSpacing.sm,
              ),
              borderRadius: AppRadius.borderRadiusPill,
              child: Text(
                '${_entries.length} ${_entries.length == 1 ? 'Eintrag' : 'Einträge'}',
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: AppColors.primary,
                ),
              ),
            )
          : null,
      children: _loading
          ? [const SizedBox(height: 120), const Center(child: CircularProgressIndicator())]
          : _entries.isEmpty
              ? _buildEmptyChildren(context)
              : _buildContentChildren(context),
    );
  }

  // ── Empty state ────────────────────────────────────────────────────────

  List<Widget> _buildEmptyChildren(BuildContext context) {
    return [
      const SizedBox(height: AppSpacing.xxxl),
      Center(
        child: Column(
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.08),
                borderRadius: AppRadius.borderRadiusXxl,
              ),
              child: const Icon(
                Icons.camera_alt_rounded,
                size: 40,
                color: AppColors.primary,
              ),
            ),
            const SizedBox(height: AppSpacing.xl),
            Text(
              'Noch keine Einträge',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              'Dokumentiere deine Wundheilung mit Fotos,\n'
              'Schmerzwerten und Notizen.',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: AppColors.textSecondary,
                height: 1.5,
              ),
            ),
            const SizedBox(height: AppSpacing.xxl),
            GlassButton(
              onPressed: _openEditor,
              label: 'Erste Dokumentation starten',
              icon: Icons.add_a_photo_outlined,
              expand: true,
            ),
          ],
        ),
      ),
      const SizedBox(height: AppSpacing.xxxl),
      const WoundHygieneCard(),
    ];
  }

  // ── Main content ───────────────────────────────────────────────────────

  List<Widget> _buildContentChildren(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final current = _current!;

    return [
      _buildPhotoCard(context, current),
      const SizedBox(height: AppSpacing.lg),
      _buildDaySelector(context),
      const SizedBox(height: AppSpacing.xxl),
      _buildDetailCard(context, current),
      const SizedBox(height: AppSpacing.lg),
      _buildQuickActions(context),
      const SizedBox(height: AppSpacing.lg),
      const WoundHygieneCard(),
      const SizedBox(height: AppSpacing.xxl),
      _sectionTitle(context, l.history),
      const SizedBox(height: AppSpacing.md),
      _buildTimeline(context),
      const SizedBox(height: AppSpacing.xxl),
      GlassButton(
        onPressed: _openEditor,
        label: 'Neues Foto aufnehmen',
        icon: Icons.camera_alt_rounded,
        expand: true,
      ),
    ];
  }

  // ── Photo card ─────────────────────────────────────────────────────────

  Widget _buildPhotoCard(BuildContext context, WoundEntry entry) {
    final path = entry.photoPath;
    final hasPath = path != null && path.trim().isNotEmpty;
    final file = hasPath ? File(path.trim()) : null;
    final hasImage = file != null && file.existsSync();
    final dayOffset = _dayOffset(entry);

    return GlassContainer(
      padding: EdgeInsets.zero,
      borderRadius: AppRadius.borderRadiusXl,
      child: Column(
        children: [
          GestureDetector(
            onTap: () => _openDetail(entry),
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
                  if (hasImage)
                    Positioned.fill(
                      child: ClipRRect(
                        borderRadius: const BorderRadius.vertical(
                          top: Radius.circular(AppRadius.xl),
                        ),
                        child: Image.file(file, fit: BoxFit.cover),
                      ),
                    )
                  else
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
                            'Kein Foto vorhanden',
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                          const SizedBox(height: AppSpacing.xs),
                          Text(
                            'Tippen für Details',
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                        ],
                      ),
                    ),

                  // Day badge
                  Positioned(
                    top: AppSpacing.lg,
                    left: AppSpacing.lg,
                    child: _DayBadge(dayOffset: dayOffset),
                  ),

                  // Pain badge
                  Positioned(
                    top: AppSpacing.lg,
                    right: AppSpacing.lg,
                    child: _PainBadge(level: entry.pain),
                  ),
                ],
              ),
            ),
          ),

          // Thumbnail strip
          if (_entries.length > 1)
            Padding(
              padding: const EdgeInsets.all(AppSpacing.md),
              child: SizedBox(
                height: 60,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: _entries.length,
                  separatorBuilder: (_, _) =>
                      const SizedBox(width: AppSpacing.sm),
                  itemBuilder: (context, i) {
                    final selected = i == _selectedIndex;
                    final e = _entries[i];
                    final thumbPath = e.photoPath;
                    final thumbFile = thumbPath != null && thumbPath.isNotEmpty
                        ? File(thumbPath)
                        : null;
                    final hasThumb =
                        thumbFile != null && thumbFile.existsSync();

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
                        child: hasThumb
                            ? ClipRRect(
                                borderRadius:
                                    BorderRadius.circular(AppRadius.md - 2),
                                child: Image.file(
                                  thumbFile,
                                  fit: BoxFit.cover,
                                  width: 60,
                                  height: 60,
                                ),
                              )
                            : Column(
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
                                    _dayLabel(_dayOffset(e)),
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
    if (_entries.length <= 1) return const SizedBox.shrink();

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
            _formatDate(_current!.createdAt),
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

  // ── Detail card ────────────────────────────────────────────────────────

  Widget _buildDetailCard(BuildContext context, WoundEntry entry) {
    final l = AppLocalizations.of(context)!;
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
              Text(l.details, style: Theme.of(context).textTheme.titleMedium),
            ],
          ),
          const SizedBox(height: AppSpacing.lg),
          _DetailRow(
            label: l.painLevel,
            value: '${entry.pain}/10',
            color: _painColor(entry.pain),
          ),
          if (entry.bodyLocation != null &&
              entry.bodyLocation!.trim().isNotEmpty) ...[
            const SizedBox(height: AppSpacing.sm),
            _DetailRow(label: 'Körperstelle', value: entry.bodyLocation!),
          ],
          if (entry.note.trim().isNotEmpty) ...[
            const SizedBox(height: AppSpacing.lg),
            Text(
              entry.note.trim(),
              style: Theme.of(context)
                  .textTheme
                  .bodyMedium
                  ?.copyWith(height: 1.55),
            ),
          ],
        ],
      ),
    );
  }

  // ── Quick actions ──────────────────────────────────────────────────────

  Widget _buildQuickActions(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _QuickActionCard(
                icon: Icons.add_a_photo_outlined,
                label: 'Neu erfassen',
                color: AppColors.primary,
                onTap: _openEditor,
              ),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: _QuickActionCard(
                icon: Icons.compare_arrows_rounded,
                label: l.woundCompare,
                color: AppColors.accent,
                onTap: _openCompare,
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.md),
        Row(
          children: [
            Expanded(
              child: _QuickActionCard(
                icon: Icons.history_rounded,
                label: l.history,
                color: AppColors.success,
                onTap: _openHistory,
              ),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: _QuickActionCard(
                icon: Icons.healing_rounded,
                label: 'Bella Analyse 🐰',
                color: const Color(0xFFE91E63),
                onTap: () => _openBellaAnalysis(context),
              ),
            ),
          ],
        ),
        if (_entries.where((e) => e.photoPath != null && e.photoPath!.trim().isNotEmpty).length >= 2) ...[
          const SizedBox(height: AppSpacing.md),
          GlassButton(
            onPressed: _openComparison,
            label: 'Verlauf vergleichen',
            icon: Icons.compare_rounded,
            expand: true,
          ),
        ],
      ],
    );
  }

  // ── Progress timeline ──────────────────────────────────────────────────

  Widget _buildTimeline(BuildContext context) {
    final items = _entries.take(5).toList();

    return GlassContainer(
      padding: const EdgeInsets.all(AppSpacing.xl),
      borderRadius: AppRadius.borderRadiusXl,
      child: Column(
        children: [
          for (var i = 0; i < items.length; i++)
            _TimelineRow(
              entry: items[i],
              dayOffset: _dayOffset(items[i]),
              isLast: i == items.length - 1,
              isSelected: i == _selectedIndex,
              onTap: () => setState(() => _selectedIndex = i),
            ),
          if (_entries.length > 5) ...[
            const SizedBox(height: AppSpacing.md),
            GestureDetector(
              onTap: _openHistory,
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Alle anzeigen',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: AppColors.primary,
                    ),
                  ),
                  SizedBox(width: 4),
                  Icon(
                    Icons.arrow_forward_ios_rounded,
                    size: 12,
                    color: AppColors.primary,
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  // ── Helpers ────────────────────────────────────────────────────────────

  int _dayOffset(WoundEntry entry) {
    final now = DateTime.now();
    return DateTime(entry.createdAt.year, entry.createdAt.month,
            entry.createdAt.day)
        .difference(DateTime(now.year, now.month, now.day))
        .inDays;
  }

  static String _dayLabel(int offset) {
    if (offset == 0) return 'Heute';
    if (offset == -1) return 'Gestern';
    return 'Tag $offset';
  }

  static String _formatDate(DateTime dt) {
    const months = [
      'Jan', 'Feb', 'Mär', 'Apr', 'Mai', 'Jun',
      'Jul', 'Aug', 'Sep', 'Okt', 'Nov', 'Dez',
    ];
    return '${dt.day}. ${months[dt.month - 1]} ${dt.year}';
  }

  static Color _painColor(int level) {
    if (level <= 3) return AppColors.success;
    if (level <= 6) return AppColors.warning;
    return AppColors.error;
  }

  Widget _sectionTitle(BuildContext context, String title) {
    return Padding(
      padding: const EdgeInsets.only(left: AppSpacing.xs),
      child: Text(title, style: Theme.of(context).textTheme.titleLarge),
    );
  }
}

// ── Shared widgets ───────────────────────────────────────────────────────────

class _DetailRow extends StatelessWidget {
  const _DetailRow({
    required this.label,
    required this.value,
    this.color,
  });

  final String label;
  final String value;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: AppColors.textSecondary,
          ),
        ),
        const Spacer(),
        Text(
          value,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: color ?? AppColors.textPrimary,
          ),
        ),
      ],
    );
  }
}

class _QuickActionCard extends StatelessWidget {
  const _QuickActionCard({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return PressableScale(
      onTap: onTap,
      child: GlassContainer(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.sm,
          vertical: AppSpacing.lg,
        ),
        borderRadius: AppRadius.borderRadiusLg,
        child: Column(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.10),
                borderRadius: AppRadius.borderRadiusMd,
              ),
              child: Icon(icon, size: 22, color: color),
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              label,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DayBadge extends StatelessWidget {
  const _DayBadge({required this.dayOffset});

  final int dayOffset;

  @override
  Widget build(BuildContext context) {
    final String text;
    final Color bg;

    if (dayOffset == 0) {
      text = 'Heute';
      bg = AppColors.primary;
    } else if (dayOffset == -1) {
      text = 'Gestern';
      bg = AppColors.success;
    } else {
      text = 'Vor ${dayOffset.abs()} Tagen';
      bg = AppColors.success;
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
        style: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w700,
          color: AppColors.white,
        ),
      ),
    );
  }
}

class _PainBadge extends StatelessWidget {
  const _PainBadge({required this.level});

  final int level;

  Color get _color {
    if (level <= 3) return AppColors.success;
    if (level <= 6) return AppColors.warning;
    return AppColors.error;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.xs,
      ),
      decoration: BoxDecoration(
        color: _color.withValues(alpha: 0.90),
        borderRadius: AppRadius.borderRadiusPill,
      ),
      child: Text(
        '$level/10',
        style: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w700,
          color: AppColors.white,
        ),
      ),
    );
  }
}

class _TimelineRow extends StatelessWidget {
  const _TimelineRow({
    required this.entry,
    required this.dayOffset,
    required this.isLast,
    required this.isSelected,
    required this.onTap,
  });

  final WoundEntry entry;
  final int dayOffset;
  final bool isLast;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Rail
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
                          : AppColors.success.withValues(alpha: 0.10),
                      shape: BoxShape.circle,
                      border: isSelected
                          ? Border.all(color: AppColors.primary, width: 2)
                          : null,
                    ),
                    child: Icon(
                      Icons.check_rounded,
                      size: 14,
                      color: isSelected ? AppColors.primary : AppColors.success,
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

            // Content
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
                            _WoundHubScreenState._formatDate(entry.createdAt),
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: isSelected
                                  ? FontWeight.w600
                                  : FontWeight.w500,
                              color: AppColors.textPrimary,
                            ),
                          ),
                        ),
                        Text(
                          _WoundHubScreenState._dayLabel(dayOffset),
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    Row(
                      children: [
                        Text(
                          'Schmerz: ${entry.pain}/10',
                          style: TextStyle(
                            fontSize: 13,
                            color: _WoundHubScreenState._painColor(entry.pain),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        if (entry.bodyLocation != null &&
                            entry.bodyLocation!.trim().isNotEmpty) ...[
                          const SizedBox(width: AppSpacing.md),
                          Text(
                            entry.bodyLocation!,
                            style: const TextStyle(
                              fontSize: 13,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ],
                    ),
                    if (entry.note.trim().isNotEmpty) ...[
                      const SizedBox(height: AppSpacing.xs),
                      Text(
                        entry.note.trim(),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 13,
                          color: AppColors.textSecondary,
                          height: 1.4,
                        ),
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
