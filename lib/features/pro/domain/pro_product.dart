/// Product IDs that match App Store Connect / Google Play Console.
abstract final class ProProduct {
  static const String monthlyId = 'einmonatproopbeg';
  static const String yearlyId = 'einjahrproopbeg';

  static const Set<String> allIds = {monthlyId, yearlyId};

  // ── RC Web Billing purchase links (web checkout) ──────────────────
  //
  // Create Web Purchase Links in RC Dashboard → Web → Create web purchase link.
  // Set via --dart-define when building for web, e.g.:
  //   flutter build web
  //     --dart-define=RC_WEB_API_KEY=rcb_pub_xxx
  //     --dart-define=RC_WEB_LINK_MONTHLY=https://pay.rev.cat/xxxxxx
  //     --dart-define=RC_WEB_LINK_YEARLY=https://pay.rev.cat/yyyyyy
  //
  // The current Firebase UID is appended automatically by BillingService:
  //   https://pay.rev.cat/<token>/<uid>?email=<email>
  static const String rcWebLinkMonthly = String.fromEnvironment(
    'RC_WEB_LINK_MONTHLY',
    defaultValue: '',
  );
  static const String rcWebLinkYearly = String.fromEnvironment(
    'RC_WEB_LINK_YEARLY',
    defaultValue: '',
  );

  /// Maps a consumer store product ID to an RC Web Purchase Link base URL.
  static String? rcWebLinkForProduct(String storeId) {
    if (storeId == monthlyId) return rcWebLinkMonthly.isEmpty ? null : rcWebLinkMonthly;
    if (storeId == yearlyId) return rcWebLinkYearly.isEmpty ? null : rcWebLinkYearly;
    return null;
  }

  // Fallback prices shown when the store has not responded yet.
  static const double monthlyPrice = 8.99;
  static const double yearlyPrice = 75.00;
  static const String monthlyPriceDisplay = '8,99\u00a0€';
  static const String yearlyPriceDisplay = '75,00\u00a0€';
  static const int savingsPercent = 30;

  // ── Org / Arzt Pro products ────────────────────────────────────────
  static const String orgMonthlyId = 'org_pro_monthly';
  static const String orgYearlyId = 'org_pro_yearly';

  static const Set<String> orgAllIds = {orgMonthlyId, orgYearlyId};

  static const double orgMonthlyPrice = 19.99;
  static const String orgMonthlyPriceDisplay = '19,99\u00a0€';
  static const double orgYearlyPrice = 149.99;
  static const String orgYearlyPriceDisplay = '149,99\u00a0€';
  /// Savings compared to 12 × monthly (12 × 19.99 = 239.88 → 149.99 ≈ 37 %).
  static const int orgSavingsPercent = 37;

  // ── RC Web Billing purchase links (Org web checkout) ──────────────
  static const String rcWebLinkOrgMonthly = String.fromEnvironment(
    'RC_WEB_LINK_ORG_MONTHLY',
    defaultValue: '',
  );
  static const String rcWebLinkOrgYearly = String.fromEnvironment(
    'RC_WEB_LINK_ORG_YEARLY',
    defaultValue: '',
  );

  /// Maps an Org store product ID to an RC Web Purchase Link base URL.
  static String? rcWebLinkForOrgProduct(String storeId) {
    if (storeId == orgMonthlyId) return rcWebLinkOrgMonthly.isEmpty ? null : rcWebLinkOrgMonthly;
    if (storeId == orgYearlyId) return rcWebLinkOrgYearly.isEmpty ? null : rcWebLinkOrgYearly;
    return null;
  }
}
