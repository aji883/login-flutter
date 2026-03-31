import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../utils/constants.dart';

class StorageService {
  final FlutterSecureStorage _secureStorage;

  StorageService({FlutterSecureStorage? secureStorage})
      : _secureStorage = secureStorage ?? const FlutterSecureStorage();

  /// Save auth token securely
  Future<void> saveToken(String token) async {
    await _secureStorage.write(key: StorageKeys.token, value: token);
  }

  /// Get stored auth token
  Future<String?> getToken() async {
    return await _secureStorage.read(key: StorageKeys.token);
  }

  /// Delete auth token
  Future<void> deleteToken() async {
    await _secureStorage.delete(key: StorageKeys.token);
  }

  /// Save user email
  Future<void> saveUserEmail(String email) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(StorageKeys.userEmail, email);
  }

  /// Get stored user email
  Future<String?> getUserEmail() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(StorageKeys.userEmail);
  }

  /// Set login status
  Future<void> setLoggedIn(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(StorageKeys.isLoggedIn, value);
  }

  /// Check if user is logged in
  Future<bool> isLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(StorageKeys.isLoggedIn) ?? false;
  }

  /// Clear all stored data (logout)
  Future<void> clearAll() async {
    await _secureStorage.deleteAll();
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
  }
}
