import 'dart:async';
import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:purchases_flutter/purchases_flutter.dart';
import 'package:purchases_ui_flutter/purchases_ui_flutter.dart';
import 'package:url_launcher/url_launcher.dart';

import '../domain/pro_product.dart';
import 'revenuecat_config.dart';

/// Result of a restore-purchases attempt.
enum RestoreResult { success, empty, error }

/// Lightweight product wrapper so paywall screens keep a familiar API.
class RcProduct {
  const RcProduct({
    required this.id,
    required this.price,
    required this.rawPrice,
    required this.currencyCode,
    required this.package,
  });

  /// Store product identifier (e.g. `einmonatproopbeg`).
  final String id;

  /// Localised price string (e.g. `8,99 €`).
  final String price;

  /// Raw numeric price.
  final double rawPrice;

  /// ISO 4217 currency code (e.g. `EUR`).
  final String currencyCode;

  /// RevenueCat package – needed for purchasing.
  final Package package;

  /// Best-effort currency symbol derived from [currencyCode].
  String get currencySymbol {
    return switch (currencyCode) {
      'EUR' => '€',
      'USD' || 'AUD' || 'CAD' => '\$',
      'GBP' => '£',
      'CHF' => 'CHF',
      'JPY' => '¥',
      _ => currencyCode,
    };
  }
}

/// Manages store interactions via RevenueCat: loading products (offerings),
/// starting purchases, restoring purchases.
///
/// RevenueCat handles receipt validation automatically – no Cloud Functions
/// needed for purchase verification.
class BillingService {
  BillingService._();

  factory BillingService.enabled() => BillingService._();

  factory BillingService.disabledBackend() => BillingService._();

  /// Available products loaded from RevenueCat offerings.
  final ValueNotifier<List<RcProduct>> products =
      ValueNotifier<List<RcProduct>>([]);

  /// Organisation products loaded separately.
  final ValueNotifier<List<RcProduct>> orgProducts =
      ValueNotifier<List<RcProduct>>([]);

  /// `true` while product metadata is loaded from RevenueCat.
  final ValueNotifier<bool> productsLoading = ValueNotifier<bool>(false);

  /// `true` when the platform store is reachable.
  final ValueNotifier<bool> storeAvailable = ValueNotifier<bool>(true);

  /// `true` while a purchase flow is running.
  final ValueNotifier<bool> purchasing = ValueNotifier<bool>(false);

  /// `true` while a restore is in progress.
  final ValueNotifier<bool> restoring = ValueNotifier<bool>(false);

  /// Last error message (if any).
  final ValueNotifier<String?> error = ValueNotifier<String?>(null);

  /// Called after a purchase has been successfully verified by RevenueCat.
  VoidCallback? onPurchaseVerified;

  /// Called when a restore attempt completes.
  ValueChanged<RestoreResult>? onRestoreComplete;

  bool _initialised = false;

  /// True only on iOS / Android (native store purchases supported).
  bool get _supportsStorePlatform => RevenueCatConfig.supportsNativePurchases;

  // ── RC Web Billing (web) ───────────────────────────────────────────

