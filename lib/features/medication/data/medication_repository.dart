import '../domain/medication_intake.dart';

abstract class MedicationRepository {
  Stream<List<MedicationIntake>> watchAll();
  Future<void> upsert(MedicationIntake entry);
  Future<void> delete(String id);
  Future<MedicationIntake?> getById(String id);
  Future<void> loadFromDisk();
  Future<void> saveToDisk();
}
