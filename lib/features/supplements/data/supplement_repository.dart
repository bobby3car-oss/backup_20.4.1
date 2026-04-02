import '../domain/supplement.dart';

abstract interface class SupplementRepository {
  Stream<List<Supplement>> watchAll();
  Future<void> upsert(Supplement supplement);
  Future<void> delete(String id);
  Future<Supplement?> getById(String id);
  Future<void> loadFromDisk();
  Future<void> saveToDisk();
}

