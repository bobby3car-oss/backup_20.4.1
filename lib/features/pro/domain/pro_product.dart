/// Product IDs that match App Store Connect / Google Play Console.
abstract final class ProProduct {
  static const String monthlyId = 'einmonatproopbeg';
  static const String yearlyId = 'einjahrproopbeg';

  static const Set<String> allIds = {monthlyId, yearlyId};

  // Fallback prices shown when the store has not responded yet.
  static const double monthlyPrice = 8.99;
  static const double yearlyPrice = 75.00;
  static const String monthlyPriceDisplay = '8,99\u00a0€';
  static const String yearlyPriceDisplay = '75,00\u00a0€';
  static const int savingsPercent = 30;
}
