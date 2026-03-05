import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:share_plus/share_plus.dart';

import '../../../ui/ui.dart';
import '../../medication/data/medication_repository_local.dart';
import '../../medication/domain/medication_intake.dart';
import '../../pain/data/pain_repository_local.dart';
import '../../pain/domain/pain_entry.dart';
import '../../photos/data/photos_repository_local.dart';
import '../../photos/domain/photo_entry.dart';
import '../../vitals/data/vital_repository_local.dart';
import '../../vitals/domain/vital_entry.dart';
import '../../wound/data/wound_repository_local.dart';
import '../../wound/domain/wound_entry.dart';

// ---------------------------------------------------------------------------
// Data model
// ---------------------------------------------------------------------------

class _ReportData {
  const _ReportData({
    required this.opArt,
    required this.opDate,
    required this.daysPostOp,
    required this.modus,
    required this.painAvg,
    required this.painTrend,
    required this.painEntries,
    required this.latestVital,
    required this.medications,
    required this.woundEntries,
    required this.woundPhotos,
  });

  final String opArt;
  final DateTime? opDate;
  final int? daysPostOp;
  final String modus;

  final double? painAvg;
  final String painTrend; // ↑ ↓ →
  final List<PainEntry> painEntries;

  final VitalEntry? latestVital;

  final List<MedicationIntake> medications;

  final List<WoundEntry> woundEntries;
  final List<PhotoEntry> woundPhotos;
}

// ---------------------------------------------------------------------------
// Screen
// ---------------------------------------------------------------------------

class ReportScreen extends StatefulWidget {
  const ReportScreen({super.key});

  @override
  State<ReportScreen> createState() => _ReportScreenState();
}

