import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../../auth/auth_service.dart';

class UsersTab extends StatefulWidget {
  const UsersTab({super.key});

  @override
  State<UsersTab> createState() => _UsersTabState();
}

class _UsersTabState extends State<UsersTab> {
  final _searchController = TextEditingController();
  List<Map<String, dynamic>> _results = [];
  bool _loading = false;

  static const _roleLabels = <String, String>{
    'patient': 'Patient',
    'doctor': 'Arzt',
    'caregiver': 'Begleiter',
    'admin': 'Admin',
    'superAdmin': 'Super-Admin',
  };

  static const _roleColors = <String, Color>{
    'patient': Colors.blue,
    'doctor': Colors.teal,
    'caregiver': Colors.orange,
    'admin': Colors.deepPurple,
    'superAdmin': Colors.red,
  };

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

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
        _results =
            snap.docs.map((d) => {'uid': d.id, ...d.data()}).toList();
      });
    } catch (e) {
      if (kDebugMode) debugPrint('[UsersTab] search error: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Suche fehlgeschlagen.')),
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
      builder: (ctx) => AlertDialog(
        title: const Text('Rolle ändern'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: roles.map((r) {
            final selected = r == currentRole;
            return ListTile(
              leading: Icon(
                selected ? Icons.radio_button_checked : Icons.radio_button_off,
                color: _roleColors[r],
              ),
              title: Text(_roleLabels[r] ?? r),
              selected: selected,
              onTap: () => Navigator.of(ctx).pop(r),
            );
          }).toList(),
        ),
      ),
    );

    if (newRole == null || newRole == currentRole) return;

    // Confirmation for critical changes
    if (newRole == 'admin' || newRole == 'superAdmin') {
      if (!mounted) return;
      final confirmed = await showDialog<bool>(
        context: context,
        builder: (ctx) => AlertDialog(
          title: const Text('Sicher?'),
          content: Text(
            'Nutzer "$uid" wird ${_roleLabels[newRole]}. '
            'Das gewährt erweiterte Berechtigungen.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(false),
              child: const Text('Abbrechen'),
            ),
            FilledButton(
              onPressed: () => Navigator.of(ctx).pop(true),
              child: const Text('Bestätigen'),
            ),
          ],
        ),
      );
      if (confirmed != true) return;
    }

    try {
      final fn = FirebaseFunctions.instanceFor(region: 'europe-west1');
      await fn.httpsCallable('setUserRole').call<void>(
        {'uid': uid, 'role': newRole},
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Rolle auf "${_roleLabels[newRole]}" geändert.'),
          ),
        );
        _search(); // refresh
      }
    } catch (e) {
      if (kDebugMode) debugPrint('[UsersTab] changeRole error: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Rolle konnte nicht geändert werden.')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Nutzer verwalten'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Abmelden',
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
                  onPressed: _loading ? null : _search,
                  child: const Text('Suchen'),
                ),
              ],
            ),
            const SizedBox(height: 16),
            if (_loading) const LinearProgressIndicator(),
            Expanded(
              child: _results.isEmpty
                  ? Center(
                      child: Text(
                        'Nutzer per E-Mail oder UID suchen',
                        style: TextStyle(color: cs.onSurfaceVariant),
                      ),
                    )
                  : ListView.builder(
                      itemCount: _results.length,
                      itemBuilder: (context, index) {
                        final user = _results[index];
                        return _UserCard(
                          user: user,
                          onChangeRole: () => _changeRole(
                            user['uid'] as String,
                            user['role'] as String? ?? 'patient',
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

class _UserCard extends StatelessWidget {
  const _UserCard({required this.user, required this.onChangeRole});

  final Map<String, dynamic> user;
  final VoidCallback onChangeRole;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final uid = user['uid'] as String;
    final email = user['email'] as String? ?? '–';
    final role = user['role'] as String? ?? 'patient';
    final isPro = user['isPro'] as bool? ?? false;
    final proExpires = user['proExpiresAt'] as Timestamp?;

    final roleColor = _UsersTabState._roleColors[role] ?? Colors.grey;
    final roleLabel = _UsersTabState._roleLabels[role] ?? role;

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    email,
                    style: Theme.of(context).textTheme.titleMedium,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Chip(
                  label: Text(
                    roleLabel,
                    style: TextStyle(
                      color: cs.surface,
                      fontSize: 12,
                    ),
                  ),
                  backgroundColor: roleColor,
                  padding: EdgeInsets.zero,
                  materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              'UID: $uid',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: cs.onSurfaceVariant,
                  ),
            ),
            if (isPro) ...[
              const SizedBox(height: 4),
              Row(
                children: [
                  Icon(Icons.star, size: 16, color: Colors.amber.shade700),
                  const SizedBox(width: 4),
                  Text(
                    proExpires != null
                        ? 'Pro bis ${_formatDate(proExpires)}'
                        : 'Pro aktiv',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Colors.amber.shade700,
                          fontWeight: FontWeight.w600,
                        ),
                  ),
                ],
              ),
            ],
            const SizedBox(height: 8),
            Align(
              alignment: Alignment.centerRight,
              child: OutlinedButton.icon(
                onPressed: onChangeRole,
                icon: const Icon(Icons.edit, size: 16),
                label: const Text('Rolle ändern'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatDate(Timestamp ts) {
    final d = ts.toDate();
    return '${d.day.toString().padLeft(2, '0')}.'
        '${d.month.toString().padLeft(2, '0')}.'
        '${d.year}';
  }
}
