import '../domain/supplement_intake.dart';

abstract class SupplementIntakeRepository {
  Stream<List<SupplementIntake>> watchAll();
  Future<void> upsert(SupplementIntake entry);
  Future<void> delete(String id);
  Future<SupplementIntake?> getById(String id);
  Future<void> loadFromDisk();
  Future<void> saveToDisk();
}

