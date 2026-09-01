import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:yoyu/features/home/data/repositories/widget_repository.dart';
import 'package:yoyu/features/home/domain/repositories/widget_data_port.dart';

final widgetRepositoryProvider = Provider<WidgetDataPort>((ref) {
  return WidgetRepository();
});
