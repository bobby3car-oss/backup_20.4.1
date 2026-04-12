import 'dart:async';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

import '../../../main.dart';
import '../../../sync/storage_upload_queue.dart';
import '../../../ui/ui.dart';
import '../../ads/data/ad_config.dart';
import '../../ads/presentation/ad_banner_widget.dart';
import '../../ads/presentation/ad_slot_helper.dart';
import '../../pro/domain/pro_feature_gate.dart';
import '../../pro/domain/trigger_context.dart';
import '../../pro/presentation/smart_paywall.dart';
import '../data/documents_repository_local.dart';
import '../domain/document_item.dart';
import 'document_preview_screen.dart';
import '../../../ui/theme/app_icons.dart';
import '../../../l10n/app_localizations.dart';

// ── Helpers ──────────────────────────────────────────────────────────────────

enum _SortOrder {
  newestFirst('Neueste zuerst'),
  oldestFirst('Älteste zuerst'),
  nameAZ('Name A → Z'),
  nameZA('Name Z → A');

  const _SortOrder(this.label);
  final String label;
}

extension _DocumentTypeMeta on DocumentType {
  String get label => switch (this) {
    DocumentType.arztbrief => 'Arztbrief',
    DocumentType.aufklaerung => 'Aufklärung',
    DocumentType.rezept => 'Rezept',
    DocumentType.befunde => 'Befunde',
    DocumentType.sonstiges => 'Sonstiges',
  };

  IconData get icon => switch (this) {
    DocumentType.arztbrief => Icons.description_outlined,
    DocumentType.aufklaerung => Icons.fact_check_outlined,
    DocumentType.rezept => Icons.medication_outlined,
    DocumentType.befunde => Icons.biotech_outlined,
    DocumentType.sonstiges => Icons.insert_drive_file_outlined,
  };

  Color get color => switch (this) {
    DocumentType.arztbrief => AppColors.primary,
    DocumentType.aufklaerung => AppColors.warning,
    DocumentType.rezept => AppColors.success,
    DocumentType.befunde => AppColors.error,
    DocumentType.sonstiges => AppColors.grey600,
  };
}

String _formatDate(DateTime d) {
  final dd = d.day.toString().padLeft(2, '0');
  final mm = d.month.toString().padLeft(2, '0');
  return '$dd.$mm.${d.year}';
}

String _formatSize(int? bytes) {
  if (bytes == null || bytes <= 0) return '';
  if (bytes < 1024) return '$bytes B';
  if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(0)} KB';
  return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
}

String _generateId() {
  final now = DateTime.now();
  return 'doc_${now.year}${now.month.toString().padLeft(2, '0')}'
      '${now.day.toString().padLeft(2, '0')}'
      '_${now.hour.toString().padLeft(2, '0')}'
      '${now.minute.toString().padLeft(2, '0')}'
      '${now.second.toString().padLeft(2, '0')}'
      '_${now.microsecondsSinceEpoch}';
}

String _defaultTitle(String rawName) {
  final trimmed = rawName.trim();
  if (trimmed.isEmpty) return 'Dokument';
  final lower = trimmed.toLowerCase();
  if (lower.endsWith('.pdf') && trimmed.length > 4) {
    return trimmed.substring(0, trimmed.length - 4);
  }
  return trimmed;
}

// ─────────────────────────────────────────────────────────────────────────────

class DocumentsScreen extends StatefulWidget {
  const DocumentsScreen({super.key});

  @override
  State<DocumentsScreen> createState() => _DocumentsScreenState();
}

class _DocumentsScreenState extends State<DocumentsScreen> {
  final DocumentsRepositoryLocal _repository =
      DocumentsRepositoryLocal.instance;
  final TextEditingController _searchController = TextEditingController();

  DocumentType? _activeFilter;
  _SortOrder _sortOrder = _SortOrder.newestFirst;
  String _searchQuery = '';
  bool _isUploading = false;
  bool _initialRouteStateApplied = false;
  String? _contextLabel;
  Timer? _pendingDeleteTimer;

  String? _currentUserId() {
    try {
      final uid = FirebaseAuth.instance.currentUser?.uid;
      if (uid == null || uid.trim().isEmpty) return null;
      return uid;
    } catch (_) {
      return null;
    }
  }

  @override
  void initState() {
    super.initState();
    _retryPendingUploads();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_initialRouteStateApplied) return;
    _initialRouteStateApplied = true;

    final args = ModalRoute.of(context)?.settings.arguments;
    if (args is! Map) return;

    final typeName = args['type']?.toString();
    final query = args['query']?.toString().trim() ?? '';
    final contextLabel = args['contextLabel']?.toString().trim();
    final filter = typeName == null
        ? null
        : DocumentType.values.asNameMap()[typeName];

