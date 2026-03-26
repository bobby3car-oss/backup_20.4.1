import 'dart:async';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../../../main.dart';
import '../../../ui/ui.dart';
import '../../pro/domain/pro_feature_gate.dart';
import '../../pro/domain/trigger_context.dart';
import '../../pro/presentation/smart_paywall.dart';
import '../data/photos_repository_sync.dart';
import '../domain/photo_entry.dart';
import '../../../ui/theme/app_icons.dart';
import '../../../l10n/app_localizations.dart';

class PhotosScreen extends StatefulWidget {
  const PhotosScreen({super.key});

  @override
  State<PhotosScreen> createState() => _PhotosScreenState();
}

class _PhotosScreenState extends State<PhotosScreen> {
  static final PhotosRepositorySync _repository = PhotosRepositorySync.instance;
  static final ImagePicker _picker = ImagePicker();

  final TextEditingController _searchController = TextEditingController();
  String _query = '';
  bool _busy = false;

  @override
  void initState() {
    super.initState();
    _searchController.addListener(() {
      setState(() => _query = _searchController.text.trim());
    });
    unawaited(_repository.loadFromDisk());
    unawaited(_repository.pullLatest());
    unawaited(_repository.retryPending());
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GlassPage(
      title: 'Fotos',
      titleIcon: AppIcons.photos,
      titleColor: AppColors.primary,
      horizontalPadding: AppSpacing.lg,
      scrollableBody: (headerHeight) => StreamBuilder<List<PhotoEntry>>(
        stream: _repository.watchAll(),
        builder: (context, snapshot) {
          final allEntries = snapshot.data ?? const <PhotoEntry>[];
          final visibleEntries = _applySearch(allEntries, _query);
          return ListView(
            physics: adaptiveScrollPhysics,
            padding: EdgeInsets.fromLTRB(20, headerHeight + 12, 20, 24),
            children: [
              _searchBar(),
              const SizedBox(height: 18),
              _buildSection(
                title: 'Wundheilung',
                count: _countByCategory(allEntries, PhotoCategory.wound),
                tip:
                    'Tipp: Machen Sie täglich ein Foto von Pflaster UND Wunde',
                category: PhotoCategory.wound,
              ),
              const SizedBox(height: 18),
              _buildSection(
                title: 'OP-Aufklärungen',
                count: _countByCategory(allEntries, PhotoCategory.consent),
                category: PhotoCategory.consent,
              ),
              const SizedBox(height: 18),
              _buildSection(
                title: 'Sonstiges',
                count: _countByCategory(allEntries, PhotoCategory.other),
                category: PhotoCategory.other,
              ),
              const SizedBox(height: 18),
              if (_query.isNotEmpty) ...[
                Text(
                  'Suchtreffer (${visibleEntries.length})',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF374151),
                  ),
                ),
                const SizedBox(height: 10),
              ] else ...[
                const Text(
                  'Neueste Einträge',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF374151),
                  ),
                ),
                const SizedBox(height: 10),
              ],
              if (visibleEntries.isEmpty)
                _emptyState(_query.isNotEmpty)
              else
                ...visibleEntries.take(20).map(_entryTile),
            ],
          );
        },
      ),
    );
  }

  Widget _searchBar() {
    return Container(
      height: 44,
      decoration: BoxDecoration(
        color: const Color(0xFFE7EAF0),
        borderRadius: BorderRadius.circular(16),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 12),
      alignment: Alignment.center,
      child: Row(
        children: [
          const Icon(Icons.search_rounded, color: Color(0xFF7A828F), size: 20),
          const SizedBox(width: 8),
          Expanded(
            child: TextField(
              controller: _searchController,
              decoration: const InputDecoration(
                isCollapsed: true,
                border: InputBorder.none,
                hintText: 'Fotos durchsuchen (Datum, Notiz, Kategorie)…',
                hintStyle: TextStyle(
                  color: Color(0xFF7A828F),
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
              style: const TextStyle(
                color: Color(0xFF4B5563),
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSection({
    required String title,
    required int count,
    required PhotoCategory category,
    String? tip,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '$title ($count)',
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w800,
            color: Color(0xFF1E2430),
          ),
        ),
        if (tip != null) ...[
          const SizedBox(height: 4),
          Text(
            tip,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: Color(0xFF8E97A7),
            ),
          ),
        ],
        const SizedBox(height: 10),
        Row(
          children: [
            Expanded(
              child: _primaryPillButton(
                label: 'Foto aufnehmen',
                onPressed: _busy
                    ? null
                    : () => _pickAndStore(
                        category: category,
                        source: ImageSource.camera,
                      ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _secondaryPillButton(
                label: 'Aus Galerie',
                onPressed: _busy
                    ? null
                    : () => _pickAndStore(
                        category: category,
                        source: ImageSource.gallery,
                      ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _primaryPillButton({
    required String label,
    required VoidCallback? onPressed,
  }) {
    return SizedBox(
      height: 52,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF0A74FF),
          foregroundColor: Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(26),
          ),
          textStyle: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
        ),
        child: Text(label),
      ),
    );
  }

  Widget _secondaryPillButton({
    required String label,
    required VoidCallback? onPressed,
  }) {
    return SizedBox(
      height: 52,
      child: OutlinedButton(
        onPressed: onPressed,
        style: OutlinedButton.styleFrom(
          foregroundColor: const Color(0xFF0A74FF),
          backgroundColor: Colors.white,
          side: const BorderSide(color: Color(0xFFD8DEE8), width: 1),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(26),
          ),
          textStyle: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
        ),
        child: Text(label),
      ),
    );
  }

  Future<void> _pickAndStore({
    required PhotoCategory category,
    required ImageSource source,
  }) async {
    if (_busy) return;

    // ── Soft limit: free users can only store up to N photos ──
    final pro = ProServices.maybeOf(context);
    if (pro != null && !pro.entitlementService.isPro) {
      final currentCount =
          (await _repository.watchAll().first).length;
      if (currentCount >= ProLimits.freePhotos) {
        pro.proAnalytics.softLimitReached(
          feature: 'photos',
          count: currentCount,
          limit: ProLimits.freePhotos,
        );
        if (mounted) {
          SmartPaywall.trigger(
            context: context,
            triggerContext: TriggerContext.photoLimit,
          );
        }
        return;
      }
    }

    setState(() => _busy = true);
    try {
      final l = AppLocalizations.of(context)!;
      final picked = await _picker.pickImage(source: source, imageQuality: 88);
      if (picked == null) return;

      await _repository.createFromPickedFile(
        category: category,
        sourcePath: picked.path,
      );
      await _repository.pullLatest();

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l.photoSaved),
          duration: Duration(milliseconds: 1200),
        ),
      );
    } catch (_) {
      final l = AppLocalizations.of(context)!;
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l.uploadPending),
          duration: Duration(milliseconds: 1400),
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _busy = false);
      }
    }
  }

  List<PhotoEntry> _applySearch(List<PhotoEntry> entries, String query) {
    if (query.trim().isEmpty) return entries;
    final q = query.toLowerCase();
    return entries.where((item) {
      final date = _dateLabel(item.createdAt).toLowerCase();
      final note = item.note.toLowerCase();
      final category = _categoryLabel(item.category).toLowerCase();
      return date.contains(q) || note.contains(q) || category.contains(q);
    }).toList();
  }

  int _countByCategory(List<PhotoEntry> entries, PhotoCategory category) {
    return entries.where((item) => item.category == category).length;
  }

  Widget _entryTile(PhotoEntry item) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE5EAF2)),
      ),
      child: Row(
        children: [
          Text(
            _categoryEmoji(item.category),
            style: const TextStyle(fontSize: 20),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${_categoryLabel(item.category)} · ${_dateLabel(item.createdAt)}',
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF374151),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  item.note.isEmpty ? 'Keine Notiz' : item.note,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: Color(0xFF6B7280),
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: item.status == PhotoStatus.synced
                  ? const Color(0xFFECFDF3)
                  : const Color(0xFFFFF7ED),
              borderRadius: BorderRadius.circular(999),
            ),
            child: Text(
              item.status == PhotoStatus.synced ? 'synced' : 'pending',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: item.status == PhotoStatus.synced
                    ? const Color(0xFF0D9F6E)
                    : const Color(0xFFC27803),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _emptyState(bool isSearch) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE5EAF2)),
      ),
      child: Text(
        isSearch ? 'Keine Treffer gefunden.' : 'Noch keine Fotos vorhanden.',
        style: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: Color(0xFF6B7280),
        ),
      ),
    );
  }

  String _categoryLabel(PhotoCategory category) {
    final l = AppLocalizations.of(context)!;
    switch (category) {
      case PhotoCategory.wound:
        return 'Wundheilung';
      case PhotoCategory.consent:
        return l.opAufklaerungen;
      case PhotoCategory.other:
        return 'Sonstiges';
    }
  }

  String _categoryEmoji(PhotoCategory category) {
    switch (category) {
      case PhotoCategory.wound:
        return '🩹';
      case PhotoCategory.consent:
        return '📄';
      case PhotoCategory.other:
        return '📷';
    }
  }

  String _dateLabel(DateTime value) {
    final dd = value.day.toString().padLeft(2, '0');
    final mm = value.month.toString().padLeft(2, '0');
    final yyyy = value.year.toString();
    return '$dd.$mm.$yyyy';
  }
}
