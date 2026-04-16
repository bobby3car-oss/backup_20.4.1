import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  test('cloud functions usage goes through shared region helpers', () {
    const allowedFiles = <String>{
      'lib/firebase/app_functions.dart',
      'lib/roles/admin/admin_functions.dart',
    };

    final directInstancePattern = RegExp(r'FirebaseFunctions\.instance\b');
    final injectedDefaultPattern = RegExp(
      r'functions\s*\?\?\s*FirebaseFunctions\.instance\b',
    );
    final directRegionPattern = RegExp(
      r'FirebaseFunctions\.instanceFor\s*\(',
    );

    final violations = <String>[];
    final files = Directory('lib')
        .listSync(recursive: true)
        .whereType<File>()
        .where((file) => file.path.endsWith('.dart'));

    for (final file in files) {
      final normalizedPath = file.path.replaceAll('\\', '/');
      final libIndex = normalizedPath.indexOf('/lib/');
      final relativePath = libIndex == -1
          ? normalizedPath
          : normalizedPath.substring(libIndex + 1);

      if (allowedFiles.contains(relativePath)) {
        continue;
      }

      final source = file.readAsStringSync();
      if (injectedDefaultPattern.hasMatch(source)) {
        violations.add('$relativePath defaults to FirebaseFunctions.instance');
      } else if (directInstancePattern.hasMatch(source)) {
        violations.add('$relativePath uses FirebaseFunctions.instance directly');
      }
      if (directRegionPattern.hasMatch(source)) {
        violations.add('$relativePath creates a direct region-pinned FirebaseFunctions instance');
      }
    }

    expect(
      violations,
      isEmpty,
      reason: violations.isEmpty
          ? null
          : 'Use appFunctions()/adminFunctions() instead:\n${violations.join('\n')}',
    );
  });
}