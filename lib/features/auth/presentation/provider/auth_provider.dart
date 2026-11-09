import 'dart:async';

import 'package:flutter/material.dart';
import 'package:rafoof/core/di/service_locator.dart';
import 'package:rafoof/core/services/app_preferences.dart';
import 'package:rafoof/core/services/auth_event_service.dart';
import 'package:rafoof/features/auth/data/models/user_model.dart';
import 'package:rafoof/features/auth/data/repositories/auth_repository.dart';

class AuthProvider extends ChangeNotifier {
  AuthRepository get _authRepository => sl<AuthRepository>();
  AppPreferences get _appPreferences => sl<AppPreferences>();

  StreamSubscription<AuthEvent>? _authSubscription;

  UserModel? _user;
  bool _isLoggedIn = false;
  bool _isLoading = false;
  String? _error;
  bool _obscurePassword = true;
  bool _keepSignedIn = true;

  UserModel? get user => _user;
  bool get isLoggedIn => _isLoggedIn;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get obscurePassword => _obscurePassword;
  bool get keepSignedIn => _keepSignedIn;

  AuthProvider() {
    _authSubscription = AuthEventService().authEvents.listen((event) {
      if (event == AuthEvent.unauthenticated && _isLoggedIn) {
        _user = null;
        _isLoggedIn = false;
        notifyListeners();
      }
    });
  }

  Future<void> loadUser() async {
    final token = _appPreferences.getToken();
    if (token == null || token.isEmpty) return;

    if (!_appPreferences.keepSignedIn()) {
      await _authRepository.logout();
      return;
    }

    _isLoggedIn = true;
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _user = await _authRepository.getCurrentUser();
    } catch (e) {
      _error = e.toString().replaceFirst('Exception: ', '');
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<void> login({
    required String username,
    required String password,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _user = await _authRepository.login(
        username: username,
        password: password,
        keepSignedIn: _keepSignedIn,
      );
      _isLoggedIn = true;
      _obscurePassword = true;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> logout() async {
    _user = null;
    _isLoggedIn = false;
    _error = null;
    notifyListeners();
    await _authRepository.logout();
  }

  void togglePasswordVisibility() {
    _obscurePassword = !_obscurePassword;
    notifyListeners();
  }

  void toggleKeepSignedIn() {
    _keepSignedIn = !_keepSignedIn;
    notifyListeners();
  }

  @override
  void dispose() {
    _authSubscription?.cancel();
    super.dispose();
  }
}
