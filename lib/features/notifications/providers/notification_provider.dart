import 'package:flutter/material.dart';
import 'package:gestparc/features/notifications/services/notification_service.dart';

class NotificationProvider extends ChangeNotifier {
  final NotificationService _notificationService;

  NotificationProvider(this._notificationService);

  bool _isLoading = false;
  List<dynamic> _notifications = [];
  String? _error;

  bool get isLoading => _isLoading;
  List<dynamic> get notifications => _notifications;
  String? get error => _error;
  
  int get unreadCount => _notifications.where((n) => n['read'] == false).length;

  Future<void> loadNotifications() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final data = await _notificationService.getNotifications();
      _notifications = data['data'] ?? [];
      _isLoading = false;
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
    }
    notifyListeners();
  }

  Future<void> markAsRead(int id) async {
    try {
      await _notificationService.markAsRead(id);
      final index = _notifications.indexWhere((n) => n['id'] == id);
      if (index != -1) {
        _notifications[index]['read'] = true;
        notifyListeners();
      }
    } catch (e) {
      // Ignorer l'erreur pour la fluidité UI
    }
  }

  Future<void> markAllAsRead() async {
    try {
      await _notificationService.markAllAsRead();
      for (var n in _notifications) {
        n['read'] = true;
      }
      notifyListeners();
    } catch (e) {}
  }

  Future<void> deleteNotification(int id) async {
    try {
      await _notificationService.deleteNotification(id);
      _notifications.removeWhere((n) => n['id'] == id);
      notifyListeners();
    } catch (e) {}
  }

  Future<void> deleteAllRead() async {
    try {
      await _notificationService.deleteAllRead();
      _notifications.removeWhere((n) => n['read'] == true);
      notifyListeners();
    } catch (e) {}
  }
}
