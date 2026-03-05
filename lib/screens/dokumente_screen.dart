import 'dart:async';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

import '../features/documents/data/documents_repository_local.dart';
import '../features/documents/domain/document_item.dart';
import '../features/pro/domain/pro_feature_gate.dart';
import '../features/pro/domain/trigger_context.dart';
import '../features/pro/presentation/smart_paywall.dart';
import '../main.dart';
import '../ui/ui.dart';

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

class DokumenteScreen extends StatefulWidget {
  const DokumenteScreen({super.key});

  @override
  State<DokumenteScreen> createState() => _DokumenteScreenState();
}

class _DokumenteScreenState extends State<DokumenteScreen> {
  final DocumentsRepositoryLocal _repository =
      DocumentsRepositoryLocal.instance;

  DocumentType? _activeFilter;
  _SortOrder _sortOrder = _SortOrder.newestFirst;
  String _searchQuery = '';
  bool _isUploading = false;

  @override
  void initState() {
    super.initState();
    _retryPendingUploads();
  }

  List<DocumentItem> _filteredAndSorted(List<DocumentItem> source) {
    var result = source;

    // Filter by type
    if (_activeFilter != null) {
      result = result
          .where((d) => d.type == _activeFilter)
          .toList(growable: false);
    }

    // Search
    if (_searchQuery.isNotEmpty) {
      final q = _searchQuery.toLowerCase();
      result = result.where((d) {
        return d.title.toLowerCase().contains(q) ||
            d.type.label.toLowerCase().contains(q);
      }).toList(growable: false);
    }

    // Sort
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

  @override
  Widget build(BuildContext context) {
    return GlassPage(
      title: 'Dokumente',
      titleEmoji: '📄',
      titleColor: AppColors.primary,
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Sort button
          PressableScale(
            onTap: () => _showSortSheet(context),
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: AppRadius.borderRadiusSm,
                boxShadow: const [
                  BoxShadow(
                    color: Color(0x14000000),
                    blurRadius: 8,
                    offset: Offset(0, 2),
                  ),
                ],
              ),
              child: const Icon(
                Icons.sort_rounded,
                size: 20,
                color: AppColors.primary,
              ),
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          // Upload button
          PressableScale(
            onTap: _isUploading ? null : _startUploadFlow,
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: AppRadius.borderRadiusSm,
                boxShadow: const [
                  BoxShadow(
                    color: Color(0x14000000),
                    blurRadius: 8,
                    offset: Offset(0, 2),
                  ),
                ],
              ),
              child: _isUploading
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator.adaptive(strokeWidth: 2),
                    )
                  : const Icon(
                      Icons.upload_file_rounded,
                      size: 20,
                      color: AppColors.primary,
                    ),
            ),
          ),
        ],
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

              // ── Search bar ──────────────────────────
              Padding(
                padding: AppSpacing.paddingHorizontalXl,
                child: GlassTextField(
                  prefixIcon: Icons.search_rounded,
                  hint: 'Dokumente durchsuchen …',
                  onChanged: (v) => setState(() => _searchQuery = v),
                ),
              ),
              const SizedBox(height: AppSpacing.md),

              // ── Filter chips ────────────────────────
              _FilterRow(
                activeFilter: _activeFilter,
                counts: counts,
                onChanged: (type) {
                  setState(() {
                    _activeFilter = _activeFilter == type ? null : type;
                  });
                },
              ),
              const SizedBox(height: AppSpacing.md),

              // ── Content ─────────────────────────────
              Expanded(
                child: allItems.isEmpty && _searchQuery.isEmpty
                    ? _EmptyUploadZone(onUpload: _startUploadFlow)
                    : filtered.isEmpty
                        ? Center(
                            child: Padding(
                              padding: AppSpacing.paddingHorizontalXl,
                              child: Text(
                                'Keine Treffer für diese Suche.',
                                style: Theme.of(context)
                                    .textTheme
                                    .bodyMedium
                                    ?.copyWith(color: AppColors.textSecondary),
                              ),
                            ),
                          )
                        : ListView.separated(
                            physics: adaptiveScrollPhysics,
                            padding: const EdgeInsets.only(
                              left: AppSpacing.xl,
                              right: AppSpacing.xl,
                              bottom: 120,
                            ),
                            itemCount: filtered.length,
                            separatorBuilder: (_, _) =>
                                const SizedBox(height: AppSpacing.md),
                            itemBuilder: (context, index) {
                              final item = filtered[index];
                              return FadeSlideIn(
                                delay: Duration(
                                  milliseconds: (index * 60).clamp(0, 600),
                                ),
                                child: _SwipeableDocumentCard(
                                  item: item,
                                  onDelete: () => _deleteItem(item),
                                  onTap: () => _openPreview(context, item),
                                  onShare: () => _shareItem(context, item),
                                ),
                              );
                            },
                          ),
              ),
            ],
          );
        },
      ),
    );
  }

  // ── Actions ──────────────────────────────────────────────────────────────

  void _openPreview(BuildContext context, DocumentItem item) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => _DocumentPreviewScreen(
          item: item,
          onDelete: () => _deleteItem(item),
        ),
      ),
    );
  }

  Future<void> _deleteItem(DocumentItem item) async {
    await _repository.delete(item.id);

    // Try to delete from Storage & Firestore
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid != null && uid.isNotEmpty) {
      unawaited(
        FirebaseFirestore.instance
            .doc('patients/$uid/documents/${item.id}')
            .delete()
            .catchError((_) {}),
      );
      if (item.storagePath != null) {
        unawaited(
          FirebaseStorage.instance
              .ref()
              .child(item.storagePath!)
              .delete()
              .catchError((_) {}),
        );
      }
    }

    if (!mounted) return;
    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('„${item.title}" gelöscht'),
        action: SnackBarAction(
          label: 'Rückgängig',
          onPressed: () => _repository.upsert(item),
        ),
      ),
    );
  }

  Future<void> _shareItem(BuildContext context, DocumentItem item) async {
    final path = item.localPath;
    if (path == null || path.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Keine lokale Datei vorhanden.')),
      );
      return;
    }
    final file = File(path);
    if (!await file.exists()) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Datei nicht gefunden.')),
      );
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

    // Pro limit check
    final pro = ProServices.maybeOf(context);
    if (pro != null && !pro.entitlementService.isPro) {
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
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null || uid.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Bitte zuerst anmelden.')),
      );
      return;
    }

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
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Datei konnte nicht gelesen werden.')),
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
      final storagePath = 'patients/$uid/documents/$id.pdf';

      final baseItem = DocumentItem(
        id: id,
        ownerId: uid,
        type: selectedType,
        title: _defaultTitle(fileInfo.name),
        createdAt: now,
        updatedAt: now,
        localPath: localPath,
        storagePath: storagePath,
        mimeType: 'application/pdf',
        sizeBytes: sizeBytes,
        metadata: const <String, dynamic>{'syncState': 'uploading'},
      );

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
        final pendingItem = baseItem.copyWith(
          updatedAt: DateTime.now(),
          metadata: const <String, dynamic>{'syncState': 'pending'},
        );
        await _repository.upsert(pendingItem);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                'Upload fehlgeschlagen – lokal gespeichert.',
              ),
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

    final uid = FirebaseAuth.instance.currentUser?.uid;
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
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: type.color.withValues(alpha: 0.10),
                      borderRadius: AppRadius.borderRadiusSm,
                    ),
                    child: Icon(type.icon, color: type.color, size: 20),
                  ),
                  title: Text(type.label),
                  onTap: () => Navigator.of(ctx).pop(type),
                ),
            ],
          ),
        ),
      );
    },
  );
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
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.lg,
          vertical: AppSpacing.sm,
        ),
        decoration: BoxDecoration(
          color: selected
              ? type.color.withValues(alpha: 0.12)
              : AppColors.white.withValues(alpha: 0.5),
          borderRadius: AppRadius.borderRadiusPill,
          border: Border.all(
            color: selected
                ? type.color.withValues(alpha: 0.35)
                : AppColors.grey200,
            width: selected ? 1.5 : 0.5,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              type.icon,
              size: 16,
              color: selected ? type.color : AppColors.grey500,
            ),
            const SizedBox(width: AppSpacing.sm),
            Text(
              count > 0 ? '${type.label} ($count)' : type.label,
              style: TextStyle(
                fontSize: 13,
                fontWeight: selected ? FontWeight.w600 : FontWeight.w500,
                color: selected ? type.color : AppColors.textSecondary,
              ),
            ),
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
        child: GestureDetector(
          onTap: onUpload,
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.xxl,
              vertical: AppSpacing.huge,
            ),
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.03),
              borderRadius: AppRadius.borderRadiusXl,
              border: Border.all(
                color: AppColors.primary.withValues(alpha: 0.18),
                width: 1.5,
              ),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 72,
                  height: 72,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [AppColors.primary, AppColors.primaryLight],
                    ),
                    borderRadius: AppRadius.borderRadiusXxl,
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primary.withValues(alpha: 0.25),
                        blurRadius: 20,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.folder_open_rounded,
                    size: 36,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: AppSpacing.xxl),
                const Text(
                  'Noch keine Dokumente',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
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
                GlassButton(
                  onPressed: onUpload,
                  label: 'Dokument hochladen',
                  icon: Icons.upload_file_rounded,
                  expand: true,
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
    return Dismissible(
      key: ValueKey(item.id),
      direction: DismissDirection.endToStart,
      onDismissed: (_) => onDelete(),
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: AppSpacing.xxl),
        decoration: BoxDecoration(
          color: AppColors.error.withValues(alpha: 0.12),
          borderRadius: AppRadius.borderRadiusLg,
        ),
        child: const Icon(
          Icons.delete_rounded,
          color: AppColors.error,
          size: 28,
        ),
      ),
      child: _DocumentCard(
        item: item,
        onTap: onTap,
        onShare: onShare,
      ),
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
      onTap: onTap,
      child: GlassContainer(
        padding: const EdgeInsets.all(AppSpacing.lg),
        borderRadius: AppRadius.borderRadiusLg,
        child: Row(
          children: [
            // ── File type icon ────────────────────────────────
            _FileIcon(type: item.type),
            const SizedBox(width: AppSpacing.md),

            // ── Info ──────────────────────────────────────────
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.title,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: AppSpacing.xs),
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
                    const SizedBox(height: AppSpacing.xs),
                    _SyncBadge(isPending: isPending),
                  ],
                ],
              ),
            ),
            const SizedBox(width: AppSpacing.sm),

            // ── Share button ──────────────────────────────────
            PressableScale(
              onTap: onShare,
              child: Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.08),
                  borderRadius: AppRadius.borderRadiusSm,
                ),
                child: const Icon(
                  Icons.ios_share_rounded,
                  size: 18,
                  color: AppColors.primary,
                ),
              ),
            ),
          ],
        ),
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
    final color = isPending ? AppColors.warning : AppColors.success;
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: AppSpacing.xxs,
      ),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.10),
        borderRadius: AppRadius.borderRadiusPill,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            isPending ? Icons.cloud_upload_outlined : Icons.cloud_done_rounded,
            size: 12,
            color: color,
          ),
          const SizedBox(width: AppSpacing.xs),
          Text(
            isPending ? 'Ausstehend' : 'Gespeichert',
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}

