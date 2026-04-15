import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../../firebase/firebase_paths.dart';
import '../../../security/field_encryption_service.dart';
import '../../../ui/ui.dart';
import '../../../features/doctor_invite/presentation/connect_doctor_screen.dart';
import '../data/patient_aftercare_plan_service.dart';
import '../domain/patient_aftercare_plan.dart';
import 'patient_plan_view_screen.dart';

/// Patient-side hub for aftercare plan access.
///
/// Three states:
///  1. No doctor linked → prompt to connect
///  2. Doctor linked but no plan → ask doctor
///  3. Doctor linked + plan exists → navigate to plan view
class PatientPlanHubScreen extends StatefulWidget {
  const PatientPlanHubScreen({super.key});

  @override
  State<PatientPlanHubScreen> createState() => _PatientPlanHubScreenState();
}

class _PatientPlanHubScreenState extends State<PatientPlanHubScreen> {
  final _firestore = FirebaseFirestore.instance;
  bool _loading = true;
  bool _hasLinkedDoctor = false;
  String? _doctorName;

  @override
  void initState() {
    super.initState();
    _checkLinkedDoctor();
  }

  Future<void> _checkLinkedDoctor() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) {
      if (mounted) setState(() => _loading = false);
      return;
    }

    try {
      final snap = await _firestore
          .collection(FirestorePaths.linksCollection(uid))
          .where('linkType', isEqualTo: 'doctor')
          .where('status', isEqualTo: 'active')
          .limit(1)
          .get();

      if (snap.docs.isNotEmpty) {
        final linkedUid =
            snap.docs.first.data()['linkedUid'] as String? ?? '';
        String? name;
        if (linkedUid.isNotEmpty) {
          try {
            final userDoc = await _firestore
                .doc(FirestorePaths.userDoc(linkedUid))
                .get();
            final data = userDoc.data();
            if (data != null) {
              final decrypted = FieldEncryptionService.instance
                  .decryptFields(linkedUid, data, kEncryptedUserFields);
              name = (decrypted['displayName'] ?? '').toString();
            }
            if (name != null && name.isEmpty) name = null;
          } catch (_) {}
        }
        if (mounted) {
          setState(() {
            _hasLinkedDoctor = true;
            _doctorName = name;
            _loading = false;
          });
        }
      } else {
        if (mounted) {
          setState(() {
            _hasLinkedDoctor = false;
            _loading = false;
          });
        }
      }
    } catch (_) {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final uid = FirebaseAuth.instance.currentUser?.uid ?? '';

    return GlassPage(
      title: 'Mein Behandlungsplan',
      titleIcon: Icons.assignment_rounded,
      scrollableBody: (headerHeight) {
        if (_loading) {
          return Padding(
            padding: EdgeInsets.only(top: headerHeight + AppSpacing.huge),
            child: const Center(child: CupertinoActivityIndicator()),
          );
        }

        // State 1: No doctor linked
        if (!_hasLinkedDoctor) {
          return _NoDoctorState(headerHeight: headerHeight);
        }

        // State 2 & 3: Doctor linked — stream plan
        return StreamBuilder<PatientAftercarePlan?>(
          stream: PatientAftercarePlanService()
              .getCurrentPatientPlan(uid),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting &&
                !snapshot.hasData) {
              return Padding(
                padding:
                    EdgeInsets.only(top: headerHeight + AppSpacing.huge),
                child:
                    const Center(child: CupertinoActivityIndicator()),
              );
            }

            final plan = snapshot.data;

            if (plan == null) {
              // State 2: Doctor linked but no plan
              return _NoPlanState(
                headerHeight: headerHeight,
                doctorName: _doctorName,
              );
            }

            // State 3: Plan exists → navigate to full view
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (!mounted) return;
              Navigator.of(context).pushReplacement(
                CupertinoPageRoute<void>(
                  builder: (_) => PatientPlanViewScreen(patientId: uid),
                ),
              );
            });

            return Padding(
              padding:
                  EdgeInsets.only(top: headerHeight + AppSpacing.huge),
              child: const Center(child: CupertinoActivityIndicator()),
            );
          },
        );
      },
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// State 1: No doctor linked
// ═══════════════════════════════════════════════════════════════════════════

