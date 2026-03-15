import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../ui/ui.dart';
import '../../../main.dart';
import '../data/ad_config.dart';
import '../data/ad_service.dart';
import '../data/partner_ad.dart';

/// Smart banner widget that shows either a Google AdMob banner, a partner ad,
/// or nothing — depending on the global [AdConfig] and the user's Pro status.
class AdBannerWidget extends StatefulWidget {
  const AdBannerWidget({super.key});

  @override
  State<AdBannerWidget> createState() => _AdBannerWidgetState();
}

class _AdBannerWidgetState extends State<AdBannerWidget> {
  BannerAd? _bannerAd;
  bool _isBannerLoaded = false;
  bool _googleAdFailed = false;

  static String get _adUnitId {
    if (kIsWeb) return '';
    if (Platform.isAndroid) {
      return 'ca-app-pub-3940256099942544/6300978111'; // Google test ID – Android production ID pending
    } else if (Platform.isIOS) {
      return 'ca-app-pub-6478508481705081/7538053827';
    }
    return '';
  }

  @override
  void dispose() {
    _disposeBannerAd();
    super.dispose();
  }

  void _disposeBannerAd() {
    _bannerAd?.dispose();
    _bannerAd = null;
    _isBannerLoaded = false;
  }

  void _loadBannerAd() {
    if (_bannerAd != null) return;
    _googleAdFailed = false;
    _bannerAd = BannerAd(
      adUnitId: _adUnitId,
      size: AdSize.banner,
      request: const AdRequest(),
      listener: BannerAdListener(
        onAdLoaded: (_) {
          if (mounted) setState(() => _isBannerLoaded = true);
        },
        onAdFailedToLoad: (ad, error) {
          if (kDebugMode) debugPrint('[AdBanner] Failed to load: $error');
          ad.dispose();
          _bannerAd = null;
          if (mounted) {
            setState(() {
              _googleAdFailed = true;
              _isBannerLoaded = false;
            });
          }
        },
      ),
    )..load();
  }

  @override
  Widget build(BuildContext context) {
    final proServices = ProServices.maybeOf(context);
    if (proServices == null) return const SizedBox.shrink();

    final isPro = proServices.entitlementService.isPro;
    if (isPro) {
      _disposeBannerAd();
      return const SizedBox.shrink();
    }

    final adService = AdServiceScope.maybeOf(context);
    if (adService == null) return const SizedBox.shrink();

    return ValueListenableBuilder<AdConfig>(
      valueListenable: adService.config,
      builder: (context, config, _) {
        if (!config.adsEnabled) {
          _disposeBannerAd();
          return const SizedBox.shrink();
        }

        final shouldTryGoogle =
            config.googleAdsEnabled && !kIsWeb && _adUnitId.isNotEmpty;

        if (shouldTryGoogle) {
          _loadBannerAd();
          if (_isBannerLoaded && _bannerAd != null) {
            return Container(
              alignment: Alignment.center,
              width: _bannerAd!.size.width.toDouble(),
              height: _bannerAd!.size.height.toDouble(),
              margin: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
              child: AdWidget(ad: _bannerAd!),
            );
          }
        } else {
          _disposeBannerAd();
        }

        if (config.partnerAdsEnabled &&
            (!shouldTryGoogle || _googleAdFailed || !_isBannerLoaded)) {
          final partnerAds = adService.partnerAds.value;
          if (partnerAds.isNotEmpty) {
            return _PartnerAdBanner(adService: adService);
          }
        }

        if (kDebugMode &&
            (config.googleAdsEnabled || config.partnerAdsEnabled)) {
          return const _DebugAdPreviewBanner();
        }

        return const SizedBox.shrink();
      },
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────

class _DebugAdPreviewBanner extends StatelessWidget {
  const _DebugAdPreviewBanner();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 80,
      margin: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.lg,
        vertical: AppSpacing.md,
      ),
      decoration: BoxDecoration(
        borderRadius: AppRadius.borderRadiusMd,
        gradient: const LinearGradient(
          colors: [Color(0xFF0055D4), Color(0xFF5AC8FA)],
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.18),
              borderRadius: AppRadius.borderRadiusSm,
            ),
            child: const Icon(
              Icons.campaign_rounded,
              color: Colors.white,
              size: 18,
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Testanzeige',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                SizedBox(height: 2),
                Text(
                  'Debug-Vorschau fuer Nicht-Pro-Nutzer, solange keine echte Bannerquelle verfuegbar ist.',
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 12,
                    height: 1.25,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(
              color: Colors.black26,
              borderRadius: BorderRadius.circular(4),
            ),
            child: const Text(
              'Anzeige',
              style: TextStyle(
                color: Colors.white,
                fontSize: 9,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────

class _PartnerAdBanner extends StatelessWidget {
  const _PartnerAdBanner({required this.adService});

  final AdService adService;

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<List<PartnerAd>>(
      valueListenable: adService.partnerAds,
      builder: (context, ads, _) {
        if (ads.isEmpty) return const SizedBox.shrink();

        final ad = adService.randomPartnerAd();
        if (ad == null) return const SizedBox.shrink();

        return Container(
          margin: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
          decoration: BoxDecoration(
            borderRadius: AppRadius.borderRadiusMd,
            border: Border.all(
              color: Theme.of(context).dividerColor.withValues(alpha: 0.15),
            ),
          ),
          child: Stack(
            children: [
              ClipRRect(
                borderRadius: AppRadius.borderRadiusMd,
                child: Image.network(
                  ad.imageUrl,
                  width: double.infinity,
                  height: 80,
                  fit: BoxFit.cover,
                  errorBuilder: (_, _, _) => const SizedBox(height: 80),
                ),
              ),
              Positioned.fill(
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    borderRadius: AppRadius.borderRadiusMd,
                    onTap: () => _openLink(ad.linkUrl),
                  ),
                ),
              ),
              Positioned(
                top: 4,
                right: 4,
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: Colors.black54,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: const Text(
                    'Anzeige',
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 9,
                      fontWeight: FontWeight.w500,
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

  Future<void> _openLink(String url) async {
    final uri = Uri.tryParse(url);
    if (uri == null) return;
    try {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } catch (_) {
      // URL could not be opened
    }
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// InheritedWidget to provide AdService down the tree.
// ─────────────────────────────────────────────────────────────────────────────

class AdServiceScope extends InheritedWidget {
  const AdServiceScope({
    super.key,
    required this.adService,
    required super.child,
  });

  final AdService adService;

  static AdService? maybeOf(BuildContext context) {
    return context
        .dependOnInheritedWidgetOfExactType<AdServiceScope>()
        ?.adService;
  }

  static AdService of(BuildContext context) {
    final result = maybeOf(context);
    assert(result != null, 'No AdServiceScope found in context');
    return result!;
  }

  @override
  bool updateShouldNotify(AdServiceScope oldWidget) =>
      adService != oldWidget.adService;
}
