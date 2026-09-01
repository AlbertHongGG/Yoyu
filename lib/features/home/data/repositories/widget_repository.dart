import 'dart:convert';
import 'package:home_widget/home_widget.dart';
import 'package:yoyu/features/home/domain/models/card_entity.dart';
import 'package:yoyu/features/home/domain/repositories/widget_data_port.dart';

class WidgetRepository implements WidgetDataPort {
  static const String _groupId = 'group.com.yoyu.app'; // iOS App Group ID
  static const String _iOSWidgetName = 'YoyuWidget';
  static const String _androidWidgetName = 'YoyuWidgetProvider';
  static const String _widgetDataKey = 'widget_cards_data';

  WidgetRepository() {
    // Initialize home_widget with AppGroup
    HomeWidget.setAppGroupId(_groupId);
  }

  @override
  Future<void> syncCardsToWidget(List<CardEntity> cards) async {
    try {
      // 1. Serialize cards to JSON string
      final List<Map<String, dynamic>> jsonList = cards.map((e) => e.toJson()).toList();
      final String jsonString = jsonEncode(jsonList);

      // 2. Save to shared preferences (accessible by native)
      await HomeWidget.saveWidgetData<String>(_widgetDataKey, jsonString);

      // 3. Trigger native widget update
      await HomeWidget.updateWidget(
        iOSName: _iOSWidgetName,
        androidName: _androidWidgetName,
      );
    } catch (e) {
      // Error handling (e.g. log)
      print('Error syncing cards to widget: $e');
    }
  }
}
