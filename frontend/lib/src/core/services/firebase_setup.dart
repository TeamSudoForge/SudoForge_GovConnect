import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:provider/provider.dart';
import 'package:gov_connect/src/core/models/notification_model.dart';
import 'package:gov_connect/src/core/providers/notification_provider.dart';
import 'package:gov_connect/src/core/services/api_service.dart';
import 'package:gov_connect/src/injection.dart';
import 'package:flutter/material.dart';

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

Future<void> setupFirebaseAndNotifications() async {
  await Firebase.initializeApp();

  // Request notification permissions
  await FirebaseMessaging.instance.requestPermission();

  final fcmToken = await FirebaseMessaging.instance.getToken();
  if (fcmToken != null) {
    await ServiceLocator().apiService.sendFcmToken(fcmToken);
  }

  // Listen for foreground messages
  FirebaseMessaging.onMessage.listen((RemoteMessage message) {
    final notification = message.notification;
    if (notification != null) {
      final data = message.data;
      final provider = navigatorKey.currentContext != null
          ? Provider.of<NotificationProvider>(
              navigatorKey.currentContext!,
              listen: false,
            )
          : null;
      if (provider != null) {
        provider.addNotification(
          NotificationModel(
            id: data['id'] ?? DateTime.now().millisecondsSinceEpoch.toString(),
            title: notification.title ?? 'Notification',
            message: notification.body ?? '',
            createdAt: DateTime.now(),
            read: false,
            type: data['type'],
          ),
        );
      }
    }
    // Optionally: show local notification here
  });

  // Listen for background messages
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
}

Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  // TODO: handle background notification (e.g., update NotificationProvider)
}
