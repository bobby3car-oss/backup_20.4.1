import 'package:cloud_firestore/cloud_firestore.dart';

/// Represents the Pro entitlement state from Firestore.
///
/// Reads flat fields from `users/{uid}`:
///   isPro, proSince, proExpiresAt, proProductId, proPlatform,
///   proSource, lastReceiptValidationAt
class Entitlement {
  const Entitlement({
    required this.isPro,
    this.proSince,
    this.proExpiresAt,
    this.proProductId,
    this.proPlatform,
    this.proSource,
    this.lastReceiptValidationAt,
  });

  final bool isPro;
  final DateTime? proSince;
  final DateTime? proExpiresAt;
  final String? proProductId;
  final String? proPlatform;
  /// "key" when activated via Pro key, null for store subscriptions.
  final String? proSource;
  final DateTime? lastReceiptValidationAt;

  factory Entitlement.free() => const Entitlement(isPro: false);

  factory Entitlement.fromFirestore(Map<String, dynamic> data) {
    final isPro = data['isPro'] as bool? ?? false;

    return Entitlement(
      isPro: isPro,
      proSince: _toDateTime(data['proSince']),
      proExpiresAt: _toDateTime(data['proExpiresAt']),
      proProductId: data['proProductId'] as String?,
      proPlatform: data['proPlatform'] as String?,
      proSource: data['proSource'] as String?,
      lastReceiptValidationAt:
          _toDateTime(data['lastReceiptValidationAt']),
    );
  }

  /// Converts Firestore Timestamp or ISO string to DateTime.
  static DateTime? _toDateTime(Object? value) {
    if (value == null) return null;
    // cloud_firestore returns Timestamp objects on the client.
    if (value is Timestamp) return value.toDate();
    if (value is String) return DateTime.tryParse(value);
    return null;
  }
}
