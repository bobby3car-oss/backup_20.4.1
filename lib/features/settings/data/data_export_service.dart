import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:share_plus/share_plus.dart';

import '../../../ui/error_helpers.dart';
import '../../appointments/data/appointments_repository_sync.dart';
import '../../medication/data/medication_repository_local.dart';
import '../../pain/data/pain_repository_local.dart';
import '../../questions/data/questions_repository_local.dart';
import '../../vitals/data/vital_repository_local.dart';
import '../../wound/data/wound_repository_local.dart';
import '../../../l10n/app_localizations.dart';

class DataExportService {
  DataExportService._();

  /// Shows a bottom sheet to choose export format (PDF / JSON).
  static Future<void> showExportSheet(BuildContext context) async {
    final l = AppLocalizations.of(context)!;
    final choice = await showModalBottomSheet<String>(
      context: context,
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 12),
            Container(
              width: 36,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              l.settingsExportData,
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 16),
            ListTile(
              leading: const Icon(Icons.picture_as_pdf_rounded,
                  color: Colors.redAccent),
              title: Text(l.exportAsPdf),
              subtitle: Text(l.exportAsPdfSubtitle),
              onTap: () => Navigator.pop(ctx, 'pdf'),
            ),
            ListTile(
              leading: const Icon(Icons.data_object_rounded,
                  color: Colors.blueAccent),
              title: Text(l.exportAsJson),
              subtitle: Text(l.exportAsJsonSubtitle),
              onTap: () => Navigator.pop(ctx, 'json'),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );

    if (choice == null || !context.mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(l.exportCreating)),
    );

