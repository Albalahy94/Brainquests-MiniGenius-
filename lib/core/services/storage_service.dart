import 'package:flutter/foundation.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../models/game_progress.dart';
import '../models/user_progress.dart';
import '../models/world.dart';
import '../models/daily_challenge.dart';
import '../models/currency.dart';
import '../models/parent_dashboard.dart';

class StorageService {
  static final StorageService _instance = StorageService._internal();

  factory StorageService() {
    return _instance;
  }

  StorageService._internal();
  static const String _gameProgressBox = 'game_progress';
  static const String _userProgressBox = 'user_progress';
  static const String _worldProgressBox = 'world_progress';
  static const String _challengeProgressBox = 'challenge_progress';
  static const String _streakBox = 'streak_data';
  static const String _shopItemsBox = 'shop_items';
  static const String _purchasedItemsBox = 'purchased_items';
  static const String _parentSettingsBox = 'parent_settings';
  static const String _playSessionsBox = 'play_sessions';

  Box<GameProgress>? _gameProgressBoxInstance;
  Box<UserProgress>? _userProgressBoxInstance;
  Box<WorldProgress>? _worldProgressBoxInstance;
  Box<ChallengeProgress>? _challengeProgressBoxInstance;
  Box<StreakData>? _streakBoxInstance;
  Box<PurchasedItem>? _purchasedItemsBoxInstance;
  Box<ParentSettings>? _parentSettingsBoxInstance;
  Box<PlaySession>? _playSessionsBoxInstance;

  Future<void>? _initFuture;
  bool _isInitializing = false;

  Future<void> init() async {
    // If already initialized, return immediately
    if (_userProgressBoxInstance != null) {
      return;
    }
    
    // If currently initializing, wait for the existing init to complete
    if (_isInitializing && _initFuture != null) {
      return _initFuture!;
    }
    
    // Start new initialization
    _isInitializing = true;
    _initFuture = _initImplementation().then((_) {
      _isInitializing = false;
    }).catchError((e, stackTrace) {
      _isInitializing = false;
      _initFuture = null; // Reset on error so we can retry
      throw e; // Re-throw the error
    });
    
    return _initFuture!;
  }

