import 'package:shared_preferences/shared_preferences.dart';

class StorageRepository {
  final SharedPreferences _preferences;

  StorageRepository._(this._preferences);

  static Future<StorageRepository> getInstance() async {
    final prefs = await SharedPreferences.getInstance();
    return StorageRepository._(prefs);
  }

  Future<bool> deleteString(String key) {
    return _preferences.remove(key);
  }

  Future<bool> putString(String key, {required String value}) {
    return _preferences.setString(key, value);
  }

  Future<bool> putStringList(String key, {required List<String> value}) {
    return _preferences.setStringList(key, value);
  }

  List<String> getStringList(String key, {List<String> defValue = const []}) {
    return _preferences.getStringList(key) ?? defValue;
  }

  String getString(String key, {String defValue = ''}) {
    return _preferences.getString(key) ?? defValue;
  }

  Future<bool> putInt(String key, {required int value}) {
    return _preferences.setInt(key, value);
  }

  int getInt(String key, {int defValue = 0}) {
    return _preferences.getInt(key) ?? defValue;
  }

  Future<bool> putBool(String key, {required bool value}) {
    return _preferences.setBool(key, value);
  }

  bool getBool(String key, {bool defValue = false}) {
    return _preferences.getBool(key) ?? defValue;
  }

  Future<bool> clearAll() {
    return _preferences.clear();
  }
}
