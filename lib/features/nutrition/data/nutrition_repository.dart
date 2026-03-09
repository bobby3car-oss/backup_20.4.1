import '../domain/nutrition_entry.dart';

abstract class NutritionRepository {
  Stream<List<NutritionEntry>> watchAll();
  Future<void> upsert(NutritionEntry entry);
  Future<void> delete(String id);
  Future<NutritionEntry?> getById(String id);
  Future<void> loadFromDisk();
  Future<void> saveToDisk();
}
