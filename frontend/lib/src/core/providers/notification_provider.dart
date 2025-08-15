import 'package:flutter/material.dart';
import '../models/notification_model.dart';
import '../services/api_service.dart';

class NotificationProvider extends ChangeNotifier {
  final ApiService _apiService;
  List<NotificationModel> _notifications = [];
  bool _loading = false;

  NotificationProvider(this._apiService);

  List<NotificationModel> get notifications => _notifications;
  int get unreadCount => _notifications.where((n) => !n.read).length;
  bool get loading => _loading;

  Future<void> fetchNotifications() async {
    _loading = true;
    notifyListeners();
    try {
      final data = await _apiService.getNotifications();
      _notifications = data
          .map<NotificationModel>(NotificationModel.fromJson)
          .toList();
    } catch (e) {
      // handle error
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  Future<void> markAsRead(String id) async {
    try {
      await _apiService.markNotificationAsRead(id);
      final idx = _notifications.indexWhere((n) => n.id == id);
      if (idx != -1) {
        _notifications[idx] = _notifications[idx].copyWith(read: true);
        notifyListeners();
      }
    } catch (e) {
      // handle error
    }
  }

  void addNotification(NotificationModel notification) {
    _notifications.insert(0, notification);
    notifyListeners();
  }
}
