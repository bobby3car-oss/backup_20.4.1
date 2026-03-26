import 'dart:io';

import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';

import '../../../ui/ui.dart';
import '../data/documents_repository_local.dart';
import '../domain/document_item.dart';
import '../../../ui/theme/app_icons.dart';
import '../../../l10n/app_localizations.dart';

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
    final l = AppLocalizations.of(context)!;
    final canShare =
        item.localPath != null && item.localPath!.trim().isNotEmpty;
    return GlassPage(
      title: item.title,
      titleIcon: AppIcons.documents,
      titleColor: item.type.color,
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _HeaderActionButton(
            icon: Icons.ios_share_outlined,
            onTap: canShare ? () => _shareLocalFile(context, item) : null,
          ),
          const SizedBox(width: AppSpacing.sm),
          _HeaderActionButton(
            icon: Icons.delete_outline_rounded,
            onTap: () => _confirmDelete(context),
          ),
        ],
      ),
      children: [
        // ── Hero preview card ────────────────────────────────
        Padding(
          padding: AppSpacing.paddingHorizontalXl,
          child: FadeSlideIn(
            child: _PreviewHeroCard(item: item),
          ),
        ),
        const SizedBox(height: AppSpacing.xl),

        // ── Meta grid ────────────────────────────────────────
        Padding(
          padding: AppSpacing.paddingHorizontalXl,
          child: FadeSlideIn(
            delay: const Duration(milliseconds: 80),
            child: GlassContainer(
              padding: const EdgeInsets.all(AppSpacing.lg),
              borderRadius: AppRadius.borderRadiusLg,
              variant: GlassVariant.thick,
              elevation: GlassElevation.low,
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
                          label: l.status,
                          value: item.metadata['syncState'] == 'synced'
                              ? 'Synchronisiert'
                              : item.metadata['syncState'] == 'pending'
                                  ? l.pending
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
        ),
        const SizedBox(height: AppSpacing.xxl),

        // ── Open button ──────────────────────────────────────
        Padding(
          padding: AppSpacing.paddingHorizontalXl,
          child: FadeSlideIn(
            delay: const Duration(milliseconds: 160),
            child: GlassButton(
              onPressed: canShare
                  ? () => _shareLocalFile(context, item)
                  : null,
              label: 'Öffnen / Teilen',
              icon: Icons.open_in_new_rounded,
              expand: true,
            ),
          ),
        ),
      ],
    );
  }

  Future<void> _confirmDelete(BuildContext context) async {
    final l = AppLocalizations.of(context)!;
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l.documentDeleteConfirm),
        content: Text('„${item.title}" wird unwiderruflich gelöscht.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: Text(l.cancel),
          ),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: Text(
              l.delete,
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
    final l = AppLocalizations.of(context)!;
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(l.fileNotFound)),
    );
    return;
  }

  await SharePlus.instance.share(
    ShareParams(files: <XFile>[XFile(path)], text: item.title),
  );
}

// ═══════════════════════════════════════════════════════════════════════════════
//  PREMIUM  UI  COMPONENTS
// ═══════════════════════════════════════════════════════════════════════════════

// ── Header action button ─────────────────────────────────────────────────────

class _HeaderActionButton extends StatelessWidget {
  const _HeaderActionButton({
    required this.icon,
    required this.onTap,
  });

  final IconData icon;
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
          color: icon == Icons.delete_outline_rounded
              ? AppColors.error
              : onTap != null
                  ? AppColors.primary
                  : AppColors.textSecondary,
        ),
      ),
    );
  }
}

// ── Preview hero card ────────────────────────────────────────────────────────

class _PreviewHeroCard extends StatelessWidget {
  const _PreviewHeroCard({required this.item});

  final DocumentItem item;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.xxl,
        vertical: AppSpacing.huge,
      ),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            item.type.color.withValues(alpha: 0.08),
            item.type.color.withValues(alpha: 0.03),
            Colors.white.withValues(alpha: 0.90),
          ],
          stops: const [0.0, 0.4, 1.0],
        ),
        borderRadius: AppRadius.borderRadiusXl,
        border: Border.all(
          color: item.type.color.withValues(alpha: 0.12),
          width: 0.5,
        ),
        boxShadow: [
          BoxShadow(
            color: item.type.color.withValues(alpha: 0.08),
            blurRadius: 20,
            offset: const Offset(0, 6),
            spreadRadius: -4,
          ),
          const BoxShadow(
            color: Color(0x06000000),
            blurRadius: 12,
            offset: Offset(0, 2),
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
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  item.type.color,
                  item.type.color.withValues(alpha: 0.70),
                ],
              ),
              borderRadius: const BorderRadius.all(Radius.circular(22)),
              boxShadow: [
                BoxShadow(
                  color: item.type.color.withValues(alpha: 0.30),
                  blurRadius: 20,
                  offset: const Offset(0, 8),
                  spreadRadius: -4,
                ),
                BoxShadow(
                  color: item.type.color.withValues(alpha: 0.12),
                  blurRadius: 36,
                  offset: const Offset(0, 16),
                  spreadRadius: -8,
                ),
              ],
            ),
            child: const Icon(
              Icons.picture_as_pdf_rounded,
              size: 40,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: AppSpacing.xl),
          Text(
            item.title,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w800,
              color: AppColors.textPrimary,
              letterSpacing: -0.3,
            ),
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            '${item.type.label} · ${_formatSize(item.sizeBytes)}',
            style: const TextStyle(
              fontSize: 13,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
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
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                color.withValues(alpha: 0.14),
                color.withValues(alpha: 0.06),
              ],
            ),
            borderRadius: AppRadius.borderRadiusSm,
            border: Border.all(
              color: color.withValues(alpha: 0.12),
              width: 0.5,
            ),
          ),
          child: Icon(icon, size: 17, color: color),
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
                  fontWeight: FontWeight.w600,
                  color: AppColors.textSecondary,
                  letterSpacing: 0.3,
                ),
              ),
              const SizedBox(height: 1),
              Text(
                value.isNotEmpty ? value : '–',
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                  letterSpacing: -0.1,
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
