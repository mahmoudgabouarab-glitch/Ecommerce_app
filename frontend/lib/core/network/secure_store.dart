import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class SecureStore {
  SecureStore._();

  static const _storage = FlutterSecureStorage();

  static const _lastPassword = 'lastPassword';

  static Future<void> saveLastPassword(String value) =>
      _storage.write(key: _lastPassword, value: value);

  static Future<String?> readLastPassword() =>
      _storage.read(key: _lastPassword);

  static Future<void> clearLastPassword() =>
      _storage.delete(key: _lastPassword);
}
