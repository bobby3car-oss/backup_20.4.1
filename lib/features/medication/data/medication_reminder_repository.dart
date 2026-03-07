import '../domain/medication_reminder.dart';

abstract interface class MedicationReminderRepository {
  Stream<List<MedicationReminder>> watchAll();
  Future<void> upsert(MedicationReminder reminder);
  Future<void> delete(String id);
  Future<MedicationReminder?> getById(String id);
  Future<void> loadFromDisk();
  Future<void> saveToDisk();
}
