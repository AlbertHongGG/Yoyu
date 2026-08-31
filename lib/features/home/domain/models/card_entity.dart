import 'package:freezed_annotation/freezed_annotation.dart';

part 'card_entity.freezed.dart';
part 'card_entity.g.dart';

@freezed
abstract class CardEntity with _$CardEntity {
  const factory CardEntity({
    required String cardNo,
    @Default('我的卡片') String cardName,
    @Default('https://static01-ipass.cdn.hinet.net/ipassapp/cardface/11.webp') String cardFaceUrl,
    required double lastTranSum,
    required bool isRegister,
  }) = _CardEntity;

  factory CardEntity.fromJson(Map<String, dynamic> json) => _$CardEntityFromJson(json);
}
