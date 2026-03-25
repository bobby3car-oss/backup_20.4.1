import 'dart:io';
import 'dart:typed_data';

import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

import '../../nutrition/domain/nutrition_entry.dart';
import '../../pain/domain/pain_entry.dart';
import '../../red_flags/domain/red_flag.dart';
import '../../wound/domain/wound_entry.dart';
import '../domain/health_report_data.dart';

/// Builds a multi-page PDF document from [HealthReportData].
class HealthReportPdfBuilder {
  HealthReportPdfBuilder._();

  static final _dateFmt = DateFormat('dd.MM.yyyy');
  static final _timeFmt = DateFormat('dd.MM.yyyy HH:mm');

  static Future<Uint8List> build(HealthReportData data) async {
    // Pre-load wound images so we can embed them in the PDF.
    final woundImages = <WoundEntry, pw.MemoryImage>{};
    for (final entry in data.woundEntries) {
      final path = entry.photoPath;
      if (path == null || path.trim().isEmpty) continue;
      try {
        final file = File(path.trim());
        if (await file.exists()) {
          final bytes = await file.readAsBytes();
          // Skip extremely large images (> 5 MB) to keep PDF manageable.
          if (bytes.lengthInBytes <= 5 * 1024 * 1024) {
            woundImages[entry] = pw.MemoryImage(bytes);
          }
        }
      } catch (_) {
        // Skip photo if unreadable.
      }
    }

    final doc = pw.Document(
      title: 'Gesundheitsbericht',
      author: 'Operationsbegleiter',
    );

    doc.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(40),
        header: (ctx) => _header(ctx, data),
        footer: (ctx) => _footer(ctx),
        build: (ctx) => _buildSections(data, woundImages),
      ),
    );

    return doc.save();
  }

  // ── Header ──────────────────────────────────────────────────────────

  static pw.Widget _header(pw.Context ctx, HealthReportData data) {
    return pw.Container(
      margin: const pw.EdgeInsets.only(bottom: 16),
      padding: const pw.EdgeInsets.only(bottom: 10),
      decoration: const pw.BoxDecoration(
        border: pw.Border(
          bottom: pw.BorderSide(color: PdfColors.blue200, width: 1),
        ),
      ),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        crossAxisAlignment: pw.CrossAxisAlignment.end,
        children: [
          pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text(
                'Gesundheitsbericht',
                style: pw.TextStyle(
                  fontSize: 20,
                  fontWeight: pw.FontWeight.bold,
                  color: PdfColors.blue800,
                ),
              ),
              pw.SizedBox(height: 4),
              pw.Text(
                data.patientName,
                style: const pw.TextStyle(
                  fontSize: 12,
                  color: PdfColors.grey700,
                ),
              ),
            ],
          ),
          pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.end,
            children: [
              pw.Text(
                'Zeitraum: ${_dateFmt.format(data.from)} \u2013 ${_dateFmt.format(data.to)}',
                style: const pw.TextStyle(
                  fontSize: 9,
                  color: PdfColors.grey600,
                ),
              ),
              pw.SizedBox(height: 2),
              pw.Text(
                'Erstellt: ${_timeFmt.format(DateTime.now())}',
                style: const pw.TextStyle(
                  fontSize: 9,
                  color: PdfColors.grey600,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ── Footer ──────────────────────────────────────────────────────────

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
            'Erstellt mit Operationsbegleiter \u2013 kein Ersatz f\u00fcr \u00e4rztliche Beratung.',
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

  // ── Sections ────────────────────────────────────────────────────────

  static List<pw.Widget> _buildSections(
    HealthReportData data,
    Map<WoundEntry, pw.MemoryImage> woundImages,
  ) {
    final widgets = <pw.Widget>[];

    // Patient info summary
    widgets.add(_patientInfoSection(data));
    widgets.add(pw.SizedBox(height: 12));

    if (data.sections.contains(ReportSection.pain) &&
        data.painEntries.isNotEmpty) {
      widgets.addAll(_painSection(data));
    }

    if (data.sections.contains(ReportSection.vitals) &&
        data.vitalEntries.isNotEmpty) {
      widgets.addAll(_vitalsSection(data));
    }

    if (data.sections.contains(ReportSection.wounds) &&
        data.woundEntries.isNotEmpty) {
      widgets.addAll(_woundsSection(data, woundImages));
    }

    if (data.sections.contains(ReportSection.medication) &&
        data.medications.isNotEmpty) {
      widgets.addAll(_medicationSection(data));
    }

    if (data.sections.contains(ReportSection.nutrition) &&
        data.nutritionEntries.isNotEmpty) {
      widgets.addAll(_nutritionSection(data));
    }

    if (data.sections.contains(ReportSection.redFlags) &&
        data.redFlags.isNotEmpty) {
      widgets.addAll(_redFlagSection(data));
    }

    if (widgets.length <= 2) {
      widgets.add(pw.Padding(
        padding: const pw.EdgeInsets.only(top: 20),
        child: pw.Text(
          'Keine Daten im gew\u00e4hlten Zeitraum vorhanden.',
          style: const pw.TextStyle(
            fontSize: 12,
            color: PdfColors.grey600,
          ),
        ),
      ));
    }

    return widgets;
  }

  // ── Patient Info ────────────────────────────────────────────────────

  static pw.Widget _patientInfoSection(HealthReportData data) {
    return pw.Container(
      padding: const pw.EdgeInsets.all(12),
      decoration: pw.BoxDecoration(
        color: PdfColors.blue50,
        borderRadius: pw.BorderRadius.circular(6),
      ),
      child: pw.Row(
        children: [
          pw.Expanded(
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text(
                  'Patienteninformation',
                  style: pw.TextStyle(
                    fontSize: 14,
                    fontWeight: pw.FontWeight.bold,
                    color: PdfColors.blue900,
                  ),
                ),
                pw.SizedBox(height: 6),
                _infoRow('Name', data.patientName),
                _infoRow('Zeitraum',
                    '${_dateFmt.format(data.from)} \u2013 ${_dateFmt.format(data.to)}'),
                _infoRow('Eintr\u00e4ge gesamt', _totalEntries(data).toString()),
              ],
            ),
          ),
        ],
      ),
    );
  }

  static pw.Widget _infoRow(String label, String value) {
    return pw.Padding(
      padding: const pw.EdgeInsets.only(bottom: 2),
      child: pw.Row(
        children: [
          pw.SizedBox(
            width: 100,
            child: pw.Text(
              label,
              style: const pw.TextStyle(
                fontSize: 10,
                color: PdfColors.grey700,
              ),
            ),
          ),
          pw.Text(
            value,
            style: pw.TextStyle(
              fontSize: 10,
              fontWeight: pw.FontWeight.bold,
              color: PdfColors.grey900,
            ),
          ),
        ],
      ),
    );
  }

  static int _totalEntries(HealthReportData data) {
    return data.painEntries.length +
        data.vitalEntries.length +
        data.woundEntries.length +
        data.medications.length +
        data.nutritionEntries.length +
        data.redFlags.length;
  }

  // ── Pain ────────────────────────────────────────────────────────────

  static List<pw.Widget> _painSection(HealthReportData data) {
    final entries = data.painEntries;
    final avg = entries.fold(0, (sum, e) => sum + e.painLevel) / entries.length;
    final max = entries.fold(0, (m, e) => e.painLevel > m ? e.painLevel : m);

    return [
      _sectionTitle('Schmerzverlauf'),
      pw.Container(
        padding: const pw.EdgeInsets.all(10),
        decoration: pw.BoxDecoration(
          color: PdfColors.red50,
          borderRadius: pw.BorderRadius.circular(4),
        ),
        child: pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Row(
              children: [
                _statBox('\u00d8 Schmerzlevel', avg.toStringAsFixed(1)),
                pw.SizedBox(width: 16),
                _statBox('Maximum', max.toString()),
                pw.SizedBox(width: 16),
                _statBox('Eintr\u00e4ge', entries.length.toString()),
              ],
            ),
            pw.SizedBox(height: 10),
            // Simple text-based chart
            _painChart(entries),
          ],
        ),
      ),
      pw.SizedBox(height: 14),
    ];
  }

  static pw.Widget _painChart(List<PainEntry> entries) {
    // Show last 20 entries as horizontal bar indicators
    final display = entries.length > 20 ? entries.sublist(entries.length - 20) : entries;
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text(
          'Schmerzwerte (letzte ${display.length} Eintr\u00e4ge)',
          style: pw.TextStyle(fontSize: 9, fontWeight: pw.FontWeight.bold),
        ),
        pw.SizedBox(height: 6),
        for (final entry in display)
          pw.Padding(
            padding: const pw.EdgeInsets.only(bottom: 3),
            child: pw.Row(
              children: [
                pw.SizedBox(
                  width: 70,
                  child: pw.Text(
                    _dateFmt.format(entry.occurredAt),
                    style: const pw.TextStyle(fontSize: 7, color: PdfColors.grey600),
                  ),
                ),
                pw.Container(
                  width: (entry.painLevel / 10.0) * 200,
                  height: 8,
                  decoration: pw.BoxDecoration(
                    color: _painColor(entry.painLevel),
                    borderRadius: pw.BorderRadius.circular(2),
                  ),
                ),
                pw.SizedBox(width: 4),
                pw.Text(
                  '${entry.painLevel}',
                  style: const pw.TextStyle(fontSize: 7, color: PdfColors.grey700),
                ),
              ],
            ),
          ),
      ],
    );
  }

  static PdfColor _painColor(int level) {
    if (level <= 3) return PdfColors.green400;
    if (level <= 6) return PdfColors.orange400;
    return PdfColors.red400;
  }

  // ── Vitals ──────────────────────────────────────────────────────────

  static List<pw.Widget> _vitalsSection(HealthReportData data) {
    final entries = data.vitalEntries;
    return [
      _sectionTitle('Vitalwerte'),
      pw.TableHelper.fromTextArray(
        headerStyle: pw.TextStyle(fontSize: 9, fontWeight: pw.FontWeight.bold),
        cellStyle: const pw.TextStyle(fontSize: 8),
        headerDecoration: const pw.BoxDecoration(color: PdfColors.blue50),
        cellPadding: const pw.EdgeInsets.symmetric(horizontal: 6, vertical: 3),
        headers: [
          'Datum',
          'Systolisch',
          'Diastolisch',
          'Puls',
          'Temp.',
          'SpO\u2082',
          'Gewicht'
        ],
        data: entries
            .map((e) => [
                  _dateFmt.format(e.createdAt),
                  '${e.systolic} mmHg',
                  '${e.diastolic} mmHg',
                  '${e.pulse} bpm',
                  e.temperature != null ? '${e.temperature}\u00b0C' : '-',
                  e.oxygenSaturation != null ? '${e.oxygenSaturation}%' : '-',
                  e.weight != null ? '${e.weight} kg' : '-',
                ])
            .toList(),
      ),
      pw.SizedBox(height: 14),
    ];
  }

  // ── Wounds ──────────────────────────────────────────────────────────

  static List<pw.Widget> _woundsSection(
    HealthReportData data,
    Map<WoundEntry, pw.MemoryImage> woundImages,
  ) {
    // Show last 3 wound entries
    final entries = data.woundEntries;
    final display = entries.length > 3 ? entries.sublist(entries.length - 3) : entries;

    return [
      _sectionTitle('Wunddokumentation (letzte ${display.length} Eintr\u00e4ge)'),
      for (final entry in display)
        pw.Container(
          margin: const pw.EdgeInsets.only(bottom: 6),
          padding: const pw.EdgeInsets.all(8),
          decoration: pw.BoxDecoration(
            border: pw.Border.all(color: PdfColors.grey300, width: 0.5),
            borderRadius: pw.BorderRadius.circular(4),
          ),
          child: pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Text(
                    _timeFmt.format(entry.createdAt),
                    style: pw.TextStyle(
                      fontSize: 9,
                      fontWeight: pw.FontWeight.bold,
                    ),
                  ),
                  if (entry.bodyLocation != null)
                    pw.Text(
                      entry.bodyLocation!,
                      style: const pw.TextStyle(
                        fontSize: 9,
                        color: PdfColors.grey600,
                      ),
                    ),
                ],
              ),
              pw.SizedBox(height: 4),
              // Embed wound photo if available
              if (woundImages.containsKey(entry))
                pw.Center(
                  child: pw.Container(
                    margin: const pw.EdgeInsets.only(bottom: 6),
                    constraints: const pw.BoxConstraints(
                      maxWidth: 200,
                      maxHeight: 150,
                    ),
                    child: pw.Image(woundImages[entry]!),
                  ),
                ),
              pw.Text(
                'Schmerz: ${entry.pain}/10',
                style: const pw.TextStyle(fontSize: 9),
              ),
              if (entry.note.isNotEmpty) ...[
                pw.SizedBox(height: 2),
                pw.Text(
                  entry.note,
                  style: const pw.TextStyle(
                    fontSize: 9,
                    color: PdfColors.grey700,
                  ),
                ),
              ],
            ],
          ),
        ),
      pw.SizedBox(height: 14),
    ];
  }

  // ── Medication ──────────────────────────────────────────────────────

  static List<pw.Widget> _medicationSection(HealthReportData data) {
    return [
      _sectionTitle('Medikamenten-Liste'),
      pw.TableHelper.fromTextArray(
        headerStyle: pw.TextStyle(fontSize: 9, fontWeight: pw.FontWeight.bold),
        cellStyle: const pw.TextStyle(fontSize: 8),
        headerDecoration: const pw.BoxDecoration(color: PdfColors.purple50),
        cellPadding: const pw.EdgeInsets.symmetric(horizontal: 6, vertical: 3),
        headers: ['Medikament', 'Dosis', 'Zeiten', 'Notiz'],
        data: data.medications
            .map((e) {
              final times = e.enabledSlots.map((s) => s.label).join(', ');
              return [
                e.medicationName,
                e.dose ?? '-',
                times.isEmpty ? '-' : times,
                e.note ?? '-',
              ];
            })
            .toList(),
      ),
      pw.SizedBox(height: 14),
    ];
  }

  // ── Nutrition ───────────────────────────────────────────────────────

  static List<pw.Widget> _nutritionSection(HealthReportData data) {
    final entries = data.nutritionEntries;
    final totalCalories = entries.fold(0, (sum, e) => sum + (e.calories ?? 0));
    final totalWater = entries.fold(0, (sum, e) => sum + (e.waterMl ?? 0));
    final days = data.to.difference(data.from).inDays.clamp(1, 365);

    return [
      _sectionTitle('Ern\u00e4hrungs-Zusammenfassung'),
      pw.Container(
        padding: const pw.EdgeInsets.all(10),
        decoration: pw.BoxDecoration(
          color: PdfColors.green50,
          borderRadius: pw.BorderRadius.circular(4),
        ),
        child: pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Row(
              children: [
                _statBox('Eintr\u00e4ge', entries.length.toString()),
                pw.SizedBox(width: 16),
                _statBox('\u00d8 kcal/Tag',
                    (totalCalories / days).toStringAsFixed(0)),
                pw.SizedBox(width: 16),
                _statBox('\u00d8 Wasser/Tag',
                    '${(totalWater / days).toStringAsFixed(0)} ml'),
              ],
            ),
            pw.SizedBox(height: 8),
            // Symptoms summary
            if (_hasSymptoms(entries)) ...[
              pw.Text(
                'Gemeldete Symptome:',
                style: pw.TextStyle(
                  fontSize: 9,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
              pw.SizedBox(height: 4),
              pw.Wrap(
                spacing: 8,
                children: _symptomSummary(entries)
                    .entries
                    .map((e) => pw.Text(
                          '${_symptomLabel(e.key)} (${e.value}\u00d7)',
                          style: const pw.TextStyle(
                            fontSize: 8,
                            color: PdfColors.grey700,
                          ),
                        ))
                    .toList(),
              ),
            ],
          ],
        ),
      ),
      pw.SizedBox(height: 14),
    ];
  }

  static bool _hasSymptoms(List<NutritionEntry> entries) {
    return entries.any((e) => e.symptoms.isNotEmpty);
  }

  static Map<NutritionSymptom, int> _symptomSummary(
      List<NutritionEntry> entries) {
    final counts = <NutritionSymptom, int>{};
    for (final entry in entries) {
      for (final symptom in entry.symptoms) {
        counts[symptom] = (counts[symptom] ?? 0) + 1;
      }
    }
    return counts;
  }

  static String _symptomLabel(NutritionSymptom s) {
    return switch (s) {
      NutritionSymptom.uebelkeit => '\u00dcbelkeit',
      NutritionSymptom.blaehungen => 'Bl\u00e4hungen',
      NutritionSymptom.schmerzen => 'Schmerzen',
      NutritionSymptom.sodbrennen => 'Sodbrennen',
      NutritionSymptom.durchfall => 'Durchfall',
      NutritionSymptom.verstopfung => 'Verstopfung',
      NutritionSymptom.muedigkeit => 'M\u00fcdigkeit',
      NutritionSymptom.sonstige => 'Sonstige',
    };
  }

  // ── Red Flags ───────────────────────────────────────────────────────

  static List<pw.Widget> _redFlagSection(HealthReportData data) {
    return [
      _sectionTitle('Red Flags'),
      for (final flag in data.redFlags)
        pw.Container(
          margin: const pw.EdgeInsets.only(bottom: 6),
          padding: const pw.EdgeInsets.all(8),
          decoration: pw.BoxDecoration(
            color: _severityBg(flag.severity),
            borderRadius: pw.BorderRadius.circular(4),
            border: pw.Border.all(
              color: _severityBorder(flag.severity),
              width: 0.5,
            ),
          ),
          child: pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Expanded(
                    child: pw.Text(
                      flag.title,
                      style: pw.TextStyle(
                        fontSize: 10,
                        fontWeight: pw.FontWeight.bold,
                      ),
                    ),
                  ),
                  pw.Text(
                    _severityLabel(flag.severity),
                    style: pw.TextStyle(
                      fontSize: 8,
                      fontWeight: pw.FontWeight.bold,
                      color: _severityBorder(flag.severity),
                    ),
                  ),
                ],
              ),
              pw.SizedBox(height: 3),
              pw.Text(
                flag.summary,
                style: const pw.TextStyle(fontSize: 9, color: PdfColors.grey800),
              ),
              pw.SizedBox(height: 2),
              pw.Text(
                '${_timeFmt.format(flag.createdAt)} \u2013 Status: ${_statusLabel(flag.status)}',
                style: const pw.TextStyle(fontSize: 7, color: PdfColors.grey600),
              ),
            ],
          ),
        ),
      pw.SizedBox(height: 14),
    ];
  }

  static PdfColor _severityBg(RedFlagSeverity s) {
    return switch (s) {
      RedFlagSeverity.green => PdfColors.green50,
      RedFlagSeverity.yellow => PdfColors.amber50,
      RedFlagSeverity.orange => PdfColors.orange50,
      RedFlagSeverity.red => PdfColors.red50,
    };
  }

  static PdfColor _severityBorder(RedFlagSeverity s) {
    return switch (s) {
      RedFlagSeverity.green => PdfColors.green400,
      RedFlagSeverity.yellow => PdfColors.amber400,
      RedFlagSeverity.orange => PdfColors.orange400,
      RedFlagSeverity.red => PdfColors.red400,
    };
  }

  static String _severityLabel(RedFlagSeverity s) {
    return switch (s) {
      RedFlagSeverity.green => 'Gering',
      RedFlagSeverity.yellow => 'Mittel',
      RedFlagSeverity.orange => 'Erh\u00f6ht',
      RedFlagSeverity.red => 'Hoch',
    };
  }

  static String _statusLabel(RedFlagStatus s) {
    return switch (s) {
      RedFlagStatus.open => 'Offen',
      RedFlagStatus.acknowledged => 'Best\u00e4tigt',
      RedFlagStatus.monitoring => '\u00dcberwachung',
      RedFlagStatus.escalated => 'Eskaliert',
      RedFlagStatus.resolved => 'Gel\u00f6st',
    };
  }

  // ── Shared helpers ──────────────────────────────────────────────────

  static pw.Widget _sectionTitle(String title) {
    return pw.Padding(
      padding: const pw.EdgeInsets.only(bottom: 8),
      child: pw.Header(
        level: 1,
        child: pw.Text(
          title,
          style: pw.TextStyle(
            fontSize: 14,
            fontWeight: pw.FontWeight.bold,
          ),
        ),
      ),
    );
  }

  static pw.Widget _statBox(String label, String value) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text(
          label,
          style: const pw.TextStyle(fontSize: 7, color: PdfColors.grey600),
        ),
        pw.Text(
          value,
          style: pw.TextStyle(fontSize: 12, fontWeight: pw.FontWeight.bold),
        ),
      ],
    );
  }
}
