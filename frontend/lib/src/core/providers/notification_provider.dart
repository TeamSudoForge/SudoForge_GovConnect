import 'package:flutter/material.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import '../services/api_service.dart';
import '../services/notification_service.dart';

class NotificationProvider extends ChangeNotifier {
  final List<RemoteMessage> _notifications = [];
  String? _fcmToken;

  List<RemoteMessage> get notifications => List.unmodifiable(_notifications);
  String? get fcmToken => _fcmToken;

  Future<void> init() async {
    _fcmToken = await NotificationService().getToken();
    if (_fcmToken != null) {
      debugPrint('FCM Token: $_fcmToken');
      await ApiService().registerFcmToken(_fcmToken!);
    }
    FirebaseMessaging.onMessage.listen((message) {
      _notifications.insert(0, message);
      notifyListeners();
    });
  }

  void clearNotifications() {
    _notifications.clear();
    notifyListeners();
  }
}
