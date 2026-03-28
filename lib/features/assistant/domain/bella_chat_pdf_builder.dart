import 'dart:typed_data';

import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

import 'chat_message.dart';


/// Builds a PDF from a list of Bella AI chat messages.
class BellaChatPdfBuilder {
  BellaChatPdfBuilder._();

  static final _timeFmt = DateFormat('dd.MM.yyyy HH:mm');

  static Future<Uint8List> build(List<ChatMessage> messages) async {
    final doc = pw.Document(
      title: 'Bella AI – Gesprächsexport',
      author: 'Operationsbegleiter',
    );

    doc.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(40),
        header: (ctx) => _header(ctx),
        footer: (ctx) => _footer(ctx),
        build: (ctx) => [
          for (final msg in messages) _messageTile(msg),
        ],
      ),
    );

    return doc.save();
  }

  static pw.Widget _header(pw.Context ctx) {
    return pw.Container(
      margin: const pw.EdgeInsets.only(bottom: 16),
      padding: const pw.EdgeInsets.only(bottom: 8),
      decoration: const pw.BoxDecoration(
        border: pw.Border(
          bottom: pw.BorderSide(color: PdfColors.pink200, width: 1),
        ),
      ),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          pw.Text(
            'Bella AI \u2013 Gespr\u00e4chsexport',
            style: pw.TextStyle(
              fontSize: 18,
              fontWeight: pw.FontWeight.bold,
              color: PdfColors.pink800,
            ),
          ),
          pw.Text(
            'Erstellt: ${_timeFmt.format(DateTime.now())}',
            style: const pw.TextStyle(fontSize: 9, color: PdfColors.grey600),
          ),
        ],
      ),
    );
  }

  static pw.Widget _footer(pw.Context ctx) {
    return pw.Container(
      margin: const pw.EdgeInsets.only(top: 8),
      padding: const pw.EdgeInsets.only(top: 6),
      decoration: const pw.BoxDecoration(
        border: pw.Border(
          top: pw.BorderSide(color: PdfColors.grey300, width: 0.5),
        ),
      ),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          pw.Text(
            'Operationsbegleiter \u2013 KI-generiert, kein medizinischer Rat.',
            style: const pw.TextStyle(fontSize: 7, color: PdfColors.grey500),
          ),
          pw.Text(
            'Seite ${ctx.pageNumber} / ${ctx.pagesCount}',
            style: const pw.TextStyle(fontSize: 7, color: PdfColors.grey500),
          ),
        ],
      ),
    );
  }

  static pw.Widget _messageTile(ChatMessage msg) {
    final isUser = msg.role == ChatRole.user;
    final roleLabel = isUser ? 'Du' : 'Bella AI \ud83d\udc30';
    final roleColor = isUser ? PdfColors.blue700 : PdfColors.pink700;
    final bgColor = isUser ? PdfColors.blue50 : PdfColors.pink50;

    return pw.Container(
      margin: const pw.EdgeInsets.only(bottom: 8),
      padding: const pw.EdgeInsets.all(10),
      decoration: pw.BoxDecoration(
        color: bgColor,
        borderRadius: pw.BorderRadius.circular(6),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
            children: [
              pw.Text(
                roleLabel,
                style: pw.TextStyle(
                  fontSize: 10,
                  fontWeight: pw.FontWeight.bold,
                  color: roleColor,
                ),
              ),
              pw.Text(
                _timeFmt.format(msg.timestamp),
                style:
                    const pw.TextStyle(fontSize: 8, color: PdfColors.grey500),
              ),
            ],
          ),
          pw.SizedBox(height: 4),
          pw.Text(
            msg.text,
            style: const pw.TextStyle(fontSize: 10, color: PdfColors.grey900),
          ),
        ],
      ),
    );
  }
}
