import 'package:cloud_functions/cloud_functions.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../ui/ui.dart';
import '../features/family/data/family_repository.dart';
import '../features/family/domain/linked_family_patient.dart';
import '../features/family/presentation/family_patient_detail_screen.dart';

const _kPendingFamilyCodeKey = 'pendingFamilyInviteCode';

/// Hub screen for patients acting as family members.
///
/// Shows linked patients from [FamilyRepository] and lets the user
/// enter a new invite code to link another patient.
class FamilyMemberHubScreen extends StatefulWidget {
  const FamilyMemberHubScreen({super.key, this.initialCode});

  /// Optional pre-filled invite code (e.g. from a deep link).
  final String? initialCode;

  @override
  State<FamilyMemberHubScreen> createState() => _FamilyMemberHubScreenState();
}

class _FamilyMemberHubScreenState extends State<FamilyMemberHubScreen> {
  final _repo = FamilyRepository();

  @override
  void initState() {
    super.initState();
    _checkPendingCode();
  }

  Future<void> _checkPendingCode() async {
    // Direct constructor code takes priority.
    if (widget.initialCode != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) _showCodeEntryDialog(prefill: widget.initialCode!);
      });
      return;
    }

    // Otherwise check SharedPreferences for a code from a deep link.
    final prefs = await SharedPreferences.getInstance();
    final pending = prefs.getString(_kPendingFamilyCodeKey);
    if (pending != null && pending.isNotEmpty) {
      await prefs.remove(_kPendingFamilyCodeKey);
      if (mounted) _showCodeEntryDialog(prefill: pending);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return GlassPage(
      title: 'Patienten begleiten',
      titleIcon: Icons.family_restroom_rounded,
      trailing: PressableScale(
        onTap: () {
          Haptic.light();
          _showCodeEntryDialog();
        },
        child: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [
                AppColors.primary,
                AppColors.accent,
              ],
            ),
            borderRadius: AppRadius.borderRadiusSm,
          ),
          child: const Icon(
            Icons.person_add_rounded,
            color: Colors.white,
            size: 20,
          ),
        ),
      ),
      scrollableBody: (headerHeight) => StreamBuilder<List<LinkedFamilyPatient>>(
        stream: _repo.watchLinkedPatients(),
        builder: (context, snap) {
          final patients = snap.data ?? [];
          final isLoading =
              snap.connectionState == ConnectionState.waiting;

          return ListView(
            physics: adaptiveScrollPhysics,
            padding: EdgeInsets.only(
              left: AppSpacing.xl,
              right: AppSpacing.xl,
              top: headerHeight + AppSpacing.md,
              bottom: 120,
            ),
            children: [
              // ── Description ───────────────────────────
              Text(
                'Begleite Patienten durch ihre OP-Reise. '
                'Gib einen Einladungscode ein, um dich mit '
                'einem Patienten zu verbinden.',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: AppSpacing.xl),

              // ── Loading ───────────────────────────────
              if (isLoading)
                const Padding(
                  padding: EdgeInsets.only(top: 80),
                  child: Center(child: CircularProgressIndicator()),
                ),

              // ── Empty state ───────────────────────────
              if (!isLoading && patients.isEmpty)
                Padding(
                  padding: const EdgeInsets.all(AppSpacing.xxl),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const SizedBox(height: 40),
                      Container(
                        width: 80,
                        height: 80,
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [
                              AppColors.primary,
                              AppColors.accent,
                            ],
                          ),
                          borderRadius: AppRadius.borderRadiusMd,
                        ),
                        child: const Icon(
                          Icons.family_restroom_rounded,
                          color: Colors.white,
                          size: 40,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.lg),
                      Text(
                        'Noch keine Patienten',
                        style: theme.textTheme.titleMedium
                            ?.copyWith(fontWeight: FontWeight.w600),
                      ),
                      const SizedBox(height: AppSpacing.sm),
                      Text(
                        'Gib einen Einladungscode ein, den du '
                        'von einem Patienten erhalten hast, um '
                        'dich als Angehöriger zu verbinden.',
                        textAlign: TextAlign.center,
                        style: theme.textTheme.bodyMedium
                            ?.copyWith(color: AppColors.textSecondary),
                      ),
                      const SizedBox(height: AppSpacing.xl),
                      FilledButton.icon(
                        onPressed: () => _showCodeEntryDialog(),
                        icon: const Icon(Icons.vpn_key_rounded),
                        label: const Text('Code eingeben'),
                      ),
                    ],
                  ),
                ),

              // ── Patient cards ─────────────────────────
              if (!isLoading && patients.isNotEmpty)
                ...List.generate(patients.length, (index) {
                  final patient = patients[index];
                  return Padding(
                    padding: EdgeInsets.only(
                      bottom: index < patients.length - 1 ? AppSpacing.md : 0,
                    ),
                    child: FadeSlideIn(
                      delay: Duration(milliseconds: index * 80),
                      child: _PatientCard(
                        patient: patient,
                        onTap: () => Navigator.of(context).push(
                          MaterialPageRoute<void>(
                            builder: (_) =>
                                FamilyPatientDetailScreen(
                                    patient: patient),
                          ),
                        ),
                      ),
                    ),
                  );
                }),
            ],
          );
        },
      ),
    );
  }

  void _showCodeEntryDialog({String? prefill}) {
    final codeCtrl = TextEditingController(text: prefill);
    bool busy = false;

    showDialog<void>(
      context: context,
      builder: (dialogCtx) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: const Text('Patient verbinden'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    'Gib den Einladungscode ein, den du vom '
                    'Patienten erhalten hast.',
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: codeCtrl,
                    textCapitalization: TextCapitalization.characters,
                    decoration: const InputDecoration(
                      labelText: 'Einladungscode',
                      hintText: 'z.B. A1B2C3D4E5F6',
                      prefixIcon: Icon(Icons.vpn_key_outlined),
                      border: OutlineInputBorder(),
                    ),
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed:
                      busy ? null : () => Navigator.of(dialogCtx).pop(),
                  child: const Text('Abbrechen'),
                ),
                FilledButton(
                  onPressed: busy
                      ? null
                      : () async {
                          final code = codeCtrl.text.trim().toUpperCase();
                          if (code.isEmpty) return;
                          setDialogState(() => busy = true);
                          try {
                            await FirebaseFunctions.instance
                                .httpsCallable('acceptInvite')
                                .call<Map<String, dynamic>>(
                                    {'code': code});
                            if (dialogCtx.mounted) {
                              Navigator.of(dialogCtx).pop();
                              if (mounted) {
                                ScaffoldMessenger.of(context)
                                    .showSnackBar(
                                  const SnackBar(
                                    content: Text(
                                        'Erfolgreich verbunden!'),
                                  ),
                                );
                              }
                            }
                          } catch (e) {
                            setDialogState(() => busy = false);
                            if (dialogCtx.mounted) {
                              ScaffoldMessenger.of(dialogCtx)
                                  .showSnackBar(
                                SnackBar(
                                    content: Text(userFacingError(e))),
                              );
                            }
                          }
                        },
                  child: busy
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                              strokeWidth: 2),
                        )
                      : const Text('Verbinden'),
                ),
              ],
            );
          },
        );
      },
    ).then((_) => codeCtrl.dispose());
  }
}
// ═════════════════════════════════════════════════════════════════════════════

