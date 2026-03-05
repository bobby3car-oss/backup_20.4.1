import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../../../auth/auth_service.dart';
import '../../../firebase/firebase_paths.dart';
import '../../../ui/ui.dart';
import '../../doctor_patients/data/doctor_patient_repository.dart';
import '../../doctor_patients/domain/linked_patient.dart';

/// The profile & settings tab for the doctor account.
class DoctorProfileTab extends StatefulWidget {
  const DoctorProfileTab({super.key});

  @override
  State<DoctorProfileTab> createState() => _DoctorProfileTabState();
}

class _DoctorProfileTabState extends State<DoctorProfileTab> {
  final _firestore = FirebaseFirestore.instance;
  final _auth = FirebaseAuth.instance;
  final _patientRepo = DoctorPatientRepository();

  final _nameController = TextEditingController();
  final _specialtyController = TextEditingController();
  final _addressController = TextEditingController();
  final _phoneController = TextEditingController();

  bool _busy = false;
  bool _loaded = false;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    final uid = _auth.currentUser?.uid;
    if (uid == null) return;

    final doc = await _firestore.doc(FirestorePaths.userDoc(uid)).get();
    final data = doc.data() ?? const <String, dynamic>{};

    _nameController.text = (data['displayName'] ?? '').toString();
    _specialtyController.text = (data['specialty'] ?? '').toString();
    _addressController.text = (data['practiceAddress'] ?? '').toString();
    _phoneController.text = (data['phone'] ?? '').toString();

