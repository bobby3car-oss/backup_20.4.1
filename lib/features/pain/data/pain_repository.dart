import '../domain/pain_entry.dart';

abstract class PainRepository {
  Stream<List<PainEntry>> watchAll();
  Future<void> upsert(PainEntry entry);
  Future<void> delete(String id);
  Future<PainEntry?> getById(String id);
  Future<void> loadFromDisk();
  Future<void> saveToDisk();
}
