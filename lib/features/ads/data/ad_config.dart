import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

/// Global ad configuration stored at `adConfig/global`.
class AdConfig {
  const AdConfig({
    this.adsEnabled = false,
    this.googleAdsEnabled = false,
    this.partnerAdsEnabled = false,
    this.adFrequency = 5,
    this.updatedAt,
  });

  final bool adsEnabled;
  final bool googleAdsEnabled;
  final bool partnerAdsEnabled;

  /// Show an ad every [adFrequency] list items.
  final int adFrequency;
  final DateTime? updatedAt;

  static AdConfig debugDefaults() => const AdConfig(
        adsEnabled: true,
        googleAdsEnabled: true,
        partnerAdsEnabled: true,
        adFrequency: 5,
      );

  factory AdConfig.fromFirestore(DocumentSnapshot<Map<String, dynamic>> doc) {
    final d = doc.data();
    if (d == null) {
      return kDebugMode ? debugDefaults() : const AdConfig();
    }
    return AdConfig(
      adsEnabled: d['adsEnabled'] as bool? ?? false,
      googleAdsEnabled: d['googleAdsEnabled'] as bool? ?? false,
      partnerAdsEnabled: d['partnerAdsEnabled'] as bool? ?? false,
      adFrequency: (d['adFrequency'] as num?)?.toInt() ?? 5,
      updatedAt: (d['updatedAt'] as Timestamp?)?.toDate(),
    );
  }

  Map<String, dynamic> toFirestore() => {
        'adsEnabled': adsEnabled,
        'googleAdsEnabled': googleAdsEnabled,
        'partnerAdsEnabled': partnerAdsEnabled,
        'adFrequency': adFrequency,
        'updatedAt': FieldValue.serverTimestamp(),
      };

  AdConfig copyWith({
    bool? adsEnabled,
    bool? googleAdsEnabled,
    bool? partnerAdsEnabled,
    int? adFrequency,
  }) {
    return AdConfig(
      adsEnabled: adsEnabled ?? this.adsEnabled,
      googleAdsEnabled: googleAdsEnabled ?? this.googleAdsEnabled,
      partnerAdsEnabled: partnerAdsEnabled ?? this.partnerAdsEnabled,
      adFrequency: adFrequency ?? this.adFrequency,
      updatedAt: updatedAt,
    );
  }
}