    _activeFilter = filter;
    _searchQuery = query;
    _searchController.text = query;
    _contextLabel = (contextLabel == null || contextLabel.isEmpty)
        ? null
        : contextLabel;
  }

  @override
  void dispose() {
    _pendingDeleteTimer?.cancel();
    _searchController.dispose();
    super.dispose();
  }

  List<DocumentItem> _filteredAndSorted(List<DocumentItem> source) {
    var result = source;

    if (_activeFilter != null) {
      result = result
          .where((d) => d.type == _activeFilter)
          .toList(growable: false);
    }

    if (_searchQuery.isNotEmpty) {
      final q = _searchQuery.toLowerCase();
      result = result
          .where((d) {
            return d.title.toLowerCase().contains(q) ||
                d.type.label.toLowerCase().contains(q);
          })
          .toList(growable: false);
    }

    final sorted = List<DocumentItem>.of(result);
    switch (_sortOrder) {
      case _SortOrder.newestFirst:
        sorted.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      case _SortOrder.oldestFirst:
        sorted.sort((a, b) => a.createdAt.compareTo(b.createdAt));
      case _SortOrder.nameAZ:
        sorted.sort(
          (a, b) => a.title.toLowerCase().compareTo(b.title.toLowerCase()),
        );
      case _SortOrder.nameZA:
        sorted.sort(
          (a, b) => b.title.toLowerCase().compareTo(a.title.toLowerCase()),
        );
    }
    return sorted;
  }

  Map<DocumentType, int> _countsByType(List<DocumentItem> items) {
    final counts = <DocumentType, int>{};
    for (final item in items) {
      counts[item.type] = (counts[item.type] ?? 0) + 1;
    }
    return counts;
  }

  int _totalSize(List<DocumentItem> items) {
    var total = 0;
    for (final item in items) {
      total += item.sizeBytes ?? 0;
    }
    return total;
  }

  int _syncedCount(List<DocumentItem> items) {
    return items.where((d) => d.metadata['syncState'] == 'synced').length;
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final bottomPadding = MediaQuery.of(context).padding.bottom;

    return Stack(
      children: [
        GlassPage(
      title: 'Dokumente',
      titleIcon: AppIcons.documents,
      titleColor: AppColors.primary,
      trailing: _HeaderActionButton(
            icon: Icons.sort_rounded,
            onTap: () => _showSortSheet(context),
          ),
      scrollableBody: (headerHeight) => StreamBuilder<List<DocumentItem>>(
        stream: _repository.watchAll(),
        builder: (context, snapshot) {
          final allItems = snapshot.data ?? const <DocumentItem>[];
          final filtered = _filteredAndSorted(allItems);
          final counts = _countsByType(allItems);

          return Column(
            children: [
              SizedBox(height: headerHeight + AppSpacing.sm),

              // ── Hero stats banner ──────────────────────
              if (allItems.isNotEmpty)
                Padding(
                  padding: AppSpacing.paddingHorizontalXl,
                  child: FadeSlideIn(
                    child: _HeroStatsBanner(
                      totalDocuments: allItems.length,
                      totalSize: _totalSize(allItems),
                      syncedCount: _syncedCount(allItems),
                      onUpload: _isUploading ? null : _startUploadFlow,
                    ),
                  ),
                ),

              SizedBox(height: allItems.isNotEmpty ? AppSpacing.xl : 0),

              // ── Search bar ─────────────────────────────
              Padding(
                padding: AppSpacing.paddingHorizontalXl,
                child: GlassTextField(
                  controller: _searchController,
                  prefixIcon: Icons.search_rounded,
                  hint: 'Dokumente durchsuchen …',
                  onChanged: (v) => setState(() => _searchQuery = v),
                ),
              ),
              const SizedBox(height: AppSpacing.md),

              if (_contextLabel != null)
                Padding(
                  padding: AppSpacing.paddingHorizontalXl,
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Wrap(
                      spacing: AppSpacing.sm,
                      runSpacing: AppSpacing.sm,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: AppSpacing.md,
                            vertical: AppSpacing.sm,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.primary.withValues(alpha: 0.10),
                            borderRadius: AppRadius.borderRadiusPill,
                            border: Border.all(
                              color: AppColors.primary.withValues(alpha: 0.18),
                            ),
                          ),
                          child: Text(
                            'Medikation: $_contextLabel',
                            style: Theme.of(context).textTheme.labelLarge
                                ?.copyWith(color: AppColors.primaryDark),
                          ),
                        ),
                        TextButton(
                          onPressed: () {
                            setState(() {
                              _contextLabel = null;
                              _activeFilter = null;
                              _searchQuery = '';
                              _searchController.clear();
                            });
                          },
                          child: Text(l.filterReset),
                        ),
                      ],
                    ),
                  ),
                ),
              if (_contextLabel != null) const SizedBox(height: AppSpacing.md),

              // ── Filter chips ───────────────────────────
              _FilterRow(
                activeFilter: _activeFilter,
                counts: counts,
                onChanged: (type) {
                  setState(() {
                    _activeFilter = _activeFilter == type ? null : type;
                  });
                },
              ),
              const SizedBox(height: AppSpacing.lg),

              // ── Content ────────────────────────────────
              Expanded(
                child: allItems.isEmpty && _searchQuery.isEmpty
                    ? _EmptyUploadZone(onUpload: _startUploadFlow)
                    : filtered.isEmpty
                    ? Center(
                        child: Padding(
                          padding: AppSpacing.paddingHorizontalXl,
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Container(
                                width: 56,
                                height: 56,
                                decoration: BoxDecoration(
                                  color: AppColors.grey200,
                                  borderRadius: AppRadius.borderRadiusXl,
                                ),
                                child: const Icon(
                                  Icons.search_off_rounded,
                                  size: 28,
                                  color: AppColors.grey400,
                                ),
                              ),
                              const SizedBox(height: AppSpacing.lg),
                              Text(
                                'Keine Treffer',
                                style: Theme.of(context).textTheme.titleMedium
                                    ?.copyWith(color: AppColors.textSecondary),
                              ),
                              const SizedBox(height: AppSpacing.xs),
                              Text(
                                'Versuche einen anderen Suchbegriff.',
                                style: Theme.of(context).textTheme.bodySmall
                                    ?.copyWith(color: AppColors.grey400),
                              ),
                            ],
                          ),
                        ),
                      )
                    : ValueListenableBuilder<AdConfig>(
                        valueListenable: AdServiceScope.of(context).config,
                        builder: (context, adConfig, _) {
                          final adFrequency =
                              normalizeAdFrequency(adConfig.adFrequency);
                          return ListView.separated(
                            physics: adaptiveScrollPhysics,
                            padding: const EdgeInsets.only(
                              left: AppSpacing.xl,
                              right: AppSpacing.xl,
                              bottom: 120,
                            ),
                            itemCount:
                                itemCountWithAds(filtered.length, adFrequency),
                            separatorBuilder: (_, _) =>
                                const SizedBox(height: AppSpacing.md),
                            itemBuilder: (context, index) {
                              final adsBefore =
                                  adsBeforeIndex(index, adFrequency);
                              final isAdSlot =
                                  isAdSlotIndex(index, adFrequency);

                              if (isAdSlot) return const AdBannerWidget();

                              final realIndex = index - adsBefore;
                              if (realIndex < 0 || realIndex >= filtered.length) {
                                return const SizedBox.shrink();
                              }
                              final item = filtered[realIndex];
                              return FadeSlideIn(
                                delay: Duration(
                                  milliseconds: (index * 60).clamp(0, 600),
                                ),
                                child: _SwipeableDocumentCard(
                                  item: item,
                                  onDelete: () => _deleteItem(item),
                                  onTap: () => _openItem(context, item),
                                  onShare: () => _shareItem(context, item),
                                ),
                              );
                            },
                          );
                        },
                      ),
              ),
            ],
          );
        },
      ),
    ),

        // ── FAB above the bottom navigation bar ──────────────────
        Positioned(
          left: 16,
          bottom: bottomPadding + 96,
          child: SizedBox(
            width: 64,
            height: 64,
            child: FloatingActionButton(
              heroTag: 'documents_fab',
              onPressed: _isUploading ? null : _startUploadFlow,
              backgroundColor: AppColors.primary,
              elevation: 6,
              shape: const CircleBorder(),
              child: _isUploading
                  ? const SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(
                        strokeWidth: 2.5,
                        color: Colors.white,
                      ),
                    )
                  : const Icon(Icons.add_rounded, size: 32, color: Colors.white),
            ),
          ),
        ),
      ],
    );
  }

  // ── Actions ──────────────────────────────────────────────────────────────

  void _openItem(BuildContext context, DocumentItem item) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => DocumentPreviewScreen(item: item),
      ),
    );
  }

  Future<void> _deleteItem(DocumentItem item) async {
    final l = AppLocalizations.of(context)!;
    try {
      await _repository.delete(item.id);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(userFacingError(e, fallback: l.fehlerBeimLoeschen))),
      );
      return;
    }

    // Defer remote deletion so the user can undo before data is lost.
    _pendingDeleteTimer?.cancel();
    final uid = _currentUserId();
    _pendingDeleteTimer = Timer(const Duration(seconds: 4), () {
      if (uid != null && uid.isNotEmpty) {
        FirebaseFirestore.instance
            .doc('patients/$uid/documents/${item.id}')
            .delete()
            .catchError((_) {});
        if (item.storagePath != null) {
          FirebaseStorage.instance
              .ref()
              .child(item.storagePath!)
              .delete()
              .catchError((_) {});
        }
      }
    });

    if (!mounted) return;
    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(l.dokumentGeloescht(item.title)),
        action: SnackBarAction(
          label: l.rueckgaengig,
          onPressed: () {
            _pendingDeleteTimer?.cancel();
            _pendingDeleteTimer = null;
            _repository.upsert(item);
          },
        ),
      ),
    );
  }

  Future<void> _shareItem(BuildContext context, DocumentItem item) async {
    final path = item.localPath;
    if (path == null || path.trim().isEmpty) {
      final l = AppLocalizations.of(context)!;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l.noLocalFile)),
      );
      return;
    }
    final file = File(path);
    if (!await file.exists()) {
      final l = AppLocalizations.of(context)!;
      if (!context.mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(l.fileNotFound)));
      return;
    }
    await SharePlus.instance.share(
      ShareParams(files: <XFile>[XFile(path)], text: item.title),
    );
  }

  void _showSortSheet(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: AppSpacing.lg),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 36,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: AppSpacing.lg),
                  decoration: BoxDecoration(
                    color: AppColors.grey300,
                    borderRadius: AppRadius.borderRadiusPill,
                  ),
                ),
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: AppSpacing.xl),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      'Sortierung',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: AppSpacing.md),
                for (final order in _SortOrder.values)
                  ListTile(
                    leading: Icon(
                      _sortOrder == order
                          ? Icons.radio_button_checked_rounded
                          : Icons.radio_button_off_rounded,
                      color: _sortOrder == order
                          ? AppColors.primary
                          : AppColors.grey400,
                    ),
                    title: Text(order.label),
                    onTap: () {
                      setState(() => _sortOrder = order);
                      Navigator.of(ctx).pop();
                    },
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

  // ── Upload logic ─────────────────────────────────────────────────────────

  Future<void> _startUploadFlow() async {
    if (_isUploading) return;

    final uid = _currentUserId();

    final pro = ProServices.maybeOf(context);
    if (uid != null && pro != null && !pro.entitlementService.isPro) {
      final currentCount = (await _repository.watchAll().first).length;
      if (currentCount >= ProLimits.freeDocuments) {
        pro.proAnalytics.softLimitReached(
          feature: 'documents',
          count: currentCount,
          limit: ProLimits.freeDocuments,
        );
        if (mounted) {
          SmartPaywall.trigger(
            context: context,
            triggerContext: TriggerContext.documentLimit,
          );
        }
        return;
      }
    }

    if (!mounted) return;

    final selectedType = await _selectType(context);
    if (selectedType == null || !mounted) return;

    setState(() => _isUploading = true);
    try {
      final picked = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: const ['pdf'],
      );
      if (picked == null || picked.files.isEmpty) return;

      final fileInfo = picked.files.single;
      final sourcePath = fileInfo.path;
      if (sourcePath == null || sourcePath.isEmpty) {
        final l = AppLocalizations.of(context)!;
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l.fileReadError)),
        );
        return;
      }

      final id = _generateId();
      final sourceFile = File(sourcePath);
      final docsDir = await getApplicationDocumentsDirectory();
      final targetDir = Directory('${docsDir.path}/docs');
      if (!await targetDir.exists()) {
        await targetDir.create(recursive: true);
      }
      final localPath = '${targetDir.path}/$id.pdf';
      final localFile = await sourceFile.copy(localPath);
      final sizeBytes = await localFile.length();
      final now = DateTime.now();
      final storagePath = uid == null
          ? null
          : 'patients/$uid/documents/$id.pdf';
      final localSyncState = uid == null ? 'local_only' : 'uploading';

      final baseItem = DocumentItem(
        id: id,
        ownerId: uid ?? 'local_device',
        type: selectedType,
        title: _defaultTitle(fileInfo.name),
        createdAt: now,
        updatedAt: now,
        localPath: localPath,
        storagePath: storagePath,
        mimeType: 'application/pdf',
        sizeBytes: sizeBytes,
        metadata: <String, dynamic>{'syncState': localSyncState},
      );

      if (uid == null || storagePath == null) {
        await _repository.upsert(baseItem);
        if (mounted) {
          final l = AppLocalizations.of(context)!;
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(l.documentSavedLocally)),
          );
        }
        return;
      }

      try {
        final storageRef = FirebaseStorage.instance.ref().child(storagePath);
        await storageRef.putFile(
          localFile,
          SettableMetadata(contentType: 'application/pdf'),
        );
        final downloadUrl = await storageRef.getDownloadURL();
        final syncedItem = baseItem.copyWith(
          downloadUrl: downloadUrl,
          updatedAt: DateTime.now(),
          metadata: const <String, dynamic>{'syncState': 'synced'},
        );

        await FirebaseFirestore.instance
            .doc('patients/$uid/documents/$id')
            .set(<String, dynamic>{
              ...syncedItem.toJson(),
              'updatedAt': FieldValue.serverTimestamp(),
              'serverUpdatedAt': FieldValue.serverTimestamp(),
            });
        await _repository.upsert(syncedItem);
      } catch (_) {
        // Queue file upload for retry when back online
        StorageUploadQueue.instance.enqueue(StorageUploadOp(
          id: 'doc_$id',
          localFilePath: localPath,
          remoteStoragePath: storagePath,
          contentType: 'application/pdf',
          createdAt: DateTime.now(),
        ));
        final pendingItem = baseItem.copyWith(
          updatedAt: DateTime.now(),
          metadata: const <String, dynamic>{'syncState': 'pending'},
        );
        await _repository.upsert(pendingItem);
        if (mounted) {
          final l = AppLocalizations.of(context)!;
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(l.uploadFailedLocal),
            ),
          );
        }
      }
    } finally {
      if (mounted) setState(() => _isUploading = false);
    }
  }

  Future<void> _retryPendingUploads() async {
    await _repository.loadFromDisk();
    final all = await _repository.watchAll().first;
    final pending = all
        .where((d) => d.metadata['syncState'] == 'pending')
        .toList(growable: false);
    for (final item in pending) {
      await _retrySingleUpload(item);
    }
  }

  Future<void> _retrySingleUpload(DocumentItem item) async {
    if (item.localPath == null) return;
    final localFile = File(item.localPath!);
    if (!await localFile.exists()) return;

    final uid = _currentUserId();
    if (uid == null) return;

    final storagePath =
        item.storagePath ?? 'patients/$uid/documents/${item.id}.pdf';
    try {
      final storageRef = FirebaseStorage.instance.ref().child(storagePath);
      await storageRef.putFile(
        localFile,
        SettableMetadata(contentType: item.mimeType ?? 'application/pdf'),
      );
      final downloadUrl = await storageRef.getDownloadURL();
      final syncedItem = item.copyWith(
        downloadUrl: downloadUrl,
        updatedAt: DateTime.now(),
        metadata: const <String, dynamic>{'syncState': 'synced'},
      );

      await FirebaseFirestore.instance
          .doc('patients/$uid/documents/${item.id}')
          .set(<String, dynamic>{
            ...syncedItem.toJson(),
            'updatedAt': FieldValue.serverTimestamp(),
            'serverUpdatedAt': FieldValue.serverTimestamp(),
          });
      await _repository.upsert(syncedItem);
    } catch (_) {
      // Still offline — keep as pending.
    }
  }
}