    try {
      if (choice == 'json') {
        await _exportJson(context);
      } else {
        await _exportPdf(context);
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(userFacingError(e, fallback: l.exportFehlgeschlagen))),
        );
      }
    }
  }

  // ── JSON export ────────────────────────────────────────────────────────

  static Future<void> _exportJson(BuildContext context) async {
    final data = await _gatherAll();
    final jsonStr = const JsonEncoder.withIndent('  ').convert(data);

    final dir = await getTemporaryDirectory();
    final file = File(
      '${dir.path}/operationsbegleiter_export_'
      '${DateTime.now().millisecondsSinceEpoch}.json',
    );
    await file.writeAsString(jsonStr);

    await SharePlus.instance.share(
      ShareParams(files: [XFile(file.path, mimeType: 'application/json')]),
    );
  }

  // ── PDF export ─────────────────────────────────────────────────────────

  static Future<void> _exportPdf(BuildContext context) async {
    final data = await _gatherAll();
    final doc = pw.Document();

    doc.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        build: (pw.Context ctx) {
          final widgets = <pw.Widget>[
            pw.Header(
              level: 0,
              child: pw.Text(
                'Operationsbegleiter – Gesundheitsbericht',
                style: pw.TextStyle(
                  fontSize: 20,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
            ),
            pw.Text(
              'Erstellt am ${_fmtDate(DateTime.now())}',
              style: const pw.TextStyle(fontSize: 12),
            ),
            pw.SizedBox(height: 16),
          ];

          // Pain
          if (data['pain'] is List && (data['pain'] as List).isNotEmpty) {
            final painList = data['pain'] as List;
            widgets.add(_pdfSection('Schmerztagebuch'));
            for (final e in painList) {
              if (e is Map<String, dynamic>) {
                final note = e['note'] is String ? e['note'] as String : '';
                widgets.add(pw.Bullet(
                  text:
                      '${e['occurredAt'] ?? '-'}: Schmerz ${e['painLevel']}/10'
                      '${note.isNotEmpty ? ' \u2013 $note' : ''}',
                ));
              }
            }
            widgets.add(pw.SizedBox(height: 12));
          }

          // Vitals
          if (data['vitals'] is List && (data['vitals'] as List).isNotEmpty) {
            final vitalsList = data['vitals'] as List;
            widgets.add(_pdfSection('Vitalzeichen'));
            for (final e in vitalsList) {
              if (e is Map<String, dynamic>) {
                widgets.add(pw.Bullet(
                  text:
                      '${e['createdAt'] ?? '-'}: '
                      '${e['systolic'] ?? '-'}/${e['diastolic'] ?? '-'} mmHg, '
                      'Puls ${e['pulse'] ?? '-'} bpm',
                ));
              }
            }
            widgets.add(pw.SizedBox(height: 12));
          }

          // Medication
          if (data['medication'] is List &&
              (data['medication'] as List).isNotEmpty) {
            final medList = data['medication'] as List;
            widgets.add(_pdfSection('Medikamente'));
            for (final e in medList) {
              if (e is Map<String, dynamic>) {
                widgets.add(pw.Bullet(
                  text: '${e['name'] ?? '-'} \u00b7 ${e['dose'] ?? '-'}',
                ));
              }
            }
            widgets.add(pw.SizedBox(height: 12));
          }

          // Wounds
          if (data['wounds'] is List && (data['wounds'] as List).isNotEmpty) {
            final woundsList = data['wounds'] as List;
            widgets.add(_pdfSection('Wunddokumentation'));
            for (final e in woundsList) {
              if (e is Map<String, dynamic>) {
                widgets.add(pw.Bullet(
                  text:
                      '${e['createdAt'] ?? '-'}: ${e['note'] ?? 'Keine Notiz'}',
                ));
              }
            }
            widgets.add(pw.SizedBox(height: 12));
          }

          // Appointments
          if (data['appointments'] is List &&
              (data['appointments'] as List).isNotEmpty) {
            final apptList = data['appointments'] as List;
            widgets.add(_pdfSection('Termine'));
            for (final e in apptList) {
              if (e is Map<String, dynamic>) {
                widgets.add(pw.Bullet(
                  text: '${e['date'] ?? '-'}: ${e['title'] ?? '-'}',
                ));
              }
            }
            widgets.add(pw.SizedBox(height: 12));
          }

          // Questions
          if (data['questions'] is List &&
              (data['questions'] as List).isNotEmpty) {
            final questionsList = data['questions'] as List;
            widgets.add(_pdfSection('Arzt-Fragen'));
            for (final e in questionsList) {
              if (e is Map<String, dynamic>) {
                widgets.add(pw.Bullet(text: '${e['text'] ?? '-'}'));
              }
            }
          }

          return widgets;
        },
      ),
    );

    await Printing.sharePdf(
      bytes: await doc.save(),
      filename: 'operationsbegleiter_bericht.pdf',
    );
  }

  // ── Data gathering ─────────────────────────────────────────────────────

  static Future<Map<String, dynamic>> _gatherAll() async {
    final painRepo = PainRepositoryLocal.instance;
    await painRepo.loadFromDisk();
    final pain = await painRepo.watchAll().first;

    final vitalRepo = VitalRepositoryLocal.instance;
    await vitalRepo.loadFromDisk();
    final vitals = await vitalRepo.watchAll().first;

    final medRepo = MedicationRepositoryLocal.instance;
    await medRepo.loadFromDisk();
    final meds = await medRepo.watchAll().first;

    final woundRepo = WoundRepositoryLocal.instance;
    await woundRepo.loadFromDisk();
    final wounds = await woundRepo.watchAll().first;

    final apptRepo = AppointmentsRepositorySync.instance;
    final appointments = await apptRepo.watchAll().first;

    final qRepo = QuestionsRepositoryLocal.instance;
    await qRepo.loadFromDisk();
    final questions = await qRepo.watchAll().first;

    return <String, dynamic>{
      'exportedAt': DateTime.now().toIso8601String(),
      'pain': pain.map((e) => e.toJson()).toList(),
      'vitals': vitals.map((e) => e.toJson()).toList(),
      'medication': meds.map((e) => e.toJson()).toList(),
      'wounds': wounds.map((e) => e.toJson()).toList(),
      'appointments': appointments.map((e) => e.toJson()).toList(),
      'questions': questions.map((e) => e.toJson()).toList(),
    };
  }

  // ── Helpers ────────────────────────────────────────────────────────────

  static pw.Widget _pdfSection(String title) {
    return pw.Header(
      level: 1,
      child: pw.Text(title,
          style: pw.TextStyle(
            fontSize: 14,
            fontWeight: pw.FontWeight.bold,
          )),
    );
  }

  static String _fmtDate(DateTime d) =>
      '${d.day.toString().padLeft(2, '0')}.'
      '${d.month.toString().padLeft(2, '0')}.'
      '${d.year}';
}
