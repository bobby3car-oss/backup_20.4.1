import '../domain/sleep_entry.dart';

abstract class SleepRepository {
  Stream<List<SleepEntry>> watchAll();
  Future<void> upsert(SleepEntry entry);
  Future<void> delete(String id);
  Future<SleepEntry?> getById(String id);
  Future<void> loadFromDisk();
  Future<void> saveToDisk();
}
