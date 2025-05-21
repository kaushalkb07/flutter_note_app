import 'package:cloud_firestore/cloud_firestore.dart';

class NotesService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String _collectionName = 'notes';

  // Add a new note
  Future<DocumentReference> addNote({
    required String title,
    required String content,
    required DateTime createdAt,
    required String userId,
  }) async {
    final note = {
      'title': title,
      'content': content,
      'createdAt': Timestamp.fromDate(createdAt),
      'userId': userId,
    };

    return await _firestore.collection(_collectionName).add(note);
  }

  // Stream notes for a specific user
  Stream<QuerySnapshot> getNotesByUserId(String userId) {
    return _firestore
        .collection(_collectionName)
        .where('userId', isEqualTo: userId)
        .orderBy('createdAt', descending: true)
        .snapshots();
  }

  // Update note by id
  Future<void> updateNote({
    required String docId,
    required String title,
    required String content,
    required DateTime createdAt,
    required String userId,
  }) async {
    final updatedNote = {
      'title': title,
      'content': content,
      'createdAt': Timestamp.fromDate(createdAt),
      'userId': userId,
    };

    await _firestore.collection(_collectionName).doc(docId).update(updatedNote);
  }

  // Delete note by id
  Future<void> deleteNote(String docId) async {
    await _firestore.collection(_collectionName).doc(docId).delete();
  }
}
