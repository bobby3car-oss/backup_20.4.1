import 'dart:async';
import 'dart:io';

import 'package:cloud_functions/cloud_functions.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:in_app_purchase/in_app_purchase.dart';

import '../data/billing_service.dart';
import '../data/org_entitlement_service.dart';
import '../domain/pro_product.dart';

// ── Light B2B palette ────────────────────────────────────────────────

abstract final class _C {
  static const bg = Color(0xFFF0F2F9);
  static const card = Color(0xFFFFFFFF);
  static const cardSelected = Color(0xFFEDF4FF);
  static const border = Color(0xFFE5E5EA);
  static const borderSelected = Color(0xFF007AFF);
  static const textPrimary = Color(0xFF1C1C1E);
  static const textSecondary = Color(0xFF8E8E93);
  static const accent = Color(0xFF007AFF);
  static const accentGlow = Color(0x55007AFF);
  static const badge = Color(0xFF007AFF);
  static const success = Color(0xFF34C759);
}

/// B2B paywall screen for Organisation / Doctor Pro subscriptions.
///
/// Professional and factual layout – no emotional copy. Single scrollable page
/// with header, feature comparison table, plan cards, CTA, and legal footer.
class OrgPaywallScreen extends StatefulWidget {
  const OrgPaywallScreen({
    super.key,
    required this.billingService,
    required this.orgEntitlementService,
    this.isOrganisation = true,
  });

  final BillingService billingService;
  final OrgEntitlementService orgEntitlementService;

  /// `true` for organisation accounts, `false` for solo doctors.
  final bool isOrganisation;

  @override
  State<OrgPaywallScreen> createState() => _OrgPaywallScreenState();
}

