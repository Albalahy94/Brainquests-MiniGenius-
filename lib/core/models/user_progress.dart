import 'package:hive/hive.dart';

part 'user_progress.g.dart';

@HiveType(typeId: 2)
class UserProgress extends HiveObject {
  @HiveField(0)
  int totalStars;

  @HiveField(1)
  int totalPoints;

  @HiveField(2)
  List<String> unlockedStickers;

  @HiveField(3)
  List<String> unlockedBadges;

  @HiveField(4)
  DateTime? lastDailyGiftDate;

  @HiveField(5)
  int consecutiveDays;

  @HiveField(6)
  int totalLevelsCompleted;

  @HiveField(7)
  bool isPremium;

  @HiveField(8)
  int coins; // Virtual currency

  @HiveField(9)
  int gems; // Premium currency

  @HiveField(10)
  bool? isTestMode; // Test mode to unlock all worlds

  @HiveField(11)
  String languageCode;

  @HiveField(12)
  bool isDarkMode;

  UserProgress({
    this.totalStars = 0,
    this.totalPoints = 0,
    List<String>? unlockedStickers,
    List<String>? unlockedBadges,
    this.lastDailyGiftDate,
    this.consecutiveDays = 0,
    this.totalLevelsCompleted = 0,
    this.isPremium = false,
    this.coins = 0,
    this.gems = 0,
    this.isTestMode = false,
    this.languageCode = 'en',
    this.isDarkMode = false,
  })  : unlockedStickers = unlockedStickers ?? [],
        unlockedBadges = unlockedBadges ?? [];

  bool hasSticker(String stickerId) {
    return unlockedStickers.contains(stickerId);
  }

  bool hasBadge(String badgeId) {
    return unlockedBadges.contains(badgeId);
  }

  void addSticker(String stickerId) {
    if (!unlockedStickers.contains(stickerId)) {
      unlockedStickers.add(stickerId);
    }
  }

  void addBadge(String badgeId) {
    if (!unlockedBadges.contains(badgeId)) {
      unlockedBadges.add(badgeId);
    }
  }

  void addCoins(int amount) {
    coins += amount;
  }

  void addGems(int amount) {
    gems += amount;
  }

  bool spendCoins(int amount) {
    if (coins >= amount) {
      coins -= amount;
      return true;
    }
    return false;
  }

  bool spendGems(int amount) {
    if (gems >= amount) {
      gems -= amount;
      return true;
    }
    return false;
  }

  UserProgress copyWith({
    int? totalStars,
    int? totalPoints,
    List<String>? unlockedStickers,
    List<String>? unlockedBadges,
    DateTime? lastDailyGiftDate,
    int? consecutiveDays,
    int? totalLevelsCompleted,
    bool? isPremium,
    int? coins,
    int? gems,
    bool? isTestMode,
    String? languageCode,
    bool? isDarkMode,
  }) {
    return UserProgress(
      totalStars: totalStars ?? this.totalStars,
      totalPoints: totalPoints ?? this.totalPoints,
      unlockedStickers: unlockedStickers ?? List.from(this.unlockedStickers),
      unlockedBadges: unlockedBadges ?? List.from(this.unlockedBadges),
      lastDailyGiftDate: lastDailyGiftDate ?? this.lastDailyGiftDate,
      consecutiveDays: consecutiveDays ?? this.consecutiveDays,
      totalLevelsCompleted: totalLevelsCompleted ?? this.totalLevelsCompleted,
      isPremium: isPremium ?? this.isPremium,
      coins: coins ?? this.coins,
      gems: gems ?? this.gems,
      // Handle isTestMode explicitly - if provided (even if false), use it; otherwise keep current
      isTestMode: isTestMode != null ? isTestMode : this.isTestMode,
      languageCode: languageCode ?? this.languageCode,
      isDarkMode: isDarkMode ?? this.isDarkMode,
    );
  }
}

