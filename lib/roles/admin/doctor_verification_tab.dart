import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'admin_functions.dart';
import '../../l10n/app_localizations.dart';

/// Admin tab for reviewing and approving/rejecting doctor registrations.
class DoctorVerificationTab extends StatefulWidget {
  const DoctorVerificationTab({super.key});

  @override
  State<DoctorVerificationTab> createState() => _DoctorVerificationTabState();
}

class _DoctorVerificationTabState extends State<DoctorVerificationTab> {
  String _filter = 'pending'; // pending | approved | rejected

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    return Column(
      children: [
        // ── Filter chips ─────────────────────────────────────
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(Icons.medical_services_outlined,
                      color: cs.primary, size: 22),
                  const SizedBox(width: 8),
                  Text(l.doctorVerification,
                      style: theme.textTheme.titleMedium),
                ],
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  _FilterChip(
                    label: 'Offen',
                    selected: _filter == 'pending',
                    color: Colors.orange,
                    onTap: () => setState(() => _filter = 'pending'),
                  ),
                  const SizedBox(width: 6),
                  _FilterChip(
                    label: 'Bestätigt',
                    selected: _filter == 'approved',
                    color: Colors.green,
                    onTap: () => setState(() => _filter = 'approved'),
                  ),
                  const SizedBox(width: 6),
                  _FilterChip(
                    label: l.declined,
                    selected: _filter == 'rejected',
                    color: Colors.red,
                    onTap: () => setState(() => _filter = 'rejected'),
                  ),
                ],
              ),
            ],
          ),
        ),

        // ── List ─────────────────────────────────────────────
        Expanded(
          child: StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance
                .collection('doctor_verifications')
                .where('status', isEqualTo: _filter)
                .orderBy('submittedAt', descending: true)
                .limit(100)
                .snapshots(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }

              final docs = snapshot.data?.docs ?? [];
              if (docs.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.inbox_outlined,
                          size: 48, color: cs.onSurfaceVariant),
                      const SizedBox(height: 12),
                      Text(
                        _filter == 'pending'
                            ? 'Keine offenen Anträge'
                            : _filter == 'approved'
                                ? 'Noch keine bestätigten Ärzte'
                                : 'Keine abgelehnten Anträge',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: cs.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                );
              }

              return ListView.separated(
                padding: const EdgeInsets.all(16),
                itemCount: docs.length,
                separatorBuilder: (_, _) => const SizedBox(height: 8),
                itemBuilder: (context, index) {
                  final data =
                      docs[index].data()! as Map<String, dynamic>;
                  return _VerificationCard(
                    data: data,
                    isPending: _filter == 'pending',
                    onApprove: () => _handleAction(data, true),
                    onReject: () => _handleAction(data, false),
                    onReOpen: _filter == 'rejected'
                        ? () => _handleReOpen(data)
                        : null,
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }

  Future<void> _handleAction(
      Map<String, dynamic> data, bool approve) async {
    final uid = data['uid'] as String? ?? '';
    if (uid.isEmpty) return;

    String? reason;
    if (!approve) {
      reason = await _showReasonDialog();
      if (reason == null) return; // cancelled
    } else {
      final l = AppLocalizations.of(context)!;
      final confirmed = await showDialog<bool>(
        context: context,
        builder: (ctx) => AlertDialog(
          title: Text(l.doctorConfirm),
          content: Text(
            'Möchten Sie ${data['name']} als Arzt verifizieren? '
            'Der Account wird freigeschaltet.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: Text(l.cancel),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(ctx, true),
              child: Text(l.confirm),
            ),
          ],
        ),
      );
      if (confirmed != true) return;
    }

    try {
      final callable = adminFunctions().httpsCallable('verifyDoctor');
      await callable.call(<String, dynamic>{
        'uid': uid,
        'approved': approve,
        'reason': reason ?? '',
      });
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            approve
                ? '${data['name']} wurde bestätigt'
                : '${data['name']} wurde abgelehnt',
          ),
        ),
      );
    } catch (e) {
      final l = AppLocalizations.of(context)!;
      if (kDebugMode) debugPrint('[DoctorVerification] verify error: $e');
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l.verificationFailed)),
      );
    }
  }

  Future<void> _handleReOpen(Map<String, dynamic> data) async {
    final l = AppLocalizations.of(context)!;
    final uid = data['uid'] as String? ?? '';
    final name = data['name'] as String? ?? 'Unbekannt';
    if (uid.isEmpty) return;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l.requestReactivate),
        content: Text(
          '"$name" wird zurück in die Warteschlange gesetzt '
          'und kann erneut geprüft werden.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(l.cancel),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(l.reactivate),
          ),
        ],
      ),
    );
    if (confirmed != true) return;

    try {
      final snap = await FirebaseFirestore.instance
          .collection('doctor_verifications')
          .where('uid', isEqualTo: uid)
          .limit(1)
          .get();
      if (snap.docs.isEmpty) {
        final l = AppLocalizations.of(context)!;
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l.requestNotFound)),
        );
        return;
      }
      await snap.docs.first.reference.update({
        'status': 'pending',
        'reason': FieldValue.delete(),
      });
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Antrag von $name reaktiviert.')),
      );
    } catch (e) {
      final l = AppLocalizations.of(context)!;
      if (kDebugMode) debugPrint('[DoctorVerification] reopen error: $e');
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l.reactivationFailed)),
      );
    }
  }

  Future<String?> _showReasonDialog() {
    final l = AppLocalizations.of(context)!;
    final controller = TextEditingController();
    return showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l.declineReason),
        content: TextField(
          controller: controller,
          maxLines: 3,
          decoration: const InputDecoration(
            hintText: 'Begründung eingeben …',
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(l.cancel),
          ),
          FilledButton(
            onPressed: () {
              final text = controller.text.trim();
              Navigator.pop(ctx, text.isEmpty ? 'Kein Grund angegeben' : text);
            },
            style: FilledButton.styleFrom(
              backgroundColor: Colors.red,
            ),
            child: Text(l.decline),
          ),
        ],
      ),
    ).then((result) {
      controller.dispose();
      return result;
    });
  }
}

