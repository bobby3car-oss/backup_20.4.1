import 'dart:io';

import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';

import '../../../ui/ui.dart';
import '../doctor_report_builder.dart';
import '../../../ui/theme/app_icons.dart';
import '../../../l10n/app_localizations.dart';

class DoctorReportScreen extends StatefulWidget {
  const DoctorReportScreen({super.key});

  @override
  State<DoctorReportScreen> createState() => _DoctorReportScreenState();
}

class _DoctorReportScreenState extends State<DoctorReportScreen> {
  final DoctorReportBuilder _builder = DoctorReportBuilder();
  late Future<DoctorReportData> _future;

  @override
  void initState() {
    super.initState();
    _future = _builder.build();
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    return GlassPage(
      title: 'Arztbericht',
      titleIcon: AppIcons.doctor,
      titleColor: const Color(0xFF00C7BE),
      trailing: PressableScale(
        onTap: () => setState(() => _future = _builder.build()),
        scaleFactor: 0.90,
        child: Container(
          width: 38,
          height: 38,
          decoration: BoxDecoration(
            color: AppColors.white.withValues(alpha: 0.65),
            borderRadius: AppRadius.borderRadiusMd,
            border: Border.all(
              color: AppColors.white.withValues(alpha: 0.80),
              width: 0.5,
            ),
          ),
          child: const Icon(
            Icons.refresh_rounded,
            size: 18,
            color: AppColors.primary,
          ),
        ),
      ),
      scrollableBody: (headerHeight) => FutureBuilder<DoctorReportData>(
        future: _future,
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            return const Center(child: CircularProgressIndicator());
          }
          final data = snapshot.data;
          if (data == null) {
            return Center(child: Text(l.doctorReportNotAvailable));
          }
          return ListView(
            padding: EdgeInsets.fromLTRB(16, headerHeight + 12, 16, 24),
            children: [
              _HeaderCard(onShare: () => _share(data)),
              const SizedBox(height: 12),
              _SectionCard(
                title: l.patientBasisdaten,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _kv('Name', data.patientName ?? l.notAvailable),
                    _kv(l.fieldEmail, data.patientEmail ?? l.notAvailable),
                    _kv(
                      l.fieldBirthDate,
                      data.patientBirthDate ?? l.notAvailable,
                    ),
                    _kv('Diagnose', data.patientDiagnosis ?? l.notAvailable),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              _SectionCard(title: l.oPDatum, child: Text(_date(data.opDate))),
              const SizedBox(height: 12),
              _SectionCard(
                title: l.timelineZusammenfassung,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _kv('Heute offen', '${data.timelineTodayCount}'),
                    _kv(l.ueberfaellig, '${data.timelineOverdueCount}'),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              _buildPainSection(data),
              const SizedBox(height: 12),
              _buildWoundSection(data),
              const SizedBox(height: 12),
              _SectionCard(
                title: l.termineNaechste14Tage,
                child: data.upcomingAppointments.isEmpty
                    ? Text(l.none)
                    : Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: data.upcomingAppointments
                            .map(
                              (a) => Padding(
                                padding: const EdgeInsets.only(bottom: 6),
                                child: Text(
                                  '- ${_dateTime(a.startAt)} · ${a.title}',
                                ),
                              ),
                            )
                            .toList(growable: false),
                      ),
              ),
              const SizedBox(height: 12),
              _SectionCard(
                title: l.warnzeichenStatus,
                child: Row(
                  children: [
                    _AmpelDot(light: data.warnStatus),
                    const SizedBox(width: 8),
                    Text(_lightLabel(data.warnStatus)),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              _SectionCard(
                title: l.dokumenteLetzte3,
                child: data.latestDocuments.isEmpty
                    ? Text(l.none)
                    : Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: data.latestDocuments
                            .map(
                              (d) => Padding(
                                padding: const EdgeInsets.only(bottom: 6),
                                child: Text(
                                  '- ${_dateTime(d.createdAt)} · ${d.title}',
                                ),
                              ),
                            )
                            .toList(growable: false),
                      ),
              ),
              if (data.unavailableSections.isNotEmpty) ...[
                const SizedBox(height: 12),
                _SectionCard(
                  title: l.notAvailable,
                  child: Text(data.unavailableSections.join(', ')),
                ),
              ],
            ],
          );
        },
      ),
    );
  }

  Widget _buildPainSection(DoctorReportData data) {
    final l = AppLocalizations.of(context)!;
    final pain = data.painSummary;
    if (pain == null) {
      final l = AppLocalizations.of(context)!;
      return _SectionCard(
        title: l.schmerztagebuchLetzte7Tage,
        child: Text(l.notAvailable),
      );
    }
    return _SectionCard(
      title: l.doctorReportSchmerztagebuchLetzte7Tage,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _kv('Aktuell', '${pain.current}/10'),
          _kv('Min/Max', '${pain.min}/${pain.max}'),
          const SizedBox(height: 6),
          Text(l.lastEntries),
          const SizedBox(height: 6),
          for (final entry in pain.latestEntries)
            Padding(
              padding: const EdgeInsets.only(bottom: 6),
              child: Text(
                '- ${_dateTime(entry.occurredAt)} · ${entry.painLevel}/10'
                '${entry.note.trim().isEmpty ? "" : " · ${entry.note.trim()}"}',
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildWoundSection(DoctorReportData data) {
    final wound = data.woundSummary;
    final l = AppLocalizations.of(context)!;
    if (wound == null) {
      return _SectionCard(
        title: l.wunddokuLetzte3,
        child: Text(l.notAvailable),
      );
    }
    return _SectionCard(
      title: l.doctorReportWunddokuLetzte3,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          for (final entry in wound.latestEntries)
            Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _WoundThumb(path: entry.photoPath),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      '${_dateTime(entry.createdAt)}\nSchmerz: ${entry.pain}/10',
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Future<void> _share(DoctorReportData data) async {
    final markdown = _builder.buildMarkdown(data);
    await SharePlus.instance.share(ShareParams(text: markdown));
  }

  static Widget _kv(String key, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Text('$key: $value'),
    );
  }

  String _date(DateTime? value) {
    final l = AppLocalizations.of(context)!;
    if (value == null) return l.notAvailable;
    final dd = value.day.toString().padLeft(2, '0');
    final mm = value.month.toString().padLeft(2, '0');
    return '$dd.$mm.${value.year}';
  }

  String _dateTime(DateTime value) {
    final dd = value.day.toString().padLeft(2, '0');
    final mm = value.month.toString().padLeft(2, '0');
    final hh = value.hour.toString().padLeft(2, '0');
    final min = value.minute.toString().padLeft(2, '0');
    return '$dd.$mm.${value.year} $hh:$min';
  }

  String _lightLabel(ReportLight light) {
    final l = AppLocalizations.of(context)!;
    return switch (light) {
      ReportLight.green => l.gruen,
      ReportLight.yellow => 'Gelb',
      ReportLight.red => 'Rot',
      ReportLight.unknown => l.notAvailable,
    };
  }
}

class _HeaderCard extends StatelessWidget {
  const _HeaderCard({required this.onShare});

  final VoidCallback onShare;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            const Expanded(
              child: Text(
                'Arztbericht (MVP)\nAlle relevanten Daten auf einer Seite.',
              ),
            ),
            const SizedBox(width: 12),
            FilledButton.icon(
              onPressed: onShare,
              icon: const Icon(Icons.share_rounded),
              label: Text(l.share),
            ),
          ],
        ),
      ),
    );
  }
}

class _SectionCard extends StatelessWidget {
  const _SectionCard({required this.title, required this.child});

  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 10),
            child,
          ],
        ),
      ),
    );
  }
}

class _AmpelDot extends StatelessWidget {
  const _AmpelDot({required this.light});

  final ReportLight light;

  @override
  Widget build(BuildContext context) {
    final color = switch (light) {
      ReportLight.green => Colors.green,
      ReportLight.yellow => Colors.orange,
      ReportLight.red => Colors.red,
      ReportLight.unknown => Colors.grey,
    };
    return Container(
      width: 14,
      height: 14,
      decoration: BoxDecoration(color: color, shape: BoxShape.circle),
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
      return const _ThumbPlaceholder();
    }
    return ClipRRect(
      borderRadius: BorderRadius.circular(8),
      child: SizedBox(
        width: 54,
        height: 54,
        child: Image.file(
          File(value),
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) =>
              const _ThumbPlaceholder(),
        ),
      ),
    );
  }
}

class _ThumbPlaceholder extends StatelessWidget {
  const _ThumbPlaceholder();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 54,
      height: 54,
      decoration: BoxDecoration(
        color: Colors.grey.shade200,
        borderRadius: BorderRadius.circular(8),
      ),
      child: const Icon(Icons.image_not_supported_outlined, size: 18),
    );
  }
}
