import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'widgets/admin_confirmation_dialog.dart';
import 'widgets/csv_export.dart';

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
    'family': 'Angehöriger',
    'admin': 'Admin',
  };

  static const _roleColors = <String, Color>{
    'patient': Colors.blue,
    'doctor': Colors.teal,
    'family': Colors.orange,
    'admin': Colors.deepPurple,
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
    const roles = ['patient', 'doctor', 'family', 'admin'];
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
    if (newRole == 'admin') {
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

  Future<void> _disableUser(String uid, bool currentlyDisabled) async {
    final action = currentlyDisabled ? 'entsperren' : 'sperren';
    if (!mounted) return;
    final confirmed = await AdminConfirmationDialog.show(
      context,
      title: 'User $action?',
      message: currentlyDisabled
          ? 'Der Nutzer kann sich wieder einloggen.'
          : 'Der Nutzer wird sofort ausgeloggt und kann sich nicht mehr einloggen.',
      severity: currentlyDisabled
          ? AdminActionSeverity.normal
          : AdminActionSeverity.dangerous,
      confirmLabel: currentlyDisabled ? 'Entsperren' : 'Sperren',
    );
    if (!confirmed) return;

    try {
      final fn = FirebaseFunctions.instanceFor(region: 'europe-west1');
      await fn.httpsCallable('disableUser').call<void>({
        'uid': uid,
        'disabled': !currentlyDisabled,
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('User ${currentlyDisabled ? 'entsperrt' : 'gesperrt'}.')),
        );
        _search();
      }
    } catch (e) {
      if (kDebugMode) debugPrint('[UsersTab] disableUser error: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('User konnte nicht ${action}t werden.')),
        );
      }
    }
  }

  Future<void> _deleteUser(String uid, String email) async {
    if (!mounted) return;
    final confirmed = await AdminConfirmationDialog.show(
      context,
      title: 'User löschen (DSGVO)?',
      message: 'ALLE Daten von "$email" werden unwiderruflich gelöscht: '
          'Account, Patientendaten, Links, Dateien.',
      severity: AdminActionSeverity.destructive,
      confirmLabel: 'Endgültig löschen',
      confirmationText: 'LÖSCHEN',
    );
    if (!confirmed) return;

    try {
      final fn = FirebaseFunctions.instanceFor(region: 'europe-west1');
      await fn.httpsCallable('deleteUserAccount').call<void>({'uid': uid});
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('User und alle Daten gelöscht.')),
        );
        setState(() => _results.removeWhere((r) => r['uid'] == uid));
      }
    } catch (e) {
      if (kDebugMode) debugPrint('[UsersTab] deleteUser error: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Löschung fehlgeschlagen.')),
        );
      }
    }
  }

  Future<void> _togglePro(String uid, bool currentlyPro) async {
    if (!mounted) return;
    if (currentlyPro) {
      final confirmed = await AdminConfirmationDialog.show(
        context,
        title: 'Pro-Status entziehen?',
        message: 'Der Nutzer verliert sofort den Pro-Zugang.',
        severity: AdminActionSeverity.dangerous,
        confirmLabel: 'Pro entziehen',
      );
      if (!confirmed) return;
    }

    // For granting Pro, let admin pick duration
    int? grantDays;
    if (!currentlyPro) {
      grantDays = await showDialog<int>(
        context: context,
        builder: (ctx) => _ProDurationDialog(),
      );
      if (grantDays == null) return;
    }

    try {
      final fn = FirebaseFunctions.instanceFor(region: 'europe-west1');
      final params = <String, dynamic>{
        'uid': uid,
        'isPro': !currentlyPro,
      };
      if (grantDays != null) params['grantDays'] = grantDays;
      await fn.httpsCallable('setProStatus').call<void>(params);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(currentlyPro ? 'Pro entfernt.' : 'Pro für $grantDays Tage vergeben.')),
      );
      _search();
    } catch (e) {
      if (kDebugMode) debugPrint('[UsersTab] togglePro error: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Pro-Status konnte nicht geändert werden.')),
        );
      }
    }
  }

  Future<void> _exportCsv(BuildContext context) async {
    await exportCsv(
      context: context,
      fileName: 'nutzer_export.csv',
      headers: ['UID', 'E-Mail', 'Rolle', 'Pro', 'Deaktiviert'],
      rows: _results.map((u) => [
        (u['uid'] ?? '').toString(),
        (u['email'] ?? '').toString(),
        (u['role'] ?? 'patient').toString(),
        (u['isPro'] == true) ? 'Ja' : 'Nein',
        (u['disabled'] == true) ? 'Ja' : 'Nein',
      ]).toList(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Nutzer verwalten'),
        actions: [
          if (_results.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.download),
              tooltip: 'CSV exportieren',
              onPressed: () => _exportCsv(context),
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
                        final uid = user['uid'] as String;
                        final role = user['role'] as String? ?? 'patient';
                        final isPro = user['isPro'] as bool? ?? false;
                        final disabled = user['disabled'] as bool? ?? false;
                        return _UserCard(
                          user: user,
                          onChangeRole: () => _changeRole(uid, role),
                          onDisable: () => _disableUser(uid, disabled),
                          onDelete: () => _deleteUser(
                            uid, user['email'] as String? ?? uid),
                          onTogglePro: () => _togglePro(uid, isPro),
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
  const _UserCard({
    required this.user,
    required this.onChangeRole,
    required this.onDisable,
    required this.onDelete,
    required this.onTogglePro,
  });

  final Map<String, dynamic> user;
  final VoidCallback onChangeRole;
  final VoidCallback onDisable;
  final VoidCallback onDelete;
  final VoidCallback onTogglePro;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final uid = user['uid'] as String;
    final email = user['email'] as String? ?? '–';
    final role = user['role'] as String? ?? 'patient';
    final isPro = user['isPro'] as bool? ?? false;
    final disabled = user['disabled'] as bool? ?? false;
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
                if (disabled)
                  Padding(
                    padding: const EdgeInsets.only(right: 6),
                    child: Chip(
                      label: Text('Gesperrt',
                        style: TextStyle(color: cs.onError, fontSize: 11)),
                      backgroundColor: cs.error,
                      padding: EdgeInsets.zero,
                      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                  ),
                Chip(
                  label: Text(
                    roleLabel,
                    style: TextStyle(color: Colors.white, fontSize: 12),
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
                  Icon(Icons.star, size: 16, color: Colors.amber.shade600),
                  const SizedBox(width: 4),
                  Text(
                    proExpires != null
                        ? 'Pro bis ${_formatDate(proExpires)}'
                        : 'Pro aktiv',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Colors.amber.shade600,
                          fontWeight: FontWeight.w600,
                        ),
                  ),
                ],
              ),
            ],
            const SizedBox(height: 10),
            // Action buttons
            Wrap(
              spacing: 8,
              runSpacing: 6,
              children: [
                OutlinedButton.icon(
                  onPressed: onChangeRole,
                  icon: const Icon(Icons.edit, size: 16),
                  label: const Text('Rolle'),
                ),
                OutlinedButton.icon(
                  onPressed: onTogglePro,
                  icon: Icon(isPro ? Icons.star_border : Icons.star, size: 16),
                  label: Text(isPro ? 'Pro entziehen' : 'Pro geben'),
                ),
                OutlinedButton.icon(
                  onPressed: onDisable,
                  icon: Icon(
                    disabled ? Icons.lock_open : Icons.block,
                    size: 16,
                  ),
                  label: Text(disabled ? 'Entsperren' : 'Sperren'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: disabled ? Colors.green : Colors.orange,
                    side: BorderSide(
                      color: disabled ? Colors.green : Colors.orange),
                  ),
                ),
                OutlinedButton.icon(
                  onPressed: onDelete,
                  icon: const Icon(Icons.delete_forever, size: 16),
                  label: const Text('Löschen'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: cs.error,
                    side: BorderSide(color: cs.error),
                  ),
                ),
              ],
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

class _ProDurationDialog extends StatefulWidget {
  @override
  State<_ProDurationDialog> createState() => _ProDurationDialogState();
}

class _ProDurationDialogState extends State<_ProDurationDialog> {
  int _days = 365;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Pro-Zugang vergeben'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text('Wie viele Tage Pro-Zugang?'),
          const SizedBox(height: 16),
          SegmentedButton<int>(
            segments: const [
              ButtonSegment(value: 30, label: Text('30')),
              ButtonSegment(value: 90, label: Text('90')),
              ButtonSegment(value: 180, label: Text('180')),
              ButtonSegment(value: 365, label: Text('365')),
            ],
            selected: {_days},
            onSelectionChanged: (v) => setState(() => _days = v.first),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Abbrechen'),
        ),
        FilledButton(
          onPressed: () => Navigator.of(context).pop(_days),
          child: Text('$_days Tage vergeben'),
        ),
      ],
    );
  }
}
