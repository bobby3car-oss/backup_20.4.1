import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  test('notification repository persists through secure user-scoped storage', () {
    final source = File(
      'lib/notifications/notification_repository.dart',
    ).readAsStringSync();

    expect(
      source,
      matches(
        RegExp(
          r"UserScopedStorage\.instance\.readSecure\(\s*'in_app_notifications\.json'",
          dotAll: true,
        ),
      ),
    );
    expect(
      source,
      matches(
        RegExp(
          r"UserScopedStorage\.instance\.writeSecure\(\s*'in_app_notifications\.json',\s*payload",
          dotAll: true,
        ),
      ),
    );
    expect(source, isNot(contains('readAsString(')));
    expect(source, isNot(contains('writeAsString(')));
  });
}