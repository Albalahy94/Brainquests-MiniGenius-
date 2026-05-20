import 'package:flutter/foundation.dart';
import 'storage_service.dart';

class AchievementService {
  final StorageService _storageService;

  AchievementService(this._storageService);

  // Sticker IDs (Must match StickerDefinitions in sticker.dart)
  static const String stickerStar = 'happy_brain';
  static const String stickerCat = 'thinking_brain';
  static const String stickerRocket = 'winner_brain';
  static const String stickerHeart = 'level_up';
  static const String stickerRainbow = 'super_smart';
  static const String stickerTrophy = 'mini_genius';

  // Badge IDs
  static const String badgeFirstStar = 'badge_first_star';
  static const String badgeStarCollector = 'badge_star_collector'; // 50 stars
  static const String badgeStarMaster = 'badge_star_master'; // 200 stars
  static const String badgeGettingStarted =
      'badge_getting_started'; // 1st level
  static const String badgeLevelExpert = 'badge_level_expert'; // 50 levels
  static const String badgeDailyPlayer = 'badge_daily_player'; // 7 days streak
  static const String badgeDedicated = 'badge_dedicated'; // 30 days streak

  Future<void> checkAchievements(String gameId, int level, int stars) async {
    final userProgress = _storageService.getUserProgress();
    debugPrint('🔍 Checking achievements: ${userProgress.totalLevelsCompleted} levels, ${userProgress.totalStars} stars');
    bool changed = false;

    // --- Stickers Logic (Simple progression) ---
    // Example: Unlock a sticker every 50 total levels completed across all games
    // Or simpler: Unlock based on total stars

    // Unlock Sticker 1 at 10 stars
    if (userProgress.totalStars >= 10 &&
        !userProgress.hasSticker(stickerStar)) {
      userProgress.addSticker(stickerStar);
      changed = true;
    }
    // Unlock Sticker 2 at 30 stars
    if (userProgress.totalStars >= 30 && !userProgress.hasSticker(stickerCat)) {
      userProgress.addSticker(stickerCat);
      changed = true;
    }
    // Unlock Sticker 3 at 60 stars
    if (userProgress.totalStars >= 60 &&
        !userProgress.hasSticker(stickerRocket)) {
      userProgress.addSticker(stickerRocket);
      changed = true;
    }
    // Unlock Sticker 4 at 100 stars
    if (userProgress.totalStars >= 100 &&
        !userProgress.hasSticker(stickerHeart)) {
      userProgress.addSticker(stickerHeart);
      changed = true;
    }
    // Unlock Sticker 5 at 150 stars
    if (userProgress.totalStars >= 150 &&
        !userProgress.hasSticker(stickerRainbow)) {
      userProgress.addSticker(stickerRainbow);
      changed = true;
    }
    // Unlock Sticker 6 at 200 stars
    if (userProgress.totalStars >= 200 &&
        !userProgress.hasSticker(stickerTrophy)) {
      userProgress.addSticker(stickerTrophy);
      changed = true;
    }

    // --- Badges Logic ---

    // First Star
    if (userProgress.totalStars >= 1 &&
        !userProgress.hasBadge(badgeFirstStar)) {
      userProgress.addBadge(badgeFirstStar);
      changed = true;
    }

    // Star Collector (50 Stars)
    if (userProgress.totalStars >= 50 &&
        !userProgress.hasBadge(badgeStarCollector)) {
      userProgress.addBadge(badgeStarCollector);
      changed = true;
    }

    // Star Master (200 Stars)
    if (userProgress.totalStars >= 200 &&
        !userProgress.hasBadge(badgeStarMaster)) {
      userProgress.addBadge(badgeStarMaster);
      changed = true;
    }

    // Getting Started (Complete 1 level)
    if (userProgress.totalLevelsCompleted >= 1 &&
        !userProgress.hasBadge(badgeGettingStarted)) {
      userProgress.addBadge(badgeGettingStarted);
      changed = true;
    }

    // Level Expert (Complete 50 levels)
    if (userProgress.totalLevelsCompleted >= 50 &&
        !userProgress.hasBadge(badgeLevelExpert)) {
      userProgress.addBadge(badgeLevelExpert);
      changed = true;
    }

    // Daily Player (handled in streak logic usually, but checking here if updated)
    if (userProgress.consecutiveDays >= 7 &&
        !userProgress.hasBadge(badgeDailyPlayer)) {
      userProgress.addBadge(badgeDailyPlayer);
      changed = true;
    }

    if (userProgress.consecutiveDays >= 30 &&
        !userProgress.hasBadge(badgeDedicated)) {
      userProgress.addBadge(badgeDedicated);
      changed = true;
    }

    if (changed) {
      await _storageService.saveUserProgress(userProgress);
      debugPrint('✅ Achievements updated and saved');
    } else {
      debugPrint('ℹ️ No new achievements unlocked');
    }
  }

  Future<void> updateStreak() async {
    final userProgress = _storageService.getUserProgress();
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    if (userProgress.lastDailyGiftDate == null) {
      userProgress.consecutiveDays = 1;
      userProgress.lastDailyGiftDate = today;
      await _storageService.saveUserProgress(userProgress);
      return;
    }

    final lastDate = userProgress.lastDailyGiftDate!;
    final lastDay = DateTime(lastDate.year, lastDate.month, lastDate.day);

    final difference = today.difference(lastDay).inDays;

    if (difference == 0) {
      // Already played today
      return;
    } else if (difference == 1) {
      // Consecutive day
      userProgress.consecutiveDays += 1;
      userProgress.lastDailyGiftDate = today;
    } else {
      // Streak broken
      userProgress.consecutiveDays = 1;
      userProgress.lastDailyGiftDate = today;
    }

    await _storageService.saveUserProgress(userProgress);
    // Check streak achievements
    await checkAchievements('', 0, 0);
  }
}
