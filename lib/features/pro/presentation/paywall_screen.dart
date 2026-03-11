import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:in_app_purchase/in_app_purchase.dart';

import '../../../auth/guest_data_migration_service.dart';
import '../../../ui/theme/colors.dart';
import '../data/billing_service.dart';
import '../data/entitlement_service.dart';
import '../data/paywall_config.dart';
import '../data/pro_analytics.dart';
import '../domain/pro_product.dart';
import 'pro_success_screen.dart';
import 'package:operationsbegleiter_v3/ui/components/glass_icon.dart';
import 'package:operationsbegleiter_v3/ui/theme/app_icons.dart';

// ── Light palette (white / blue) ─────────────────────────────────────

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

/// Full-screen emotional paywall – single scrollable page.
///
/// Layout (top → bottom):
/// 1. Hero block with context-aware headline
/// 2. Story/empathy section
/// 3. Feature pills
/// 4. Social proof strip
/// 5. Plan cards
/// 6. CTA button
/// 7. Legal footer
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
  final ScrollController _scrollCtrl = ScrollController();
  bool _pricesVisible = false;

  // ── Entrance animation ─────────────────────────────────────────────
  late final AnimationController _entranceCtrl;

  // ── Inline success overlay ─────────────────────────────────────────
  bool _showSuccess = false;
  late final AnimationController _successCtrl;
  late final Animation<double> _successScale;
  late final AnimationController _successContentCtrl;

  // Price section key for scroll tracking.
  final _priceKey = GlobalKey();

  @override
  void initState() {
    super.initState();

    _selectedId = _config.defaultPlan == 'monthly'
        ? ProProduct.monthlyId
        : ProProduct.yearlyId;

    _entranceCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );

    // Success overlay
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

    _billing.products.addListener(_rebuild);
    _billing.productsLoading.addListener(_rebuild);
    _billing.storeAvailable.addListener(_rebuild);
    _billing.purchasing.addListener(_rebuild);
    _billing.restoring.addListener(_rebuild);
    _billing.error.addListener(_showError);
    _billing.onRestoreComplete = _onRestoreComplete;
    _entitlement.entitlement.addListener(_onEntitlementChanged);

    _scrollCtrl.addListener(_onScroll);

    _analytics.paywallOpened(
      source: widget.source,
      variant: 'EMOTIONAL',
    );
  }

  @override
  void dispose() {
    _entranceCtrl.dispose();
    _successCtrl.dispose();
    _successContentCtrl.dispose();
    _scrollCtrl.dispose();
    _billing.products.removeListener(_rebuild);
    _billing.productsLoading.removeListener(_rebuild);
    _billing.storeAvailable.removeListener(_rebuild);
    _billing.purchasing.removeListener(_rebuild);
    _billing.restoring.removeListener(_rebuild);
    _billing.error.removeListener(_showError);
    _billing.onRestoreComplete = null;
    _entitlement.entitlement.removeListener(_onEntitlementChanged);
    super.dispose();
  }

  void _rebuild() {
    final products = _billing.products.value;
    if (products.isNotEmpty &&
        !products.any((product) => product.id == _selectedId)) {
      _selectedId = products.first.id;
    }
    setState(() {});
  }

  void _onScroll() {
    if (_pricesVisible) return;
    final box =
        _priceKey.currentContext?.findRenderObject() as RenderBox?;
    if (box == null || !box.hasSize) return;
    final offset = box.localToGlobal(Offset.zero);
    if (offset.dy < MediaQuery.of(context).size.height) {
      _pricesVisible = true;
      _analytics.paywallScrolledToPrices(source: widget.source);
    }
  }

  void _showError() {
    final msg = _billing.error.value;
    if (msg != null && mounted) {
      _analytics.purchaseFailed(plan: _selectedId, error: msg);
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
    if (_entitlement.isPro) return;

    if (result == RestoreResult.success) _analytics.restoreSuccess();

    final (String message, Color bg) = switch (result) {
      RestoreResult.success => (
          'Kauf wiederhergestellt – Pro wird aktiviert\u2026',
          _C.success
        ),
      RestoreResult.empty => (
          'Keine früheren Käufe gefunden.',
          _C.card
        ),
      RestoreResult.error => (
          'Wiederherstellen fehlgeschlagen.',
          AppColors.error
        ),
    };
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message, style: const TextStyle(color: Colors.white)),
        backgroundColor: bg,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _onEntitlementChanged() {
    if (_entitlement.isPro && mounted) {
      final p = _billing.products.value
          .cast<ProductDetails?>()
          .firstWhere((p) => p!.id == _selectedId, orElse: () => null);
      _analytics.purchaseSuccess(plan: _selectedId, price: p?.price ?? '');
      _playSuccessOverlay();
    }
  }

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
    await Future<void>.delayed(const Duration(milliseconds: 1800));
    if (!mounted) return;
    Navigator.of(context).pushReplacement(
      MaterialPageRoute<void>(builder: (_) => const ProSuccessScreen()),
    );
  }

  void _buySelected() async {
    // Guest users must sign in before purchasing.
    if (FirebaseAuth.instance.currentUser == null) {
      final authed = await GuestDataMigrationService.requireAuth(
        context,
        reason: 'Um Pro freizuschalten, benötigst du ein Konto.',
      );
      if (!authed || !mounted) return;
    }

    HapticFeedback.mediumImpact();
    final product = _selectedProduct;
    if (product != null) {
      _analytics.purchaseStarted(plan: product.id, price: product.price);
      _billing.buy(product);
    }
  }

  Future<void> _handlePrimaryAction(ProductDetails? selectedProduct) async {
    if (_billing.purchasing.value || _billing.productsLoading.value) return;

    if (selectedProduct != null) {
      _buySelected();
      return;
    }

    HapticFeedback.selectionClick();
    await _billing.loadProducts();
    if (!mounted) return;

    final message = _primaryHintText(_selectedProduct);
    if (message == null) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  ProductDetails? get _selectedProduct {
    for (final product in _billing.products.value) {
      if (product.id == _selectedId) return product;
    }
    final products = _billing.products.value;
    if (products.isNotEmpty) return products.first;
    return null;
  }

  String _primaryButtonLabel(ProductDetails? selectedProduct) {
    if (_billing.productsLoading.value) {
      return 'Abo wird geladen';
    }
    if (selectedProduct != null) {
      return 'Jetzt Pro starten';
    }
    return _billing.storeAvailable.value
        ? 'Abo laden'
        : 'Store erneut prüfen';
  }

  String? _primaryHintText(ProductDetails? selectedProduct) {
    if (selectedProduct != null ||
        _billing.productsLoading.value ||
        _billing.purchasing.value) {
      return null;
    }
    if (!_billing.storeAvailable.value) {
      return 'Der Store ist gerade nicht verfügbar. Bitte versuche es erneut.';
    }
    return 'Die Abo-Optionen konnten noch nicht geladen werden. Bitte erneut versuchen.';
  }

  String _planSubtitle({
    required ProductDetails? product,
    required String fallback,
    String? loadedText,
  }) {
    if (product != null) return loadedText ?? fallback;
    if (_billing.productsLoading.value) return 'Preis wird geladen';
    return 'Derzeit nicht verfügbar';
  }

  String _planPrice(ProductDetails? product, {String? periodSuffix}) {
    if (product != null) {
      return periodSuffix != null
          ? '${product.price} / $periodSuffix'
          : product.price;
    }
    return _billing.productsLoading.value ? '...' : 'Nicht verf.';
  }

  /// Real savings percentage: yearly vs 12×monthly.
  int? _calcRealSavingsPercent(
      ProductDetails? monthly, ProductDetails? yearly) {
    if (monthly == null || yearly == null) return null;
    final monthlyTotal = monthly.rawPrice * 12;
    if (monthlyTotal <= 0) return null;
    final savings = 1 - (yearly.rawPrice / monthlyTotal);
    final percent = (savings * 100).round();
    return percent > 0 ? percent : null;
  }

  String? _buildYearlyBadge(
      ProductDetails? monthly, ProductDetails? yearly) {
    if (!_config.showSavings) return null;
    final percent = _calcRealSavingsPercent(monthly, yearly);
    if (percent != null) return '$percent% SPAREN';
    return 'BELIEBTESTE WAHL';
  }

  String _annualValueHeadline(ProductDetails? monthly, ProductDetails? yearly) {
    if (monthly == null || yearly == null) {
      return 'Einmal entscheiden, langfristig Ruhe haben';
    }
    final yearlyEquivalent = yearly.rawPrice / 12;
    final savings = 1 - (yearlyEquivalent / monthly.rawPrice);
    final percent = (savings * 100).round();
    if (percent <= 0) return '12 Monate Begleitung ohne monatliches Nachdenken';
    return 'Spare $percent% gegenüber dem Monatsabo';
  }

  String _annualValueSubline(ProductDetails? monthly, ProductDetails? yearly) {
    if (monthly == null || yearly == null) {
      return 'Das Jahresabo ist ideal, wenn du Arzttermine, Nachsorge und Reha über mehrere Monate begleiten willst.';
    }
    final monthlyTotal = monthly.rawPrice * 12;
    final diff = monthlyTotal - yearly.rawPrice;
    if (diff <= 0) {
      return 'Ein Preis für die gesamte OP- und Nachsorgephase.';
    }
    return 'Einmal pro Jahr statt 12 Einzelabbuchungen und mehr Fokus auf deine Genesung.';
  }

  void _scrollToPrices() {
    final box =
        _priceKey.currentContext?.findRenderObject() as RenderBox?;
    if (box == null) return;
    final offset = box.localToGlobal(Offset.zero);
    _scrollCtrl.animateTo(
      _scrollCtrl.offset + offset.dy - 120,
      duration: const Duration(milliseconds: 500),
      curve: Curves.easeOutCubic,
    );
  }

  // ── Context-aware copy ─────────────────────────────────────────────

  String get _heroHeadline {
    return switch (widget.source) {
      'relatives_feature' =>
        'Deine Liebsten\nverdienen Updates.',
      'rehab_feature' =>
        'Reha mit Struktur.\nTag für Tag.',
      'voice_feature' =>
        'Deine Stimme.\nDeine Erinnerung.',
      'photo_limit' =>
        'Noch mehr Momente\nfesthalten.',
      'document_limit' =>
        'Alle Dokumente\nsicher aufbewahrt.',
      'arztbericht_export' =>
        'Dein Arztbericht.\nImmer griffbereit.',
      'red_flag_feature' =>
        'Warnsignale früh\nerkennen.',
      'progress_feature' =>
        'Deinen Fortschritt\nim Blick behalten.',
      _ => 'Mehr Sicherheit\nrund um deine OP.',
    };
  }

  String get _storyText {
    return switch (widget.source) {
      'relatives_feature' =>
        'Eine OP betrifft nie nur dich allein. '
            'Mit Pro hältst du Familie und Freunde '
            'automatisch auf dem Laufenden – ohne '
            'jedes Mal erklären zu müssen.',
      'rehab_feature' =>
        'Nach der OP entscheidet Konstanz über Fortschritt. '
            'Mit Pro bekommst du Reha-Übungen, Timer und eine klare Struktur, '
            'damit du wirklich dranbleibst.',
      'voice_feature' =>
        'Nach einem Arztgespräch gehen Details schnell verloren. '
            'Mit Pro sprichst du einfach rein – '
            'und vergisst nichts Wichtiges mehr.',
      'photo_limit' || 'document_limit' =>
        'OP-Vorbereitung bedeutet viele Unterlagen. '
            'Mit Pro speicherst du alles zentral '
            'und hast jederzeit Zugriff.',
      _ =>
        'Eine OP ist ein Ausnahmezustand. '
            'Operationsbegleiter Pro gibt dir die Werkzeuge, '
            'damit du dich auf das Wichtigste konzentrieren kannst: '
            'deine Genesung.',
    };
  }

  @override
  Widget build(BuildContext context) {
    final products = _billing.products.value;
    final selectedProduct = _selectedProduct;
    final purchaseLoading = _billing.purchasing.value;
    final ctaLoading = purchaseLoading || _billing.productsLoading.value;
    final monthly = products.cast<ProductDetails?>().firstWhere(
          (p) => p!.id == ProProduct.monthlyId,
          orElse: () => null,
        );
    final yearly = products.cast<ProductDetails?>().firstWhere(
          (p) => p!.id == ProProduct.yearlyId,
          orElse: () => null,
        );

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.dark,
      child: Scaffold(
        backgroundColor: _C.bg,
        body: Stack(
          children: [
            const _AmbientBackground(),
            SafeArea(
              child: Column(
                children: [
                  // ── Top bar ───────────────────────────────
                  Padding(
                    padding:
                        const EdgeInsets.only(top: 8, left: 8, right: 8),
                    child: Row(
                      children: [
                        const SizedBox(width: 48),
                        const Spacer(),
                        // Close
                        IconButton(
                          icon: const Icon(Icons.close_rounded,
                              color: _C.textSecondary, size: 28),
                          onPressed: () => Navigator.of(context).pop(),
                        ),
                      ],
                    ),
                  ),
                  // ── Scrollable content ────────────────────
                  Expanded(
                    child: SingleChildScrollView(
                      controller: _scrollCtrl,
                      physics: const BouncingScrollPhysics(),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 24),
                      child: Column(
                        children: [
                          const SizedBox(height: 16),
                          // 1 ── Hero block
                          _StaggerEntry(
                            animation: _entranceCtrl,
                            delay: 0.0,
                            child: _HeroBlock(
                              headline: _heroHeadline,
                              onCta: _scrollToPrices,
                            ),
                          ),
                          const SizedBox(height: 20),

                          // 2 ── Story section
                          _StaggerEntry(
                            animation: _entranceCtrl,
                            delay: 0.10,
                            child: _StorySection(
                                text: _storyText),
                          ),
                          const SizedBox(height: 36),

                          // 3 ── Free vs Pro comparison table
                          _StaggerEntry(
                            animation: _entranceCtrl,
                            delay: 0.20,
                            child: const _FreeVsProTable(),
                          ),
                          const SizedBox(height: 36),

                          // 4 ── Social proof
                          _StaggerEntry(
                            animation: _entranceCtrl,
                            delay: 0.25,
                            child: const _SocialProofStrip(),
                          ),
                          const SizedBox(height: 20),

                          _StaggerEntry(
                            animation: _entranceCtrl,
                            delay: 0.30,
                            child: _ValueAnchorStrip(
                              headline:
                                  _annualValueHeadline(monthly, yearly),
                              subline:
                                  _annualValueSubline(monthly, yearly),
                            ),
                          ),
                          const SizedBox(height: 40),

                          // 5 ── Plan cards
                          _StaggerEntry(
                            animation: _entranceCtrl,
                            delay: 0.40,
                            child: Column(
                              key: _priceKey,
                              children: [
                                Text(
                                  'Wähle deinen Plan',
                                  style: Theme.of(context)
                                      .textTheme
                                      .titleMedium
                                      ?.copyWith(
                                        color: _C.textPrimary,
                                        fontWeight: FontWeight.w700,
                                      ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  'Für die meisten Nutzer lohnt sich Pro über die gesamte OP- und Reha-Phase am meisten im Jahresabo.',
                                  textAlign: TextAlign.center,
                                  style: Theme.of(context)
                                      .textTheme
                                      .bodySmall
                                      ?.copyWith(
                                        color: _C.textSecondary,
                                        height: 1.4,
                                      ),
                                ),
                                const SizedBox(height: 16),
                                _PlanCardGeneric(
                                  title: 'Jährlich',
                                  subtitle: _planSubtitle(
                                  product: yearly,
                                  fallback: 'Bester Preis pro Monat',
                                  loadedText: yearly != null
                                    ? 'nur ${_monthlyEquivalent(yearly)} / Monat'
                                    : null,
                                  ),
                                  price: _planPrice(yearly,
                                      periodSuffix: 'Jahr'),
                                  badge: _buildYearlyBadge(
                                      monthly, yearly),
                                  selected:
                                      _selectedId == ProProduct.yearlyId,
                                  emphasized: true,
                                  onTap: () => _selectPlanById(
                                    ProProduct.yearlyId),
                                ),
                                const SizedBox(height: 12),
                                _PlanCardGeneric(
                                  title: 'Monatlich',
                                  subtitle: _planSubtitle(
                                  product: monthly,
                                  fallback: 'monatlich kündbar',
                                  ),
                                  price: _planPrice(monthly,
                                      periodSuffix: 'Monat'),
                                  selected:
                                      _selectedId == ProProduct.monthlyId,
                                  onTap: () => _selectPlanById(
                                      ProProduct.monthlyId),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 20),

                          // ── Trust badges
                          _StaggerEntry(
                            animation: _entranceCtrl,
                            delay: 0.45,
                            child: const _TrustBadges(),
                          ),
                          const SizedBox(height: 24),

                          // 6 ── CTA
                          _StaggerEntry(
                            animation: _entranceCtrl,
                            delay: 0.50,
                            child: _GlowCTA(
                              label: _primaryButtonLabel(selectedProduct),
                              loading: ctaLoading,
                              onPressed: ctaLoading
                                  ? null
                                  : () => _handlePrimaryAction(
                                        selectedProduct,
                                      ),
                            ),
                          ),
                          if (_primaryHintText(selectedProduct) != null) ...[
                            const SizedBox(height: 12),
                            Text(
                              _primaryHintText(selectedProduct)!,
                              style: Theme.of(context)
                                  .textTheme
                                  .bodySmall
                                  ?.copyWith(
                                    color: _C.textSecondary,
                                    height: 1.35,
                                  ),
                              textAlign: TextAlign.center,
                            ),
                          ],
                          const SizedBox(height: 20),

                          // ── Testimonials (below CTA)
                          _StaggerEntry(
                            animation: _entranceCtrl,
                            delay: 0.55,
                            child: const _TestimonialsSection(),
                          ),
                          const SizedBox(height: 20),

                          // 7 ── Footer
                          _FooterLinks(
                            restoring: _billing.restoring.value,
                            onRestore: purchaseLoading
                                ? null
                                : () {
                                    _analytics.restoreClicked();
                                    _billing.restorePurchases();
                                  },
                            onRedeemKey: () {
                              Navigator.of(context)
                                  .pushNamed('/redeem-key');
                            },
                          ),
                          const SizedBox(height: 32),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            // ── Success overlay ────────────────────────────
            if (_showSuccess) _buildSuccessOverlay(),
          ],
        ),
      ),
    );
  }

  void _selectPlanById(String id) {
    setState(() => _selectedId = id);
    HapticFeedback.lightImpact();
    final product = _billing.products.value
        .cast<ProductDetails?>()
        .firstWhere((p) => p!.id == id, orElse: () => null);
    if (product != null) {
      _analytics.planSelected(plan: id, price: product.price);
    }
  }

  String _monthlyEquivalent(ProductDetails yearly) {
    final raw = yearly.rawPrice / 12;
    // Format with 2 decimals + currency symbol.
    return '${raw.toStringAsFixed(2).replaceAll('.', ',')} ${yearly.currencySymbol}';
  }

  Widget _buildSuccessOverlay() {
    final contentCurved = CurvedAnimation(
      parent: _successContentCtrl,
      curve: Curves.easeOutCubic,
    );
    return Positioned.fill(
      child: Container(
        color: _C.bg.withValues(alpha: 0.92),
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
                  child: const Icon(
                    Icons.check_rounded,
                    color: Colors.white,
                    size: 52,
                  ),
                ),
              ),
              const SizedBox(height: 28),
              FadeTransition(
                opacity: contentCurved,
                child: SlideTransition(
                  position: Tween<Offset>(
                    begin: const Offset(0, 0.15),
                    end: Offset.zero,
                  ).animate(contentCurved),
                  child: Text(
                    'Pro aktiviert',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          color: _C.textPrimary,
                          fontWeight: FontWeight.w800,
                        ),
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

// ══════════════════════════════════════════════════════════════════════
// ── Ambient background ──────────────────────────────────────────────
// ══════════════════════════════════════════════════════════════════════

class _AmbientBackground extends StatelessWidget {
  const _AmbientBackground();

  @override
  Widget build(BuildContext context) {
    return Positioned.fill(
      child: IgnorePointer(
        child: Stack(
          children: [
            Positioned(
              top: -120,
              left: -80,
              width: 360,
              height: 360,
              child: Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      _C.accent.withValues(alpha: 0.08),
                      Colors.transparent,
                    ],
                  ),
                ),
              ),
            ),
            Positioned(
              bottom: -60,
              right: -100,
              width: 300,
              height: 300,
              child: Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      _C.accent.withValues(alpha: 0.05),
                      Colors.transparent,
                    ],
                  ),
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
// ── 1. Hero block ───────────────────────────────────────────────────
// ══════════════════════════════════════════════════════════════════════

class _HeroBlock extends StatelessWidget {
  const _HeroBlock({required this.headline, this.onCta});

  final String headline;
  final VoidCallback? onCta;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        GlassIcon(icon: AppIcons.vitals, color: AppIcons.vitalsColor, size: 39),
        const SizedBox(height: 20),
        Text(
          headline,
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                color: _C.textPrimary,
                fontWeight: FontWeight.w800,
                height: 1.15,
                letterSpacing: -0.5,
              ),
        ),
        const SizedBox(height: 12),
        Text(
          'Operationsbegleiter Pro',
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: _C.accent,
                fontWeight: FontWeight.w600,
              ),
        ),
        const SizedBox(height: 24),
        TextButton(
          onPressed: onCta,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Pläne ansehen',
                style: TextStyle(
                  color: _C.accent,
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(width: 4),
              Icon(Icons.arrow_downward_rounded,
                  color: _C.accent, size: 16),
            ],
          ),
        ),
      ],
    );
  }
}

// ══════════════════════════════════════════════════════════════════════
// ── 2. Story section ────────────────────────────────────────────────
// ══════════════════════════════════════════════════════════════════════

class _StorySection extends StatelessWidget {
  const _StorySection({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      decoration: BoxDecoration(
        color: _C.card,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: _C.border, width: 0.5),
      ),
      child: Text(
        text,
        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              color: _C.textSecondary,
              height: 1.55,
              fontSize: 15,
            ),
        textAlign: TextAlign.center,
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════════════
// ── 3. Social proof strip ───────────────────────────────────────────
// ══════════════════════════════════════════════════════════════════════

class _SocialProofStrip extends StatelessWidget {
  const _SocialProofStrip();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: BoxDecoration(
        color: _C.accent.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: _C.accent.withValues(alpha: 0.15),
          width: 0.5,
        ),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Star rating
              Row(
                mainAxisSize: MainAxisSize.min,
                children: List.generate(
                  5,
                  (_) => const Icon(Icons.star_rounded,
                      color: _C.badge, size: 18),
                ),
              ),
              const SizedBox(width: 12),
              Text(
                '4,9',
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      color: _C.textPrimary,
                      fontWeight: FontWeight.w800,
                    ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.people_alt_rounded,
                  color: _C.accent, size: 18),
              const SizedBox(width: 8),
              Flexible(
                child: Text(
                  'Bereits 2.500+ Patienten vertrauen auf Pro',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: _C.textSecondary,
                        fontWeight: FontWeight.w600,
                      ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ValueAnchorStrip extends StatelessWidget {
  const _ValueAnchorStrip({
    required this.headline,
    required this.subline,
  });

  final String headline;
  final String subline;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            _C.badge.withValues(alpha: 0.16),
            _C.accent.withValues(alpha: 0.12),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: _C.badge.withValues(alpha: 0.30),
          width: 0.7,
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: _C.accent.withValues(alpha: 0.10),
              borderRadius: BorderRadius.circular(12),
            ),
            alignment: Alignment.center,
            child: const Icon(
              Icons.workspace_premium_rounded,
              color: _C.badge,
              size: 22,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  headline,
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        color: _C.textPrimary,
                        fontWeight: FontWeight.w800,
                      ),
                ),
                const SizedBox(height: 4),
                Text(
                  subline,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: _C.textSecondary,
                        height: 1.4,
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
// ── 5. Plan card ────────────────────────────────────────────────────
// ══════════════════════════════════════════════════════════════════════

// ── Plan card (works with or without store prices) ───────────────────

class _PlanCardGeneric extends StatefulWidget {
  const _PlanCardGeneric({
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
  State<_PlanCardGeneric> createState() => _PlanCardGenericState();
}

class _PlanCardGenericState extends State<_PlanCardGeneric>
    with TickerProviderStateMixin {
  late final AnimationController _bounceCtrl;
  late final Animation<double> _bounceAnim;
  late final AnimationController _shimmerCtrl;

  @override
  void initState() {
    super.initState();
    _bounceCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    _bounceAnim = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 1.0, end: 1.04), weight: 30),
      TweenSequenceItem(tween: Tween(begin: 1.04, end: 0.97), weight: 30),
      TweenSequenceItem(tween: Tween(begin: 0.97, end: 1.0), weight: 40),
    ]).animate(
        CurvedAnimation(parent: _bounceCtrl, curve: Curves.easeOutCubic));
    _shimmerCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    )..repeat();
  }

  @override
  void didUpdateWidget(_PlanCardGeneric old) {
    super.didUpdateWidget(old);
    if (widget.selected && !old.selected) {
      _bounceCtrl.forward(from: 0);
    }
  }

  @override
  void dispose() {
    _bounceCtrl.dispose();
    _shimmerCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final sel = widget.selected;
    const opacity = 1.0;

    return ScaleTransition(
      scale: _bounceAnim,
      child: Opacity(
        opacity: opacity,
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
                      )
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
                            AnimatedBuilder(
                              animation: _shimmerCtrl,
                              builder: (context, child) {
                                return ShaderMask(
                                  shaderCallback: (bounds) {
                                    return LinearGradient(
                                      colors: const [
                                        Color(0xFF007AFF),
                                        Color(0xFFFFFFFF),
                                        Color(0xFF007AFF),
                                      ],
                                      stops: [
                                        (_shimmerCtrl.value - 0.3)
                                            .clamp(0.0, 1.0),
                                        _shimmerCtrl.value,
                                        (_shimmerCtrl.value + 0.3)
                                            .clamp(0.0, 1.0),
                                      ],
                                    ).createShader(bounds);
                                  },
                                  blendMode: BlendMode.srcIn,
                                  child: child,
                                );
                              },
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 8, vertical: 3),
                                decoration: BoxDecoration(
                                  color: _C.badge,
                                  borderRadius: BorderRadius.circular(6),
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
                            ),
                          ],
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        widget.subtitle,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: _C.textSecondary,
                            ),
                      ),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      widget.price,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            color: _C.textPrimary,
                            fontWeight: FontWeight.w800,
                          ),
                    ),
                  ],
                ),
              ],
            ),
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
// ── 6. Glow CTA button ──────────────────────────────────────────────
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
// ── 7. Footer links ─────────────────────────────────────────────────
// ══════════════════════════════════════════════════════════════════════

class _FooterLinks extends StatelessWidget {
  const _FooterLinks({
    required this.restoring,
    this.onRestore,
    this.onRedeemKey,
  });

  final bool restoring;
  final VoidCallback? onRestore;
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
        // Restore
        TextButton(
          onPressed: onRestore,
          child: restoring
              ? const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: _C.textSecondary,
                  ),
                )
              : const Text('Wiederherstellen', style: linkStyle),
        ),
        // Redeem key
        TextButton(
          onPressed: onRedeemKey,
          child: const Text('Pro Key einlösen', style: linkStyle),
        ),
        const SizedBox(height: 8),
        // Legal
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            GestureDetector(
              onTap: () => Navigator.of(context).pushNamed('/privacy'),
              child: const Text('Datenschutz', style: linkStyle),
            ),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 12),
              child: Text('·',
                  style: TextStyle(color: _C.textSecondary)),
            ),
            GestureDetector(
              onTap: () => Navigator.of(context).pushNamed('/imprint'),
              child: const Text('Nutzungsbedingungen',
                  style: linkStyle),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Text(
            'Das Abo verlängert sich automatisch, sofern es nicht '
            'mindestens 24 h vor Ablauf der aktuellen Laufzeit gekündigt wird. '
            'Die Zahlung wird über dein iTunes-Konto abgewickelt. '
            'Du kannst jederzeit in den Einstellungen kündigen.',
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

// ══════════════════════════════════════════════════════════════════════
// ── Free vs Pro Comparison Table ────────────────────────────────────
// ══════════════════════════════════════════════════════════════════════

class _FreeVsProTable extends StatelessWidget {
  const _FreeVsProTable();

  static const _rows = <(String, String, String)>[
    ('OP-Timeline', '✓', '✓'),
    ('Medikamenten\u00ADplan', '✓', '✓'),
    ('Schmerztagebuch', '✓', '✓'),
    ('Vitalwerte', '✓', '✓'),
    ('Termin\u00ADverwaltung', '✓', '✓'),
    ('Packlisten', '1', '∞'),
    ('Fotos', '3', '∞'),
    ('Dokumente', '5', '∞'),
    ('Sprach\u00ADnotizen', '–', '✓'),
    ('Angehörige einladen', '–', '✓'),
    ('Reha-System', '–', '✓'),
    ('Red-Flag Warnung', '–', '✓'),
    ('Arztbericht Export', '–', '✓'),
    ('Fortschritts\u00ADtracking', '–', '✓'),
    ('Werbefrei', '–', '✓'),
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
          // Header
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            color: _C.accent.withValues(alpha: 0.10),
            child: Row(
              children: [
                Expanded(
                  flex: 3,
                  child: Text(
                    'Feature',
                    style: ts.labelMedium?.copyWith(
                      color: _C.textSecondary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                Expanded(
                  child: Text(
                    'Free',
                    textAlign: TextAlign.center,
                    style: ts.labelMedium?.copyWith(
                      color: _C.textSecondary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                Expanded(
                  child: Text(
                    'Pro',
                    textAlign: TextAlign.center,
                    style: ts.labelMedium?.copyWith(
                      color: _C.accent,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ],
            ),
          ),
          // Rows
          for (int i = 0; i < _rows.length; i++)
            Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 11),
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
                    child: Text(
                      _rows[i].$2,
                      textAlign: TextAlign.center,
                      style: ts.bodySmall?.copyWith(
                        color: _rows[i].$2 == '–'
                            ? _C.textSecondary.withValues(alpha: 0.5)
                            : _rows[i].$2 == '✓'
                                ? _C.success
                                : _C.textSecondary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  Expanded(
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
// ── Testimonials Section ────────────────────────────────────────────
// ══════════════════════════════════════════════════════════════════════

class _TestimonialsSection extends StatelessWidget {
  const _TestimonialsSection();

  static const _testimonials = <({String text, String name, String context, int stars})>[
    (
      text: 'Nach meiner Knie-OP hatte ich hundert Fragen. '
          'Mit Pro konnte ich alles per Sprache festhalten '
          'und meiner Familie über die Angehörigen-Funktion Updates schicken. '
          'Das hat mir so viel Stress genommen.',
      name: 'Maria K.',
      context: 'Knie-TEP, 58 Jahre',
      stars: 5,
    ),
    (
      text: 'Das Reha-System mit Timer ist Gold wert. '
          'Ich habe meine Übungen jeden Tag gemacht und '
          'konnte meinem Arzt beim nächsten Termin den '
          'Fortschrittsbericht direkt zeigen.',
      name: 'Thomas R.',
      context: 'Bandscheiben-OP, 44 Jahre',
      stars: 5,
    ),
    (
      text: 'Ich war nervös vor der OP. Die Red-Flag Warnung '
          'hat mir nach dem Eingriff Sicherheit gegeben – '
          'ich wusste immer, worauf ich achten muss. '
          'Die paar Euro im Monat sind es absolut wert.',
      name: 'Sandra W.',
      context: 'Schilddrüsen-OP, 36 Jahre',
      stars: 5,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          'Das sagen unsere Nutzer',
          style: Theme.of(context).textTheme.titleSmall?.copyWith(
                color: _C.textPrimary,
                fontWeight: FontWeight.w700,
              ),
        ),
        const SizedBox(height: 14),
        for (int i = 0; i < _testimonials.length; i++) ...[
          _TestimonialCard(testimonial: _testimonials[i]),
          if (i < _testimonials.length - 1) const SizedBox(height: 10),
        ],
      ],
    );
  }
}

class _TestimonialCard extends StatelessWidget {
  const _TestimonialCard({required this.testimonial});

  final ({String text, String name, String context, int stars}) testimonial;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _C.card,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: _C.border, width: 0.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Stars
          Row(
            children: List.generate(
              testimonial.stars,
              (_) => const Icon(Icons.star_rounded,
                  color: _C.badge, size: 16),
            ),
          ),
          const SizedBox(height: 10),
          Text(
            '»${testimonial.text}«',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: _C.textSecondary,
                  height: 1.5,
                  fontStyle: FontStyle.italic,
                ),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: _C.accent.withValues(alpha: 0.15),
                  shape: BoxShape.circle,
                ),
                alignment: Alignment.center,
                child: Text(
                  testimonial.name[0],
                  style: TextStyle(
                    color: _C.accent,
                    fontWeight: FontWeight.w700,
                    fontSize: 14,
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      testimonial.name,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: _C.textPrimary,
                            fontWeight: FontWeight.w700,
                          ),
                    ),
                    Text(
                      testimonial.context,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: _C.textSecondary,
                            fontSize: 11,
                          ),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.verified_rounded,
                  color: _C.accent, size: 16),
            ],
          ),
        ],
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════════════
// ── Trust Badges ────────────────────────────────────────────────────
// ══════════════════════════════════════════════════════════════════════

class _TrustBadges extends StatelessWidget {
  const _TrustBadges();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: const [
        Expanded(child: _TrustBadge(
          icon: Icons.cancel_outlined,
          text: 'Jederzeit\nkündbar',
        )),
        SizedBox(width: 8),
        Expanded(child: _TrustBadge(
          icon: Icons.verified_user_outlined,
          text: 'Zufriedenheits\u00ADgarantie',
        )),
        SizedBox(width: 8),
        Expanded(child: _TrustBadge(
          icon: Icons.lock_outline_rounded,
          text: 'Sichere\nZahlung',
        )),
      ],
    );
  }
}

class _TrustBadge extends StatelessWidget {
  const _TrustBadge({required this.icon, required this.text});

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 8),
      decoration: BoxDecoration(
        color: _C.success.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: _C.success.withValues(alpha: 0.15),
          width: 0.5,
        ),
      ),
      child: Column(
        children: [
          Icon(icon, color: _C.success, size: 22),
          const SizedBox(height: 6),
          Text(
            text,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: _C.textSecondary,
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  height: 1.3,
                ),
          ),
        ],
      ),
    );
  }
}
