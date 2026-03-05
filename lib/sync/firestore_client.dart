import 'package:cloud_firestore/cloud_firestore.dart';

class FirestoreCollectionDoc {
  const FirestoreCollectionDoc({required this.id, required this.data});

  final String id;
  final Map<String, dynamic> data;
}

class FirestoreClient {
  FirestoreClient({FirebaseFirestore? firestore})
    : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;

  Future<void> upsertDoc(String path, Map<String, dynamic> payload) async {
    await _firestore.doc(path).set(payload, SetOptions(merge: true));
  }

  Future<void> deleteDoc(String path) async {
    await _firestore.doc(path).delete();
  }

  Future<List<FirestoreCollectionDoc>> fetchCollectionDocs(
    String collectionPath, {
    int? limit,
  }) async {
    Query<Map<String, dynamic>> query = _firestore.collection(collectionPath);
    if (limit != null && limit > 0) {
      query = query.limit(limit);
    }
    final snapshot = await query.get();
    return snapshot.docs
        .map(
          (doc) => FirestoreCollectionDoc(
            id: doc.id,
            data: Map<String, dynamic>.from(doc.data()),
          ),
        )
        .toList(growable: false);
  }

  Stream<Map<String, dynamic>> watchDoc(String path) {
    return _firestore.doc(path).snapshots().map((snapshot) {
      return snapshot.data() ?? <String, dynamic>{};
    });
  }
}
