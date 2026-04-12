import 'dart:async';
import 'dart:io';

import 'package:cloud_functions/cloud_functions.dart';
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
    this.package,
    this.storeProduct,
  });

  /// Store product identifier (e.g. `einmonatproopbeg`).
  final String id;

  /// Localised price string (e.g. `8,99 €`).
  final String price;

  /// Raw numeric price.
  final double rawPrice;

  /// ISO 4217 currency code (e.g. `EUR`).
  final String currencyCode;

  /// RevenueCat package – needed for purchasing via offerings.
  /// Null when loaded via direct product ID fallback.
  final Package? package;

  /// Store product – used for purchasing when [package] is null.
  final StoreProduct? storeProduct;

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

  /// Whether the native RevenueCat SDK has been configured (static so it
  /// survives across BillingService instances and can be queried before an
  /// instance exists).
  static bool _sdkConfigured = false;

  /// In-flight configuration future so concurrent callers share the same work.
  static Future<void>? _configuringFuture;

  /// Whether the RevenueCat SDK has been configured and is safe to call.
  static bool get sdkConfigured => _sdkConfigured;

  /// True only on iOS / Android (native store purchases supported).
  bool get _supportsStorePlatform => RevenueCatConfig.supportsNativePurchases;

  /// Configures the RevenueCat SDK at the earliest possible moment.
  ///
  /// This is a **static** method so it can be called from [main] *before*
  /// any [BillingService] instance is created. The native SDK crashes with a
  /// Swift `fatalError` when any `Purchases.*` API is invoked before
  /// `configure()`, so this **must** run before [EntitlementService.init].
  ///
  /// Safe to call multiple times – concurrent/subsequent calls share the
  /// same Future so `Purchases.configure()` is never invoked twice.
  static Future<void> configureRevenueCatSdk() {
    return _configuringFuture ??= _doConfigureRevenueCatSdk();
  }

  static Future<void> _doConfigureRevenueCatSdk() async {
    if (_sdkConfigured) return;
    if (kIsWeb) {
      final webKey = RevenueCatConfig.webApiKey;
      if (webKey.isEmpty) return;
      try {
        await Purchases.configure(PurchasesConfiguration(webKey));
        // setLogLevel AFTER configure – the plugin routes through
        // Purchases.shared which crashes if called before configure.
        await Purchases.setLogLevel(
            kDebugMode ? LogLevel.debug : LogLevel.info);
        _sdkConfigured = true;
        if (kDebugMode) debugPrint('[BillingService] RC configured on web');
      } catch (e) {
        if (kDebugMode) {
          debugPrint('[BillingService] RC web configure error: $e');
        }
      }
      return;
    }
    if (!RevenueCatConfig.supportsNativePurchases) return;
    final apiKey = RevenueCatConfig.apiKey;
    if (apiKey.isEmpty) return;
    try {
      await Purchases.configure(PurchasesConfiguration(apiKey));
      // setLogLevel AFTER configure – see above.
      await Purchases.setLogLevel(kDebugMode ? LogLevel.debug : LogLevel.info);
      _sdkConfigured = true;
      if (kDebugMode) {
        debugPrint('[BillingService] RevenueCat configured '
            'on ${Platform.operatingSystem}');
      }
    } catch (e) {
      if (kDebugMode) debugPrint('[BillingService] RC configure error: $e');
    }
  }

  /// Configures the RevenueCat SDK without logging in or loading products.
  ///
  /// Must be called before any other code calls [Purchases] methods (e.g.
  /// `Purchases.logIn`). Safe to call multiple times – the SDK is only
  /// configured on the first invocation.
  Future<void> configureSdk() async {
    if (_initialised) return;
    // Delegate to the static implementation (idempotent).
    await configureRevenueCatSdk();
    if (_sdkConfigured) _initialised = true;
  }

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
          final configuration = PurchasesConfiguration(webKey);
          await Purchases.configure(configuration);
          await Purchases.setLogLevel(
              kDebugMode ? LogLevel.debug : LogLevel.info);
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
        // Await the shared configuration future – never calls
        // Purchases.configure() a second time concurrently.
        await configureRevenueCatSdk();
        if (_sdkConfigured) {
          _initialised = true;
        } else {
          // Configuration failed – bail out.
          storeAvailable.value = false;
          productsLoading.value = false;
          return;
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
      // ── Try RC offerings first ──
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
          consumerProducts.sort((a, b) => a.rawPrice.compareTo(b.rawPrice));
          products.value = consumerProducts;
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
      } catch (e) {
        if (kDebugMode) {
          debugPrint('[BillingService] getOfferings failed (will try direct): $e');
        }
      }

      // ── Fallback: load directly by product ID when offerings are empty ──
      // Covers the case where RC Dashboard offerings are not configured
      // but StoreKit products exist (e.g. StoreKit Testing on simulator).
      if (products.value.isEmpty) {
        await _loadProductsByIds(
          ProProduct.allIds.toList(),
          (loaded) => products.value = loaded,
          'consumer',
        );
      }
      if (orgProducts.value.isEmpty) {
        await _loadProductsByIds(
          ProProduct.orgAllIds.toList(),
          (loaded) => orgProducts.value = loaded,
          'org',
        );
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

  /// Loads store products directly by identifier (bypasses RC offerings).
  Future<void> _loadProductsByIds(
    List<String> ids,
    void Function(List<RcProduct>) setter,
    String label,
  ) async {
    try {
      final storeProducts = await Purchases.getProducts(ids);
      if (storeProducts.isNotEmpty) {
        final loaded = storeProducts.map((sp) {
          // Use the store-returned price when EUR, otherwise fall back to
          // hardcoded EUR values (StoreKit Testing / sandbox may return USD).
          final eurPrice = _eurFallbackPrice(sp.identifier);
          final useEur = sp.currencyCode != 'EUR' && eurPrice != null;
          return RcProduct(
            id: sp.identifier,
            price: useEur ? eurPrice.display : sp.priceString,
            rawPrice: useEur ? eurPrice.value : sp.price,
            currencyCode: useEur ? 'EUR' : sp.currencyCode,
            storeProduct: sp,
            package: null,
          );
        }).toList()
          ..sort((a, b) => a.rawPrice.compareTo(b.rawPrice));
        setter(loaded);
        if (kDebugMode) {
          debugPrint('[BillingService] $label products loaded by ID: '
              '${loaded.map((p) => '${p.id}=${p.price}').toList()}');
        }
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('[BillingService] $label getProducts fallback error: $e');
      }
    }
  }

  /// Returns hard-coded EUR price for a known product ID.
  static ({String display, double value})? _eurFallbackPrice(String id) {
    return switch (id) {
      ProProduct.monthlyId => (
        display: ProProduct.monthlyPriceDisplay,
        value: ProProduct.monthlyPrice,
      ),
      ProProduct.yearlyId => (
        display: ProProduct.yearlyPriceDisplay,
        value: ProProduct.yearlyPrice,
      ),
      ProProduct.orgMonthlyId => (
        display: ProProduct.orgMonthlyPriceDisplay,
        value: ProProduct.orgMonthlyPrice,
      ),
      ProProduct.orgYearlyId => (
        display: ProProduct.orgYearlyPriceDisplay,
        value: ProProduct.orgYearlyPrice,
      ),
      _ => null,
    };
  }

  RcProduct _packageToProduct(Package pkg) {
    final sp = pkg.storeProduct;
    return RcProduct(
      id: sp.identifier,
      price: sp.priceString,
      rawPrice: sp.price,
      currencyCode: sp.currencyCode,
      package: pkg,
      storeProduct: sp,
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
      final PurchaseResult result;
      if (product.package != null) {
        result = await Purchases.purchase(
          PurchaseParams.package(product.package!),
        );
      } else if (product.storeProduct != null) {
        result = await Purchases.purchase(
          PurchaseParams.storeProduct(product.storeProduct!),
        );
      } else {
        error.value = 'Produkt nicht verfügbar.';
        purchasing.value = false;
        return;
      }

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

  // ── Firestore sync after RevenueCat purchase ───────────────────────

  /// Calls the `confirmProPurchase` Cloud Function to persist the
  /// RevenueCat-confirmed entitlement to Firestore.
  ///
  /// [scope] is `"user"` for individual doctors/patients or
  /// `"organisation"` for organisation accounts.
  ///
  /// This is a best-effort operation: if it fails the user still has
  /// Pro via RevenueCat, but Firestore won't be updated until next
  /// re-verification run.
  Future<void> confirmPurchaseFirestore({String scope = 'user'}) async {
    try {
      final fn = FirebaseFunctions.instanceFor(region: 'europe-west1');
      await fn.httpsCallable('confirmProPurchase').call<void>({
        'scope': scope,
      });
      if (kDebugMode) {
        debugPrint('[BillingService] confirmPurchaseFirestore OK '
            '(scope=$scope)');
      }
    } catch (e) {
      // Best-effort – log but don't crash.
      if (kDebugMode) {
        debugPrint('[BillingService] confirmPurchaseFirestore error: $e');
      }
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
