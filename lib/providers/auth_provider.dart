import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/user_model.dart';
import '../services/auth_service.dart';
import '../services/notification_service.dart';
import '../services/mock_database.dart';
import '../utils/app_constants.dart';

enum AuthStatus { initial, loading, authenticated, unauthenticated, error }

class AuthProvider extends ChangeNotifier {
  final AuthService _authService = AuthService();

  AuthStatus _status = AuthStatus.initial;
  UserModel? _user;
  String? _errorMessage;

  AuthStatus get status => _status;
  UserModel? get user => _user;
  String? get errorMessage => _errorMessage;
  bool get isAdmin => _user?.isAdmin ?? false;
  bool get isAuthenticated => _status == AuthStatus.authenticated;

  AuthProvider() {
    if (AppConstants.isDemoMode) {
      _status = AuthStatus.unauthenticated;
      notifyListeners();
      MockDatabase.instance.authStateChanges.listen((mockUser) {
        _user = mockUser;
        _status = mockUser != null
            ? AuthStatus.authenticated
            : AuthStatus.unauthenticated;
        notifyListeners();
      });
    } else {
      _authService.authStateChanges.listen(_onAuthStateChanged);
    }
  }

  Future<void> _onAuthStateChanged(User? firebaseUser) async {
    if (firebaseUser == null) {
      _status = AuthStatus.unauthenticated;
      _user = null;
    } else {
      _user = await _authService.getUserData(firebaseUser.uid);
      if (_user != null) {
        _status = AuthStatus.authenticated;
        _updateFcmToken();
      } else {
        _status = AuthStatus.unauthenticated;
      }
    }
    notifyListeners();
  }

  Future<void> _updateFcmToken() async {
    if (_user == null) return;
    final token = await NotificationService.instance.getToken();
    if (token != null) {
      await _authService.updateFcmToken(_user!.uid, token);
    }
  }

  Future<bool> signUp({
    required String email,
    required String password,
    required String name,
    required String department,
    required String semester,
    String role = 'student',
  }) async {
    _setLoading();
    try {
      if (AppConstants.isDemoMode) {
        _user = await MockDatabase.instance.signUpWithEmail(
          email: email,
          password: password,
          name: name,
          department: department,
          semester: semester,
          role: role,
        );
      } else {
        _user = await _authService.signUpWithEmail(
          email: email,
          password: password,
          name: name,
          department: department,
          semester: semester,
          role: role,
        );
      }
      _status = AuthStatus.authenticated;
      notifyListeners();
      return true;
    } catch (e) {
      if (AppConstants.isDemoMode) {
        _setError(e.toString().replaceAll('Exception: ', ''));
      } else if (e is FirebaseAuthException) {
        _setError(_mapFirebaseError(e.code));
      } else {
        _setError('An error occurred. Please try again.');
      }
      return false;
    }
  }

  Future<bool> signIn({
    required String email,
    required String password,
  }) async {
    _setLoading();
    try {
      if (AppConstants.isDemoMode) {
        _user = await MockDatabase.instance.signInWithEmail(
          email: email,
          password: password,
        );
      } else {
        _user = await _authService.signInWithEmail(
          email: email,
          password: password,
        );
      }
      _status = AuthStatus.authenticated;
      notifyListeners();
      return true;
    } catch (e) {
      if (AppConstants.isDemoMode) {
        _setError(e.toString().replaceAll('Exception: ', ''));
      } else if (e is FirebaseAuthException) {
        _setError(_mapFirebaseError(e.code));
      } else {
        _setError('An error occurred. Please try again.');
      }
      return false;
    }
  }

  Future<bool> signInWithGoogle() async {
    _setLoading();
    try {
      if (AppConstants.isDemoMode) {
        _user = await MockDatabase.instance.signInWithGoogle();
      } else {
        _user = await _authService.signInWithGoogle();
      }
      if (_user != null) {
        _status = AuthStatus.authenticated;
        notifyListeners();
        return true;
      }
      _setError('Google Sign-In was cancelled.');
      return false;
    } catch (e) {
      _setError('Google Sign-In failed. Please try again.');
      return false;
    }
  }

  Future<void> signOut() async {
    if (AppConstants.isDemoMode) {
      await MockDatabase.instance.signOut();
    } else {
      await _authService.signOut();
    }
    _user = null;
    _status = AuthStatus.unauthenticated;
    notifyListeners();
  }

  Future<bool> sendPasswordReset(String email) async {
    try {
      if (AppConstants.isDemoMode) {
        return true;
      } else {
        await _authService.sendPasswordResetEmail(email);
        return true;
      }
    } catch (_) {
      return false;
    }
  }

  Future<void> refreshUser() async {
    if (_user == null) return;
    if (AppConstants.isDemoMode) {
      _user = await MockDatabase.instance.getUserData(_user!.uid);
    } else {
      _user = await _authService.getUserData(_user!.uid);
    }
    notifyListeners();
  }

  void _setLoading() {
    _status = AuthStatus.loading;
    _errorMessage = null;
    notifyListeners();
  }

  void _setError(String message) {
    _status = AuthStatus.error;
    _errorMessage = message;
    notifyListeners();
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  String _mapFirebaseError(String code) {
    switch (code) {
      case 'user-not-found':
        return 'No account found with this email.';
      case 'wrong-password':
        return 'Incorrect password.';
      case 'email-already-in-use':
        return 'This email is already registered.';
      case 'weak-password':
        return 'Password must be at least 6 characters.';
      case 'invalid-email':
        return 'Please enter a valid email address.';
      case 'too-many-requests':
        return 'Too many attempts. Please try again later.';
      default:
        return 'An error occurred. Please try again.';
    }
  }
}
