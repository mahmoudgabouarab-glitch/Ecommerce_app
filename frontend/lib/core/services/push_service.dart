import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

import '../../features/notifications/data/repo/notifications_repo_impl.dart';
import '../network/service_locator.dart';

@pragma('vm:entry-point')
Future<void> _firebaseBackgroundHandler(RemoteMessage message) async {}

class PushService {
  PushService._();

  static bool _ready = false;

  static final _local = FlutterLocalNotificationsPlugin();

  static const _channel = AndroidNotificationChannel(
    'order_updates',
    'Order updates',
    description: 'Order status and payment notifications',
    importance: Importance.high,
  );

  static VoidCallback? onForegroundMessage;

  static Future<void> initApp() async {
    try {
      await Firebase.initializeApp();
      FirebaseMessaging.onBackgroundMessage(_firebaseBackgroundHandler);
      await _initLocalNotifications();
      FirebaseMessaging.onMessage.listen(_showForeground);
      _ready = true;
    } catch (_) {
      _ready = false;
    }
  }

  static Future<void> _initLocalNotifications() async {
    const settings = InitializationSettings(
      android: AndroidInitializationSettings('@mipmap/ic_launcher'),
      iOS: DarwinInitializationSettings(),
    );
    await _local.initialize(settings);
    await _local
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(_channel);
  }

  static Future<void> _showForeground(RemoteMessage message) async {
    final notification = message.notification;
    final title = notification?.title ?? message.data['title'];
    final body = notification?.body ?? message.data['body'];
    final imageUrl = notification?.android?.imageUrl ?? message.data['image'];

    onForegroundMessage?.call();
    if (title == null && body == null) return;

    final bytes = imageUrl == null ? null : await _download(imageUrl);
    final styleInformation = bytes == null
        ? null
        : BigPictureStyleInformation(ByteArrayAndroidBitmap(bytes),
            hideExpandedLargeIcon: true);

    await _local.show(
      DateTime.now().millisecondsSinceEpoch ~/ 1000,
      title,
      body,
      NotificationDetails(
        android: AndroidNotificationDetails(
          _channel.id,
          _channel.name,
          channelDescription: _channel.description,
          importance: Importance.high,
          priority: Priority.high,
          icon: '@mipmap/ic_launcher',
          largeIcon: bytes == null ? null : ByteArrayAndroidBitmap(bytes),
          styleInformation: styleInformation,
        ),
        iOS: const DarwinNotificationDetails(),
      ),
      payload: jsonEncode(message.data),
    );
  }

  static Future<Uint8List?> _download(String url) async {
    try {
      final client = HttpClient();
      final response = await (await client.getUrl(Uri.parse(url))).close();
      final builder = BytesBuilder();
      await for (final chunk in response) {
        builder.add(chunk);
      }
      client.close();
      return builder.takeBytes();
    } catch (_) {
      return null;
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
