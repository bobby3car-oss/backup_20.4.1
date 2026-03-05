import 'package:flutter/material.dart';

import '../../../features/doctor_report/doctor_report_builder.dart';
import '../../../ui/ui.dart';
import '../data/doctor_patient_repository.dart';
import '../domain/linked_patient.dart';
import 'tabs/patient_documents_tab.dart';
import 'tabs/patient_pain_tab.dart';
import 'tabs/patient_report_tab.dart';
import 'tabs/patient_wounds_tab.dart';

/// Detail screen for a single patient, showing 4 tabs:
/// Report | Wunde | Schmerz | Dokumente
class PatientDetailScreen extends StatelessWidget {
  const PatientDetailScreen({
    super.key,
    required this.patient,
  });

  final LinkedPatient patient;

  Color _ampelColor(ReportLight status) => switch (status) {
        ReportLight.green => AppColors.success,
        ReportLight.yellow => AppColors.warning,
        ReportLight.red => AppColors.error,
        ReportLight.unknown => AppColors.grey400,
      };

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 4,
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          title: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(patient.displayName),
              const SizedBox(width: 8),
              Container(
                width: 10,
                height: 10,
                decoration: BoxDecoration(
                  color: _ampelColor(patient.warnStatus),
                  shape: BoxShape.circle,
                ),
              ),
            ],
          ),
          actions: [
            PopupMenuButton<String>(
              onSelected: (value) async {
                if (value == 'unlink') {
                  final confirm = await showDialog<bool>(
                    context: context,
                    builder: (ctx) => AlertDialog(
                      title: const Text('Verbindung trennen?'),
                      content: Text(
                        'Möchten Sie die Verbindung zu ${patient.displayName} wirklich trennen?',
                      ),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(ctx, false),
                          child: const Text('Abbrechen'),
                        ),
                        FilledButton(
                          onPressed: () => Navigator.pop(ctx, true),
                          child: const Text('Trennen'),
                        ),
                      ],
                    ),
                  );
                  if (confirm == true && context.mounted) {
                    await DoctorPatientRepository()
                        .unlinkPatient(patient.uid);
                    if (context.mounted) Navigator.pop(context);
                  }
                }
              },
              itemBuilder: (_) => [
                const PopupMenuItem(
                  value: 'unlink',
                  child: Row(
                    children: [
                      Icon(Icons.link_off, color: AppColors.error),
                      SizedBox(width: 8),
                      Text('Verbindung trennen'),
                    ],
                  ),
                ),
              ],
            ),
          ],
          bottom: const TabBar(
            tabs: [
              Tab(text: 'Report'),
              Tab(text: 'Wunde'),
              Tab(text: 'Schmerz'),
              Tab(text: 'Dokumente'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            PatientReportTab(patient: patient),
            PatientWoundsTab(patientId: patient.uid),
            PatientPainTab(patientId: patient.uid),
            PatientDocumentsTab(patientId: patient.uid),
          ],
        ),
      ),
    );
  }
}
