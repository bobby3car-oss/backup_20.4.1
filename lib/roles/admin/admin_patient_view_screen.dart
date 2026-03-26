import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../../features/doctor_patients/domain/linked_patient.dart';
import '../../features/doctor_patients/presentation/tabs/patient_documents_tab.dart';
import '../../features/doctor_patients/presentation/tabs/patient_pain_tab.dart';
import '../../features/doctor_patients/presentation/tabs/patient_red_flags_tab.dart';
import '../../features/doctor_patients/presentation/tabs/patient_report_tab.dart';
import '../../features/doctor_patients/presentation/tabs/patient_wounds_tab.dart';
import '../../ui/error_helpers.dart';
import '../../l10n/app_localizations.dart';

/// Admin screen to view any patient's data by searching via UID or email.
class AdminPatientViewScreen extends StatefulWidget {
  const AdminPatientViewScreen({super.key});

  @override
  State<AdminPatientViewScreen> createState() =>
      _AdminPatientViewScreenState();
}

class _AdminPatientViewScreenState extends State<AdminPatientViewScreen> {
  final _searchController = TextEditingController();
  String _searchQuery = '';
  LinkedPatient? _patient;

  @override
  void initState() {
    super.initState();
    _searchController.addListener(() {
      setState(() =>
          _searchQuery = _searchController.text.toLowerCase().trim());
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _openPatient(Map<String, dynamic> data, String uid) {
    DateTime? opDate;
    final opTs = data['opDate'];
    if (opTs is Timestamp) opDate = opTs.toDate();
    setState(() {
      _patient = LinkedPatient(
        uid: uid,
        displayName: (data['displayName'] as String?)?.isNotEmpty == true
            ? data['displayName'] as String
            : (data['email'] as String? ?? uid),
        email: data['email'] as String? ?? '',
        opDate: opDate,
        diagnosis: data['diagnosis'] as String?,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    if (_patient != null) {
      return _PatientDetailView(
        patient: _patient!,
        onBack: () => setState(() => _patient = null),
      );
    }

    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(title: Text(l.patientData)),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 12, 12, 4),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Suchen (Name, E-Mail oder UID)…',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _searchQuery.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () => _searchController.clear(),
                      )
                    : null,
                border: const OutlineInputBorder(),
              ),
            ),
          ),
          Expanded(
            child: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
              stream: FirebaseFirestore.instance
                  .collection('users')
                  .where('role', isEqualTo: 'patient')
                  .limit(200)
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Text(
                        userFacingError(snapshot.error!),
                        style: TextStyle(color: cs.error),
                      ),
                    ),
                  );
                }
                if (snapshot.connectionState == ConnectionState.waiting &&
                    !snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }

                final docs = snapshot.data?.docs ?? [];
                var patients = docs
                    .map((d) =>
                        <String, dynamic>{'uid': d.id, ...d.data()})
                    .toList();

                if (_searchQuery.isNotEmpty) {
                  patients = patients.where((p) {
                    final email =
                        (p['email'] ?? '').toString().toLowerCase();
                    final uid =
                        (p['uid'] ?? '').toString().toLowerCase();
                    final name =
                        (p['displayName'] ?? '').toString().toLowerCase();
                    return email.contains(_searchQuery) ||
                        uid.contains(_searchQuery) ||
                        name.contains(_searchQuery);
                  }).toList();
                }

                if (patients.isEmpty) {
                  return Center(
                    child: Text(
                      docs.isEmpty
                          ? 'Keine Patienten vorhanden.'
                          : 'Keine Treffer für "$_searchQuery".',
                      style: TextStyle(color: cs.onSurfaceVariant),
                    ),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.all(12),
                  itemCount: patients.length,
                  itemBuilder: (context, index) {
                    final p = patients[index];
                    final uid = p['uid'] as String;
                    final email = (p['email'] ?? '').toString();
                    final name =
                        (p['displayName'] as String?)?.isNotEmpty == true
                            ? p['displayName'] as String
                            : email;
                    final isPro = p['isPro'] as bool? ?? false;

                    return Card(
                      margin: const EdgeInsets.only(bottom: 6),
                      child: ListTile(
                        leading: CircleAvatar(
                          child: Text(
                            name.isNotEmpty
                                ? name[0].toUpperCase()
                                : '?',
                          ),
                        ),
                        title: Text(
                          name,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        subtitle: Text(
                          email,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            if (isPro)
                              Icon(Icons.star,
                                  size: 16,
                                  color: Colors.amber.shade600),
                            const SizedBox(width: 4),
                            const Icon(Icons.chevron_right),
                          ],
                        ),
                        onTap: () => _openPatient(p, uid),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
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
