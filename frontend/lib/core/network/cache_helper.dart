import 'package:shared_preferences/shared_preferences.dart';

class CacheHelper {
  static late SharedPreferences sharedPreferences;

  Future<void> init() async {
    sharedPreferences = await SharedPreferences.getInstance();
  }

  static String? getDataString({required String key}) {
    return sharedPreferences.getString(key);
  }

  static dynamic getData({required String key}) {
    return sharedPreferences.get(key);
  }

  static List<String> getStringList({required String key}) {
    return sharedPreferences.getStringList(key) ?? [];
  }

  static Future<bool> saveData({
    required String key,
    required dynamic value,
  }) async {
    if (value is bool) return sharedPreferences.setBool(key, value);
    if (value is int) return sharedPreferences.setInt(key, value);
    if (value is double) return sharedPreferences.setDouble(key, value);
    if (value is String) return sharedPreferences.setString(key, value);
    if (value is List<String>) {
      return sharedPreferences.setStringList(key, value);
    }
    throw Exception("Unsupported value type for CacheHelper.saveData");
  }

  static Future<bool> removeData({required String key}) {
    return sharedPreferences.remove(key);
  }

  static bool containsKey({required String key}) {
    return sharedPreferences.containsKey(key);
  }

  static Future<bool> clearData() {
    return sharedPreferences.clear();
  }
}
