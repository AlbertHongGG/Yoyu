import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:yoyu/features/home/domain/models/card_entity.dart';
import 'package:yoyu/features/home/data/repositories/card_repository.dart';
import 'package:yoyu/core/notifications/controllers/notification_controller.dart';

class CardListNotifier extends AsyncNotifier<List<CardEntity>> {
  @override
  Future<List<CardEntity>> build() async {
    return ref.read(cardRepositoryProvider).loadCards();
  }

  Future<bool> addCard(String cardNo, String cardName) async {
    final currentCards = state.value ?? [];
    if (currentCards.any((c) => c.cardNo == cardNo)) {
      ref.read(notificationProvider.notifier).showWarning('此卡片已存在');
      return false;
    }

    try {
      var newCard = await ref.read(cardRepositoryProvider).checkCard(cardNo);
      if (newCard != null) {
        newCard = newCard.copyWith(cardName: cardName.isNotEmpty ? cardName : '我的卡片');
        final updatedCards = [...currentCards, newCard];
        state = AsyncData(updatedCards);
        await ref.read(cardRepositoryProvider).saveCards(updatedCards);
        ref.read(notificationProvider.notifier).showSuccess('新增卡片成功');
        return true;
      }
      return false;
    } catch (e) {
      ref.read(notificationProvider.notifier).showError(e.toString().replaceAll('Exception: ', ''));
      return false;
    }
  }

  Future<void> updateCard(CardEntity updatedCard) async {
    final currentCards = state.value ?? [];
    final updatedCards = currentCards.map((c) => c.cardNo == updatedCard.cardNo ? updatedCard : c).toList();
    state = AsyncData(updatedCards);
    await ref.read(cardRepositoryProvider).saveCards(updatedCards);
  }
  
  Future<void> removeCard(String cardNo) async {
    final currentCards = state.value ?? [];
    final updatedCards = currentCards.where((c) => c.cardNo != cardNo).toList();
    state = AsyncData(updatedCards);
    await ref.read(cardRepositoryProvider).saveCards(updatedCards);
  }
}

final cardListProvider = AsyncNotifierProvider<CardListNotifier, List<CardEntity>>(() {
  return CardListNotifier();
});
