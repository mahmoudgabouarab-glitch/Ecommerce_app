import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Encrypted key-value storage (Keychain on iOS, Keystore on Android) for
/// sensitive values that must not sit in plain SharedPreferences.
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
