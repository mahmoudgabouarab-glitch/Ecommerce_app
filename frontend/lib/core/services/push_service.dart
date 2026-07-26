import 'dart:io';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

import '../../features/notifications/data/repo/notifications_repo_impl.dart';
import '../network/service_locator.dart';

@pragma('vm:entry-point')
Future<void> _firebaseBackgroundHandler(RemoteMessage message) async {
}

class PushService {
  PushService._();

  static bool _ready = false;

  static Future<void> initApp() async {
    try {
      await Firebase.initializeApp();
      FirebaseMessaging.onBackgroundMessage(_firebaseBackgroundHandler);
      _ready = true;
    } catch (_) {
      _ready = false;
    }
  }

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
