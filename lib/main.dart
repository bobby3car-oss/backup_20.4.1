import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'firebase_options.dart';
import 'features/documents/presentation/documents_screen.dart';
import 'features/wound/domain/wound_entry.dart';
import 'features/wound/presentation/wound_compare_screen.dart';
import 'features/wound/presentation/wound_entry_detail_screen.dart';
import 'features/wound/presentation/wound_history_screen.dart';
import 'features/wound/presentation/wound_screen.dart';
import 'notifications/local_notifications.dart';
import 'navigation/main_navigation.dart';
import 'ui/theme/app_theme.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  if (kDebugMode) {
    ErrorWidget.builder = (details) {
      return Material(
        color: const Color(0xFFF7F8FC),
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Container(
              constraints: const BoxConstraints(maxWidth: 520),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0x33FF3B30)),
              ),
              child: Text(
                'UI Error\n${details.exceptionAsString()}',
                style: const TextStyle(
                  color: Color(0xFF1C1C1E),
                  fontSize: 13,
                  height: 1.4,
                ),
              ),
            ),
          ),
        ),
      );
    };
  }

  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  } catch (error, stackTrace) {
    if (kDebugMode) {
      debugPrint('[main] Firebase init skipped: $error');
      debugPrintStack(stackTrace: stackTrace);
    }
  }
  await LocalNotifications.init();
  await LocalNotifications.requestPermissionsIfNeeded();
  runApp(const OperationsbegleiterApp());
}

class OperationsbegleiterApp extends StatelessWidget {
  const OperationsbegleiterApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Operationsbegleiter',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      home: const MainNavigation(),
      routes: {
        '/wound': (_) => const WoundScreen(),
        '/wound-history': (_) => WoundHistoryScreen(),
        '/wound-detail': (context) {
          final args = ModalRoute.of(context)?.settings.arguments;
          final entry = _extractWoundEntry(args);
          if (entry == null) {
            return const _NamedPlaceholderScreen(
              title: 'Wunddetail (fehlende Argumente)',
            );
          }
          return WoundEntryDetailScreen(entry: entry);
        },
        '/wound-compare': (context) {
          final args = ModalRoute.of(context)?.settings.arguments;
          final compareEntries = _extractCompareEntries(args);
          if (compareEntries == null) {
            return const _NamedPlaceholderScreen(
              title: 'Wundvergleich (fehlende Argumente)',
            );
          }
          return WoundCompareScreen(
            entryA: compareEntries.$1,
            entryB: compareEntries.$2,
          );
        },
        '/meds': (_) => const _NamedPlaceholderScreen(title: 'Medikamente'),
        '/checklist': (_) => const _NamedPlaceholderScreen(title: 'Checkliste'),
        '/appointment': (_) => const _NamedPlaceholderScreen(title: 'Termin'),
        '/messages': (_) => const _NamedPlaceholderScreen(title: 'Nachrichten'),
        '/documents': (_) => const DocumentsScreen(),
      },
    );
  }
}

WoundEntry? _extractWoundEntry(Object? args) {
  if (args is WoundEntry) return args;
  if (args is Map && args['entry'] is WoundEntry) {
    return args['entry'] as WoundEntry;
  }
  return null;
}

(WoundEntry, WoundEntry)? _extractCompareEntries(Object? args) {
  if (args is Map && args['entryA'] is WoundEntry && args['entryB'] is WoundEntry) {
    return (args['entryA'] as WoundEntry, args['entryB'] as WoundEntry);
  }
  if (args is List && args.length >= 2 && args[0] is WoundEntry && args[1] is WoundEntry) {
    return (args[0] as WoundEntry, args[1] as WoundEntry);
  }
  return null;
}

class _NamedPlaceholderScreen extends StatelessWidget {
  const _NamedPlaceholderScreen({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'In Arbeit',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Zurück'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class PatientsScreen extends StatelessWidget {
  const PatientsScreen({super.key});

  Future<void> _addTestPatient() async {
    final now = DateTime.now();
    await FirebaseFirestore.instance.collection('patients').add({
      'name': 'Test Patient ${now.hour}:${now.minute}:${now.second}',
      'birthDate': '01.01.1990',
      'diagnosis': 'Test',
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  @override
  Widget build(BuildContext context) {
    final patientsStream = FirebaseFirestore.instance
        .collection('patients')
        .orderBy('createdAt', descending: true)
        .snapshots();

    return Scaffold(
      appBar: AppBar(title: const Text('Patienten')),
      floatingActionButton: FloatingActionButton(
        onPressed: _addTestPatient,
        child: const Icon(Icons.add),
      ),
      body: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
        stream: patientsStream,
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
              child: Text('Noch keine Patienten. Tippe auf +'),
            );
          }

          return ListView.separated(
            itemCount: docs.length,
            separatorBuilder: (_, __) => const Divider(height: 1),
            itemBuilder: (context, index) {
              final data = docs[index].data();
              final name = (data['name'] ?? 'Unbenannt') as String;
              final birthDate = (data['birthDate'] ?? '') as String;
              final diagnosis = (data['diagnosis'] ?? '') as String;

              return ListTile(
                title: Text(name),
                subtitle: Text(
                  [birthDate, diagnosis].where((s) => s.isNotEmpty).join(' • '),
                ),
                trailing: const Icon(Icons.chevron_right),
                onTap: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Patient geöffnet: $name')),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}
