import 'dart:math';
import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/services/storage_service.dart';
import '../../../core/services/achievement_service.dart';
import '../../../core/services/sound_service.dart';
import '../../../core/services/parent_dashboard_service.dart';
import '../../../core/services/daily_challenge_service.dart';
import '../../../core/services/world_service.dart';
import '../../../core/services/notification_service.dart';
import '../../../core/models/parent_dashboard.dart';
import '../../../core/models/game_progress.dart';
import 'package:confetti/confetti.dart';

class ResultScreen extends StatefulWidget {
  final int stars;
  final int points;
  final int level;
  final String gameId;
  final StorageService storageService;
  final DateTime? gameStartTime;
  final String? worldId; // Optional: if game was played from a world

  const ResultScreen({
    super.key,
    required this.stars,
    required this.points,
    required this.level,
    required this.gameId,
    required this.storageService,
    this.gameStartTime,
    this.worldId,
  });

  @override
  State<ResultScreen> createState() => _ResultScreenState();
}

class _ResultScreenState extends State<ResultScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late ConfettiController _confettiController;
  bool _hasShownReward = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _confettiController = ConfettiController(duration: const Duration(seconds: 3));
    
    if (widget.stars >= 2) {
      _confettiController.play();
    }
    
    _controller.forward();

    // Play win sound
    SoundService().playWin();

    _checkRewards();
  }

  List<String> _newUnlockedStickers = [];
  List<String> _newUnlockedBadges = [];

  void _checkRewards() async {
    // 1. Update User Progress (Totals)
    final achievementService = AchievementService(widget.storageService);
    final userProgress = widget.storageService.getUserProgress();

    // Capture state before update
    final initialStickers = List<String>.from(userProgress.unlockedStickers);
    final initialBadges = List<String>.from(userProgress.unlockedBadges);

    // Update User Progress (Totals) - save immediately
    await widget.storageService.updateUserProgress((progress) {
      progress.totalLevelsCompleted += 1;
      progress.totalStars += widget.stars;
      progress.totalPoints += widget.points;
      // Note: consecutiveDays is handled by updateStreak() below
      debugPrint('📊 Updated progress: ${progress.totalLevelsCompleted} levels, ${progress.totalStars} stars');
      return progress;
    });

    // 2. Save Play Session for Parent Dashboard
    if (widget.gameStartTime != null) {
      try {
        final parentService = ParentDashboardService();
        final session = PlaySession(
          startTime: widget.gameStartTime!,
          endTime: DateTime.now(),
          gameId: widget.gameId,
          levelNumber: widget.level,
          score: widget.points,
          stars: widget.stars,
        );
        await parentService.savePlaySession(session);
      } catch (e) {
        debugPrint('Error saving play session: $e');
      }
    }

    // 3. Update World Progress (if played from a world)
    if (widget.worldId != null && widget.worldId!.isNotEmpty) {
      try {
        final worldService = WorldService();
        await worldService.init();
        final levelProgress = LevelProgress(
          levelNumber: widget.level,
          stars: widget.stars,
          points: widget.points,
          isCompleted: true,
          isUnlocked: true,
          completedAt: DateTime.now(),
        );
        await worldService.updateWorldLevel(
          widget.worldId!,
          widget.level,
          levelProgress,
        );
        debugPrint('✅ World progress updated for ${widget.worldId}, level ${widget.level}');
      } catch (e) {
        debugPrint('Error updating world progress: $e');
      }
    }

    // 4. Check Daily Challenge
    try {
      final challengeService = DailyChallengeService();
      final todayChallenge = challengeService.getTodayChallenge();
      
      // Check if this game matches today's challenge
      if (todayChallenge.gameId == widget.gameId) {
        final progress = challengeService.getTodayProgress();
        if (progress != null && !progress.isCompleted) {
          // Update challenge progress with current score
          final updatedProgress = progress.copyWith(
            currentScore: widget.points,
          );
          await widget.storageService.saveChallengeProgress(updatedProgress);
          
          // Check if challenge is completed
          if (widget.points >= todayChallenge.targetScore) {
            final completed = await challengeService.completeChallenge(widget.points);
            if (completed && mounted) {
              // Show challenge completion notification
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    '🎉 أكملت التحدي اليومي! +${todayChallenge.rewardStars} ⭐ +${todayChallenge.rewardCoins} 🪙',
                  ),
                  backgroundColor: Colors.green,
                  duration: const Duration(seconds: 4),
                ),
              );
            }
          }
        }
      }
    } catch (e) {
      debugPrint('Error checking daily challenge: $e');
    }

    // 4. Update streak (this reads and saves user progress, so it will include our updates)
    await achievementService.updateStreak();
    
    // 5. Check Achievements (after all updates are saved)
    // This will read the latest user progress which includes our updates
    await achievementService.checkAchievements(
        widget.gameId, widget.level, widget.stars);

    // 6. Get final updated progress after achievements check
    final updatedProgress = widget.storageService.getUserProgress();

    final newStickers = updatedProgress.unlockedStickers
        .where((s) => !initialStickers.contains(s))
        .toList();

    final newBadges = updatedProgress.unlockedBadges
        .where((b) => !initialBadges.contains(b))
        .toList();

    // Show notifications for new achievements (if parent settings allow)
    final parentService = ParentDashboardService();
    final parentSettings = parentService.getSettings();
    
    if (parentSettings.achievementAlerts) {
      final notificationService = NotificationService();
      await notificationService.initialize();
      
      for (final badgeId in newBadges) {
        await notificationService.showBadgeUnlocked(badgeId);
      }
      
      for (final stickerId in newStickers) {
        await notificationService.showStickerUnlocked(stickerId);
      }
    }

    if (mounted) {
      setState(() {
        _newUnlockedStickers = newStickers;
        _newUnlockedBadges = newBadges;
        _hasShownReward = newStickers.isNotEmpty || newBadges.isNotEmpty;
        if (_hasShownReward) {
          SoundService().playSuccess();
        }
      });
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: AppTheme.blueGradient,
        ),
        child: SafeArea(
          child: Stack(
            children: [
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Stars display
                  ScaleTransition(
                    scale: Tween<double>(begin: 0.0, end: 1.0).animate(
                      CurvedAnimation(
                          parent: _controller, curve: Curves.elasticOut),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(
                        3,
                        (index) => Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Icon(
                            Icons.star,
                            size: 60,
                            color: index < widget.stars
                                ? AppTheme.yellowAccent
                                : AppTheme.grey,
                          ),
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 32),

                  // Level passed text
                  Text(
                    'Level Passed!',
                    style: Theme.of(context).textTheme.displayMedium?.copyWith(
                          color: AppTheme.white,
                        ),
                  ),

                  const SizedBox(height: 16),

                  // Points
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                    decoration: BoxDecoration(
                      color: AppTheme.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      '+${widget.points} Points',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            color: AppTheme.white,
                          ),
                    ),
                  ),

                  if (_hasShownReward) ...[
                    const SizedBox(height: 24),
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppTheme.yellowAccent,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Column(
                        children: [
                          if (_newUnlockedStickers.isNotEmpty) ...[
                            const Icon(Icons.star, size: 48, color: Colors.orange),
                            const SizedBox(height: 8),
                            Text(
                              'New Sticker Unlocked!',
                              style: Theme.of(context).textTheme.titleLarge,
                            ),
                          ],
                          if (_newUnlockedBadges.isNotEmpty) ...[
                            if (_newUnlockedStickers.isNotEmpty)
                              const SizedBox(height: 16),
                            const Icon(Icons.emoji_events,
                                size: 48, color: Colors.orange),
                            const SizedBox(height: 8),
                            Text(
                              'New Badge Unlocked!',
                              style: Theme.of(context).textTheme.titleLarge,
                            ),
                          ]
                        ],
                      ),
                    ),
                  ],

                  const Spacer(),

                  // Buttons
                  Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Column(
                      children: [
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: () {
                              Navigator.pop(context);
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppTheme.yellowAccent,
                              foregroundColor: AppTheme.darkText,
                              padding: const EdgeInsets.symmetric(vertical: 16),
                            ),
                            child: Text(
                              'Next Level',
                              style: Theme.of(context).textTheme.titleLarge,
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Expanded(
                              child: OutlinedButton(
                                onPressed: () {
                                  Navigator.pop(context);
                                },
                                style: OutlinedButton.styleFrom(
                                  foregroundColor: AppTheme.white,
                                  side: const BorderSide(color: AppTheme.white),
                                  padding: const EdgeInsets.symmetric(vertical: 16),
                                ),
                                child: const Text('Retry'),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: OutlinedButton(
                                onPressed: () {
                                  Navigator.popUntil(
                                      context, (route) => route.isFirst);
                                },
                                style: OutlinedButton.styleFrom(
                                  foregroundColor: AppTheme.white,
                                  side: const BorderSide(color: AppTheme.white),
                                  padding: const EdgeInsets.symmetric(vertical: 16),
                                ),
                                child: const Text('Home'),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              Align(
                alignment: Alignment.topCenter,
                child: ConfettiWidget(
                  confettiController: _confettiController,
                  blastDirection: pi / 2, // Downwards
                  blastDirectionality: BlastDirectionality.explosive,
                  emissionFrequency: 0.05,
                  numberOfParticles: 50,
                  gravity: 0.1,
                  colors: const [Colors.green, Colors.blue, Colors.pink, Colors.orange, Colors.purple],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
