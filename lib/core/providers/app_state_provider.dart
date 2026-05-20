import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import '../services/storage_service.dart';
import '../models/user_progress.dart';
import '../models/game_progress.dart';

class AppStateProvider extends ChangeNotifier {
  final StorageService _storageService = StorageService();
  UserProgress? _userProgress;
  Map<String, GameProgress> _gameProgress = {};

  bool get isDarkMode => _userProgress?.isDarkMode ?? false;
  Locale get locale => Locale(_userProgress?.languageCode ?? 'en');

  Future<void> initialize() async {
    try {
      await _storageService.init();
      _userProgress = _storageService.getUserProgress();
      
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

  void setLanguage(String languageCode) {
    if (_userProgress == null) return;
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