// ═══════════════════════════════════════════════════════════════════════════════
//  PREMIUM  UI  COMPONENTS
// ═══════════════════════════════════════════════════════════════════════════════

Future<DocumentType?> _selectType(BuildContext context) {
  return showModalBottomSheet<DocumentType>(
    context: context,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (ctx) {
      return SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: AppSpacing.lg),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 36,
                height: 4,
                margin: const EdgeInsets.only(bottom: AppSpacing.lg),
                decoration: BoxDecoration(
                  color: AppColors.grey300,
                  borderRadius: AppRadius.borderRadiusPill,
                ),
              ),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: AppSpacing.xl),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Dokumenttyp wählen',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              for (final type in DocumentType.values)
                ListTile(
                  leading: Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          type.color.withValues(alpha: 0.15),
                          type.color.withValues(alpha: 0.06),
                        ],
                      ),
                      borderRadius: AppRadius.borderRadiusMd,
                      border: Border.all(
                        color: type.color.withValues(alpha: 0.18),
                        width: 0.5,
                      ),
                    ),
                    child: Icon(type.icon, color: type.color, size: 22),
                  ),
                  title: Text(
                    type.label,
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 15,
                    ),
                  ),
                  onTap: () => Navigator.of(ctx).pop(type),
                ),
            ],
          ),
        ),
      );
    },
  );
}

