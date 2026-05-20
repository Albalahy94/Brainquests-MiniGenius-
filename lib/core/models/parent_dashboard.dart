import 'package:hive/hive.dart';

part 'parent_dashboard.g.dart';

@HiveType(typeId: 11)
class ParentSettings extends HiveObject {
  @HiveField(0)
  bool isParentModeEnabled;

  @HiveField(1)
  int? dailyPlayTimeLimit; // Minutes per day (null = unlimited)

  @HiveField(2)
  List<String> allowedGameIds; // Games allowed to play

  @HiveField(3)
  int? ageGroup; // Child's age group (3-5, 6-8, 9-12, etc.)

  @HiveField(4)
  bool achievementAlerts; // Show achievement notifications

  @HiveField(5)
  String? parentPassword; // Password to access parent mode

  ParentSettings({
    this.isParentModeEnabled = false,
    this.dailyPlayTimeLimit,
    List<String>? allowedGameIds,
    this.ageGroup,
    this.achievementAlerts = true,
    this.parentPassword,
  }) : allowedGameIds = allowedGameIds ?? [];

  ParentSettings copyWith({
    bool? isParentModeEnabled,
    int? dailyPlayTimeLimit,
    List<String>? allowedGameIds,
    int? ageGroup,
    bool? achievementAlerts,
    String? parentPassword,
  }) {
    return ParentSettings(
      isParentModeEnabled: isParentModeEnabled ?? this.isParentModeEnabled,
      dailyPlayTimeLimit: dailyPlayTimeLimit ?? this.dailyPlayTimeLimit,
      allowedGameIds: allowedGameIds ?? List.from(this.allowedGameIds),
      ageGroup: ageGroup ?? this.ageGroup,
      achievementAlerts: achievementAlerts ?? this.achievementAlerts,
      parentPassword: parentPassword ?? this.parentPassword,
    );
  }
}

@HiveType(typeId: 12)
class PlaySession extends HiveObject {
  @HiveField(0)
  final DateTime startTime;

  @HiveField(1)
  final DateTime endTime;

  @HiveField(2)
  final String gameId;

  @HiveField(3)
  final int levelNumber;

  @HiveField(4)
  final int score;

  @HiveField(5)
  final int stars;

  PlaySession({
    required this.startTime,
    required this.endTime,
    required this.gameId,
    required this.levelNumber,
    this.score = 0,
    this.stars = 0,
  });

  Duration get duration => endTime.difference(startTime);
}

@HiveType(typeId: 13)
class ChildProgressReport extends HiveObject {
  @HiveField(0)
  final DateTime reportDate;

  @HiveField(1)
  final int totalPlayTime; // Minutes

  @HiveField(2)
  final int gamesPlayed;

  @HiveField(3)
  final int levelsCompleted;

  @HiveField(4)
  final int totalStars;

  @HiveField(5)
  final Map<String, int> gameStats; // gameId -> times played

  @HiveField(6)
  final Map<String, double> averageScores; // gameId -> average score

  @HiveField(7)
  final List<String> achievementsUnlocked;

  ChildProgressReport({
    required this.reportDate,
    this.totalPlayTime = 0,
    this.gamesPlayed = 0,
    this.levelsCompleted = 0,
    this.totalStars = 0,
    Map<String, int>? gameStats,
    Map<String, double>? averageScores,
    List<String>? achievementsUnlocked,
  })  : gameStats = gameStats ?? {},
        averageScores = averageScores ?? {},
        achievementsUnlocked = achievementsUnlocked ?? [];
}

