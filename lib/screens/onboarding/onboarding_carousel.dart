import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

import '../../ui/ui.dart';
import 'auth_slide.dart';
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
  final int _totalPages = onboardingSlides.length + 1; // +1 for auth slide

  // Parallax background offset
  late final AnimationController _bgAnimCtrl;

  @override
  void initState() {
    super.initState();
    final initialPage = widget.skipToAuth ? onboardingSlides.length : 0;
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

  bool get _isAuthSlide => _currentPage == onboardingSlides.length;
  bool get _isLastFeatureSlide => _currentPage == onboardingSlides.length - 1;

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
      onboardingSlides.length,
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
    return Scaffold(
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
            physics: const BouncingScrollPhysics(),
            itemBuilder: (context, index) {
              if (index < onboardingSlides.length) {
                return OnboardingSlide(
                  data: onboardingSlides[index],
                  isActive: _currentPage == index,
                );
              }
              return AuthSlide(
                onSkipAsGuest: widget.onSkipAsGuest,
              );
            },
          ),

          // ── Skip button (top right) ─────────────────────────────
          if (!_isAuthSlide)
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
                      'Überspringen',
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
          if (!_isAuthSlide)
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
        Color accent = const Color(0xFF007AFF);
        final idx = page.floor().clamp(0, onboardingSlides.length - 1);
        final nextIdx = (idx + 1).clamp(0, onboardingSlides.length - 1);
        final t = page - page.floor();

        if (idx < onboardingSlides.length && nextIdx < onboardingSlides.length) {
          accent = Color.lerp(
            onboardingSlides[idx].accentColor,
            onboardingSlides[nextIdx].accentColor,
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
                    isLastFeature ? 'Los geht\'s' : 'Weiter',
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
