import 'storage_service.dart';

class DailyGiftService {
  final StorageService _storageService;

  DailyGiftService(this._storageService);

  bool isGiftAvailable() {
    final userProgress = _storageService.getUserProgress();
    final now = DateTime.now();
    final lastGiftDate = userProgress.lastDailyGiftDate;

    if (lastGiftDate == null) {
      return true; // First time user
    }

    // Check if it's a new day
    final lastDate = DateTime(lastGiftDate.year, lastGiftDate.month, lastGiftDate.day);
    final today = DateTime(now.year, now.month, now.day);

    return today.isAfter(lastDate);
  }

  int getConsecutiveDays() {
    final userProgress = _storageService.getUserProgress();
    return userProgress.consecutiveDays;
  }

  Future<DailyGiftResult> claimDailyGift() async {
    if (!isGiftAvailable()) {
      return DailyGiftResult(
        success: false,
        message: 'You already claimed today\'s gift!',
      );
    }

    final userProgress = _storageService.getUserProgress();
    final now = DateTime.now();
    final lastGiftDate = userProgress.lastDailyGiftDate;

    int consecutiveDays = 1;
    if (lastGiftDate != null) {
      final lastDate = DateTime(lastGiftDate.year, lastGiftDate.month, lastGiftDate.day);
      final today = DateTime(now.year, now.month, now.day);
      final difference = today.difference(lastDate).inDays;

      if (difference == 1) {
        // Consecutive day
        consecutiveDays = userProgress.consecutiveDays + 1;
      } else {
        // Reset consecutive days
        consecutiveDays = 1;
      }
    }

    // Calculate rewards
    int starsReward = 1;
    int pointsReward = 10;
    String? stickerReward;

    // Bonus for consecutive days
    if (consecutiveDays >= 7) {
      starsReward = 3;
      pointsReward = 50;
      // Give a special sticker for 7+ consecutive days
      stickerReward = 'dedicated_player';
    } else if (consecutiveDays >= 3) {
      starsReward = 2;
      pointsReward = 25;
    }

    // Update user progress
    _storageService.updateUserProgress((progress) {
      progress.totalStars += starsReward;
      progress.totalPoints += pointsReward;
      progress.lastDailyGiftDate = now;
      progress.consecutiveDays = consecutiveDays;

      if (stickerReward != null && !progress.hasSticker(stickerReward)) {
        progress.addSticker(stickerReward);
      }

      return progress;
    });

    return DailyGiftResult(
      success: true,
      message: 'Daily gift claimed!',
      stars: starsReward,
      points: pointsReward,
      consecutiveDays: consecutiveDays,
      stickerReward: stickerReward,
    );
  }

  String getNextGiftTime() {
    final userProgress = _storageService.getUserProgress();
    final lastGiftDate = userProgress.lastDailyGiftDate;

    if (lastGiftDate == null) {
      return 'Available now!';
    }

    final tomorrow = DateTime(
      lastGiftDate.year,
      lastGiftDate.month,
      lastGiftDate.day,
    ).add(const Duration(days: 1));

    final now = DateTime.now();
    if (tomorrow.isBefore(now)) {
      return 'Available now!';
    }

    final difference = tomorrow.difference(now);
    final hours = difference.inHours;
    final minutes = difference.inMinutes % 60;

    if (hours > 0) {
      return 'Next gift in $hours hours';
    } else {
      return 'Next gift in $minutes minutes';
    }
  }
}

class DailyGiftResult {
  final bool success;
  final String message;
  final int stars;
  final int points;
  final int consecutiveDays;
  final String? stickerReward;

  DailyGiftResult({
    required this.success,
    required this.message,
    this.stars = 0,
    this.points = 0,
    this.consecutiveDays = 0,
    this.stickerReward,
  });
}

