import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:url_launcher/url_launcher.dart';

import '../domain/pro_product.dart';

/// Result of a restore-purchases attempt.
enum RestoreResult { success, empty, error }

/// Manages store interactions: loading products, starting purchases, and
/// forwarding receipts to the backend for server-side verification.
class BillingService {
  BillingService({
    InAppPurchase? iap,
    FirebaseFunctions? functions,
  })  : _iap = iap ?? InAppPurchase.instance,
        _functions = functions ?? FirebaseFunctions.instance;

  final InAppPurchase _iap;
  final FirebaseFunctions _functions;

  StreamSubscription<List<PurchaseDetails>>? _subscription;

  /// Available products loaded from the store.
  final ValueNotifier<List<ProductDetails>> products =
      ValueNotifier<List<ProductDetails>>([]);

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

  // ── Lifecycle ──────────────────────────────────────────────────────

  /// Call once at app start (after Firebase init).
  Future<void> init() async {
    final available = await _iap.isAvailable();
    if (!available) {
      error.value = 'Store nicht verfügbar';
      return;
    }

    _subscription = _iap.purchaseStream.listen(
      _onPurchaseUpdate,
      onError: (Object e) {
        error.value = 'Kaufstream-Fehler: $e';
        purchasing.value = false;
      },
    );

    await loadProducts();
  }

  void dispose() {
    _restoreTimeout?.cancel();
    _subscription?.cancel();
    products.dispose();
    purchasing.dispose();
    restoring.dispose();
    error.dispose();
  }

  // ── Products ───────────────────────────────────────────────────────

  /// Opens the platform subscription management page.
  Future<void> openSubscriptionManagement() async {
    final Uri url;
    if (Platform.isIOS) {
      url = Uri.parse('https://apps.apple.com/account/subscriptions');
    } else {
      url = Uri.parse(
        'https://play.google.com/store/account/subscriptions',
      );
    }
    await launchUrl(url, mode: LaunchMode.externalApplication);
  }

  Future<void> loadProducts() async {
    final response = await _iap.queryProductDetails(ProProduct.allIds);
    if (response.notFoundIDs.isNotEmpty && kDebugMode) {
      debugPrint(
        '[BillingService] Products not found: ${response.notFoundIDs}',
      );
    }
    if (response.error != null) {
      error.value = response.error!.message;
      return;
    }

    // Sort: monthly first, then yearly.
    final sorted = response.productDetails.toList()
      ..sort((a, b) => a.rawPrice.compareTo(b.rawPrice));
    products.value = sorted;
  }

  // ── Purchase ───────────────────────────────────────────────────────

  /// Initiates a subscription purchase.
  Future<void> buy(ProductDetails product) async {
    error.value = null;
    purchasing.value = true;

    final purchaseParam = PurchaseParam(productDetails: product);

    try {
      final started = await _iap.buyNonConsumable(
        purchaseParam: purchaseParam,
      );
      if (!started) {
        purchasing.value = false;
        error.value = 'Kauf konnte nicht gestartet werden.';
      }
    } catch (e) {
      purchasing.value = false;
      error.value = 'Kauffehler: $e';
    }
  }

  /// Restores previous purchases (e.g. after re-install).
  Future<void> restorePurchases() async {
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

      await _functions.httpsCallable('verifyPurchase').call<dynamic>({
        'productId': purchase.productID,
        'purchaseToken': purchase.verificationData.serverVerificationData,
        'transactionId': purchase.purchaseID ?? '',
        'platform': platform,
      });

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