    if (mounted) setState(() => _loaded = true);
  }

  Future<void> _saveProfile() async {
    final uid = _auth.currentUser?.uid;
    if (uid == null) return;

    setState(() => _busy = true);
    try {
      await _firestore.doc(FirestorePaths.userDoc(uid)).set(
        <String, dynamic>{
          'displayName': _nameController.text.trim(),
          'specialty': _specialtyController.text.trim(),
          'practiceAddress': _addressController.text.trim(),
          'phone': _phoneController.text.trim(),
          'updatedAt': FieldValue.serverTimestamp(),
        },
        SetOptions(merge: true),
      );
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Profil gespeichert')),
        );
      }
    } catch (e) {
      if (kDebugMode) debugPrint('[DoctorProfileTab] save error: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Profil konnte nicht gespeichert werden.')),
        );
      }
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _specialtyController.dispose();
    _addressController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  String get _initials {
    final name = _nameController.text.trim();
    if (name.isEmpty) return '?';
    final parts = name.split(' ').where((s) => s.isNotEmpty).toList();
    if (parts.length >= 2) {
      return '${parts.first[0]}${parts.last[0]}'.toUpperCase();
    }
    return parts.first[0].toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final email = _auth.currentUser?.email ?? '';

    return Scaffold(
      backgroundColor: AppColors.background,
      body: AppBackground(
        child: SafeArea(
          child: !_loaded
              ? const Center(child: CircularProgressIndicator())
              : ListView(
                  padding: const EdgeInsets.fromLTRB(
                    AppSpacing.xl,
                    AppSpacing.lg,
                    AppSpacing.xl,
                    120,
                  ),
                  children: [
                    const SizedBox(height: AppSpacing.md),
                    Text(
                      'Mein Profil',
                      style: theme.textTheme.headlineSmall
                          ?.copyWith(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: AppSpacing.xxl),

                    // ── Avatar + Name header ───────────────────────
                    Center(
                      child: Column(
                        children: [
                          Container(
                            width: 80,
                            height: 80,
                            decoration: const BoxDecoration(
                              shape: BoxShape.circle,
                              gradient: AppColors.primaryGradient,
                            ),
                            child: Center(
                              child: Text(
                                _initials,
                                style: const TextStyle(
                                  fontSize: 28,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.white,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: AppSpacing.md),
                          if (_nameController.text.trim().isNotEmpty)
                            Text(
                              _nameController.text.trim(),
                              style: theme.textTheme.titleLarge?.copyWith(
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          if (email.isNotEmpty) ...[
                            const SizedBox(height: AppSpacing.xxs),
                            Text(
                              email,
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: AppColors.textSecondary,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),

                    const SizedBox(height: AppSpacing.xxl),

                    // ── Section: Personal ──────────────────────────
                    _ProfileSectionTitle(
                      icon: Icons.person_rounded,
                      title: 'Persönliche Daten',
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    GlassContainer(
                      padding: AppSpacing.paddingLg,
                      child: Column(
                        children: [
                          TextField(
                            controller: _nameController,
                            decoration:
                                const InputDecoration(labelText: 'Name'),
                            onChanged: (_) => setState(() {}),
                          ),
                          const SizedBox(height: AppSpacing.md),
                          TextField(
                            controller: _specialtyController,
                            decoration: const InputDecoration(
                                labelText: 'Fachrichtung'),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: AppSpacing.xl),

                    // ── Section: Practice ──────────────────────────
                    _ProfileSectionTitle(
                      icon: Icons.local_hospital_rounded,
                      title: 'Praxisinformationen',
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    GlassContainer(
                      padding: AppSpacing.paddingLg,
                      child: Column(
                        children: [
                          TextField(
                            controller: _addressController,
                            decoration: const InputDecoration(
                                labelText: 'Praxisadresse'),
                            maxLines: 2,
                          ),
                          const SizedBox(height: AppSpacing.md),
                          TextField(
                            controller: _phoneController,
                            decoration: const InputDecoration(
                                labelText: 'Telefonnummer'),
                            keyboardType: TextInputType.phone,
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: AppSpacing.lg),
                    SizedBox(
                      width: double.infinity,
                      child: FilledButton.icon(
                        onPressed: _busy ? null : _saveProfile,
                        icon: Icon(_busy
                            ? Icons.hourglass_top_rounded
                            : Icons.save_rounded),
                        label: Text(
                            _busy ? 'Speichern...' : 'Profil speichern'),
                      ),
                    ),

                    const SizedBox(height: AppSpacing.xxl),

                    // ── Section: Linked patients ───────────────────
                    _ProfileSectionTitle(
                      icon: Icons.people_rounded,
                      title: 'Verknüpfte Patienten',
                    ),
                    const SizedBox(height: AppSpacing.sm),

                    StreamBuilder<List<LinkedPatient>>(
                      stream: _patientRepo.watchLinkedPatients(),
                      builder: (context, snapshot) {
                        final patients = snapshot.data ?? [];
                        if (patients.isEmpty) {
                          return GlassCard(
                            child: Row(
                              children: [
                                Icon(Icons.person_off_rounded,
                                    color: AppColors.grey400, size: 24),
                                const SizedBox(width: AppSpacing.md),
                                Text(
                                  'Keine Patienten verknüpft.',
                                  style: TextStyle(
                                      color: AppColors.textSecondary),
                                ),
                              ],
                            ),
                          );
                        }

                        return Column(
                          children: patients.map((patient) {
                            final initials = _patientInitials(
                                patient.displayName);
                            return Padding(
                              padding: const EdgeInsets.only(
                                  bottom: AppSpacing.sm),
                              child: GlassCard(
                                child: Row(
                                  children: [
                                    Container(
                                      width: 36,
                                      height: 36,
                                      decoration: BoxDecoration(
                                        color: AppColors.primary
                                            .withValues(alpha: 0.1),
                                        shape: BoxShape.circle,
                                      ),
                                      child: Center(
                                        child: Text(
                                          initials,
                                          style: TextStyle(
                                            fontSize: 13,
                                            fontWeight: FontWeight.w600,
                                            color: AppColors.primary,
                                          ),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: AppSpacing.md),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            patient.displayName,
                                            style: const TextStyle(
                                                fontWeight:
                                                    FontWeight.w500),
                                          ),
                                          Text(
                                            patient.email,
                                            style: TextStyle(
                                              fontSize: 12,
                                              color:
                                                  AppColors.textSecondary,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    IconButton(
                                      icon: Icon(Icons.link_off,
                                          color: AppColors.error),
                                      tooltip: 'Verbindung trennen',
                                      onPressed: () async {
                                        final ok =
                                            await showDialog<bool>(
                                          context: context,
                                          builder: (ctx) => AlertDialog(
                                            title: const Text(
                                                'Verbindung trennen?'),
                                            content: Text(
                                              'Die Verbindung zu ${patient.displayName} wird getrennt.',
                                            ),
                                            actions: [
                                              TextButton(
                                                onPressed: () =>
                                                    Navigator.pop(
                                                        ctx, false),
                                                child: const Text(
                                                    'Abbrechen'),
                                              ),
                                              FilledButton(
                                                onPressed: () =>
                                                    Navigator.pop(
                                                        ctx, true),
                                                child: const Text(
                                                    'Trennen'),
                                              ),
                                            ],
                                          ),
                                        );
                                        if (ok == true) {
                                          await _patientRepo
                                              .unlinkPatient(
                                                  patient.uid);
                                        }
                                      },
                                    ),
                                  ],
                                ),
                              ),
                            );
                          }).toList(growable: false),
                        );
                      },
                    ),

                    const SizedBox(height: AppSpacing.xxxl),

                    // ── Logout ─────────────────────────────────────
                    Center(
                      child: OutlinedButton.icon(
                        onPressed: () => AuthService().signOut(),
                        icon: const Icon(Icons.logout_rounded),
                        label: const Text('Abmelden'),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AppColors.error,
                        ),
                      ),
                    ),

                    const SizedBox(height: AppSpacing.xxl),
                  ],
                ),
        ),
      ),
    );
  }

  String _patientInitials(String name) {
    if (name.isEmpty) return '?';
    final parts = name.split(' ').where((s) => s.isNotEmpty).toList();
    if (parts.length >= 2) {
      return '${parts.first[0]}${parts.last[0]}'.toUpperCase();
    }
    return parts.first[0].toUpperCase();
  }
}

class _ProfileSectionTitle extends StatelessWidget {
  const _ProfileSectionTitle({
    required this.icon,
    required this.title,
  });

  final IconData icon;
  final String title;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 18, color: AppColors.textSecondary),
        const SizedBox(width: AppSpacing.sm),
        Text(
          title,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
        ),
      ],
    );
  }
}
