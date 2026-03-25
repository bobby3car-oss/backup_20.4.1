import 'dart:async';
import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:url_launcher/url_launcher.dart';

import '../domain/pro_product.dart';
import 'paddle_checkout.dart' as paddle;

/// Result of a restore-purchases attempt.
enum RestoreResult { success, empty, error }

/// Manages store interactions: loading products, starting purchases, and
/// forwarding receipts to the backend for server-side verification.
class BillingService {
  BillingService({InAppPurchase? iap, FirebaseFunctions? functions})
    : _iap = iap ?? InAppPurchase.instance,
      _functions = functions;

  factory BillingService.enabled() {
    return BillingService(functions: FirebaseFunctions.instance);
  }

  factory BillingService.disabledBackend() {
    return BillingService();
  }

  final InAppPurchase _iap;
  final FirebaseFunctions? _functions;

  StreamSubscription<List<PurchaseDetails>>? _subscription;

  /// Available products loaded from the store.
  final ValueNotifier<List<ProductDetails>> products =
      ValueNotifier<List<ProductDetails>>([]);

  /// `true` while product metadata is loaded from the store.
  final ValueNotifier<bool> productsLoading = ValueNotifier<bool>(false);

  /// `true` when the platform store is reachable.
  final ValueNotifier<bool> storeAvailable = ValueNotifier<bool>(true);

  /// `true` while a purchase flow is running.
  final ValueNotifier<bool> purchasing = ValueNotifier<bool>(false);

  /// `true` while a restore is in progress.
  final ValueNotifier<bool> restoring = ValueNotifier<bool>(false);

  /// Last error message (if any).
  final ValueNotifier<String?> error = ValueNotifier<String?>(null);

  /// Called after a purchase has been successfully verified on the backend.
  VoidCallback? onPurchaseVerified;

  /// Called when a restore attempt completes.
  ValueChanged<RestoreResult>? onRestoreComplete;

  Timer? _restoreTimeout;

  bool get _supportsStorePlatform =>
      !kIsWeb && (Platform.isIOS || Platform.isAndroid);

  bool _paddleInitialised = false;

  /// Initialise Paddle.js on web (no-op on other platforms).
  void _ensurePaddleInit() {
    if (!kIsWeb || _paddleInitialised) return;
    if (ProProduct.paddleClientToken.isEmpty) {
      debugPrint('[BillingService] Paddle client token is empty!');
      return;
    }
    debugPrint('[BillingService] Initializing Paddle (token=${ProProduct.paddleClientToken.substring(0, 8)}…)');
    paddle.paddleInit(
      token: ProProduct.paddleClientToken,
      sandbox: ProProduct.paddleSandbox,
    );
    _paddleInitialised = true;

    // Verify prices exist in the environment.
    final monthly = ProProduct.paddleMonthlyPriceId;
    final yearly = ProProduct.paddleYearlyPriceId;
    if (monthly.isNotEmpty) paddle.paddleVerifyPrice(monthly);
    if (yearly.isNotEmpty) paddle.paddleVerifyPrice(yearly);
  }

