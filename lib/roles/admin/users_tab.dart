import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import '../../l10n/app_localizations.dart';

import '../../ui/error_helpers.dart';
import 'admin_functions.dart';
import 'admin_role_metadata.dart';

import 'widgets/admin_confirmation_dialog.dart';
import 'widgets/csv_export.dart';

class UsersTab extends StatefulWidget {
  const UsersTab({super.key});

  @override
  State<UsersTab> createState() => _UsersTabState();
}

class _UsersTabState extends State<UsersTab> {
  final _searchController = TextEditingController();
  String _searchQuery = '';
  String? _roleFilter;
  List<Map<String, dynamic>> _csvData = [];

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

  List<Map<String, dynamic>> _applyFilters(
      List<Map<String, dynamic>> users) {
    var result = users;
    if (_roleFilter != null) {
      result = result
          .where((u) => (u['role'] ?? 'patient') == _roleFilter)
          .toList();
    }
    if (_searchQuery.isNotEmpty) {
      result = result.where((u) {
        final email = (u['email'] ?? '').toString().toLowerCase();
        final uid = (u['uid'] ?? '').toString().toLowerCase();
        final name = (u['displayName'] ?? '').toString().toLowerCase();
        return email.contains(_searchQuery) ||
            uid.contains(_searchQuery) ||
            name.contains(_searchQuery);
      }).toList();
    }
    return result;
  }

  Future<void> _changeRole(String uid, String currentRole) async {
    const roles = ['patient', 'doctor', 'staff', 'organisation', 'admin'];
    final newRole = await showDialog<String>(
      context: context,
      builder: (ctx) {
        final l = AppLocalizations.of(ctx)!;
        return AlertDialog(
        title: Text(l.roleChange),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: roles.map((r) {
            final selected = r == currentRole;
            return ListTile(
              leading: Icon(
                selected ? Icons.radio_button_checked : Icons.radio_button_off,
                color: adminRoleColors[r],
              ),
              title: Text(adminRoleLabels[r] ?? r),
              selected: selected,
              onTap: () => Navigator.of(ctx).pop(r),
            );
          }).toList(),
        ),
      );
      },
    );

    if (newRole == null || newRole == currentRole) return;

