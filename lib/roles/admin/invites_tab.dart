import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Admin tab showing all doctor invites and patient invites across the system.
///
/// Doctor invites are stored in the top-level `doctor_invites` collection.
/// Patient invites are stored in `patients/{pid}/invites` subcollections
/// (queried via collection-group).
class InvitesTab extends StatefulWidget {
  const InvitesTab({super.key});

  @override
  State<InvitesTab> createState() => _InvitesTabState();
}

class _InvitesTabState extends State<InvitesTab>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;
  String? _statusFilter; // null = alle

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Einladungen'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Arzt-Einladungen'),
            Tab(text: 'Patienten-Einladungen'),
          ],
        ),
        actions: [
          PopupMenuButton<String?>(
            icon: const Icon(Icons.filter_list, size: 20),
            tooltip: 'Status filtern',
            onSelected: (v) => setState(() => _statusFilter = v),
            itemBuilder: (_) => [
              const PopupMenuItem(value: null, child: Text('Alle')),
              const PopupMenuItem(value: 'pending', child: Text('Ausstehend')),
              const PopupMenuItem(value: 'accepted', child: Text('Akzeptiert')),
              const PopupMenuItem(value: 'revoked', child: Text('Widerrufen')),
            ],
          ),
        ],
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _DoctorInvitesList(statusFilter: _statusFilter),
          _PatientInvitesList(statusFilter: _statusFilter),
        ],
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════════════════════
// Doctor Invites (top-level `doctor_invites` collection)
// ══════════════════════════════════════════════════════════════════════════════

class _DoctorInvitesList extends StatelessWidget {
  const _DoctorInvitesList({this.statusFilter});
  final String? statusFilter;

  @override
  Widget build(BuildContext context) {
    Query<Map<String, dynamic>> query =
        FirebaseFirestore.instance.collection('doctor_invites');

    if (statusFilter != null) {
      query = query.where('status', isEqualTo: statusFilter);
    }
    query = query.orderBy('createdAt', descending: true).limit(200);

    return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
      stream: query.snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        final docs = snapshot.data?.docs ?? [];
        if (docs.isEmpty) {
          return Center(
            child: Text('Keine Arzt-Einladungen.',
                style: TextStyle(
                    color: Theme.of(context).colorScheme.onSurfaceVariant)),
          );
        }
        return ListView.builder(
          padding: const EdgeInsets.all(12),
          itemCount: docs.length,
          itemBuilder: (context, i) {
            final data = docs[i].data();
            final code = docs[i].id;
            final status = (data['status'] ?? 'pending').toString();
            final doctorUid = (data['doctorUid'] ?? '').toString();
            final createdAt =
                DateTime.tryParse(data['createdAt']?.toString() ?? '') ??
                    DateTime.now();
            final expiresAt =
                DateTime.tryParse(data['expiresAt']?.toString() ?? '');
            final acceptedByUid = data['acceptedByUid']?.toString();

            final isExpired =
                expiresAt != null && DateTime.now().isAfter(expiresAt);
            final displayStatus =
                (status == 'pending' && isExpired) ? 'expired' : status;

            return _InviteCard(
              code: code,
              status: displayStatus,
              createdAt: createdAt,
              expiresAt: expiresAt,
              ownerLabel: 'Arzt: $doctorUid',
              acceptedBy: acceptedByUid,
              onRevoke: status == 'pending' && !isExpired
                  ? () => _revoke(context, code)
                  : null,
            );
          },
        );
      },
    );
  }

  Future<void> _revoke(BuildContext context, String code) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Einladung widerrufen?'),
        content: Text('Code: $code'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('Abbrechen')),
          FilledButton(
              onPressed: () => Navigator.pop(ctx, true),
              child: const Text('Widerrufen')),
        ],
      ),
    );
    if (confirmed != true) return;
    await FirebaseFirestore.instance.doc('doctor_invites/$code').update({
      'status': 'revoked',
    });
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Einladung widerrufen.')),
      );
    }
  }
}

// ══════════════════════════════════════════════════════════════════════════════
// Patient Invites (collection-group `invites` under patients)
// ══════════════════════════════════════════════════════════════════════════════

class _PatientInvitesList extends StatelessWidget {
  const _PatientInvitesList({this.statusFilter});
  final String? statusFilter;

