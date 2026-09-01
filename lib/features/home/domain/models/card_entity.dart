import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:yoyu/core/constants/app_constants.dart';

part 'card_entity.freezed.dart';
part 'card_entity.g.dart';

@freezed
abstract class CardEntity with _$CardEntity {
  const factory CardEntity({
    required String cardNo,
    @Default('我的卡片') String cardName,
    @Default(AppConstants.defaultCardFaceUrl) String cardFaceUrl,
    required double lastTranSum,
    required bool isRegister,
  }) = _CardEntity;

  factory CardEntity.fromJson(Map<String, dynamic> json) => _$CardEntityFromJson(json);

  /// Defensive programming: Always use default face URL for new cards.
  factory CardEntity.fromApi(Map<String, dynamic> cardData) {
    return CardEntity(
      cardNo: cardData['cardNo']?.toString() ?? '',
      cardFaceUrl: AppConstants.defaultCardFaceUrl,
      lastTranSum: (cardData['LastTranSum'] ?? 0).toDouble(),
      isRegister: cardData['isRegister'] ?? false,
    );
  }
}