class _NoDoctorState extends StatelessWidget {
  const _NoDoctorState({required this.headerHeight});
  final double headerHeight;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 480),
        child: Padding(
          padding: EdgeInsets.only(
            top: headerHeight + AppSpacing.xl,
            left: AppSpacing.lg,
            right: AppSpacing.lg,
          ),
          child: FadeSlideIn(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.08),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.person_add_alt_1_rounded,
                    size: 40,
                    color: AppColors.primary,
                  ),
                ),
                const SizedBox(height: AppSpacing.xl),
                Text(
                  'Persönlicher Behandlungsplan',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                      ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: AppSpacing.md),
                Text(
                  'Erhalten Sie einen individuellen Nachbehandlungsplan '
                  'von Ihrem Arzt — speziell auf Ihre Operation abgestimmt.',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppColors.textSecondary,
                        height: 1.5,
                      ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: AppSpacing.lg),
                GlassCard(
                  child: Row(
                    children: [
                      Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: AppColors.accent.withValues(alpha: 0.1),
                          borderRadius: AppRadius.borderRadiusMd,
                        ),
                        child: Icon(Icons.link_rounded,
                            size: 22, color: AppColors.accent),
                      ),
                      const SizedBox(width: AppSpacing.md),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Arzt verbinden',
                              style: Theme.of(context)
                                  .textTheme
                                  .titleSmall
                                  ?.copyWith(
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.textPrimary,
                                  ),
                            ),
                            const SizedBox(height: AppSpacing.xxs),
                            Text(
                              'Verbinden Sie sich mit Ihrem Arzt, um einen '
                              'personalisierten Plan zu erhalten.',
                              style: Theme.of(context)
                                  .textTheme
                                  .bodySmall
                                  ?.copyWith(color: AppColors.textSecondary),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: AppSpacing.xl),
                GlassButton(
                  label: 'Mit Arzt verbinden',
                  icon: Icons.person_add_rounded,
                  onPressed: () => Navigator.of(context).push(
                    CupertinoPageRoute<void>(
                      builder: (_) => const ConnectDoctorScreen(),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// State 2: Doctor linked but no plan assigned
// ═══════════════════════════════════════════════════════════════════════════

class _NoPlanState extends StatelessWidget {
  const _NoPlanState({
    required this.headerHeight,
    this.doctorName,
  });
  final double headerHeight;
  final String? doctorName;

  @override
  Widget build(BuildContext context) {
    final doctor = doctorName ?? 'Ihren Arzt';

    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 480),
        child: Padding(
          padding: EdgeInsets.only(
            top: headerHeight + AppSpacing.xl,
            left: AppSpacing.lg,
            right: AppSpacing.lg,
          ),
          child: FadeSlideIn(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    color: AppColors.success.withValues(alpha: 0.08),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.check_circle_outline_rounded,
                    size: 40,
                    color: AppColors.success,
                  ),
                ),
                const SizedBox(height: AppSpacing.xl),
                Text(
                  'Arzt verbunden',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                      ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: AppSpacing.sm),
                if (doctorName != null && doctorName!.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(bottom: AppSpacing.md),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.person_rounded,
                            size: 16, color: AppColors.primary),
                        const SizedBox(width: AppSpacing.xs),
                        Text(
                          doctorName!,
                          style: Theme.of(context)
                              .textTheme
                              .bodyMedium
                              ?.copyWith(
                                color: AppColors.primary,
                                fontWeight: FontWeight.w600,
                              ),
                        ),
                      ],
                    ),
                  ),
                Text(
                  'Ihr Arzt hat Ihnen noch keinen '
                  'Nachbehandlungsplan zugewiesen.',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppColors.textSecondary,
                        height: 1.5,
                      ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: AppSpacing.lg),
                GlassCard(
                  child: Row(
                    children: [
                      Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: AppColors.primary.withValues(alpha: 0.1),
                          borderRadius: AppRadius.borderRadiusMd,
                        ),
                        child: Icon(Icons.assignment_rounded,
                            size: 22, color: AppColors.primary),
                      ),
                      const SizedBox(width: AppSpacing.md),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Persönlicher Plan',
                              style: Theme.of(context)
                                  .textTheme
                                  .titleSmall
                                  ?.copyWith(
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.textPrimary,
                                  ),
                            ),
                            const SizedBox(height: AppSpacing.xxs),
                            Text(
                              'Bitten Sie $doctor um einen '
                              'personalisierten Nachbehandlungsplan '
                              'für Ihre Operation.',
                              style: Theme.of(context)
                                  .textTheme
                                  .bodySmall
                                  ?.copyWith(color: AppColors.textSecondary),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: AppSpacing.lg),
                Opacity(
                  opacity: 0.7,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.info_outline_rounded,
                          size: 14, color: AppColors.grey500),
                      const SizedBox(width: AppSpacing.xs),
                      Text(
                        'Sobald ein Plan zugewiesen wurde,\nerscheint er automatisch hier.',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: AppColors.grey500,
                              fontSize: 12,
                            ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
