import 'dart:io';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

import '../../features/notifications/data/repo/notifications_repo_impl.dart';
import '../network/service_locator.dart';

@pragma('vm:entry-point')
Future<void> _firebaseBackgroundHandler(RemoteMessage message) async {
  // The system tray displays "notification" messages automatically; the app
  // doesn't need to do anything here.
}

/// Thin wrapper around Firebase Cloud Messaging. Every call is guarded so the
/// app keeps working (with in-app notifications) even before Firebase is set
/// up via `flutterfire configure` — push simply stays disabled until then.
class PushService {
  PushService._();

  static bool _ready = false;

  /// Initialize Firebase and the background handler. Call once at startup.
  static Future<void> initApp() async {
    try {
      await Firebase.initializeApp();
      FirebaseMessaging.onBackgroundMessage(_firebaseBackgroundHandler);
      _ready = true;
    } catch (_) {
      _ready = false; // Firebase not configured yet — push disabled.
    }
  }

  /// Request permission, fetch the FCM token, and register it with the API.
  /// Call after the user is logged in.
  static Future<void> registerDevice() async {
    if (!_ready) return;
    try {
      final messaging = FirebaseMessaging.instance;
      await messaging.requestPermission();
      final token = await messaging.getToken();
      if (token != null) await _send(token);
      messaging.onTokenRefresh.listen(_send);
    } catch (_) {}
  }

  static Future<void> _send(String token) async {
    await getIt<NotificationsRepoImpl>().registerDevice(
      token: token,
      platform: Platform.isIOS ? 'ios' : 'android',
    );
  }

  /// Remove this device's token from the API (call before clearing the auth
  /// token on logout).
  static Future<void> unregister() async {
    if (!_ready) return;
    try {
      final token = await FirebaseMessaging.instance.getToken();
      if (token != null) {
        await getIt<NotificationsRepoImpl>().unregisterDevice(token);
      }
    } catch (_) {}
  }
}
