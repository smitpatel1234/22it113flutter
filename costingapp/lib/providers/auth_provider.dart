import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_model.dart';
import '../repositories/auth_repository.dart';

class AuthProvider extends ChangeNotifier {
  final AuthRepository _authRepository = AuthRepository();

  UserModel? _user;
  bool _isLoading = false;
  String? _error;

  UserModel? get user => _user;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get isAuthenticated => _user != null;
  bool get isAdmin => _user?.role == UserRole.admin;

  AuthProvider() {
    _initializeUser();
  }

  void _initializeUser() {
    _authRepository.authStateChanges.listen((User? firebaseUser) async {
      if (firebaseUser != null) {
        try {
          final userDoc =
              await FirebaseFirestore.instance
                  .collection('users')
                  .doc(firebaseUser.uid)
                  .get();

          if (userDoc.exists) {
            _user = UserModel.fromMap({
              ...userDoc.data()!,
              'uid': firebaseUser.uid,
            });
          } else {
            _user = null;
          }
        } catch (e) {
          _user = null;
          _error = e.toString();
        }
      } else {
        _user = null;
      }
      notifyListeners();
    });
  }

  Future<void> signIn({required String email, required String password}) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      _user = await _authRepository.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
    } catch (e) {
      _error = e.toString();
      _user = null;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> register({
    required String email,
    required String password,
    required String name,
    required UserRole role,
  }) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      _user = await _authRepository.registerWithEmailAndPassword(
        email: email,
        password: password,
        name: name,
        role: role,
      );
    } catch (e) {
      _error = e.toString();
      _user = null;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> signOut() async {
    try {
      await _authRepository.signOut();
      _user = null;
    } catch (e) {
      _error = e.toString();
    }
    notifyListeners();
  }
}
