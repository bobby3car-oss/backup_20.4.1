import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../../../auth/auth_service.dart';
import '../../../ui/ui.dart';
import '../../pro/data/entitlement_service.dart';
import '../../pro/domain/entitlement.dart';
import '../../pro/domain/trigger_context.dart';
import '../../pro/presentation/smart_paywall.dart';
import '../../../main.dart';
import '../../../ui/theme/app_icons.dart';

/// Profile & settings tab for family member accounts.
class FamilyProfileTab extends StatefulWidget {
  const FamilyProfileTab({super.key});

  @override
  State<FamilyProfileTab> createState() => _FamilyProfileTabState();
}

class _FamilyProfileTabState extends State<FamilyProfileTab> {
  Map<String, dynamic>? _userData;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;
    final doc =
        await FirebaseFirestore.instance.collection('users').doc(uid).get();
    if (mounted) {
      setState(() {
        _userData = doc.data();
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Center(child: CircularProgressIndicator());
    }

    final user = FirebaseAuth.instance.currentUser;
    final name =
        _userData?['displayName'] as String? ?? user?.displayName ?? '';
    final email = user?.email ?? '';
    final proServices = ProServices.maybeOf(context);
    final entitlementService = proServices?.entitlementService;

    return GlassPage(
      title: 'Profil',
      titleIcon: AppIcons.profile,
      titleColor: AppColors.primary,
      showBackButton: false,
      horizontalPadding: AppSpacing.lg,
      children: [
        // Avatar header
        _AvatarHeader(
          name: name,
          email: email,
          entitlementService: entitlementService,
          onBadgeTap: () {
            if (entitlementService != null &&
                !entitlementService.entitlement.value.isPro) {
              SmartPaywall.trigger(
                context: context,
                triggerContext: TriggerContext.settingsProButton,
              );
            }
          },
        ),
        const SizedBox(height: AppSpacing.xxl),

        // Add patient section
        GlassContainer(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Patientenverknüpfung',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                    ),
              ),
              const SizedBox(height: AppSpacing.sm),
              Text(
                'Gib einen neuen Einladungscode ein, um einen '
                'weiteren Patienten hinzuzufügen.',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppColors.textSecondary,
                    ),
              ),
              const SizedBox(height: AppSpacing.md),
              GlassButton(
                onPressed: () => _showAddPatientDialog(context),
                label: 'Code eingeben',
                icon: Icons.vpn_key_rounded,
                variant: GlassButtonVariant.secondary,
                expand: true,
              ),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.xxl),

        // Notification settings
        GlassContainer(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Benachrichtigungen',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                    ),
              ),
              const SizedBox(height: AppSpacing.md),
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: const Icon(Icons.notifications_outlined),
                title: const Text('Benachrichtigungen verwalten'),
                trailing: const Icon(Icons.chevron_right_rounded, size: 20),
                onTap: () =>
                    Navigator.of(context).pushNamed('/notifications'),
              ),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.xxl),

        // Account section
        GlassContainer(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Konto',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                    ),
              ),
              const SizedBox(height: AppSpacing.md),
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: const Icon(Icons.settings_rounded),
                title: const Text('Einstellungen'),
                trailing: const Icon(Icons.chevron_right_rounded, size: 20),
                onTap: () => Navigator.of(context).pushNamed('/settings'),
              ),
              const Divider(height: 1),
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading:
                    Icon(Icons.logout_rounded, color: Colors.red.shade400),
                title: Text(
                  'Abmelden',
                  style: TextStyle(color: Colors.red.shade400),
                ),
                onTap: () async => AuthService().signOut(),
              ),
            ],
          ),
        ),

        const SizedBox(height: 100), // bottom nav padding
      ],
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
            return AlertDialog(
              title: const Text('Patient hinzufügen'),
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
                                .call<Map<String, dynamic>>({'code': code});
                            if (dialogCtx.mounted) {
                              Navigator.of(dialogCtx).pop();
                            }
                            if (mounted) {
                              ScaffoldMessenger.of(this.context).showSnackBar(
                                const SnackBar(
                                  content:
                                      Text('Patient erfolgreich verknüpft!'),
                                ),
                              );
                            }
                          } catch (e) {
                            setDialogState(() => busy = false);
                            if (dialogCtx.mounted) {
                              ScaffoldMessenger.of(dialogCtx).showSnackBar(
                                SnackBar(content: Text('Fehler: $e')),
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
                      : const Text('Verbinden'),
                ),
              ],
            );
          },
        );
      },
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────

class _AvatarHeader extends StatelessWidget {
  const _AvatarHeader({
    required this.name,
    required this.email,
    required this.entitlementService,
    required this.onBadgeTap,
  });

  final String name;
  final String email;
  final EntitlementService? entitlementService;
  final VoidCallback onBadgeTap;

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;
    final initials = name.isNotEmpty
        ? name
            .trim()
            .split(' ')
            .map((w) => w[0])
            .take(2)
            .join()
            .toUpperCase()
        : '?';

    return GlassContainer(
      child: Column(
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                colors: [
                  AppColors.accent,
                  AppColors.accent.withValues(alpha: 0.7),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            alignment: Alignment.center,
            child: Text(
              initials,
              style: tt.headlineSmall?.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            name.isNotEmpty ? name : 'Angehöriger',
            style: tt.titleLarge?.copyWith(
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 2),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
            decoration: BoxDecoration(
              color: AppColors.accent.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              'Angehöriger',
              style: tt.labelSmall?.copyWith(
                color: AppColors.accent,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          if (email.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(
              email,
              style: tt.bodyMedium?.copyWith(color: AppColors.textSecondary),
            ),
          ],
          const SizedBox(height: 10),
          if (entitlementService != null)
            ValueListenableBuilder<Entitlement>(
              valueListenable: entitlementService!.entitlement,
              builder: (context2, ent, child2) {
                final isPro = ent.isPro;
                return GestureDetector(
                  onTap: onBadgeTap,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 5,
                    ),
                    decoration: BoxDecoration(
                      color: isPro
                          ? AppColors.primary.withValues(alpha: 0.12)
                          : AppColors.textSecondary.withValues(alpha: 0.10),
                      borderRadius: AppRadius.borderRadiusLg,
                    ),
                    child: Text(
                      isPro ? '⭐ Pro' : 'Basis',
                      style: tt.labelMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                        color:
                            isPro ? AppColors.primary : AppColors.textSecondary,
                      ),
                    ),
                  ),
                );
              },
            ),
        ],
      ),
    );
  }
}
