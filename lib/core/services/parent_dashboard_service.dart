import '../models/parent_dashboard.dart';
import 'storage_service.dart';

class ParentDashboardService {
  static final ParentDashboardService _instance = ParentDashboardService._internal();
  factory ParentDashboardService() => _instance;
  ParentDashboardService._internal();

  final StorageService _storageService = StorageService();

  ParentSettings getSettings() {
    return _storageService.getParentSettings();
  }

  Future<void> updateSettings(ParentSettings settings) async {
    await _storageService.saveParentSettings(settings);
  }

  Future<void> savePlaySession(PlaySession session) async {
    await _storageService.savePlaySession(session);
  }

  ChildProgressReport generateReport({
    DateTime? startDate,
    DateTime? endDate,
  }) {
    final end = endDate ?? DateTime.now();
    final start = startDate ?? DateTime.now().subtract(const Duration(days: 7));

    final sessions = _storageService.getPlaySessions(
      startDate: start,
      endDate: end,
    );

    // Calculate statistics
    int totalPlayTime = 0;
    final gameStats = <String, int>{};
    final gameScores = <String, List<int>>{};
    final achievementsUnlocked = <String>[];

    for (final session in sessions) {
      totalPlayTime += session.duration.inMinutes;
      
      gameStats[session.gameId] = (gameStats[session.gameId] ?? 0) + 1;
      
      if (!gameScores.containsKey(session.gameId)) {
        gameScores[session.gameId] = [];
      }
      gameScores[session.gameId]!.add(session.score);
    }

    // Calculate average scores
    final averageScores = <String, double>{};
    gameScores.forEach((gameId, scores) {
      if (scores.isNotEmpty) {
        averageScores[gameId] = scores.reduce((a, b) => a + b) / scores.length;
      }
    });

    // Get user progress for achievements
    final userProgress = _storageService.getUserProgress();
    achievementsUnlocked.addAll(userProgress.unlockedBadges);

    // Get total levels completed
    final gameIds = ['memory_cards', 'find_difference', 'shape_matcher', 
                     'pattern_logic', 'quick_math', 'color_memory'];
    int totalLevelsCompleted = 0;
    for (final gameId in gameIds) {
      final progress = _storageService.getGameProgress(gameId);
      if (progress != null) {
        totalLevelsCompleted += progress.completedLevels;
      }
    }

    return ChildProgressReport(
      reportDate: DateTime.now(),
      totalPlayTime: totalPlayTime,
      gamesPlayed: sessions.length,
      levelsCompleted: totalLevelsCompleted,
      totalStars: userProgress.totalStars,
      gameStats: gameStats,
      averageScores: averageScores,
      achievementsUnlocked: achievementsUnlocked,
    );
  }

  int getTodayPlayTime() {
    final today = DateTime.now();
    final startOfDay = DateTime(today.year, today.month, today.day);
    final endOfDay = startOfDay.add(const Duration(days: 1));

    final sessions = _storageService.getPlaySessions(
      startDate: startOfDay,
      endDate: endOfDay,
    );

    int totalMinutes = 0;
    for (final session in sessions) {
      totalMinutes += session.duration.inMinutes;
    }

    return totalMinutes;
  }

  bool isPlayTimeLimitReached() {
    final settings = getSettings();
    if (settings.dailyPlayTimeLimit == null) {
      return false; // No limit set
    }

    final todayPlayTime = getTodayPlayTime();
    return todayPlayTime >= settings.dailyPlayTimeLimit!;
  }

  bool isGameAllowed(String gameId) {
    final settings = getSettings();
    if (settings.allowedGameIds.isEmpty) {
      return true; // All games allowed if no restrictions
    }
    return settings.allowedGameIds.contains(gameId);
  }

  bool verifyPassword(String password) {
    final settings = getSettings();
    if (settings.parentPassword == null || settings.parentPassword!.isEmpty) {
      return false; // No password set
    }
    return settings.parentPassword == password;
  }

  bool hasPassword() {
    final settings = getSettings();
    return settings.parentPassword != null && settings.parentPassword!.isNotEmpty;
  }

  Future<void> setPassword(String password) async {
    final settings = getSettings();
    final updated = settings.copyWith(parentPassword: password);
    await updateSettings(updated);
  }

  Future<void> changePassword(String oldPassword, String newPassword) async {
    if (!verifyPassword(oldPassword)) {
      throw Exception('كلمة المرور القديمة غير صحيحة');
    }
    await setPassword(newPassword);
  }
}

