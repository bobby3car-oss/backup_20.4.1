import 'dart:io';

import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';

import '../../../ui/ui.dart';
import '../domain/document_item.dart';

class DocumentPreviewScreen extends StatelessWidget {
  const DocumentPreviewScreen({super.key, required this.item});

  final DocumentItem item;

  @override
  Widget build(BuildContext context) {
    final localFileName = _localFileName(item.localPath);
    final canShare =
        item.localPath != null && item.localPath!.trim().isNotEmpty;
    return GlassPage(
      title: item.title,
      titleEmoji: '📎',
      titleColor: AppColors.primary,
      trailing: PressableScale(
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
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 520),
            child: Card(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.picture_as_pdf_rounded,
                      size: 52,
                      color: Colors.redAccent,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      item.title,
                      style: Theme.of(context).textTheme.titleMedium,
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      localFileName ?? 'Datei lokal vorhanden',
                      style: Theme.of(context).textTheme.bodySmall,
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'PDF Preview kommt als naechstes.',
                      style: Theme.of(context).textTheme.bodyMedium,
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
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

String? _localFileName(String? path) {
  if (path == null || path.trim().isEmpty) return null;
  return File(path).uri.pathSegments.isNotEmpty
      ? File(path).uri.pathSegments.last
      : path;
}
