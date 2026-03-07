import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';

import '../../../../features/documents/domain/document_item.dart';
import '../../../../ui/ui.dart';
import '../../data/doctor_patient_repository.dart';

/// Doctor-facing document list for a patient, with upload capability.
class PatientDocumentsTab extends StatefulWidget {
  const PatientDocumentsTab({
    super.key,
    required this.patientId,
    this.canWrite = false,
  });

  final String patientId;
  final bool canWrite;

  @override
  State<PatientDocumentsTab> createState() => _PatientDocumentsTabState();
}

class _PatientDocumentsTabState extends State<PatientDocumentsTab>
    with AutomaticKeepAliveClientMixin {
  final _repo = DoctorPatientRepository();
  DocumentType? _activeFilter;
  bool _isUploading = false;

  @override
  bool get wantKeepAlive => true;

  String _formatDate(DateTime dt) =>
      '${dt.day.toString().padLeft(2, '0')}.${dt.month.toString().padLeft(2, '0')}.${dt.year}';

  IconData _docIcon(DocumentType type) => switch (type) {
        DocumentType.arztbrief => Icons.description_rounded,
        DocumentType.aufklaerung => Icons.fact_check_rounded,
        DocumentType.rezept => Icons.medication_rounded,
        DocumentType.befunde => Icons.biotech_rounded,
        DocumentType.sonstiges => Icons.insert_drive_file_rounded,
      };

  String _docLabel(DocumentType type) => switch (type) {
        DocumentType.arztbrief => 'Arztbrief',
        DocumentType.aufklaerung => 'Aufklärung',
        DocumentType.rezept => 'Rezept',
        DocumentType.befunde => 'Befunde',
        DocumentType.sonstiges => 'Sonstiges',
      };

  Color _docColor(DocumentType type) => switch (type) {
        DocumentType.arztbrief => AppColors.primary,
        DocumentType.aufklaerung => AppColors.warning,
        DocumentType.rezept => AppColors.success,
        DocumentType.befunde => AppColors.error,
        DocumentType.sonstiges => AppColors.grey600,
      };

  String _formatSize(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(0)} KB';
    return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return StreamBuilder<List<DocumentItem>>(
      stream: _repo.watchPatientDocuments(widget.patientId),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting &&
            !snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        final allDocs = snapshot.data ?? [];
        final filteredDocs = _activeFilter == null
            ? allDocs
            : allDocs.where((d) => d.type == _activeFilter).toList();

        return Column(
          children: [
            // ── Filter chips + upload button ──
            Padding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.md, AppSpacing.sm, AppSpacing.md, 0,
              ),
              child: Row(
                children: [
                  Expanded(
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: [
                          _FilterChip(
                            label: 'Alle (${allDocs.length})',
                            selected: _activeFilter == null,
                            onTap: () => setState(() => _activeFilter = null),
                          ),
                          for (final type in DocumentType.values)
                            if (allDocs.any((d) => d.type == type))
                              Padding(
                                padding: const EdgeInsets.only(left: 6),
                                child: _FilterChip(
                                  label: _docLabel(type),
                                  count: allDocs
                                      .where((d) => d.type == type)
                                      .length,
                                  selected: _activeFilter == type,
                                  color: _docColor(type),
                                  onTap: () => setState(() {
                                    _activeFilter =
                                        _activeFilter == type ? null : type;
                                  }),
                                ),
                              ),
                        ],
                      ),
                    ),
                  ),
                  if (widget.canWrite) ...[
                    const SizedBox(width: AppSpacing.sm),
                    _UploadButton(
                      isUploading: _isUploading,
                      onTap: _isUploading ? null : _startUpload,
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            // ── Document list ──
            Expanded(
              child: filteredDocs.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.folder_open_rounded,
                              size: 48, color: AppColors.grey400),
                          const SizedBox(height: AppSpacing.md),
                          Text(
                            allDocs.isEmpty
                                ? 'Keine Dokumente vorhanden'
                                : 'Keine Treffer für diesen Filter',
                            style:
                                TextStyle(color: AppColors.textSecondary),
                          ),
                          if (widget.canWrite && allDocs.isEmpty) ...[
                            const SizedBox(height: AppSpacing.lg),
                            FilledButton.icon(
                              onPressed: _isUploading ? null : _startUpload,
                              icon: const Icon(Icons.upload_file_rounded),
                              label: const Text('Dokument hochladen'),
                            ),
                          ],
                        ],
                      ),
                    )
                  : ListView.separated(
                      padding: AppSpacing.screenPadding,
                      itemCount: filteredDocs.length,
                      separatorBuilder: (_, _) =>
                          const SizedBox(height: AppSpacing.sm),
                      itemBuilder: (context, index) {
                        final doc = filteredDocs[index];
                        return _DocumentCard(
                          doc: doc,
                          docIcon: _docIcon(doc.type),
                          docLabel: _docLabel(doc.type),
                          docColor: _docColor(doc.type),
                          formatDate: _formatDate,
                          formatSize: _formatSize,
                        );
                      },
                    ),
            ),
          ],
        );
      },
    );
  }

  // ── Upload flow ──

  Future<void> _startUpload() async {
    if (_isUploading) return;

    final selectedType = await _showTypeSelector();
    if (selectedType == null || !mounted) return;

    setState(() => _isUploading = true);
    try {
      final picked = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: const ['pdf', 'jpg', 'jpeg', 'png'],
      );
      if (picked == null || picked.files.isEmpty || !mounted) return;

      final fileInfo = picked.files.single;
      final sourcePath = fileInfo.path;
      if (sourcePath == null || sourcePath.isEmpty) {
        _showSnack('Datei konnte nicht gelesen werden.');
        return;
      }

      final uid = FirebaseAuth.instance.currentUser?.uid;
      if (uid == null) return;

      final sourceFile = File(sourcePath);
      final sizeBytes = await sourceFile.length();
      final ext = sourcePath.split('.').last.toLowerCase();
      final mimeType = switch (ext) {
        'pdf' => 'application/pdf',
        'jpg' || 'jpeg' => 'image/jpeg',
        'png' => 'image/png',
        _ => 'application/octet-stream',
      };

      final id = 'doc_${DateTime.now().millisecondsSinceEpoch}_$uid';
      final storagePath =
          'patients/${widget.patientId}/documents/$id.$ext';
      final title = _defaultTitle(fileInfo.name);

      // Upload to Firebase Storage
      final ref = FirebaseStorage.instance.ref().child(storagePath);
      await ref.putFile(sourceFile, SettableMetadata(contentType: mimeType));
      final downloadUrl = await ref.getDownloadURL();

      final now = DateTime.now();
      final docItem = DocumentItem(
        id: id,
        ownerId: widget.patientId,
        type: selectedType,
        title: title,
        createdAt: now,
        updatedAt: now,
        storagePath: storagePath,
        downloadUrl: downloadUrl,
        mimeType: mimeType,
        sizeBytes: sizeBytes,
        uploadedBy: uid,
        uploadedByRole: 'doctor',
      );

      await FirebaseFirestore.instance
          .doc('patients/${widget.patientId}/documents/$id')
          .set(<String, dynamic>{
        ...docItem.toJson(),
        'updatedAt': FieldValue.serverTimestamp(),
        'serverUpdatedAt': FieldValue.serverTimestamp(),
      });

      if (mounted) _showSnack('Dokument „$title" hochgeladen ✓');
    } catch (e) {
      if (mounted) _showSnack('Upload fehlgeschlagen: $e');
    } finally {
      if (mounted) setState(() => _isUploading = false);
    }
  }

  String _defaultTitle(String rawName) {
    final trimmed = rawName.trim();
    if (trimmed.isEmpty) return 'Dokument';
    final dotIndex = trimmed.lastIndexOf('.');
    if (dotIndex > 0) return trimmed.substring(0, dotIndex);
    return trimmed;
  }

  void _showSnack(String msg) {
    ScaffoldMessenger.of(context)
      ..clearSnackBars()
      ..showSnackBar(SnackBar(content: Text(msg)));
  }

  Future<DocumentType?> _showTypeSelector() async {
    return showModalBottomSheet<DocumentType>(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: AppSpacing.lg),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 36,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.grey300,
                  borderRadius: AppRadius.borderRadiusPill,
                ),
              ),
              const SizedBox(height: AppSpacing.lg),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: AppSpacing.xl),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Dokumenttyp wählen',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
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
                      color: _docColor(type).withValues(alpha: 0.1),
                      borderRadius: AppRadius.borderRadiusSm,
                    ),
                    child: Icon(_docIcon(type), color: _docColor(type)),
                  ),
                  title: Text(_docLabel(type)),
                  onTap: () => Navigator.of(ctx).pop(type),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Private widgets ──

