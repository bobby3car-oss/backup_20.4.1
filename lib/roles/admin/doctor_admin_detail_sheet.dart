import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'admin_functions.dart';

/// Detail sheet / dialog showing a doctor's full profile, linked patients,
/// and management actions (edit, suspend, delete).
class DoctorAdminDetailSheet extends StatefulWidget {
  const DoctorAdminDetailSheet({
    super.key,
    required this.doctor,
    this.scrollController,
  });

  /// Basic doctor data from the `users` collection.
  final Map<String, dynamic> doctor;

  /// Provided by [DraggableScrollableSheet] on narrow layouts.
  final ScrollController? scrollController;

  @override
  State<DoctorAdminDetailSheet> createState() => _DoctorAdminDetailSheetState();
}

class _DoctorAdminDetailSheetState extends State<DoctorAdminDetailSheet> {
  Map<String, dynamic>? _workspace; // doctors/{uid} doc
  List<Map<String, dynamic>>? _linkedPatients;
  bool _loading = true;

  String get _uid => widget.doctor['uid'] as String? ?? '';

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    try {
      final results = await Future.wait([
        // 1. Doctor workspace doc
        FirebaseFirestore.instance.doc('doctors/$_uid').get(),
        // 2. Linked patients (collectionGroup query)
        FirebaseFirestore.instance
            .collectionGroup('links')
            .where('linkedUid', isEqualTo: _uid)
            .where('linkType', isEqualTo: 'doctor')
            .where('status', isEqualTo: 'active')
            .limit(50)
            .get(),
      ]);

      final workspaceSnap = results[0] as DocumentSnapshot;
      final linksSnap = results[1] as QuerySnapshot;

      if (!mounted) return;
      setState(() {
        _workspace = workspaceSnap.exists
            ? workspaceSnap.data() as Map<String, dynamic>?
            : null;
        _linkedPatients = linksSnap.docs.map((d) {
          // Extract patientId from the document path:
          // patients/{patientId}/links/{linkDocId}
          final ref = d.reference;
          final patientId = ref.parent.parent?.id ?? '?';
          return <String, dynamic>{
            'patientId': patientId,
            ...d.data() as Map<String, dynamic>,
          };
        }).toList();
        _loading = false;
      });
    } catch (e) {
      if (kDebugMode) debugPrint('[DoctorDetail] load error: $e');
      if (!mounted) return;
      setState(() => _loading = false);
    }
  }

  // ── Edit profile ─────────────────────────────────────────────

  Future<void> _showEditDialog() async {
    final nameC =
        TextEditingController(text: widget.doctor['displayName'] as String? ?? '');
    final specialtyC =
        TextEditingController(text: widget.doctor['specialty'] as String? ?? '');
    final phoneC =
        TextEditingController(text: _workspace?['phone'] as String? ?? '');
    final addressC =
        TextEditingController(text: _workspace?['practiceAddress'] as String? ?? '');
    final practiceC =
        TextEditingController(text: _workspace?['practiceName'] as String? ?? '');

    final saved = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Profil bearbeiten'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameC,
                decoration: const InputDecoration(
                  labelText: 'Name',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: specialtyC,
                decoration: const InputDecoration(
                  labelText: 'Fachrichtung',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: practiceC,
                decoration: const InputDecoration(
                  labelText: 'Praxisname',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: addressC,
                decoration: const InputDecoration(
                  labelText: 'Adresse',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: phoneC,
                decoration: const InputDecoration(
                  labelText: 'Telefon',
                  border: OutlineInputBorder(),
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Abbrechen'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Speichern'),
          ),
        ],
      ),
    );

    if (saved != true || !mounted) return;

    try {
      final batch = FirebaseFirestore.instance.batch();

      // Update user doc
      batch.set(
        FirebaseFirestore.instance.doc('users/$_uid'),
        {
          'displayName': nameC.text.trim(),
          'specialty': specialtyC.text.trim(),
          'updatedAt': FieldValue.serverTimestamp(),
        },
        SetOptions(merge: true),
      );

      // Update doctor workspace doc
      batch.set(
        FirebaseFirestore.instance.doc('doctors/$_uid'),
        {
          'practiceName': practiceC.text.trim(),
          'practiceAddress': addressC.text.trim(),
          'phone': phoneC.text.trim(),
          'updatedAt': FieldValue.serverTimestamp(),
        },
        SetOptions(merge: true),
      );

      await batch.commit();

      if (!mounted) return;
      // Update local data to reflect changes
      setState(() {
        widget.doctor['displayName'] = nameC.text.trim();
        widget.doctor['specialty'] = specialtyC.text.trim();
        _workspace?['practiceName'] = practiceC.text.trim();
        _workspace?['practiceAddress'] = addressC.text.trim();
        _workspace?['phone'] = phoneC.text.trim();
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Profil gespeichert.')),
      );
    } catch (e) {
      if (kDebugMode) debugPrint('[DoctorDetail] save error: $e');
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Speichern fehlgeschlagen.')),
      );
    }
  }

  // ── Suspend / Unsuspend ──────────────────────────────────────

  Future<void> _toggleSuspend() async {
    final suspended = widget.doctor['suspended'] as bool? ?? false;
    final name = widget.doctor['displayName'] as String? ?? 'Arzt';
    final action = suspended ? 'unsuspendDoctor' : 'suspendDoctor';

    try {
      await adminFunctions()
          .httpsCallable(action)
          .call<void>({'uid': _uid});
      if (!mounted) return;
      setState(() {
        widget.doctor['suspended'] = !suspended;
        widget.doctor['doctorVerified'] = suspended; // unsuspend → verified
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
              suspended ? '$name entsperrt.' : '$name gesperrt.'),
        ),
      );
    } catch (e) {
      if (kDebugMode) debugPrint('[DoctorDetail] toggle suspend: $e');
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Aktion fehlgeschlagen.')),
      );
    }
  }

  // ── Delete ───────────────────────────────────────────────────

  Future<void> _deleteDoctor() async {
    try {
      await adminFunctions()
          .httpsCallable('deleteDoctor')
          .call<void>({'uid': _uid});
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Arzt gelöscht.')),
      );
      Navigator.of(context).pop(); // close sheet / dialog
    } catch (e) {
      if (kDebugMode) debugPrint('[DoctorDetail] delete error: $e');
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Löschung fehlgeschlagen.')),
      );
    }
  }

  // ── Build ────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    final name = widget.doctor['displayName'] as String? ?? '—';
    final email = widget.doctor['email'] as String? ?? '—';
    final specialty = widget.doctor['specialty'] as String? ?? '';
    final verified = widget.doctor['doctorVerified'] as bool? ?? false;
    final suspended = widget.doctor['suspended'] as bool? ?? false;
    final createdAt = widget.doctor['createdAt'] as Timestamp?;

    return ClipRRect(
      borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
      child: Scaffold(
        backgroundColor: cs.surface,
        appBar: AppBar(
          title: const Text('Arzt-Details'),
          automaticallyImplyLeading: false,
          actions: [
            IconButton(
              icon: const Icon(Icons.close),
              onPressed: () => Navigator.pop(context),
            ),
          ],
        ),
        body: _loading
            ? const Center(child: CircularProgressIndicator())
            : ListView(
                controller: widget.scrollController,
                padding: const EdgeInsets.all(16),
                children: [
                  // ── Header ──────────────────────────────────
                  _buildHeader(cs, theme, name, email, specialty,
                      verified, suspended),
                  const SizedBox(height: 20),

                  // ── Credentials ─────────────────────────────
                  _buildSection(
                    cs,
                    theme,
                    'Praxis & Credentials',
                    Icons.business_outlined,
                    [
                      _infoRow('Praxisname',
                          _workspace?['practiceName'] as String? ?? '—'),
                      _infoRow('Adresse',
                          _workspace?['practiceAddress'] as String? ?? '—'),
                      _infoRow('Telefon',
                          _workspace?['phone'] as String? ?? '—'),
                      _infoRow('Approbationsnr.',
                          _workspace?['approbationNumber'] as String? ?? '—'),
                      _infoRow('KV-Nummer',
                          _workspace?['kvNumber'] as String? ?? '—'),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // ── Linked patients ─────────────────────────
                  _buildSection(
                    cs,
                    theme,
                    'Verknüpfte Patienten (${_linkedPatients?.length ?? 0})',
                    Icons.people_outline,
                    _linkedPatients == null || _linkedPatients!.isEmpty
                        ? [
                            Padding(
                              padding: const EdgeInsets.all(8),
                              child: Text(
                                'Keine verknüpften Patienten.',
                                style: TextStyle(color: cs.onSurfaceVariant),
                              ),
                            ),
                          ]
                        : _linkedPatients!.map((p) {
                            final pid = p['patientId'] as String? ?? '?';
                            return ListTile(
                              dense: true,
                              leading: Icon(Icons.person_outline,
                                  size: 20, color: cs.onSurfaceVariant),
                              title: Text(
                                pid,
                                style: theme.textTheme.bodySmall?.copyWith(
                                    fontFamily: 'monospace'),
                              ),
                              subtitle: Text(
                                'Status: ${p['status'] ?? '—'}',
                                style: theme.textTheme.bodySmall?.copyWith(
                                    color: cs.onSurfaceVariant),
                              ),
                            );
                          }).toList(),
                  ),
                  const SizedBox(height: 16),

                  // ── Statistics ──────────────────────────────
                  _buildSection(
                    cs,
                    theme,
                    'Statistiken',
                    Icons.analytics_outlined,
                    [
                      _infoRow('Patienten',
                          '${_linkedPatients?.length ?? 0}'),
                      _infoRow(
                        'Registriert am',
                        createdAt != null
                            ? _formatDate(createdAt)
                            : '—',
                      ),
                      _infoRow(
                        'Status',
                        suspended
                            ? 'Gesperrt'
                            : verified
                                ? 'Verifiziert & Aktiv'
                                : 'Nicht verifiziert',
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // ── UID ─────────────────────────────────────
                  SelectableText(
                    'UID: $_uid',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: cs.onSurfaceVariant,
                      fontFamily: 'monospace',
                    ),
                  ),
                  const SizedBox(height: 24),

                  // ── Actions ─────────────────────────────────
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      FilledButton.icon(
                        onPressed: _showEditDialog,
                        icon: const Icon(Icons.edit_outlined, size: 18),
                        label: const Text('Bearbeiten'),
                      ),
                      OutlinedButton.icon(
                        onPressed: _toggleSuspend,
                        icon: Icon(
                          suspended ? Icons.lock_open : Icons.block,
                          size: 18,
                        ),
                        label: Text(suspended ? 'Entsperren' : 'Sperren'),
                        style: OutlinedButton.styleFrom(
                          foregroundColor:
                              suspended ? Colors.green : Colors.orange,
                          side: BorderSide(
                            color:
                                suspended ? Colors.green : Colors.orange,
                          ),
                        ),
                      ),
                      OutlinedButton.icon(
                        onPressed: _deleteDoctor,
                        icon: const Icon(Icons.delete_forever, size: 18),
                        label: const Text('Löschen'),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: cs.error,
                          side: BorderSide(color: cs.error),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                ],
              ),
      ),
    );
  }

  // ── Helper widgets ─────────────────────────────────────────────

  Widget _buildHeader(
    ColorScheme cs,
    ThemeData theme,
    String name,
    String email,
    String specialty,
    bool verified,
    bool suspended,
  ) {
    final parts = name.trim().split(RegExp(r'\s+'));
    final initials = parts.length >= 2
        ? '${parts.first[0]}${parts.last[0]}'.toUpperCase()
        : name.isNotEmpty && name != '—'
            ? name[0].toUpperCase()
            : '?';

    final Color statusColor;
    final String statusLabel;
    if (suspended) {
      statusColor = Colors.red;
      statusLabel = 'Gesperrt';
    } else if (verified) {
      statusColor = Colors.green;
      statusLabel = 'Verifiziert';
    } else {
      statusColor = Colors.orange;
      statusLabel = 'Nicht verifiziert';
    }

    return Row(
      children: [
        CircleAvatar(
          radius: 28,
          backgroundColor: cs.primaryContainer,
          child: Text(
            initials,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: cs.onPrimaryContainer,
            ),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(name, style: theme.textTheme.titleMedium),
              Text(email,
                  style: theme.textTheme.bodySmall?.copyWith(
                      color: cs.onSurfaceVariant)),
              if (specialty.isNotEmpty)
                Text(specialty,
                    style: theme.textTheme.bodySmall?.copyWith(
                        color: cs.onSurfaceVariant)),
            ],
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
          decoration: BoxDecoration(
            color: statusColor.withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            statusLabel,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: statusColor,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSection(
    ColorScheme cs,
    ThemeData theme,
    String title,
    IconData icon,
    List<Widget> children,
  ) {
    return Card(
      color: cs.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: cs.outline.withValues(alpha: 0.3)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, size: 18, color: cs.primary),
                const SizedBox(width: 8),
                Text(title, style: theme.textTheme.titleSmall),
              ],
            ),
            const SizedBox(height: 12),
            ...children,
          ],
        ),
      ),
    );
  }

  Widget _infoRow(String label, String value) {
    final cs = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: TextStyle(
                fontSize: 13,
                color: cs.onSurfaceVariant,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontSize: 13),
            ),
          ),
        ],
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
