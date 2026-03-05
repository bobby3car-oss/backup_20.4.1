import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:in_app_purchase/in_app_purchase.dart';

import '../../../ui/theme/colors.dart';
import '../data/billing_service.dart';
import '../data/entitlement_service.dart';
import '../data/paywall_config.dart';
import '../data/pro_analytics.dart';
import '../domain/pro_product.dart';
import 'pro_success_screen.dart';

// dark-mode palette (local to paywall)

abstract final class _C {
  static const bg = Color(0xFF0A0A0F);
  static const card = Color(0x1AFFFFFF);
  static const cardSelected = Color(0x26FFFFFF);
  static const border = Color(0x20FFFFFF);
  static const borderSelected = Color(0x55FFFFFF);
  static const textPrimary = Color(0xFFF5F5F7);
  static const textSecondary = Color(0x99EBEBF5);
  static const accent = Color(0xFF0A84FF);
  static const accentGlow = Color(0x550A84FF);
  static const badge = Color(0xFFFFD60A);
  static const success = Color(0xFF30D158);
}

/// Full-screen premium paywall with dark glassmorphism design.
class PaywallScreen extends StatefulWidget {
  const PaywallScreen({
    super.key,
    required this.billingService,
    required this.entitlementService,
    required this.proAnalytics,
    required this.paywallConfig,
    this.source = 'unknown',
  });

  final BillingService billingService;
  final EntitlementService entitlementService;
  final ProAnalytics proAnalytics;
  final PaywallConfig paywallConfig;
  final String source;

  @override
  State<PaywallScreen> createState() => _PaywallScreenState();
}

