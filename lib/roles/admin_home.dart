import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../auth/auth_service.dart';

class AdminHome extends StatefulWidget {
  const AdminHome({super.key});

  @override
  State<AdminHome> createState() => _AdminHomeState();
}

class _AdminHomeState extends State<AdminHome> {
  int _currentIndex = 0;

  static const _screens = <Widget>[
    _UsersTab(),
    _ProKeysTab(),
    _AuditLogTab(),
    _StatsTab(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(index: _currentIndex, children: _screens),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: (i) => setState(() => _currentIndex = i),
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.people_outline),
            selectedIcon: Icon(Icons.people),
            label: 'Nutzer',
          ),
          NavigationDestination(
            icon: Icon(Icons.vpn_key_outlined),
            selectedIcon: Icon(Icons.vpn_key),
            label: 'Pro-Keys',
          ),
          NavigationDestination(
            icon: Icon(Icons.history_outlined),
            selectedIcon: Icon(Icons.history),
            label: 'Audit-Log',
          ),
          NavigationDestination(
            icon: Icon(Icons.analytics_outlined),
            selectedIcon: Icon(Icons.analytics),
            label: 'Statistiken',
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────
// TAB 1: Users
// ─────────────────────────────────────────────────
class _UsersTab extends StatefulWidget {
  const _UsersTab();

  @override
  State<_UsersTab> createState() => _UsersTabState();
}

class _UsersTabState extends State<_UsersTab> {
  final _searchController = TextEditingController();
  List<Map<String, dynamic>> _results = [];
  bool _loading = false;

  Future<void> _search() async {
    final query = _searchController.text.trim();
    if (query.isEmpty) return;

    setState(() => _loading = true);

    try {
      // Search by email
      var snap = await FirebaseFirestore.instance
          .collection('users')
          .where('email', isEqualTo: query)
          .limit(5)
          .get();

      // Fallback: try UID
      if (snap.docs.isEmpty) {
        final docSnap = await FirebaseFirestore.instance
            .collection('users')
            .doc(query)
            .get();
        if (docSnap.exists) {
          snap = await FirebaseFirestore.instance
              .collection('users')
              .where(FieldPath.documentId, isEqualTo: query)
              .limit(1)
              .get();
        }
      }

      setState(() {
        _results = snap.docs
            .map((d) => {'uid': d.id, ...d.data()})
            .toList();
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Fehler: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _changeRole(String uid, String currentRole) async {
    const roles = ['patient', 'doctor', 'caregiver', 'admin', 'superAdmin'];
    final newRole = await showDialog<String>(
      context: context,
      builder: (ctx) => SimpleDialog(
        title: const Text('Rolle ändern'),
        children: roles.map((r) {
          return SimpleDialogOption(
            onPressed: () => Navigator.of(ctx).pop(r),
            child: ListTile(
              title: Text(r),
              trailing: r == currentRole
                  ? const Icon(Icons.check, color: Colors.green)
                  : null,
            ),
          );
        }).toList(),
      ),
    );

    if (newRole == null || newRole == currentRole) return;

    try {
      final fn = FirebaseFunctions.instanceFor(region: 'europe-west1');
      await fn.httpsCallable('setUserRole').call<void>(
        {'uid': uid, 'newRole': newRole},
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Rolle auf "$newRole" geändert.')),
        );
        _search(); // refresh
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Fehler: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Nutzer verwalten'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async => AuthService().signOut(),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _searchController,
                    decoration: const InputDecoration(
                      labelText: 'E-Mail oder UID',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.search),
                    ),
                    onSubmitted: (_) => _search(),
                  ),
                ),
                const SizedBox(width: 8),
                FilledButton(
                  onPressed: _search,
                  child: const Text('Suchen'),
                ),
              ],
            ),
            const SizedBox(height: 16),
            if (_loading) const CircularProgressIndicator(),
            Expanded(
              child: ListView.builder(
                itemCount: _results.length,
                itemBuilder: (context, index) {
                  final user = _results[index];
                  final uid = user['uid'] as String;
                  final email = user['email'] as String? ?? '–';
                  final role = user['role'] as String? ?? '–';

                  return Card(
                    child: ListTile(
                      title: Text(email),
                      subtitle: Text('UID: $uid\nRolle: $role'),
                      isThreeLine: true,
                      trailing: IconButton(
                        icon: const Icon(Icons.edit),
                        onPressed: () => _changeRole(uid, role),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────
// TAB 2: Pro-Keys
// ─────────────────────────────────────────────────
class _ProKeysTab extends StatelessWidget {
  const _ProKeysTab();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Pro-Keys')),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _createKey(context),
        child: const Icon(Icons.add),
      ),
      body: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
        stream: FirebaseFirestore.instance
            .collection('proKeys')
            .orderBy('createdAt', descending: true)
            .limit(100)
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
            return const Center(child: Text('Keine Pro-Keys vorhanden.'));
          }

          return ListView.builder(
            padding: const EdgeInsets.all(12),
            itemCount: docs.length,
            itemBuilder: (context, index) {
              final data = docs[index].data();
              final code = docs[index].id;
              final active = data['active'] as bool? ?? true;
              final usedBy = data['usedBy'] as String?;

              return Card(
                child: ListTile(
                  leading: Icon(
                    active ? Icons.vpn_key : Icons.block,
                    color: active ? Colors.green : Colors.red,
                  ),
                  title: Text(code, style: const TextStyle(fontSize: 13)),
                  subtitle: Text(usedBy != null
                      ? 'Eingelöst von: $usedBy'
                      : (active ? 'Verfügbar' : 'Deaktiviert')),
                  trailing: active && usedBy == null
                      ? IconButton(
                          icon: const Icon(Icons.copy, size: 18),
                          onPressed: () {
                            Clipboard.setData(ClipboardData(text: code));
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Kopiert!')),
                            );
                          },
                        )
                      : null,
                ),
              );
            },
          );
        },
      ),
    );
  }

  Future<void> _createKey(BuildContext context) async {
    try {
      final fn = FirebaseFunctions.instanceFor(region: 'europe-west1');
      final result =
          await fn.httpsCallable('createProKey').call<Map<String, dynamic>>(
        <String, dynamic>{},
      );
      final code = result.data['code'] ?? '?';
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Key erstellt: $code')),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Fehler: $e')),
        );
      }
    }
  }
}

