import 'package:flutter/material.dart';

import '../../../../features/doctor_report/doctor_report_builder.dart';
import '../../../../ui/ui.dart';
import '../../domain/linked_patient.dart';

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

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    // Build report using the patient UID.
    final builder = DoctorReportBuilder();
    _reportFuture = builder.buildForPatient(widget.patient.uid);
  }

  @override
  Widget build(BuildContext context) {
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
        final report = snapshot.data!;
        return ListView(
          padding: AppSpacing.screenPadding,
          children: [
            _ReportSection(
              icon: Icons.person_rounded,
              title: 'Patient',
              children: [
                _InfoRow('Name', report.patientName ?? '–'),
                _InfoRow('E-Mail', report.patientEmail ?? '–'),
                _InfoRow('Geburtsdatum', report.patientBirthDate ?? '–'),
                _InfoRow('Diagnose', report.patientDiagnosis ?? '–'),
              ],
            ),
            const SizedBox(height: AppSpacing.md),
            _ReportSection(
              icon: Icons.calendar_today_rounded,
              title: 'OP & Timeline',
              children: [
                _InfoRow(
                  'OP-Datum',
                  report.opDate != null
                      ? '${report.opDate!.day}.${report.opDate!.month}.${report.opDate!.year}'
                      : '–',
                ),
                _InfoRow('Heute fällig', '${report.timelineTodayCount}'),
                _InfoRow('Überfällig', '${report.timelineOverdueCount}'),
              ],
            ),
            const SizedBox(height: AppSpacing.md),
            if (report.painSummary != null)
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
            _ReportSection(
              icon: Icons.warning_amber_rounded,
              title: 'Warnstatus',
              children: [
                _InfoRow('Status', report.warnStatus.name.toUpperCase()),
              ],
            ),
            if (report.unavailableSections.isNotEmpty) ...[
              const SizedBox(height: AppSpacing.md),
              GlassCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Nicht verfügbare Bereiche',
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
