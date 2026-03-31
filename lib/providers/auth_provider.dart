import 'package:flutter/material.dart';
import '../models/login_request_model.dart';
import '../models/login_response_model.dart';
import '../models/user_model.dart';
import '../repositories/auth_repository.dart';

enum AuthState {
  initial,
  loading,
  authenticated,
  unauthenticated,
  error,
}

class AuthProvider extends ChangeNotifier {
  final AuthRepository _authRepository;

  AuthState _state = AuthState.initial;
  String? _token;
  String? _email;
  String? _errorMessage;
  UserModel? _user;

  AuthProvider({AuthRepository? authRepository})
      : _authRepository = authRepository ?? AuthRepository();

  // Getters
  AuthState get state => _state;
  String? get token => _token;
  String? get email => _email;
  String? get errorMessage => _errorMessage;
  UserModel? get user => _user;
  bool get isAuthenticated => _state == AuthState.authenticated;
  bool get isLoading => _state == AuthState.loading;

  /// Initialize auth state - check if user was previously logged in
  Future<void> initialize() async {
    _state = AuthState.loading;
    notifyListeners();

    try {
      final isAuth = await _authRepository.isAuthenticated();
      if (isAuth) {
        _token = await _authRepository.getToken();
        _email = await _authRepository.getUserEmail();
        // Load user profile
        _user = await _authRepository.getUserProfile(4);
        _state = AuthState.authenticated;
      } else {
        _state = AuthState.unauthenticated;
      }
    } catch (e) {
      _state = AuthState.unauthenticated;
    }

    notifyListeners();
  }

  /// Login with email and password
  Future<bool> login(String email, String password) async {
    _state = AuthState.loading;
    _errorMessage = null;
    notifyListeners();

    final request = LoginRequestModel(email: email, password: password);
    final LoginResponseModel response = await _authRepository.login(request);

    if (response.isSuccess) {
      _token = response.token;
      _email = email;
      _errorMessage = null;
      // Load user profile after successful login
      _user = await _authRepository.getUserProfile(4);
      _state = AuthState.authenticated;
      notifyListeners();
      return true;
    } else {
      _errorMessage = response.error ?? 'Login failed. Please try again.';
      _state = AuthState.error;
      notifyListeners();
      return false;
    }
  }

  /// Register with email and password
  Future<bool> register(String email, String password) async {
    _state = AuthState.loading;
    _errorMessage = null;
    notifyListeners();

    final request = LoginRequestModel(email: email, password: password);
    final LoginResponseModel response = await _authRepository.register(request);

    if (response.isSuccess) {
      _token = response.token;
      _email = email;
      _errorMessage = null;
      // Load user profile after successful registration
      _user = await _authRepository.getUserProfile(4);
      _state = AuthState.authenticated;
      notifyListeners();
      return true;
    } else {
      _errorMessage = response.error ?? 'Registration failed. Please try again.';
      _state = AuthState.error;
      notifyListeners();
      return false;
    }
  }

  /// Logout user
  Future<void> logout() async {
    _state = AuthState.loading;
    notifyListeners();

    await _authRepository.logout();

    _token = null;
    _email = null;
    _user = null;
    _errorMessage = null;
    _state = AuthState.unauthenticated;
    notifyListeners();
  }

  /// Clear error message
  void clearError() {
    _errorMessage = null;
    if (_state == AuthState.error) {
      _state = AuthState.unauthenticated;
    }
    notifyListeners();
  }

  @override
  void dispose() {
    _authRepository.dispose();
    super.dispose();
  }
}
