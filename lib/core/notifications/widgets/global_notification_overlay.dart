import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:yoyu/core/notifications/controllers/notification_controller.dart';
import 'package:yoyu/core/notifications/widgets/notification_toast.dart';

class GlobalNotificationOverlay extends ConsumerWidget {
  final Widget child;

  const GlobalNotificationOverlay({
    super.key,
    required this.child,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notifications = ref.watch(notificationProvider);

    return Material(
      type: MaterialType.transparency,
      child: Stack(
        children: [
          child,
          // Notification Layer
          Positioned(
            top: MediaQuery.of(context).padding.top + 16, // Safe area + padding
            left: 0,
            right: 0,
            child: IgnorePointer(
              ignoring: notifications.isEmpty, // Allow touches to pass through when empty
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: notifications.map((n) {
                  return IgnorePointer(
                    ignoring: false, // Make the toast itself interactive
                    child: TweenAnimationBuilder<double>(
                      key: ValueKey(n.id),
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.easeOutQuart,
                      tween: Tween(begin: 0.0, end: 1.0),
                      builder: (context, value, child) {
                        return Transform.translate(
                          offset: Offset(0, -50 * (1 - value)),
                          child: Opacity(
                            opacity: value,
                            child: child,
                          ),
                        );
                      },
                      child: NotificationToast(
                        notification: n,
                        onDismiss: () => ref.read(notificationProvider.notifier).remove(n.id),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
