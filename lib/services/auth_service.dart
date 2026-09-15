import 'package:flutter/foundation.dart';
import '../models/user_model.dart';

/// Authentication service for LL Lifelink AI.
/// Currently uses in-memory demo authentication.
/// Prepared for future FastAPI JWT endpoints (`/api/v1/auth/login`, `/api/v1/auth/register`).
class AuthService extends ChangeNotifier {
  static final AuthService _instance = AuthService._internal();
  factory AuthService() => _instance;
  AuthService._internal();

  UserModel? _currentUser;
  bool _isAuthenticated = false;

  UserModel? get currentUser => _currentUser;
  bool get isAuthenticated => _isAuthenticated;

  /// Simulates demo login.
  /// Accepts any valid formatted email and password for demo showcase.
  Future<bool> login({
    required String email,
    required String password,
  }) async {
    // Simulated network latency for realistic feel
    await Future.delayed(const Duration(milliseconds: 600));

    if (email.contains('@') && password.length >= 6) {
      _currentUser = UserModel.defaultDemo().copyWith(email: email);
      _isAuthenticated = true;
      notifyListeners();
      return true;
    }
    return false;
  }

  /// Simulates demo user registration.
  Future<bool> register({
    required String name,
    required String email,
    required String password,
  }) async {
    await Future.delayed(const Duration(milliseconds: 700));

    if (name.isNotEmpty && email.contains('@') && password.length >= 6) {
      _currentUser = UserModel.defaultDemo().copyWith(
        name: name,
        email: email,
      );
      _isAuthenticated = true;
      notifyListeners();
      return true;
    }
    return false;
  }

  /// Signs out and resets demo user state.
  void logout() {
    _currentUser = null;
    _isAuthenticated = false;
    notifyListeners();
  }
}
