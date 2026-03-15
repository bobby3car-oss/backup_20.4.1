import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../features/doctor_patients/domain/doctor_permissions.dart';
import '../firebase/firebase_paths.dart';
import '../ui/ui.dart';
import '../ui/theme/app_icons.dart';

/// Patient-facing screen to manage linked doctors and their per-feature
/// permissions. The patient can view, edit permissions, and unlink doctors.
class LinkedDoctorsScreen extends StatefulWidget {
  const LinkedDoctorsScreen({super.key});

  @override
  State<LinkedDoctorsScreen> createState() => _LinkedDoctorsScreenState();
}

class _LinkedDoctorsScreenState extends State<LinkedDoctorsScreen> {
  List<_LinkedDoctor> _doctors = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;

    try {
      final snap = await FirebaseFirestore.instance
          .collection(FirestorePaths.linksCollection(uid))
          .where('linkType', isEqualTo: 'doctor')
          .get();

      final doctors = <_LinkedDoctor>[];
      for (final doc in snap.docs) {
        final d = doc.data();
        if (d['status'] != 'active') continue;

        final linkedUid = d['linkedUid'] as String? ?? '';
        String name = 'Arzt';
        String email = '';
        String specialty = '';

        // Try to get doctor's user info
        try {
          final userDoc = await FirebaseFirestore.instance
              .doc(FirestorePaths.userDoc(linkedUid))
              .get();
          final ud = userDoc.data() ?? {};
          name = (ud['displayName'] ?? '').toString();
          email = (ud['email'] ?? '').toString();
          specialty = (ud['specialty'] ?? '').toString();
          if (name.isEmpty) name = email.isNotEmpty ? email : 'Arzt';
        } catch (_) {}

        final created = d['createdAt'];
        String since = '';
        if (created is Timestamp) {
          final dt = created.toDate();
          since = '${dt.day.toString().padLeft(2, '0')}.'
              '${dt.month.toString().padLeft(2, '0')}.${dt.year}';
        }

        final rawPerms = d['featurePermissions'] as Map<String, dynamic>?;
        final perms = DoctorPermissions.fromMap(rawPerms);

        doctors.add(_LinkedDoctor(
          linkDocId: doc.id,
          doctorUid: linkedUid,
          name: name,
          email: email,
          specialty: specialty,
          connectedSince: since,
          permissions: perms,
        ));
      }

      if (mounted) {
        setState(() {
          _doctors = doctors;
          _loading = false;
        });
      }
    } catch (_) {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _showPermissionsSheet(int index) async {
    final doctor = _doctors[index];
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;

    final linkDocPath =
        '${FirestorePaths.linksCollection(uid)}/${doctor.linkDocId}';

    final result = await showModalBottomSheet<DoctorPermissions>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _DoctorPermissionsSheet(
        linkDocPath: linkDocPath,
        doctorName: doctor.name,
        initialPermissions: doctor.permissions,
      ),
    );

    if (result != null && mounted) {
      setState(() {
        _doctors[index] = _LinkedDoctor(
          linkDocId: doctor.linkDocId,
          doctorUid: doctor.doctorUid,
          name: doctor.name,
          email: doctor.email,
          specialty: doctor.specialty,
          connectedSince: doctor.connectedSince,
          permissions: result,
        );
      });
    }
  }

