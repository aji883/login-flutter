import '../models/login_request_model.dart';
import '../models/login_response_model.dart';
import '../models/user_model.dart';
import '../services/api_service.dart';
import '../services/storage_service.dart';

class AuthRepository {
  final ApiService _apiService;
  final StorageService _storageService;

  AuthRepository({
    ApiService? apiService,
    StorageService? storageService,
  })  : _apiService = apiService ?? ApiService(),
        _storageService = storageService ?? StorageService();

  /// Authenticate user with email and password
  /// Returns [LoginResponseModel] with token on success
  Future<LoginResponseModel> login(LoginRequestModel request) async {
    try {
      final responseData = await _apiService.login(request.toJson());
      final loginResponse = LoginResponseModel.fromJson(responseData);

      if (loginResponse.isSuccess) {
        // Save token and user data securely
        await _storageService.saveToken(loginResponse.token!);
        await _storageService.saveUserEmail(request.email);
        await _storageService.setLoggedIn(true);
      }

      return loginResponse;
    } on ApiException catch (e) {
      return LoginResponseModel(error: e.message);
    }
  }

  /// Register user with email and password
  /// Returns [LoginResponseModel] with token on success
  Future<LoginResponseModel> register(LoginRequestModel request) async {
    try {
      final responseData = await _apiService.register(request.toJson());
      final registerResponse = LoginResponseModel.fromJson(responseData);

      if (registerResponse.isSuccess) {
        // Save token and user data securely
        await _storageService.saveToken(registerResponse.token!);
        await _storageService.saveUserEmail(request.email);
        await _storageService.setLoggedIn(true);
      }

      return registerResponse;
    } on ApiException catch (e) {
      return LoginResponseModel(error: e.message);
    }
  }

  /// Fetch user profile from API
  Future<UserModel?> getUserProfile(int userId) async {
    try {
      final data = await _apiService.getUserProfile(userId);
      return UserModel.fromJson(data);
    } catch (e) {
      return null;
    }
  }

  /// Check if user has a valid session
  Future<bool> isAuthenticated() async {
    return await _storageService.isLoggedIn();
  }

  /// Get stored token
  Future<String?> getToken() async {
    return await _storageService.getToken();
  }

  /// Get stored email
  Future<String?> getUserEmail() async {
    return await _storageService.getUserEmail();
  }

  /// Logout user and clear all stored data
  Future<void> logout() async {
    await _storageService.clearAll();
  }

  void dispose() {
    _apiService.dispose();
  }
}
