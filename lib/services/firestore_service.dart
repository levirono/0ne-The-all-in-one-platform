import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class FirestoreService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> saveUserDetails(String uid, String fullName, String email) async {
    try {
      await _firestore.collection('users').doc(uid).set({
        'fullName': fullName,
        'email': email,
      });
    } catch (e) {
      print(e.toString());
    }
  }

  Future<void> syncNotes(String uid, List<Map<String, dynamic>> notes) async {
    try {
      final userNotesRef = _firestore.collection('users').doc(uid).collection('notes');
      final batch = _firestore.batch();

      for (var note in notes) {
        final noteRef = userNotesRef.doc(note['id'].toString());
        batch.set(noteRef, note);
      }

      await batch.commit();
    } catch (e) {
      print(e.toString());
    }
  }

  //fetching 
  Future<List<Map<String, dynamic>>> fetchNotes(String uid) async {
  try {
    final userNotesRef = _firestore.collection('users').doc(uid).collection('notes');
    final snapshot = await userNotesRef.get();
    return snapshot.docs.map((doc) => doc.data()).toList();
  } catch (e) {
    print(e.toString());
    return [];
  }
}
Future<void> syncTodos(String uid, List<Map<String, dynamic>> todos) async {
    try {
      final userTodosRef = _firestore.collection('users').doc(uid).collection('todos');
      final batch = _firestore.batch();

      for (var todo in todos) {
        final todoRef = userTodosRef.doc(todo['id'].toString());
        batch.set(todoRef, todo);
      }

      await batch.commit();
    } catch (e) {
      print('Error syncing todos: $e');
    }
  }

  Future<List<Map<String, dynamic>>> fetchTodos(String uid) async {
    try {
      final userTodosRef = _firestore.collection('users').doc(uid).collection('todos');
      final snapshot = await userTodosRef.get();
      return snapshot.docs.map((doc) => doc.data()).toList();
    } catch (e) {
      print('Error fetching todos: $e');
      return [];
    }
  }




  // methods for cummunities

  Stream<List<Map<String, dynamic>>> streamCommunities() {
    return _firestore.collection('communities').snapshots().map((snapshot) {
      return snapshot.docs.map((doc) => {'id': doc.id, ...doc.data()}).toList();
    });
  }

  Future<void> createCommunity(String name, String uid) async {
  final user = FirebaseAuth.instance.currentUser!;
  final communityRef = await FirebaseFirestore.instance.collection('communities').add({
    'name': name,
    'createdBy': user.uid,
    'createdAt': FieldValue.serverTimestamp(),
  });

  // Add the creator as a member
  await communityRef.collection('members').doc(user.uid).set({
    'fullName': user.displayName ?? 'Unknown',
    'joinedAt': FieldValue.serverTimestamp(),
  });
}

  Stream<Map<String, dynamic>> streamCommunityDetails(String communityId) {
    return _firestore.collection('communities').doc(communityId).snapshots().map((doc) {
      return {'id': doc.id, ...doc.data()!};
    });
  }

  Stream<List<Map<String, dynamic>>> streamCommunityNotes(String communityId) {
    return _firestore
        .collection('communities')
        .doc(communityId)
        .collection('shared_notes')
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) => {'id': doc.id, ...doc.data()}).toList();
    });
  }

}