// ── File icon ────────────────────────────────────────────────────────────────

class _FileIcon extends StatelessWidget {
  const _FileIcon({required this.type});

  final DocumentType type;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 48,
      height: 56,
      decoration: BoxDecoration(
        color: type.color.withValues(alpha: 0.08),
        borderRadius: AppRadius.borderRadiusMd,
        border: Border.all(
          color: type.color.withValues(alpha: 0.15),
          width: 0.5,
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.picture_as_pdf_rounded, size: 22, color: type.color),
          const SizedBox(height: AppSpacing.xxs),
          Text(
            'PDF',
            style: TextStyle(
              fontSize: 9,
              fontWeight: FontWeight.w700,
              color: type.color,
              letterSpacing: 0.5,
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
        horizontal: AppSpacing.sm,
        vertical: AppSpacing.xxs,
      ),
      decoration: BoxDecoration(
        color: type.color.withValues(alpha: 0.10),
        borderRadius: AppRadius.borderRadiusPill,
      ),
      child: Text(
        type.label,
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w600,
          color: type.color,
        ),
      ),
    );
  }
}

// ── Document preview screen ──────────────────────────────────────────────────

class _DocumentPreviewScreen extends StatelessWidget {
  const _DocumentPreviewScreen({
    required this.item,
    required this.onDelete,
  });