// ── Header action button ─────────────────────────────────────────────────────

class _HeaderActionButton extends StatelessWidget {
  const _HeaderActionButton({
    this.icon,
    required this.onTap,
  });

  final IconData? icon;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return PressableScale(
      onTap: onTap,
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: AppRadius.borderRadiusMd,
          boxShadow: const [
            BoxShadow(
              color: Color(0x14000000),
              blurRadius: 8,
              offset: Offset(0, 3),
            ),
          ],
        ),
        child: Icon(
          icon,
          size: 20,
          color: AppColors.primary,
        ),
      ),
    );
  }
}

// ── Hero stats banner ────────────────────────────────────────────────────────

class _HeroStatsBanner extends StatelessWidget {
  const _HeroStatsBanner({
    required this.totalDocuments,
    required this.totalSize,
    required this.syncedCount,
    this.onUpload,
  });

  final int totalDocuments;
  final int totalSize;
  final int syncedCount;
  final VoidCallback? onUpload;

  static const _borderRadius = BorderRadius.all(Radius.circular(24));

  static const _gradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF1A6EF5), Color(0xFF3D8BFD), Color(0xFF59A5FF)],
    stops: [0.0, 0.55, 1.0],
  );

  @override
  Widget build(BuildContext context) {
    final syncProgress = totalDocuments > 0
        ? syncedCount / totalDocuments
        : 0.0;

    return PressableScale(
      onTap: onUpload,
      scaleFactor: 0.975,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: _borderRadius,
          gradient: _gradient,
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF1A6EF5).withValues(alpha: 0.28),
              blurRadius: 28,
              offset: const Offset(0, 10),
              spreadRadius: -6,
            ),
            BoxShadow(
              color: const Color(0xFF1A6EF5).withValues(alpha: 0.10),
              blurRadius: 48,
              offset: const Offset(0, 20),
              spreadRadius: -10,
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: _borderRadius,
          child: CustomPaint(
            painter: _BannerHighlightPainter(),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.xxl,
                AppSpacing.xl,
                AppSpacing.xxl,
                AppSpacing.lg + 2,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ── Top row ──
                  Row(
                    children: [
                      Container(
                        width: 44,
                        height: 44,
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.18),
                          borderRadius: AppRadius.borderRadiusMd,
                          border: Border.all(
                            color: Colors.white.withValues(alpha: 0.22),
                            width: 0.5,
                          ),
                        ),
                        child: const Icon(
                          Icons.folder_rounded,
                          size: 24,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(width: AppSpacing.md),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '$totalDocuments Dokumente',
                              style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.w800,
                                color: Colors.white,
                                letterSpacing: -0.3,
                                height: 1.15,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              _formatSize(totalSize),
                              style: const TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w500,
                                color: Color(0xB3FFFFFF),
                                letterSpacing: 0.1,
                              ),
                            ),
                          ],
                        ),
                      ),
                      if (onUpload != null)
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: AppSpacing.md,
                            vertical: AppSpacing.xs + 1,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.20),
                            borderRadius: AppRadius.borderRadiusPill,
                            border: Border.all(
                              color: Colors.white.withValues(alpha: 0.25),
                              width: 0.5,
                            ),
                          ),
                          child: const Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.add_rounded,
                                size: 14,
                                color: Color(0xE6FFFFFF),
                              ),
                              SizedBox(width: AppSpacing.xs),
                              Text(
                                'Hochladen',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: Color(0xE6FFFFFF),
                                  letterSpacing: 0.1,
                                ),
                              ),
                            ],
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.lg),

                  // ── Sync progress bar ──
                  Container(
                    height: 6,
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.16),
                      borderRadius: AppRadius.borderRadiusPill,
                    ),
                    child: LayoutBuilder(
                      builder: (context, constraints) {
                        final fillWidth = constraints.maxWidth * syncProgress;
                        return Stack(
                          children: [
                            AnimatedContainer(
                              duration: const Duration(milliseconds: 600),
                              curve: Curves.easeOutCubic,
                              width: fillWidth,
                              decoration: BoxDecoration(
                                gradient: const LinearGradient(
                                  colors: [
                                    Color(0xF2FFFFFF),
                                    Color(0xD9FFFFFF),
                                  ],
                                ),
                                borderRadius: AppRadius.borderRadiusPill,
                                boxShadow: syncProgress > 0.02
                                    ? [
                                        BoxShadow(
                                          color: Colors.white.withValues(
                                            alpha: 0.45,
                                          ),
                                          blurRadius: 8,
                                          offset: const Offset(0, 1),
                                        ),
                                      ]
                                    : null,
                              ),
                            ),
                          ],
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: AppSpacing.sm),

                  // ── Counter row ──
                  Row(
                    children: [
                      Text(
                        '$syncedCount von $totalDocuments synchronisiert',
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          color: Color(0xAAFFFFFF),
                          letterSpacing: 0.05,
                        ),
                      ),
                      const Spacer(),
                      Text(
                        '${(syncProgress * 100).round()}%',
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w800,
                          color: Color(0xDDFFFFFF),
                          letterSpacing: -0.3,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ── Banner highlight painter ─────────────────────────────────────────────────

class _BannerHighlightPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;

    final topGlow = Paint()
      ..shader = RadialGradient(
        center: const Alignment(-0.7, -0.9),
        radius: 0.8,
        colors: [
          Colors.white.withValues(alpha: 0.14),
          Colors.white.withValues(alpha: 0.0),
        ],
      ).createShader(rect);
    canvas.drawRect(rect, topGlow);

    final bottomGlow = Paint()
      ..shader = RadialGradient(
        center: const Alignment(0.8, 1.0),
        radius: 0.7,
        colors: [
          Colors.white.withValues(alpha: 0.06),
          Colors.white.withValues(alpha: 0.0),
        ],
      ).createShader(rect);
    canvas.drawRect(rect, bottomGlow);

    final topLine = Paint()
      ..shader = LinearGradient(
        begin: Alignment.centerLeft,
        end: Alignment.centerRight,
        colors: [
          Colors.white.withValues(alpha: 0.0),
          Colors.white.withValues(alpha: 0.28),
          Colors.white.withValues(alpha: 0.0),
        ],
        stops: const [0.05, 0.5, 0.95],
      ).createShader(Offset.zero & Size(size.width, 1))
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.8;

    canvas.drawLine(const Offset(0, 0.5), Offset(size.width, 0.5), topLine);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// ── Filter row ───────────────────────────────────────────────────────────────

class _FilterRow extends StatelessWidget {
  const _FilterRow({
    required this.activeFilter,
    required this.counts,
    required this.onChanged,
  });

  final DocumentType? activeFilter;
  final Map<DocumentType, int> counts;
  final ValueChanged<DocumentType> onChanged;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: AppSpacing.paddingHorizontalXl,
      child: Row(
        children: [
          for (final type in DocumentType.values) ...[
            _FilterChip(
              type: type,
              count: counts[type] ?? 0,
              selected: activeFilter == type,
              onTap: () => onChanged(type),
            ),
            const SizedBox(width: AppSpacing.sm),
          ],
        ],
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  const _FilterChip({
    required this.type,
    required this.count,
    required this.selected,
    required this.onTap,
  });

  final DocumentType type;
  final int count;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return PressableScale(
      onTap: () {
        Haptic.light();
        onTap();
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.lg,
          vertical: AppSpacing.sm + 1,
        ),
        decoration: BoxDecoration(
          color: selected ? type.color.withValues(alpha: 0.12) : Colors.white,
          borderRadius: AppRadius.borderRadiusPill,
          border: Border.all(
            color: selected
                ? type.color.withValues(alpha: 0.40)
                : AppColors.grey200,
            width: selected ? 1.5 : 0.5,
          ),
          boxShadow: selected
              ? [
                  BoxShadow(
                    color: type.color.withValues(alpha: 0.12),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ]
              : [
                  const BoxShadow(
                    color: Color(0x0A000000),
                    blurRadius: 4,
                    offset: Offset(0, 1),
                  ),
                ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              type.icon,
              size: 15,
              color: selected ? type.color : AppColors.grey500,
            ),
            const SizedBox(width: AppSpacing.sm),
            Text(
              type.label,
              style: TextStyle(
                fontSize: 13,
                fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                color: selected ? type.color : AppColors.textSecondary,
              ),
            ),
            if (count > 0) ...[
              const SizedBox(width: AppSpacing.xs),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                decoration: BoxDecoration(
                  color: selected
                      ? type.color.withValues(alpha: 0.18)
                      : AppColors.grey100,
                  borderRadius: AppRadius.borderRadiusPill,
                ),
                child: Text(
                  '$count',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    color: selected ? type.color : AppColors.grey500,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

// ── Empty upload zone ────────────────────────────────────────────────────────

class _EmptyUploadZone extends StatelessWidget {
  const _EmptyUploadZone({required this.onUpload});

  final VoidCallback onUpload;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: AppSpacing.paddingHorizontalXl,
        child: PressableScale(
          onTap: () {
            Haptic.light();
            onUpload();
          },
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.xxl,
              vertical: AppSpacing.huge + AppSpacing.lg,
            ),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  AppColors.primary.withValues(alpha: 0.04),
                  AppColors.primaryLight.withValues(alpha: 0.02),
                ],
              ),
              borderRadius: AppRadius.borderRadiusXl,
              border: Border.all(
                color: AppColors.primary.withValues(alpha: 0.15),
                width: 1.5,
              ),
              boxShadow: [
                BoxShadow(
                  color: AppColors.primary.withValues(alpha: 0.04),
                  blurRadius: 20,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    gradient: AppColors.primaryGradient,
                    borderRadius: const BorderRadius.all(Radius.circular(24)),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primary.withValues(alpha: 0.30),
                        blurRadius: 24,
                        offset: const Offset(0, 8),
                        spreadRadius: -4,
                      ),
                      BoxShadow(
                        color: AppColors.primary.withValues(alpha: 0.12),
                        blurRadius: 40,
                        offset: const Offset(0, 16),
                        spreadRadius: -8,
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.cloud_upload_rounded,
                    size: 40,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: AppSpacing.xxl),
                const Text(
                  'Noch keine Dokumente',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                    color: AppColors.textPrimary,
                    letterSpacing: -0.3,
                  ),
                ),
                const SizedBox(height: AppSpacing.sm),
                const Text(
                  'Laden Sie Arztbriefe, Befunde,\nRezepte und mehr als PDF hoch.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 14,
                    height: 1.5,
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: AppSpacing.xxl),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.xxl,
                    vertical: AppSpacing.md,
                  ),
                  decoration: BoxDecoration(
                    gradient: AppColors.primaryGradient,
                    borderRadius: AppRadius.borderRadiusMd,
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primary.withValues(alpha: 0.25),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.upload_file_rounded,
                        size: 18,
                        color: Colors.white,
                      ),
                      SizedBox(width: AppSpacing.sm),
                      Text(
                        'PDF hochladen',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                          letterSpacing: 0.1,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ── Swipeable document card ──────────────────────────────────────────────────

class _SwipeableDocumentCard extends StatelessWidget {
  const _SwipeableDocumentCard({
    required this.item,
    required this.onDelete,
    required this.onTap,
    required this.onShare,
  });

  final DocumentItem item;
  final VoidCallback onDelete;
  final VoidCallback onTap;
  final VoidCallback onShare;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    return Dismissible(
      key: ValueKey(item.id),
      direction: DismissDirection.endToStart,
      onDismissed: (_) => onDelete(),
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: AppSpacing.xxl),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              AppColors.error.withValues(alpha: 0.04),
              AppColors.error.withValues(alpha: 0.14),
            ],
          ),
          borderRadius: AppRadius.borderRadiusLg,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: AppColors.error.withValues(alpha: 0.12),
                borderRadius: AppRadius.borderRadiusMd,
              ),
              child: const Icon(
                Icons.delete_rounded,
                color: AppColors.error,
                size: 22,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              l.delete,
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w600,
                color: AppColors.error,
              ),
            ),
          ],
        ),
      ),
      child: _DocumentCard(item: item, onTap: onTap, onShare: onShare),
    );
  }
}

// ── Document card ────────────────────────────────────────────────────────────

class _DocumentCard extends StatelessWidget {
  const _DocumentCard({
    required this.item,
    required this.onTap,
    required this.onShare,
  });

  final DocumentItem item;
  final VoidCallback onTap;
  final VoidCallback onShare;

  @override
  Widget build(BuildContext context) {
    final syncState = item.metadata['syncState']?.toString();
    final isPending = syncState == 'pending';
    final isSynced = syncState == 'synced';

    return PressableScale(
      onTap: () {
        Haptic.light();
        onTap();
      },
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: AppRadius.borderRadiusLg,
          border: Border.all(color: AppColors.grey100, width: 0.5),
          boxShadow: [
            BoxShadow(
              color: item.type.color.withValues(alpha: 0.06),
              blurRadius: 16,
              offset: const Offset(0, 4),
              spreadRadius: -2,
            ),
            const BoxShadow(
              color: Color(0x08000000),
              blurRadius: 8,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: AppRadius.borderRadiusLg,
          child: Row(
            children: [
              // ── Color accent stripe ──
              Container(
                width: 4,
                height: 88,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      item.type.color,
                      item.type.color.withValues(alpha: 0.40),
                    ],
                  ),
                ),
              ),

              // ── File icon ──
              Padding(
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.lg,
                  AppSpacing.lg,
                  AppSpacing.md,
                  AppSpacing.lg,
                ),
                child: _GradientFileIcon(type: item.type),
              ),

              // ── Info ──
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item.title,
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textPrimary,
                          letterSpacing: -0.2,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          _TypeLabel(type: item.type),
                          const SizedBox(width: AppSpacing.sm),
                          Flexible(
                            child: Text(
                              [
                                _formatDate(item.createdAt),
                                _formatSize(item.sizeBytes),
                              ].where((s) => s.isNotEmpty).join(' · '),
                              style: const TextStyle(
                                fontSize: 12,
                                color: AppColors.textSecondary,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                      if (isPending || isSynced) ...[
                        const SizedBox(height: 6),
                        _SyncBadge(isPending: isPending),
                      ],
                    ],
                  ),
                ),
              ),

              // ── Share button ──
              Padding(
                padding: const EdgeInsets.only(right: AppSpacing.md),
                child: PressableScale(
                  onTap: onShare,
                  child: Container(
                    width: 38,
                    height: 38,
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.06),
                      borderRadius: AppRadius.borderRadiusMd,
                      border: Border.all(
                        color: AppColors.primary.withValues(alpha: 0.10),
                        width: 0.5,
                      ),
                    ),
                    child: const Icon(
                      Icons.ios_share_rounded,
                      size: 17,
                      color: AppColors.primary,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Gradient file icon ───────────────────────────────────────────────────────

class _GradientFileIcon extends StatelessWidget {
  const _GradientFileIcon({required this.type});

  final DocumentType type;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 52,
      height: 58,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            type.color.withValues(alpha: 0.12),
            type.color.withValues(alpha: 0.04),
          ],
        ),
        borderRadius: AppRadius.borderRadiusMd,
        border: Border.all(
          color: type.color.withValues(alpha: 0.18),
          width: 0.5,
        ),
        boxShadow: [
          BoxShadow(
            color: type.color.withValues(alpha: 0.08),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.picture_as_pdf_rounded, size: 24, color: type.color),
          const SizedBox(height: 2),
          Text(
            'PDF',
            style: TextStyle(
              fontSize: 9,
              fontWeight: FontWeight.w800,
              color: type.color,
              letterSpacing: 0.8,
            ),
          ),
        ],
      ),
    );
  }
}

