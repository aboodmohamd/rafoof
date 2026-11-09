import 'package:rafoof/core/constants/app_constants.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AppPreferences {
  final SharedPreferences _prefs;
  final FlutterSecureStorage _secureStorage;

  String? _cachedToken;
  String? _cachedRefreshToken;

  AppPreferences(this._prefs, this._secureStorage);

  static const String keyIsAuthenticated = 'is_authenticated';
  static const String keyUserName = 'user_name';
  static const String keyUserEmail = 'user_email';
  static const String keyKeepSignedIn = 'keep_signed_in';
  static const String keyRecentSearches = 'recent_searches';

  Future<void> loadToken() async {
    _cachedToken = await _secureStorage.read(key: AppConstants.authTokenKey);
    _cachedRefreshToken = await _secureStorage.read(
      key: AppConstants.refreshTokenKey,
    );
  }

  String? getToken() => _cachedToken;

  Future<void> setToken(String token) async {
    _cachedToken = token;
    await _secureStorage.write(key: AppConstants.authTokenKey, value: token);
  }

  String? getRefreshToken() => _cachedRefreshToken;

  Future<void> setRefreshToken(String token) async {
    _cachedRefreshToken = token;
    await _secureStorage.write(key: AppConstants.refreshTokenKey, value: token);
  }

  bool isAuthenticated() => _prefs.getBool(keyIsAuthenticated) ?? false;
  Future<bool> setAuthenticated(bool value) =>
      _prefs.setBool(keyIsAuthenticated, value);

  String getUserName() => _prefs.getString(keyUserName) ?? '';
  Future<bool> setUserName(String name) => _prefs.setString(keyUserName, name);

  String getUserEmail() => _prefs.getString(keyUserEmail) ?? '';
  Future<bool> setUserEmail(String email) =>
      _prefs.setString(keyUserEmail, email);

  bool keepSignedIn() => _prefs.getBool(keyKeepSignedIn) ?? true;
  Future<bool> setKeepSignedIn(bool value) =>
      _prefs.setBool(keyKeepSignedIn, value);

  List<String> getRecentSearches() =>
      _prefs.getStringList(keyRecentSearches) ?? [];
  Future<bool> setRecentSearches(List<String> searches) =>
      _prefs.setStringList(keyRecentSearches, searches);

  Future<void> logout() async {
    _cachedToken = null;
    _cachedRefreshToken = null;
    await _secureStorage.delete(key: AppConstants.authTokenKey);
    await _secureStorage.delete(key: AppConstants.refreshTokenKey);
    await _prefs.remove(keyIsAuthenticated);
    await _prefs.remove(keyKeepSignedIn);
    await _prefs.remove(keyUserName);
    await _prefs.remove(keyUserEmail);
  }
}
