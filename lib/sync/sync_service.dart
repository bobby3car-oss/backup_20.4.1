import 'firestore_client.dart';
import 'sync_models.dart';
import 'sync_queue_local.dart';

class SyncService {
  SyncService({
    required SyncQueueLocal queue,
    required FirestoreClient firestoreClient,
  }) : _queue = queue,
       _firestoreClient = firestoreClient;

  final SyncQueueLocal _queue;
  final FirestoreClient _firestoreClient;

  bool _isSyncing = false;
  bool get isSyncing => _isSyncing;

  Future<void> syncNow() async {
    if (_isSyncing) return;
    _isSyncing = true;

    try {
      final ops = await _queue.pending();
      for (final op in ops) {
        try {
          switch (op.type) {
            case SyncOpType.upsert:
              await _firestoreClient.upsertDoc(op.fullDocPath, op.payload);
              break;
            case SyncOpType.delete:
              await _firestoreClient.deleteDoc(op.fullDocPath);
              break;
          }
          await _queue.markDone(op.id);
        } catch (error) {
          // Keep op in queue so it can be retried later (offline-first).
          await _queue.markFailed(op.id, error.toString());
        }
      }
    } finally {
      _isSyncing = false;
    }
  }
}
