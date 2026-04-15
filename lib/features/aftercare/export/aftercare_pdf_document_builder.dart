import 'dart:typed_data';

import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

import 'aftercare_export_mapper.dart';
import 'aftercare_pdf_branding_resolver.dart';

class AftercarePdfDocumentBuilder {
  AftercarePdfDocumentBuilder._();

  static final DateFormat _date = DateFormat('dd.MM.yyyy');
  static final DateFormat _dateTime = DateFormat('dd.MM.yyyy HH:mm');

  static Future<Uint8List> buildPersonalized({
    required AftercarePlanPdfData data,
    required AftercarePdfBranding branding,
  }) async {
    final doc = pw.Document(
      title: 'Nachbehandlungsplan',
      author: branding.appTitle,
    );

    final logo = await _loadLogo(branding.logoUrl);

    doc.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(32),
        header: (ctx) => _header(
          ctx: ctx,
          branding: branding,
          logo: logo,
          title: 'Personalisierter Nachbehandlungsplan',
        ),
        footer: _footer,
        build: (ctx) => [
          _metaSection(
            title: data.title,
            rows: <(String, String)>[
              ('Status', data.status),
              ('Patient', data.patientName ?? 'Nicht hinterlegt'),
              ('OP-Datum', _date.format(data.surgeryDate)),
              ('Gültig ab', _date.format(data.effectiveFrom)),
              ('Behandelnder Arzt', data.doctorName ?? 'Nicht hinterlegt'),
              ('Organisation',
                  data.organizationName ?? branding.organizationName ?? 'Nicht hinterlegt'),
              ('Version', 'v${data.version}'),
              ('Erstellt', _dateTime.format(data.createdAt)),
              ('Aktualisiert', _dateTime.format(data.updatedAt)),
            ],
          ),
          pw.SizedBox(height: 14),
          ..._phaseWidgets(data.phases),
          pw.SizedBox(height: 12),
          _medicalHint(),
        ],
      ),
    );

    return doc.save();
  }

  static Future<Uint8List> buildBlankTemplate({
    required AftercareTemplatePdfData data,
    required AftercarePdfBranding branding,
  }) async {
    final doc = pw.Document(
      title: 'Nachbehandlungsvorlage',
      author: branding.appTitle,
    );

    final logo = await _loadLogo(branding.logoUrl);

    doc.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(32),
        header: (ctx) => _header(
          ctx: ctx,
          branding: branding,
          logo: logo,
          title: 'Blanko-Nachbehandlungsvorlage',
        ),
        footer: _footer,
        build: (ctx) => [
          _metaSection(
            title: data.title,
            rows: <(String, String)>[
              ('Vorlagentyp', data.templateType),
              ('Beschreibung', data.description.isNotEmpty ? data.description : '–'),
              ('OP-Art', data.surgeryType.isNotEmpty ? data.surgeryType : '–'),
              ('Körperregion', data.bodyRegion.isNotEmpty ? data.bodyRegion : '–'),
              ('Organisation',
                  data.organizationName ?? branding.organizationName ?? '–'),
              ('Version', 'v${data.version}'),
              ('Erstellt', _dateTime.format(data.createdAt)),
              ('Aktualisiert', _dateTime.format(data.updatedAt)),
            ],
          ),
          pw.SizedBox(height: 14),
          ..._phaseWidgets(data.phases),
        ],
      ),
    );

    return doc.save();
  }

  static Future<pw.ImageProvider?> _loadLogo(String? logoUrl) async {
    if (logoUrl == null || logoUrl.isEmpty) return null;
    try {
      return await networkImage(logoUrl)
          .timeout(const Duration(seconds: 8));
    } catch (_) {
      return null;
    }
  }

  static pw.Widget _header({
    required pw.Context ctx,
    required AftercarePdfBranding branding,
    required pw.ImageProvider? logo,
    required String title,
  }) {
    return pw.Container(
      margin: const pw.EdgeInsets.only(bottom: 14),
      padding: const pw.EdgeInsets.only(bottom: 8),
      decoration: const pw.BoxDecoration(
        border: pw.Border(bottom: pw.BorderSide(color: PdfColors.blue200)),
      ),
      child: pw.Row(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          pw.Expanded(
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text(
                  title,
                  style: pw.TextStyle(
                    fontSize: 18,
                    fontWeight: pw.FontWeight.bold,
                    color: PdfColors.blue900,
                  ),
                ),
                pw.SizedBox(height: 4),
                pw.Text(
                  branding.organizationName ?? branding.appTitle,
                  style: const pw.TextStyle(
                    fontSize: 10,
                    color: PdfColors.grey700,
                  ),
                ),
                for (final line in branding.contactLines.take(3))
                  pw.Text(
                    line,
                    style: const pw.TextStyle(
                      fontSize: 9,
                      color: PdfColors.grey600,
                    ),
                  ),
              ],
            ),
          ),
          if (logo != null)
            pw.Container(
              width: 52,
              height: 52,
              decoration: pw.BoxDecoration(
                border: pw.Border.all(color: PdfColors.grey300),
                borderRadius: pw.BorderRadius.circular(6),
              ),
              padding: const pw.EdgeInsets.all(4),
              child: pw.Image(logo, fit: pw.BoxFit.contain),
            ),
        ],
      ),
    );
  }

  static pw.Widget _footer(pw.Context ctx) {
    return pw.Container(
      margin: const pw.EdgeInsets.only(top: 8),
      padding: const pw.EdgeInsets.only(top: 5),
      decoration: const pw.BoxDecoration(
        border: pw.Border(top: pw.BorderSide(color: PdfColors.grey300)),
      ),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          pw.Text(
            'Operationsbegleiter',
            style: const pw.TextStyle(fontSize: 8, color: PdfColors.grey500),
          ),
          pw.Text(
            'Seite ${ctx.pageNumber}/${ctx.pagesCount}',
            style: const pw.TextStyle(fontSize: 8, color: PdfColors.grey500),
          ),
        ],
      ),
    );
  }

  static pw.Widget _metaSection({
    required String title,
    required List<(String, String)> rows,
  }) {
    return pw.Container(
      padding: const pw.EdgeInsets.all(10),
      decoration: pw.BoxDecoration(
        color: PdfColors.blue50,
        borderRadius: pw.BorderRadius.circular(6),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(
            title,
            style: pw.TextStyle(
              fontSize: 14,
              fontWeight: pw.FontWeight.bold,
              color: PdfColors.blue900,
            ),
          ),
          pw.SizedBox(height: 8),
          ...rows.map((e) => _kv(e.$1, e.$2)),
        ],
      ),
    );
  }

  static List<pw.Widget> _phaseWidgets(List<AftercarePdfPhase> phases) {
    if (phases.isEmpty) {
      return [
        pw.Text(
          'Keine Phasen vorhanden.',
          style: const pw.TextStyle(color: PdfColors.grey600, fontSize: 10),
        ),
      ];
    }

    final out = <pw.Widget>[];
    for (var i = 0; i < phases.length; i++) {
      final phase = phases[i];
      out.add(
        pw.Container(
          margin: const pw.EdgeInsets.only(bottom: 10),
          padding: const pw.EdgeInsets.all(10),
          decoration: pw.BoxDecoration(
            borderRadius: pw.BorderRadius.circular(6),
            border: pw.Border.all(color: PdfColors.grey300),
          ),
          child: pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text(
                'Phase ${i + 1}: ${phase.title}',
                style: pw.TextStyle(
                  fontSize: 12,
                  fontWeight: pw.FontWeight.bold,
                  color: PdfColors.grey900,
                ),
              ),
              pw.SizedBox(height: 2),
              pw.Text(
                phase.dayRangeLabel,
                style: const pw.TextStyle(fontSize: 9, color: PdfColors.grey700),
              ),
              pw.SizedBox(height: 8),
              if (phase.sections.isEmpty)
                pw.Text(
                  'Keine Einträge in dieser Phase.',
                  style: const pw.TextStyle(
                    fontSize: 9,
                    color: PdfColors.grey600,
                  ),
                ),
              for (final section in phase.sections) ...[
                pw.Container(
                  margin: const pw.EdgeInsets.only(bottom: 4),
                  padding: const pw.EdgeInsets.symmetric(
                    horizontal: 6,
                    vertical: 3,
                  ),
                  decoration: pw.BoxDecoration(
                    color: PdfColors.grey100,
                    borderRadius: pw.BorderRadius.circular(4),
                  ),
                  child: pw.Text(
                    section.category,
                    style: pw.TextStyle(
                      fontSize: 10,
                      fontWeight: pw.FontWeight.bold,
                      color: PdfColors.grey800,
                    ),
                  ),
                ),
                for (final item in section.items)
                  pw.Container(
                    margin: const pw.EdgeInsets.only(bottom: 5),
                    padding: const pw.EdgeInsets.only(left: 4),
                    child: pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        pw.Text(
                          '• ${item.title} (${item.timeLabel})',
                          style: pw.TextStyle(
                            fontSize: 9,
                            fontWeight: pw.FontWeight.bold,
                            color: PdfColors.grey900,
                          ),
                        ),
                        if (item.description.isNotEmpty)
                          pw.Text(
                            item.description,
                            style: const pw.TextStyle(
                              fontSize: 9,
                              color: PdfColors.grey700,
                            ),
                          ),
                        if (item.notes.isNotEmpty)
                          pw.Text(
                            'Hinweis: ${item.notes}',
                            style: const pw.TextStyle(
                              fontSize: 8,
                              color: PdfColors.grey600,
                            ),
                          ),
                      ],
                    ),
                  ),
              ],
            ],
          ),
        ),
      );
    }
    return out;
  }

  static pw.Widget _kv(String label, String value) {
    return pw.Padding(
      padding: const pw.EdgeInsets.symmetric(vertical: 1),
      child: pw.Row(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.SizedBox(
            width: 110,
            child: pw.Text(
              label,
              style: pw.TextStyle(
                fontSize: 9,
                fontWeight: pw.FontWeight.bold,
                color: PdfColors.grey800,
              ),
            ),
          ),
          pw.Expanded(
            child: pw.Text(
              value,
              style: const pw.TextStyle(fontSize: 9, color: PdfColors.grey900),
            ),
          ),
        ],
      ),
    );
  }

  static pw.Widget _medicalHint() {
    return pw.Container(
      padding: const pw.EdgeInsets.all(8),
      decoration: pw.BoxDecoration(
        color: PdfColors.amber50,
        borderRadius: pw.BorderRadius.circular(5),
        border: pw.Border.all(color: PdfColors.amber200),
      ),
      child: pw.Text(
        'Hinweis: Anpassungen der Nachbehandlung bitte stets im ärztlichen Gespräch abstimmen.',
        style: const pw.TextStyle(fontSize: 8, color: PdfColors.grey800),
      ),
    );
  }
}
