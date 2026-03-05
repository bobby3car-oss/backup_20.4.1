import 'dart:io';

import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';

import '../../../ui/ui.dart';
import '../doctor_report_builder.dart';

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
    return GlassPage(
      title: 'Arztbericht',
      titleEmoji: '🧑‍⚕️',
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
            return const Center(child: Text('Arztbericht nicht verfügbar.'));
          }
          return ListView(
            padding: EdgeInsets.fromLTRB(16, headerHeight + 12, 16, 24),
            children: [
              _HeaderCard(onShare: () => _share(data)),
              const SizedBox(height: 12),
              _SectionCard(
                title: 'Patient Basisdaten',
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _kv('Name', data.patientName ?? 'Nicht verfügbar'),
                    _kv('E-Mail', data.patientEmail ?? 'Nicht verfügbar'),
                    _kv(
                      'Geburtsdatum',
                      data.patientBirthDate ?? 'Nicht verfügbar',
                    ),
                    _kv('Diagnose', data.patientDiagnosis ?? 'Nicht verfügbar'),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              _SectionCard(title: 'OP Datum', child: Text(_date(data.opDate))),
              const SizedBox(height: 12),
              _SectionCard(
                title: 'Timeline Zusammenfassung',
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _kv('Heute offen', '${data.timelineTodayCount}'),
                    _kv('Überfällig', '${data.timelineOverdueCount}'),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              _buildPainSection(data),
              const SizedBox(height: 12),
              _buildWoundSection(data),
              const SizedBox(height: 12),
              _SectionCard(
                title: 'Termine nächste 14 Tage',
                child: data.upcomingAppointments.isEmpty
                    ? const Text('Keine')
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
                title: 'Warnzeichen Status',
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
                title: 'Dokumente letzte 3',
                child: data.latestDocuments.isEmpty
                    ? const Text('Keine')
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
                  title: 'Nicht verfügbar',
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
    final pain = data.painSummary;
    if (pain == null) {
      return const _SectionCard(
        title: 'Schmerztagebuch letzte 7 Tage',
        child: Text('Nicht verfügbar'),
      );
    }
    return _SectionCard(
      title: 'Schmerztagebuch letzte 7 Tage',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _kv('Aktuell', '${pain.current}/10'),
          _kv('Min/Max', '${pain.min}/${pain.max}'),
          const SizedBox(height: 6),
          const Text('Letzte Einträge:'),
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
    if (wound == null) {
      return const _SectionCard(
        title: 'Wunddoku letzte 3',
        child: Text('Nicht verfügbar'),
      );
    }
    return _SectionCard(
      title: 'Wunddoku letzte 3',
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
    if (value == null) return 'Nicht verfügbar';
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
    return switch (light) {
      ReportLight.green => 'Grün',
      ReportLight.yellow => 'Gelb',
      ReportLight.red => 'Rot',
      ReportLight.unknown => 'Nicht verfügbar',
    };
  }
}

class _HeaderCard extends StatelessWidget {
  const _HeaderCard({required this.onShare});

  final VoidCallback onShare;

  @override
  Widget build(BuildContext context) {
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
              label: const Text('Teilen'),
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