// ── Sync badge ───────────────────────────────────────────────────────────────

class _SyncBadge extends StatelessWidget {
  const _SyncBadge({required this.isPending});

  final bool isPending;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final color = isPending ? AppColors.warning : AppColors.success;
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm + 2,
        vertical: AppSpacing.xxs + 1,
      ),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            color.withValues(alpha: 0.12),
            color.withValues(alpha: 0.06),
          ],
        ),
        borderRadius: AppRadius.borderRadiusPill,
        border: Border.all(color: color.withValues(alpha: 0.18), width: 0.5),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 6,
            height: 6,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(color: color.withValues(alpha: 0.40), blurRadius: 4),
              ],
            ),
          ),
          const SizedBox(width: AppSpacing.xs),
          Text(
            isPending ? l.pending : 'Synchronisiert',
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w700,
              color: color,
              letterSpacing: 0.1,
            ),
          ),
        ],
      ),
    );
  }
}

// ── Type label ───────────────────────────────────────────────────────────────

class _TypeLabel extends StatelessWidget {
  const _TypeLabel({required this.type});

  final DocumentType type;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm + 2,
        vertical: AppSpacing.xxs + 1,
      ),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            type.color.withValues(alpha: 0.12),
            type.color.withValues(alpha: 0.06),
          ],
        ),
        borderRadius: AppRadius.borderRadiusPill,
        border: Border.all(
          color: type.color.withValues(alpha: 0.18),
          width: 0.5,
        ),
      ),
      child: Text(
        type.label,
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w700,
          color: type.color,
          letterSpacing: 0.1,
        ),
      ),
    );
  }
}
