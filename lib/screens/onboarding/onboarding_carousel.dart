import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../l10n/app_localizations.dart';
import '../../ui/ui.dart';
import 'auth_slide.dart';
import 'language_slide.dart';
import 'onboarding_data.dart';
import 'onboarding_slide.dart';
import 'widgets/parallax_background.dart';

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
      backgroundColor: const Color(0xFFF0F1F7),
      body: Stack(
        children: [
          // ── Parallax gradient background ────────────────────────
          ParallaxSlideBackground(
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
                      color: Colors.black.withValues(alpha: 0.04),
                      borderRadius: AppRadius.borderRadiusPill,
                      border: Border.all(
                        color: Colors.black.withValues(alpha: 0.06),
                        width: 0.5,
                      ),
                    ),
                    child: Text(
                      l.onboardingSkip,
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ),
                ),
              ),
            ),

          // ── Bottom bar: progress bar + next button ──────────────
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

    final featureCount = totalPages - 2; // exclude language + auth
    final featureIdx = (currentPage - 1).clamp(0, featureCount - 1);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xxl),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // ── Dot indicators ─────────────────────────────────
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(featureCount, (i) {
              final isActive = i == featureIdx;
              return AnimatedContainer(
                duration: MotionDuration.medium,
                curve: MotionCurve.standard,
                margin: const EdgeInsets.symmetric(horizontal: 4),
                width: isActive ? 24 : 8,
                height: 8,
                decoration: BoxDecoration(
                  color: isActive
                      ? AppColors.primary
                      : AppColors.primary.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(4),
                ),
              );
            }),
          ),
          const SizedBox(height: AppSpacing.xl),

          // ── Full-width CTA button ──────────────────────────
          PressableScale(
            onTap: () {
              Haptic.light();
              if (isLastFeature) {
                onSkip();
              } else {
                onNext();
              }
            },
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: AppSpacing.lg),
              decoration: BoxDecoration(
                gradient: AppColors.primaryGradient,
                borderRadius: AppRadius.borderRadiusPill,
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primary.withValues(alpha: 0.35),
                    blurRadius: 20,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Text(
                isLastFeature
                    ? l.onboardingGetStarted
                    : l.onboardingNext,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                  letterSpacing: -0.2,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
