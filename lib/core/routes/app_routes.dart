import 'package:flutter/material.dart';
import '../../features/home/ui/home_screen.dart';
import '../../features/games/memory_cards/ui/memory_cards_select_screen.dart';
import '../../features/games/find_difference/ui/find_difference_select_screen.dart';
import '../../features/games/shape_matcher/ui/shape_matcher_select_screen.dart';
import '../../features/games/pattern_logic/ui/pattern_logic_select_screen.dart';
import '../../features/games/quick_math/ui/quick_math_select_screen.dart';
import '../../features/games/color_memory/ui/color_memory_select_screen.dart';
import '../../features/games/word_puzzle/ui/word_puzzle_select_screen.dart';
import '../../features/games/maze_runner/ui/maze_runner_select_screen.dart';
import '../../features/games/sorting_game/ui/sorting_game_select_screen.dart';
import '../../features/games/jigsaw_puzzle/ui/jigsaw_puzzle_select_screen.dart';
import '../../features/stickers/ui/sticker_album_screen.dart';
import '../../features/achievements/ui/achievements_screen.dart';
import '../../features/settings/ui/settings_screen.dart';
import '../../features/premium/ui/premium_screen.dart';
import '../../features/splash/ui/splash_screen.dart';
import '../../features/daily_gift/ui/daily_gift_screen.dart';
import '../../features/worlds/ui/world_select_screen.dart';
import '../../features/daily_challenge/ui/daily_challenge_screen.dart';
import '../../features/shop/ui/shop_screen.dart';
import '../../features/parent_dashboard/ui/parent_dashboard_screen.dart';
import '../../features/settings/ui/privacy_policy_screen.dart';
import '../../features/onboarding/ui/onboarding_screen.dart';

class AppRoutes {
  static const String splash = '/';
  static const String home = '/home';
  static const String memoryCards = '/memory-cards';
  static const String findDifference = '/find-difference';
  static const String shapeMatcher = '/shape-matcher';
  static const String patternLogic = '/pattern-logic';
  static const String quickMath = '/quick-math';
  static const String colorMemory = '/color-memory';
  static const String wordPuzzle = '/word-puzzle';
  static const String mazeRunner = '/maze-runner';
  static const String sortingGame = '/sorting-game';
  static const String jigsawPuzzle = '/jigsaw-puzzle';
  static const String stickers = '/stickers';
  static const String achievements = '/achievements';
  static const String settings = '/settings';
  static const String premium = '/premium';
  static const String dailyGift = '/daily-gift';
  static const String worlds = '/worlds';
  static const String dailyChallenge = '/daily-challenge';
  static const String shop = '/shop';
  static const String parentDashboard = '/parent-dashboard';
  static const String privacyPolicy = '/privacy-policy';
  static const String onboarding = '/onboarding';

  static Map<String, WidgetBuilder> get routes {
    return {
      splash: (context) => const SplashScreen(),
      home: (context) => const HomeScreen(),
      memoryCards: (context) => const MemoryCardsSelectScreen(),
      findDifference: (context) => const FindDifferenceSelectScreen(),
      shapeMatcher: (context) => const ShapeMatcherSelectScreen(),
      patternLogic: (context) => const PatternLogicSelectScreen(),
      quickMath: (context) => const QuickMathSelectScreen(),
      colorMemory: (context) => const ColorMemorySelectScreen(),
      wordPuzzle: (context) => const WordPuzzleSelectScreen(),
      mazeRunner: (context) => const MazeRunnerSelectScreen(),
      sortingGame: (context) => const SortingGameSelectScreen(),
      jigsawPuzzle: (context) => const JigsawPuzzleSelectScreen(),
      stickers: (context) => const StickerAlbumScreen(),
      achievements: (context) => const AchievementsScreen(),
      settings: (context) => const SettingsScreen(),
      premium: (context) => const PremiumScreen(),
      dailyGift: (context) => const DailyGiftScreen(),
      worlds: (context) => const WorldSelectScreen(),
      dailyChallenge: (context) => const DailyChallengeScreen(),
      shop: (context) => const ShopScreen(),
      parentDashboard: (context) => const ParentDashboardScreen(),
      privacyPolicy: (context) => const PrivacyPolicyScreen(),
      onboarding: (context) => const OnboardingScreen(),
    };
  }
}

