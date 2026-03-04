import '../domain/wound_entry.dart';

abstract class WoundRepository {
  Stream<List<WoundEntry>> watchAll();
  Future<void> upsert(WoundEntry entry);
  Future<void> delete(String id);
  Future<void> loadFromDisk();
  Future<void> saveToDisk();
}