  Future<void> _confirmRemove(int index) async {
    final doctor = _doctors[index];
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Arzt trennen'),
        content: Text(
          'Möchtest du die Verbindung mit ${doctor.name} wirklich auflösen?\n\n'
          'Der Arzt verliert sofort den Zugriff auf deine Daten.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Abbrechen'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: AppColors.error,
            ),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Trennen'),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;

    try {
      final callable =
          FirebaseFunctions.instance.httpsCallable('unlinkPatient');
      final uid = FirebaseAuth.instance.currentUser?.uid;
      if (uid == null) return;
      await callable.call<dynamic>({
        'patientId': uid,
        'linkType': 'doctor',
        'linkedUid': doctor.doctorUid,
      });
      HapticFeedback.mediumImpact();
      if (mounted) {
        setState(() => _doctors.removeAt(index));
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Verbindung aufgelöst')),
        );
      }
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Fehler beim Trennen')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return GlassPage(
      title: 'Meine Ärzte',
      titleIcon: AppIcons.vitals,
      titleColor: AppColors.primary,
      children: [
        if (_loading)
          const Center(child: CircularProgressIndicator())
        else if (_doctors.isEmpty)
          _buildEmpty()
        else
          for (var i = 0; i < _doctors.length; i++) ...[
            _DoctorCard(
              doctor: _doctors[i],
              onPermissions: () => _showPermissionsSheet(i),
              onRemove: () => _confirmRemove(i),
            ),
            if (i < _doctors.length - 1) const SizedBox(height: AppSpacing.md),
          ],
      ],
    );
  }

  Widget _buildEmpty() {
    return GlassContainer(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xxl),
        child: Column(
          children: [
            const Text('🩺', style: TextStyle(fontSize: 48)),
            const SizedBox(height: AppSpacing.lg),
            Text(
              'Noch kein Arzt verbunden',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              'Verbinde dich über den Bereich "Arzt verbinden" mit deinem Arzt.',
              textAlign: TextAlign.center,
              style: TextStyle(color: AppColors.grey600),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Data Model ───────────────────────────────────────────────────────

class _LinkedDoctor {
  const _LinkedDoctor({
    required this.linkDocId,
    required this.doctorUid,
    required this.name,
    required this.email,
    required this.specialty,
    required this.connectedSince,
    required this.permissions,
  });

  final String linkDocId;
  final String doctorUid;
  final String name;
  final String email;
  final String specialty;
  final String connectedSince;
  final DoctorPermissions permissions;

  String get initials {
    final parts = name.split(' ').where((w) => w.isNotEmpty).take(2);
    return parts.map((w) => w[0].toUpperCase()).join();
  }
}

// ── Doctor Card ──────────────────────────────────────────────────────

class _DoctorCard extends StatelessWidget {
  const _DoctorCard({
    required this.doctor,
    required this.onPermissions,
    required this.onRemove,
  });

  final _LinkedDoctor doctor;
  final VoidCallback onPermissions;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    final initials = doctor.initials.isEmpty ? '?' : doctor.initials;
    final enabledCount = DoctorPermissions.featureLabels.keys
        .where((k) => doctor.permissions[k].canRead)
        .length;
    final totalCount = DoctorPermissions.featureLabels.length;

    return GlassContainer(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 22,
                backgroundColor: AppColors.primary.withValues(alpha: 0.12),
                child: Text(
                  initials,
                  style: TextStyle(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      doctor.name,
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 15,
                      ),
                    ),
                    if (doctor.specialty.isNotEmpty)
                      Text(
                        doctor.specialty,
                        style: TextStyle(
                          fontSize: 12,
                          color: AppColors.grey600,
                        ),
                      ),
                  ],
                ),
              ),
              PopupMenuButton<String>(
                itemBuilder: (_) => [
                  const PopupMenuItem(
                    value: 'permissions',
                    child: Row(
                      children: [
                        Icon(Icons.tune_rounded, size: 18),
                        SizedBox(width: 8),
                        Text('Berechtigungen'),
                      ],
                    ),
                  ),
                  const PopupMenuItem(
                    value: 'remove',
                    child: Row(
                      children: [
                        Icon(Icons.link_off_rounded,
                            size: 18, color: Colors.red),
                        SizedBox(width: 8),
                        Text('Trennen',
                            style: TextStyle(color: Colors.red)),
                      ],
                    ),
                  ),
                ],
                onSelected: (v) {
                  if (v == 'permissions') onPermissions();
                  if (v == 'remove') onRemove();
                },
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          Container(height: 1, color: AppColors.grey200),
          const SizedBox(height: AppSpacing.sm),
          Row(
            children: [
              if (doctor.connectedSince.isNotEmpty)
                Text(
                  'Seit ${doctor.connectedSince}',
                  style: TextStyle(fontSize: 12, color: AppColors.grey500),
                ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.md,
                  vertical: AppSpacing.xs,
                ),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.08),
                  borderRadius: AppRadius.borderRadiusPill,
                ),
                child: Text(
                  '$enabledCount / $totalCount Features',
                  style: TextStyle(
                    fontSize: 11,
                    color: AppColors.primary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              GestureDetector(
                onTap: onPermissions,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.md,
                    vertical: AppSpacing.xs,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.08),
                    borderRadius: AppRadius.borderRadiusPill,
                    border: Border.all(
                      color: AppColors.primary.withValues(alpha: 0.20),
                    ),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.tune_rounded, size: 14),
                      SizedBox(width: AppSpacing.xs),
                      Text('Berechtigungen',
                          style: TextStyle(fontSize: 12)),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ── Permissions Sheet ────────────────────────────────────────────────

class _DoctorPermissionsSheet extends StatefulWidget {
  const _DoctorPermissionsSheet({
    required this.linkDocPath,
    required this.doctorName,
    required this.initialPermissions,
  });

  final String linkDocPath;
  final String doctorName;
  final DoctorPermissions initialPermissions;

  @override
  State<_DoctorPermissionsSheet> createState() =>
      _DoctorPermissionsSheetState();
}

class _DoctorPermissionsSheetState extends State<_DoctorPermissionsSheet> {
  late DoctorPermissions _permissions;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _permissions = widget.initialPermissions;
  }

  Future<void> _save() async {
    setState(() => _saving = true);
    try {
      // Derive binary permissions from featurePermissions to keep them
      // consistent. The binary flags are used for legacy/generic checks.
      final features = DoctorPermissions.featureLabels.keys;
      final anyRead = features.any((k) => _permissions[k].canRead);
      final anyWrite = features.any((k) => _permissions[k].canWrite);

      await FirebaseFirestore.instance.doc(widget.linkDocPath).update({
        'featurePermissions': _permissions.toMap(),
        'permissions': {'read': anyRead, 'write': anyWrite},
      });
      HapticFeedback.mediumImpact();
      if (mounted) Navigator.of(context).pop(_permissions);
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Fehler beim Speichern')),
        );
        setState(() => _saving = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final bottomPad = MediaQuery.of(context).viewInsets.bottom;
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      padding: EdgeInsets.only(bottom: bottomPad),
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.xxl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.grey300,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: AppSpacing.xl),
            Text(
              'Berechtigungen für ${widget.doctorName}',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
            ),
            const SizedBox(height: AppSpacing.xs),
            Text(
              'Lege fest, auf welche Daten dein Arzt zugreifen darf.',
              style: TextStyle(fontSize: 13, color: AppColors.grey600),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpacing.lg),

            // Quick actions
            Wrap(
              spacing: 8,
              runSpacing: 4,
              children: [
                ActionChip(
                  avatar: const Icon(Icons.check_circle_outline, size: 16),
                  label: const Text('Alles freigeben',
                      style: TextStyle(fontSize: 12)),
                  onPressed: () => setState(
                      () => _permissions = DoctorPermissions.allAccess),
                ),
                ActionChip(
                  avatar: const Icon(Icons.visibility_outlined, size: 16),
                  label: const Text('Nur Lesen',
                      style: TextStyle(fontSize: 12)),
                  onPressed: () => setState(
                      () => _permissions = DoctorPermissions.readOnly),
                ),
                ActionChip(
                  avatar:
                      const Icon(Icons.visibility_off_outlined, size: 16),
                  label:
                      const Text('Minimal', style: TextStyle(fontSize: 12)),
                  onPressed: () => setState(
                      () => _permissions = DoctorPermissions.minimal),
                ),
              ],
            ),

            const SizedBox(height: AppSpacing.lg),

            // Per-feature controls
            for (final entry
                in DoctorPermissions.featureLabels.entries) ...[
              _PermissionRow(
                label: entry.value,
                icon:
                    DoctorPermissions.featureIcons[entry.key] ?? const IconData(0xe873, fontFamily: 'MaterialIcons'),
                value: _permissions[entry.key],
                onChanged: (v) => setState(
                    () => _permissions =
                        _permissions.copyWithFeature(entry.key, v)),
              ),
            ],

            const SizedBox(height: AppSpacing.xxl),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: _saving ? null : _save,
                child: Text(_saving ? 'Speichern...' : 'Speichern'),
              ),
            ),
            const SizedBox(height: AppSpacing.md),
          ],
        ),
      ),
    );
  }
}

