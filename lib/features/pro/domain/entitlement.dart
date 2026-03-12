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

  /// Whether the Pro entitlement is currently active (not expired).
  bool get isActive {
    if (!isPro) return false;
    // No expiry date means lifetime / admin-granted.
    if (proExpiresAt == null) return true;
    return proExpiresAt!.isAfter(DateTime.now());
  }

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

  /// Deserializes from a JSON map (used for offline cache).
  factory Entitlement.fromJson(Map<String, dynamic> json) {
    return Entitlement(
      isPro: json['isPro'] as bool? ?? false,
      proSince: json['proSince'] != null
          ? DateTime.tryParse(json['proSince'] as String)
          : null,
      proExpiresAt: json['proExpiresAt'] != null
          ? DateTime.tryParse(json['proExpiresAt'] as String)
          : null,
      proProductId: json['proProductId'] as String?,
      proPlatform: json['proPlatform'] as String?,
      proSource: json['proSource'] as String?,
      lastReceiptValidationAt: json['lastReceiptValidationAt'] != null
          ? DateTime.tryParse(json['lastReceiptValidationAt'] as String)
          : null,
    );
  }

  /// Serializes to a JSON map (used for offline cache).
  Map<String, dynamic> toJson() => {
        'isPro': isPro,
        if (proSince != null) 'proSince': proSince!.toIso8601String(),
        if (proExpiresAt != null)
          'proExpiresAt': proExpiresAt!.toIso8601String(),
        if (proProductId != null) 'proProductId': proProductId,
        if (proPlatform != null) 'proPlatform': proPlatform,
        if (proSource != null) 'proSource': proSource,
        if (lastReceiptValidationAt != null)
          'lastReceiptValidationAt':
              lastReceiptValidationAt!.toIso8601String(),
      };

  /// Converts Firestore Timestamp or ISO string to DateTime.
  static DateTime? _toDateTime(Object? value) {
    if (value == null) return null;
    // cloud_firestore returns Timestamp objects on the client.
    if (value is Timestamp) return value.toDate();
    if (value is String) return DateTime.tryParse(value);
    return null;
  }
}
