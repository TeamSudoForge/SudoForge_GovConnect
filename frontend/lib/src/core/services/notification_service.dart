import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter/material.dart';
import 'package:gov_connect/src/core/services/auth_service.dart';

import 'api_service.dart';

class NotificationService extends ChangeNotifier {
  final FirebaseMessaging _messaging = FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin _localNotifications =
      FlutterLocalNotificationsPlugin();

  AuthService? _authService; // inject AuthService
  String? _fcmToken;
  String? get fcmToken => _fcmToken;

  final List<RemoteMessage> _notifications = [];
  List<RemoteMessage> get notifications => List.unmodifiable(_notifications);

  void setAuthService(AuthService authService) {
    _authService = authService;
    // Listen for login/logout
    _authService!.addListener(() {
      if (_authService!.isAuthenticated) {
        _initializeNotifications();
      } else {
        clearNotifications();
      }
    });
  }

  Future<void> _initializeNotifications() async {
    debugPrint('Initializing Notification Service');

    await _messaging.requestPermission();

    const androidSettings = AndroidInitializationSettings(
      '@mipmap/ic_launcher',
    );
    const iosSettings = DarwinInitializationSettings();
    const initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );
    await _localNotifications.initialize(initSettings);

    await _registerFcmToken();

    FirebaseMessaging.onMessage.listen(_handleMessage);
    FirebaseMessaging.onMessageOpenedApp.listen(_handleOpenedApp);
  }

  Future<void> _registerFcmToken() async {
    _fcmToken = await _messaging.getToken();
    if (_fcmToken != null) {
      debugPrint('FCM Token: $_fcmToken');
      await ApiService().registerFcmToken(_fcmToken!);
    }

    FirebaseMessaging.instance.onTokenRefresh.listen((newToken) async {
      _fcmToken = newToken;
      await ApiService().registerFcmToken(newToken);
    });
  }

  void _handleMessage(RemoteMessage message) {
    _notifications.insert(0, message);
    showLocalNotification(message);
    notifyListeners();
  }

  void _handleOpenedApp(RemoteMessage message) {
    // Handle navigation/actions here
  }

  Future<void> showLocalNotification(RemoteMessage message) async {
    final notification = message.notification;
    if (notification != null) {
      const androidDetails = AndroidNotificationDetails(
        'default_channel',
        'Default',
        importance: Importance.max,
        priority: Priority.high,
      );
      const iosDetails = DarwinNotificationDetails();
      const details = NotificationDetails(
        android: androidDetails,
        iOS: iosDetails,
      );

      await _localNotifications.show(
        notification.hashCode,
        notification.title,
        notification.body,
        details,
      );
    }
  }

  void clearNotifications() {
    _notifications.clear();
    notifyListeners();
  }
}
