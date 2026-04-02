import '../domain/rts_assessment.dart';

abstract class RtsRepository {
  Stream<List<RtsAssessment>> watchAll();
  Future<void> upsert(RtsAssessment assessment);
  Future<void> delete(String id);
  Future<RtsAssessment?> getById(String id);
  Future<void> loadFromDisk();
  Future<void> saveToDisk();
}
