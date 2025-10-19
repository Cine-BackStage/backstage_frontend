import 'package:shared_preferences/shared_preferences.dart';

/// Local storage adapter for Backstage Cinema
/// Wrapper around SharedPreferences
class LocalStorage {
  static LocalStorage? _instance;
  static SharedPreferences? _preferences;

  LocalStorage._();

  static Future<LocalStorage> getInstance() async {
    _instance ??= LocalStorage._();
    _preferences ??= await SharedPreferences.getInstance();
    return _instance!;
  }

  /// Save string value
  Future<bool> setString(String key, String value) async {
    return await _preferences!.setString(key, value);
  }

  /// Get string value
  String? getString(String key) {
    return _preferences!.getString(key);
  }

  /// Save int value
  Future<bool> setInt(String key, int value) async {
    return await _preferences!.setInt(key, value);
  }

  /// Get int value
  int? getInt(String key) {
    return _preferences!.getInt(key);
  }

  /// Save double value
  Future<bool> setDouble(String key, double value) async {
    return await _preferences!.setDouble(key, value);
  }

  /// Get double value
  double? getDouble(String key) {
    return _preferences!.getDouble(key);
  }

  /// Save bool value
  Future<bool> setBool(String key, bool value) async {
    return await _preferences!.setBool(key, value);
  }

  /// Get bool value
  bool? getBool(String key) {
    return _preferences!.getBool(key);
  }

  /// Save string list
  Future<bool> setStringList(String key, List<String> value) async {
    return await _preferences!.setStringList(key, value);
  }

  /// Get string list
  List<String>? getStringList(String key) {
    return _preferences!.getStringList(key);
  }

  /// Remove value
  Future<bool> remove(String key) async {
    return await _preferences!.remove(key);
  }

  /// Clear all values
  Future<bool> clear() async {
    return await _preferences!.clear();
  }

  /// Check if key exists
  bool containsKey(String key) {
    return _preferences!.containsKey(key);
  }

  /// Get all keys
  Set<String> getKeys() {
    return _preferences!.getKeys();
  }
}

/// Storage keys constants
class StorageKeys {
  StorageKeys._();

  static const String authToken = 'auth_token';
  static const String userId = 'user_id';
  static const String userCpf = 'user_cpf';
  static const String userName = 'user_name';
  static const String userRole = 'user_role';
  static const String cinemaId = 'cinema_id';
  static const String cinemaName = 'cinema_name';
  static const String language = 'language';
  static const String themeMode = 'theme_mode';
}
