import '../domain/mood_entry.dart';

abstract class MoodRepository {
  Stream<List<MoodEntry>> watchAll();
  Future<void> upsert(MoodEntry entry);
  Future<void> delete(String id);
  Future<MoodEntry?> getById(String id);
  Future<void> loadFromDisk();
  Future<void> saveToDisk();
}
