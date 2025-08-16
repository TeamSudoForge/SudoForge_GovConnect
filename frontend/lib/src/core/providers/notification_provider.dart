import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../../injection.dart';

class NotificationProvider extends ChangeNotifier {
  final ApiService _apiService = ServiceLocator().apiService;

  List<NotificationDto> _notifications = [];
  bool _loading = false;
  String? _error;

  List<NotificationDto> get notifications => _notifications;
  bool get loading => _loading;
  String? get error => _error;

  int get unreadCount => _notifications.where((n) => !n.read).length;

  Future<void> fetchNotifications() async {
    _loading = true;
    _error = null;
    notifyListeners();
    try {
      _notifications = await _apiService.fetchNotifications();
    } catch (e) {
      _error = e.toString();
    }
    _loading = false;
    notifyListeners();
  }

  List<NotificationDto> filtered(bool showUnread) {
    return showUnread
        ? _notifications.where((n) => !n.read).toList()
        : _notifications;
  }

  Future<void> markAsRead(String id) async {
    await _apiService.markNotificationAsRead(id);
    final idx = _notifications.indexWhere((n) => n.id == id);
    if (idx != -1) {
      _notifications[idx] = NotificationDto(
        id: _notifications[idx].id,
        title: _notifications[idx].title,
        body: _notifications[idx].body,
        read: true,
        createdAt: _notifications[idx].createdAt,
      );
      notifyListeners();
    }
  }

  void clearNotifications() {
    _notifications.clear();
    notifyListeners();
  }
}
