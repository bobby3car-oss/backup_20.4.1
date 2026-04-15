import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'privacy_consent_service.dart';

/// GDPR-compliant cookie consent banner for Flutter Web.
///
/// Shown once on first visit. Persists the user's choice in SharedPreferences
/// (which maps to localStorage on web). Integrates with [PrivacyConsentService]
/// to enable/disable Firebase Analytics based on the user's decision.
///
/// Only renders on [kIsWeb]. On native platforms this widget is transparent.
class WebCookieConsentBanner extends StatefulWidget {
  const WebCookieConsentBanner({super.key, required this.child});

  final Widget child;

  @override
  State<WebCookieConsentBanner> createState() =>
      _WebCookieConsentBannerState();
}

class _WebCookieConsentBannerState extends State<WebCookieConsentBanner>
    with SingleTickerProviderStateMixin {
  static const _prefKey = 'web_cookie_consent_v1';

  bool _showBanner = false;
  late final AnimationController _controller;
  late final Animation<double> _slideAnim;
  late final Animation<double> _fadeAnim;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 350),
    );
    _slideAnim = Tween<double>(begin: 80, end: 0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic),
    );
    _fadeAnim = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOut),
    );

    if (kIsWeb) {
      _checkConsent();
    }
  }

  Future<void> _checkConsent() async {
    final prefs = await SharedPreferences.getInstance();
    final alreadyChosen = prefs.containsKey(_prefKey);
    if (!alreadyChosen && mounted) {
      // Brief delay so it doesn't pop up before the splash screen fades
      await Future<void>.delayed(const Duration(milliseconds: 800));
      if (mounted) {
        setState(() => _showBanner = true);
        _controller.forward();
      }
    }
  }

  Future<void> _acceptAll() async {
    await _saveCookieConsent(analyticsEnabled: true);
    await PrivacyConsentService.instance.setAnalyticsEnabled(true);
    await _dismiss();
  }

  Future<void> _acceptNecessaryOnly() async {
    await _saveCookieConsent(analyticsEnabled: false);
    await PrivacyConsentService.instance.setAnalyticsEnabled(false);
    await _dismiss();
  }

  Future<void> _saveCookieConsent({required bool analyticsEnabled}) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      _prefKey,
      analyticsEnabled ? 'all' : 'necessary',
    );
  }

  Future<void> _dismiss() async {
    await _controller.reverse();
    if (mounted) setState(() => _showBanner = false);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!kIsWeb || !_showBanner) return widget.child;

    final theme = Theme.of(context);
    final isNarrow = MediaQuery.sizeOf(context).width < 600;

    return Stack(
      fit: StackFit.expand,
      children: [
        widget.child,
        Positioned(
          left: 0,
          right: 0,
          bottom: 0,
          child: AnimatedBuilder(
            animation: _controller,
            builder: (context, child) => Opacity(
              opacity: _fadeAnim.value,
              child: Transform.translate(
                offset: Offset(0, _slideAnim.value),
                child: child,
              ),
            ),
            child: _CookieBannerContent(
              isNarrow: isNarrow,
              theme: theme,
              onAcceptAll: _acceptAll,
              onNecessaryOnly: _acceptNecessaryOnly,
            ),
          ),
        ),
      ],
    );
  }
}

class _CookieBannerContent extends StatelessWidget {
  const _CookieBannerContent({
    required this.isNarrow,
    required this.theme,
    required this.onAcceptAll,
    required this.onNecessaryOnly,
  });

  final bool isNarrow;
  final ThemeData theme;
  final VoidCallback onAcceptAll;
  final VoidCallback onNecessaryOnly;

