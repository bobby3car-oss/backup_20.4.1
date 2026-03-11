int normalizeAdFrequency(int? raw, {int fallback = 5}) {
  final value = raw ?? fallback;
  if (value <= 0) return 0;
  return value;
}

int itemCountWithAds(int realCount, int adFrequency) {
  if (adFrequency <= 0 || realCount <= 0) return realCount;
  return realCount + (realCount ~/ adFrequency);
}

int adsBeforeIndex(int index, int adFrequency) {
  if (adFrequency <= 0) return 0;
  return (index + 1) ~/ (adFrequency + 1);
}

bool isAdSlotIndex(int index, int adFrequency) {
  if (adFrequency <= 0 || index <= 0) return false;
  return (index + 1) % (adFrequency + 1) == 0;
}

bool shouldInsertAdAfterRealItem(
  int realIndex,
  int totalRealItems,
  int adFrequency,
) {
  if (adFrequency <= 0 || totalRealItems <= 0) return false;
  final itemNumber = realIndex + 1;
  if (itemNumber >= totalRealItems) return false;
  return itemNumber % adFrequency == 0;
}