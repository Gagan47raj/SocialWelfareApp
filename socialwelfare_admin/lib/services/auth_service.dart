import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  Future<User?> login(String email, String password) async {
    try {
      final credential = await _auth.signInWithEmailAndPassword(
          email: email, password: password);
      return credential.user;
    } catch (e) {
      print('Login error: $e');
      return null;
    }
  }

  Future<User?> signup(String email, String password) async {
    try {
      final credential = await _auth.createUserWithEmailAndPassword(
          email: email, password: password);

      await _db.collection('admins').doc(credential.user!.uid).set({
        'email': email,
        'uid': credential.user!.uid,
        'createdAt': FieldValue.serverTimestamp(),
      });

      return credential.user;
    } catch (e) {
      print('Signup error: $e');
      return null;
    }
  }

  Future<void> logout() async {
    await _auth.signOut();
  }
}