  /// Opens a Paddle checkout overlay (web only).
  Future<void> buyWeb(String productId) async {
    debugPrint('[BillingService] buyWeb($productId)');
    final wasAlreadyInit = _paddleInitialised;
    _ensurePaddleInit();
    final priceId = ProProduct.paddlePriceId(productId);
    debugPrint('[BillingService] priceId=$priceId');
    if (priceId == null || priceId.isEmpty) {
      error.value = 'Paddle-Preis nicht konfiguriert.';
      return;
    }
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      error.value = 'Bitte melde dich zuerst an.';
      return;
    }
    // If Paddle was just initialised for the first time, give it a moment
    // to complete token verification before opening the checkout overlay.
    if (!wasAlreadyInit) {
      await Future<void>.delayed(const Duration(milliseconds: 800));
    }
    final diag = paddle.paddleDiag();
    debugPrint('[BillingService] Paddle diag: $diag');
    debugPrint('[BillingService] Opening Paddle checkout for ${user.uid}');
    paddle.paddleOpenCheckout(
      priceId: priceId,
      uid: user.uid,
      email: user.email,
    );
  }

  // ── Lifecycle ──────────────────────────────────────────────────────

  /// Call once at app start (after Firebase init).
  Future<void> init() async {
    error.value = null;
    productsLoading.value = true;
    if (!_supportsStorePlatform) {
      storeAvailable.value = false;
      products.value = const <ProductDetails>[];
      productsLoading.value = false;
      // Eagerly initialise Paddle on web so token verification completes
      // before the user taps "Buy" (avoids a race with Checkout.open).
      _ensurePaddleInit();
      return;
    }
    final available = await _iap.isAvailable();
    storeAvailable.value = available;
    if (kDebugMode) {
      debugPrint('[BillingService] Store available: $available, '
          'platform: ${Platform.operatingSystem}');
    }
    if (!available) {
      error.value = 'Store nicht verfügbar';
      productsLoading.value = false;
      return;
    }

    _subscription = _iap.purchaseStream.listen(
      _onPurchaseUpdate,
      onError: (Object e) {
        error.value = 'Kauf konnte nicht verarbeitet werden. Bitte versuche es erneut.';
        purchasing.value = false;
      },
    );

    await loadProducts();
  }

  void dispose() {
    _restoreTimeout?.cancel();
    _subscription?.cancel();
    products.dispose();
    productsLoading.dispose();
    storeAvailable.dispose();
    purchasing.dispose();
    restoring.dispose();
    error.dispose();
  }

  // ── Products ───────────────────────────────────────────────────────

  /// Opens the platform subscription management page.
  Future<void> openSubscriptionManagement() async {
    if (!_supportsStorePlatform) return;
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

    // If init() bailed early (isAvailable returned false), re-check now and
    // set up the purchase-stream subscription so purchases are processed.
    if (_subscription == null) {
      final available = await _iap.isAvailable();
      storeAvailable.value = available;
      if (kDebugMode) {
        debugPrint('[BillingService] Re-checked availability: $available');
      }
      if (!available) {
        error.value = 'Store nicht verfügbar. Bitte prüfe deine Netzwerkverbindung.';
        productsLoading.value = false;
        return;
      }
      _subscription = _iap.purchaseStream.listen(
        _onPurchaseUpdate,
        onError: (Object e) {
          error.value =
              'Kauf konnte nicht verarbeitet werden. Bitte versuche es erneut.';
          purchasing.value = false;
        },
      );
    }

    try {
      for (var attempt = 1; attempt <= 3; attempt++) {
        try {
          if (kDebugMode) {
            debugPrint(
              '[BillingService] queryProductDetails attempt $attempt '
              'for IDs: ${ProProduct.allIds}',
            );
          }
          final response = await _iap.queryProductDetails(ProProduct.allIds);
          storeAvailable.value = true;

          if (kDebugMode) {
            debugPrint(
              '[BillingService] Response: '
              '${response.productDetails.length} products, '
              '${response.notFoundIDs.length} not found, '
              'error: ${response.error?.message}',
            );
          }

          if (response.notFoundIDs.isNotEmpty && kDebugMode) {
            debugPrint(
              '[BillingService] Products not found (attempt $attempt): '
              '${response.notFoundIDs}',
            );
          }
          if (response.error != null) {
            if (attempt < 3) {
              await Future<void>.delayed(const Duration(seconds: 1));
              continue;
            }
            products.value = const <ProductDetails>[];
            error.value = response.error!.message;
            return;
          }

          // Sort: monthly first, then yearly.
          final sorted = response.productDetails.toList()
            ..sort((a, b) => a.rawPrice.compareTo(b.rawPrice));
          products.value = sorted;

          if (sorted.isEmpty && attempt < 3) {
            await Future<void>.delayed(const Duration(seconds: 1));
            continue;
          }
          if (sorted.isEmpty) {
            if (kDebugMode) {
              debugPrint(
                '[BillingService] No products found after $attempt attempts. '
                'NotFoundIDs were: ${response.notFoundIDs}',
              );
            }
            error.value = 'Abo-Produkte nicht gefunden. Prüfe die Produktkonfiguration im App Store.';
          }
          return;
        } catch (e) {
          if (attempt < 3) {
            if (kDebugMode) {
              debugPrint('[BillingService] Load attempt $attempt failed: $e');
            }
            await Future<void>.delayed(const Duration(seconds: 1));
            continue;
          }
          products.value = const <ProductDetails>[];
          error.value = 'Produkte konnten nicht geladen werden. Bitte versuche es später erneut.';
        }
      }
    } finally {
      productsLoading.value = false;
    }
  }

  // ── Purchase ───────────────────────────────────────────────────────

  /// Initiates a subscription purchase.
  Future<void> buy(ProductDetails product) async {
    if (!_supportsStorePlatform) {
      error.value = 'Käufe sind auf dieser Plattform nicht verfügbar';
      return;
    }
    error.value = null;
    purchasing.value = true;

    final purchaseParam = PurchaseParam(productDetails: product);

    try {
      final started = await _iap.buyNonConsumable(purchaseParam: purchaseParam);
      if (!started) {
        purchasing.value = false;
        error.value = 'Kauf konnte nicht gestartet werden.';
      }
    } catch (e, st) {
      purchasing.value = false;
      if (kDebugMode) {
        debugPrint('[BillingService] Buy error: $e');
        debugPrint('[BillingService] Stack trace: $st');
      }
      final msg = e.toString();
      if (msg.contains('storekit') || msg.contains('StoreKit') ||
          msg.contains('SKError') || msg.contains('failed to respond')) {
        error.value =
            'Verbindung zum App Store fehlgeschlagen. '
            'Bitte prüfe deine Internetverbindung und versuche es erneut.';
      } else {
        error.value = 'Kauf fehlgeschlagen. Bitte versuche es erneut.';
      }
    }
  }

  /// Restores previous purchases (e.g. after re-install).
  Future<void> restorePurchases() async {
    if (!_supportsStorePlatform) {
      error.value = 'Wiederherstellen ist auf dieser Plattform nicht verfügbar';
      onRestoreComplete?.call(RestoreResult.error);
      return;
    }
    error.value = null;
    purchasing.value = true;
    restoring.value = true;
    _restoreTimeout?.cancel();

    try {
      await _iap.restorePurchases();

      // If no restored purchases arrive within 30 s, assume none exist.
      _restoreTimeout = Timer(const Duration(seconds: 30), () {
        if (restoring.value) {
          restoring.value = false;
          purchasing.value = false;
          onRestoreComplete?.call(RestoreResult.empty);
        }
      });
    } catch (e) {
      error.value = 'Wiederherstellen fehlgeschlagen: $e';
      purchasing.value = false;
      restoring.value = false;
      onRestoreComplete?.call(RestoreResult.error);
    }
  }

  // ── Purchase Stream Handler ────────────────────────────────────────

  Future<void> _onPurchaseUpdate(List<PurchaseDetails> purchases) async {
    for (final purchase in purchases) {
      switch (purchase.status) {
        case PurchaseStatus.pending:
          purchasing.value = true;
          break;

        case PurchaseStatus.purchased:
        case PurchaseStatus.restored:
          await _verifyAndFinish(purchase);
          break;

        case PurchaseStatus.error:
          error.value = purchase.error?.message ?? 'Unbekannter Fehler';
          purchasing.value = false;
          if (purchase.pendingCompletePurchase) {
            await _iap.completePurchase(purchase);
          }
          break;

        case PurchaseStatus.canceled:
          purchasing.value = false;
          if (purchase.pendingCompletePurchase) {
            await _iap.completePurchase(purchase);
          }
          break;
      }
    }
  }

  /// Sends receipt to Cloud Function for server-side verification,
  /// then completes the purchase.
  Future<void> _verifyAndFinish(PurchaseDetails purchase) async {
    try {
      final platform = Platform.isIOS ? 'ios' : 'android';

      final functions = _functions;
      if (functions != null) {
        await functions.httpsCallable('verifyPurchase').call<dynamic>({
          'productId': purchase.productID,
          'purchaseToken': purchase.verificationData.serverVerificationData,
          'transactionId': purchase.purchaseID ?? '',
          'platform': platform,
        });
      }

      onPurchaseVerified?.call();

      // If this was a restore, signal success and clear restore state.
      if (purchase.status == PurchaseStatus.restored) {
        _restoreTimeout?.cancel();
        restoring.value = false;
        onRestoreComplete?.call(RestoreResult.success);
      }
    } catch (e) {
      error.value = 'Verifizierung fehlgeschlagen: $e';
      if (kDebugMode) {
        debugPrint('[BillingService] Verification error: $e');
      }
      if (purchase.status == PurchaseStatus.restored) {
        _restoreTimeout?.cancel();
        restoring.value = false;
        onRestoreComplete?.call(RestoreResult.error);
      }
    } finally {
      if (purchase.pendingCompletePurchase) {
        await _iap.completePurchase(purchase);
      }
      purchasing.value = false;
    }
  }
}
