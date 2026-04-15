import 'dart:typed_data';

import 'pdf_download_stub.dart'
    if (dart.library.js_interop) 'pdf_download_web.dart' as impl;

/// Downloads PDF bytes.
/// On web: triggers a browser download via Blob + anchor click.
/// On native: uses Printing.sharePdf to open the system share sheet.
Future<void> downloadPdfBytes(Uint8List bytes, String filename) {
  return impl.downloadPdfBytes(bytes, filename);
}
