import 'package:hive/hive.dart';

part 'game_progress.g.dart';

@HiveType(typeId: 0)
class GameProgress extends HiveObject {
  @HiveField(0)
  final String gameId;

  @HiveField(1)
  final Map<int, LevelProgress> levels;

  @HiveField(2)
  int totalStars;

  @HiveField(3)
  int totalPoints;

  GameProgress({
    required this.gameId,
    Map<int, LevelProgress>? levels,
    this.totalStars = 0,
    this.totalPoints = 0,
  }) : levels = levels ?? {};

  int get unlockedLevels {
    return levels.values.where((level) => level.isUnlocked).length;
  }

  int get completedLevels {
    return levels.values.where((level) => level.isCompleted).length;
  }

  void updateLevel(int levelNumber, LevelProgress progress) {
    levels[levelNumber] = progress;
    _recalculateTotals();
  }

  void _recalculateTotals() {
    totalStars = levels.values.fold(0, (sum, level) => sum + level.stars);
    totalPoints = levels.values.fold(0, (sum, level) => sum + level.points);
  }

  GameProgress copyWith({
    String? gameId,
    Map<int, LevelProgress>? levels,
    int? totalStars,
    int? totalPoints,
  }) {
    return GameProgress(
      gameId: gameId ?? this.gameId,
      levels: levels ?? Map.from(this.levels),
      totalStars: totalStars ?? this.totalStars,
      totalPoints: totalPoints ?? this.totalPoints,
    );
  }
}

@HiveType(typeId: 1)
class LevelProgress extends HiveObject {
  @HiveField(0)
  final int levelNumber;

  @HiveField(1)
  final int stars; // 0-3

  @HiveField(2)
  final int points;

  @HiveField(3)
  final bool isCompleted;

  @HiveField(4)
  final bool isUnlocked;

  @HiveField(5)
  final DateTime? completedAt;

  LevelProgress({
    required this.levelNumber,
    this.stars = 0,
    this.points = 0,
    this.isCompleted = false,
    this.isUnlocked = false,
    this.completedAt,
  });

  LevelProgress copyWith({
    int? levelNumber,
    int? stars,
    int? points,
    bool? isCompleted,
    bool? isUnlocked,
    DateTime? completedAt,
  }) {
    return LevelProgress(
      levelNumber: levelNumber ?? this.levelNumber,
      stars: stars ?? this.stars,
      points: points ?? this.points,
      isCompleted: isCompleted ?? this.isCompleted,
      isUnlocked: isUnlocked ?? this.isUnlocked,
      completedAt: completedAt ?? this.completedAt,
    );
  }
}

