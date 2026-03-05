import '../domain/rehab_session.dart';

abstract class RehabSessionRepository {
  Stream<List<RehabSession>> watchAll();
  Future<void> upsert(RehabSession session);
  Future<void> delete(String id);
  Future<RehabSession?> getById(String id);
  Future<void> loadFromDisk();
  Future<void> saveToDisk();
}
