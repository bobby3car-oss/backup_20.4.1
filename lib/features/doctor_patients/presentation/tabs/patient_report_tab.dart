import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';

import '../../../../features/doctor_report/doctor_report_builder.dart';
import '../../../../main.dart';
import '../../../../ui/ui.dart';
import '../../../pro/domain/trigger_context.dart';
import '../../../pro/presentation/smart_paywall.dart';
import '../../domain/linked_patient.dart';
import '../../../../l10n/app_localizations.dart';

/// Read-only report tab re-using the DoctorReportData display.
class PatientReportTab extends StatefulWidget {
  const PatientReportTab({super.key, required this.patient});

  final LinkedPatient patient;

  @override
  State<PatientReportTab> createState() => _PatientReportTabState();
}

class _PatientReportTabState extends State<PatientReportTab>
    with AutomaticKeepAliveClientMixin {
  late Future<DoctorReportData> _reportFuture;
  final _builder = DoctorReportBuilder();

  @override
  bool get wantKeepAlive => true;

  bool get _isPro =>
      ProServices.maybeOf(context)?.entitlementService.isPro ?? false;

  @override
  void initState() {
    super.initState();
    // Build report using the patient UID.
    _reportFuture = _builder.buildForPatient(widget.patient.uid);
  }

  Future<void> _exportPdf(DoctorReportData report) async {
    final markdown = _builder.buildMarkdown(report);
    await SharePlus.instance.share(ShareParams(text: markdown));
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    super.build(context);
    return FutureBuilder<DoctorReportData>(
      future: _reportFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return Center(
            child: Text(
              'Report konnte nicht geladen werden.',
              style: TextStyle(color: AppColors.error),
            ),
          );
        }
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }
        final report = snapshot.data!;
        return ListView(
          padding: AppSpacing.screenPadding,
          children: [
            _ReportSection(
              icon: Icons.person_rounded,
              title: l.patient,
              children: [
                _InfoRow('Name', report.patientName ?? '–'),
                _InfoRow(l.fieldEmail, report.patientEmail ?? '–'),
                _InfoRow(l.fieldBirthDate, report.patientBirthDate ?? '–'),
                _InfoRow('Diagnose', report.patientDiagnosis ?? '–'),
              ],
            ),
            const SizedBox(height: AppSpacing.md),
            _ReportSection(
              icon: Icons.calendar_today_rounded,
              title: l.oPUndTimeline,
              children: [
                _InfoRow(
                  'OP-Datum',
                  report.opDate != null
                      ? '${report.opDate!.day}.${report.opDate!.month}.${report.opDate!.year}'
                      : '–',
                ),
                _InfoRow(l.heuteFaellig, '${report.timelineTodayCount}'),
                _InfoRow(l.ueberfaellig, '${report.timelineOverdueCount}'),
              ],
            ),
            const SizedBox(height: AppSpacing.md),
            if (report.painSummary != null) ...[
              _ReportSection(
                icon: Icons.show_chart_rounded,
                title: 'Schmerz',
                children: [
                  _InfoRow('Aktuell', '${report.painSummary!.current}/10'),
                  _InfoRow('Min', '${report.painSummary!.min}/10'),
                  _InfoRow('Max', '${report.painSummary!.max}/10'),
                ],
              ),
              const SizedBox(height: AppSpacing.md),
            ],
            if (report.woundSummary != null) ...[
              _ReportSection(
                icon: Icons.healing_rounded,
                title: 'Wunddokumentation',
                children: report.woundSummary!.latestEntries.map((w) {
                  final date = '${w.createdAt.day}.${w.createdAt.month}.${w.createdAt.year}';
                  final label = w.bodyLocation ?? 'Eintrag';
                  return _InfoRow(date, '$label (Schmerz: ${w.pain}/10)');
                }).toList(),
              ),
              const SizedBox(height: AppSpacing.md),
            ],
            _ReportSection(
              icon: Icons.event_rounded,
              title: l.naechsteTermine,
              children: report.upcomingAppointments.isEmpty
                  ? [const _InfoRow('–', 'Keine anstehenden Termine')]
                  : report.upcomingAppointments.map((a) {
                      final dt = a.startAt;
                      final date = '${dt.day}.${dt.month}.${dt.year}';
                      final time = '${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
                      return _InfoRow('$date $time', a.title);
                    }).toList(),
            ),
            const SizedBox(height: AppSpacing.md),
            if (report.latestDocuments.isNotEmpty) ...[
              _ReportSection(
                icon: Icons.folder_rounded,
                title: l.letzteDokumente,
                children: report.latestDocuments.map((d) {
                  final date = '${d.createdAt.day}.${d.createdAt.month}.${d.createdAt.year}';
                  return _InfoRow(d.title, date);
                }).toList(),
              ),
              const SizedBox(height: AppSpacing.md),
            ],
            _ReportSection(
              icon: Icons.warning_amber_rounded,
              title: 'Warnstatus',
              children: [
                _InfoRow(l.status, report.warnStatus.name.toUpperCase()),
              ],
            ),
            if (report.unavailableSections.isNotEmpty) ...[
              const SizedBox(height: AppSpacing.md),
              GlassCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l.nichtVerfuegbareBereiche,
                      style: Theme.of(context).textTheme.titleSmall,
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    ...report.unavailableSections.map(
                      (s) => Text('• $s',
                          style: TextStyle(color: AppColors.textSecondary)),
                    ),
                  ],
                ),
              ),
            ],

            // ── PDF Export Button ──────────────────────────────────
            const SizedBox(height: AppSpacing.xl),
            SizedBox(
              width: double.infinity,
              child: _isPro
                  ? FilledButton.icon(
                      onPressed: () => _exportPdf(report),
                      icon: const Icon(Icons.picture_as_pdf_rounded),
                      label: Text(l.exportAsPdf),
                    )
                  : Opacity(
                      opacity: 0.5,
                      child: FilledButton.icon(
                        onPressed: () {
                          SmartPaywall.trigger(
                            context: context,
                            triggerContext: TriggerContext.doctorPdfExport,
                          );
                        },
                        icon: const Icon(Icons.lock_rounded),
                        label: Text('🔒 ${l.exportAsPdf}'),
                        style: FilledButton.styleFrom(
                          backgroundColor: AppColors.grey400,
                        ),
                      ),
                    ),
            ),
            const SizedBox(height: AppSpacing.xl),
          ],
        );
      },
    );
  }
}

class _ReportSection extends StatelessWidget {
  const _ReportSection({
    required this.icon,
    required this.title,
    required this.children,
  });

  final IconData icon;
  final String title;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 20, color: AppColors.primary),
              const SizedBox(width: AppSpacing.sm),
              Text(
                title,
                style: Theme.of(context)
                    .textTheme
                    .titleSmall
                    ?.copyWith(fontWeight: FontWeight.w600),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          ...children,
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow(this.label, this.value);

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label,
              style: TextStyle(color: AppColors.textSecondary, fontSize: 13)),
          Flexible(
            child: Text(
              value,
              style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
              textAlign: TextAlign.end,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}
