import 'package:flutter_test/flutter_test.dart';
import 'package:operationsbegleiter_v3/features/ads/presentation/ad_slot_helper.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('ad_slot_helper', () {
    test('normalizes disabled or missing frequencies', () {
      expect(normalizeAdFrequency(null), 5);
      expect(normalizeAdFrequency(0), 0);
      expect(normalizeAdFrequency(-3), 0);
      expect(normalizeAdFrequency(4), 4);
    });

    test('calculates ad slots and total item counts consistently', () {
      expect(itemCountWithAds(0, 5), 0);
      expect(itemCountWithAds(5, 5), 6);
      expect(itemCountWithAds(11, 5), 13);

      expect(isAdSlotIndex(0, 5), isFalse);
      expect(isAdSlotIndex(5, 5), isTrue);
      expect(isAdSlotIndex(11, 5), isTrue);

      expect(adsBeforeIndex(0, 5), 0);
      expect(adsBeforeIndex(5, 5), 1);
      expect(adsBeforeIndex(11, 5), 2);
    });

    test('supports grouped layouts that render ads after real items', () {
      expect(shouldInsertAdAfterRealItem(0, 6, 5), isFalse);
      expect(shouldInsertAdAfterRealItem(4, 6, 5), isTrue);
      expect(shouldInsertAdAfterRealItem(4, 5, 5), isFalse);
      expect(shouldInsertAdAfterRealItem(1, 4, 0), isFalse);
    });
  });
}