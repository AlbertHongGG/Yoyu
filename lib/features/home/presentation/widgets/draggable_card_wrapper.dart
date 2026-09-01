import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:yoyu/features/home/domain/models/card_entity.dart';
import 'package:yoyu/features/home/presentation/providers/dragging_state_provider.dart';

class DraggableCardWrapper extends ConsumerWidget {
  final CardEntity card;
  final Widget child;

  const DraggableCardWrapper({
    super.key,
    required this.card,
    required this.child,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return LongPressDraggable<CardEntity>(
      data: card,
      delay: const Duration(milliseconds: 200),
      onDragStarted: () {
        ref.read(isCardDraggingProvider.notifier).setDragging(true);
      },
      onDragEnd: (details) {
        ref.read(isCardDraggingProvider.notifier).setDragging(false);
      },
      onDraggableCanceled: (velocity, offset) {
        ref.read(isCardDraggingProvider.notifier).setDragging(false);
      },
      feedback: Material(
        type: MaterialType.transparency,
        child: SizedBox(
          width: MediaQuery.of(context).size.width - 40,
          child: Opacity(
            opacity: 0.8,
            child: Transform.scale(
              scale: 1.05,
              child: child,
            ),
          ),
        ),
      ),
      childWhenDragging: Opacity(
        opacity: 0.2,
        child: child,
      ),
      child: child,
    );
  }
}