  @override
  Widget build(BuildContext context) {
    Query<Map<String, dynamic>> query =
        FirebaseFirestore.instance.collectionGroup('invites');

    if (statusFilter != null) {
      query = query.where('status', isEqualTo: statusFilter);
    }
    query = query.orderBy('createdAt', descending: true).limit(200);

    return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
      stream: query.snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Text(
                'Fehler beim Laden der Patienten-Einladungen.\n'
                'Collection-Group-Index ggf. noch nicht erstellt.',
                textAlign: TextAlign.center,
                style: TextStyle(
                    color: Theme.of(context).colorScheme.onSurfaceVariant),
              ),
            ),
          );
        }
        final docs = snapshot.data?.docs ?? [];
        if (docs.isEmpty) {
          return Center(
            child: Text('Keine Patienten-Einladungen.',
                style: TextStyle(
                    color: Theme.of(context).colorScheme.onSurfaceVariant)),
          );
        }
        return ListView.builder(
          padding: const EdgeInsets.all(12),
          itemCount: docs.length,
          itemBuilder: (context, i) {
            final data = docs[i].data();
            final docRef = docs[i].reference;
            final status = (data['status'] ?? 'pending').toString();
            final linkType = (data['linkType'] ?? '').toString();
            final createdBy = (data['createdBy'] ?? '').toString();
            final createdAt = (data['createdAt'] as Timestamp?)?.toDate() ??
                DateTime.now();
            final expiresAt = (data['expiresAt'] as Timestamp?)?.toDate();
            final acceptedByUid = data['acceptedByUid']?.toString();

            final isExpired =
                expiresAt != null && DateTime.now().isAfter(expiresAt);
            final displayStatus =
                (status == 'pending' && isExpired) ? 'expired' : status;

            // Extract patient ID from the document path
            final patientId = docRef.parent.parent?.id ?? '?';

            return _InviteCard(
              code: docRef.id.substring(0, 8.clamp(0, docRef.id.length)),
              status: displayStatus,
              createdAt: createdAt,
              expiresAt: expiresAt,
              ownerLabel: 'Patient: $patientId',
              extra: 'Typ: $linkType',
              acceptedBy: acceptedByUid,
              onRevoke: status == 'pending' && !isExpired
                  ? () => _revoke(context, docRef, createdBy)
                  : null,
            );
          },
        );
      },
    );
  }

  Future<void> _revoke(BuildContext context,
      DocumentReference<Map<String, dynamic>> ref, String createdBy) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Einladung widerrufen?'),
        content: Text('Erstellt von: $createdBy'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('Abbrechen')),
          FilledButton(
              onPressed: () => Navigator.pop(ctx, true),
              child: const Text('Widerrufen')),
        ],
      ),
    );
    if (confirmed != true) return;
    await ref.update({'status': 'revoked'});
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Einladung widerrufen.')),
      );
    }
  }
}

// ══════════════════════════════════════════════════════════════════════════════
// Shared invite card
// ══════════════════════════════════════════════════════════════════════════════

class _InviteCard extends StatelessWidget {
  const _InviteCard({
    required this.code,
    required this.status,
    required this.createdAt,
    this.expiresAt,
    required this.ownerLabel,
    this.extra,
    this.acceptedBy,
    this.onRevoke,
  });

  final String code;
  final String status;
  final DateTime createdAt;
  final DateTime? expiresAt;
  final String ownerLabel;
  final String? extra;
  final String? acceptedBy;
  final VoidCallback? onRevoke;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final statusColor = switch (status) {
      'pending' => Colors.orange,
      'accepted' => Colors.green,
      'revoked' => Colors.red,
      'expired' => Colors.grey,
      _ => cs.onSurfaceVariant,
    };
    final statusLabel = switch (status) {
      'pending' => 'Ausstehend',
      'accepted' => 'Akzeptiert',
      'revoked' => 'Widerrufen',
      'expired' => 'Abgelaufen',
      _ => status,
    };

    return Card(
      margin: const EdgeInsets.only(bottom: 6),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Status icon
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: statusColor.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                switch (status) {
                  'pending' => Icons.hourglass_empty,
                  'accepted' => Icons.check_circle,
                  'revoked' => Icons.block,
                  'expired' => Icons.schedule,
                  _ => Icons.link,
                },
                color: statusColor,
                size: 20,
              ),
            ),
            const SizedBox(width: 12),

            // Content
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      GestureDetector(
                        onTap: () {
                          Clipboard.setData(ClipboardData(text: code));
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                                content: Text('Code kopiert'),
                                duration: Duration(seconds: 1)),
                          );
                        },
                        child: Text(
                          'Code: $code',
                          style: Theme.of(context)
                              .textTheme
                              .titleSmall
                              ?.copyWith(fontFamily: 'monospace'),
                        ),
                      ),
                      const Spacer(),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: statusColor.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          statusLabel,
                          style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: statusColor),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(ownerLabel,
                      style: Theme.of(context).textTheme.bodySmall),
                  if (extra != null) ...[
                    const SizedBox(height: 2),
                    Text(extra!,
                        style: Theme.of(context).textTheme.bodySmall),
                  ],
                  if (acceptedBy != null && acceptedBy!.isNotEmpty) ...[
                    const SizedBox(height: 2),
                    Text('Akzeptiert von: $acceptedBy',
                        style: Theme.of(context).textTheme.bodySmall),
                  ],
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Text(
                        'Erstellt: ${_fmt(createdAt)}',
                        style: Theme.of(context).textTheme.labelSmall,
                      ),
                      if (expiresAt != null) ...[
                        const SizedBox(width: 12),
                        Text(
                          'Ablauf: ${_fmt(expiresAt!)}',
                          style: Theme.of(context).textTheme.labelSmall,
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),

            // Revoke action
            if (onRevoke != null)
              IconButton(
                icon: Icon(Icons.block, color: cs.error, size: 18),
                tooltip: 'Widerrufen',
                onPressed: onRevoke,
              ),
          ],
        ),
      ),
    );
  }

  String _fmt(DateTime d) =>
      '${d.day.toString().padLeft(2, '0')}.${d.month.toString().padLeft(2, '0')}.${d.year} '
      '${d.hour.toString().padLeft(2, '0')}:${d.minute.toString().padLeft(2, '0')}';
}
