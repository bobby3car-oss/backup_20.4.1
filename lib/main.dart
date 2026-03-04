import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'firebase_options.dart';
import 'navigation/main_navigation.dart';
import 'ui/theme/app_theme.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
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
    final patientsStream =
        FirebaseFirestore.instance.collection('patients').orderBy('createdAt', descending: true).snapshots();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Patienten'),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _addTestPatient,
        child: const Icon(Icons.add),
      ),
      body: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
        stream: patientsStream,
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(
              child: Text('Fehler: ${snapshot.error}'),
            );
          }
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final docs = snapshot.data?.docs ?? [];
          if (docs.isEmpty) {
            return const Center(child: Text('Noch keine Patienten. Tippe auf +'));
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
                subtitle: Text([birthDate, diagnosis].where((s) => s.isNotEmpty).join(' • ')),
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