class _FilterChip extends StatelessWidget {
  const _FilterChip({
    required this.label,
    required this.selected,
    required this.onTap,
    this.count,
    this.color,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;
  final int? count;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final chipColor = color ?? AppColors.primary;
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(
          horizontal: 12,
          vertical: 6,
        ),
        decoration: BoxDecoration(
          color: selected
              ? chipColor.withValues(alpha: 0.15)
              : AppColors.grey200.withValues(alpha: 0.5),
          borderRadius: AppRadius.borderRadiusPill,
          border: Border.all(
            color: selected
                ? chipColor.withValues(alpha: 0.4)
                : Colors.transparent,
          ),
        ),
        child: Text(
          count != null ? '$label ($count)' : label,
          style: TextStyle(
            fontSize: 13,
            fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
            color: selected ? chipColor : AppColors.textSecondary,
          ),
        ),
      ),
    );
  }
}

class _UploadButton extends StatelessWidget {
  const _UploadButton({required this.isUploading, required this.onTap});

  final bool isUploading;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [AppColors.primary, AppColors.primaryDark],
          ),
          borderRadius: AppRadius.borderRadiusSm,
        ),
        child: isUploading
            ? const Padding(
                padding: EdgeInsets.all(8),
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation(Colors.white),
                ),
              )
            : const Icon(Icons.add_rounded, color: Colors.white, size: 20),
      ),
    );
  }
}

