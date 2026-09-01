import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:yoyu/core/network/api_client.dart';
import 'package:yoyu/features/home/domain/models/card_entity.dart';

class CardRepository {
  final ApiClient _apiClient;
  static const String _prefsKey = 'saved_cards';

  CardRepository(this._apiClient);

  Future<CardEntity?> checkCard(String cardNo) async {
    try {
      final response = await _apiClient.post(
        'CheckMyCards',
        data: {
          "cardNos": [cardNo]
        },
      );

      final data = response.data;
      if (data['rtnCode'] == '0' && data['cardNos'] != null) {
        final List<dynamic> cardsData = data['cardNos'];
        if (cardsData.isNotEmpty) {
          final cardData = cardsData.first;
          
          if (cardData['errCode'] == '0') {
            return CardEntity.fromApi(cardData);
          } else {
             throw Exception(cardData['errMsg'] ?? '驗證失敗');
          }
        }
      } else {
        throw Exception(data['rtnMsg'] ?? '驗證失敗');
      }
    } catch (e) {
      rethrow;
    }
    return null;
  }

  Future<void> saveCards(List<CardEntity> cards) async {
    final prefs = await SharedPreferences.getInstance();
    final String jsonString = jsonEncode(cards.map((e) => e.toJson()).toList());
    await prefs.setString(_prefsKey, jsonString);
  }

  Future<List<CardEntity>> loadCards() async {
    final prefs = await SharedPreferences.getInstance();
    final String? jsonString = prefs.getString(_prefsKey);
    if (jsonString != null) {
      try {
        final List<dynamic> jsonList = jsonDecode(jsonString);
        return jsonList.map((e) => CardEntity.fromJson(e as Map<String, dynamic>)).toList();
      } catch (e) {
        return [];
      }
    }
    return [];
  }
  Future<List<CardEntity>> fetchLatestCardsBalance(List<CardEntity> existingCards) async {
    if (existingCards.isEmpty) return [];

    final updatedCards = <CardEntity>[];
    
    // In a real scenario, this could be a batch API call. 
    // Here we use checkCard for each.
    for (var card in existingCards) {
      try {
        final updatedCard = await checkCard(card.cardNo);
        if (updatedCard != null) {
          // preserve custom cardName and faceUrl from the local entity
          updatedCards.add(updatedCard.copyWith(
            cardName: card.cardName,
            cardFaceUrl: card.cardFaceUrl,
          ));
        } else {
          updatedCards.add(card);
        }
      } catch (e) {
        // Fallback to existing card on error
        updatedCards.add(card);
      }
    }
    
    await saveCards(updatedCards);
    return updatedCards;
  }
}

final cardRepositoryProvider = Provider<CardRepository>((ref) {
  return CardRepository(ref.watch(apiClientProvider));
});
