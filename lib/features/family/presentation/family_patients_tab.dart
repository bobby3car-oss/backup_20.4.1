import 'package:flutter/material.dart';

import '../../../auth/auth_service.dart';
import '../../../firebase/app_functions.dart';
import '../../../ui/ui.dart';
import '../data/family_repository.dart';
import '../domain/linked_family_patient.dart';
import 'family_patient_detail_screen.dart';
import '../../../ui/theme/app_icons.dart';
import '../../../l10n/app_localizations.dart';

/// Shows all patients this family member is linked to as cards.
///
/// If no patients are linked, shows an empty state with the option
/// to enter an invite code.
class FamilyPatientsTab extends StatefulWidget {
  const FamilyPatientsTab({super.key});

  @override
  State<FamilyPatientsTab> createState() => _FamilyPatientsTabState();
}

class _FamilyPatientsTabState extends State<FamilyPatientsTab> {
  final _repo = FamilyRepository();

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    return GlassPage(
      title: l.familyPatientsMeinePatienten,
      titleIcon: AppIcons.family,
      titleColor: AppColors.primary,
      showBackButton: false,
      horizontalPadding: AppSpacing.lg,
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            icon: const Icon(Icons.add_rounded),
            tooltip: l.weiterenPatientenHinzufuegen,
            onPressed: () => _showAddPatientDialog(context),
          ),
          IconButton(
            icon: const Icon(Icons.logout_rounded),
            tooltip: l.logout,
            onPressed: () async => AuthService().signOut(),
          ),
        ],
      ),
      children: [
        StreamBuilder<List<LinkedFamilyPatient>>(
          stream: _repo.watchLinkedPatients(),
          builder: (context, snapshot) {
            if (snapshot.hasError) {
              return _ErrorCard(message: userFacingError(snapshot.error!));
            }
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Padding(
                padding: EdgeInsets.only(top: 80),
                child: Center(child: CircularProgressIndicator()),
              );
            }

            final patients = snapshot.data ?? [];

            if (patients.isEmpty) {
              return _EmptyState(
                onAddPatient: () => _showAddPatientDialog(context),
              );
            }

            return Column(
              children: [
                for (var i = 0; i < patients.length; i++) ...[
                  _PatientCard(
                    patient: patients[i],
                    onTap: () => _openPatientDetail(context, patients[i]),
                  ),
                  if (i < patients.length - 1)
                    const SizedBox(height: AppSpacing.md),
                ],
                const SizedBox(height: AppSpacing.xxl),
                GlassButton(
                  onPressed: () => _showAddPatientDialog(context),
                  label: 'Weiteren Patienten hinzufügen',
                  icon: Icons.person_add_rounded,
                  variant: GlassButtonVariant.secondary,
                  expand: true,
                ),
              ],
            );
          },
        ),
        const SizedBox(height: 100), // bottom nav padding
      ],
    );
  }

  void _openPatientDetail(BuildContext context, LinkedFamilyPatient patient) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => FamilyPatientDetailScreen(patient: patient),
      ),
    );
  }

  void _showAddPatientDialog(BuildContext context) {
    final codeCtrl = TextEditingController();
    bool busy = false;

    showDialog<void>(
      context: context,
      builder: (dialogCtx) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            final l = AppLocalizations.of(context)!;
            return AlertDialog(
              title: Text(l.patientAdd),
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
                    decoration: InputDecoration(
                      labelText: l.einladungscode,
                      hintText: l.familyPatientsZBA1B2C3D4E5F6,
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
                  child: Text(l.cancel),
                ),
                FilledButton(
                  onPressed: busy
                      ? null
                      : () async {
                          final code = codeCtrl.text.trim().toUpperCase();
                          if (code.isEmpty) return;
                          setDialogState(() => busy = true);
                          try {
                            await appFunctions()
                                .httpsCallable('acceptInvite')
                                .call<Map<String, dynamic>>({'code': code});
                            if (dialogCtx.mounted) {
                              Navigator.of(dialogCtx).pop();
                            }
                            if (mounted) {
                              ScaffoldMessenger.of(this.context).showSnackBar(
                                SnackBar(
                                  content:
                                      Text(l.patientLinked),
                                ),
                              );
                            }
                          } catch (e) {
                            setDialogState(() => busy = false);
                            if (dialogCtx.mounted) {
                              ScaffoldMessenger.of(dialogCtx).showSnackBar(
                                SnackBar(
                                  content: Text(userFacingError(e)),
                                ),
                              );
                            }
                          }
                        },
                  child: busy
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : Text(l.connect),
                ),
              ],
            );
          },
        );
      },
    ).then((_) => codeCtrl.dispose());
  }
}

// ─────────────────────────────────────────────────────────────────────────────

class _PatientCard extends StatelessWidget {
  const _PatientCard({required this.patient, required this.onTap});

  final LinkedFamilyPatient patient;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;
    final since =
        '${patient.connectedSince.day.toString().padLeft(2, '0')}.'
        '${patient.connectedSince.month.toString().padLeft(2, '0')}.'
        '${patient.connectedSince.year}';

    return GestureDetector(
      onTap: onTap,
      child: GlassContainer(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Row(
          children: [
            // Avatar
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  colors: [
                    AppColors.primary,
                    AppColors.primary.withValues(alpha: 0.7),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              alignment: Alignment.center,
              child: Text(
                patient.avatarInitials,
                style: tt.titleMedium?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            const SizedBox(width: AppSpacing.lg),
            // Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    patient.patientName,
                    style: tt.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  if (patient.opType != null) ...[
                    const SizedBox(height: 2),
                    Text(
                      patient.opType!,
                      style: tt.bodySmall?.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                  const SizedBox(height: 4),
                  Text(
                    'Verbunden seit $since',
                    style: tt.labelSmall?.copyWith(
                      color: AppColors.textSecondary,
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
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────

class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.onAddPatient});

  final VoidCallback onAddPatient;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 60),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.link_off_rounded, size: 64, color: AppColors.grey400),
          const SizedBox(height: AppSpacing.lg),
          Text(
            'Noch kein Patient verknüpft',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            'Lass dich über einen Einladungscode\nmit einem Patienten verbinden.',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppColors.textSecondary,
                ),
          ),
          const SizedBox(height: AppSpacing.xxl),
          GlassButton(
            onPressed: onAddPatient,
            label: l.codeEnter,
            icon: Icons.vpn_key_rounded,
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────

class _ErrorCard extends StatelessWidget {
  const _ErrorCard({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return GlassContainer(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Row(
        children: [
          const Icon(Icons.error_outline, color: AppColors.error),
          const SizedBox(width: AppSpacing.md),
          Expanded(child: Text(message)),
        ],
      ),
    );
  }
}
