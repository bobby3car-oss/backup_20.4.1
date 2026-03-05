import 'dart:io';

import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';

import '../../../ui/ui.dart';
import '../data/documents_repository_local.dart';
import '../domain/document_item.dart';

// ── Helpers ──────────────────────────────────────────────────────────────────

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

// ─────────────────────────────────────────────────────────────────────────────

class DocumentPreviewScreen extends StatelessWidget {
  const DocumentPreviewScreen({super.key, required this.item});

  final DocumentItem item;

  @override
  Widget build(BuildContext context) {
    final canShare =
        item.localPath != null && item.localPath!.trim().isNotEmpty;
    return GlassPage(
      title: item.title,
      titleEmoji: '📎',
      titleColor: item.type.color,
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Share
          PressableScale(
            onTap: canShare ? () => _shareLocalFile(context, item) : null,
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
                color: canShare ? AppColors.primary : AppColors.textSecondary,
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
            onPressed: canShare ? () => _shareLocalFile(context, item) : null,
            label: 'Öffnen / Teilen',
            icon: Icons.open_in_new_rounded,
            expand: true,
          ),
        ),
      ],
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
            child: const Text(
              'Löschen',
              style: TextStyle(color: AppColors.error),
            ),
          ),
        ],
      ),
    );
    if (confirm != true) return;
    await DocumentsRepositoryLocal.instance.delete(item.id);
    if (!context.mounted) return;
    Navigator.of(context).pop();
  }
}

Future<void> _shareLocalFile(BuildContext context, DocumentItem item) async {
  final path = item.localPath;
  if (path == null || path.trim().isEmpty) return;

  final file = File(path);
  if (!await file.exists()) {
    if (!context.mounted) return;
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Datei nicht gefunden.')));
    return;
  }

  await SharePlus.instance.share(
    ShareParams(files: <XFile>[XFile(path)], text: item.title),
  );
}

// ── Meta tile ────────────────────────────────────────────────────────────────

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
