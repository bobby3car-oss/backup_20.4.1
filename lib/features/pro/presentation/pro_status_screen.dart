import 'package:flutter/material.dart';

import '../../../main.dart';
import '../../../ui/ui.dart';
import '../data/billing_service.dart';
import '../data/entitlement_service.dart';
import '../domain/entitlement.dart';
import '../../../ui/theme/app_icons.dart';

/// Settings screen showing Pro status, manage subscription, restore, key redeem.
class ProStatusScreen extends StatefulWidget {
  const ProStatusScreen({super.key});

  @override
  State<ProStatusScreen> createState() => _ProStatusScreenState();
}

class _ProStatusScreenState extends State<ProStatusScreen> {
  late final EntitlementService _entitlement;
  late final BillingService _billing;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final pro = ProServices.of(context);
    _entitlement = pro.entitlementService;
    _billing = pro.billingService;
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<Entitlement>(
      valueListenable: _entitlement.entitlement,
      builder: (context, entitlement, _) {
        return GlassPage(
          title: 'Pro Status',
          titleIcon: AppIcons.pro,
          titleColor: AppColors.primary,
          horizontalPadding: AppSpacing.lg,
          children: [
            if (entitlement.isActive)
              _ProActiveCard(entitlement: entitlement)
            else
              _FreeTeaser(
                onUpgrade: () => Navigator.of(context).pushNamed(
                  '/paywall',
                  arguments: {'source': 'settings'},
                ),
              ),
            const SizedBox(height: 16),
            _ActionsCard(
              isPro: entitlement.isActive,
              billing: _billing,
              onRestore: () async {
                _billing.restorePurchases();
              },
              onManage: () {
                // Opens platform subscription management
                _billing.openSubscriptionManagement();
              },
            ),
          ],
        );
      },
    );
  }
}

// ══════════════════════════════════════════════════════════════════════
// Pro Active Card
// ══════════════════════════════════════════════════════════════════════

class _ProActiveCard extends StatelessWidget {
  const _ProActiveCard({required this.entitlement});

  final Entitlement entitlement;

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;

    String? validUntil;
    if (entitlement.proExpiresAt != null) {
      final d = entitlement.proExpiresAt!;
      validUntil =
          '${d.day.toString().padLeft(2, '0')}.${d.month.toString().padLeft(2, '0')}.${d.year}';
    }

    String sourceLabel;
    if (entitlement.proProductId != null) {
      sourceLabel = entitlement.proProductId!.contains('yearly')
          ? 'Jahresabo'
          : 'Monatsabo';
    } else {
      sourceLabel = 'Pro Mitgliedschaft';
    }

    return GlassContainer(
      child: Column(
        children: [
          GlassIcon(icon: AppIcons.done, color: AppIcons.doneColor, size: 30),
          const SizedBox(height: 12),
          Text(
            'Pro aktiv',
            style: tt.headlineSmall?.copyWith(
              fontWeight: FontWeight.w800,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            sourceLabel,
            style: tt.bodyMedium?.copyWith(color: AppColors.textSecondary),
          ),
          if (validUntil != null) ...[
            const SizedBox(height: 4),
            Text(
              'Gültig bis $validUntil',
              style: tt.bodyMedium?.copyWith(color: AppColors.textSecondary),
            ),
          ],
        ],
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════════════
// Free Teaser Card
// ══════════════════════════════════════════════════════════════════════

class _FreeTeaser extends StatelessWidget {
  const _FreeTeaser({required this.onUpgrade});

  final VoidCallback onUpgrade;

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;

    return GlassContainer(
      child: Column(
        children: [
          GlassIcon(icon: AppIcons.pro, color: AppIcons.proColor, size: 30),
          const SizedBox(height: 12),
          Text(
            'Pro freischalten',
            style: tt.headlineSmall?.copyWith(
              fontWeight: FontWeight.w800,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Angehörige einladen und alle\nPro Funktionen nutzen.',
            style: tt.bodyMedium?.copyWith(
              color: AppColors.textSecondary,
              height: 1.45,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: FilledButton(
              onPressed: onUpgrade,
              child: const Text('Pro freischalten'),
            ),
          ),
        ],
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════════════
// Actions Card
// ══════════════════════════════════════════════════════════════════════

class _ActionsCard extends StatelessWidget {
  const _ActionsCard({
    required this.isPro,
    required this.billing,
    required this.onRestore,
    required this.onManage,
  });

  final bool isPro;
  final BillingService billing;
  final VoidCallback onRestore;
  final VoidCallback onManage;

  @override
  Widget build(BuildContext context) {
    return GlassContainer(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Aktionen',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
          ),
          const SizedBox(height: 8),
          if (isPro)
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const Icon(Icons.settings_rounded),
              title: const Text('Abo verwalten'),
              trailing: const Icon(Icons.chevron_right_rounded, size: 20),
              onTap: onManage,
            ),
          ListTile(
            contentPadding: EdgeInsets.zero,
            leading: const Icon(Icons.refresh_rounded),
            title: const Text('Kauf wiederherstellen'),
            trailing: ValueListenableBuilder<bool>(
              valueListenable: billing.restoring,
              builder: (_, restoring, _) => restoring
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.chevron_right_rounded, size: 20),
            ),
            onTap: onRestore,
          ),
        ],
      ),
    );
  }
}
