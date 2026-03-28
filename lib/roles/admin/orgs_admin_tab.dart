import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'admin_functions.dart';
import '../../l10n/app_localizations.dart';

/// Admin tab for reviewing and approving/rejecting organisation registrations.
class OrgsAdminTab extends StatefulWidget {
  const OrgsAdminTab({super.key});

  @override
  State<OrgsAdminTab> createState() => _OrgsAdminTabState();
}

class _OrgsAdminTabState extends State<OrgsAdminTab> {
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
          child: Row(
            children: [
              Icon(Icons.business_outlined, color: cs.primary, size: 22),
              const SizedBox(width: 8),
              Text(l.orgVerification,
                  style: theme.textTheme.titleMedium),
              const Spacer(),
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
        ),

        // ── List ─────────────────────────────────────────────
        Expanded(
          child: StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance
                .collection('org_verifications')
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
                                ? 'Noch keine bestätigten Organisationen'
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
                  return _OrgVerificationCard(
                    data: data,
                    isPending: _filter == 'pending',
                    onApprove: () => _handleAction(data, true),
                    onReject: () => _handleAction(data, false),
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
      if (reason == null) return;
    } else {
      final l = AppLocalizations.of(context)!;
      final confirmed = await showDialog<bool>(
        context: context,
        builder: (ctx) => AlertDialog(
          title: Text(l.orgConfirm),
          content: Text(
            'Möchten Sie „${data['name']}" als Organisation verifizieren? '
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
      final callable = adminFunctions().httpsCallable('verifyOrganisation');
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
                ? '„${data['name']}" wurde bestätigt'
                : '„${data['name']}" wurde abgelehnt',
          ),
        ),
      );
    } catch (e) {
      final l = AppLocalizations.of(context)!;
      if (kDebugMode) debugPrint('[OrgVerification] verify error: $e');
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l.verificationFailed)),
      );
    }
  }

  Future<String?> _showReasonDialog() {
    final l = AppLocalizations.of(context)!;
    final controller = TextEditingController();
    return showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l.declineReasonAlt),
        content: TextField(
          controller: controller,
          maxLines: 3,
          decoration: InputDecoration(
            hintText: l.grundEingeben,
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

class _OrgVerificationCard extends StatelessWidget {
  const _OrgVerificationCard({
    required this.data,
    required this.isPending,
    required this.onApprove,
    required this.onReject,
  });

  final Map<String, dynamic> data;
  final bool isPending;
  final VoidCallback onApprove;
  final VoidCallback onReject;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final cs = Theme.of(context).colorScheme;
    final name = data['name'] ?? 'Unbekannt';
    final email = data['email'] ?? '';
    final orgType = data['orgType'] ?? '';
    final address = data['address'] ?? '';
    final contactPerson = data['contactPerson'] ?? '';
    final phone = data['phone'] ?? '';
    final status = data['status'] ?? 'pending';

    final statusColor = switch (status) {
      'approved' => Colors.green,
      'rejected' => Colors.red,
      _ => Colors.orange,
    };

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: cs.primaryContainer,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(Icons.business, color: cs.primary, size: 20),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(name.toString(),
                          style: const TextStyle(fontWeight: FontWeight.w600)),
                      if (orgType.toString().isNotEmpty)
                        Text(orgType.toString(),
                            style: TextStyle(
                                fontSize: 12, color: cs.onSurfaceVariant)),
                    ],
                  ),
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: statusColor.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    status.toString().toUpperCase(),
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: statusColor,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            _InfoRow(Icons.email_outlined, email.toString()),
            if (address.toString().isNotEmpty)
              _InfoRow(Icons.location_on_outlined, address.toString()),
            if (contactPerson.toString().isNotEmpty)
              _InfoRow(Icons.person_outline, contactPerson.toString()),
            if (phone.toString().isNotEmpty)
              _InfoRow(Icons.phone_outlined, phone.toString()),
            if (isPending) ...[
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  OutlinedButton.icon(
                    onPressed: onReject,
                    icon: const Icon(Icons.close, size: 18),
                    label: Text(l.decline),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.red,
                    ),
                  ),
                  const SizedBox(width: 8),
                  FilledButton.icon(
                    onPressed: onApprove,
                    icon: const Icon(Icons.check, size: 18),
                    label: Text(l.confirm),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow(this.icon, this.text);
  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 4),
      child: Row(
        children: [
          Icon(icon, size: 16, color: Theme.of(context).colorScheme.onSurfaceVariant),
          const SizedBox(width: 8),
          Expanded(
            child: Text(text,
                style: TextStyle(
                    fontSize: 13,
                    color: Theme.of(context).colorScheme.onSurfaceVariant)),
          ),
        ],
      ),
    );
  }
}

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
          color: selected ? color.withValues(alpha: 0.15) : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: selected ? color : Colors.grey.withValues(alpha: 0.3),
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: selected ? FontWeight.w600 : FontWeight.normal,
            color: selected ? color : null,
          ),
        ),
      ),
    );
  }
}
