import 'package:flutter/material.dart';
import 'package:doz_shared/doz_shared.dart';

/// Notifications provider — fetches and manages driver notifications.
class NotificationsProvider extends ChangeNotifier {
  final ApiClient _api;

  List<NotificationModel> _notifications = [];
  bool _isLoading = false;
  bool _hasLoaded = false;
  String? _errorMessage;
  int _unreadCount = 0;

  NotificationsProvider({required ApiClient api}) : _api = api;

  List<NotificationModel> get notifications => List.unmodifiable(_notifications);
  bool get isLoading => _isLoading;
  bool get hasLoaded => _hasLoaded;
  String? get errorMessage => _errorMessage;
  int get unreadCount => _unreadCount;

  Future<void> loadNotifications() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _notifications = await _api.getNotifications(
        limit: AppConstants.notificationsPageSize,
      );
      _unreadCount = _notifications.where((n) => !n.isRead).length;
      _hasLoaded = true;
    } catch (e) {
      _errorMessage = e is ApiException ? e.message : e.toString();
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<void> markRead(String notificationId) async {
    try {
      await _api.markNotificationRead(notificationId);
      _notifications = _notifications.map((n) {
        if (n.id == notificationId) {
          return n.copyWith(isRead: true);
        }
        return n;
      }).toList();
      _unreadCount = _notifications.where((n) => !n.isRead).length;
      notifyListeners();
    } catch (_) {}
  }

  Future<void> markAllRead() async {
    try {
      await _api.markAllNotificationsRead();
      _notifications = _notifications.map((n) => n.copyWith(isRead: true)).toList();
      _unreadCount = 0;
      notifyListeners();
    } catch (e) {
      _errorMessage = e is ApiException ? e.message : e.toString();
      notifyListeners();
    }
  }

  void addNotification(NotificationModel notification) {
    _notifications.insert(0, notification);
    if (!notification.isRead) _unreadCount++;
    notifyListeners();
  }
}
