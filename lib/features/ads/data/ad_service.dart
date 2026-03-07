import 'dart:async';
import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';

import 'ad_config.dart';
import 'partner_ad.dart';

/// Manages ad configuration and partner ads via Firestore.
class AdService {
  AdService({FirebaseFirestore? firestore, FirebaseStorage? storage})
    : _firestore = firestore,
      _storage = storage;

  factory AdService.enabled() {
    return AdService(
      firestore: FirebaseFirestore.instance,
      storage: FirebaseStorage.instance,
    );
  }

  factory AdService.disabled() {
    return AdService();
  }

  final FirebaseFirestore? _firestore;
  final FirebaseStorage? _storage;

  final ValueNotifier<AdConfig> config = ValueNotifier(const AdConfig());
  final ValueNotifier<List<PartnerAd>> partnerAds = ValueNotifier([]);

  StreamSubscription<DocumentSnapshot<Map<String, dynamic>>>? _configSub;
  StreamSubscription<QuerySnapshot<Map<String, dynamic>>>? _adsSub;

  final _random = Random();

  // ── Lifecycle ────────────────────────────────────────────────────

  void init() {
    final firestore = _firestore;
    if (firestore == null) return;
    _configSub = firestore
        .doc('adConfig/global')
        .snapshots()
        .listen(_onConfig, onError: _onError);

    _adsSub = firestore
        .collection('partnerAds')
        .where('isActive', isEqualTo: true)
        .orderBy('displayOrder')
        .snapshots()
        .listen(_onAds, onError: _onError);
  }

  void dispose() {
    _configSub?.cancel();
    _adsSub?.cancel();
    config.dispose();
    partnerAds.dispose();
  }

  void _onConfig(DocumentSnapshot<Map<String, dynamic>> snap) {
    config.value = AdConfig.fromFirestore(snap);
  }

  void _onAds(QuerySnapshot<Map<String, dynamic>> snap) {
    partnerAds.value = snap.docs
        .map((d) => PartnerAd.fromFirestore(d))
        .toList();
  }

  void _onError(Object error) {
    if (kDebugMode) debugPrint('[AdService] Stream error: $error');
  }

  // ── Convenience ──────────────────────────────────────────────────

  /// Whether ads should be displayed (globally enabled and at least one
  /// source active).
  bool get shouldShowAds =>
      config.value.adsEnabled &&
      (config.value.googleAdsEnabled || config.value.partnerAdsEnabled);

  /// Pick a random active partner ad for display.
  PartnerAd? randomPartnerAd() {
    final ads = partnerAds.value;
    if (ads.isEmpty) return null;
    return ads[_random.nextInt(ads.length)];
  }

  // ── Admin: Config CRUD ───────────────────────────────────────────

  Future<void> updateConfig(AdConfig newConfig) {
    final firestore = _firestore;
    if (firestore == null) return Future.value();
    return firestore
        .doc('adConfig/global')
        .set(newConfig.toFirestore(), SetOptions(merge: true));
  }

  // ── Admin: Partner ad CRUD ───────────────────────────────────────

  /// Stream all partner ads (including inactive) for admin UI.
  Stream<List<PartnerAd>> allPartnerAdsStream() {
    final firestore = _firestore;
    if (firestore == null) return const Stream<List<PartnerAd>>.empty();
    return firestore
        .collection('partnerAds')
        .orderBy('displayOrder')
        .snapshots()
        .map(
          (snap) => snap.docs.map((d) => PartnerAd.fromFirestore(d)).toList(),
        );
  }

  Future<String> createPartnerAd({
    required String title,
    required String imageUrl,
    required String linkUrl,
    int displayOrder = 0,
  }) async {
    final firestore = _firestore;
    if (firestore == null) return '';
    final ref = await firestore.collection('partnerAds').add({
      'title': title,
      'imageUrl': imageUrl,
      'linkUrl': linkUrl,
      'isActive': true,
      'displayOrder': displayOrder,
      'createdAt': FieldValue.serverTimestamp(),
    });
    return ref.id;
  }

  Future<void> togglePartnerAd(String adId, {required bool isActive}) {
    final firestore = _firestore;
    if (firestore == null) return Future.value();
    return firestore.doc('partnerAds/$adId').update({'isActive': isActive});
  }

  Future<void> deletePartnerAd(String adId) {
    final firestore = _firestore;
    if (firestore == null) return Future.value();
    return firestore.doc('partnerAds/$adId').delete();
  }

  // ── Image upload ─────────────────────────────────────────────────

  /// Upload ad image to Firebase Storage and return the download URL.
  Future<String> uploadAdImage(String adId, Uint8List bytes) async {
    final storage = _storage;
    if (storage == null) return '';
    final ref = storage.ref('ads/$adId/image');
    await ref.putData(bytes, SettableMetadata(contentType: 'image/jpeg'));
    return ref.getDownloadURL();
  }
}
