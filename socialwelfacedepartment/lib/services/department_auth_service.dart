import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../model/department.dart';

class DepartmentAuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Sign up a new department
  Future<Department?> signUp({
    required String name,
    required String email,
    required String phone,
    required String type,
    required String governmentLevel,
    required String parentMinistry,
    required String password,
    required List<String> complaintCategories,
  }) async {
    try {
      UserCredential userCredential =
          await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      Department newDepartment = Department(
        id: userCredential.user!.uid,
        name: name,
        email: email,
        phone: phone,
        type: type,
        governmentLevel: governmentLevel,
        parentMinistry: parentMinistry,
        complaintCategories: complaintCategories,
        createdAt: DateTime.now(),
      );

      await _firestore
          .collection('departments')
          .doc(userCredential.user!.uid)
          .set(newDepartment.toMap());

      return newDepartment;
    } catch (e) {
      print('Signup error: $e');
      rethrow;
    }
  }

  // Login existing department
  Future<Department?> login(String email, String password) async {
    try {
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      DocumentSnapshot doc = await _firestore
          .collection('departments')
          .doc(userCredential.user!.uid)
          .get();

      if (doc.exists) {
        return Department.fromMap(doc.data() as Map<String, dynamic>);
      }
      return null;
    } catch (e) {
      print('Login error: $e');
      rethrow;
    }
  }

  // Logout
  Future<void> logout() async {
    await _auth.signOut();
  }

  // Get current department stream
  Stream<Department?> get currentDepartment {
    return _auth.authStateChanges().asyncMap((user) async {
      if (user == null) return null;
      DocumentSnapshot doc =
          await _firestore.collection('departments').doc(user.uid).get();
      return doc.exists
          ? Department.fromMap(doc.data() as Map<String, dynamic>)
          : null;
    });
  }
}