class _PaywallScreenState extends State<PaywallScreen>
    with TickerProviderStateMixin {
  BillingService get _billing => widget.billingService;
  EntitlementService get _entitlement => widget.entitlementService;
  ProAnalytics get _analytics => widget.proAnalytics;
  PaywallConfig get _config => widget.paywallConfig;

  late String _selectedId;

  late final AnimationController _heroCtrl;
  late final AnimationController _featuresCtrl;
  late final AnimationController _cardsCtrl;
  late final AnimationController _ctaCtrl;

  @override
  void initState() {
    super.initState();

    // ── Remote Config: default plan ──
    _selectedId = _config.defaultPlan == 'monthly'
        ? ProProduct.monthlyId
        : ProProduct.yearlyId;

    _heroCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );
    _featuresCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _cardsCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _ctaCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );

    _playStagger();

    _billing.products.addListener(_rebuild);
    _billing.purchasing.addListener(_rebuild);
    _billing.restoring.addListener(_rebuild);
    _billing.error.addListener(_showError);
    _billing.onRestoreComplete = _onRestoreComplete;
    _entitlement.entitlement.addListener(_onEntitlementChanged);

    // ── Analytics: paywall_opened
    _analytics.paywallOpened(
      source: widget.source,
      variant: _config.variant.name.toUpperCase(),
    );
  }

  Future<void> _playStagger() async {
    await Future<void>.delayed(const Duration(milliseconds: 100));
    if (!mounted) return;
    _heroCtrl.forward();
    await Future<void>.delayed(const Duration(milliseconds: 200));
    if (!mounted) return;
    _featuresCtrl.forward();
    await Future<void>.delayed(const Duration(milliseconds: 150));
    if (!mounted) return;
    _cardsCtrl.forward();
    await Future<void>.delayed(const Duration(milliseconds: 150));
    if (!mounted) return;
    _ctaCtrl.forward();
  }

  @override
  void dispose() {
    _heroCtrl.dispose();
    _featuresCtrl.dispose();
    _cardsCtrl.dispose();
    _ctaCtrl.dispose();
    _billing.products.removeListener(_rebuild);
    _billing.purchasing.removeListener(_rebuild);
    _billing.restoring.removeListener(_rebuild);
    _billing.error.removeListener(_showError);
    _billing.onRestoreComplete = null;
    _entitlement.entitlement.removeListener(_onEntitlementChanged);
    super.dispose();
  }

  void _rebuild() => setState(() {});

  void _showError() {
    final msg = _billing.error.value;
    if (msg != null && mounted) {
      // ── Analytics: purchase_failed
      _analytics.purchaseFailed(
        plan: _selectedId,
        error: msg,
      );

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(msg),
          backgroundColor: AppColors.error,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  void _onRestoreComplete(RestoreResult result) {
    if (!mounted) return;
    // If entitlement already flipped to Pro the success screen will show.
    if (_entitlement.isPro) return;

    // ── Analytics: restore_success
    if (result == RestoreResult.success) {
      _analytics.restoreSuccess();
    }

    final String message;
    final Color bg;
    switch (result) {
      case RestoreResult.success:
        message = 'Kauf wiederhergestellt \u2013 Pro wird aktiviert\u2026';
        bg = _C.success;
        break;
      case RestoreResult.empty:
        message = 'Keine fr\u00fcheren K\u00e4ufe gefunden.';
        bg = _C.card;
        break;
      case RestoreResult.error:
        message = 'Wiederherstellen fehlgeschlagen.';
        bg = AppColors.error;
        break;
    }
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: const TextStyle(color: Colors.white),
        ),
        backgroundColor: bg,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _onEntitlementChanged() {
    if (_entitlement.isPro && mounted) {
      // ── Analytics: purchase_success
      final selectedProduct = _billing.products.value
          .cast<ProductDetails?>()
          .firstWhere((p) => p!.id == _selectedId, orElse: () => null);
      _analytics.purchaseSuccess(
        plan: _selectedId,
        price: selectedProduct?.price ?? '',
      );

      Navigator.of(context).pushReplacement(
        MaterialPageRoute<void>(
          builder: (_) => const ProSuccessScreen(),
        ),
      );
    }
  }

  void _buySelected() {
    HapticFeedback.mediumImpact();
    final products = _billing.products.value;
    final product = products.cast<ProductDetails?>().firstWhere(
          (p) => p!.id == _selectedId,
          orElse: () => null,
        );
    if (product != null) {
      // ── Analytics: purchase_started
      _analytics.purchaseStarted(
        plan: _selectedId,
        price: product.price,
      );
      _billing.buy(product);
    }
  }

  bool get _isYearlySelected => _selectedId == ProProduct.yearlyId;

  @override
  Widget build(BuildContext context) {
    final products = _billing.products.value;
    final loading = _billing.purchasing.value;
    final monthly = products.cast<ProductDetails?>().firstWhere(
          (p) => p!.id == ProProduct.monthlyId,
          orElse: () => null,
        );
    final yearly = products.cast<ProductDetails?>().firstWhere(
          (p) => p!.id == ProProduct.yearlyId,
          orElse: () => null,
        );

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: Scaffold(
        backgroundColor: _C.bg,
        body: Stack(
          children: [
            const _AmbientBackground(),
            SafeArea(
              child: Column(
                children: [
                  Align(
                    alignment: Alignment.topRight,
                    child: Padding(
                      padding: const EdgeInsets.only(top: 8, right: 8),
                      child: IconButton(
                        icon: const Icon(Icons.close_rounded,
                            color: _C.textSecondary, size: 28),
                        onPressed: () => Navigator.of(context).pop(),
                      ),
                    ),
                  ),
                  Expanded(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.symmetric(horizontal: 28),
                      physics: const BouncingScrollPhysics(),
                      child: Column(
                        children: _buildVariantSections(
                          variant: _config.variant,
                          loading: loading,
                          monthly: monthly,
                          yearly: yearly,
                          products: products,
                        ),
                      ),
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

  // ── Variant section builders ───────────────────────────────────────

  List<Widget> _buildVariantSections({
    required PaywallVariant variant,
    required bool loading,
    required ProductDetails? monthly,
    required ProductDetails? yearly,
    required List<ProductDetails> products,
  }) {
    final showSavings = _config.showSavings;
    final showFeatures = _config.showFeatures;

    final hero = _StaggerEntry(
      animation: _heroCtrl,
      withScale: true,
      child: variant == PaywallVariant.b
          ? const _OutcomeHero()
          : const _HeroSection(),
    );

    final features = showFeatures
        ? _StaggerEntry(
            animation: _featuresCtrl,
            child: const _FeatureList(),
          )
        : null;

    final cards = _StaggerEntry(
      animation: _cardsCtrl,
      slideOffset: 40,
      child: products.isEmpty
          ? const _LoadingProducts()
          : _buildPlanCards(
              monthly: monthly,
              yearly: yearly,
              showSavings: showSavings,
              emphasizeYearly: variant == PaywallVariant.c,
            ),
    );

    final cta = _StaggerEntry(
      animation: _ctaCtrl,
      child: _GlowCTA(
        label:
            _isYearlySelected ? '1 Jahr Pro sichern' : 'Pro starten',
        loading: loading,
        onPressed: loading ? null : _buySelected,
      ),
    );

    final footer = _StaggerEntry(
      animation: _ctaCtrl,
      child: _FooterLinks(
        restoring: _billing.restoring.value,
        onRestore: loading
            ? null
            : () {
                _analytics.restoreClicked();
                _billing.restorePurchases();
              },
      ),
    );

    // ── Layout order per variant ──
    switch (variant) {
      case PaywallVariant.a:
        // A: Hero → Features → Cards → CTA
        return [
          const SizedBox(height: 8),
          hero,
          const SizedBox(height: 36),
          if (features != null) ...[features, const SizedBox(height: 36)],
          cards,
          const SizedBox(height: 28),
          cta,
          const SizedBox(height: 16),
          footer,
          const SizedBox(height: 24),
        ];
      case PaywallVariant.b:
        // B: Outcome Hero → Cards → Features → CTA
        return [
          const SizedBox(height: 8),
          hero,
          const SizedBox(height: 36),
          cards,
          if (features != null) ...[const SizedBox(height: 36), features],
          const SizedBox(height: 28),
          cta,
          const SizedBox(height: 16),
          footer,
          const SizedBox(height: 24),
        ];
      case PaywallVariant.c:
        // C: Hero → Cards (yearly bigger) → Features → CTA
        return [
          const SizedBox(height: 8),
          hero,
          const SizedBox(height: 36),
          cards,
          if (features != null) ...[const SizedBox(height: 36), features],
          const SizedBox(height: 28),
          cta,
          const SizedBox(height: 16),
          footer,
          const SizedBox(height: 24),
        ];
    }
  }

  Widget _buildPlanCards({
    required ProductDetails? monthly,
    required ProductDetails? yearly,
    required bool showSavings,
    required bool emphasizeYearly,
  }) {
    return Column(
      children: [
        if (yearly != null)
          _PlanCard(
            title: 'Pro j\u00e4hrlich',
            price: '74,99 \u20ac / Jahr',
            subtitle: 'nur 6,25 \u20ac / Monat',
            savingsLabel: showSavings ? 'Spare 32,89 \u20ac pro Jahr' : null,
            badge: 'BEST VALUE',
            selected: _isYearlySelected,
            emphasized: emphasizeYearly,
            onTap: () {
              setState(() => _selectedId = ProProduct.yearlyId);
              _analytics.planSelected(
                plan: ProProduct.yearlyId,
                price: yearly.price,
              );
            },
          ),
        const SizedBox(height: 12),
        if (monthly != null)
          _PlanCard(
            title: 'Pro monatlich',
            price: '8,99 \u20ac / Monat',
            subtitle: 'monatlich k\u00fcndbar',
            selected: !_isYearlySelected,
            onTap: () {
              setState(() => _selectedId = ProProduct.monthlyId);
              _analytics.planSelected(
                plan: ProProduct.monthlyId,
                price: monthly.price,
              );
            },
          ),
      ],
    );
  }
}

class _AmbientBackground extends StatelessWidget {
  const _AmbientBackground();

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Positioned(
          top: -80,
          left: -60,
          child: Container(
            width: 280,
            height: 280,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [
                  _C.accent.withValues(alpha: 0.25),
                  _C.accent.withValues(alpha: 0.0),
                ],
              ),
            ),
          ),
        ),
        Positioned(
          bottom: 40,
          right: -100,
          child: Container(
            width: 320,
            height: 320,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [
                  const Color(0xFF5E5CE6).withValues(alpha: 0.18),
                  const Color(0xFF5E5CE6).withValues(alpha: 0.0),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _StaggerEntry extends StatelessWidget {
  const _StaggerEntry({
    required this.animation,
    required this.child,
    this.slideOffset = 20,
    this.withScale = false,
  });

  final AnimationController animation;
  final Widget child;
  final double slideOffset;
  final bool withScale;

  @override
  Widget build(BuildContext context) {
    final curved =
        CurvedAnimation(parent: animation, curve: Curves.easeOutCubic);
    return AnimatedBuilder(
      animation: curved,
      builder: (_, __) {
        Widget result = Transform.translate(
          offset: Offset(0, slideOffset * (1 - curved.value)),
          child: child,
        );
        if (withScale) {
          result = Transform.scale(
            scale: 0.92 + 0.08 * curved.value,
            child: result,
          );
        }
        return Opacity(
          opacity: curved.value,
          child: result,
        );
      },
    );
  }
}

class _HeroSection extends StatelessWidget {
  const _HeroSection();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const Text('\u{1F680}', style: TextStyle(fontSize: 56)),
        const SizedBox(height: 20),
        Text(
          'Pro freischalten',
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.w800,
                color: _C.textPrimary,
                letterSpacing: -0.5,
                height: 1.15,
              ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 10),
        Text(
          'Mehr Kontrolle rund um deine OP.',
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: _C.textSecondary,
                height: 1.4,
              ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}

/// Variant B hero – outcome-focused social-proof text.
class _OutcomeHero extends StatelessWidget {
  const _OutcomeHero();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const Text('\u{2728}', style: TextStyle(fontSize: 56)),
        const SizedBox(height: 20),
        Text(
          'Bestens vorbereitet\nin deine OP',
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.w800,
                color: _C.textPrimary,
                letterSpacing: -0.5,
                height: 1.15,
              ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 10),
        Text(
          'Tausende Patienten nutzen Pro f\u00fcr\nmehr Sicherheit und \u00dcberblick.',
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: _C.textSecondary,
                height: 1.5,
              ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}

class _FeatureList extends StatelessWidget {
  const _FeatureList();

  static const _features = [
    ('\u{1F468}\u200D\u{1F469}\u200D\u{1F467}', 'Angeh\u00f6rige einladen'),
    ('\u{1F514}', 'Smarte Erinnerungen'),
    ('\u{1F5C2}\uFE0F', 'Mehr \u00dcbersicht in der Timeline'),
    ('\u{1F512}', 'Sichere Synchronisation'),
  ];

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 24, sigmaY: 24),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
          decoration: BoxDecoration(
            color: _C.card,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: _C.border, width: 0.5),
          ),
          child: Column(
            children: [
              for (int i = 0; i < _features.length; i++) ...[
                if (i > 0)
                  Divider(
                    color: _C.border,
                    height: 20,
                    thickness: 0.5,
                  ),
                Row(
                  children: [
                    Text(
                      _features[i].$1,
                      style: const TextStyle(fontSize: 22),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Text(
                        _features[i].$2,
                        style:
                            Theme.of(context).textTheme.bodyMedium?.copyWith(
                                  color: _C.textPrimary,
                                  fontWeight: FontWeight.w500,
                                ),
                      ),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _PlanCard extends StatefulWidget {
  const _PlanCard({
    required this.title,
    required this.price,
    required this.subtitle,
    this.savingsLabel,
    this.badge,
    required this.selected,
    required this.onTap,
    this.emphasized = false,
  });

  final String title;
  final String price;
  final String subtitle;
  final String? savingsLabel;
  final String? badge;
  final bool selected;
  final VoidCallback onTap;
  final bool emphasized;

  @override
  State<_PlanCard> createState() => _PlanCardState();
}

class _PlanCardState extends State<_PlanCard>
    with SingleTickerProviderStateMixin {
  late final AnimationController _bounceCtrl;
  late final Animation<double> _bounceScale;
  late final Animation<double> _glowFlash;

  @override
  void initState() {
    super.initState();
    _bounceCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    _bounceScale = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 1.0, end: 1.04), weight: 25),
      TweenSequenceItem(tween: Tween(begin: 1.04, end: 0.97), weight: 30),
      TweenSequenceItem(tween: Tween(begin: 0.97, end: 1.0), weight: 45),
    ]).animate(CurvedAnimation(parent: _bounceCtrl, curve: Curves.easeInOut));
    _glowFlash = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 0.0, end: 0.35), weight: 25),
      TweenSequenceItem(tween: Tween(begin: 0.35, end: 0.0), weight: 75),
    ]).animate(CurvedAnimation(parent: _bounceCtrl, curve: Curves.easeOut));
  }

  @override
  void didUpdateWidget(_PlanCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.selected && !oldWidget.selected) {
      _bounceCtrl.forward(from: 0);
    }
  }

  @override
  void dispose() {
    _bounceCtrl.dispose();
    super.dispose();
  }

  void _handleTap() {
    HapticFeedback.lightImpact();
    widget.onTap();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _bounceCtrl,
      builder: (context, child) {
        return Transform.scale(
          scale: _bounceScale.value,
          child: child,
        );
      },
      child: GestureDetector(
        onTap: _handleTap,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 250),
              curve: Curves.easeOutCubic,
              padding: EdgeInsets.all(widget.emphasized ? 24 : 18),
              decoration: BoxDecoration(
                color: widget.selected ? _C.cardSelected : _C.card,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: widget.selected ? _C.borderSelected : _C.border,
                  width: widget.selected ? 1.5 : 0.5,
                ),
                boxShadow: [
                  if (widget.selected)
                    BoxShadow(
                      color: _C.accent.withValues(alpha: 0.15),
                      blurRadius: 24,
                      offset: const Offset(0, 4),
                    ),
                  BoxShadow(
                    color: _C.accent.withValues(alpha: _glowFlash.value),
                    blurRadius: 32,
                    spreadRadius: 2,
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (widget.badge != null) ...[
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 3),
                      decoration: BoxDecoration(
                        color: _C.badge.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        widget.badge!,
                        style: const TextStyle(
                          color: _C.badge,
                          fontSize: 11,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 0.8,
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                  ],
                  Row(
                    children: [
                      _RadioDot(selected: widget.selected),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Text(
                          widget.title,
                          style: Theme.of(context)
                              .textTheme
                              .titleMedium
                              ?.copyWith(
                                fontWeight: FontWeight.w600,
                                color: _C.textPrimary,
                              ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Padding(
                    padding: const EdgeInsets.only(left: 38),
                    child: Text(
                      widget.price,
                      style: widget.emphasized
                          ? Theme.of(context).textTheme.headlineSmall?.copyWith(
                                fontWeight: FontWeight.w800,
                                color: _C.textPrimary,
                                letterSpacing: -0.3,
                              )
                          : Theme.of(context).textTheme.titleLarge?.copyWith(
                                fontWeight: FontWeight.w800,
                                color: _C.textPrimary,
                                letterSpacing: -0.3,
                              ),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Padding(
                    padding: const EdgeInsets.only(left: 38),
                    child: Text(
                      widget.subtitle,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: _C.textSecondary,
                          ),
                    ),
                  ),
                  if (widget.savingsLabel != null) ...[
                    const SizedBox(height: 10),
                    Padding(
                      padding: const EdgeInsets.only(left: 38),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: _C.success.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          widget.savingsLabel!,
                          style: const TextStyle(
                            color: _C.success,
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _RadioDot extends StatelessWidget {
  const _RadioDot({required this.selected});

  final bool selected;

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 250),
      curve: Curves.easeOutCubic,
      width: 22,
      height: 22,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(
          color: selected ? _C.accent : _C.textSecondary,
          width: selected ? 6 : 2,
        ),
        color: Colors.transparent,
      ),
    );
  }
}

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
    with TickerProviderStateMixin {
  late final AnimationController _pulseCtrl;
  late final Animation<double> _pulse;
  late final AnimationController _shineCtrl;

  @override
  void initState() {
    super.initState();
    _pulseCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    )..repeat(reverse: true);
    _pulse = Tween<double>(begin: 0.4, end: 1.0).animate(
      CurvedAnimation(parent: _pulseCtrl, curve: Curves.easeInOut),
    );
    _shineCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2400),
    )..repeat();
  }

  @override
  void dispose() {
    _pulseCtrl.dispose();
    _shineCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: Listenable.merge([_pulse, _shineCtrl]),
      builder: (context, child) {
        return Container(
          height: 56,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: _C.accentGlow.withValues(alpha: 0.35 * _pulse.value),
                blurRadius: 28,
                spreadRadius: 2,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: child,
        );
      },
      child: SizedBox(
        width: double.infinity,
        height: 56,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: Stack(
            children: [
              Positioned.fill(
                child: ElevatedButton(
                  onPressed: widget.onPressed,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _C.accent,
                    foregroundColor: Colors.white,
                    disabledBackgroundColor: _C.accent.withValues(alpha: 0.5),
                    disabledForegroundColor: Colors.white70,
                    elevation: 0,
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
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(
                            strokeWidth: 2.5,
                            color: Colors.white,
                          ),
                        )
                      : Text(widget.label),
                ),
              ),
              // Shine sweep overlay
              if (!widget.loading)
                Positioned.fill(
                  child: IgnorePointer(
                    child: AnimatedBuilder(
                      animation: _shineCtrl,
                      builder: (context, _) {
                        final dx = _shineCtrl.value * 3.0 - 1.0;
                        return ShaderMask(
                          shaderCallback: (bounds) {
                            return LinearGradient(
                              begin: Alignment(dx - 0.3, 0),
                              end: Alignment(dx + 0.3, 0),
                              colors: const [
                                Color(0x00FFFFFF),
                                Color(0x18FFFFFF),
                                Color(0x00FFFFFF),
                              ],
                            ).createShader(bounds);
                          },
                          blendMode: BlendMode.srcATop,
                          child: Container(color: Colors.white),
                        );
                      },
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _FooterLinks extends StatelessWidget {
  const _FooterLinks({this.onRestore, this.restoring = false});

  final VoidCallback? onRestore;
  final bool restoring;

  @override
  Widget build(BuildContext context) {
    const linkStyle = TextStyle(
      color: _C.textSecondary,
      fontSize: 12,
      decoration: TextDecoration.underline,
      decorationColor: _C.textSecondary,
    );
    const sep = Text(
      '  \u00b7  ',
      style: TextStyle(color: _C.textSecondary, fontSize: 12),
    );

    return Column(
      children: [
        TextButton(
          onPressed: onRestore,
          style: TextButton.styleFrom(foregroundColor: _C.textSecondary),
          child: restoring
              ? const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: _C.textSecondary,
                  ),
                )
              : const Text(
                  'Wiederherstellen',
                  style: TextStyle(fontSize: 13),
                ),
        ),
        const SizedBox(height: 4),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            GestureDetector(
              onTap: () => Navigator.of(context).pushNamed('/privacy'),
              child: const Text('Datenschutz', style: linkStyle),
            ),
            sep,
            GestureDetector(
              onTap: () => Navigator.of(context).pushNamed('/imprint'),
              child: const Text('Nutzungsbedingungen', style: linkStyle),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Text(
          'Das Abo verl\u00e4ngert sich automatisch, sofern es nicht '
          '24 h vor Ablauf gek\u00fcndigt wird.',
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: _C.textSecondary.withValues(alpha: 0.5),
                fontSize: 10,
                height: 1.4,
              ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}

class _LoadingProducts extends StatelessWidget {
  const _LoadingProducts();

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.symmetric(vertical: 40),
      child: Center(
        child: CircularProgressIndicator(
          strokeWidth: 2,
          color: _C.textSecondary,
        ),
      ),
    );
  }
}