  @override
  Widget build(BuildContext context) {
    return Material(
      elevation: 12,
      shadowColor: Colors.black26,
      child: Container(
        decoration: const BoxDecoration(
          color: Color(0xFFF9F9FB),
          border: Border(
            top: BorderSide(color: Color(0xFFE5E5EA), width: 1),
          ),
        ),
        child: SafeArea(
          top: false,
          child: Padding(
            padding: EdgeInsets.symmetric(
              horizontal: isNarrow ? 16 : 24,
              vertical: 16,
            ),
            child: isNarrow
                ? _NarrowLayout(
                    theme: theme,
                    onAcceptAll: onAcceptAll,
                    onNecessaryOnly: onNecessaryOnly,
                  )
                : _WideLayout(
                    theme: theme,
                    onAcceptAll: onAcceptAll,
                    onNecessaryOnly: onNecessaryOnly,
                  ),
          ),
        ),
      ),
    );
  }
}

class _NarrowLayout extends StatelessWidget {
  const _NarrowLayout({
    required this.theme,
    required this.onAcceptAll,
    required this.onNecessaryOnly,
  });

  final ThemeData theme;
  final VoidCallback onAcceptAll;
  final VoidCallback onNecessaryOnly;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _BannerText(theme: theme),
        const SizedBox(height: 12),
        _BannerButtons(
          onAcceptAll: onAcceptAll,
          onNecessaryOnly: onNecessaryOnly,
          isNarrow: true,
        ),
      ],
    );
  }
}

class _WideLayout extends StatelessWidget {
  const _WideLayout({
    required this.theme,
    required this.onAcceptAll,
    required this.onNecessaryOnly,
  });

  final ThemeData theme;
  final VoidCallback onAcceptAll;
  final VoidCallback onNecessaryOnly;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Expanded(child: _BannerText(theme: theme)),
        const SizedBox(width: 24),
        _BannerButtons(
          onAcceptAll: onAcceptAll,
          onNecessaryOnly: onNecessaryOnly,
          isNarrow: false,
        ),
      ],
    );
  }
}

class _BannerText extends StatelessWidget {
  const _BannerText({required this.theme});

  final ThemeData theme;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          children: [
            const Icon(
              Icons.cookie_outlined,
              size: 18,
              color: Color(0xFF007AFF),
            ),
            const SizedBox(width: 6),
            Text(
              'Cookies & Datenschutz',
              style: theme.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w600,
                color: const Color(0xFF1C1C1E),
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          'Wir verwenden notwendige Cookies für die App-Funktion (Authentifizierung) sowie optionale Analyse-Cookies (Firebase Analytics) '
          'zur Verbesserung der App. Gemäß DSGVO Art. 6(1)(a) benötigen wir Ihre Zustimmung für optionale Cookies.',
          style: theme.textTheme.bodySmall?.copyWith(
            color: const Color(0xFF6D6D72),
            height: 1.45,
          ),
        ),
      ],
    );
  }
}

class _BannerButtons extends StatelessWidget {
  const _BannerButtons({
    required this.onAcceptAll,
    required this.onNecessaryOnly,
    required this.isNarrow,
  });

  final VoidCallback onAcceptAll;
  final VoidCallback onNecessaryOnly;
  final bool isNarrow;

  @override
  Widget build(BuildContext context) {
    final buttons = [
      SizedBox(
        width: isNarrow ? double.infinity : null,
        child: OutlinedButton(
          onPressed: onNecessaryOnly,
          style: OutlinedButton.styleFrom(
            foregroundColor: const Color(0xFF6D6D72),
            side: const BorderSide(color: Color(0xFFD1D1D6)),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
          child: const Text(
            'Nur notwendige',
            style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
          ),
        ),
      ),
      SizedBox(
        width: isNarrow ? double.infinity : null,
        child: FilledButton(
          onPressed: onAcceptAll,
          style: FilledButton.styleFrom(
            backgroundColor: const Color(0xFF007AFF),
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
          child: const Text(
            'Alle akzeptieren',
            style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
          ),
        ),
      ),
    ];

    if (isNarrow) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          buttons[1],
          const SizedBox(height: 8),
          buttons[0],
        ],
      );
    }

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        buttons[0],
        const SizedBox(width: 8),
        buttons[1],
      ],
    );
  }
}