class _PermissionRow extends StatelessWidget {
  const _PermissionRow({
    required this.label,
    required this.icon,
    required this.value,
    required this.onChanged,
  });

  final String label;
  final IconData icon;
  final FeatureAccess value;
  final ValueChanged<FeatureAccess> onChanged;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Icon(
            icon,
            size: 20,
            color: value == FeatureAccess.none
                ? AppColors.grey400
                : AppColors.primary,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              label,
              style: TextStyle(
                fontSize: 14,
                color: value == FeatureAccess.none
                    ? AppColors.grey500
                    : null,
              ),
            ),
          ),
          SegmentedButton<FeatureAccess>(
            segments: const [
              ButtonSegment(
                value: FeatureAccess.none,
                label: Text('Aus', style: TextStyle(fontSize: 11)),
              ),
              ButtonSegment(
                value: FeatureAccess.read,
                label: Text('Lesen', style: TextStyle(fontSize: 11)),
              ),
              ButtonSegment(
                value: FeatureAccess.readWrite,
                label: Text('Voll', style: TextStyle(fontSize: 11)),
              ),
            ],
            selected: {value},
            onSelectionChanged: (s) => onChanged(s.first),
            showSelectedIcon: false,
            style: ButtonStyle(
              visualDensity: VisualDensity.compact,
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
          ),
        ],
      ),
    );
  }
}
