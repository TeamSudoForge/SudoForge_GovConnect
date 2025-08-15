import 'package:flutter/material.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:gov_connect/src/injection.dart';
import '../services/notification_service.dart';

class NotificationProvider extends ChangeNotifier {
  final NotificationService _notificationService =
      ServiceLocator().notificationService;

  List<RemoteMessage> get notifications => _notificationService.notifications;
  String? get fcmToken => _notificationService.fcmToken;

  void clearNotifications() {
    _notificationService.clearNotifications();
  }
}
