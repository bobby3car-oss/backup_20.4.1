import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../../../auth/auth_service.dart';
import '../../../features/pro/data/entitlement_service.dart';
import '../../../features/pro/domain/entitlement.dart';
import '../../../features/pro/domain/trigger_context.dart';
import '../../../features/pro/presentation/smart_paywall.dart';
import '../../../firebase/firebase_paths.dart';
import '../../../main.dart';
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
    final email = _auth.currentUser?.email ?? '';
    final entService = ProServices.maybeOf(context)?.entitlementService;

    if (!_loaded) {
      return const Scaffold(
        backgroundColor: AppColors.background,
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return GlassPage(
      title: 'Mein Profil',
      titleEmoji: '👨‍⚕️',
      titleColor: AppColors.primary,
      showBackButton: false,
      children: [
        // ── Avatar + Name header ───────────────────────
        _DoctorAvatarHeader(
          name: _nameController.text.trim(),
          email: email,
          initials: _initials,
          entitlementService: entService,
          onBadgeTap: () {
            final pro = ProServices.maybeOf(context);
            if (pro != null && pro.entitlementService.isPro) {
              Navigator.of(context).pushNamed('/pro-status');
            } else {
              SmartPaywall.trigger(
                context: context,
                triggerContext: TriggerContext.manualOpen,
              );
            }
          },
        ),

        const SizedBox(height: AppSpacing.xxl),

        // ── Section: Personal ──────────────────────────
        _ProfileSectionTitle(
          icon: Icons.person_rounded,
          title: 'Persönliche Daten',
        ),
        const SizedBox(height: AppSpacing.sm),
        GlassContainer(
          padding: const EdgeInsets.all(AppSpacing.lg),
          borderRadius: AppRadius.borderRadiusXl,
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
          padding: const EdgeInsets.all(AppSpacing.lg),
          borderRadius: AppRadius.borderRadiusXl,
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
          child: GlassButton(
            onPressed: _busy ? null : _saveProfile,
            icon: _busy
                ? Icons.hourglass_top_rounded
                : Icons.save_rounded,
            label: _busy ? 'Speichern...' : 'Profil speichern',
            expand: true,
          ),
        ),

        const SizedBox(height: AppSpacing.xxl),

        // ── Section: Pro / Subscription ────────────────
        _ProfileSectionTitle(
          icon: Icons.workspace_premium_rounded,
          title: 'Abonnement',
        ),
        const SizedBox(height: AppSpacing.sm),
        _DoctorSubscriptionCard(
          entitlementService: entService,
          onUpgrade: () => SmartPaywall.trigger(
            context: context,
            triggerContext: TriggerContext.manualOpen,
          ),
          onManage: () =>
              Navigator.of(context).pushNamed('/pro-status'),
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

// ── Doctor avatar header ─────────────────────────────────────────────────────

class _DoctorAvatarHeader extends StatelessWidget {
  const _DoctorAvatarHeader({
    required this.name,
    required this.email,
    required this.initials,
    this.entitlementService,
    this.onBadgeTap,
  });

  final String name;
  final String email;
  final String initials;
  final EntitlementService? entitlementService;
  final VoidCallback? onBadgeTap;

  @override
  Widget build(BuildContext context) {
    return GlassContainer(
      padding: const EdgeInsets.all(AppSpacing.xl),
      borderRadius: AppRadius.borderRadiusXl,
      child: Row(
        children: [
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              gradient: AppColors.primaryGradient,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: AppColors.primary.withValues(alpha: 0.30),
                  blurRadius: 16,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: Center(
              child: Text(
                initials,
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                  color: AppColors.white,
                ),
              ),
            ),
          ),
          const SizedBox(width: AppSpacing.lg),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (name.isNotEmpty)
                  Text(name,
                      style: Theme.of(context).textTheme.titleLarge),
                if (email.isNotEmpty) ...[
                  const SizedBox(height: AppSpacing.xs),
                  Text(email,
                      style: Theme.of(context).textTheme.bodySmall),
                ],
                const SizedBox(height: AppSpacing.sm),
                if (entitlementService != null)
                  ValueListenableBuilder<Entitlement>(
                    valueListenable: entitlementService!.entitlement,
                    builder: (context, ent, _) {
                      final isPro = ent.isPro;
                      return GestureDetector(
                        onTap: onBadgeTap,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: AppSpacing.sm,
                            vertical: AppSpacing.xxs,
                          ),
                          decoration: BoxDecoration(
                            gradient:
                                isPro ? AppColors.primaryGradient : null,
                            color: isPro ? null : AppColors.grey200,
                            borderRadius: AppRadius.borderRadiusPill,
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                isPro
                                    ? Icons.workspace_premium_rounded
                                    : Icons.arrow_upward_rounded,
                                size: 12,
                                color: isPro
                                    ? AppColors.white
                                    : AppColors.textSecondary,
                              ),
                              const SizedBox(width: AppSpacing.xs),
                              Text(
                                isPro ? 'Pro Mitglied' : 'Upgrade auf Pro',
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                  color: isPro
                                      ? AppColors.white
                                      : AppColors.textSecondary,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ── Doctor subscription card ─────────────────────────────────────────────────

class _DoctorSubscriptionCard extends StatelessWidget {
  const _DoctorSubscriptionCard({
    required this.entitlementService,
    required this.onUpgrade,
    required this.onManage,
  });

  final EntitlementService? entitlementService;
  final VoidCallback onUpgrade;
  final VoidCallback onManage;

  @override
  Widget build(BuildContext context) {
    final service = entitlementService;
    if (service == null) {
      return _buildFree(context);
    }

    return ValueListenableBuilder<Entitlement>(
      valueListenable: service.entitlement,
      builder: (context, ent, _) {
        if (ent.isPro) return _buildPro(context, ent);
        return _buildFree(context);
      },
    );
  }

  Widget _buildPro(BuildContext context, Entitlement ent) {
    String planLabel;
    if (ent.proProductId?.contains('yearly') == true) {
      planLabel = 'Jahresabo';
    } else if (ent.proProductId?.contains('monthly') == true) {
      planLabel = 'Monatsabo';
    } else {
      planLabel = 'Pro Mitgliedschaft';
    }

    return GlassContainer(
      padding: const EdgeInsets.all(AppSpacing.lg),
      borderRadius: AppRadius.borderRadiusXl,
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              gradient: AppColors.primaryGradient,
              borderRadius: AppRadius.borderRadiusMd,
            ),
            child: const Icon(
              Icons.workspace_premium_rounded,
              size: 20,
              color: AppColors.white,
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Pro aktiv',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
                Text(
                  planLabel,
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          GestureDetector(
            onTap: onManage,
            child: Container(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.md,
                vertical: AppSpacing.xs,
              ),
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.08),
                borderRadius: AppRadius.borderRadiusPill,
              ),
              child: const Text(
                'Verwalten',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: AppColors.primary,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFree(BuildContext context) {
    return GlassContainer(
      padding: const EdgeInsets.all(AppSpacing.lg),
      borderRadius: AppRadius.borderRadiusXl,
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: AppColors.grey200,
              borderRadius: AppRadius.borderRadiusMd,
            ),
            child: const Icon(
              Icons.workspace_premium_rounded,
              size: 20,
              color: AppColors.grey500,
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Basis',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
                Text(
                  'Grundfunktionen aktiv',
                  style: TextStyle(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          GestureDetector(
            onTap: onUpgrade,
            child: Container(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.md,
                vertical: AppSpacing.xs,
              ),
              decoration: BoxDecoration(
                gradient: AppColors.primaryGradient,
                borderRadius: AppRadius.borderRadiusPill,
              ),
              child: const Text(
                'Pro entdecken',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: AppColors.white,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
