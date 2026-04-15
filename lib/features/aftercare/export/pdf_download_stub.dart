import 'dart:typed_data';

import 'package:printing/printing.dart';

/// Non-web: use Printing.sharePdf.
Future<void> downloadPdfBytes(Uint8List bytes, String filename) async {
  await Printing.sharePdf(bytes: bytes, filename: filename);
}
