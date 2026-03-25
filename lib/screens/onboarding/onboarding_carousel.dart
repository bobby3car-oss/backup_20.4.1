import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

import '../../l10n/app_localizations.dart';
import '../../ui/ui.dart';
import 'auth_slide.dart';
import 'language_slide.dart';
import 'onboarding_data.dart';
import 'onboarding_slide.dart';

/// Key used in [SharedPreferences] to remember whether the user
/// has already seen the feature onboarding slides.
const kOnboardingSeenKey = 'onboarding_seen';

/// Full-screen onboarding carousel shown on first app launch.
///
/// Contains 5 feature slides + 1 auth slide (login/register).
/// When [skipToAuth] is true, only the auth slide is shown
/// (used for returning unauthenticated users).
class OnboardingCarousel extends StatefulWidget {
  const OnboardingCarousel({
    super.key,
    this.skipToAuth = false,
    this.onSkipAsGuest,
  });

  /// If true, skip feature slides and show the auth slide directly.
  final bool skipToAuth;

  /// Called when the user chooses to use the app without an account.
  final VoidCallback? onSkipAsGuest;

  @override
  State<OnboardingCarousel> createState() => _OnboardingCarouselState();
}

class _OnboardingCarouselState extends State<OnboardingCarousel>
    with SingleTickerProviderStateMixin {
  late final PageController _pageCtrl;
  int _currentPage = 0;
  // language slide (1) + feature slides + auth slide (1)
  final int _totalPages = 1 + onboardingSlidesCount + 1;

  // Parallax background offset
  late final AnimationController _bgAnimCtrl;

  @override
  void initState() {
    super.initState();
    // When skipToAuth, jump past language + feature slides to auth
    final initialPage =
        widget.skipToAuth ? 1 + onboardingSlidesCount : 0;
    _currentPage = initialPage;
    _pageCtrl = PageController(initialPage: initialPage);
    _bgAnimCtrl = AnimationController(
      vsync: this,
      duration: Duration.zero,
    );
  }

  @override
  void dispose() {
    _pageCtrl.dispose();
    _bgAnimCtrl.dispose();
    super.dispose();
  }

  bool get _isLanguageSlide => _currentPage == 0;
  bool get _isAuthSlide => _currentPage == 1 + onboardingSlidesCount;
  bool get _isLastFeatureSlide =>
      _currentPage == onboardingSlidesCount; // last feature = index slides.length

  void _onPageChanged(int page) {
    Haptic.selection();
    setState(() => _currentPage = page);
  }

  void _goNext() {
    if (_currentPage < _totalPages - 1) {
      _pageCtrl.nextPage(
        duration: MotionDuration.slow,
        curve: MotionCurve.standard,
      );
    }
  }

  Future<void> _skipToAuth() async {
    await _markOnboardingSeen();
    _pageCtrl.animateToPage(
      1 + onboardingSlidesCount,
      duration: MotionDuration.slow,
      curve: MotionCurve.standard,
    );
  }

  Future<void> _markOnboardingSeen() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(kOnboardingSeenKey, true);
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final slides = getOnboardingSlides(l);
    return Scaffold(
      backgroundColor: const Color(0xFFF2F2F7),
      body: Stack(
        children: [
          // ── Animated dark gradient background ────────────────────
          _AnimatedBackground(
            pageCtrl: _pageCtrl,
            totalPages: _totalPages,
          ),

          // ── Page view ───────────────────────────────────────────
          PageView.builder(
            controller: _pageCtrl,
            onPageChanged: _onPageChanged,
            itemCount: _totalPages,
            physics: _isLanguageSlide
                ? const NeverScrollableScrollPhysics()
                : const BouncingScrollPhysics(),
            itemBuilder: (context, index) {
              // Page 0: Language selection
              if (index == 0) {
                return LanguageSlide(
                  onLanguageSelected: _goNext,
                );
              }
              // Pages 1..N: Feature slides
              final featureIndex = index - 1;
              if (featureIndex < slides.length) {
                return OnboardingSlide(
                  data: slides[featureIndex],
                  isActive: _currentPage == index,
                );
              }
              // Last page: Auth slide
              return AuthSlide(
                onSkipAsGuest: widget.onSkipAsGuest,
              );
            },
          ),

          // ── Skip button (top right) ─────────────────────────────
          if (!_isAuthSlide && !_isLanguageSlide)
            Positioned(
              top: MediaQuery.of(context).padding.top + AppSpacing.lg,
              right: AppSpacing.xl,
              child: FadeSlideIn(
                child: PressableScale(
                  onTap: _skipToAuth,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.lg,
                      vertical: AppSpacing.sm,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.05),
                      borderRadius: AppRadius.borderRadiusPill,
                      border: Border.all(
                        color: Colors.black.withValues(alpha: 0.08),
                        width: 0.5,
                      ),
                    ),
                    child: Text(
                      l.onboardingSkip,
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ),
                ),
              ),
            ),

          // ── Bottom bar: indicator + next button ─────────────────
          if (!_isAuthSlide && !_isLanguageSlide)
            Positioned(
              left: 0,
              right: 0,
              bottom: MediaQuery.of(context).padding.bottom + AppSpacing.xxl,
              child: _BottomBar(
                pageCtrl: _pageCtrl,
                totalPages: _totalPages,
                currentPage: _currentPage,
                isLastFeature: _isLastFeatureSlide,
                onNext: _goNext,
                onSkip: _skipToAuth,
              ),
            ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────

/// Renders the dark gradient background with a subtle parallax shift
/// and accent color blending based on the current page position.
class _AnimatedBackground extends StatelessWidget {
  const _AnimatedBackground({
    required this.pageCtrl,
    required this.totalPages,
  });

  final PageController pageCtrl;
  final int totalPages;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: pageCtrl,
      builder: (context, _) {
        final page = pageCtrl.hasClients && pageCtrl.page != null
            ? pageCtrl.page!
            : 0.0;

        // Determine accent color from current/next slide
        // Page 0 is language slide, so offset by 1 for feature slides
        Color accent = const Color(0xFF007AFF);
        final featurePage = (page - 1).clamp(0.0, onboardingSlidesCount.toDouble());
        final idx = featurePage.floor().clamp(0, onboardingSlidesCount - 1);
        final nextIdx = (idx + 1).clamp(0, onboardingSlidesCount - 1);
        final t = featurePage - featurePage.floor();

        if (idx < onboardingSlidesCount && nextIdx < onboardingSlidesCount) {
          accent = Color.lerp(
            onboardingSlideColors[idx],
            onboardingSlideColors[nextIdx],
            t,
          )!;
        }

        // Subtle parallax for the glow spot
        final offset = (page - totalPages / 2) * 40;

        return Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Color(0xFFF2F2F7),
                Color(0xFFE8EBF4),
                Color(0xFFF2F2F7),
              ],
              stops: [0.0, 0.5, 1.0],
            ),
          ),
          child: Stack(
            children: [
              // Ambient glow
              Positioned(
                top: -80,
                left: MediaQuery.of(context).size.width / 2 - 150 + offset,
                child: Container(
                  width: 300,
                  height: 300,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(
                      colors: [
                        accent.withValues(alpha: 0.08),
                        accent.withValues(alpha: 0.0),
                      ],
                    ),
                  ),
                ),
              ),
              // Bottom glow
              Positioned(
                bottom: -120,
                left: MediaQuery.of(context).size.width / 2 - 200 - offset * 0.5,
                child: Container(
                  width: 400,
                  height: 400,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(
                      colors: [
                        accent.withValues(alpha: 0.05),
                        accent.withValues(alpha: 0.0),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────

class _BottomBar extends StatelessWidget {
  const _BottomBar({
    required this.pageCtrl,
    required this.totalPages,
    required this.currentPage,
    required this.isLastFeature,
    required this.onNext,
    required this.onSkip,
  });

  final PageController pageCtrl;
  final int totalPages;
  final int currentPage;
  final bool isLastFeature;
  final VoidCallback onNext;
  final VoidCallback onSkip;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xxl),
      child: Row(
        children: [
          // ── Page indicator ────────────────────────────────────
          SmoothPageIndicator(
            controller: pageCtrl,
            count: totalPages,
            effect: ExpandingDotsEffect(
              activeDotColor: AppColors.primary,
              dotColor: AppColors.primary.withValues(alpha: 0.2),
              dotHeight: 8,
              dotWidth: 8,
              expansionFactor: 3,
              spacing: 6,
            ),
          ),
          const Spacer(),

          // ── Next / Get started button ────────────────────────
          PressableScale(
            onTap: isLastFeature ? onSkip : onNext,
            child: Container(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.xl,
                vertical: AppSpacing.md,
              ),
              decoration: BoxDecoration(
                gradient: AppColors.primaryGradient,
                borderRadius: AppRadius.borderRadiusPill,
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primary.withValues(alpha: 0.4),
                    blurRadius: 16,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    isLastFeature ? l.onboardingGetStarted : l.onboardingNext,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                      letterSpacing: -0.1,
                    ),
                  ),
                  const SizedBox(width: AppSpacing.xs),
                  const Icon(
                    Icons.arrow_forward_rounded,
                    size: 18,
                    color: Colors.white,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
