import 'dart:typed_data';

import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

import '../medication/domain/medication_intake.dart';
import '../pain/domain/pain_entry.dart';
import '../vitals/domain/vital_entry.dart';
import '../wound/domain/wound_entry.dart';

/// Data transfer class for PDF generation.
class PdfReportData {
  const PdfReportData({
    required this.opArt,
    this.opDate,
    this.daysPostOp,
    required this.modus,
    this.painAvg,
    required this.painTrend,
    required this.painEntries,
    this.latestVital,
    required this.medications,
    required this.woundEntries,
  });

  final String opArt;
  final DateTime? opDate;
  final int? daysPostOp;
  final String modus;
  final double? painAvg;
  final String painTrend;
  final List<PainEntry> painEntries;
  final VitalEntry? latestVital;
  final List<MedicationIntake> medications;
  final List<WoundEntry> woundEntries;
}

/// Builds a PDF Uint8List from [PdfReportData].
class PdfReportBuilder {
  PdfReportBuilder._();

  static final _dateFmt = DateFormat('dd.MM.yyyy');
  static final _dateTimeFmt = DateFormat('dd.MM.yyyy HH:mm');

  static Future<Uint8List> build(PdfReportData d) async {
    final doc = pw.Document(
      title: 'Kurzbericht',
      author: 'Operationsbegleiter',
    );

    doc.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(40),
        header: (ctx) => _header(ctx),
        footer: (ctx) => _footer(ctx),
        build: (ctx) => [
          _opSection(d),
          pw.SizedBox(height: 14),
          _painSection(d),
          pw.SizedBox(height: 14),
          _vitalsSection(d),
          pw.SizedBox(height: 14),
          _medsSection(d),
          pw.SizedBox(height: 14),
          _woundSection(d),
        ],
      ),
    );

    return doc.save();
  }

  // ── Header / Footer ───────────────────────────────────────────────────────

  static pw.Widget _header(pw.Context ctx) {
    return pw.Container(
      margin: const pw.EdgeInsets.only(bottom: 16),
      padding: const pw.EdgeInsets.only(bottom: 8),
      decoration: const pw.BoxDecoration(
        border: pw.Border(
          bottom: pw.BorderSide(color: PdfColors.blue200, width: 1),
        ),
      ),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          pw.Text(
            'Kurzbericht',
            style: pw.TextStyle(
              fontSize: 20,
              fontWeight: pw.FontWeight.bold,
              color: PdfColors.blue800,
            ),
          ),
          pw.Text(
            'Erstellt: ${_dateFmt.format(DateTime.now())}',
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
            'Operationsbegleiter App',
            style: const pw.TextStyle(fontSize: 8, color: PdfColors.grey500),
          ),
          pw.Text(
            'Seite ${ctx.pageNumber} / ${ctx.pagesCount}',
            style: const pw.TextStyle(fontSize: 8, color: PdfColors.grey500),
          ),
        ],
      ),
    );
  }

  // ── Sections ──────────────────────────────────────────────────────────────

  static pw.Widget _sectionTitle(String title) {
    return pw.Container(
      margin: const pw.EdgeInsets.only(bottom: 6),
      padding: const pw.EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: pw.BoxDecoration(
        color: PdfColors.blue50,
        borderRadius: pw.BorderRadius.circular(4),
      ),
      child: pw.Text(
        title,
        style: pw.TextStyle(
          fontSize: 12,
          fontWeight: pw.FontWeight.bold,
          color: PdfColors.blue900,
        ),
      ),
    );
  }

  static pw.Widget _kv(String label, String value) {
    return pw.Padding(
      padding: const pw.EdgeInsets.symmetric(vertical: 2),
      child: pw.Row(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.SizedBox(
            width: 120,
            child: pw.Text(
              label,
              style: pw.TextStyle(
                fontSize: 10,
                fontWeight: pw.FontWeight.bold,
                color: PdfColors.grey700,
              ),
            ),
          ),
          pw.Expanded(
            child: pw.Text(
              value,
              style: const pw.TextStyle(fontSize: 10, color: PdfColors.grey900),
            ),
          ),
        ],
      ),
    );
  }

  // ── 1) OP Details ─────────────────────────────────────────────────────────

  static pw.Widget _opSection(PdfReportData d) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        _sectionTitle('OP-Details'),
        _kv('Art', d.opArt),
        _kv('Datum', d.opDate != null ? _dateFmt.format(d.opDate!) : '–'),
        _kv('Tage post-OP', d.daysPostOp != null ? '${d.daysPostOp}' : '–'),
        _kv('Modus', d.modus),
      ],
    );
  }

  // ── 2) Pain ───────────────────────────────────────────────────────────────

  static pw.Widget _painSection(PdfReportData d) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        _sectionTitle('Schmerztrend (letzte 7 Tage)'),
        _kv(
          'Durchschnitt',
          d.painAvg != null ? '${d.painAvg!.toStringAsFixed(1)}/10' : '–',
        ),
        _kv('Tendenz', d.painTrend),
        if (d.painEntries.isNotEmpty) ...[
          pw.SizedBox(height: 6),
          pw.TableHelper.fromTextArray(
            headerStyle: pw.TextStyle(
              fontSize: 9,
              fontWeight: pw.FontWeight.bold,
            ),
            cellStyle: const pw.TextStyle(fontSize: 9),
            headerDecoration: const pw.BoxDecoration(color: PdfColors.grey100),
            cellPadding:
                const pw.EdgeInsets.symmetric(horizontal: 6, vertical: 3),
            headers: ['Datum', 'Level', 'Ort', 'Notiz'],
            data: d.painEntries.take(5).map((e) {
              return [
                _dateTimeFmt.format(e.occurredAt),
                '${e.painLevel}/10',
                e.location ?? '–',
                e.note.length > 40
                    ? '${e.note.substring(0, 40)}…'
                    : (e.note.isEmpty ? '–' : e.note),
              ];
            }).toList(),
          ),
        ],
      ],
    );
  }

  // ── 3) Vitals ─────────────────────────────────────────────────────────────

  static pw.Widget _vitalsSection(PdfReportData d) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        _sectionTitle('Letzte Vitalwerte'),
        if (d.latestVital != null) ...[
          _kv(
            'Blutdruck',
            '${d.latestVital!.systolic}/${d.latestVital!.diastolic} mmHg',
          ),
          _kv('Puls', '${d.latestVital!.pulse} bpm'),
          _kv('Gemessen', _dateTimeFmt.format(d.latestVital!.createdAt)),
        ] else
          pw.Text(
            'Noch keine Messung',
            style: const pw.TextStyle(fontSize: 10, color: PdfColors.grey500),
          ),
      ],
    );
  }

  // ── 4) Medication ─────────────────────────────────────────────────────────

  static pw.Widget _medsSection(PdfReportData d) {
    final unique = <String, MedicationIntake>{};
    for (final m in d.medications) {
      unique.putIfAbsent(m.name, () => m);
    }

    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        _sectionTitle('Medikamentenplan'),
        if (unique.isEmpty)
          pw.Text(
            'Keine Einnahmen erfasst',
            style: const pw.TextStyle(fontSize: 10, color: PdfColors.grey500),
          )
        else
          ...unique.values.map(
            (m) => pw.Padding(
              padding: const pw.EdgeInsets.symmetric(vertical: 1),
              child: pw.Text(
                '• ${m.name}${m.dose != null ? " – ${m.dose}" : ""}',
                style: const pw.TextStyle(fontSize: 10),
              ),
            ),
          ),
      ],
    );
  }

  // ── 5) Wound ──────────────────────────────────────────────────────────────

  static pw.Widget _woundSection(PdfReportData d) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        _sectionTitle('Wunddokumentation'),
        if (d.woundEntries.isEmpty)
          pw.Text(
            'Keine Einträge',
            style: const pw.TextStyle(fontSize: 10, color: PdfColors.grey500),
          )
        else
          pw.TableHelper.fromTextArray(
            headerStyle: pw.TextStyle(
              fontSize: 9,
              fontWeight: pw.FontWeight.bold,
            ),
            cellStyle: const pw.TextStyle(fontSize: 9),
            headerDecoration: const pw.BoxDecoration(color: PdfColors.grey100),
            cellPadding:
                const pw.EdgeInsets.symmetric(horizontal: 6, vertical: 3),
            headers: ['Datum', 'Schmerz', 'Ort', 'Notiz'],
            data: d.woundEntries.take(5).map((e) {
              return [
                _dateFmt.format(e.createdAt),
                '${e.pain}/10',
                e.bodyLocation ?? '–',
                e.note.length > 40
                    ? '${e.note.substring(0, 40)}…'
                    : (e.note.isEmpty ? '–' : e.note),
              ];
            }).toList(),
          ),
      ],
    );
  }
}
