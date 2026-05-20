import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:provider/provider.dart';
import 'package:minigenius/generated/l10n/app_localizations.dart';
import 'package:minigenius/core/theme/app_theme.dart';
import 'package:minigenius/core/routes/app_routes.dart';
import 'package:minigenius/core/providers/app_state_provider.dart';
import 'package:minigenius/core/services/notification_service.dart';
import 'package:minigenius/core/models/game_progress.dart';
import 'package:minigenius/core/models/user_progress.dart';
import 'package:minigenius/core/models/world.dart';
import 'package:minigenius/core/models/daily_challenge.dart';
import 'package:minigenius/core/models/currency.dart';
import 'package:minigenius/core/models/parent_dashboard.dart';
import 'package:minigenius/features/worlds/ui/world_levels_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Set preferred orientations
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  // Initialize Hive
  await Hive.initFlutter();
  
  // Register all adapters
  Hive.registerAdapter(GameProgressAdapter());
  Hive.registerAdapter(LevelProgressAdapter());
  Hive.registerAdapter(UserProgressAdapter());
  Hive.registerAdapter(WorldAdapter());
  Hive.registerAdapter(WorldProgressAdapter());
  Hive.registerAdapter(DailyChallengeAdapter());
  Hive.registerAdapter(ChallengeProgressAdapter());
  Hive.registerAdapter(StreakDataAdapter());
  Hive.registerAdapter(CurrencyAdapter());
  Hive.registerAdapter(ShopItemAdapter());
  Hive.registerAdapter(PurchasedItemAdapter());
  Hive.registerAdapter(ParentSettingsAdapter());
  Hive.registerAdapter(PlaySessionAdapter());
  Hive.registerAdapter(ChildProgressReportAdapter());

  // Initialize services
  final notificationService = NotificationService();
  await notificationService.initialize();

  // Create provider
  final appStateProvider = AppStateProvider();
  await appStateProvider.initialize();

  runApp(
    ChangeNotifierProvider.value(
      value: appStateProvider,
      child: const MiniGeniusApp(),
    ),
  );
}

class MiniGeniusApp extends StatelessWidget {
  const MiniGeniusApp({super.key});

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppStateProvider>();

    return MaterialApp(
      title: 'Mini Genius',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.getLightTheme(appState.locale.languageCode),
      darkTheme: AppTheme.getDarkTheme(appState.locale.languageCode),
      themeMode: appState.isDarkMode ? ThemeMode.dark : ThemeMode.light,
      
      // Localization
      locale: appState.locale,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      
      routes: AppRoutes.routes,
      onGenerateRoute: (settings) {
        if (settings.name != null && settings.name!.startsWith('/world/')) {
          final worldId = settings.name!.substring(7);
          return MaterialPageRoute(
            builder: (context) => WorldLevelsScreen(worldId: worldId),
            settings: settings,
          );
        }
        return null;
      },
      initialRoute: AppRoutes.splash,
    );
  }
}
