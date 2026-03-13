/// Product IDs that match App Store Connect / Google Play Console.
abstract final class ProProduct {
  static const String monthlyId = 'einmonatproopbeg';
  static const String yearlyId = 'einjahrproopbeg';

  static const Set<String> allIds = {monthlyId, yearlyId};

  // ── Paddle Billing price IDs (web checkout) ───────────────────────
  // Set via --dart-define when building for web, e.g.:
  //   flutter build web --dart-define=PADDLE_PRICE_MONTHLY=pri_xxx
  //                      --dart-define=PADDLE_PRICE_YEARLY=pri_yyy
  //                      --dart-define=PADDLE_CLIENT_TOKEN=test_xxx
  //                      --dart-define=PADDLE_SANDBOX=true
  static const String paddleMonthlyPriceId = String.fromEnvironment(
    'PADDLE_PRICE_MONTHLY',
    defaultValue: '',
  );
  static const String paddleYearlyPriceId = String.fromEnvironment(
    'PADDLE_PRICE_YEARLY',
    defaultValue: '',
  );
  static const String paddleClientToken = String.fromEnvironment(
    'PADDLE_CLIENT_TOKEN',
    defaultValue: '',
  );
  static const bool paddleSandbox = bool.fromEnvironment(
    'PADDLE_SANDBOX',
    defaultValue: true,
  );

  /// Maps a store product ID to a Paddle price ID.
  static String? paddlePriceId(String storeId) {
    if (storeId == monthlyId) return paddleMonthlyPriceId;
    if (storeId == yearlyId) return paddleYearlyPriceId;
    return null;
  }

  // Fallback prices shown when the store has not responded yet.
  static const double monthlyPrice = 8.99;
  static const double yearlyPrice = 75.00;
  static const String monthlyPriceDisplay = '8,99\u00a0€';
  static const String yearlyPriceDisplay = '75,00\u00a0€';
  static const int savingsPercent = 30;
}
