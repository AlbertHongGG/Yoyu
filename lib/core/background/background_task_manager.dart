import 'package:workmanager/workmanager.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:yoyu/features/home/data/repositories/card_repository.dart';
import 'package:yoyu/features/home/data/repositories/widget_repository.dart';

@pragma('vm:entry-point')
void callbackDispatcher() {
  Workmanager().executeTask((task, inputData) async {
    try {
      // 1. Initialize a container since we are outside the widget tree
      final container = ProviderContainer();
      
      // 2. Fetch the latest card data from the repository
      final cardRepo = container.read(cardRepositoryProvider);
      final localCards = await cardRepo.loadCards(); 
      final updatedCards = await cardRepo.fetchLatestCardsBalance(localCards);
      
      // 3. Sync to widget
      final widgetRepo = WidgetRepository();
      await widgetRepo.syncCardsToWidget(updatedCards);
      
      return Future.value(true);
    } catch (e) {
      print('Background task failed: $e');
      return Future.value(false);
    }
  });
}

class BackgroundTaskManager {
  static const String syncTaskName = 'com.yoyu.app.backgroundSync';

  static Future<void> initialize() async {
    await Workmanager().initialize(
      callbackDispatcher,
      isInDebugMode: false,
    );
  }

  static void registerPeriodicSync() {
    Workmanager().registerPeriodicTask(
      'yoyu_periodic_sync_1',
      syncTaskName,
      frequency: const Duration(minutes: 15), // Android minimum is 15 mins
      constraints: Constraints(
        networkType: NetworkType.connected, // Require network
      ),
    );
  }
}
