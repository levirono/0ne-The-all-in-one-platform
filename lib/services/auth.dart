import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:one/services/database_helper.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final DatabaseHelper _dbHelper = DatabaseHelper.instance;

  Future<User?> signInWithEmail(String email, String password) async {
    try {
      UserCredential result = await _auth.signInWithEmailAndPassword(email: email, password: password);
      User? user = result.user;

      if (user != null) {
        DocumentSnapshot userData = await _firestore.collection('users').doc(user.uid).get();

        if (userData.exists) {
          await _dbHelper.cacheUserData({
            'id': user.uid,
            'fullName': userData['fullName'],
            'email': user.email,
          });
        }
      }

      return user;
    } catch (e) {
      print("Error during sign in: $e");
      return null;
    }
  }

  Future<User?> signUpWithEmail(String email, String password, String fullName) async {
    try {
      UserCredential result = await _auth.createUserWithEmailAndPassword(email: email, password: password);
      User? user = result.user;

      if (user != null) {
        await _firestore.collection('users').doc(user.uid).set({
          'fullName': fullName,
          'email': email,
        });

        await _dbHelper.cacheUserData({
          'id': user.uid,
          'fullName': fullName,
          'email': email,
        });
      }

      return user;
    } catch (e) {
      print("Error during sign up: $e");
      return null;
    }
  }

  Future<void> signOut() async {
    try {
      await _auth.signOut();
      await _dbHelper.clearUserCache();
    } catch (e) {
      print("Error during sign out: $e");
    }
  }

  Future<User?> getCurrentUser() async {
    return _auth.currentUser;
  }
}
