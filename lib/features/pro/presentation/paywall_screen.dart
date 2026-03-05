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

// ── Dark palette ─────────────────────────────────────────────────────

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
    _billing.purchasing.removeListener(_rebuild);
    _billing.restoring.removeListener(_rebuild);
    _billing.error.removeListener(_showError);
    _billing.onRestoreComplete = null;
    _entitlement.entitlement.removeListener(_onEntitlementChanged);
    super.dispose();
  }

  void _rebuild() => setState(() {});

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

  void _buySelected() {
    HapticFeedback.mediumImpact();
    final products = _billing.products.value;
    final product = products.cast<ProductDetails?>().firstWhere(
          (p) => p!.id == _selectedId,
          orElse: () => null,
        );
    if (product != null) {
      _analytics.purchaseStarted(plan: _selectedId, price: product.price);
      _billing.buy(product);
    }
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
                    child: products.isEmpty
                        ? const _LoadingProducts()
                        : SingleChildScrollView(
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
                                const SizedBox(height: 40),

                                // 2 ── Story section
                                _StaggerEntry(
                                  animation: _entranceCtrl,
                                  delay: 0.10,
                                  child: _StorySection(
                                      text: _storyText),
                                ),
                                const SizedBox(height: 36),

                                // 3 ── Feature pills
                                _StaggerEntry(
                                  animation: _entranceCtrl,
                                  delay: 0.20,
                                  child: const _FeaturePills(),
                                ),
                                const SizedBox(height: 36),

                                // 4 ── Social proof
                                _StaggerEntry(
                                  animation: _entranceCtrl,
                                  delay: 0.30,
                                  child: const _SocialProofStrip(),
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
                                      const SizedBox(height: 16),
                                      if (yearly != null)
                                        _PlanCard(
                                          product: yearly,
                                          title: 'Jährlich',
                                          subtitle:
                                              'nur ${_monthlyEquivalent(yearly)} / Monat',
                                          badge: _config.showSavings
                                              ? 'BEST VALUE'
                                              : null,
                                          selected:
                                              _selectedId ==
                                              ProProduct.yearlyId,
                                          emphasized: true,
                                          onTap: () => _selectPlan(
                                              ProProduct.yearlyId,
                                              yearly),
                                        ),
                                      const SizedBox(height: 12),
                                      if (monthly != null)
                                        _PlanCard(
                                          product: monthly,
                                          title: 'Monatlich',
                                          subtitle: 'monatlich kündbar',
                                          selected:
                                              _selectedId ==
                                              ProProduct.monthlyId,
                                          onTap: () => _selectPlan(
                                              ProProduct.monthlyId,
                                              monthly),
                                        ),
                                    ],
                                  ),
                                ),
                                const SizedBox(height: 24),

                                // 6 ── CTA
                                _StaggerEntry(
                                  animation: _entranceCtrl,
                                  delay: 0.50,
                                  child: _GlowCTA(
                                    label: _selectedId ==
                                            ProProduct.yearlyId
                                        ? '1 Jahr Pro sichern'
                                        : 'Pro starten',
                                    loading: loading,
                                    onPressed:
                                        loading ? null : _buySelected,
                                  ),
                                ),
                                const SizedBox(height: 20),

                                // 7 ── Footer
                                _FooterLinks(
                                  restoring: _billing.restoring.value,
                                  onRestore: loading
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

  void _selectPlan(String id, ProductDetails product) {
    setState(() => _selectedId = id);
    _analytics.planSelected(plan: id, price: product.price);
    HapticFeedback.lightImpact();
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
        const Text('💙', style: TextStyle(fontSize: 56)),
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
// ── 3. Feature pills ────────────────────────────────────────────────
// ══════════════════════════════════════════════════════════════════════

class _FeaturePills extends StatelessWidget {
  const _FeaturePills();

  static const _features = <(String, String)>[
    ('👨‍👩‍👧', 'Angehörige einladen'),
    ('🎙️', 'Sprach\u00ADnotizen'),
    ('📸', 'Unbegrenzt Fotos'),
    ('📄', 'Unbegrenzt Dokumente'),
    ('📊', 'Fortschritts\u00ADtracking'),
    ('🚨', 'Red-Flag Warnung'),
    ('📋', 'Arztbericht Export'),
  ];

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      alignment: WrapAlignment.center,
      children: _features.map((f) {
        return Container(
          padding:
              const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          decoration: BoxDecoration(
            color: _C.card,
            borderRadius: BorderRadius.circular(40),
            border: Border.all(color: _C.border, width: 0.5),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(f.$1, style: const TextStyle(fontSize: 16)),
              const SizedBox(width: 6),
              Text(
                f.$2,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: _C.textPrimary,
                      fontWeight: FontWeight.w600,
                    ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }
}

// ══════════════════════════════════════════════════════════════════════
// ── 4. Social proof strip ───────────────────────────────────────────
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
      child: Row(
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
          Flexible(
            child: Text(
              'Von Patienten für Patienten entwickelt',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: _C.textSecondary,
                    fontWeight: FontWeight.w500,
                  ),
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

class _PlanCard extends StatefulWidget {
  const _PlanCard({
    required this.product,
    required this.title,
    required this.subtitle,
    required this.selected,
    required this.onTap,
    this.badge,
    this.emphasized = false,
  });

  final ProductDetails product;
  final String title;
  final String subtitle;
  final bool selected;
  final bool emphasized;
  final String? badge;
  final VoidCallback onTap;

  @override
  State<_PlanCard> createState() => _PlanCardState();
}

class _PlanCardState extends State<_PlanCard>
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
      TweenSequenceItem(tween: Tween(begin: 1.04, end: 0.97), weight: 30),
      TweenSequenceItem(tween: Tween(begin: 0.97, end: 1.0), weight: 40),
    ]).animate(
        CurvedAnimation(parent: _bounceCtrl, curve: Curves.easeOutCubic));
  }

  @override
  void didUpdateWidget(_PlanCard old) {
    super.didUpdateWidget(old);
    if (widget.selected && !old.selected) {
      _bounceCtrl.forward(from: 0);
    }
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
                    )
                  ]
                : null,
          ),
          child: Row(
            children: [
              // Radio dot
              _RadioDot(selected: sel),
              const SizedBox(width: 14),
              // Text
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
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              widget.badge!,
                              style: const TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w800,
                                color: Colors.black,
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
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: _C.textSecondary,
                          ),
                    ),
                  ],
                ),
              ),
              // Price
              Text(
                widget.product.price,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
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
            '24 h vor Ablauf gekündigt wird.',
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
// ── Loading spinner ─────────────────────────────────────────────────
// ══════════════════════════════════════════════════════════════════════

class _LoadingProducts extends StatelessWidget {
  const _LoadingProducts();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          CircularProgressIndicator(color: _C.accent),
          SizedBox(height: 16),
          Text(
            'Lade Preise\u2026',
            style: TextStyle(color: _C.textSecondary),
          ),
        ],
      ),
    );
  }
}
