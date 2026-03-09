/// Product IDs that match App Store Connect / Google Play Console.
abstract final class ProProduct {
  static const String monthlyId = 'einmonatproopbeg';
  static const String yearlyId = 'einjahrproopbeg';

  static const Set<String> allIds = {monthlyId, yearlyId};
}
