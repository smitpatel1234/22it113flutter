import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_model.dart';

class AuthRepository {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Get current user
  User? get currentUser => _auth.currentUser;

  // Auth state changes
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  // Register with email & password
  Future<UserModel> registerWithEmailAndPassword({
    required String email,
    required String password,
    required String name,
    required UserRole role,
  }) async {
    try {
      final userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (userCredential.user != null) {
        final user = UserModel(
          uid: userCredential.user!.uid,
          email: email,
          name: name,
          role: role,
          createdAt: DateTime.now(),
        );

        // Save user data to Firestore
        await _firestore.collection('users').doc(user.uid).set(user.toMap());

        return user;
      }
      throw Exception("Failed to create user");
    } on FirebaseAuthException catch (e) {
      throw Exception(e.message ?? "Registration failed");
    }
  }

  // Sign in with email & password
  Future<UserModel> signInWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    try {
      final userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (userCredential.user != null) {
        // Update last login time
        final userDoc =
            await _firestore
                .collection('users')
                .doc(userCredential.user!.uid)
                .get();

        final userData = userDoc.data();

        if (userData == null) {
          throw Exception("User data not found");
        }

        await _firestore
            .collection('users')
            .doc(userCredential.user!.uid)
            .update({'lastLogin': DateTime.now().millisecondsSinceEpoch});

        return UserModel.fromMap({
          ...userData,
          'uid': userCredential.user!.uid,
        });
      }
      throw Exception("Failed to sign in");
    } on FirebaseAuthException catch (e) {
      throw Exception(e.message ?? "Login failed");
    }
  }

  // Get user role
  Future<UserRole> getUserRole(String uid) async {
    try {
      final userDoc = await _firestore.collection('users').doc(uid).get();
      final userData = userDoc.data();

      if (userData != null) {
        return userData['role'] == 'admin' ? UserRole.admin : UserRole.operator;
      }

      throw Exception("User role not found");
    } catch (e) {
      throw Exception("Failed to get user role");
    }
  }

  // Sign out
  Future<void> signOut() async {
    await _auth.signOut();
  }
}
