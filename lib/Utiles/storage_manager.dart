import 'package:shared_preferences/shared_preferences.dart';

enum StorageKey {
  score('score'),
  music("music"),
  sound("sound"),
  name("name"),;

  final String rawValue;

  const StorageKey(this.rawValue);
}

class StorageManager {
  static final StorageManager _instance = StorageManager._internal();

  factory StorageManager() {
    return _instance;
  }

  StorageManager._internal();

   // MARK: -----Shared Preferences------
  Future<void> saveString(StorageKey key, String value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(key.rawValue, value);
  }

  Future<String?> getSavedString(StorageKey key) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(key.rawValue);
  }

  Future<void> saveInt(StorageKey key, int value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(key.rawValue, value);
  }

  Future<int?> getSavedInt(StorageKey key) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(key.rawValue);
  }

  Future<void> saveBool(StorageKey key, bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(key.rawValue, value);
  }

  Future<bool?> getSavedBool(StorageKey key) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(key.rawValue);
  }

  Future<bool> removeSharedString(StorageKey key) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.remove(key.rawValue);
  }
}