class _DocumentCard extends StatelessWidget {
  const _DocumentCard({
    required this.doc,
    required this.docIcon,
    required this.docLabel,
    required this.docColor,
    required this.formatDate,
    required this.formatSize,
  });

  final DocumentItem doc;
  final IconData docIcon;
  final String docLabel;
  final Color docColor;
  final String Function(DateTime) formatDate;
  final String Function(int) formatSize;

  @override
  Widget build(BuildContext context) {
    final isFromDoctor = doc.uploadedByRole == 'doctor';

    return GlassCard(
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: docColor.withValues(alpha: 0.1),
              borderRadius: AppRadius.borderRadiusSm,
            ),
            child: Icon(docIcon, color: docColor, size: 22),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  doc.title,
                  style: Theme.of(context)
                      .textTheme
                      .titleSmall
                      ?.copyWith(fontWeight: FontWeight.w500),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Row(
                  children: [
                    Text(
                      docLabel,
                      style: TextStyle(
                        fontSize: 12,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    Text(
                      formatDate(doc.createdAt),
                      style: TextStyle(
                        fontSize: 12,
                        color: AppColors.grey600,
                      ),
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    // Source badge
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 6,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: isFromDoctor
                            ? AppColors.primary.withValues(alpha: 0.1)
                            : AppColors.success.withValues(alpha: 0.1),
                        borderRadius: AppRadius.borderRadiusPill,
                      ),
                      child: Text(
                        isFromDoctor ? 'Arzt' : 'Patient',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                          color: isFromDoctor
                              ? AppColors.primary
                              : AppColors.success,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          if (doc.sizeBytes != null)
            Text(
              formatSize(doc.sizeBytes!),
              style: TextStyle(fontSize: 11, color: AppColors.grey600),
            ),
        ],
      ),
    );
  }
}