class _OrgPaywallScreenState extends State<OrgPaywallScreen>
    with TickerProviderStateMixin {
  BillingService get _billing => widget.billingService;
  OrgEntitlementService get _orgEntitlement => widget.orgEntitlementService;

  late String _selectedId;

  // ── Product loading ──────────────────────────────────────────────
  List<ProductDetails> _orgProducts = const [];
  bool _productsLoading = true;
  bool _purchasing = false;
  String? _errorMessage;

  StreamSubscription<List<PurchaseDetails>>? _purchaseSub;

  // ── Entrance animation ──────────────────────────────────────────
  late final AnimationController _entranceCtrl;

  // ── Success overlay ─────────────────────────────────────────────
  bool _showSuccess = false;
  late final AnimationController _successCtrl;
  late final Animation<double> _successScale;
  late final AnimationController _successContentCtrl;

  @override
  void initState() {
    super.initState();
    _selectedId = ProProduct.orgYearlyId; // yearly pre-selected

    _entranceCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _successCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _successScale = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 0.0, end: 1.2), weight: 50),
      TweenSequenceItem(tween: Tween(begin: 1.2, end: 0.9), weight: 20),
      TweenSequenceItem(tween: Tween(begin: 0.9, end: 1.0), weight: 30),
    ]).animate(CurvedAnimation(parent: _successCtrl, curve: Curves.easeOut));
    _successContentCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 450),
    );

    Future.delayed(const Duration(milliseconds: 150), () {
      if (mounted) _entranceCtrl.forward();
    });

    _orgEntitlement.entitlement.addListener(_onEntitlementChanged);
    _loadOrgProducts();
    _listenToPurchases();
  }

  @override
  void dispose() {
    _orgEntitlement.entitlement.removeListener(_onEntitlementChanged);
    _entranceCtrl.dispose();
    _successCtrl.dispose();
    _successContentCtrl.dispose();
    _purchaseSub?.cancel();
    super.dispose();
  }

  // ── Product loading ─────────────────────────────────────────────

  Future<void> _loadOrgProducts() async {
    if (kIsWeb || !(Platform.isIOS || Platform.isAndroid)) {
      setState(() => _productsLoading = false);
      return;
    }

    final iap = InAppPurchase.instance;
    final available = await iap.isAvailable();
    if (!available) {
      setState(() {
        _productsLoading = false;
        _errorMessage = 'Store nicht verfügbar.';
      });
      return;
    }

    try {
      final response =
          await iap.queryProductDetails(ProProduct.orgAllIds);
      final sorted = response.productDetails.toList()
        ..sort((a, b) => a.rawPrice.compareTo(b.rawPrice));
      setState(() {
        _orgProducts = sorted;
        _productsLoading = false;
      });
    } catch (e) {
      setState(() {
        _productsLoading = false;
        _errorMessage = 'Produkte konnten nicht geladen werden.';
      });
    }
  }

  // ── Purchase stream ─────────────────────────────────────────────

  void _listenToPurchases() {
    if (kIsWeb || !(Platform.isIOS || Platform.isAndroid)) return;
    _purchaseSub =
        InAppPurchase.instance.purchaseStream.listen(_onPurchaseUpdate);
  }

  Future<void> _onPurchaseUpdate(List<PurchaseDetails> purchases) async {
    for (final purchase in purchases) {
      // Only handle org product purchases.
      if (!ProProduct.orgAllIds.contains(purchase.productID)) continue;

      switch (purchase.status) {
        case PurchaseStatus.pending:
          setState(() => _purchasing = true);
          break;
        case PurchaseStatus.purchased:
        case PurchaseStatus.restored:
          await _verifyOrgPurchase(purchase);
          break;
        case PurchaseStatus.error:
          setState(() {
            _purchasing = false;
            _errorMessage = 'Kauf fehlgeschlagen. Bitte versuche es erneut.';
          });
          if (purchase.pendingCompletePurchase) {
            await InAppPurchase.instance.completePurchase(purchase);
          }
          break;
        case PurchaseStatus.canceled:
          setState(() => _purchasing = false);
          if (purchase.pendingCompletePurchase) {
            await InAppPurchase.instance.completePurchase(purchase);
          }
          break;
      }
    }
  }

  Future<void> _verifyOrgPurchase(PurchaseDetails purchase) async {
    try {
      final platform = Platform.isIOS ? 'ios' : 'android';
      final functions =
          FirebaseFunctions.instanceFor(region: 'europe-west1');
      await functions.httpsCallable('verifyOrgPurchase').call<dynamic>({
        'productId': purchase.productID,
        'purchaseToken': purchase.verificationData.serverVerificationData,
        'transactionId': purchase.purchaseID ?? '',
        'platform': platform,
      });

      // Refresh entitlement.
      await _orgEntitlement.refresh();
      if (mounted) _playSuccessOverlay();
    } catch (e) {
      setState(() {
        _purchasing = false;
        _errorMessage = 'Verifizierung fehlgeschlagen: $e';
      });
    } finally {
      if (purchase.pendingCompletePurchase) {
        await InAppPurchase.instance.completePurchase(purchase);
      }
      setState(() => _purchasing = false);
    }
  }

  void _onEntitlementChanged() {
    if (!mounted || _showSuccess || !_orgEntitlement.isPro) return;
    _playSuccessOverlay();
  }

  // ── Buy ─────────────────────────────────────────────────────────

  void _buySelected() async {
    if (_purchasing || _productsLoading) return;

    if (kIsWeb) {
      // Paddle checkout for org products.
      final priceId = ProProduct.orgPaddlePriceId(_selectedId);
      if (priceId == null || priceId.isEmpty) {
        setState(
            () => _errorMessage = 'Paddle-Preis nicht konfiguriert.');
        return;
      }
      // Use billing service's web checkout infrastructure.
      await _billing.buyWeb(_selectedId);
      return;
    }

    final product = _selectedProduct;
    if (product == null) {
      // Retry loading.
      HapticFeedback.selectionClick();
      await _loadOrgProducts();
      if (_selectedProduct == null) {
        setState(() =>
            _errorMessage = 'Produkte nicht verfügbar. Bitte versuche es erneut.');
        return;
      }
    }
    final p = _selectedProduct;
    if (p == null) return;

    HapticFeedback.mediumImpact();
    setState(() {
      _purchasing = true;
      _errorMessage = null;
    });

    try {
      final purchaseParam = PurchaseParam(productDetails: p);
      final started = await InAppPurchase.instance
          .buyNonConsumable(purchaseParam: purchaseParam);
      if (!started) {
        setState(() {
          _purchasing = false;
          _errorMessage = 'Kauf konnte nicht gestartet werden.';
        });
      }
    } catch (e) {
      setState(() {
        _purchasing = false;
        _errorMessage = 'Kauf fehlgeschlagen. Bitte versuche es erneut.';
      });
    }
  }

  // ── Success overlay ─────────────────────────────────────────────

  Future<void> _playSuccessOverlay() async {
    HapticFeedback.heavyImpact();
    setState(() => _showSuccess = true);
    await Future<void>.delayed(const Duration(milliseconds: 100));
    if (!mounted) return;
    _successCtrl.forward();
    await Future<void>.delayed(const Duration(milliseconds: 400));
    if (!mounted) return;
    HapticFeedback.mediumImpact();
    _successContentCtrl.forward();
    await Future<void>.delayed(const Duration(milliseconds: 2200));
    if (!mounted) return;
    Navigator.of(context).pop(true);
  }

  // ── Helpers ─────────────────────────────────────────────────────

  ProductDetails? get _selectedProduct {
    for (final p in _orgProducts) {
      if (p.id == _selectedId) return p;
    }
    return _orgProducts.isNotEmpty ? _orgProducts.first : null;
  }

  ProductDetails? get _monthly => _orgProducts
      .cast<ProductDetails?>()
      .firstWhere((p) => p!.id == ProProduct.orgMonthlyId,
          orElse: () => null);

  ProductDetails? get _yearly => _orgProducts
      .cast<ProductDetails?>()
      .firstWhere((p) => p!.id == ProProduct.orgYearlyId,
          orElse: () => null);

  String _ctaLabel() {
    if (_productsLoading) return 'Lade Abos\u2026';
    final product = _selectedProduct;
    if (product != null) {
      final period =
          product.id == ProProduct.orgYearlyId ? 'Jahr' : 'Monat';
      return 'Jetzt Pro aktivieren · ${product.price}/$period';
    }
    final fallback = _selectedId == ProProduct.orgYearlyId
        ? ProProduct.orgYearlyPriceDisplay
        : ProProduct.orgMonthlyPriceDisplay;
    final period =
        _selectedId == ProProduct.orgYearlyId ? 'Jahr' : 'Monat';
    return 'Jetzt Pro aktivieren · $fallback/$period';
  }

  String _yearlyBadge() {
    final m = _monthly;
    final y = _yearly;
    if (m != null && y != null) {
      final monthlyTotal = m.rawPrice * 12;
      if (monthlyTotal > 0) {
        final savings = ((1 - y.rawPrice / monthlyTotal) * 100).round();
        if (savings > 0) return '$savings% SPAREN';
      }
    }
    return '${ProProduct.orgSavingsPercent}% SPAREN';
  }

  String _planPrice(ProductDetails? product, String period,
      String fallback) {
    if (product != null) return '${product.price}/$period';
    return '$fallback/$period';
  }

  String _planSubtitle(ProductDetails? product, String fallback) {
    return product != null ? fallback : fallback;
  }

  void _selectPlan(String id) {
    setState(() => _selectedId = id);
    HapticFeedback.lightImpact();
  }

  // ── Build ───────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final isOrg = widget.isOrganisation;
    final ctaLoading = _purchasing || _productsLoading;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.dark,
      child: Scaffold(
        backgroundColor: _C.bg,
        body: Stack(
          children: [
            // Subtle ambient glow.
            _AmbientBg(),
            SafeArea(
              child: Column(
                children: [
                  // ── Top bar ───────────────────────────────
                  Padding(
                    padding: const EdgeInsets.only(
                        top: 8, left: 8, right: 8),
                    child: Row(
                      children: [
                        const SizedBox(width: 48),
                        const Spacer(),
                        IconButton(
                          icon: const Icon(Icons.close_rounded,
                              color: _C.textSecondary, size: 28),
                          onPressed: () =>
                              Navigator.of(context).pop(),
                        ),
                      ],
                    ),
                  ),
                  // ── Scrollable content ─────────────────────
                  Expanded(
                    child: SingleChildScrollView(
                      physics: const BouncingScrollPhysics(),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 24),
                      child: Column(
                        children: [
                          const SizedBox(height: 12),

                          // 1 ── Header ──────────────────
                          _StaggerEntry(
                            animation: _entranceCtrl,
                            delay: 0.0,
                            child: _Header(isOrg: isOrg),
                          ),
                          const SizedBox(height: 28),

                          // 2 ── Feature table ───────────
                          _StaggerEntry(
                            animation: _entranceCtrl,
                            delay: 0.12,
                            child: const _OrgFreeVsProTable(),
                          ),
                          const SizedBox(height: 32),

                          // 3 ── Plan cards ──────────────
                          _StaggerEntry(
                            animation: _entranceCtrl,
                            delay: 0.24,
                            child: Column(
                              children: [
                                Text(
                                  'Wählen Sie Ihren Plan',
                                  style: Theme.of(context)
                                      .textTheme
                                      .titleMedium
                                      ?.copyWith(
                                        color: _C.textPrimary,
                                        fontWeight: FontWeight.w700,
                                      ),
                                ),
                                const SizedBox(height: 16),
                                _OrgPlanCard(
                                  title: 'Jährlich',
                                  subtitle: _planSubtitle(
                                      _yearly,
                                      'Jederzeit kündbar'),
                                  price: _planPrice(
                                    _yearly,
                                    'Jahr',
                                    ProProduct
                                        .orgYearlyPriceDisplay,
                                  ),
                                  badge: _yearlyBadge(),
                                  selected: _selectedId ==
                                      ProProduct.orgYearlyId,
                                  emphasized: true,
                                  onTap: () => _selectPlan(
                                      ProProduct.orgYearlyId),
                                ),
                                const SizedBox(height: 12),
                                _OrgPlanCard(
                                  title: 'Monatlich',
                                  subtitle: _planSubtitle(
                                      _monthly,
                                      'Flexibel, monatlich kündbar'),
                                  price: _planPrice(
                                    _monthly,
                                    'Monat',
                                    ProProduct
                                        .orgMonthlyPriceDisplay,
                                  ),
                                  selected: _selectedId ==
                                      ProProduct.orgMonthlyId,
                                  onTap: () => _selectPlan(
                                      ProProduct.orgMonthlyId),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 24),

                          // 4 ── CTA ─────────────────────
                          _StaggerEntry(
                            animation: _entranceCtrl,
                            delay: 0.36,
                            child: _GlowCTA(
                              label: _ctaLabel(),
                              loading: ctaLoading,
                              onPressed:
                                  ctaLoading ? null : _buySelected,
                            ),
                          ),
                          if (_errorMessage != null) ...[
                            const SizedBox(height: 12),
                            Text(
                              _errorMessage!,
                              style: Theme.of(context)
                                  .textTheme
                                  .bodySmall
                                  ?.copyWith(
                                    color: const Color(0xFFFF3B30),
                                    height: 1.35,
                                  ),
                              textAlign: TextAlign.center,
                            ),
                          ],
                          const SizedBox(height: 24),

                          // 5 ── Footer ──────────────────
                          _StaggerEntry(
                            animation: _entranceCtrl,
                            delay: 0.42,
                            child: _Footer(
                              onRedeemKey: () {
                                Navigator.of(context)
                                    .pushNamed('/redeem-key');
                              },
                            ),
                          ),
                          const SizedBox(height: 32),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            if (_showSuccess) _buildSuccessOverlay(),
          ],
        ),
      ),
    );
  }

  Widget _buildSuccessOverlay() {
    final curved = CurvedAnimation(
      parent: _successContentCtrl,
      curve: Curves.easeOutCubic,
    );
    return Positioned.fill(
      child: Container(
        color: _C.bg.withValues(alpha: 0.94),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ScaleTransition(
                scale: _successScale,
                child: Container(
                  width: 96,
                  height: 96,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: _C.success,
                  ),
                  child: const Icon(Icons.check_rounded,
                      color: Colors.white, size: 52),
                ),
              ),
              const SizedBox(height: 28),
              FadeTransition(
                opacity: curved,
                child: SlideTransition(
                  position: Tween<Offset>(
                    begin: const Offset(0, 0.15),
                    end: Offset.zero,
                  ).animate(curved),
                  child: Text(
                    'Pro aktiviert',
                    style: Theme.of(context)
                        .textTheme
                        .headlineSmall
                        ?.copyWith(
                          color: _C.textPrimary,
                          fontWeight: FontWeight.w800,
                        ),
                  ),
                ),
              ),
              const SizedBox(height: 8),
              FadeTransition(
                opacity: curved,
                child: Text(
                  widget.isOrganisation
                      ? 'Alle Ärzte Ihrer Organisation haben jetzt Pro.'
                      : 'Ihr Account hat jetzt Pro.',
                  style: Theme.of(context)
                      .textTheme
                      .bodyMedium
                      ?.copyWith(color: _C.textSecondary),
                  textAlign: TextAlign.center,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════════════
// ── Ambient background ──────────────────────────────────────────────
// ══════════════════════════════════════════════════════════════════════

class _AmbientBg extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Positioned.fill(
      child: IgnorePointer(
        child: Stack(
          children: [
            Positioned(
              top: -100,
              left: -60,
              width: 320,
              height: 320,
              child: Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(colors: [
                    _C.accent.withValues(alpha: 0.06),
                    Colors.transparent,
                  ]),
                ),
              ),
            ),
            Positioned(
              bottom: -80,
              right: -80,
              width: 280,
              height: 280,
              child: Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(colors: [
                    _C.accent.withValues(alpha: 0.04),
                    Colors.transparent,
                  ]),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════════════
// ── Stagger animation wrapper ───────────────────────────────────────
// ══════════════════════════════════════════════════════════════════════

class _StaggerEntry extends StatelessWidget {
  const _StaggerEntry({
    required this.animation,
    required this.child,
    this.delay = 0.0,
  });

  final Animation<double> animation;
  final Widget child;
  final double delay;

  @override
  Widget build(BuildContext context) {
    final curved = CurvedAnimation(
      parent: animation,
      curve: Interval(delay, (delay + 0.5).clamp(0, 1),
          curve: Curves.easeOutCubic),
    );
    return FadeTransition(
      opacity: curved,
      child: SlideTransition(
        position: Tween<Offset>(
          begin: const Offset(0, 20 / 500),
          end: Offset.zero,
        ).animate(curved),
        child: child,
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════════════
// ── 1. Header ───────────────────────────────────────────────────────
// ══════════════════════════════════════════════════════════════════════

class _Header extends StatelessWidget {
  const _Header({required this.isOrg});

  final bool isOrg;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Pro badge icon.
        Container(
          width: 56,
          height: 56,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                _C.accent,
                _C.accent.withValues(alpha: 0.7),
              ],
            ),
          ),
          child: const Icon(Icons.verified_rounded,
              color: Colors.white, size: 30),
        ),
        const SizedBox(height: 20),
        Text(
          isOrg
              ? 'Pro für Ihre Praxis'
              : 'Pro für Ihren Arztaccount',
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                color: _C.textPrimary,
                fontWeight: FontWeight.w800,
                height: 1.15,
                letterSpacing: -0.5,
              ),
        ),
        const SizedBox(height: 10),
        Text(
          isOrg
              ? 'Alle Ärzte Ihrer Organisation erhalten sofort Zugang'
              : 'Voller Funktionsumfang für Ihren Account',
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: _C.textSecondary,
                height: 1.4,
              ),
        ),
      ],
    );
  }
}

// ══════════════════════════════════════════════════════════════════════
// ── 2. Free vs Pro comparison table ─────────────────────────────────
// ══════════════════════════════════════════════════════════════════════

class _OrgFreeVsProTable extends StatelessWidget {
  const _OrgFreeVsProTable();

  static const _rows = <(String, String, String)>[
    ('Patienten', 'max.\u00a0100', 'Unbegrenzt ✅'),
    ('Eigene Vorlagen', 'max.\u00a03', 'Unbegrenzt ✅'),
    ('Mitarbeiter', 'max.\u00a03', 'Unbegrenzt ✅'),
    ('PDF-Berichte', '❌', '✅'),
    ('System\u00ADvorlagen', '❌', '✅'),
  ];

  @override
  Widget build(BuildContext context) {
    final ts = Theme.of(context).textTheme;
    return Container(
      decoration: BoxDecoration(
        color: _C.card,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: _C.border, width: 0.5),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: [
          // Header row.
          Container(
            padding: const EdgeInsets.symmetric(
                horizontal: 16, vertical: 12),
            color: _C.accent.withValues(alpha: 0.10),
            child: Row(
              children: [
                Expanded(
                  flex: 3,
                  child: Text('Feature',
                      style: ts.labelMedium?.copyWith(
                        color: _C.textSecondary,
                        fontWeight: FontWeight.w600,
                      )),
                ),
                Expanded(
                  flex: 2,
                  child: Text('Free',
                      textAlign: TextAlign.center,
                      style: ts.labelMedium?.copyWith(
                        color: _C.textSecondary,
                        fontWeight: FontWeight.w600,
                      )),
                ),
                Expanded(
                  flex: 2,
                  child: Text('Pro',
                      textAlign: TextAlign.center,
                      style: ts.labelMedium?.copyWith(
                        color: _C.accent,
                        fontWeight: FontWeight.w800,
                      )),
                ),
              ],
            ),
          ),
          // Data rows.
          for (int i = 0; i < _rows.length; i++)
            Container(
              padding: const EdgeInsets.symmetric(
                  horizontal: 16, vertical: 13),
              decoration: BoxDecoration(
                color: i.isOdd
                    ? _C.accent.withValues(alpha: 0.03)
                    : Colors.transparent,
                border: Border(
                  top: BorderSide(
                    color: _C.border.withValues(alpha: 0.3),
                    width: 0.5,
                  ),
                ),
              ),
              child: Row(
                children: [
                  Expanded(
                    flex: 3,
                    child: Text(
                      _rows[i].$1,
                      style: ts.bodySmall?.copyWith(
                        color: _C.textPrimary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  Expanded(
                    flex: 2,
                    child: Text(
                      _rows[i].$2,
                      textAlign: TextAlign.center,
                      style: ts.bodySmall?.copyWith(
                        color: _rows[i].$2 == '❌'
                            ? _C.textSecondary.withValues(alpha: 0.5)
                            : _rows[i].$2 == '✅'
                                ? _C.success
                                : _C.textSecondary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  Expanded(
                    flex: 2,
                    child: Text(
                      _rows[i].$3,
                      textAlign: TextAlign.center,
                      style: ts.bodySmall?.copyWith(
                        color: _C.success,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════════════
// ── 3. Plan card ────────────────────────────────────────────────────
// ══════════════════════════════════════════════════════════════════════

class _OrgPlanCard extends StatefulWidget {
  const _OrgPlanCard({
    required this.title,
    required this.subtitle,
    required this.price,
    required this.selected,
    required this.onTap,
    this.badge,
    this.emphasized = false,
  });

  final String title;
  final String subtitle;
  final String price;
  final bool selected;
  final bool emphasized;
  final String? badge;
  final VoidCallback onTap;

  @override
  State<_OrgPlanCard> createState() => _OrgPlanCardState();
}

class _OrgPlanCardState extends State<_OrgPlanCard>
    with SingleTickerProviderStateMixin {
  late final AnimationController _bounceCtrl;
  late final Animation<double> _bounceAnim;

  @override
  void initState() {
    super.initState();
    _bounceCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    _bounceAnim = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 1.0, end: 1.04), weight: 30),
      TweenSequenceItem(
          tween: Tween(begin: 1.04, end: 0.97), weight: 30),
      TweenSequenceItem(tween: Tween(begin: 0.97, end: 1.0), weight: 40),
    ]).animate(CurvedAnimation(
        parent: _bounceCtrl, curve: Curves.easeOutCubic));
  }

  @override
  void didUpdateWidget(_OrgPlanCard old) {
    super.didUpdateWidget(old);
    if (widget.selected && !old.selected) _bounceCtrl.forward(from: 0);
  }

  @override
  void dispose() {
    _bounceCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final sel = widget.selected;
    return ScaleTransition(
      scale: _bounceAnim,
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeOut,
          padding: EdgeInsets.all(widget.emphasized ? 22 : 18),
          decoration: BoxDecoration(
            color: sel ? _C.cardSelected : _C.card,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: sel ? _C.borderSelected : _C.border,
              width: sel ? 1.5 : 0.5,
            ),
            boxShadow: sel
                ? [
                    BoxShadow(
                      color: _C.accentGlow,
                      blurRadius: 24,
                      spreadRadius: -4,
                    ),
                  ]
                : null,
          ),
          child: Row(
            children: [
              _RadioDot(selected: sel),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          widget.title,
                          style: Theme.of(context)
                              .textTheme
                              .titleSmall
                              ?.copyWith(
                                color: _C.textPrimary,
                                fontWeight: FontWeight.w700,
                              ),
                        ),
                        if (widget.badge != null) ...[
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(
                              color: _C.badge,
                              borderRadius:
                                  BorderRadius.circular(6),
                            ),
                            child: Text(
                              widget.badge!,
                              style: const TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w800,
                                color: Colors.white,
                                letterSpacing: 0.5,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      widget.subtitle,
                      style: Theme.of(context)
                          .textTheme
                          .bodySmall
                          ?.copyWith(color: _C.textSecondary),
                    ),
                  ],
                ),
              ),
              Text(
                widget.price,
                style: Theme.of(context)
                    .textTheme
                    .titleMedium
                    ?.copyWith(
                      color: _C.textPrimary,
                      fontWeight: FontWeight.w800,
                    ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Radio dot ────────────────────────────────────────────────────────

class _RadioDot extends StatelessWidget {
  const _RadioDot({required this.selected});

  final bool selected;

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 250),
      width: 22,
      height: 22,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(
          color: selected ? _C.accent : _C.textSecondary,
          width: selected ? 6 : 2,
        ),
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════════════
// ── 4. Glow CTA button ──────────────────────────────────────────────
// ══════════════════════════════════════════════════════════════════════

class _GlowCTA extends StatefulWidget {
  const _GlowCTA({
    required this.label,
    required this.loading,
    this.onPressed,
  });

  final String label;
  final bool loading;
  final VoidCallback? onPressed;

  @override
  State<_GlowCTA> createState() => _GlowCTAState();
}

class _GlowCTAState extends State<_GlowCTA>
    with SingleTickerProviderStateMixin {
  late final AnimationController _pulseCtrl;

  @override
  void initState() {
    super.initState();
    _pulseCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _pulseCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: _pulseCtrl,
      builder: (context, child) {
        final glow = 0.4 + _pulseCtrl.value * 0.6;
        return Container(
          width: double.infinity,
          height: 56,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: _C.accent.withValues(alpha: glow * 0.35),
                blurRadius: 24,
                spreadRadius: -2,
              ),
            ],
          ),
          child: child,
        );
      },
      child: ElevatedButton(
        onPressed: widget.onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: _C.accent,
          foregroundColor: Colors.white,
          elevation: 0,
          minimumSize: const Size.fromHeight(56),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          textStyle: const TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.w700,
            letterSpacing: -0.2,
          ),
        ),
        child: widget.loading
            ? const SizedBox(
                width: 22,
                height: 22,
                child: CircularProgressIndicator(
                  strokeWidth: 2.5,
                  color: Colors.white,
                ),
              )
            : Text(widget.label),
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════════════
// ── 5. Footer ───────────────────────────────────────────────────────
// ══════════════════════════════════════════════════════════════════════

class _Footer extends StatelessWidget {
  const _Footer({this.onRedeemKey});

  final VoidCallback? onRedeemKey;

  @override
  Widget build(BuildContext context) {
    const linkStyle = TextStyle(
      fontSize: 13,
      color: _C.textSecondary,
      decoration: TextDecoration.underline,
      decorationColor: _C.textSecondary,
    );

    return Column(
      children: [
        // Redeem key.
        TextButton(
          onPressed: onRedeemKey,
          child: const Text('Key einlösen', style: linkStyle),
        ),
        const SizedBox(height: 8),
        // Legal links.
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            GestureDetector(
              onTap: () =>
                  Navigator.of(context).pushNamed('/privacy'),
              child: const Text('Datenschutz', style: linkStyle),
            ),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 12),
              child: Text('·',
                  style: TextStyle(color: _C.textSecondary)),
            ),
            GestureDetector(
              onTap: () =>
                  Navigator.of(context).pushNamed('/terms'),
              child: const Text('Nutzungsbedingungen',
                  style: linkStyle),
            ),
          ],
        ),
        const SizedBox(height: 12),
        // Legal disclaimer.
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Text(
            'Der Betrag wird bei Kaufbestätigung über Ihr Apple-ID- bzw. '
            'Google-Play-Konto abgebucht. Das Abonnement verlängert sich '
            'automatisch, sofern es nicht mindestens 24\u00a0Stunden vor '
            'Ablauf der aktuellen Laufzeit gekündigt wird. Sie können das '
            'Abonnement jederzeit in Ihren Geräteeinstellungen verwalten '
            'und kündigen.',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: _C.textSecondary.withValues(alpha: 0.5),
                  fontSize: 11,
                ),
            textAlign: TextAlign.center,
          ),
        ),
      ],
    );
  }
}



