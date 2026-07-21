import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

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
    await Future.wait([
      _initFcm(),
      _initLocalNotifications(),
    ]);
  }

  Future<void> _initLocalNotifications() async {
    try {
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
          AndroidInitializationSettings('ic_launcher_foreground');
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
    } catch (e) {
      debugPrint('Local notifications init skipped: $e');
    }
  }

  Future<void> _initFcm() async {
    try {
      try {
        await _messaging.requestPermission(
          alert: true,
          badge: true,
          sound: true,
        );
      } catch (_) {
      }

      await _saveFcmToken();

      _messaging.onTokenRefresh.listen(_saveFcmTokenToFirestore);

      FirebaseMessaging.onMessage.listen((message) {
        final data = message.data;
        final notification = message.notification;
        if (notification != null) {
          _showLocalNotification(
            data['senderId'],
            notification.title ?? 'New Message',
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
    } catch (e) {
      debugPrint('FCM init error: $e');
    }
  }

  Future<void> _saveFcmToken() async {
    try {
      final token = await _messaging.getToken();
      if (token != null) {
        await _saveFcmTokenToFirestore(token);
        debugPrint('FCM token saved: ${token.substring(0, 20)}...');
      }
    } catch (e) {
      debugPrint('Failed to save FCM token: $e');
    }
  }

  Future<void> _saveFcmTokenToFirestore(String token) async {
    try {
      final user = _auth.currentUser;
      if (user != null) {
        await _firestore.collection('users').doc(user.uid).set(
          {'fcmToken': token},
          SetOptions(merge: true),
        );
      }
    } catch (e) {
      debugPrint('Failed to save FCM token to Firestore: $e');
    }
  }

  Future<void> _showLocalNotification(
    String? senderId,
    String title,
    String body,
  ) async {
    try {
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
    } catch (e) {
      debugPrint('Failed to show local notification: $e');
    }
  }
}
