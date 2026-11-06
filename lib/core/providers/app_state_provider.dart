import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import '../services/storage_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/licensing_api_service.dart';
import '../models/user_progress.dart';
import '../models/game_progress.dart';

class AppStateProvider extends ChangeNotifier {
  final StorageService _storageService = StorageService();
  UserProgress? _userProgress;
  Map<String, GameProgress> _gameProgress = {};

  bool get isDarkMode => _userProgress?.isDarkMode ?? false;
  Locale get locale {
    final lang = _userProgress?.languageCode;
    if (lang != null && lang.isNotEmpty) {
      return Locale(lang);
    }
    final deviceLang = WidgetsBinding.instance.platformDispatcher.locale.languageCode;
    return deviceLang == 'ar' ? const Locale('ar') : const Locale('en');
  }

  Future<void> initialize() async {
    try {
      await _storageService.init();
      _userProgress = _storageService.getUserProgress();

      // On first launch or if user hasn't explicitly chosen, match device system language
      try {
        final prefs = await SharedPreferences.getInstance();
        final hasSelected = prefs.getBool('has_user_selected_language') ?? false;
        if (!hasSelected) {
          final deviceLang = WidgetsBinding.instance.platformDispatcher.locale.languageCode;
          final initialLang = deviceLang == 'ar' ? 'ar' : 'en';
          if (_userProgress != null && _userProgress!.languageCode != initialLang) {
            _userProgress!.languageCode = initialLang;
            await _storageService.saveUserProgress(_userProgress!);
          }
        }
      } catch (e) {
        debugPrint('Device language auto-detect note: $e');
      }
      
      // Load all game progress
      final gameIds = [
        'memory_cards', 'find_difference', 'shape_matcher', 
        'pattern_logic', 'quick_math', 'color_memory',
        'word_puzzle', 'maze_runner', 'sorting_game', 'jigsaw_puzzle',
      ];
      for (var gameId in gameIds) {
        try {
          _gameProgress[gameId] = _storageService.getOrCreateGameProgress(gameId);
        } catch (e) {
          debugPrint('Error loading progress for $gameId: $e');
          // Continue with other games
        }
      }
      
      notifyListeners();
      debugPrint('✅ AppStateProvider initialized successfully');

      // Verify central device license status on app launch (non-blocking)
      LicensingApiService().verifyLicense().then((res) {
        final subData = res['data'] as Map<String, dynamic>?;
        if (subData != null) {
          _userProgress = _storageService.getUserProgress();
          notifyListeners();
        }
      }).catchError((e) {
        debugPrint('⚠️ Central license check on launch skipped: $e');
      });
    } catch (e, stackTrace) {
      debugPrint('❌ Error initializing AppStateProvider: $e');
      debugPrint('Stack: $stackTrace');
      // Create default user progress if initialization fails
      _userProgress = UserProgress();
      notifyListeners();
    }
  }

  void toggleDarkMode(bool? value) {
    if (_userProgress == null) return;
    final newValue = value ?? !_userProgress!.isDarkMode;
    updateUserProgress((progress) => progress.copyWith(isDarkMode: newValue));
  }

  void setLanguage(String languageCode) async {
    if (_userProgress == null) return;
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('has_user_selected_language', true);
    } catch (_) {}
    updateUserProgress((progress) => progress.copyWith(languageCode: languageCode));
  }

  void updateUserProgress(UserProgress Function(UserProgress) updater) {
    if (_userProgress == null) return;
    
    _userProgress = updater(_userProgress!);
    _storageService.saveUserProgress(_userProgress!);
    notifyListeners();
  }

  void updateGameProgress(String gameId, GameProgress Function(GameProgress) updater) {
    if (!_gameProgress.containsKey(gameId)) {
      _gameProgress[gameId] = _storageService.getOrCreateGameProgress(gameId);
    }
    
    _gameProgress[gameId] = updater(_gameProgress[gameId]!);
    _storageService.saveGameProgress(_gameProgress[gameId]!);
    notifyListeners();
  }

  void refreshGameProgress(String gameId) {
    _gameProgress[gameId] = _storageService.getOrCreateGameProgress(gameId);
    notifyListeners();
  }

  void refreshUserProgress() {
    _userProgress = _storageService.getUserProgress();
    notifyListeners();
  }
}

