import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'game_progress.dart';

part 'world.g.dart';

@HiveType(typeId: 3)
class World extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String name;

  @HiveField(2)
  final String nameAr; // Arabic name

  @HiveField(3)
  final String description;

  @HiveField(4)
  final String descriptionAr; // Arabic description

  @HiveField(5)
  final String icon; // Icon identifier or emoji

  @HiveField(6)
  final int colorValue; // World theme color as int

  @HiveField(7)
  final int requiredStars; // Stars needed to unlock

  @HiveField(8)
  final int totalLevels; // Total levels in this world

  @HiveField(9)
  final List<String> gameIds; // Games available in this world

  World({
    required this.id,
    required this.name,
    required this.nameAr,
    required this.description,
    required this.descriptionAr,
    required this.icon,
    required this.colorValue,
    this.requiredStars = 0,
    this.totalLevels = 10,
    List<String>? gameIds,
  }) : gameIds = gameIds ?? [];

  World.fromColor({
    required this.id,
    required this.name,
    required this.nameAr,
    required this.description,
    required this.descriptionAr,
    required this.icon,
    required Color color,
    this.requiredStars = 0,
    this.totalLevels = 10,
    List<String>? gameIds,
  }) : colorValue = color.value,
       gameIds = gameIds ?? [];

  Color get color => Color(colorValue);

  bool isUnlocked(int totalStars) {
    return totalStars >= requiredStars;
  }
}

@HiveType(typeId: 4)
class WorldProgress extends HiveObject {
  @HiveField(0)
  final String worldId;

  @HiveField(1)
  final Map<int, LevelProgress> levels; // levelNumber -> LevelProgress

  @HiveField(2)
  int totalStars;

  @HiveField(3)
  bool isUnlocked;

  @HiveField(4)
  DateTime? unlockedAt;

  WorldProgress({
    required this.worldId,
    Map<int, LevelProgress>? levels,
    this.totalStars = 0,
    this.isUnlocked = false,
    this.unlockedAt,
  }) : levels = levels ?? {};

  int get completedLevels {
    return levels.values.where((level) => level.isCompleted).length;
  }

  void updateLevel(int levelNumber, LevelProgress progress) {
    levels[levelNumber] = progress;
    _recalculateTotals();
  }

  void _recalculateTotals() {
    totalStars = levels.values.fold(0, (sum, level) => sum + level.stars);
  }

  WorldProgress copyWith({
    String? worldId,
    Map<int, LevelProgress>? levels,
    int? totalStars,
    bool? isUnlocked,
    DateTime? unlockedAt,
  }) {
    return WorldProgress(
      worldId: worldId ?? this.worldId,
      levels: levels ?? Map.from(this.levels),
      totalStars: totalStars ?? this.totalStars,
      isUnlocked: isUnlocked ?? this.isUnlocked,
      unlockedAt: unlockedAt ?? this.unlockedAt,
    );
  }
}

