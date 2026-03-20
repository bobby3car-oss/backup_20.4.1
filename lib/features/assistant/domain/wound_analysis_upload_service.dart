import 'dart:io';

import 'package:firebase_app_check/firebase_app_check.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';

/// Handles upload of wound photos to Firebase Storage for AI analysis
/// and cleanup after analysis is complete.
///
/// Attaches a valid App Check token to every upload for backend
/// verification.
class WoundAnalysisUploadService {
  WoundAnalysisUploadService._();
  static final instance = WoundAnalysisUploadService._();

  static const _basePath = 'woundAnalysis';

  /// Uploads local wound photos to Firebase Storage and returns
  /// download URLs that can be passed to the AI analysis endpoint.
  ///
  /// Photos are stored under `woundAnalysis/{uid}/{timestamp}.jpg`.
  Future<List<String>> uploadPhotos(List<String> localPaths) async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) throw StateError('Not authenticated');

    // Obtain a fresh App Check token for the upload batch.
    String? appCheckToken;
    try {
      appCheckToken =
          (await FirebaseAppCheck.instance.getToken());
    } catch (e) {
      debugPrint('[WoundAnalysisUpload] App Check token failed: $e');
    }

    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final urls = <String>[];

    for (var i = 0; i < localPaths.length; i++) {
      final file = File(localPaths[i]);
      if (!file.existsSync()) continue;

      final ref = FirebaseStorage.instance
          .ref('$_basePath/$uid/$timestamp${localPaths.length > 1 ? '_$i' : ''}.jpg');
      await ref.putFile(
        file,
        SettableMetadata(
          contentType: 'image/jpeg',
          customMetadata: appCheckToken != null
              ? {'appCheckToken': appCheckToken}
              : null,
        ),
      );
      final url = await ref.getDownloadURL();
      urls.add(url);
    }

    return urls;
  }

  /// Deletes temporary analysis photos from Firebase Storage.
  /// Fire-and-forget — errors are logged but not propagated.
  Future<void> deletePhotos(List<String> downloadUrls) async {
    for (final url in downloadUrls) {
      try {
        final ref = FirebaseStorage.instance.refFromURL(url);
        await ref.delete();
      } catch (e) {
        debugPrint('[WoundAnalysisUpload] delete failed: $e');
      }
    }
  }
}