class _ReportScreenState extends State<ReportScreen> {
  _ReportData? _data;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);

    // --- Pain (last 7 days) --------------------------------------------------
    final painRepo = PainRepositoryLocal.instance;
    await painRepo.loadFromDisk();
    final allPain = await painRepo.watchAll().first;
    final now = DateTime.now();
    final sevenAgo = now.subtract(const Duration(days: 7));
    final recentPain =
        allPain
            .where((e) => !e.occurredAt.isBefore(sevenAgo))
            .toList(growable: false)
          ..sort((a, b) => a.occurredAt.compareTo(b.occurredAt));

    double? painAvg;
    String painTrend = '→';
    if (recentPain.isNotEmpty) {
      final levels = recentPain.map((e) => e.painLevel).toList();
      painAvg = levels.reduce((a, b) => a + b) / levels.length;
      if (levels.length >= 2) {
        final firstHalf = levels.sublist(0, levels.length ~/ 2);
        final secondHalf = levels.sublist(levels.length ~/ 2);
        final avgFirst = firstHalf.reduce((a, b) => a + b) / firstHalf.length;
        final avgSecond =
            secondHalf.reduce((a, b) => a + b) / secondHalf.length;
        if (avgSecond - avgFirst > 0.5) {
          painTrend = '↑ steigend';
        } else if (avgFirst - avgSecond > 0.5) {
          painTrend = '↓ fallend';
        } else {
          painTrend = '→ stabil';
        }
      }
    }

    // --- Vitals --------------------------------------------------------------
    final vitalRepo = VitalRepositoryLocal.instance;
    await vitalRepo.loadFromDisk();
    final allVitals = await vitalRepo.watchAll().first;
    final latestVital = allVitals.isNotEmpty ? allVitals.first : null;

    // --- Medication ----------------------------------------------------------
    final medRepo = MedicationRepositoryLocal.instance;
    await medRepo.loadFromDisk();
    final allMeds = await medRepo.watchAll().first;
    final activeMeds = allMeds
        .where((m) => !m.isDeleted)
        .toList(growable: false);

    // --- Wound / Photos ------------------------------------------------------
    final woundRepo = WoundRepositoryLocal.instance;
    await woundRepo.loadFromDisk();
    final allWounds = await woundRepo.watchAll().first;
    final latestWounds = allWounds.take(3).toList(growable: false);

    final photoRepo = PhotosRepositoryLocal.instance;
    await photoRepo.loadFromDisk();
    final allPhotos = await photoRepo.watchAll().first;
    final woundPhotos = allPhotos
        .where((p) => p.category == PhotoCategory.wound && p.deletedAt == null)
        .take(4)
        .toList(growable: false);

    // --- OP details (placeholder – real config comes from patient profile) ----
    DateTime? opDate;
    int? daysPostOp;
    // Try to derive from wound entries or metadata — best-effort
    // In a real app this comes from Firestore `patients/{uid}`.
    // For now we show placeholder / "Nicht hinterlegt".

    setState(() {
      _data = _ReportData(
        opArt: 'Nicht hinterlegt',
        opDate: opDate,
        daysPostOp: daysPostOp,
        modus: 'Nicht hinterlegt',
        painAvg: painAvg,
        painTrend: painTrend,
        painEntries: recentPain,
        latestVital: latestVital,
        medications: activeMeds,
        woundEntries: latestWounds,
        woundPhotos: woundPhotos,
      );
      _loading = false;
    });
  }

  // ---------------------------------------------------------------------------
  // Text report builder
  // ---------------------------------------------------------------------------
  String _buildTextReport(_ReportData d) {
    final buf = StringBuffer();
    buf.writeln('👨‍⚕️ KURZBERICHT');
    buf.writeln('Erstellt: ${_fmtDate(DateTime.now())}');
    buf.writeln();

    buf.writeln('📋 OP-DETAILS');
    buf.writeln('  Art:           ${d.opArt}');
    buf.writeln(
      '  Datum:         ${d.opDate != null ? _fmtDate(d.opDate!) : "–"}',
    );
    buf.writeln('  Tage post-OP:  ${d.daysPostOp ?? "–"}');
    buf.writeln('  Modus:         ${d.modus}');
    buf.writeln();

    buf.writeln('📊 SCHMERZTREND (letzte 7 Tage)');
    buf.writeln(
      '  Durchschnitt:  ${d.painAvg != null ? d.painAvg!.toStringAsFixed(1) : "–"}/10',
    );
    buf.writeln('  Tendenz:       ${d.painTrend}');
    buf.writeln();

    buf.writeln('❤️ LETZTE VITALWERTE');
    if (d.latestVital != null) {
      final v = d.latestVital!;
      buf.writeln('  Blutdruck:  ${v.systolic}/${v.diastolic} mmHg');
      buf.writeln('  Puls:       ${v.pulse} bpm');
      buf.writeln('  Gemessen:   ${_fmtDateTime(v.createdAt)}');
    } else {
      buf.writeln('  Noch keine Messung');
    }
    buf.writeln();

    buf.writeln('💊 MEDIKAMENTENPLAN');
    if (d.medications.isEmpty) {
      buf.writeln('  Keine Einnahmen erfasst');
    } else {
      final unique = <String, MedicationIntake>{};
      for (final m in d.medications) {
        unique.putIfAbsent(m.name, () => m);
      }
      for (final m in unique.values) {
        buf.writeln('  • ${m.name}${m.dose != null ? " – ${m.dose}" : ""}');
      }
    }
    buf.writeln();

    buf.writeln('📸 WUNDDOKUMENTATION');
    if (d.woundEntries.isEmpty) {
      buf.writeln('  Keine Einträge');
    } else {
      for (final w in d.woundEntries) {
        buf.writeln(
          '  • ${_fmtDate(w.createdAt)} · Schmerz ${w.pain}/10'
          '${w.note.trim().isNotEmpty ? " · ${w.note.trim()}" : ""}',
        );
      }
    }

    return buf.toString();
  }

  // ---------------------------------------------------------------------------
  // Actions
  // ---------------------------------------------------------------------------
  void _copyToClipboard() {
    if (_data == null) return;
    final text = _buildTextReport(_data!);
    Clipboard.setData(ClipboardData(text: text));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Bericht in Zwischenablage kopiert'),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  Future<void> _sendEmail() async {
    if (_data == null) return;
    final text = _buildTextReport(_data!);
    await SharePlus.instance.share(
      ShareParams(
        text: text,
        subject: '👨‍⚕️ Kurzbericht – ${_fmtDate(DateTime.now())}',
      ),
    );
  }

  Future<void> _fullExport() async {
    if (_data == null) return;
    final text = _buildTextReport(_data!);
    await SharePlus.instance.share(
      ShareParams(
        text: text,
        subject:
            '👨‍⚕️ Vollständiger Kurzbericht – ${_fmtDate(DateTime.now())}',
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Build
  // ---------------------------------------------------------------------------
  @override
  Widget build(BuildContext context) {
    return GlassPage(
      title: 'Kurzbericht',
      titleEmoji: '👨‍⚕️',
      titleColor: const Color(0xFF00C7BE),
      trailing: PressableScale(
        onTap: _load,
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
          child: const Icon(
            Icons.refresh_rounded,
            size: 20,
            color: AppColors.primary,
          ),
        ),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator.adaptive())
          : _buildBody(),
    );
  }

  Widget _buildBody() {
    final d = _data!;
    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 40),
      physics: const BouncingScrollPhysics(
        parent: AlwaysScrollableScrollPhysics(),
      ),
      children: [
        // --- Header ----------------------------------------------------------
        Text(
          '👨‍⚕️ Kurzbericht',
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          'Offline-tauglich für Arztgespräche',
          style: Theme.of(
            context,
          ).textTheme.bodyMedium?.copyWith(color: AppColors.textSecondary),
        ),
        const SizedBox(height: 20),

        // --- Button Row ------------------------------------------------------
        Row(
          children: [
            Expanded(
              child: SizedBox(
                height: 52,
                child: ElevatedButton(
                  onPressed: _copyToClipboard,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    shape: const StadiumBorder(),
                    elevation: 0,
                  ),
                  child: const Text(
                    '📋 Als Text kopieren',
                    style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: SizedBox(
                height: 52,
                child: OutlinedButton(
                  onPressed: _sendEmail,
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.textPrimary,
                    backgroundColor: Colors.white,
                    side: const BorderSide(color: AppColors.primary),
                    shape: const StadiumBorder(),
                    elevation: 0,
                  ),
                  child: const Text(
                    '✉️ Per E-Mail senden',
                    style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
                  ),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 24),

        // --- 1) OP-Details ---------------------------------------------------
        _OutlinedSection(
          title: '📋 OP-Details',
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _KVRow(label: 'Art', value: d.opArt),
              _KVRow(
                label: 'Datum',
                value: d.opDate != null ? _fmtDate(d.opDate!) : '–',
              ),
              _KVRow(
                label: 'Tage post-OP',
                value: d.daysPostOp != null ? '${d.daysPostOp}' : '–',
              ),
              _KVRow(label: 'Modus', value: d.modus),
            ],
          ),
        ),
        const SizedBox(height: 14),

        // --- 2) Schmerztrend -------------------------------------------------
        _OutlinedSection(
          title: '📊 Schmerztrend (letzte 7 Tage)',
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _KVRow(
                label: 'Durchschnitt',
                value: d.painAvg != null
                    ? '${d.painAvg!.toStringAsFixed(1)} / 10'
                    : 'Keine Daten',
              ),
              _KVRow(label: 'Tendenz', value: d.painTrend),
              if (d.painEntries.isNotEmpty) ...[
                const SizedBox(height: 8),
                SizedBox(
                  height: 40,
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: d.painEntries.map((e) {
                      final frac = e.painLevel / 10.0;
                      return Expanded(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 2),
                          child: FractionallySizedBox(
                            heightFactor: frac.clamp(0.08, 1.0),
                            alignment: Alignment.bottomCenter,
                            child: Container(
                              decoration: BoxDecoration(
                                color: _painColor(e.painLevel),
                                borderRadius: BorderRadius.circular(4),
                              ),
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ],
            ],
          ),
        ),
        const SizedBox(height: 14),

        // --- 3) Letzte Vitalwerte --------------------------------------------
        _OutlinedSection(
          title: '❤️ Letzte Vitalwerte',
          child: d.latestVital != null
              ? Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _KVRow(
                      label: 'Blutdruck',
                      value:
                          '${d.latestVital!.systolic}/${d.latestVital!.diastolic} mmHg',
                    ),
                    _KVRow(label: 'Puls', value: '${d.latestVital!.pulse} bpm'),
                    _KVRow(
                      label: 'Gemessen',
                      value: _fmtDateTime(d.latestVital!.createdAt),
                    ),
                  ],
                )
              : const Text(
                  'Noch keine Messung',
                  style: TextStyle(color: AppColors.textSecondary),
                ),
        ),
        const SizedBox(height: 14),

        // --- 4) Medikamentenplan ---------------------------------------------
        _OutlinedSection(
          title: '💊 Medikamentenplan',
          child: d.medications.isEmpty
              ? const Text(
                  'Keine Einnahmen erfasst',
                  style: TextStyle(color: AppColors.textSecondary),
                )
              : Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: _uniqueMeds(d.medications)
                      .map(
                        (m) => Padding(
                          padding: const EdgeInsets.only(bottom: 6),
                          child: Row(
                            children: [
                              const Text('💊 ', style: TextStyle(fontSize: 16)),
                              Expanded(
                                child: Text(
                                  '${m.name}${m.dose != null ? " – ${m.dose}" : ""}',
                                  style: const TextStyle(fontSize: 15),
                                ),
                              ),
                            ],
                          ),
                        ),
                      )
                      .toList(),
                ),
        ),
        const SizedBox(height: 14),

        // --- 5) Wunddokumentation --------------------------------------------
        _OutlinedSection(
          title: '📸 Wunddokumentation',
          child: d.woundEntries.isEmpty && d.woundPhotos.isEmpty
              ? const Text(
                  'Keine Einträge',
                  style: TextStyle(color: AppColors.textSecondary),
                )
              : Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // wound entries
                    for (final w in d.woundEntries)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: Row(
                          children: [
                            _WoundThumb(path: w.photoPath),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    _fmtDate(w.createdAt),
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w600,
                                      fontSize: 14,
                                    ),
                                  ),
                                  Text(
                                    'Schmerz: ${w.pain}/10'
                                    '${w.note.trim().isNotEmpty ? " · ${w.note.trim()}" : ""}',
                                    style: const TextStyle(
                                      color: AppColors.textSecondary,
                                      fontSize: 13,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    // photo thumbnails row if available
                    if (d.woundPhotos.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      SizedBox(
                        height: 64,
                        child: ListView.separated(
                          scrollDirection: Axis.horizontal,
                          itemCount: d.woundPhotos.length,
                          separatorBuilder: (_, __) => const SizedBox(width: 8),
                          itemBuilder: (_, i) =>
                              _WoundThumb(path: d.woundPhotos[i].localPath),
                        ),
                      ),
                    ],
                  ],
                ),
        ),
        const SizedBox(height: 28),

        // --- Vollständiger Export ---------------------------------------------
        SizedBox(
          height: 52,
          width: double.infinity,
          child: OutlinedButton(
            onPressed: _fullExport,
            style: OutlinedButton.styleFrom(
              foregroundColor: AppColors.textPrimary,
              backgroundColor: Colors.white,
              side: const BorderSide(color: AppColors.primary),
              shape: const StadiumBorder(),
              elevation: 0,
            ),
            child: const Text(
              '📤 Vollständiger Export',
              style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
            ),
          ),
        ),
      ],
    );
  }

  // ---------------------------------------------------------------------------
  // Helpers
  // ---------------------------------------------------------------------------

  List<MedicationIntake> _uniqueMeds(List<MedicationIntake> all) {
    final seen = <String, MedicationIntake>{};
    for (final m in all) {
      seen.putIfAbsent(m.name, () => m);
    }
    return seen.values.toList();
  }

  Color _painColor(int level) {
    if (level <= 3) return AppColors.success;
    if (level <= 6) return AppColors.warning;
    return AppColors.error;
  }

  static String _fmtDate(DateTime d) {
    final dd = d.day.toString().padLeft(2, '0');
    final mm = d.month.toString().padLeft(2, '0');
    return '$dd.$mm.${d.year}';
  }

  static String _fmtDateTime(DateTime d) {
    return '${_fmtDate(d)} ${d.hour.toString().padLeft(2, '0')}:${d.minute.toString().padLeft(2, '0')}';
  }
}

// =============================================================================
// Reusable widgets
// =============================================================================

class _OutlinedSection extends StatelessWidget {
  const _OutlinedSection({required this.title, required this.child});

  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.primary, width: 1),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0F000000),
            blurRadius: 24,
            offset: Offset(0, 4),
          ),
        ],
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 10),
          child,
        ],
      ),
    );
  }
}

class _KVRow extends StatelessWidget {
  const _KVRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: const TextStyle(
                fontSize: 14,
                color: AppColors.textSecondary,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: AppColors.textPrimary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _WoundThumb extends StatelessWidget {
  const _WoundThumb({required this.path});

  final String? path;

  @override
  Widget build(BuildContext context) {
    final value = path?.trim() ?? '';
    if (value.isEmpty) {
      return Container(
        width: 54,
        height: 54,
        decoration: BoxDecoration(
          color: AppColors.grey100,
          borderRadius: BorderRadius.circular(10),
        ),
        child: const Icon(
          Icons.image_not_supported_outlined,
          size: 18,
          color: AppColors.textSecondary,
        ),
      );
    }
    return ClipRRect(
      borderRadius: BorderRadius.circular(10),
      child: SizedBox(
        width: 54,
        height: 54,
        child: Image.file(
          File(value),
          fit: BoxFit.cover,
          errorBuilder: (_, __, ___) => Container(
            width: 54,
            height: 54,
            color: AppColors.grey100,
            child: const Icon(
              Icons.broken_image_outlined,
              size: 18,
              color: AppColors.textSecondary,
            ),
          ),
        ),
      ),
    );
  }
}