// ─────────────────────────────────────────────────────────────────────────────

class _FilterChip extends StatelessWidget {
  const _FilterChip({
    required this.label,
    required this.selected,
    required this.color,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: selected ? color.withValues(alpha: 0.2) : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: selected ? color : Colors.grey.withValues(alpha: 0.3),
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: selected ? color : Colors.grey,
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────

class _VerificationCard extends StatelessWidget {
  const _VerificationCard({
    required this.data,
    required this.isPending,
    required this.onApprove,
    required this.onReject,
    this.onReOpen,
  });

  final Map<String, dynamic> data;
  final bool isPending;
  final VoidCallback onApprove;
  final VoidCallback onReject;
  final VoidCallback? onReOpen;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    final name = data['name'] ?? '—';
    final email = data['email'] ?? '—';
    final specialty = data['specialty'] ?? '—';
    final approbation = data['approbationNumber'] ?? '—';
    final practice = data['practiceName'] ?? '—';
    final kvNumber = data['kvNumber'] ?? '';
    final status = data['status'] ?? 'pending';
    final submittedAt = data['submittedAt'] as Timestamp?;
    final reason = data['reason'] as String?;

    final statusColor = switch (status) {
      'approved' => Colors.green,
      'rejected' => Colors.red,
      _ => Colors.orange,
    };

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
            // Header
            Row(
              children: [
                CircleAvatar(
                  radius: 20,
                  backgroundColor: statusColor.withValues(alpha: 0.15),
                  child: Icon(Icons.medical_services, color: statusColor, size: 20),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(name.toString(),
                          style: theme.textTheme.titleSmall),
                      Text(email.toString(),
                          style: theme.textTheme.bodySmall
                              ?.copyWith(color: cs.onSurfaceVariant)),
                    ],
                  ),
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: statusColor.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    status.toString().toUpperCase(),
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                      color: statusColor,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            const Divider(height: 1),
            const SizedBox(height: 12),

            // Details grid
            _DetailRow(label: l.doctorRegSpecialty, value: specialty.toString()),
            _DetailRow(label: 'Approbation', value: approbation.toString()),
            _DetailRow(label: 'Praxis/Klinik', value: practice.toString()),
            if (kvNumber.toString().isNotEmpty)
              _DetailRow(label: l.doctorRegKvNumber, value: kvNumber.toString()),
            if (submittedAt != null)
              _DetailRow(
                label: 'Eingereicht',
                value: _formatTimestamp(submittedAt),
              ),
            if (reason != null && reason.isNotEmpty)
              _DetailRow(label: 'Begründung', value: reason),

            // Action buttons
            if (isPending) ...[
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: onReject,
                      icon: const Icon(Icons.close, size: 18),
                      label: Text(l.decline),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.red,
                        side: const BorderSide(color: Colors.red),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: FilledButton.icon(
                      onPressed: onApprove,
                      icon: const Icon(Icons.check, size: 18),
                      label: Text(l.confirm),
                      style: FilledButton.styleFrom(
                        backgroundColor: Colors.green,
                      ),
                    ),
                  ),
                ],
              ),
            ],
            if (onReOpen != null) ...[  
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: onReOpen,
                  icon: const Icon(Icons.refresh, size: 18),
                  label: Text(l.checkAgain),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  String _formatTimestamp(Timestamp ts) {
    final d = ts.toDate();
    return '${d.day.toString().padLeft(2, '0')}.'
        '${d.month.toString().padLeft(2, '0')}.'
        '${d.year} – '
        '${d.hour.toString().padLeft(2, '0')}:'
        '${d.minute.toString().padLeft(2, '0')}';
  }
}

class _DetailRow extends StatelessWidget {
  const _DetailRow({required this.label, required this.value});
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 110,
            child: Text(
              label,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    fontWeight: FontWeight.w500,
                  ),
            ),
          ),
        ],
      ),
    );
  }
}