    // Confirmation for critical changes
    if (newRole == 'admin') {
      if (!mounted) return;
      final confirmed = await showDialog<bool>(
        context: context,
        builder: (ctx) {
          final l = AppLocalizations.of(ctx)!;
          return AlertDialog(
          title: Text(l.sureQuestion),
          content: Text(
            'Nutzer "$uid" wird ${adminRoleLabels[newRole]}. '
            'Das gewährt erweiterte Berechtigungen.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(false),
              child: Text(l.cancel),
            ),
            FilledButton(
              onPressed: () => Navigator.of(ctx).pop(true),
              child: Text(l.confirm),
            ),
          ],
        );
        },
      );
      if (confirmed != true) return;
    }

    try {
      await adminFunctions().httpsCallable('setUserRole').call<void>(
        {'uid': uid, 'role': newRole},
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Rolle auf "${adminRoleLabels[newRole]}" geändert.'),
          ),
        );
      }
    } catch (e) {
      if (kDebugMode) debugPrint('[UsersTab] changeRole error: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(AppLocalizations.of(context)!.roleChangeError)),
        );
      }
    }
  }

  Future<void> _disableUser(String uid, bool currentlyDisabled) async {
    final l = AppLocalizations.of(context)!;
    final action = currentlyDisabled ? 'entsperren' : 'sperren';

    // When disabling: ask for an optional internal reason first
    String? reason;
    if (!currentlyDisabled) {
      if (!mounted) return;
      final reasonCtrl = TextEditingController();
      reason = await showDialog<String>(
        context: context,
        builder: (ctx) {
          final l = AppLocalizations.of(ctx)!;
          return AlertDialog(
          title: Text(l.adminUserLock),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(l.internalCommentOptional),
              const SizedBox(height: 12),
              TextField(
                controller: reasonCtrl,
                maxLines: 3,
                decoration: const InputDecoration(
                  hintText: 'Grund der Sperrung …',
                  border: OutlineInputBorder(),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: Text(l.cancel),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(ctx, reasonCtrl.text.trim()),
              style: FilledButton.styleFrom(
                  backgroundColor: Colors.orange),
              child: Text(l.next),
            ),
          ],
        );
        },
      );
      reasonCtrl.dispose();
      if (reason == null) return; // cancelled
    }

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
      confirmLabel: currentlyDisabled ? l.unlock : 'Sperren',
    );
    if (!confirmed) return;

    try {
      await adminFunctions().httpsCallable('disableUser').call<void>({
        'uid': uid,
        'disabled': !currentlyDisabled,
      });
      // Persist or clear the disable-reason in Firestore
      final userDoc = FirebaseFirestore.instance.doc('users/$uid');
      if (!currentlyDisabled) {
        final data = <String, dynamic>{
          'disabledAt': FieldValue.serverTimestamp(),
        };
        if (reason != null && reason.isNotEmpty) {
          data['disabledReason'] = reason;
        }
        await userDoc.set(data, SetOptions(merge: true));
      } else {
        await userDoc.update({
          'disabledReason': FieldValue.delete(),
          'disabledAt': FieldValue.delete(),
        });
      }
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('User ${currentlyDisabled ? 'entsperrt' : 'gesperrt'}.')),
        );
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
    final l = AppLocalizations.of(context)!;
    if (!mounted) return;
    final confirmed = await AdminConfirmationDialog.show(
      context,
      title: 'User löschen (DSGVO)?',
      message: 'ALLE Daten von "$email" werden unwiderruflich gelöscht: '
          'Account, Patientendaten, Links, Dateien.',
      severity: AdminActionSeverity.destructive,
      confirmLabel: l.deleteFinal,
      confirmationText: 'LÖSCHEN',
    );
    if (!confirmed) return;

    try {
      await adminFunctions().httpsCallable('deleteUserAccount').call<void>({'uid': uid});
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l.deleteUserAndData)),
        );
      }
    } catch (e) {
      if (kDebugMode) debugPrint('[UsersTab] deleteUser error: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(AppLocalizations.of(context)!.deleteFailed)),
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
      if (!mounted) return;
      grantDays = await showDialog<int>(
        context: context,
        builder: (ctx) => _ProDurationDialog(),
      );
      if (grantDays == null) return;
    }

    try {
      final params = <String, dynamic>{
        'uid': uid,
        'isPro': !currentlyPro,
      };
      if (grantDays != null) params['grantDays'] = grantDays;
      await adminFunctions().httpsCallable('setProStatus').call<void>(params);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(currentlyPro ? 'Pro entfernt.' : 'Pro für $grantDays Tage vergeben.')),
      );
    } catch (e) {
      if (kDebugMode) debugPrint('[UsersTab] togglePro error: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(AppLocalizations.of(context)!.proStatusChangeError)),
        );
      }
    }
  }

  Future<void> _sendPushToUser(String uid, String email) async {
    if (!mounted) return;
    final titleCtrl = TextEditingController();
    final bodyCtrl = TextEditingController();
    try {
      final confirmed = await showDialog<bool>(
        context: context,
        builder: (ctx) {
          final l = AppLocalizations.of(ctx)!;
          return AlertDialog(
          title: Text('Push an $email'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: titleCtrl,
                decoration: const InputDecoration(labelText: 'Titel'),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: bodyCtrl,
                decoration: InputDecoration(
                  labelText: l.message,
                  alignLabelWithHint: true,
                ),
                maxLines: 3,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: Text(l.cancel),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(ctx, true),
              child: Text(l.send),
            ),
          ],
        );
        },
      );
      if (confirmed != true || !mounted) return;
      final title = titleCtrl.text.trim();
      final body = bodyCtrl.text.trim();
      if (title.isEmpty || body.isEmpty) return;
      await adminFunctions().httpsCallable('sendAdminNotification').call<void>({
        'title': title,
        'body': body,
        'targetType': 'user',
        'targetValue': uid,
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Push an $email gesendet.')),
        );
      }
    } catch (e) {
      if (kDebugMode) debugPrint('[UsersTab] sendPush error: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(AppLocalizations.of(context)!.messageSendError)),
        );
      }
    } finally {
      titleCtrl.dispose();
      bodyCtrl.dispose();
    }
  }

  Future<void> _exportCsv(
      BuildContext context, List<Map<String, dynamic>> users) async {
    final l = AppLocalizations.of(context)!;
    await exportCsv(
      context: context,
      fileName: 'nutzer_export.csv',
      headers: ['UID', l.fieldEmail, l.role, 'Pro', 'Deaktiviert'],
      rows: users
          .map((u) => [
                (u['uid'] ?? '').toString(),
                (u['email'] ?? '').toString(),
                (u['role'] ?? 'patient').toString(),
                (u['isPro'] == true) ? l.yes : l.no,
                (u['disabled'] == true) ? l.yes : l.no,
              ])
          .toList(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final l = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: Text(l.adminUserManage),
        actions: [
          if (_csvData.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.download),
              tooltip: 'CSV exportieren',
              onPressed: () => _exportCsv(context, _csvData),
            ),
          PopupMenuButton<String?>(
            icon: const Icon(Icons.filter_list),
            tooltip: 'Nach Rolle filtern',
            onSelected: (v) => setState(() => _roleFilter = v),
            itemBuilder: (_) => [
              PopupMenuItem(
                  value: null, child: Text(l.adminAllRoles)),
              ...adminRoleLabels.entries.map(
                (e) => PopupMenuItem(
                    value: e.key, child: Text(e.value)),
              ),
            ],
          ),
        ],
      ),
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
          if (_roleFilter != null)
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 0, 12, 4),
              child: Row(
                children: [
                  Chip(
                    avatar: Icon(Icons.filter_alt,
                        size: 16, color: cs.onSecondaryContainer),
                    label: Text(
                      'Rolle: ${adminRoleLabels[_roleFilter] ?? _roleFilter}',
                      style: TextStyle(color: cs.onSecondaryContainer),
                    ),
                    backgroundColor: cs.secondaryContainer,
                    deleteIcon: const Icon(Icons.close, size: 16),
                    onDeleted: () => setState(() => _roleFilter = null),
                  ),
                ],
              ),
            ),
          Expanded(
            child: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
              stream: FirebaseFirestore.instance
                  .collection('users')
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
                final allUsers = docs
                    .map((d) =>
                        <String, dynamic>{'uid': d.id, ...d.data()})
                    .toList();

                // Keep a copy for CSV export.
                if (_csvData.length != allUsers.length ||
                    !listEquals(
                      _csvData.map((u) => u['uid']).toList(),
                      allUsers.map((u) => u['uid']).toList(),
                    )) {
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    if (mounted) setState(() => _csvData = allUsers);
                  });
                }

                final filtered = _applyFilters(allUsers);

                if (filtered.isEmpty) {
                  return Center(
                    child: Text(
                      allUsers.isEmpty
                          ? 'Keine Nutzer vorhanden.'
                          : 'Keine Treffer.',
                      style: TextStyle(color: cs.onSurfaceVariant),
                    ),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  itemCount: filtered.length,
                  itemBuilder: (context, index) {
                    final user = filtered[index];
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
                      onSendPush: () => _sendPushToUser(
                          uid, user['email'] as String? ?? uid),
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

class _UserCard extends StatelessWidget {
  const _UserCard({
    required this.user,
    required this.onChangeRole,
    required this.onDisable,
    required this.onDelete,
    required this.onTogglePro,
    required this.onSendPush,
  });

  final Map<String, dynamic> user;
  final VoidCallback onChangeRole;
  final VoidCallback onDisable;
  final VoidCallback onDelete;
  final VoidCallback onTogglePro;
  final VoidCallback onSendPush;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final l = AppLocalizations.of(context)!;
    final uid = user['uid'] as String;
    final email = user['email'] as String? ?? '–';
    final role = user['role'] as String? ?? 'patient';
    final isPro = user['isPro'] as bool? ?? false;
    final disabled = user['disabled'] as bool? ?? false;
    final proExpires = user['proExpiresAt'] as Timestamp?;

    final roleColor = adminRoleColors[role] ?? Colors.grey;
    final roleLabel = adminRoleLabels[role] ?? role;

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
                      label: Text(l.locked,
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
            if (user['createdAt'] is Timestamp) ...[  
              const SizedBox(height: 2),
              Text(
                'Registriert: ${_formatDate(user['createdAt'] as Timestamp)}',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: cs.onSurfaceVariant,
                    ),
              ),
            ],
            if (user['lastLoginAt'] is Timestamp) ...[  
              const SizedBox(height: 2),
              Text(
                'Letzter Login: ${_formatDate(user['lastLoginAt'] as Timestamp)}',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: cs.onSurfaceVariant,
                    ),
              ),
            ],
            if (disabled &&
                (user['disabledReason'] as String?)?.isNotEmpty == true) ...[  
              const SizedBox(height: 4),
              Row(
                children: [
                  Icon(Icons.comment_outlined, size: 14, color: cs.error),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      'Grund: ${user['disabledReason']}',
                      style: Theme.of(context)
                          .textTheme
                          .bodySmall
                          ?.copyWith(color: cs.error),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ],
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
                  label: Text(l.role),
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
                  label: Text(disabled ? l.unlock : 'Sperren'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: disabled ? Colors.green : Colors.orange,
                    side: BorderSide(
                      color: disabled ? Colors.green : Colors.orange),
                  ),
                ),
                OutlinedButton.icon(
                  onPressed: onDelete,
                  icon: const Icon(Icons.delete_forever, size: 16),
                  label: Text(l.delete),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: cs.error,
                    side: BorderSide(color: cs.error),
                  ),
                ),
                OutlinedButton.icon(
                  onPressed: onSendPush,
                  icon: const Icon(Icons.send, size: 16),
                  label: const Text('Push'),
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
    final l = AppLocalizations.of(context)!;
    return AlertDialog(
      title: Text(l.proGrantAccess),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(l.proHowManyDays),
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
          child: Text(l.cancel),
        ),
        FilledButton(
          onPressed: () => Navigator.of(context).pop(_days),
          child: Text('$_days Tage vergeben'),
        ),
      ],
    );
  }
}
