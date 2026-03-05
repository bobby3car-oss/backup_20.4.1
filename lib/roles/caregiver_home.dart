import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../auth/auth_service.dart';
import '../features/observations/data/observation_repository.dart';
import '../features/observations/domain/observation_entry.dart';
import '../firebase/firebase_paths.dart';

class CaregiverHome extends StatefulWidget {
  const CaregiverHome({super.key});

  @override
  State<CaregiverHome> createState() => _CaregiverHomeState();
}

class _CaregiverHomeState extends State<CaregiverHome> {
  int _currentIndex = 0;
  String? _linkedPatientId;
  bool _loadingPatient = true;

  @override
  void initState() {
    super.initState();
    _loadLinkedPatient();
  }

  Future<void> _loadLinkedPatient() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;

    try {
      final linksQuery = await FirebaseFirestore.instance
          .collectionGroup('links')
          .where('linkedUid', isEqualTo: uid)
          .where('status', isEqualTo: 'active')
          .where('linkType', isEqualTo: 'caregiver')
          .limit(1)
          .get();

      if (linksQuery.docs.isNotEmpty) {
        final linkDoc = linksQuery.docs.first;
        // Path: patients/{patientId}/links/{linkId}
        final patientId = linkDoc.reference.parent.parent?.id;
        if (mounted) {
          setState(() {
            _linkedPatientId = patientId;
            _loadingPatient = false;
          });
        }
      } else {
        if (mounted) setState(() => _loadingPatient = false);
      }
    } catch (_) {
      if (mounted) setState(() => _loadingPatient = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loadingPatient) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (_linkedPatientId == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Begleiter')),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.link_off, size: 64, color: Colors.grey),
                const SizedBox(height: 16),
                const Text(
                  'Noch kein Patient verknüpft.\n'
                  'Bitte lasse dich über einen Einladungscode verbinden.',
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                FilledButton(
                  onPressed: () async => AuthService().signOut(),
                  child: const Text('Logout'),
                ),
              ],
            ),
          ),
        ),
      );
    }

    final screens = <Widget>[
      _CaregiverTimelineTab(patientId: _linkedPatientId!),
      _CaregiverObservationsTab(patientId: _linkedPatientId!),
    ];

    return Scaffold(
      body: IndexedStack(index: _currentIndex, children: screens),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: (index) =>
            setState(() => _currentIndex = index),
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.timeline_outlined),
            selectedIcon: Icon(Icons.timeline),
            label: 'Plan',
          ),
          NavigationDestination(
            icon: Icon(Icons.note_alt_outlined),
            selectedIcon: Icon(Icons.note_alt),
            label: 'Beobachtungen',
          ),
        ],
      ),
    );
  }
}

/// Read-only view of the patient's timeline.
class _CaregiverTimelineTab extends StatelessWidget {
  const _CaregiverTimelineTab({required this.patientId});

  final String patientId;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Patienten-Plan'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async => AuthService().signOut(),
          ),
        ],
      ),
      body: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
        stream: FirebaseFirestore.instance
            .collection(FirestorePaths.timelineCollection(patientId))
            .orderBy('scheduledAt')
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(child: Text('Fehler: ${snapshot.error}'));
          }
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final docs = snapshot.data?.docs ?? [];
          if (docs.isEmpty) {
            return const Center(
              child: Text('Noch keine Aufgaben im Plan.'),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(12),
            itemCount: docs.length,
            itemBuilder: (context, index) {
              final data = docs[index].data();
              final title = data['title'] as String? ?? '';
              final subtitle = data['subtitle'] as String? ?? '';
              final state = data['state'] as String? ?? 'planned';
              final isDone = state == 'done' || state == 'skipped';

              return Card(
                child: ListTile(
                  leading: Icon(
                    isDone
                        ? Icons.check_circle
                        : Icons.radio_button_unchecked,
                    color: isDone ? Colors.green : null,
                  ),
                  title: Text(
                    title,
                    style: isDone
                        ? const TextStyle(
                            decoration: TextDecoration.lineThrough)
                        : null,
                  ),
                  subtitle: subtitle.isNotEmpty ? Text(subtitle) : null,
                  trailing: Text(
                    state.toUpperCase(),
                    style: TextStyle(
                      fontSize: 10,
                      color: isDone ? Colors.green : Colors.orange,
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}

/// Tab for viewing and creating caregiver observations.
class _CaregiverObservationsTab extends StatelessWidget {
  _CaregiverObservationsTab({required this.patientId});

  final String patientId;
  final ObservationRepository _repo = ObservationRepository();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Meine Beobachtungen')),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddObservationDialog(context),
        child: const Icon(Icons.add),
      ),
      body: StreamBuilder<List<ObservationEntry>>(
        stream: _repo.watchObservations(patientId),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(child: Text('Fehler: ${snapshot.error}'));
          }
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final entries = snapshot.data ?? [];
          if (entries.isEmpty) {
            return const Center(
              child: Text('Noch keine Beobachtungen eingetragen.'),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(12),
            itemCount: entries.length,
            itemBuilder: (context, index) {
              final entry = entries[index];
              return Card(
                child: ListTile(
                  leading: _severityIcon(entry.severity),
                  title: Text(entry.text,
                      maxLines: 2, overflow: TextOverflow.ellipsis),
                  subtitle: Text(
                    '${entry.authorName} · ${_formatDate(entry.createdAt)}',
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  void _showAddObservationDialog(BuildContext context) {
    final textController = TextEditingController();
    var selectedSeverity = ObservationSeverity.info;

    showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: const Text('Neue Beobachtung'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: textController,
                    maxLines: 4,
                    decoration: const InputDecoration(
                      labelText: 'Beobachtung',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 12),
                  SegmentedButton<ObservationSeverity>(
                    segments: const [
                      ButtonSegment(
                        value: ObservationSeverity.info,
                        label: Text('Info'),
                        icon: Icon(Icons.info_outline),
                      ),
                      ButtonSegment(
                        value: ObservationSeverity.warning,
                        label: Text('Warnung'),
                        icon: Icon(Icons.warning_amber),
                      ),
                      ButtonSegment(
                        value: ObservationSeverity.critical,
                        label: Text('Kritisch'),
                        icon: Icon(Icons.error_outline),
                      ),
                    ],
                    selected: {selectedSeverity},
                    onSelectionChanged: (selection) {
                      setDialogState(
                          () => selectedSeverity = selection.first);
                    },
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(dialogContext).pop(),
                  child: const Text('Abbrechen'),
                ),
                FilledButton(
                  onPressed: () async {
                    final text = textController.text.trim();
                    if (text.isEmpty) return;
                    await _repo.addObservation(
                      patientId: patientId,
                      text: text,
                      severity: selectedSeverity,
                    );
                    if (dialogContext.mounted) {
                      Navigator.of(dialogContext).pop();
                    }
                  },
                  child: const Text('Speichern'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Widget _severityIcon(ObservationSeverity severity) {
    switch (severity) {
      case ObservationSeverity.info:
        return const Icon(Icons.info_outline, color: Colors.blue);
      case ObservationSeverity.warning:
        return const Icon(Icons.warning_amber, color: Colors.orange);
      case ObservationSeverity.critical:
        return const Icon(Icons.error_outline, color: Colors.red);
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}.'
        '${date.month.toString().padLeft(2, '0')}.'
        '${date.year} '
        '${date.hour.toString().padLeft(2, '0')}:'
        '${date.minute.toString().padLeft(2, '0')}';
  }
}

