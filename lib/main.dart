import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:yoyu/core/router/app_router.dart';
import 'package:yoyu/core/theme/app_theme.dart';
import 'package:yoyu/core/notifications/widgets/global_notification_overlay.dart';
import 'package:yoyu/features/splash/splash_page.dart';
import 'package:yoyu/core/background/background_task_manager.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await BackgroundTaskManager.initialize();
  BackgroundTaskManager.registerPeriodicSync();
  
  runApp(
    const ProviderScope(
      child: YoyuBootstrap(),
    ),
  );
}

class YoyuBootstrap extends StatefulWidget {
  const YoyuBootstrap({super.key});

  @override
  State<YoyuBootstrap> createState() => _YoyuBootstrapState();
}

class _YoyuBootstrapState extends State<YoyuBootstrap> {
  bool _isInitialized = false;

  @override
  Widget build(BuildContext context) {
    if (!_isInitialized) {
      return MaterialApp(
        debugShowCheckedModeBanner: false,
        home: SplashPage(
          onInitializationComplete: () {
            if (mounted) {
              setState(() {
                _isInitialized = true;
              });
            }
          },
        ),
      );
    }
    return const MyApp();
  }
}

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(routerProvider);
    
    return MaterialApp.router(
      title: 'Yoyu',
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.system,
      routerConfig: router,
      debugShowCheckedModeBanner: false,
      builder: (context, child) {
        return GlobalNotificationOverlay(
          child: child ?? const SizedBox.shrink(),
        );
      },
    );
  }
}
