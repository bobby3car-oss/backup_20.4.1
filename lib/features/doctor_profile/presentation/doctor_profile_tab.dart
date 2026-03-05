import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
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
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Fehler: $e')),
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: AppBackground(
        child: SafeArea(
          child: !_loaded
              ? const Center(child: CircularProgressIndicator())
              : ListView(
                  padding: AppSpacing.screenPadding,
                  children: [
                    const SizedBox(height: AppSpacing.md),
                    Text(
                      'Mein Profil',
                      style: Theme.of(context)
                          .textTheme
                          .headlineSmall
                          ?.copyWith(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: AppSpacing.xxl),

                    // ── Profile fields ─────────────────────────────
                    GlassContainer(
                      padding: AppSpacing.paddingLg,
                      child: Column(
                        children: [
                          TextField(
                            controller: _nameController,
                            decoration:
                                const InputDecoration(labelText: 'Name'),
                          ),
                          const SizedBox(height: AppSpacing.md),
                          TextField(
                            controller: _specialtyController,
                            decoration: const InputDecoration(
                                labelText: 'Fachrichtung'),
                          ),
                          const SizedBox(height: AppSpacing.md),
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
                          const SizedBox(height: AppSpacing.xl),
                          SizedBox(
                            width: double.infinity,
                            child: FilledButton(
                              onPressed: _busy ? null : _saveProfile,
                              child: Text(
                                  _busy ? 'Speichern...' : 'Profil speichern'),
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: AppSpacing.xxl),

                    // ── Linked patients management ─────────────────
                    Text(
                      'Verknüpfte Patienten',
                      style: Theme.of(context)
                          .textTheme
                          .titleMedium
                          ?.copyWith(fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(height: AppSpacing.sm),

                    StreamBuilder<List<LinkedPatient>>(
                      stream: _patientRepo.watchLinkedPatients(),
                      builder: (context, snapshot) {
                        final patients = snapshot.data ?? [];
                        if (patients.isEmpty) {
                          return GlassCard(
                            child: Text(
                              'Keine Patienten verknüpft.',
                              style:
                                  TextStyle(color: AppColors.textSecondary),
                            ),
                          );
                        }

                        return Column(
                          children: patients.map((patient) {
                            return GlassCard(
                              child: Row(
                                children: [
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          patient.displayName,
                                          style: const TextStyle(
                                              fontWeight: FontWeight.w500),
                                        ),
                                        Text(
                                          patient.email,
                                          style: TextStyle(
                                            fontSize: 12,
                                            color: AppColors.textSecondary,
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
                                      final ok = await showDialog<bool>(
                                        context: context,
                                        builder: (ctx) => AlertDialog(
                                          title: const Text(
                                              'Verbindung trennen?'),
                                          actions: [
                                            TextButton(
                                              onPressed: () =>
                                                  Navigator.pop(ctx, false),
                                              child:
                                                  const Text('Abbrechen'),
                                            ),
                                            FilledButton(
                                              onPressed: () =>
                                                  Navigator.pop(ctx, true),
                                              child: const Text('Trennen'),
                                            ),
                                          ],
                                        ),
                                      );
                                      if (ok == true) {
                                        await _patientRepo
                                            .unlinkPatient(patient.uid);
                                      }
                                    },
                                  ),
                                ],
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
}
