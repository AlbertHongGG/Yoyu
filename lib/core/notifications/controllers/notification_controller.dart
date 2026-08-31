import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import 'package:yoyu/core/notifications/models/app_notification.dart';

class NotificationController extends Notifier<List<AppNotification>> {
  @override
  List<AppNotification> build() {
    return [];
  }

  void _addNotification(AppNotification notification) {
    // Max 3 notifications on screen, drop oldest if exceeded
    final newState = [...state, notification];
    if (newState.length > 3) {
      newState.removeAt(0);
    }
    state = newState;

    Timer(notification.duration, () {
      remove(notification.id);
    });
  }

  void remove(String id) {
    state = state.where((n) => n.id != id).toList();
  }

  void showSuccess(String message, {Duration duration = const Duration(seconds: 4)}) {
    _addNotification(AppNotification(
      id: Uuid().v4(),
      type: NotificationType.success,
      message: message,
      duration: duration,
    ));
  }

  void showError(String message, {Duration duration = const Duration(seconds: 5)}) {
    _addNotification(AppNotification(
      id: Uuid().v4(),
      type: NotificationType.error,
      message: message,
      duration: duration,
    ));
  }

  void showWarning(String message, {Duration duration = const Duration(seconds: 4)}) {
    _addNotification(AppNotification(
      id: Uuid().v4(),
      type: NotificationType.warning,
      message: message,
      duration: duration,
    ));
  }

  void showInfo(String message, {Duration duration = const Duration(seconds: 4)}) {
    _addNotification(AppNotification(
      id: Uuid().v4(),
      type: NotificationType.info,
      message: message,
      duration: duration,
    ));
  }
}

final notificationProvider = NotifierProvider<NotificationController, List<AppNotification>>(() {
  return NotificationController();
});
