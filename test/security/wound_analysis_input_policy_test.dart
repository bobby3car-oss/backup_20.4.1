import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  test('wound analysis uses validated storage paths instead of arbitrary URLs', () {
    final uploadService = File(
      'lib/features/assistant/domain/wound_analysis_upload_service.dart',
    ).readAsStringSync();
    final assistantService = File(
      'lib/features/assistant/domain/assistant_service.dart',
    ).readAsStringSync();
    final functionsSource = File('functions/index.js').readAsStringSync();

    expect(uploadService, contains('ref.fullPath'));
    expect(uploadService, isNot(contains('getDownloadURL()')));
    expect(uploadService, isNot(contains('refFromURL')));

    expect(assistantService, contains('imageStoragePaths'));
    expect(assistantService, contains("bodyMap['imageStoragePaths']"));

    expect(functionsSource, contains('resolveWoundAnalysisStoragePaths'));
    expect(functionsSource, contains(r'woundAnalysis/${uid}/'));
    expect(functionsSource, contains('.bucket().file('));
    expect(functionsSource, isNot(contains('u.startsWith("https://")')));
    expect(functionsSource, isNot(contains('proxyImageAsDataUri(url)')));
  });
}