  Future<void> _initImplementation() async {
    try {
      // Game Progress
      if (!Hive.isBoxOpen(_gameProgressBox)) {
        _gameProgressBoxInstance =
            await Hive.openBox<GameProgress>(_gameProgressBox);
      } else {
        _gameProgressBoxInstance = Hive.box<GameProgress>(_gameProgressBox);
      }

      // User Progress
      if (!Hive.isBoxOpen(_userProgressBox)) {
        try {
          _userProgressBoxInstance =
              await Hive.openBox<UserProgress>(_userProgressBox);
          debugPrint('✅ UserProgress box opened');
        } catch (e) {
          // If opening fails due to data corruption, delete and recreate
          debugPrint('⚠️ Error opening UserProgress box: $e');
          debugPrint('🔄 Attempting to delete and recreate box...');
          try {
            await Hive.deleteBoxFromDisk(_userProgressBox);
            debugPrint('✅ Deleted corrupted UserProgress box');
          } catch (deleteError) {
            debugPrint('⚠️ Could not delete box: $deleteError');
          }
          // Try opening again
          _userProgressBoxInstance =
              await Hive.openBox<UserProgress>(_userProgressBox);
          debugPrint('✅ UserProgress box recreated successfully');
        }
      } else {
        _userProgressBoxInstance = Hive.box<UserProgress>(_userProgressBox);
        debugPrint('✅ UserProgress box already open');
      }
      
      // Verify the box is actually set
      if (_userProgressBoxInstance == null) {
        throw Exception('Failed to initialize UserProgress box');
      }

      // World Progress
      if (!Hive.isBoxOpen(_worldProgressBox)) {
        _worldProgressBoxInstance =
            await Hive.openBox<WorldProgress>(_worldProgressBox);
      } else {
        _worldProgressBoxInstance = Hive.box<WorldProgress>(_worldProgressBox);
      }

      // Challenge Progress
      if (!Hive.isBoxOpen(_challengeProgressBox)) {
        _challengeProgressBoxInstance =
            await Hive.openBox<ChallengeProgress>(_challengeProgressBox);
      } else {
        _challengeProgressBoxInstance =
            Hive.box<ChallengeProgress>(_challengeProgressBox);
      }

      // Streak
      if (!Hive.isBoxOpen(_streakBox)) {
        _streakBoxInstance = await Hive.openBox<StreakData>(_streakBox);
      } else {
        _streakBoxInstance = Hive.box<StreakData>(_streakBox);
      }

      // Purchased Items
      if (!Hive.isBoxOpen(_purchasedItemsBox)) {
        _purchasedItemsBoxInstance =
            await Hive.openBox<PurchasedItem>(_purchasedItemsBox);
      } else {
        _purchasedItemsBoxInstance =
            Hive.box<PurchasedItem>(_purchasedItemsBox);
      }

      // Parent Settings
      if (!Hive.isBoxOpen(_parentSettingsBox)) {
        _parentSettingsBoxInstance =
            await Hive.openBox<ParentSettings>(_parentSettingsBox);
      } else {
        _parentSettingsBoxInstance =
            Hive.box<ParentSettings>(_parentSettingsBox);
      }

      // Play Sessions
      if (!Hive.isBoxOpen(_playSessionsBox)) {
        _playSessionsBoxInstance =
            await Hive.openBox<PlaySession>(_playSessionsBox);
      } else {
        _playSessionsBoxInstance = Hive.box<PlaySession>(_playSessionsBox);
      }

      // Verify all critical boxes are initialized
      if (_userProgressBoxInstance == null) {
        throw Exception('UserProgress box failed to initialize');
      }
      
      // Initialize user progress if it doesn't exist
      if (_userProgressBoxInstance!.isEmpty) {
        await _userProgressBoxInstance!.put('user', UserProgress());
        debugPrint('✅ Initial UserProgress created');
      }

      debugPrint('✅ StorageService initialized successfully');
      debugPrint('✅ UserProgress box status: ${_userProgressBoxInstance != null ? "ready" : "null"}');
    } catch (e, stackTrace) {
      debugPrint('❌ Error initializing StorageService: $e');
      debugPrint('Stack: $stackTrace');
      // Re-throw to prevent silent failures
      rethrow;
    }
  }

  // Game Progress
  Future<void> saveGameProgress(GameProgress progress) async {
    await _gameProgressBoxInstance?.put(progress.gameId, progress);
  }

  GameProgress? getGameProgress(String gameId) {
    return _gameProgressBoxInstance?.get(gameId);
  }

  GameProgress getOrCreateGameProgress(String gameId) {
    final progress = getGameProgress(gameId);
    if (progress != null) {
      return progress;
    }

    final newProgress = GameProgress(gameId: gameId);
    saveGameProgress(newProgress);
    return newProgress;
  }

  // User Progress
  Future<void> saveUserProgress(UserProgress progress) async {
    // Ensure box is initialized - wait for init to complete
    if (_userProgressBoxInstance == null) {
      debugPrint('⚠️ UserProgress box is null, initializing...');
      await init();
      // Wait a bit for the box to be set
      int retries = 0;
      while (_userProgressBoxInstance == null && retries < 5) {
        await Future.delayed(const Duration(milliseconds: 100));
        retries++;
      }
    }
    
    if (_userProgressBoxInstance != null) {
      await _userProgressBoxInstance!.put('user', progress);
      debugPrint('✅ UserProgress saved to Hive - isTestMode: ${progress.isTestMode}');
    } else {
      debugPrint('❌ Cannot save UserProgress - box is still null after init');
      throw Exception('UserProgress box is not initialized');
    }
  }

  UserProgress getUserProgress() {
    return _userProgressBoxInstance?.get('user') ?? UserProgress();
  }

