import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class AuditLogTab extends StatefulWidget {
  const AuditLogTab({super.key});

  @override
  State<AuditLogTab> createState() => _AuditLogTabState();
}

class _AuditLogTabState extends State<AuditLogTab> {
  String? _actionFilter;

  static const _actionFilters = <String, String>{
    'KEY': 'Key',
    'ROLE': 'Rolle',
    'OBSERVATION': 'Beobachtung',
    'WOUND': 'Wunde',
    'PRO': 'Pro',
  };

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    Query<Map<String, dynamic>> query = FirebaseFirestore.instance
        .collection('auditLog')
        .orderBy('timestamp', descending: true)
        .limit(200);

    // Client-side filtering is sufficient for 200 docs
    return Scaffold(
      appBar: AppBar(title: const Text('Audit-Log')),
      body: Column(
        children: [
          // Filter chips
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 8, 12, 0),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  FilterChip(
                    label: const Text('Alle'),
                    selected: _actionFilter == null,
                    onSelected: (_) =>
                        setState(() => _actionFilter = null),
                  ),
                  const SizedBox(width: 8),
                  ..._actionFilters.entries.map((e) => Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: FilterChip(
                          label: Text(e.value),
                          selected: _actionFilter == e.key,
                          onSelected: (_) =>
                              setState(() => _actionFilter = e.key),
                        ),
                      )),
                ],
              ),
            ),
          ),
          const SizedBox(height: 8),

          Expanded(
            child: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
              stream: query.snapshots(),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return Center(child: Text('Fehler: ${snapshot.error}'));
                }
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                var docs = snapshot.data?.docs ?? [];

                // Apply client-side filter
                if (_actionFilter != null) {
                  docs = docs.where((d) {
                    final action =
                        (d.data()['action'] as String? ?? '').toUpperCase();
                    return action.contains(_actionFilter!);
                  }).toList();
                }

                if (docs.isEmpty) {
                  return Center(
                    child: Text(
                      'Keine Einträge.',
                      style: TextStyle(color: cs.onSurfaceVariant),
                    ),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  itemCount: docs.length,
                  itemBuilder: (context, index) {
                    final data = docs[index].data();
                    return _AuditLogCard(data: data);
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

class _AuditLogCard extends StatelessWidget {
  const _AuditLogCard({required this.data});

  final Map<String, dynamic> data;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final action = data['action'] as String? ?? '–';
    final actor = data['actorUid'] as String? ?? '–';
    final ts = data['timestamp'] as Timestamp?;
    final detail = data['detail'] as String?;
    final patientId = data['patientId'] as String?;

    final icon = _iconForAction(action);

    return Card(
      margin: const EdgeInsets.only(bottom: 6),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, size: 20, color: cs.primary),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    action,
                    style: Theme.of(context).textTheme.titleSmall,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'Von: ${_shortenUid(actor)}',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: cs.onSurfaceVariant,
                        ),
                  ),
                  if (patientId != null) ...[
                    const SizedBox(height: 2),
                    Text(
                      'Patient: ${_shortenUid(patientId)}',
                      style:
                          Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: cs.onSurfaceVariant,
                              ),
                    ),
                  ],
                  if (detail != null) ...[
                    const SizedBox(height: 2),
                    Text(
                      detail,
                      style:
                          Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: cs.onSurfaceVariant,
                              ),
                    ),
                  ],
                ],
              ),
            ),
            if (ts != null)
              Text(
                _formatTimestamp(ts),
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      color: cs.onSurfaceVariant,
                    ),
              ),
          ],
        ),
      ),
    );
  }

  String _shortenUid(String uid) {
    if (uid.length <= 12) return uid;
    return '${uid.substring(0, 8)}...';
  }

  IconData _iconForAction(String action) {
    final upper = action.toUpperCase();
    if (upper.contains('KEY')) return Icons.vpn_key;
    if (upper.contains('ROLE')) return Icons.manage_accounts;
    if (upper.contains('OBSERVATION')) return Icons.visibility;
    if (upper.contains('WOUND') || upper.contains('WARNING')) {
      return Icons.warning_amber;
    }
    if (upper.contains('PRO')) return Icons.star;
    if (upper.contains('DELETE')) return Icons.delete;
    return Icons.receipt_long;
  }

  String _formatTimestamp(Timestamp ts) {
    final d = ts.toDate();
    return '${d.day.toString().padLeft(2, '0')}.'
        '${d.month.toString().padLeft(2, '0')}. '
        '${d.hour.toString().padLeft(2, '0')}:'
        '${d.minute.toString().padLeft(2, '0')}';
  }
}
