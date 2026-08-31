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
            return CardEntity(
              cardNo: cardData['cardNo'],
              cardFaceUrl: cardData['cardImageUrl'] ?? 'https://static01-ipass.cdn.hinet.net/ipassapp/cardface/11.webp',
              lastTranSum: (cardData['LastTranSum'] ?? 0).toDouble(),
              lastTranDate: cardData['LastTranDate'] ?? '',
              isRegister: cardData['isRegister'] ?? false,
            );
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
}

final cardRepositoryProvider = Provider<CardRepository>((ref) {
  return CardRepository(ref.watch(apiClientProvider));
});
