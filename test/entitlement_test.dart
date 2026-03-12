import 'package:flutter_test/flutter_test.dart';
import 'package:operationsbegleiter_v3/features/pro/domain/entitlement.dart';

void main() {
  group('Entitlement.free', () {
    test('returns isPro=false', () {
      final ent = Entitlement.free();
      expect(ent.isPro, false);
      expect(ent.proSince, isNull);
      expect(ent.proExpiresAt, isNull);
      expect(ent.proProductId, isNull);
      expect(ent.proPlatform, isNull);
      expect(ent.proSource, isNull);
    });
  });

  group('Entitlement.fromFirestore', () {
    test('parses isPro=true with all fields', () {
      final data = <String, dynamic>{
        'isPro': true,
        'proSince': '2026-01-15T10:00:00.000Z',
        'proExpiresAt': '2027-01-15T10:00:00.000Z',
        'proProductId': 'operationsbegleiter_pro_yearly',
        'proPlatform': 'ios',
        'proSource': null,
        'lastReceiptValidationAt': '2026-03-01T12:00:00.000Z',
      };

      final ent = Entitlement.fromFirestore(data);

      expect(ent.isPro, true);
      expect(ent.proSince, DateTime.utc(2026, 1, 15, 10));
      expect(ent.proExpiresAt, DateTime.utc(2027, 1, 15, 10));
      expect(ent.proProductId, 'operationsbegleiter_pro_yearly');
      expect(ent.proPlatform, 'ios');
      expect(ent.proSource, isNull);
      expect(ent.lastReceiptValidationAt, DateTime.utc(2026, 3, 1, 12));
    });

    test('handles missing isPro field (defaults to false)', () {
      final ent = Entitlement.fromFirestore(<String, dynamic>{});
      expect(ent.isPro, false);
    });

    test('handles null values gracefully', () {
      final data = <String, dynamic>{
        'isPro': true,
        'proSince': null,
        'proExpiresAt': null,
      };
      final ent = Entitlement.fromFirestore(data);
      expect(ent.isPro, true);
      expect(ent.proSince, isNull);
      expect(ent.proExpiresAt, isNull);
    });

    test('parses proSource "key" for Pro-Key activation', () {
      final data = <String, dynamic>{
        'isPro': true,
        'proSource': 'key',
      };
      final ent = Entitlement.fromFirestore(data);
      expect(ent.isPro, true);
      expect(ent.proSource, 'key');
    });
  });

  group('Entitlement JSON round-trip', () {
    test('free entitlement survives round-trip', () {
      final original = Entitlement.free();
      final json = original.toJson();
      final restored = Entitlement.fromJson(json);

      expect(restored.isPro, original.isPro);
      expect(restored.proSince, original.proSince);
      expect(restored.proExpiresAt, original.proExpiresAt);
    });

    test('pro entitlement survives round-trip', () {
      const original = Entitlement(
        isPro: true,
        proSince: null,
        proExpiresAt: null,
        proProductId: 'operationsbegleiter_pro_monthly',
        proPlatform: 'ios',
        proSource: 'key',
      );

      final json = original.toJson();
      final restored = Entitlement.fromJson(json);

      expect(restored.isPro, true);
      expect(restored.proProductId, 'operationsbegleiter_pro_monthly');
      expect(restored.proPlatform, 'ios');
      expect(restored.proSource, 'key');
    });

    test('pro entitlement with dates survives round-trip', () {
      final original = Entitlement(
        isPro: true,
        proSince: DateTime.utc(2026, 1, 15, 10),
        proExpiresAt: DateTime.utc(2027, 1, 15, 10),
        proProductId: 'operationsbegleiter_pro_yearly',
        proPlatform: 'ios',
        lastReceiptValidationAt: DateTime.utc(2026, 3, 1, 12),
      );

      final json = original.toJson();
      final restored = Entitlement.fromJson(json);

      expect(restored.isPro, true);
      expect(restored.proSince, original.proSince);
      expect(restored.proExpiresAt, original.proExpiresAt);
      expect(restored.lastReceiptValidationAt,
          original.lastReceiptValidationAt);
    });
  });

  group('Entitlement.fromJson', () {
    test('handles empty JSON (defaults to free)', () {
      final ent = Entitlement.fromJson(<String, dynamic>{});
      expect(ent.isPro, false);
    });

    test('handles malformed date strings gracefully', () {
      final data = <String, dynamic>{
        'isPro': true,
        'proSince': 'not-a-date',
        'proExpiresAt': '',
      };
      final ent = Entitlement.fromJson(data);
      expect(ent.isPro, true);
      expect(ent.proSince, isNull);
      expect(ent.proExpiresAt, isNull);
    });
  });

  group('Entitlement.isActive', () {
    test('free entitlement is not active', () {
      final ent = Entitlement.free();
      expect(ent.isActive, false);
    });

    test('pro without expiry is active (lifetime)', () {
      const ent = Entitlement(isPro: true);
      expect(ent.isActive, true);
    });

    test('pro with future expiry is active', () {
      final ent = Entitlement(
        isPro: true,
        proExpiresAt: DateTime.now().add(const Duration(days: 30)),
      );
      expect(ent.isActive, true);
    });

    test('pro with past expiry is NOT active', () {
      final ent = Entitlement(
        isPro: true,
        proExpiresAt: DateTime.now().subtract(const Duration(days: 1)),
      );
      expect(ent.isActive, false);
    });

    test('isPro=false with future expiry is NOT active', () {
      final ent = Entitlement(
        isPro: false,
        proExpiresAt: DateTime.now().add(const Duration(days: 30)),
      );
      expect(ent.isActive, false);
    });
  });
}