  Future<void> updateUserProgress(
      UserProgress Function(UserProgress) updater) async {
    // Ensure box is initialized - wait for init to complete
    if (_userProgressBoxInstance == null) {
      debugPrint('⚠️ UserProgress box is null in updateUserProgress, initializing...');
      await init();
      // Wait a bit for the box to be set
      int retries = 0;
      while (_userProgressBoxInstance == null && retries < 5) {
        await Future.delayed(const Duration(milliseconds: 100));
        retries++;
      }
    }
    
    if (_userProgressBoxInstance == null) {
      throw Exception('UserProgress box is not initialized after init()');
    }
    
    final current = getUserProgress();
    final updated = updater(current);
    await saveUserProgress(updated);
    
    // Verify the save was successful
    final saved = getUserProgress();
    debugPrint('✅ UserProgress saved - isTestMode: ${saved.isTestMode}');
  }

  // World Progress
  Future<void> saveWorldProgress(WorldProgress progress) async {
    await _worldProgressBoxInstance?.put(progress.worldId, progress);
  }

  WorldProgress? getWorldProgress(String worldId) {
    return _worldProgressBoxInstance?.get(worldId);
  }

  WorldProgress getOrCreateWorldProgress(String worldId) {
    final progress = getWorldProgress(worldId);
    if (progress != null) {
      return progress;
    }
    final newProgress = WorldProgress(worldId: worldId);
    saveWorldProgress(newProgress);
    return newProgress;
  }

  // Challenge Progress
  Future<void> saveChallengeProgress(ChallengeProgress progress) async {
    await _challengeProgressBoxInstance?.put(progress.challengeId, progress);
  }

  ChallengeProgress? getChallengeProgress(String challengeId) {
    return _challengeProgressBoxInstance?.get(challengeId);
  }

  // Streak Data
  Future<void> saveStreakData(StreakData streak) async {
    await _streakBoxInstance?.put('streak', streak);
  }

  StreakData getStreakData() {
    return _streakBoxInstance?.get('streak') ?? StreakData();
  }

  // Purchased Items
  Future<void> savePurchasedItem(PurchasedItem item) async {
    await _purchasedItemsBoxInstance?.put(item.itemId, item);
  }

  bool isItemPurchased(String itemId) {
    return _purchasedItemsBoxInstance?.containsKey(itemId) ?? false;
  }

  List<PurchasedItem> getAllPurchasedItems() {
    return _purchasedItemsBoxInstance?.values.toList() ?? [];
  }

  // Parent Settings
  Future<void> saveParentSettings(ParentSettings settings) async {
    await _parentSettingsBoxInstance?.put('settings', settings);
  }

  ParentSettings getParentSettings() {
    return _parentSettingsBoxInstance?.get('settings') ?? ParentSettings();
  }

  // Play Sessions
  Future<void> savePlaySession(PlaySession session) async {
    final key = '${session.startTime.millisecondsSinceEpoch}_${session.gameId}';
    await _playSessionsBoxInstance?.put(key, session);
  }

  List<PlaySession> getPlaySessions({
    DateTime? startDate,
    DateTime? endDate,
  }) {
    final allSessions = _playSessionsBoxInstance?.values.toList() ?? [];
    if (startDate != null || endDate != null) {
      return allSessions.where((session) {
        if (startDate != null && session.startTime.isBefore(startDate)) {
          return false;
        }
        if (endDate != null && session.startTime.isAfter(endDate)) {
          return false;
        }
        return true;
      }).toList();
    }
    return allSessions;
  }

  // Account Deletion / Data Wipe
  Future<void> clearAllData() async {
    try {
      await _gameProgressBoxInstance?.clear();
      await _userProgressBoxInstance?.clear();
      await _worldProgressBoxInstance?.clear();
      await _challengeProgressBoxInstance?.clear();
      await _streakBoxInstance?.clear();
      await _purchasedItemsBoxInstance?.clear();
      await _parentSettingsBoxInstance?.clear();
      await _playSessionsBoxInstance?.clear();
      
      // Re-initialize default user progress
      await _userProgressBoxInstance?.put('user', UserProgress());
      debugPrint('✅ All app data has been successfully wiped.');
    } catch (e) {
      debugPrint('❌ Error clearing data: $e');
      rethrow;
    }
  }
}
