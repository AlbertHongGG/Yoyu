import 'package:yoyu/features/home/domain/models/card_entity.dart';

abstract class WidgetDataPort {
  /// 將最新的卡片資料同步給原生 Widget 共享空間
  Future<void> syncCardsToWidget(List<CardEntity> cards);
}
