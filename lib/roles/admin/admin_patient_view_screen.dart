import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../../features/doctor_patients/domain/linked_patient.dart';
import '../../features/doctor_patients/presentation/tabs/patient_documents_tab.dart';
import '../../features/doctor_patients/presentation/tabs/patient_pain_tab.dart';
import '../../features/doctor_patients/presentation/tabs/patient_red_flags_tab.dart';
import '../../features/doctor_patients/presentation/tabs/patient_report_tab.dart';
import '../../features/doctor_patients/presentation/tabs/patient_wounds_tab.dart';

/// Admin screen to view any patient's data by searching via UID or email.
class AdminPatientViewScreen extends StatefulWidget {
  const AdminPatientViewScreen({super.key});

  @override
  State<AdminPatientViewScreen> createState() =>
      _AdminPatientViewScreenState();
}

class _AdminPatientViewScreenState extends State<AdminPatientViewScreen> {
  final _searchController = TextEditingController();
  bool _searching = false;
  String? _error;
  LinkedPatient? _patient;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _search() async {
    final query = _searchController.text.trim();
    if (query.isEmpty) return;

    setState(() {
      _searching = true;
      _error = null;
      _patient = null;
    });

    try {
      final db = FirebaseFirestore.instance;
      DocumentSnapshot<Map<String, dynamic>>? userDoc;

      // Try UID first.
      final byUid = await db.collection('users').doc(query).get();
      if (byUid.exists) {
        userDoc = byUid;
      } else {
        // Try email lookup.
        final byEmail = await db
            .collection('users')
            .where('email', isEqualTo: query)
            .limit(1)
            .get();
        if (byEmail.docs.isNotEmpty) {
          userDoc = byEmail.docs.first;
        }
      }

      if (userDoc == null || !userDoc.exists) {
        setState(() => _error = 'Kein Nutzer gefunden.');
        return;
      }

      final data = userDoc.data()!;
      final uid = userDoc.id;

      DateTime? opDate;
      final opTs = data['opDate'];
      if (opTs is Timestamp) opDate = opTs.toDate();

      setState(() {
        _patient = LinkedPatient(
          uid: uid,
          displayName: data['displayName'] as String? ?? uid,
          email: data['email'] as String? ?? '',
          opDate: opDate,
          diagnosis: data['diagnosis'] as String?,
        );
      });
    } catch (e) {
      setState(() => _error = 'Fehler: $e');
    } finally {
      setState(() => _searching = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_patient != null) {
      return _PatientDetailView(
        patient: _patient!,
        onBack: () => setState(() => _patient = null),
      );
    }

    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Patientendaten',
                style: Theme.of(context).textTheme.headlineSmall),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _searchController,
                    decoration: const InputDecoration(
                      labelText: 'UID oder E-Mail',
                      prefixIcon: Icon(Icons.search),
                    ),
                    onSubmitted: (_) => _search(),
                  ),
                ),
                const SizedBox(width: 8),
                FilledButton(
                  onPressed: _searching ? null : _search,
                  child: _searching
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child:
                              CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Text('Suchen'),
                ),
              ],
            ),
            if (_error != null) ...[
              const SizedBox(height: 12),
              Text(_error!,
                  style: TextStyle(
                      color: Theme.of(context).colorScheme.error)),
            ],
          ],
        ),
      ),
    );
  }
}

class _PatientDetailView extends StatelessWidget {
  const _PatientDetailView({
    required this.patient,
    required this.onBack,
  });

  final LinkedPatient patient;
  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 5,
      child: Scaffold(
        appBar: AppBar(
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: onBack,
          ),
          title: Text(patient.displayName),
          bottom: const TabBar(
            isScrollable: true,
            tabs: [
              Tab(text: 'Bericht'),
              Tab(text: 'Red Flags'),
              Tab(text: 'Wunden'),
              Tab(text: 'Schmerz'),
              Tab(text: 'Dokumente'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            PatientReportTab(patient: patient),
            PatientRedFlagsTab(patientId: patient.uid),
            PatientWoundsTab(patientId: patient.uid),
            PatientPainTab(patientId: patient.uid),
            PatientDocumentsTab(patientId: patient.uid),
          ],
        ),
      ),
    );
  }
}
