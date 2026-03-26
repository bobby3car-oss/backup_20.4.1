import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';
import '../../../l10n/app_localizations.dart';

/// Generates a CSV string from the given [rows] and headers, then shares it.
Future<void> exportCsv({
  required BuildContext context,
  required String fileName,
  required List<String> headers,
  required List<List<String>> rows,
}) async {
  final buffer = StringBuffer();

  // BOM for Excel UTF-8 detection
  buffer.write('\uFEFF');

  // Header row
  buffer.writeln(headers.map(_escapeCsv).join(';'));

  // Data rows
  for (final row in rows) {
    buffer.writeln(row.map(_escapeCsv).join(';'));
  }

  final csv = buffer.toString();
  final bytes = utf8.encode(csv);

  await SharePlus.instance.share(
    ShareParams(
      files: [
        XFile.fromData(
          bytes,
          name: fileName,
          mimeType: 'text/csv',
        ),
      ],
    ),
  );

  if (context.mounted) {
    final l = AppLocalizations.of(context)!;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(l.csvExporting)),
    );
  }
}

String _escapeCsv(String value) {
  if (value.contains('"') || value.contains(';') || value.contains('\n')) {
    return '"${value.replaceAll('"', '""')}"';
  }
  return value;
}
