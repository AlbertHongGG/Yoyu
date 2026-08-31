import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:yoyu/core/notifications/models/app_notification.dart';

class NotificationToast extends StatelessWidget {
  final AppNotification notification;
  final VoidCallback onDismiss;

  const NotificationToast({
    super.key,
    required this.notification,
    required this.onDismiss,
  });

  @override
  Widget build(BuildContext context) {
    Color typeColor;
    IconData typeIcon;

    switch (notification.type) {
      case NotificationType.success:
        typeColor = Colors.greenAccent;
        typeIcon = Icons.check_circle_outline;
        break;
      case NotificationType.error:
        typeColor = Colors.redAccent;
        typeIcon = Icons.error_outline;
        break;
      case NotificationType.info:
        typeColor = Colors.blueAccent;
        typeIcon = Icons.info_outline;
        break;
      case NotificationType.warning:
        typeColor = Colors.amberAccent;
        typeIcon = Icons.warning_amber_rounded;
        break;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 12, left: 16, right: 16),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              color: Theme.of(context).brightness == Brightness.dark
                  ? Colors.black.withValues(alpha: 0.4)
                  : Colors.white.withValues(alpha: 0.7),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: Theme.of(context).brightness == Brightness.dark
                    ? Colors.white.withValues(alpha: 0.1)
                    : Colors.black.withValues(alpha: 0.05),
                width: 1,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.1),
                  blurRadius: 20,
                  offset: const Offset(0, 8),
                )
              ],
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Icon(typeIcon, color: typeColor, size: 24),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    notification.message,
                    style: TextStyle(
                      color: Theme.of(context).brightness == Brightness.dark ? Colors.white : Colors.black87,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      decoration: TextDecoration.none,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                GestureDetector(
                  onTap: onDismiss,
                  child: Icon(
                    Icons.close, 
                    color: Theme.of(context).brightness == Brightness.dark ? Colors.white54 : Colors.black54, 
                    size: 20
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
