import '../models/daily_challenge.dart';
import 'storage_service.dart';

class DailyChallengeService {
  static final DailyChallengeService _instance = DailyChallengeService._internal();
  factory DailyChallengeService() => _instance;
  DailyChallengeService._internal();

  final StorageService _storageService = StorageService();

  // Generate today's challenge
  DailyChallenge getTodayChallenge() {
    final today = DateTime.now();
    final dayOfYear = today.difference(DateTime(today.year, 1, 1)).inDays;

    // Rotate challenge types
    final challengeTypes = [
      {'type': 'memory', 'gameId': 'memory_cards', 'target': 1000},
      {'type': 'math', 'gameId': 'quick_math', 'target': 500},
      {'type': 'pattern', 'gameId': 'pattern_logic', 'target': 800},
      {'type': 'color', 'gameId': 'color_memory', 'target': 600},
      {'type': 'shape', 'gameId': 'shape_matcher', 'target': 700},
      {'type': 'difference', 'gameId': 'find_difference', 'target': 900},
    ];

    final challenge = challengeTypes[dayOfYear % challengeTypes.length];
    
    final titles = {
      'memory': {'en': 'Memory Master', 'ar': 'سيد الذاكرة'},
      'math': {'en': 'Math Wizard', 'ar': 'ساحر الرياضيات'},
      'pattern': {'en': 'Pattern Pro', 'ar': 'خبير الأنماط'},
      'color': {'en': 'Color Champion', 'ar': 'بطل الألوان'},
      'shape': {'en': 'Shape Expert', 'ar': 'خبير الأشكال'},
      'difference': {'en': 'Eagle Eye', 'ar': 'عين الصقر'},
    };

    final title = titles[challenge['type']] ?? {'en': 'Daily Challenge', 'ar': 'تحدي يومي'};

    return DailyChallenge(
      id: 'challenge_${today.year}_${today.month}_${today.day}',
      type: challenge['type'] as String,
      title: title['en'] as String,
      titleAr: title['ar'] as String,
      description: 'Complete this challenge to earn rewards!',
      descriptionAr: 'أكمل هذا التحدي لكسب المكافآت!',
      gameId: challenge['gameId'] as String,
      targetScore: challenge['target'] as int,
      rewardStars: 5,
      rewardCoins: 20,
      date: DateTime(today.year, today.month, today.day),
    );
  }

  ChallengeProgress? getTodayProgress() {
    final challenge = getTodayChallenge();
    return _storageService.getChallengeProgress(challenge.id);
  }

  ChallengeProgress getOrCreateTodayProgress() {
    final challenge = getTodayChallenge();
    final progress = _storageService.getChallengeProgress(challenge.id);
    if (progress != null) {
      return progress;
    }

    final newProgress = ChallengeProgress(
      challengeId: challenge.id,
      date: challenge.date,
    );
    _storageService.saveChallengeProgress(newProgress);
    return newProgress;
  }

  Future<bool> completeChallenge(int score) async {
    final challenge = getTodayChallenge();
    if (score < challenge.targetScore) {
      return false;
    }

    final progress = getOrCreateTodayProgress();
    if (progress.isCompleted) {
      return false; // Already completed
    }

    // Update progress
    final updated = progress.copyWith(
      isCompleted: true,
      currentScore: score,
      completedAt: DateTime.now(),
    );
    await _storageService.saveChallengeProgress(updated);

    // Update streak
    final streak = _storageService.getStreakData();
    streak.updateStreak(DateTime.now());
    await _storageService.saveStreakData(streak);

    // Add rewards to user
    final userProgress = _storageService.getUserProgress();
    userProgress.totalStars += challenge.rewardStars;
    userProgress.addCoins(challenge.rewardCoins);
    await _storageService.saveUserProgress(userProgress);

    return true;
  }

  bool isChallengeCompleted() {
    final progress = getTodayProgress();
    return progress?.isCompleted ?? false;
  }

  StreakData getStreakData() {
    return _storageService.getStreakData();
  }
}

