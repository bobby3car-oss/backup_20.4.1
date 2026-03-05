import '../domain/vital_entry.dart';

abstract class VitalRepository {
  Stream<List<VitalEntry>> watchAll();
  Future<void> upsert(VitalEntry entry);
  Future<void> delete(String id);
  Future<VitalEntry?> getById(String id);
  Future<void> loadFromDisk();
  Future<void> saveToDisk();
}
