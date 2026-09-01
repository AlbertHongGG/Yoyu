import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:yoyu/features/home/domain/models/card_entity.dart';
import 'package:yoyu/features/home/presentation/controllers/card_list_controller.dart';
import 'package:yoyu/features/home/presentation/providers/dragging_state_provider.dart';
import 'package:yoyu/features/home/presentation/widgets/add_card_bottom_sheet.dart';

class SmartFloatingActionTarget extends ConsumerWidget {
  const SmartFloatingActionTarget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDragging = ref.watch(isCardDraggingProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return DragTarget<CardEntity>(
      onAcceptWithDetails: (details) async {
        HapticFeedback.heavyImpact();
        await ref.read(cardListProvider.notifier).removeCard(details.data.cardNo);
      },
      builder: (context, candidateData, rejectedData) {
        final isHovering = candidateData.isNotEmpty;

        Color containerColor;
        Color borderColor;
        Color iconColor;
        double size;
        IconData iconData;

        if (isHovering) {
          containerColor = Colors.redAccent.withValues(alpha: 0.9);
          borderColor = Colors.red;
          iconColor = Colors.white;
          size = 64.0;
          iconData = Icons.delete_forever;
        } else if (isDragging) {
          containerColor = isDark
              ? Colors.black.withValues(alpha: 0.6)
              : Colors.white.withValues(alpha: 0.8);
          borderColor = isDark ? Colors.white12 : Colors.black12;
          iconColor = isDark ? Colors.white70 : Colors.black54;
          size = 56.0;
          iconData = Icons.delete_outline;
        } else {
          containerColor = isDark
              ? Colors.black.withValues(alpha: 0.6)
              : Colors.white.withValues(alpha: 0.8);
          borderColor = isDark ? Colors.white12 : Colors.black12;
          iconColor = isDark ? Colors.white70 : Colors.black54;
          size = 56.0;
          iconData = Icons.add_rounded;
        }

        return GestureDetector(
          onTap: isDragging ? null : () => showAddCardBottomSheet(context),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            curve: Curves.easeOut,
            width: size,
            height: size,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: containerColor,
              boxShadow: [
                BoxShadow(
                  color: isHovering
                      ? Colors.redAccent.withValues(alpha: 0.4)
                      : Colors.black.withValues(alpha: 0.1),
                  blurRadius: isHovering ? 20 : 10,
                  offset: const Offset(0, 4),
                )
              ],
              border: Border.all(
                color: borderColor,
                width: isHovering ? 2 : 1,
              ),
            ),
            child: ClipOval(
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                child: Icon(
                  iconData,
                  color: iconColor,
                  size: isHovering ? 32 : 28,
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