// ─────────────────────────────────────────────────
// TAB 3: Audit-Log
// ─────────────────────────────────────────────────
class _AuditLogTab extends StatelessWidget {
  const _AuditLogTab();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Audit-Log')),
      body: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
        stream: FirebaseFirestore.instance
            .collection('auditLog')
            .orderBy('timestamp', descending: true)
            .limit(200)
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
            return const Center(child: Text('Keine Einträge.'));
          }

          return ListView.builder(
            padding: const EdgeInsets.all(12),
            itemCount: docs.length,
            itemBuilder: (context, index) {
              final data = docs[index].data();
              final action = data['action'] as String? ?? '–';
              final actor = data['actorUid'] as String? ?? '–';
              final ts = data['timestamp'] as Timestamp?;
              final detail = data['detail'] as String?;

              return Card(
                child: ListTile(
                  leading: const Icon(Icons.receipt_long),
                  title: Text(action),
                  subtitle: Text(
                    'Von: $actor\n'
                    '${ts != null ? _formatTimestamp(ts) : ''}'
                    '${detail != null ? '\n$detail' : ''}',
                  ),
                  isThreeLine: detail != null,
                ),
              );
            },
          );
        },
      ),
    );
  }

  String _formatTimestamp(Timestamp ts) {
    final d = ts.toDate();
    return '${d.day.toString().padLeft(2, '0')}.'
        '${d.month.toString().padLeft(2, '0')}.'
        '${d.year} '
        '${d.hour.toString().padLeft(2, '0')}:'
        '${d.minute.toString().padLeft(2, '0')}';
  }
}

// ─────────────────────────────────────────────────
// TAB 4: Stats
// ─────────────────────────────────────────────────
class _StatsTab extends StatefulWidget {
  const _StatsTab();

  @override
  State<_StatsTab> createState() => _StatsTabState();
}

class _StatsTabState extends State<_StatsTab> {
  bool _refreshing = false;

  Future<void> _refreshStats() async {
    setState(() => _refreshing = true);
    try {
      final fn = FirebaseFunctions.instanceFor(region: 'europe-west1');
      await fn.httpsCallable('getAdminStats').call<void>({});
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Fehler: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _refreshing = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Statistiken'),
        actions: [
          IconButton(
            onPressed: _refreshing ? null : _refreshStats,
            icon: _refreshing
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.refresh),
          ),
        ],
      ),
      body: StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
        stream: FirebaseFirestore.instance
            .doc('adminStats/global')
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(child: Text('Fehler: ${snapshot.error}'));
          }
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final data = snapshot.data?.data();
          if (data == null || data.isEmpty) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text('Noch keine Statistik generiert.'),
                  const SizedBox(height: 12),
                  FilledButton.icon(
                    onPressed: _refreshing ? null : _refreshStats,
                    icon: const Icon(Icons.refresh),
                    label: const Text('Jetzt generieren'),
                  ),
                ],
              ),
            );
          }

          final totalUsers = data['totalUsers'] ?? 0;
          final totalPatients = data['totalPatients'] ?? 0;
          final totalDoctors = data['totalDoctors'] ?? 0;
          final totalCaregivers = data['totalCaregivers'] ?? 0;
          final proActive = data['proActive'] ?? 0;
          final updatedAt = data['updatedAt'] as Timestamp?;

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              _StatCard(label: 'Nutzer gesamt', value: '$totalUsers'),
              _StatCard(label: 'Patienten', value: '$totalPatients'),
              _StatCard(label: 'Ärzte', value: '$totalDoctors'),
              _StatCard(label: 'Begleiter', value: '$totalCaregivers'),
              _StatCard(label: 'Aktive Pro-Lizenzen', value: '$proActive'),
              if (updatedAt != null)
                Padding(
                  padding: const EdgeInsets.only(top: 24),
                  child: Text(
                    'Zuletzt aktualisiert: '
                    '${_formatTimestamp(updatedAt)}',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ),
            ],
          );
        },
      ),
    );
  }

  String _formatTimestamp(Timestamp ts) {
    final d = ts.toDate();
    return '${d.day.toString().padLeft(2, '0')}.'
        '${d.month.toString().padLeft(2, '0')}.'
        '${d.year} '
        '${d.hour.toString().padLeft(2, '0')}:'
        '${d.minute.toString().padLeft(2, '0')}';
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label, style: Theme.of(context).textTheme.titleMedium),
            Text(
              value,
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
          ],
        ),
      ),
    );
  }
}
