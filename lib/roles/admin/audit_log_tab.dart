import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../../ui/error_helpers.dart';
import 'widgets/csv_export.dart';
import '../../l10n/app_localizations.dart';

class AuditLogTab extends StatefulWidget {
  const AuditLogTab({super.key});

  @override
  State<AuditLogTab> createState() => _AuditLogTabState();
}

class _AuditLogTabState extends State<AuditLogTab> {
  String? _actionFilter;
  String _searchQuery = '';
  DateTimeRange? _dateRange;
  List<QueryDocumentSnapshot<Map<String, dynamic>>> _currentDocs = [];

  static const _actionFilters = <String, String>{
    'KEY': 'Key',
    'ROLE': 'Rolle',
    'OBSERVATION': 'Beobachtung',
    'WOUND': 'Wunde',
    'PRO': 'Pro',
    'PUSH': 'Push',
    'DELETE': 'Löschung',
    'DISABLE': 'Sperrung',
    'MAINTENANCE': 'Wartung',
  };

  Future<void> _pickDateRange() async {
    final now = DateTime.now();
    final result = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2024),
      lastDate: now,
      initialDateRange: _dateRange,
    );
    if (result != null) {
      setState(() => _dateRange = result);
    }
  }

  Future<void> _exportCsv(BuildContext context) async {
    final l = AppLocalizations.of(context)!;
    await exportCsv(
      context: context,
      fileName: 'audit_log_export.csv',
      headers: ['Aktion', 'Akteur', l.patient, 'Detail', 'Zeitstempel'],
      rows: _currentDocs.map((d) {
        final data = d.data();
        final ts = (data['timestamp'] as Timestamp?)?.toDate();
        return [
          (data['action'] ?? '').toString(),
          (data['actorUid'] ?? '').toString(),
          (data['patientId'] ?? '').toString(),
          (data['detail'] ?? '').toString(),
          ts != null
              ? '${ts.day.toString().padLeft(2, '0')}.${ts.month.toString().padLeft(2, '0')}.${ts.year} ${ts.hour.toString().padLeft(2, '0')}:${ts.minute.toString().padLeft(2, '0')}'
              : '',
        ];
      }).toList(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final cs = Theme.of(context).colorScheme;

    Query<Map<String, dynamic>> query = FirebaseFirestore.instance
        .collection('auditLog')
        .orderBy('timestamp', descending: true);

    // Server-side date filtering
    if (_dateRange != null) {
      query = query
          .where('timestamp',
              isGreaterThanOrEqualTo:
                  Timestamp.fromDate(_dateRange!.start))
          .where('timestamp',
              isLessThanOrEqualTo: Timestamp.fromDate(
                  _dateRange!.end.add(const Duration(days: 1))));
    }

    query = query.limit(500);

    return Scaffold(
      appBar: AppBar(
        title: Text(l.adminAuditLog),
        actions: [
          if (_currentDocs.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.download),
              tooltip: 'CSV exportieren',
              onPressed: () => _exportCsv(context),
            ),
          IconButton(
            icon: Icon(
              Icons.date_range,
              color: _dateRange != null ? cs.primary : null,
            ),
            tooltip: 'Zeitraum filtern',
            onPressed: _pickDateRange,
          ),
          if (_dateRange != null)
            IconButton(
              icon: const Icon(Icons.clear),
              tooltip: 'Zeitfilter zurücksetzen',
              onPressed: () => setState(() => _dateRange = null),
            ),
        ],
      ),
      body: Column(
        children: [
          // Search bar
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 8, 12, 0),
            child: TextField(
              decoration: const InputDecoration(
                prefixIcon: Icon(Icons.search, size: 20),
                hintText: 'Suche in Aktionen, Details, UID…',
                isDense: true,
              ),
              onChanged: (v) => setState(() => _searchQuery = v.trim().toLowerCase()),
            ),
          ),

          // Filter chips
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 8, 12, 0),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  FilterChip(
                    label: Text(l.all),
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
                  return Center(child: Text(userFacingError(snapshot.error!)));
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

                // Apply search filter
                if (_searchQuery.isNotEmpty) {
                  docs = docs.where((d) {
                    final data = d.data();
                    final haystack = [
                      data['action'] as String? ?? '',
                      data['detail'] as String? ?? '',
                      data['actorUid'] as String? ?? '',
                      data['patientId'] as String? ?? '',
                    ].join(' ').toLowerCase();
                    return haystack.contains(_searchQuery);
                  }).toList();
                }

                if (docs.isEmpty) {
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    if (!mounted) return;
                    if (_currentDocs.isNotEmpty) setState(() => _currentDocs = []);
                  });
                  return Center(
                    child: Text(
                      'Keine Einträge.',
                      style: TextStyle(color: cs.onSurfaceVariant),
                    ),
                  );
                }

                WidgetsBinding.instance.addPostFrameCallback((_) {
                  if (!mounted) return;
                  if (_currentDocs.length != docs.length) {
                    setState(() => _currentDocs = docs);
                  }
                });

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
