import 'dart:async';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:printing/printing.dart';
import 'package:share_plus/share_plus.dart';

import '../../../firebase/firebase_paths.dart';
import '../../../main.dart';
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
import '../../pro/domain/trigger_context.dart';
import '../../pro/presentation/pro_feature_gate_view.dart';
import '../../pro/presentation/smart_paywall.dart';
import '../pdf_report_builder.dart';

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

  bool get _isPro =>
      ProServices.maybeOf(context)?.entitlementService.isPro ?? false;

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

    // --- OP details from Firestore patient profile ----------------------------
    String opArt = 'Nicht hinterlegt';
    String modus = 'Nicht hinterlegt';
    DateTime? opDate;
    int? daysPostOp;

    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid != null) {
      try {
        final userDoc = await FirebaseFirestore.instance
            .doc(FirestorePaths.userDoc(uid))
            .get();
        final userData = userDoc.data();
        if (userData != null) {
          if (userData['opType'] is String &&
              (userData['opType'] as String).isNotEmpty) {
            opArt = userData['opType'] as String;
          }
          if (userData['opModus'] is String &&
              (userData['opModus'] as String).isNotEmpty) {
            modus = userData['opModus'] as String;
          }
          final rawDate = userData['opDate'];
          if (rawDate is Timestamp) {
            opDate = rawDate.toDate();
          } else if (rawDate is String && rawDate.isNotEmpty) {
            opDate = DateTime.tryParse(rawDate);
          }
          if (opDate != null) {
            daysPostOp = now.difference(opDate).inDays;
          }
        }
      } catch (_) {
        // Best-effort — fields stay at defaults.
      }
    }

    if (!mounted) return;
    setState(() {
      _data = _ReportData(
        opArt: opArt,
        opDate: opDate,
        daysPostOp: daysPostOp,
        modus: modus,
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

  Future<void> _sharePdf() async {
    if (_data == null) return;

    final d = _data!;
    final pdfData = PdfReportData(
      opArt: d.opArt,
      opDate: d.opDate,
      daysPostOp: d.daysPostOp,
      modus: d.modus,
      painAvg: d.painAvg,
      painTrend: d.painTrend,
      painEntries: d.painEntries,
      latestVital: d.latestVital,
      medications: d.medications,
      woundEntries: d.woundEntries,
    );
    final bytes = await PdfReportBuilder.build(pdfData);
    final date = DateFormat('yyyy-MM-dd').format(DateTime.now());
    await Printing.sharePdf(bytes: bytes, filename: 'Kurzbericht_$date.pdf');
  }

  // ---------------------------------------------------------------------------
  // Build
  // ---------------------------------------------------------------------------
  @override
  Widget build(BuildContext context) {
    if (!_isPro) {
      return ProFeatureGateView(
        pageTitle: 'Kurzbericht',
        pageEmoji: '👨‍⚕️',
        pageColor: const Color(0xFF00C7BE),
        heroEmoji: '📋',
        heroTitle: 'Dein Arzt verdient alle Infos auf einen Blick',
        heroSubtitle:
            'Stell dir vor: Beim nächsten Arzttermin hast du Schmerzverlauf, '
            'Vitalwerte und Medikamente in einem Bericht parat – '
            'statt hektisch in Notizen zu suchen.',
        primaryCta: '3 Tage kostenlos testen',
        onPrimaryTap: () {
          SmartPaywall.trigger(
            context: context,
            triggerContext: TriggerContext.arztberichtExport,
          );
        },
        benefits: const <(String, String)>[
          (
            'Sofort versandbereit',
            'Schicke deinem Arzt alle relevanten Infos als strukturierte Zusammenfassung – direkt vom Handy.',
          ),
          (
            'Keine Lücken mehr im Gespräch',
            'Schmerz, Medikamente, Wunde und Vitals gebündelt. Dein Arzt sieht sofort, was wichtig ist.',
          ),
          (
            'Vorbereitet statt überfordert',
            'Du gehst mit Klarheit ins Kontrollgespräch. Das gibt Sicherheit – dir und deinem Arzt.',
          ),
        ],
        preview: _ReportLockedPreview(),
      );
    }

    return GlassPage(
      title: 'Kurzbericht',
      titleEmoji: '👨‍⚕️',
      titleColor: const Color(0xFF00C7BE),
      trailing: PressableScale(
        onTap: _load,
        child: GlassContainer(
          variant: GlassVariant.thin,
          padding: const EdgeInsets.all(8),
          borderRadius: AppRadius.borderRadiusSm,
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
    final statusColor = _statusColor(d.painAvg);
    int sectionIndex = 0;

    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 48),
      physics: const BouncingScrollPhysics(
        parent: AlwaysScrollableScrollPhysics(),
      ),
      children: [
        // ═══════════════════════════════════════════════════════════════════════
        // Hero Banner
        // ═══════════════════════════════════════════════════════════════════════
        FadeSlideIn(
          child: GlassContainer(
            variant: GlassVariant.thick,
            elevation: GlassElevation.high,
            borderRadius: AppRadius.borderRadiusXl,
            padding: const EdgeInsets.all(20),
            child: Stack(
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            gradient: AppColors.primaryGradient,
                            borderRadius: AppRadius.borderRadiusMd,
                          ),
                          child: const Center(
                            child: Text(
                              '👨‍⚕️',
                              style: TextStyle(fontSize: 20),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Kurzbericht',
                                style: Theme.of(context)
                                    .textTheme
                                    .titleLarge
                                    ?.copyWith(
                                      fontWeight: FontWeight.w700,
                                      color: AppColors.textPrimary,
                                    ),
                              ),
                              Text(
                                'Erstellt am ${_fmtDate(DateTime.now())}',
                                style: Theme.of(context)
                                    .textTheme
                                    .bodySmall
                                    ?.copyWith(color: AppColors.textSecondary),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),
                    Text(
                      'Offline-tauglich für Arztgespräche',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                    if (d.daysPostOp != null) ...[
                      const SizedBox(height: 12),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          gradient: AppColors.primaryGradient,
                          borderRadius: AppRadius.borderRadiusPill,
                        ),
                        child: Text(
                          '${d.daysPostOp} Tage post-OP',
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textOnPrimary,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
                // Status dot
                Positioned(
                  top: 0,
                  right: 0,
                  child: Container(
                    width: 14,
                    height: 14,
                    decoration: BoxDecoration(
                      color: statusColor,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: AppColors.white,
                        width: 2,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: statusColor.withValues(alpha: 0.4),
                          blurRadius: 8,
                          spreadRadius: 1,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),

        // ═══════════════════════════════════════════════════════════════════════
        // Quick Stats Row
        // ═══════════════════════════════════════════════════════════════════════
        FadeSlideIn(
          delay: const Duration(milliseconds: 80),
          child: Row(
            children: [
              Expanded(
                child: _StatTile(
                  icon: Icons.insights_rounded,
                  iconColor: _painAvgColor(d.painAvg),
                  label: 'Schmerz-Ø',
                  value: d.painAvg != null
                      ? d.painAvg!.toStringAsFixed(1)
                      : '–',
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _StatTile(
                  icon: Icons.calendar_today_rounded,
                  iconColor: AppColors.primary,
                  label: 'Tage post-OP',
                  value: d.daysPostOp != null ? '${d.daysPostOp}' : '–',
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _StatTile(
                  icon: Icons.medication_rounded,
                  iconColor: AppColors.accent,
                  label: 'Medikamente',
                  value: '${_uniqueMeds(d.medications).length}',
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),

        // ═══════════════════════════════════════════════════════════════════════
        // Action Buttons
        // ═══════════════════════════════════════════════════════════════════════
        FadeSlideIn(
          delay: const Duration(milliseconds: 140),
          child: Row(
            children: [
              Expanded(
                child: GlassButton(
                  onPressed: _copyToClipboard,
                  label: 'Als Text kopieren',
                  icon: Icons.copy_rounded,
                  expand: true,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: GlassButton(
                  onPressed: _sendEmail,
                  label: 'Per E-Mail',
                  icon: Icons.mail_outline_rounded,
                  variant: GlassButtonVariant.ghost,
                  expand: true,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 10),
        FadeSlideIn(
          delay: const Duration(milliseconds: 180),
          child: GlassButton(
            onPressed: _sharePdf,
            label: 'Als PDF teilen',
            icon: Icons.picture_as_pdf_rounded,
            expand: true,
          ),
        ),
        const SizedBox(height: 24),

        // ═══════════════════════════════════════════════════════════════════════
        // 1) OP-Details
        // ═══════════════════════════════════════════════════════════════════════
        _sectionFade(
          index: sectionIndex++,
          child: _GlassSection(
            icon: Icons.content_cut_rounded,
            iconColor: AppColors.primary,
            title: 'OP-Details',
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
        ),
        const SizedBox(height: 14),

        // ═══════════════════════════════════════════════════════════════════════
        // 2) Schmerztrend
        // ═══════════════════════════════════════════════════════════════════════
        _sectionFade(
          index: sectionIndex++,
          child: _GlassSection(
            icon: Icons.show_chart_rounded,
            iconColor: AppColors.warning,
            title: 'Schmerztrend (7 Tage)',
            trailing: d.painTrend.isNotEmpty
                ? _TrendPill(trend: d.painTrend)
                : null,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _KVRow(
                  label: 'Durchschnitt',
                  value: d.painAvg != null
                      ? '${d.painAvg!.toStringAsFixed(1)} / 10'
                      : 'Keine Daten',
                ),
                if (d.painEntries.isNotEmpty) ...[
                  const SizedBox(height: 12),
                  SizedBox(
                    height: 80,
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: d.painEntries.map((e) {
                        final frac = e.painLevel / 10.0;
                        return Expanded(
                          child: Padding(
                            padding:
                                const EdgeInsets.symmetric(horizontal: 2),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                // Value label
                                Text(
                                  '${e.painLevel}',
                                  style: TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.w600,
                                    color: _painColor(e.painLevel),
                                  ),
                                ),
                                const SizedBox(height: 2),
                                // Bar
                                Expanded(
                                  child: FractionallySizedBox(
                                    heightFactor: frac.clamp(0.08, 1.0),
                                    alignment: Alignment.bottomCenter,
                                    child: Container(
                                      decoration: BoxDecoration(
                                        gradient: LinearGradient(
                                          begin: Alignment.topCenter,
                                          end: Alignment.bottomCenter,
                                          colors: [
                                            _painColor(e.painLevel)
                                                .withValues(alpha: 0.6),
                                            _painColor(e.painLevel),
                                          ],
                                        ),
                                        borderRadius:
                                            BorderRadius.circular(6),
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 4),
                                // Day label
                                Text(
                                  _weekdayShort(e.occurredAt),
                                  style: const TextStyle(
                                    fontSize: 10,
                                    color: AppColors.textSecondary,
                                  ),
                                ),
                              ],
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
        ),
        const SizedBox(height: 14),

        // ═══════════════════════════════════════════════════════════════════════
        // 3) Vitalzeichen
        // ═══════════════════════════════════════════════════════════════════════
        _sectionFade(
          index: sectionIndex++,
          child: _GlassSection(
            icon: Icons.monitor_heart_outlined,
            iconColor: const Color(0xFF00C7BE),
            title: 'Letzte Vitalwerte',
            child: d.latestVital != null
                ? Row(
                    children: [
                      Expanded(
                        child: _VitalTile(
                          icon: Icons.monitor_heart_outlined,
                          iconColor: const Color(0xFF00C7BE),
                          label: 'Blutdruck',
                          value:
                              '${d.latestVital!.systolic}/${d.latestVital!.diastolic}',
                          unit: 'mmHg',
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: _VitalTile(
                          icon: Icons.favorite_rounded,
                          iconColor: AppColors.error,
                          label: 'Puls',
                          value: '${d.latestVital!.pulse}',
                          unit: 'bpm',
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: _VitalTile(
                          icon: Icons.schedule_rounded,
                          iconColor: AppColors.grey600,
                          label: 'Gemessen',
                          value: _fmtTime(d.latestVital!.createdAt),
                          unit: _fmtDateShort(d.latestVital!.createdAt),
                        ),
                      ),
                    ],
                  )
                : const Text(
                    'Noch keine Messung',
                    style: TextStyle(color: AppColors.textSecondary),
                  ),
          ),
        ),
        const SizedBox(height: 14),

        // ═══════════════════════════════════════════════════════════════════════
        // 4) Medikamentenplan
        // ═══════════════════════════════════════════════════════════════════════
        _sectionFade(
          index: sectionIndex++,
          child: _GlassSection(
            icon: Icons.medication_rounded,
            iconColor: AppColors.accent,
            title: 'Medikamentenplan',
            child: _uniqueMeds(d.medications).isEmpty
                ? const Text(
                    'Keine Einnahmen erfasst',
                    style: TextStyle(color: AppColors.textSecondary),
                  )
                : Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: _uniqueMeds(d.medications)
                        .map((m) => _MedChip(med: m))
                        .toList(),
                  ),
          ),
        ),
        const SizedBox(height: 14),

        // ═══════════════════════════════════════════════════════════════════════
        // 5) Wunddokumentation
        // ═══════════════════════════════════════════════════════════════════════
        _sectionFade(
          index: sectionIndex++,
          child: _GlassSection(
            icon: Icons.camera_alt_rounded,
            iconColor: AppColors.success,
            title: 'Wunddokumentation',
            child: d.woundEntries.isEmpty && d.woundPhotos.isEmpty
                ? const Text(
                    'Keine Einträge',
                    style: TextStyle(color: AppColors.textSecondary),
                  )
                : Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      for (final w in d.woundEntries)
                        Padding(
                          padding: const EdgeInsets.only(bottom: 10),
                          child: _WoundCard(wound: w),
                        ),
                      if (d.woundPhotos.isNotEmpty) ...[
                        const SizedBox(height: 4),
                        SizedBox(
                          height: 72,
                          child: ListView.separated(
                            scrollDirection: Axis.horizontal,
                            itemCount: d.woundPhotos.length,
                            separatorBuilder: (_, _) =>
                                const SizedBox(width: 8),
                            itemBuilder: (_, i) => _WoundThumb(
                              path: d.woundPhotos[i].localPath,
                              size: 72,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
          ),
        ),
        const SizedBox(height: 28),

        // ═══════════════════════════════════════════════════════════════════════
        // Vollständiger Export
        // ═══════════════════════════════════════════════════════════════════════
        FadeSlideIn(
          delay: Duration(milliseconds: 160 + sectionIndex * 60),
          child: GlassButton(
            onPressed: _fullExport,
            label: 'Vollständiger Export',
            icon: Icons.ios_share_rounded,
            variant: GlassButtonVariant.ghost,
            expand: true,
          ),
        ),
      ],
    );
  }

  // ---------------------------------------------------------------------------
  // Helpers
  // ---------------------------------------------------------------------------

  Widget _sectionFade({required int index, required Widget child}) {
    return FadeSlideIn(
      delay: Duration(milliseconds: 160 + index * 60),
      child: child,
    );
  }

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

  static Color _painAvgColor(double? avg) {
    if (avg == null) return AppColors.grey400;
    if (avg < 4) return AppColors.success;
    if (avg < 7) return AppColors.warning;
    return AppColors.error;
  }

  static Color _statusColor(double? painAvg) {
    if (painAvg == null) return AppColors.grey400;
    if (painAvg >= 7) return AppColors.error;
    if (painAvg >= 4) return AppColors.warning;
    return AppColors.success;
  }

  static String _weekdayShort(DateTime d) {
    const days = ['Mo', 'Di', 'Mi', 'Do', 'Fr', 'Sa', 'So'];
    return days[d.weekday - 1];
  }

  static String _fmtDate(DateTime d) {
    final dd = d.day.toString().padLeft(2, '0');
    final mm = d.month.toString().padLeft(2, '0');
    return '$dd.$mm.${d.year}';
  }

  static String _fmtDateShort(DateTime d) {
    final dd = d.day.toString().padLeft(2, '0');
    final mm = d.month.toString().padLeft(2, '0');
    return '$dd.$mm.';
  }

  static String _fmtTime(DateTime d) {
    return '${d.hour.toString().padLeft(2, '0')}:${d.minute.toString().padLeft(2, '0')}';
  }

  static String _fmtDateTime(DateTime d) {
    return '${_fmtDate(d)} ${_fmtTime(d)}';
  }
}

class _ReportLockedPreview extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return GlassContainer(
      variant: GlassVariant.medium,
      borderRadius: AppRadius.borderRadiusLg,
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: _PreviewMetric(
                  label: 'Schmerztrend',
                  value: '7 Tage',
                  color: AppColors.warning,
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: _PreviewMetric(
                  label: 'Vitals',
                  value: 'Live',
                  color: AppColors.primary,
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: _PreviewMetric(
                  label: 'PDF',
                  value: '1 Tap',
                  color: AppColors.success,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(AppSpacing.md),
            decoration: BoxDecoration(
              color: AppColors.grey100.withValues(alpha: 0.55),
              borderRadius: AppRadius.borderRadiusLg,
            ),
            child: Text(
              'Vorschau: OP-Details, Schmerztrend, letzte Vitalwerte, '
              'Medikamentenplan und Wunddokumentation in einem kompakten Bericht.',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppColors.textSecondary,
                    height: 1.45,
                  ),
            ),
          ),
        ],
      ),
    );
  }
}

class _PreviewMetric extends StatelessWidget {
  const _PreviewMetric({
    required this.label,
    required this.value,
    required this.color,
  });

  final String label;
  final String value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: AppSpacing.md,
      ),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.10),
        borderRadius: AppRadius.borderRadiusLg,
      ),
      child: Column(
        children: [
          Text(
            value,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  color: color,
                  fontWeight: FontWeight.w800,
                ),
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            label,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: AppColors.textSecondary,
                  fontWeight: FontWeight.w600,
                ),
          ),
        ],
      ),
    );
  }
}

// =============================================================================
// Reusable widgets
// =============================================================================

// ─── Glass Section ──────────────────────────────────────────────────────────

class _GlassSection extends StatelessWidget {
  const _GlassSection({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.child,
    this.trailing,
  });

  final IconData icon;
  final Color iconColor;
  final String title;
  final Widget child;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    return GlassContainer(
      variant: GlassVariant.medium,
      elevation: GlassElevation.medium,
      borderRadius: AppRadius.borderRadiusLg,
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: iconColor.withValues(alpha: 0.12),
                  borderRadius: AppRadius.borderRadiusSm,
                ),
                child: Icon(icon, size: 18, color: iconColor),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
              ?trailing,
            ],
          ),
          const SizedBox(height: 14),
          child,
        ],
      ),
    );
  }
}

// ─── Stat Tile ──────────────────────────────────────────────────────────────

class _StatTile extends StatelessWidget {
  const _StatTile({
    required this.icon,
    required this.iconColor,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final Color iconColor;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return GlassContainer(
      variant: GlassVariant.thin,
      borderRadius: AppRadius.borderRadiusMd,
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
      child: Column(
        children: [
          Icon(icon, size: 20, color: iconColor),
          const SizedBox(height: 6),
          Text(
            value,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: const TextStyle(
              fontSize: 11,
              color: AppColors.textSecondary,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

// ─── Trend Pill ─────────────────────────────────────────────────────────────

class _TrendPill extends StatelessWidget {
  const _TrendPill({required this.trend});

  final String trend;

  @override
  Widget build(BuildContext context) {
    final Color bg;
    final Color fg;
    if (trend.contains('↑')) {
      bg = AppColors.error.withValues(alpha: 0.1);
      fg = AppColors.error;
    } else if (trend.contains('↓')) {
      bg = AppColors.success.withValues(alpha: 0.1);
      fg = AppColors.success;
    } else {
      bg = AppColors.grey200;
      fg = AppColors.textSecondary;
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: AppRadius.borderRadiusPill,
      ),
      child: Text(
        trend,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: fg,
        ),
      ),
    );
  }
}

// ─── Vital Tile ─────────────────────────────────────────────────────────────

class _VitalTile extends StatelessWidget {
  const _VitalTile({
    required this.icon,
    required this.iconColor,
    required this.label,
    required this.value,
    required this.unit,
  });

  final IconData icon;
  final Color iconColor;
  final String label;
  final String value;
  final String unit;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: iconColor.withValues(alpha: 0.10),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, size: 18, color: iconColor),
        ),
        const SizedBox(height: 8),
        Text(
          value,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary,
          ),
        ),
        Text(
          unit,
          style: const TextStyle(
            fontSize: 11,
            color: AppColors.textSecondary,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: const TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.w500,
            color: AppColors.textSecondary,
          ),
        ),
      ],
    );
  }
}

// ─── Med Chip ───────────────────────────────────────────────────────────────

class _MedChip extends StatelessWidget {
  const _MedChip({required this.med});

  final MedicationIntake med;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: AppRadius.borderRadiusPill,
        border: Border.all(
          color: AppColors.accent.withValues(alpha: 0.25),
          width: 1,
        ),
        boxShadow: const [
          BoxShadow(
            color: Color(0x08000000),
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.medication_rounded,
            size: 14,
            color: AppColors.accent,
          ),
          const SizedBox(width: 6),
          Text(
            '${med.name}${med.dose != null ? " · ${med.dose}" : ""}',
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: AppColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }
}

// ─── KV Row ─────────────────────────────────────────────────────────────────

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
            width: 110,
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

// ─── Wound Card ─────────────────────────────────────────────────────────────

class _WoundCard extends StatelessWidget {
  const _WoundCard({required this.wound});

  final WoundEntry wound;

  @override
  Widget build(BuildContext context) {
    final painColor = _woundPainColor(wound.pain);
    return GlassContainer(
      variant: GlassVariant.thin,
      borderRadius: AppRadius.borderRadiusMd,
      padding: const EdgeInsets.all(12),
      child: Row(
        children: [
          _WoundThumb(path: wound.photoPath, size: 80),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _fmtDate(wound.createdAt),
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 4),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 3,
                  ),
                  decoration: BoxDecoration(
                    color: painColor.withValues(alpha: 0.1),
                    borderRadius: AppRadius.borderRadiusPill,
                  ),
                  child: Text(
                    'Schmerz ${wound.pain}/10',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: painColor,
                    ),
                  ),
                ),
                if (wound.note.trim().isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Text(
                    wound.note.trim(),
                    style: const TextStyle(
                      fontSize: 13,
                      color: AppColors.textSecondary,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  static Color _woundPainColor(int level) {
    if (level <= 3) return AppColors.success;
    if (level <= 6) return AppColors.warning;
    return AppColors.error;
  }

  static String _fmtDate(DateTime d) {
    final dd = d.day.toString().padLeft(2, '0');
    final mm = d.month.toString().padLeft(2, '0');
    return '$dd.$mm.${d.year}';
  }
}

// ─── Wound Thumb ────────────────────────────────────────────────────────────

class _WoundThumb extends StatelessWidget {
  const _WoundThumb({required this.path, this.size = 54});

  final String? path;
  final double size;

  @override
  Widget build(BuildContext context) {
    final value = path?.trim() ?? '';
    if (value.isEmpty) {
      return Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: AppColors.grey100,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(
          Icons.image_not_supported_outlined,
          size: size * 0.33,
          color: AppColors.textSecondary,
        ),
      );
    }
    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: SizedBox(
        width: size,
        height: size,
        child: Image.file(
          File(value),
          fit: BoxFit.cover,
          errorBuilder: (_, _, _) => Container(
            width: size,
            height: size,
            color: AppColors.grey100,
            child: Icon(
              Icons.broken_image_outlined,
              size: size * 0.33,
              color: AppColors.textSecondary,
            ),
          ),
        ),
      ),
    );
  }
}
