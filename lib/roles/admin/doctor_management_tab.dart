import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../../security/field_encryption_service.dart';
import '../../ui/error_helpers.dart';
import 'admin_functions.dart';
import 'doctor_admin_detail_sheet.dart';
import 'widgets/admin_confirmation_dialog.dart';
import '../../l10n/app_localizations.dart';

/// Admin tab that lists all doctors with search, filter, and management actions.
class DoctorManagementTab extends StatefulWidget {
  const DoctorManagementTab({super.key});

  @override
  State<DoctorManagementTab> createState() => _DoctorManagementTabState();
}

class _DoctorManagementTabState extends State<DoctorManagementTab>
    with AutomaticKeepAliveClientMixin {
  final _searchController = TextEditingController();
  String _searchQuery = '';
  String _statusFilter = 'all'; // all | verified | suspended

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    _searchController.addListener(() {
      setState(
          () => _searchQuery = _searchController.text.toLowerCase().trim());
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<Map<String, dynamic>> _applyFilters(List<Map<String, dynamic>> docs) {
    var result = docs;

    // Status filter
    if (_statusFilter == 'verified') {
      result =
          result.where((d) => d['doctorVerified'] == true).toList();
    } else if (_statusFilter == 'suspended') {
      result = result
          .where((d) =>
              d['suspended'] == true || d['doctorVerified'] != true)
          .toList();
    }

    // Search
    if (_searchQuery.isNotEmpty) {
      result = result.where((d) {
        final name = (d['displayName'] ?? '').toString().toLowerCase();
        final email = (d['email'] ?? '').toString().toLowerCase();
        final uid = (d['uid'] ?? '').toString().toLowerCase();
        final specialty = (d['specialty'] ?? '').toString().toLowerCase();
        return name.contains(_searchQuery) ||
            email.contains(_searchQuery) ||
            uid.contains(_searchQuery) ||
            specialty.contains(_searchQuery);
      }).toList();
    }

    return result;
  }

  // ── Actions ──────────────────────────────────────────────────

  Future<void> _suspendDoctor(String uid, String name) async {
    if (!mounted) return;
    final l = AppLocalizations.of(context)!;
    final confirmed = await AdminConfirmationDialog.show(
      context,
      title: l.arztSperren,
      message: '"$name" wird sofort gesperrt und kann keine '
          'Arzt-Funktionen mehr nutzen.',
      severity: AdminActionSeverity.dangerous,
      confirmLabel: 'Sperren',
    );
    if (!confirmed) return;

    try {
      await adminFunctions()
          .httpsCallable('suspendDoctor')
          .call<void>({'uid': uid});
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l.nameWurdeGesperrt(name))),
      );
    } catch (e) {
      final l = AppLocalizations.of(context)!;
      if (kDebugMode) debugPrint('[DoctorMgmt] suspend error: $e');
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l.lockFailed)),
      );
    }
  }

  Future<void> _unsuspendDoctor(String uid, String name) async {
    final l = AppLocalizations.of(context)!;
    if (!mounted) return;
    final confirmed = await AdminConfirmationDialog.show(
      context,
      title: l.arztEntsperren,
      message: '"$name" erhält wieder vollen Arzt-Zugang.',
      severity: AdminActionSeverity.normal,
      confirmLabel: l.unlock,
    );
    if (!confirmed) return;

    try {
      await adminFunctions()
          .httpsCallable('unsuspendDoctor')
          .call<void>({'uid': uid});
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l.nameWurdeEntsperrt(name))),
      );
    } catch (e) {
      if (kDebugMode) debugPrint('[DoctorMgmt] unsuspend error: $e');
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l.unlockFailed)),
      );
    }
  }

  Future<void> _deleteDoctor(String uid, String name) async {
    final l = AppLocalizations.of(context)!;
    if (!mounted) return;
    final confirmed = await AdminConfirmationDialog.show(
      context,
      title: l.arztLoeschen,
      message: 'ALLE Daten von "$name" werden unwiderruflich gelöscht: '
          'Account, Patientenlinks, Praxisdaten.',
      severity: AdminActionSeverity.destructive,
      confirmLabel: l.deleteFinal,
      confirmationText: l.loeschen,
    );
    if (!confirmed) return;

    try {
      await adminFunctions()
          .httpsCallable('deleteDoctor')
          .call<void>({'uid': uid});
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l.nameWurdeGeloescht(name))),
      );
    } catch (e) {
      final l = AppLocalizations.of(context)!;
      if (kDebugMode) debugPrint('[DoctorMgmt] delete error: $e');
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l.deleteFailed)),
      );
    }
  }

  void _openDetail(Map<String, dynamic> doctor) {
    final isWide = MediaQuery.sizeOf(context).width >= 720;
    if (isWide) {
      showDialog(
        context: context,
        builder: (_) => Dialog(
          insetPadding: const EdgeInsets.all(32),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 600, maxHeight: 700),
            child: DoctorAdminDetailSheet(doctor: doctor),
          ),
        ),
      );
    } else {
      showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        useSafeArea: true,
        builder: (_) => DraggableScrollableSheet(
          initialChildSize: 0.9,
          maxChildSize: 0.95,
          minChildSize: 0.5,
          expand: false,
          builder: (_, scrollController) => DoctorAdminDetailSheet(
            doctor: doctor,
            scrollController: scrollController,
          ),
        ),
      );
    }
  }

  // ── Build ────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    super.build(context);
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    return Column(
      children: [
        // ── Search + filter ────────────────────────────────────
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
          child: Row(
            children: [
              Icon(Icons.manage_accounts_outlined,
                  color: cs.primary, size: 22),
              const SizedBox(width: 8),
              Text(l.doctorManage,
                  style: theme.textTheme.titleMedium),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(12, 0, 12, 4),
          child: TextField(
            controller: _searchController,
            decoration: InputDecoration(
              hintText: l.suchenNameEMailFachrichtung,
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
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 4, 16, 8),
          child: Row(
            children: [
              _FilterChip(
                label: l.all,
                selected: _statusFilter == 'all',
                color: cs.primary,
                onTap: () => setState(() => _statusFilter = 'all'),
              ),
              const SizedBox(width: 6),
              _FilterChip(
                label: 'Verifiziert',
                selected: _statusFilter == 'verified',
                color: Colors.green,
                onTap: () => setState(() => _statusFilter = 'verified'),
              ),
              const SizedBox(width: 6),
              _FilterChip(
                label: l.locked,
                selected: _statusFilter == 'suspended',
                color: Colors.red,
                onTap: () => setState(() => _statusFilter = 'suspended'),
              ),
            ],
          ),
        ),

        // ── Doctor list ────────────────────────────────────────
        Expanded(
          child: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
            stream: FirebaseFirestore.instance
                .collection('users')
                .where('role', isEqualTo: 'doctor')
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
              final enc = FieldEncryptionService.instance;
              final allDoctors = docs
                  .map((d) {
                    final raw = <String, dynamic>{'uid': d.id, ...d.data()};
                    return enc.decryptFields(
                        d.id, raw, kEncryptedUserFields);
                  })
                  .toList();

              // Sort by decrypted displayName client-side.
              allDoctors.sort((a, b) {
                final an = (a['displayName'] ?? '').toString().toLowerCase();
                final bn = (b['displayName'] ?? '').toString().toLowerCase();
                return an.compareTo(bn);
              });

              final filtered = _applyFilters(allDoctors);

              if (filtered.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.medical_services_outlined,
                          size: 48, color: cs.onSurfaceVariant),
                      const SizedBox(height: 12),
                      Text(
                        allDoctors.isEmpty
                            ? 'Keine Ärzte registriert.'
                            : 'Keine Treffer.',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: cs.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                );
              }

              return ListView.separated(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                itemCount: filtered.length,
                separatorBuilder: (_, i) => const SizedBox(height: 6),
                itemBuilder: (context, index) {
                  final doctor = filtered[index];
                  return _DoctorListCard(
                    doctor: doctor,
                    onTap: () => _openDetail(doctor),
                    onSuspend: () => _suspendDoctor(
                      doctor['uid'] as String,
                      doctor['displayName'] as String? ?? l.doctor,
                    ),
                    onUnsuspend: () => _unsuspendDoctor(
                      doctor['uid'] as String,
                      doctor['displayName'] as String? ?? l.doctor,
                    ),
                    onDelete: () => _deleteDoctor(
                      doctor['uid'] as String,
                      doctor['displayName'] as String? ?? l.doctor,
                    ),
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }
}

// ═════════════════════════════════════════════════════════════════════════════
// Filter chip (reused pattern from doctor_verification_tab.dart)
// ═════════════════════════════════════════════════════════════════════════════

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

// ═════════════════════════════════════════════════════════════════════════════
// Doctor list card
// ═════════════════════════════════════════════════════════════════════════════

class _DoctorListCard extends StatelessWidget {
  const _DoctorListCard({
    required this.doctor,
    required this.onTap,
    required this.onSuspend,
    required this.onUnsuspend,
    required this.onDelete,
  });

  final Map<String, dynamic> doctor;
  final VoidCallback onTap;
  final VoidCallback onSuspend;
  final VoidCallback onUnsuspend;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final cs = Theme.of(context).colorScheme;
    final name = doctor['displayName'] as String? ?? '—';
    final email = doctor['email'] as String? ?? '—';
    final specialty = doctor['specialty'] as String? ?? '';
    final verified = doctor['doctorVerified'] as bool? ?? false;
    final suspended = doctor['suspended'] as bool? ?? false;

    final String initials;
    final parts = name.trim().split(RegExp(r'\s+'));
    if (parts.length >= 2) {
      initials = '${parts.first[0]}${parts.last[0]}'.toUpperCase();
    } else if (name.isNotEmpty && name != '—') {
      initials = name[0].toUpperCase();
    } else {
      initials = '?';
    }

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

    return Card(
      margin: EdgeInsets.zero,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  CircleAvatar(
                    radius: 20,
                    backgroundColor: cs.primaryContainer,
                    child: Text(
                      initials,
                      style: TextStyle(
                        color: cs.onPrimaryContainer,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          name,
                          style: Theme.of(context).textTheme.titleSmall,
                          overflow: TextOverflow.ellipsis,
                        ),
                        Text(
                          email,
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: cs.onSurfaceVariant,
                              ),
                          overflow: TextOverflow.ellipsis,
                        ),
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
                      statusLabel,
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: statusColor,
                      ),
                    ),
                  ),
                ],
              ),
              if (specialty.isNotEmpty) ...[
                const SizedBox(height: 6),
                Row(
                  children: [
                    const SizedBox(width: 52), // align with name
                    Icon(Icons.local_hospital_outlined,
                        size: 14, color: cs.onSurfaceVariant),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        specialty,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: cs.onSurfaceVariant,
                            ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ],
              const SizedBox(height: 10),
              // Quick actions
              Wrap(
                spacing: 8,
                runSpacing: 6,
                children: [
                  if (suspended)
                    _ActionButton(
                      icon: Icons.lock_open,
                      label: l.unlock,
                      color: Colors.green,
                      onTap: onUnsuspend,
                    )
                  else
                    _ActionButton(
                      icon: Icons.block,
                      label: 'Sperren',
                      color: Colors.orange,
                      onTap: onSuspend,
                    ),
                  _ActionButton(
                    icon: Icons.delete_forever,
                    label: l.delete,
                    color: cs.error,
                    onTap: onDelete,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  const _ActionButton({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return OutlinedButton.icon(
      onPressed: onTap,
      icon: Icon(icon, size: 16),
      label: Text(label),
      style: OutlinedButton.styleFrom(
        foregroundColor: color,
        side: BorderSide(color: color),
      ),
    );
  }
}
