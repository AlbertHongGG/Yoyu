import 'package:uuid/uuid.dart';

enum NotificationType {
  success,
  error,
  info,
  warning
}

class AppNotification {
  final String id;
  final String message;
  final NotificationType type;
  final Duration duration;

  AppNotification({
    String? id,
    required this.message,
    required this.type,
    this.duration = const Duration(seconds: 4),
  }) : id = id ?? Uuid().v4();
}
