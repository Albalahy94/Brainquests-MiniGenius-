import 'package:hive/hive.dart';

part 'daily_challenge.g.dart';

@HiveType(typeId: 5)
class DailyChallenge extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String type; // 'memory', 'math', 'pattern', etc.

  @HiveField(2)
  final String title;

  @HiveField(3)
  final String titleAr; // Arabic title

  @HiveField(4)
  final String description;

  @HiveField(5)
  final String descriptionAr; // Arabic description

  @HiveField(6)
  final String gameId; // Which game this challenge is for

  @HiveField(7)
  final int targetScore; // Target score to complete

  @HiveField(8)
  final int rewardStars; // Stars reward

  @HiveField(9)
  final int rewardCoins; // Coins reward

  @HiveField(10)
  final DateTime date; // Date of the challenge

  DailyChallenge({
    required this.id,
    required this.type,
    required this.title,
    required this.titleAr,
    required this.description,
    required this.descriptionAr,
    required this.gameId,
    required this.targetScore,
    this.rewardStars = 5,
    this.rewardCoins = 10,
    required this.date,
  });
}

@HiveType(typeId: 6)
class ChallengeProgress extends HiveObject {
  @HiveField(0)
  final String challengeId;

  @HiveField(1)
  final DateTime date;

  @HiveField(2)
  bool isCompleted;

  @HiveField(3)
  int currentScore;

  @HiveField(4)
  DateTime? completedAt;

  ChallengeProgress({
    required this.challengeId,
    required this.date,
    this.isCompleted = false,
    this.currentScore = 0,
    this.completedAt,
  });

  ChallengeProgress copyWith({
    String? challengeId,
    DateTime? date,
    bool? isCompleted,
    int? currentScore,
    DateTime? completedAt,
  }) {
    return ChallengeProgress(
      challengeId: challengeId ?? this.challengeId,
      date: date ?? this.date,
      isCompleted: isCompleted ?? this.isCompleted,
      currentScore: currentScore ?? this.currentScore,
      completedAt: completedAt ?? this.completedAt,
    );
  }
}

@HiveType(typeId: 7)
class StreakData extends HiveObject {
  @HiveField(0)
  int currentStreak; // Current consecutive days

  @HiveField(1)
  int longestStreak; // Longest streak achieved

  @HiveField(2)
  DateTime? lastChallengeDate; // Last date challenge was completed

  StreakData({
    this.currentStreak = 0,
    this.longestStreak = 0,
    this.lastChallengeDate,
  });

  void updateStreak(DateTime date) {
    if (lastChallengeDate == null) {
      // First challenge
      currentStreak = 1;
      longestStreak = 1;
    } else {
      final daysDifference = date.difference(lastChallengeDate!).inDays;
      if (daysDifference == 1) {
        // Consecutive day
        currentStreak++;
        if (currentStreak > longestStreak) {
          longestStreak = currentStreak;
        }
      } else if (daysDifference > 1) {
        // Streak broken
        currentStreak = 1;
      }
      // If daysDifference == 0, same day, don't update
    }
    lastChallengeDate = date;
  }

  StreakData copyWith({
    int? currentStreak,
    int? longestStreak,
    DateTime? lastChallengeDate,
  }) {
    return StreakData(
      currentStreak: currentStreak ?? this.currentStreak,
      longestStreak: longestStreak ?? this.longestStreak,
      lastChallengeDate: lastChallengeDate ?? this.lastChallengeDate,
    );
  }
}

