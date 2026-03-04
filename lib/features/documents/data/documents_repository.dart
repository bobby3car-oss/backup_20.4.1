import '../domain/document_item.dart';

abstract class DocumentsRepository {
  Stream<List<DocumentItem>> watchAll();
  Future<void> upsert(DocumentItem item);
  Future<void> delete(String id);
  Future<void> loadFromDisk();
  Future<void> saveToDisk();
}
