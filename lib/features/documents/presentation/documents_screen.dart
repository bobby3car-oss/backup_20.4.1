import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';

import '../../../main.dart';
import '../../../ui/ui.dart';
import '../../pro/domain/pro_feature_gate.dart';
import '../../pro/domain/trigger_context.dart';
import '../../pro/presentation/smart_paywall.dart';
import '../data/documents_repository_local.dart';
import '../domain/document_item.dart';
import 'document_preview_screen.dart';

class DocumentsScreen extends StatefulWidget {
  const DocumentsScreen({super.key});

  @override
  State<DocumentsScreen> createState() => _DocumentsScreenState();
}

class _DocumentsScreenState extends State<DocumentsScreen> {
  final DocumentsRepositoryLocal _repository =
      DocumentsRepositoryLocal.instance;
  DocumentType? _activeFilter;
  bool _isUploading = false;

  @override
  void initState() {
    super.initState();
    // Retry any pending uploads on screen open.
    _retryPendingUploads();
  }

  @override
  Widget build(BuildContext context) {
    return GlassPage(
      title: 'Dokumente',
      titleEmoji: '📄',
      titleColor: AppColors.primary,
      trailing: PressableScale(
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
          child: const Icon(
            Icons.upload_file_rounded,
            size: 20,
            color: AppColors.primary,
          ),
        ),
      ),
      scrollableBody: (headerHeight) => StreamBuilder<List<DocumentItem>>(
        stream: _repository.watchAll(),
        builder: (context, snapshot) {
          final items = snapshot.data ?? const <DocumentItem>[];
          final filtered = _applyFilter(items);

          return Column(
            children: [
              SizedBox(height: headerHeight),
              _FilterRow(
                activeFilter: _activeFilter,
                onChanged: (type) {
                  setState(() {
                    _activeFilter = _activeFilter == type ? null : type;
                  });
                },
              ),
              const Divider(height: 1),
              Expanded(
                child: filtered.isEmpty
                    ? const Center(child: Text('Keine Dokumente vorhanden.'))
                    : ListView.builder(
                        physics: adaptiveScrollPhysics,
                        itemCount: filtered.length,
                        itemBuilder: (context, index) {
                          final item = filtered[index];
                          final hasLocal = item.localPath != null;
                          final isPending =
                              item.metadata['syncState'] == 'pending';
                          return Card(
                            margin: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 6,
                            ),
                            child: ListTile(
                              leading: Icon(
                                Icons.picture_as_pdf_rounded,
                                color: isPending
                                    ? Colors.orange
                                    : Colors.redAccent,
                              ),
                              title: Text(item.title),
                              subtitle: Text(
                                '${item.type.label} · ${_formatDate(item.createdAt)}\n'
                                '${isPending ? '⏳ Upload ausstehend' : hasLocal ? 'lokal gespeichert' : 'nur cloud'}',
                              ),
                              isThreeLine: true,
                              trailing: isPending
                                  ? IconButton(
                                      icon: const Icon(Icons.refresh_rounded),
                                      onPressed: () =>
                                          _retrySingleUpload(item),
                                    )
                                  : null,
                              onTap: () => _openItem(context, item),
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

  List<DocumentItem> _applyFilter(List<DocumentItem> source) {
    final filter = _activeFilter;
    if (filter == null) return source;
    return source.where((item) => item.type == filter).toList(growable: false);
  }

  void _openItem(BuildContext context, DocumentItem item) {
    if (item.localPath == null || item.localPath!.trim().isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('erst downloaden')));
      return;
    }
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => DocumentPreviewScreen(item: item),
      ),
    );
  }

  Future<void> _startUploadFlow() async {
    if (_isUploading) return;

    // ── Soft limit: free users can only store up to N documents ──
    final pro = ProServices.maybeOf(context);
    if (pro != null && !pro.entitlementService.isPro) {
      final currentCount =
          (await _repository.watchAll().first).length;
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
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Bitte zuerst anmelden.')));
      return;
    }

    final selectedType = await _selectType(context);
    if (selectedType == null) return;

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
        // TODO: Hook into generic sync service for deferred upload retry.
        final pendingItem = baseItem.copyWith(
          updatedAt: DateTime.now(),
          metadata: const <String, dynamic>{'syncState': 'pending'},
        );
        await _repository.upsert(pendingItem);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                'Upload fehlgeschlagen. Lokal als pending gespeichert.',
              ),
            ),
          );
        }
      }
    } finally {
      if (mounted) {
        setState(() => _isUploading = false);
      }
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

    final storagePath = item.storagePath ?? 'patients/$uid/documents/${item.id}.pdf';
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
      // Still offline – keep as pending.
    }
  }
}

class _FilterRow extends StatelessWidget {
  const _FilterRow({required this.activeFilter, required this.onChanged});

  final DocumentType? activeFilter;
  final ValueChanged<DocumentType> onChanged;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      child: Row(
        children: [
          for (final type in DocumentType.values) ...[
            Padding(
              padding: const EdgeInsets.only(right: 8),
              child: FilterChip(
                selected: activeFilter == type,
                label: Text(type.label),
                onSelected: (_) => onChanged(type),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

extension on DocumentType {
  String get label {
    switch (this) {
      case DocumentType.arztbrief:
        return 'Arztbrief';
      case DocumentType.aufklaerung:
        return 'Aufklaerung';
      case DocumentType.rezept:
        return 'Rezept';
      case DocumentType.befunde:
        return 'Befunde';
      case DocumentType.sonstiges:
        return 'Sonstiges';
    }
  }
}

String _formatDate(DateTime value) {
  final dd = value.day.toString().padLeft(2, '0');
  final mm = value.month.toString().padLeft(2, '0');
  final yyyy = value.year.toString().padLeft(4, '0');
  return '$dd.$mm.$yyyy';
}

Future<DocumentType?> _selectType(BuildContext context) async {
  return showDialog<DocumentType>(
    context: context,
    builder: (dialogContext) {
      return SimpleDialog(
        title: const Text('Dokumenttyp waehlen'),
        children: [
          for (final type in DocumentType.values)
            SimpleDialogOption(
              onPressed: () => Navigator.of(dialogContext).pop(type),
              child: Text(type.label),
            ),
        ],
      );
    },
  );
}

String _generateId() {
  final now = DateTime.now();
  final yyyy = now.year.toString().padLeft(4, '0');
  final mm = now.month.toString().padLeft(2, '0');
  final dd = now.day.toString().padLeft(2, '0');
  final hh = now.hour.toString().padLeft(2, '0');
  final min = now.minute.toString().padLeft(2, '0');
  final sec = now.second.toString().padLeft(2, '0');
  final us = now.microsecondsSinceEpoch.toString();
  return 'doc_$yyyy$mm$dd'
      '_$hh$min$sec'
      '_$us';
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
