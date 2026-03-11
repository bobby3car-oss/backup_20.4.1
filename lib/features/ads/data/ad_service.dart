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

  final ValueNotifier<AdConfig> config = ValueNotifier(
    kDebugMode ? AdConfig.debugDefaults() : const AdConfig(),
  );
  final ValueNotifier<List<PartnerAd>> partnerAds = ValueNotifier([]);

  StreamSubscription<DocumentSnapshot<Map<String, dynamic>>>? _configSub;
  StreamSubscription<QuerySnapshot<Map<String, dynamic>>>? _adsSub;
  bool _configEnsureStarted = false;

  final _random = Random();

  // ── Lifecycle ────────────────────────────────────────────────────

  void init() {
    final firestore = _firestore;
    if (firestore == null) return;
    if (_configSub != null || _adsSub != null) return;
    if (kDebugMode && !_configEnsureStarted) {
      _configEnsureStarted = true;
      unawaited(_ensureDebugConfigDocument());
    }
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
    _configSub = null;
    _adsSub = null;
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

  Future<void> _ensureDebugConfigDocument() async {
    final firestore = _firestore;
    if (firestore == null) return;

    try {
      final ref = firestore.doc('adConfig/global');
      final snap = await ref.get();
      if (snap.exists && snap.data() != null) return;

      await ref.set(AdConfig.debugDefaults().toFirestore());

      if (kDebugMode) {
        debugPrint('[AdService] Seeded debug ad config at adConfig/global');
      }
    } catch (error) {
      if (kDebugMode) {
        debugPrint('[AdService] Failed to seed debug ad config: $error');
      }
    }
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
    String? adId,
  }) async {
    final firestore = _firestore;
    if (firestore == null) return '';
    final ref = adId == null
        ? firestore.collection('partnerAds').doc()
        : firestore.collection('partnerAds').doc(adId);
    await ref.set({
      'title': title,
      'imageUrl': imageUrl,
      'linkUrl': linkUrl,
      'isActive': true,
      'displayOrder': displayOrder,
      'createdAt': FieldValue.serverTimestamp(),
    });
    return ref.id;
  }

  Future<String> createPartnerAdWithImage({
    required String title,
    required String linkUrl,
    required int displayOrder,
    Uint8List? imageBytes,
  }) async {
    final firestore = _firestore;
    if (firestore == null) return '';

    final ref = firestore.collection('partnerAds').doc();
    var imageUrl = '';

    try {
      if (imageBytes != null) {
        imageUrl = await uploadAdImage(ref.id, imageBytes);
      }

      await createPartnerAd(
        adId: ref.id,
        title: title,
        imageUrl: imageUrl,
        linkUrl: linkUrl,
        displayOrder: displayOrder,
      );
      return ref.id;
    } catch (_) {
      if (imageUrl.isNotEmpty) {
        await deleteAdImage(ref.id);
      }
      rethrow;
    }
  }

  Future<void> togglePartnerAd(String adId, {required bool isActive}) {
    final firestore = _firestore;
    if (firestore == null) return Future.value();
    return firestore.doc('partnerAds/$adId').update({'isActive': isActive});
  }

  Future<void> deletePartnerAd(String adId) {
    final firestore = _firestore;
    if (firestore == null) return Future.value();
    return firestore.doc('partnerAds/$adId').delete().whenComplete(() {
      return deleteAdImage(adId);
    });
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

  Future<void> deleteAdImage(String adId) async {
    final storage = _storage;
    if (storage == null) return;
    try {
      await storage.ref('ads/$adId/image').delete();
    } catch (error) {
      if (kDebugMode) {
        debugPrint('[AdService] Image cleanup skipped for $adId: $error');
      }
    }
  }
}
