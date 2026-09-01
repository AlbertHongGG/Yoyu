import 'package:flutter_riverpod/flutter_riverpod.dart';

class DraggingStateNotifier extends Notifier<bool> {
  @override
  bool build() => false;

  void setDragging(bool value) {
    state = value;
  }
}

final isCardDraggingProvider = NotifierProvider<DraggingStateNotifier, bool>(() {
  return DraggingStateNotifier();
});
