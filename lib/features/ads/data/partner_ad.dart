import 'package:cloud_firestore/cloud_firestore.dart';

/// A partner advertisement stored in `partnerAds/{adId}`.
class PartnerAd {
  const PartnerAd({
    required this.id,
    required this.title,
    required this.imageUrl,
    required this.linkUrl,
    this.isActive = true,
    this.displayOrder = 0,
    this.createdAt,
  });

  final String id;
  final String title;
  final String imageUrl;
  final String linkUrl;
  final bool isActive;
  final int displayOrder;
  final DateTime? createdAt;

  factory PartnerAd.fromFirestore(DocumentSnapshot<Map<String, dynamic>> doc) {
    final d = doc.data()!;
    return PartnerAd(
      id: doc.id,
      title: d['title'] as String? ?? '',
      imageUrl: d['imageUrl'] as String? ?? '',
      linkUrl: d['linkUrl'] as String? ?? '',
      isActive: d['isActive'] as bool? ?? true,
      displayOrder: (d['displayOrder'] as num?)?.toInt() ?? 0,
      createdAt: (d['createdAt'] as Timestamp?)?.toDate(),
    );
  }

  Map<String, dynamic> toFirestore() => {
        'title': title,
        'imageUrl': imageUrl,
        'linkUrl': linkUrl,
        'isActive': isActive,
        'displayOrder': displayOrder,
        'createdAt': FieldValue.serverTimestamp(),
      };
}