class _PatientCard extends StatelessWidget {
  const _PatientCard({required this.patient, required this.onTap});

  final LinkedFamilyPatient patient;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    String? opStatus;
    if (patient.opDate != null) {
      final diff = patient.opDate!.difference(DateTime.now()).inDays;
      if (diff > 0) {
        opStatus = 'OP in $diff Tagen';
      } else if (diff == 0) {
        opStatus = 'OP heute';
      } else {
        opStatus = '${-diff} Tage nach OP';
      }
    }

    return PressableScale(
      onTap: () {
        Haptic.light();
        onTap();
      },
      child: GlassCard(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Row(
            children: [
              // Avatar
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(colors: [
                    AppColors.primary,
                    AppColors.accent,
                  ]),
                  borderRadius: AppRadius.borderRadiusSm,
                ),
                alignment: Alignment.center,
                child: Text(
                  patient.avatarInitials,
                  style: theme.textTheme.titleMedium?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(width: AppSpacing.md),

              // Info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      patient.patientName,
                      style: theme.textTheme.titleSmall
                          ?.copyWith(fontWeight: FontWeight.w600),
                    ),
                    if (patient.opType != null)
                      Text(
                        patient.opType!,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                    if (opStatus != null)
                      Padding(
                        padding:
                            const EdgeInsets.only(top: AppSpacing.xxs),
                        child: Text(
                          opStatus,
                          style: theme.textTheme.labelSmall?.copyWith(
                            color: AppColors.primary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                  ],
                ),
              ),

              const Icon(
                Icons.chevron_right_rounded,
                color: AppColors.textSecondary,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