  /// Opens the RevenueCat Web Billing checkout for the given [productId].
  ///
  /// Resolves the correct Web Purchase Link from [ProProduct] and appends the
  /// current Firebase UID so the purchase is attributed to the signed-in user.
  /// The checkout is opened in a new browser tab; the user returns when done.
  Future<void> buyWeb(String productId) async {
    debugPrint('[BillingService] buyWeb($productId)');
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      error.value = 'Bitte melde dich zuerst an.';
      return;
    }
    final isOrgProduct = ProProduct.orgAllIds.contains(productId);
    final baseLink = isOrgProduct
        ? ProProduct.rcWebLinkForOrgProduct(productId)
        : ProProduct.rcWebLinkForProduct(productId);
    if (baseLink == null || baseLink.isEmpty) {
      error.value = 'Web-Checkout nicht konfiguriert.';
      return;
    }
    // Append the Firebase UID so the purchase is linked to this account.
    final uid = Uri.encodeComponent(user.uid);
    final email = user.email != null ? Uri.encodeComponent(user.email!) : null;
    final buffer = StringBuffer('$baseLink/$uid');
    if (email != null) buffer.write('?email=$email');
    final uri = Uri.parse(buffer.toString());
    await launchUrl(uri, mode: LaunchMode.externalApplication);
  }

  // ── Lifecycle ──────────────────────────────────────────────────────

  /// Call once at app start (after Firebase init).
  ///
  /// Configures the RevenueCat SDK and logs in the current Firebase user.
  Future<void> init() async {
    error.value = null;
    productsLoading.value = true;

    // ── Web platform: RC Web Billing ─────────────────────────────────
    if (kIsWeb) {
      storeAvailable.value = false;
      products.value = const <RcProduct>[];  // UI uses fallback prices on web
      productsLoading.value = false;
      final webKey = RevenueCatConfig.webApiKey;
      if (webKey.isNotEmpty && !_initialised) {
        try {
          await Purchases.setLogLevel(
              kDebugMode ? LogLevel.debug : LogLevel.info);
          final configuration = PurchasesConfiguration(webKey);
          await Purchases.configure(configuration);
          _initialised = true;
          if (kDebugMode) debugPrint('[BillingService] RC configured on web');
          await _loginCurrentUser();
          Purchases.addCustomerInfoUpdateListener(_onCustomerInfoUpdated);
        } catch (e) {
          if (kDebugMode) debugPrint('[BillingService] RC web init error: $e');
        }
      }
      return;
    }

    if (!_supportsStorePlatform) {
      storeAvailable.value = false;
      products.value = const <RcProduct>[];
      productsLoading.value = false;
      return;
    }

    final apiKey = RevenueCatConfig.apiKey;
    if (apiKey.isEmpty) {
      if (kDebugMode) {
        debugPrint('[BillingService] RevenueCat API key is empty!');
      }
      storeAvailable.value = false;
      productsLoading.value = false;
      return;
    }

    try {
      if (!_initialised) {
        await Purchases.setLogLevel(kDebugMode ? LogLevel.debug : LogLevel.info);
        final configuration = PurchasesConfiguration(apiKey);
        await Purchases.configure(configuration);
        _initialised = true;

        if (kDebugMode) {
          debugPrint('[BillingService] RevenueCat configured '
              'on ${Platform.operatingSystem}');
        }
      }

      // Log in the current Firebase user so subscriptions are linked.
      await _loginCurrentUser();

      // Listen for customer info updates (e.g. purchase verified).
      Purchases.addCustomerInfoUpdateListener(_onCustomerInfoUpdated);

      storeAvailable.value = true;
      await loadProducts();
    } catch (e) {
      if (kDebugMode) {
        debugPrint('[BillingService] RevenueCat init error: $e');
      }
      storeAvailable.value = false;
      productsLoading.value = false;
    }
  }

  /// Logs in the current Firebase user to RevenueCat.
  ///
  /// Must be called after Firebase auth sign-in and after RevenueCat is
  /// configured. Links the RevenueCat anonymous ID to the Firebase UID.
  Future<void> loginUser(String uid) async {
    if (!_initialised) return;
    try {
      final result = await Purchases.logIn(uid);
      if (kDebugMode) {
        debugPrint('[BillingService] RC logIn($uid) '
            'created=${result.created}');
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('[BillingService] RC logIn error: $e');
      }
    }
  }

  /// Logs out the current user from RevenueCat.
  Future<void> logoutUser() async {
    if (!_initialised) return;
    try {
      final isAnon = await Purchases.isAnonymous;
      if (!isAnon) {
        await Purchases.logOut();
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('[BillingService] RC logOut error: $e');
      }
    }
  }

  Future<void> _loginCurrentUser() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      await loginUser(user.uid);
    }
  }

  void dispose() {
    if (_initialised) {
      Purchases.removeCustomerInfoUpdateListener(_onCustomerInfoUpdated);
    }
    products.dispose();
    orgProducts.dispose();
    productsLoading.dispose();
    storeAvailable.dispose();
    purchasing.dispose();
    restoring.dispose();
    error.dispose();
  }

  // ── CustomerInfo listener ──────────────────────────────────────────

  void _onCustomerInfoUpdated(CustomerInfo info) {
    final hasPro = info.entitlements.all[RevenueCatConfig.proEntitlementId]
            ?.isActive ==
        true;
    final hasOrgPro =
        info.entitlements.all[RevenueCatConfig.orgProEntitlementId]
                ?.isActive ==
            true;
    if (hasPro || hasOrgPro) {
      onPurchaseVerified?.call();
    }
    if (kDebugMode) {
      debugPrint('[BillingService] CustomerInfo updated – '
          'pro=$hasPro orgPro=$hasOrgPro');
    }
  }

  // ── Products (Offerings) ───────────────────────────────────────────

  /// Opens the subscription management page.
  ///
  /// On web: uses the RC management URL from [CustomerInfo] if available.
  /// On iOS/Android: opens the platform subscription management page.
  Future<void> openSubscriptionManagement() async {
    if (!_initialised) return;
    try {
      final info = await Purchases.getCustomerInfo();
      final mgmtUrl = info.managementURL;
      if (mgmtUrl != null) {
        await launchUrl(Uri.parse(mgmtUrl),
            mode: LaunchMode.externalApplication);
        return;
      }
    } catch (_) {}
    if (kIsWeb) return; // No fallback URL on web
    // Fallback to generic platform URLs.
    final Uri url;
    if (Platform.isIOS) {
      url = Uri.parse('https://apps.apple.com/account/subscriptions');
    } else {
      url = Uri.parse('https://play.google.com/store/account/subscriptions');
    }
    await launchUrl(url, mode: LaunchMode.externalApplication);
  }

  Future<void> loadProducts() async {
    if (!_supportsStorePlatform) {
      productsLoading.value = false;
      return;
    }
    error.value = null;
    productsLoading.value = true;

    try {
      final offerings = await Purchases.getOfferings();

      if (kDebugMode) {
        debugPrint('[BillingService] Offerings loaded: '
            '${offerings.all.keys.toList()}');
      }

      // ── Consumer products (default offering) ──
      final defaultOffering = offerings.current;
      if (defaultOffering != null) {
        final consumerProducts = <RcProduct>[];
        for (final pkg in defaultOffering.availablePackages) {
          consumerProducts.add(_packageToProduct(pkg));
        }
        // Sort: monthly first (lower price), then yearly.
        consumerProducts.sort((a, b) => a.rawPrice.compareTo(b.rawPrice));
        products.value = consumerProducts;
      } else {
        products.value = const <RcProduct>[];
        if (kDebugMode) {
          debugPrint('[BillingService] No current offering found.');
        }
      }

      // ── Organisation products (named "org" offering) ──
      final orgOffering = offerings.all['org'];
      if (orgOffering != null) {
        final orgProds = <RcProduct>[];
        for (final pkg in orgOffering.availablePackages) {
          orgProds.add(_packageToProduct(pkg));
        }
        orgProds.sort((a, b) => a.rawPrice.compareTo(b.rawPrice));
        orgProducts.value = orgProds;
      }

      storeAvailable.value = true;

      if (products.value.isEmpty) {
        error.value =
            'Abo-Produkte nicht gefunden. Bitte versuche es später erneut.';
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('[BillingService] loadProducts error: $e');
      }
      products.value = const <RcProduct>[];
      error.value =
          'Produkte konnten nicht geladen werden. Bitte versuche es später erneut.';
    } finally {
      productsLoading.value = false;
    }
  }

  RcProduct _packageToProduct(Package pkg) {
    final sp = pkg.storeProduct;
    return RcProduct(
      id: sp.identifier,
      price: sp.priceString,
      rawPrice: sp.price,
      currencyCode: sp.currencyCode,
      package: pkg,
    );
  }

  // ── Purchase ───────────────────────────────────────────────────────

  /// Initiates a subscription purchase via RevenueCat.
  ///
  /// RevenueCat handles receipt validation automatically.
  Future<void> buy(RcProduct product) async {
    if (!_supportsStorePlatform) {
      error.value = 'Käufe sind auf dieser Plattform nicht verfügbar';
      return;
    }
    error.value = null;
    purchasing.value = true;

    try {
      final result = await Purchases.purchase(
        PurchaseParams.package(product.package),
      );

      final hasPro = result.customerInfo.entitlements
              .all[RevenueCatConfig.proEntitlementId]?.isActive ==
          true;
      final hasOrgPro = result.customerInfo.entitlements
              .all[RevenueCatConfig.orgProEntitlementId]?.isActive ==
          true;

      if (hasPro || hasOrgPro) {
        onPurchaseVerified?.call();
      }
    } on PlatformException catch (e) {
      final errorCode = PurchasesErrorHelper.getErrorCode(e);
      if (errorCode == PurchasesErrorCode.purchaseCancelledError) {
        // User cancelled – silent.
        if (kDebugMode) {
          debugPrint('[BillingService] Purchase cancelled by user.');
        }
      } else {
        if (kDebugMode) {
          debugPrint('[BillingService] Purchase error: $errorCode – $e');
        }
        error.value = _errorMessage(errorCode);
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('[BillingService] Purchase error: $e');
      }
      error.value = 'Kauf fehlgeschlagen. Bitte versuche es erneut.';
    } finally {
      purchasing.value = false;
    }
  }

  /// Restores previous purchases via RevenueCat.
  Future<void> restorePurchases() async {
    if (!_supportsStorePlatform) {
      error.value = 'Wiederherstellen ist auf dieser Plattform nicht verfügbar';
      onRestoreComplete?.call(RestoreResult.error);
      return;
    }
    error.value = null;
    purchasing.value = true;
    restoring.value = true;

    try {
      final customerInfo = await Purchases.restorePurchases();
      final hasPro = customerInfo.entitlements
              .all[RevenueCatConfig.proEntitlementId]?.isActive ==
          true;
      final hasOrgPro = customerInfo.entitlements
              .all[RevenueCatConfig.orgProEntitlementId]?.isActive ==
          true;

      if (hasPro || hasOrgPro) {
        onPurchaseVerified?.call();
        onRestoreComplete?.call(RestoreResult.success);
      } else {
        onRestoreComplete?.call(RestoreResult.empty);
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('[BillingService] Restore error: $e');
      }
      error.value = 'Wiederherstellen fehlgeschlagen: $e';
      onRestoreComplete?.call(RestoreResult.error);
    } finally {
      purchasing.value = false;
      restoring.value = false;
    }
  }

  // ── Entitlement check via RevenueCat ───────────────────────────────

  /// Checks whether the current user has an active Pro entitlement
  /// according to RevenueCat.
  Future<bool> checkProEntitlement() async {
    if (!_initialised) return false;
    try {
      final info = await Purchases.getCustomerInfo();
      return info.entitlements.all[RevenueCatConfig.proEntitlementId]
              ?.isActive ==
          true;
    } catch (e) {
      if (kDebugMode) {
        debugPrint('[BillingService] checkProEntitlement error: $e');
      }
      return false;
    }
  }

  // ── Error mapping ──────────────────────────────────────────────────

  String _errorMessage(PurchasesErrorCode code) {
    return switch (code) {
      PurchasesErrorCode.purchaseNotAllowedError =>
        'Zahlung nicht erlaubt. Bitte prüfe deine Zahlungseinstellungen.',
      PurchasesErrorCode.purchaseInvalidError =>
        'Ungültiger Kauf. Bitte versuche es erneut.',
      PurchasesErrorCode.productNotAvailableForPurchaseError =>
        'Dieses Produkt ist in deiner Region nicht verfügbar.',
      PurchasesErrorCode.networkError =>
        'Netzwerkfehler. Bitte prüfe deine Internetverbindung.',
      PurchasesErrorCode.storeProblemError =>
        'Verbindung zum Store fehlgeschlagen. Bitte versuche es später erneut.',
      PurchasesErrorCode.paymentPendingError =>
        'Zahlung wird verarbeitet. Bitte warte einen Moment.',
      _ => 'Kauf fehlgeschlagen. Bitte versuche es erneut.',
    };
  }

  // ── RevenueCat Paywall (remote UI) ─────────────────────────────────

  /// Presents the RevenueCat-hosted paywall configured in the dashboard.
  ///
  /// Returns the [PaywallResult] so callers can react to purchase/restore.
  Future<PaywallResult> presentPaywall() async {
    return RevenueCatUI.presentPaywall();
  }

  /// Presents the paywall only if the user does NOT have the Pro entitlement.
  ///
  /// Wraps [RevenueCatUI.presentPaywallIfNeeded] with the configured
  /// entitlement identifier.
  Future<PaywallResult> presentPaywallIfNeeded() async {
    return RevenueCatUI.presentPaywallIfNeeded(
      RevenueCatConfig.proEntitlementId,
    );
  }

  // ── RevenueCat Customer Center ─────────────────────────────────────

  /// Opens the RevenueCat Customer Center self-service UI.
  ///
  /// Allows subscribers to manage their subscription, cancel, restore,
  /// and contact support – all configured remotely in the RC dashboard.
  Future<void> presentCustomerCenter() async {
    if (!RevenueCatConfig.supportsNativePurchases) return;
    await RevenueCatUI.presentCustomerCenter();
  }
}