  final DocumentItem item;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    return GlassPage(
      title: item.title,
      titleEmoji: '📎',
      titleColor: item.type.color,
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Share
          PressableScale(
            onTap: item.localPath != null
                ? () => _shareFile(context)
                : null,
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: AppRadius.borderRadiusSm,
                boxShadow: const [
                  BoxShadow(
                    color: Color(0x14000000),
                    blurRadius: 8,
                    offset: Offset(0, 2),
                  ),
                ],
              ),
              child: Icon(
                Icons.ios_share_outlined,
                size: 20,
                color: item.localPath != null
                    ? AppColors.primary
                    : AppColors.textSecondary,
              ),
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          // Delete
          PressableScale(
            onTap: () => _confirmDelete(context),
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: AppRadius.borderRadiusSm,
                boxShadow: const [
                  BoxShadow(
                    color: Color(0x14000000),
                    blurRadius: 8,
                    offset: Offset(0, 2),
                  ),
                ],
              ),
              child: const Icon(
                Icons.delete_outline_rounded,
                size: 20,
                color: AppColors.error,
              ),
            ),
          ),
        ],
      ),
      children: [
        // ── Meta grid ────────────────────────────────────────
        Padding(
          padding: AppSpacing.paddingHorizontalXl,
          child: GlassContainer(
            padding: const EdgeInsets.all(AppSpacing.lg),
            borderRadius: AppRadius.borderRadiusMd,
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: _MetaTile(
                        icon: item.type.icon,
                        label: 'Typ',
                        value: item.type.label,
                        color: item.type.color,
                      ),
                    ),
                    Expanded(
                      child: _MetaTile(
                        icon: Icons.calendar_today_rounded,
                        label: 'Datum',
                        value: _formatDate(item.createdAt),
                        color: AppColors.primary,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.lg),
                Row(
                  children: [
                    Expanded(
                      child: _MetaTile(
                        icon: Icons.data_usage_rounded,
                        label: 'Größe',
                        value: _formatSize(item.sizeBytes),
                        color: AppColors.accent,
                      ),
                    ),
                    Expanded(
                      child: _MetaTile(
                        icon: item.metadata['syncState'] == 'synced'
                            ? Icons.cloud_done_rounded
                            : Icons.cloud_upload_outlined,
                        label: 'Status',
                        value: item.metadata['syncState'] == 'synced'
                            ? 'Gespeichert'
                            : item.metadata['syncState'] == 'pending'
                                ? 'Ausstehend'
                                : 'Lokal',
                        color: item.metadata['syncState'] == 'synced'
                            ? AppColors.success
                            : AppColors.warning,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: AppSpacing.xxl),

        // ── Preview placeholder ──────────────────────────────
        Padding(
          padding: AppSpacing.paddingHorizontalXl,
          child: GlassContainer(
            borderRadius: AppRadius.borderRadiusXl,
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.xxl,
              vertical: AppSpacing.huge,
            ),
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 72,
                    height: 72,
                    decoration: BoxDecoration(
                      color: item.type.color.withValues(alpha: 0.08),
                      borderRadius: AppRadius.borderRadiusXxl,
                    ),
                    child: Icon(
                      Icons.picture_as_pdf_rounded,
                      size: 36,
                      color: item.type.color,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xl),
                  Text(
                    'PDF Vorschau',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    _formatSize(item.sizeBytes),
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(height: AppSpacing.xxl),

        // ── Open button ──────────────────────────────────────
        Padding(
          padding: AppSpacing.paddingHorizontalXl,
          child: GlassButton(
            onPressed: item.localPath != null
                ? () => _shareFile(context)
                : null,
            label: 'Öffnen / Teilen',
            icon: Icons.open_in_new_rounded,
            expand: true,
          ),
        ),
      ],
    );
  }

  Future<void> _shareFile(BuildContext context) async {
    final path = item.localPath;
    if (path == null || path.trim().isEmpty) return;
    final file = File(path);
    if (!await file.exists()) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Datei nicht gefunden.')),
      );
      return;
    }
    await SharePlus.instance.share(
      ShareParams(files: <XFile>[XFile(path)], text: item.title),
    );
  }

  Future<void> _confirmDelete(BuildContext context) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Dokument löschen?'),
        content: Text('„${item.title}" wird unwiderruflich gelöscht.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Abbrechen'),
          ),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('Löschen', style: TextStyle(color: AppColors.error)),
          ),
        ],
      ),
    );
    if (confirm != true) return;
    onDelete();
    if (!context.mounted) return;
    Navigator.of(context).pop();
  }
}

// ── Meta tile for preview detail grid ────────────────────────────────────────

class _MetaTile extends StatelessWidget {
  const _MetaTile({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  final IconData icon;
  final String label;
  final String value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.10),
            borderRadius: AppRadius.borderRadiusSm,
          ),
          child: Icon(icon, size: 16, color: color),
        ),
        const SizedBox(width: AppSpacing.sm),
        Flexible(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w500,
                  color: AppColors.textSecondary,
                ),
              ),
              Text(
                value.isNotEmpty ? value : '–',
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ],
    );
  }
}
