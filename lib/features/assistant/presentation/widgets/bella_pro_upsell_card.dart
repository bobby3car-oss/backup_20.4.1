import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../auth/user_profile_service.dart';
import '../../../../ui/ui.dart';
import '../../../../l10n/app_localizations.dart';

/// Inline card shown in the Bella chat when the AI indicates a Pro feature
/// is needed.
///
/// Behaviour depends on the user's [role]:
/// - **patient** → golden upsell card, taps to patient paywall.
/// - **organisation** → golden upsell card, taps to org paywall.
/// - **doctor / staff** → blue info card explaining that their organisation
///   needs to purchase Pro. Not tappable — there is no paywall they can use.
class BellaProUpsellCard extends StatelessWidget {
  const BellaProUpsellCard({
    super.key,
    required this.onTap,
    this.role = AppUserRole.patient,
  });

  final VoidCallback onTap;
  final AppUserRole role;

  bool get _isStaffOrDoctor =>
      role == AppUserRole.doctor || role == AppUserRole.staff;

  @override
  Widget build(BuildContext context) {
    if (_isStaffOrDoctor) return _buildStaffInfoCard(context);
    return _buildUpsellCard(context);
  }

  // ── Golden upsell card (patient & organisation) ──────────────────

  Widget _buildUpsellCard(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final isOrg = role == AppUserRole.organisation;

    final title = isOrg ? 'Organisations-Pro freischalten' : l.proUnlock;
    final subtitle = isOrg
        ? 'Jetzt das Organisations-Abo aktivieren'
        : l.bellaProUpgrade;

    return Container(
      margin: const EdgeInsets.only(
        right: 52,
        top: AppSpacing.xs,
        bottom: AppSpacing.md,
      ),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFFFFF8E1), Color(0xFFFFF3E0)],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: const Color(0xFFFFB74D).withValues(alpha: 0.4),
          width: 0.5,
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFFF9800).withValues(alpha: 0.08),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () {
            HapticFeedback.lightImpact();
            onTap();
          },
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [Color(0xFFFF6B9D), Color(0xFFC44EBB)],
                    ),
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color:
                            const Color(0xFFFF6B9D).withValues(alpha: 0.30),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Center(
                    child: Text(
                      isOrg ? '🏢' : '⭐',
                      style: const TextStyle(fontSize: 20),
                    ),
                  ),
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textPrimary,
                          letterSpacing: -0.3,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        subtitle,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w400,
                          color: AppColors.textSecondary.withValues(alpha: 0.8),
                          letterSpacing: -0.1,
                        ),
                      ),
                    ],
                  ),
                ),
                const Icon(
                  Icons.arrow_forward_ios_rounded,
                  size: 14,
                  color: Color(0xFFC44EBB),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ── Blue info card (doctor & staff) ──────────────────────────────

  Widget _buildStaffInfoCard(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(
        right: 52,
        top: AppSpacing.xs,
        bottom: AppSpacing.md,
      ),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFFE8F0FE), Color(0xFFD6E4FD)],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: const Color(0xFF90B4F8).withValues(alpha: 0.4),
          width: 0.5,
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF4285F4).withValues(alpha: 0.06),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [Color(0xFF6CA4F7), Color(0xFF4285F4)],
                ),
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF4285F4).withValues(alpha: 0.25),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: const Center(
                child: Icon(
                  Icons.info_outline_rounded,
                  size: 22,
                  color: Colors.white,
                ),
              ),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    'Funktion benötigt Pro',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                      letterSpacing: -0.3,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'Bitte deine Organisation, das Pro-Abo '
                    'abzuschließen, um diese Funktion zu nutzen.',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w400,
                      color: AppColors.textSecondary.withValues(alpha: 0.8),
                      letterSpacing: -0.1,
                      height: 1.3,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
