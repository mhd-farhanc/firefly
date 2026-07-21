import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class NotificationService {
  static final NotificationService _instance = NotificationService._();
  factory NotificationService() => _instance;
  NotificationService._();

  final FirebaseMessaging _messaging = FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin _localNotifications =
      FlutterLocalNotificationsPlugin();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  void Function(String senderId, String senderName)? onNotificationTap;

  Future<void> initialize() async {
    const androidChannel = AndroidNotificationChannel(
      'chat_messages',
      'Chat Messages',
      description: 'Notifications for incoming chat messages',
      importance: Importance.high,
      playSound: true,
    );

    await _localNotifications
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(androidChannel);

    const androidSettings =
        AndroidInitializationSettings('launcher_icon');
    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );
    const initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _localNotifications.initialize(
      initSettings,
      onDidReceiveNotificationResponse: (response) {
        final payload = response.payload;
        if (payload != null && payload.contains('|')) {
          final parts = payload.split('|');
          onNotificationTap?.call(parts[0], parts[1]);
        }
      },
    );

    final settings = await _messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    if (settings.authorizationStatus == AuthorizationStatus.authorized ||
        settings.authorizationStatus == AuthorizationStatus.provisional) {
      await _saveFcmToken();
    }

    _messaging.onTokenRefresh.listen(_saveFcmTokenToFirestore);

    FirebaseMessaging.onMessage.listen((message) {
      final data = message.data;
      final notification = message.notification;
      if (notification != null) {
        _showLocalNotification(
          data['senderId'],
          data['senderName'] ?? notification.title ?? 'New Message',
          notification.body ?? '',
        );
      }
    });

    FirebaseMessaging.onMessageOpenedApp.listen((message) {
      final data = message.data;
      final senderId = data['senderId'] as String?;
      final senderName = data['senderName'] as String?;
      if (senderId != null) {
        onNotificationTap?.call(senderId, senderName ?? 'Unknown');
      }
    });

    final initialMessage = await _messaging.getInitialMessage();
    if (initialMessage != null) {
      final data = initialMessage.data;
      final senderId = data['senderId'] as String?;
      final senderName = data['senderName'] as String?;
      if (senderId != null) {
        onNotificationTap?.call(senderId, senderName ?? 'Unknown');
      }
    }
  }

  Future<void> _saveFcmToken() async {
    final token = await _messaging.getToken();
    if (token != null) {
      _saveFcmTokenToFirestore(token);
    }
  }

  Future<void> _saveFcmTokenToFirestore(String token) async {
    final user = _auth.currentUser;
    if (user != null) {
      await _firestore.collection('users').doc(user.uid).set(
        {'fcmToken': token},
        SetOptions(merge: true),
      );
    }
  }

  Future<void> _showLocalNotification(
    String? senderId,
    String title,
    String body,
  ) async {
    const androidChannel = AndroidNotificationChannel(
      'chat_messages',
      'Chat Messages',
      description: 'Notifications for incoming chat messages',
      importance: Importance.high,
      playSound: true,
    );

    final details = AndroidNotificationDetails(
      androidChannel.id,
      androidChannel.name,
      channelDescription: androidChannel.description,
      importance: Importance.high,
      priority: Priority.high,
    );

    final payload = senderId != null ? '$senderId|$title' : null;

    await _localNotifications.show(
      DateTime.now().millisecondsSinceEpoch ~/ 1000,
      title,
      body,
      NotificationDetails(android: details),
      payload: payload,
    );
  }
}
