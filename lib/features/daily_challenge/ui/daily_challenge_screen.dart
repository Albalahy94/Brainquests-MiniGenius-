import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/services/daily_challenge_service.dart';
import '../../../core/services/storage_service.dart';
import '../../../core/models/daily_challenge.dart';
import '../../../core/routes/app_routes.dart';

class DailyChallengeScreen extends StatefulWidget {
  const DailyChallengeScreen({super.key});

  @override
  State<DailyChallengeScreen> createState() => _DailyChallengeScreenState();
}

class _DailyChallengeScreenState extends State<DailyChallengeScreen> {
  final DailyChallengeService _challengeService = DailyChallengeService();
  final StorageService _storageService = StorageService();
  DailyChallenge? _challenge;
  ChallengeProgress? _progress;
  StreakData? _streak;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    await _storageService.init();
    setState(() {
      _challenge = _challengeService.getTodayChallenge();
      _progress = _challengeService.getTodayProgress();
      _streak = _challengeService.getStreakData();
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_challenge == null) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    final isAr = Localizations.localeOf(context).languageCode == 'ar';
    final isCompleted = _progress?.isCompleted ?? false;
    final currentScore = _progress?.currentScore ?? 0;

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: AppTheme.blueGradient,
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Header
              Padding(
                padding: const EdgeInsets.all(20.0),
                child: Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back, color: Colors.white),
                      onPressed: () => Navigator.pop(context),
                    ),
                    Expanded(
                      child: Text(
                        isAr ? 'التحدي اليومي' : 'Daily Challenge',
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                    ),
                    const SizedBox(width: 48),
                  ],
                ),
              ),

              // Streak indicator
              if (_streak != null)
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.local_fire_department, color: Colors.orange, size: 28),
                      const SizedBox(width: 8),
                      Text(
                        '${_streak!.currentStreak}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        isAr
                            ? 'يوم متتالي'
                            : (_streak!.currentStreak == 1 ? 'day streak' : 'days streak'),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                        ),
                      ),
                    ],
                  ),
                ),

              // Challenge Card
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    children: [
                      // Challenge Info
                      Container(
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.1),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Column(
                          children: [
                            Text(
                              isAr ? _challenge!.titleAr : _challenge!.title,
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: AppTheme.primaryBlue,
                              ),
                            ),
                            const SizedBox(height: 12),
                            Text(
                              isAr ? _challenge!.descriptionAr : _challenge!.description,
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.grey[700],
                              ),
                            ),
                            const SizedBox(height: 24),

                            // Progress
                            if (!isCompleted)
                              Column(
                                children: [
                                  Text(
                                    isAr
                                        ? 'الهدف: ${_challenge!.targetScore} نقطة'
                                        : 'Target: ${_challenge!.targetScore} pts',
                                    style: const TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  LinearProgressIndicator(
                                    value: (currentScore / _challenge!.targetScore).clamp(0.0, 1.0),
                                    backgroundColor: Colors.grey[300],
                                    valueColor: const AlwaysStoppedAnimation<Color>(AppTheme.primaryBlue),
                                    minHeight: 8,
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    '$currentScore / ${_challenge!.targetScore}',
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: Colors.grey[600],
                                    ),
                                  ),
                                ],
                              )
                            else
                              Container(
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  color: Colors.green.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    const Icon(Icons.check_circle, color: Colors.green, size: 32),
                                    const SizedBox(width: 8),
                                    Text(
                                      isAr ? 'تم إكمال التحدي!' : 'Challenge Completed!',
                                      style: const TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.green,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 24),

                      // Rewards
                      Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Column(
                          children: [
                            Text(
                              isAr ? 'المكافآت' : 'Rewards',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 16),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                _RewardItem(
                                  icon: Icons.star,
                                  label: isAr
                                      ? '${_challenge!.rewardStars} نجوم'
                                      : '${_challenge!.rewardStars} Stars',
                                  color: Colors.amber,
                                ),
                                _RewardItem(
                                  icon: Icons.monetization_on,
                                  label: isAr
                                      ? '${_challenge!.rewardCoins} عملة'
                                      : '${_challenge!.rewardCoins} Coins',
                                  color: Colors.orange,
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 24),

                      // Play Button
                      if (!isCompleted)
                        SizedBox(
                          width: double.infinity,
                          height: 56,
                          child: ElevatedButton(
                            onPressed: () {
                              final gameRoutes = {
                                'memory_cards': AppRoutes.memoryCards,
                                'quick_math': AppRoutes.quickMath,
                                'pattern_logic': AppRoutes.patternLogic,
                                'color_memory': AppRoutes.colorMemory,
                                'shape_matcher': AppRoutes.shapeMatcher,
                                'find_difference': AppRoutes.findDifference,
                              };
                              final route = gameRoutes[_challenge!.gameId];
                              if (route != null) {
                                Navigator.pushNamed(context, route);
                              }
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.white,
                              foregroundColor: AppTheme.primaryBlue,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                            ),
                            child: Text(
                              isAr ? 'ابدأ اللعب' : 'Start Playing',
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _RewardItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;

  const _RewardItem({
    required this.icon,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(icon, color: color, size: 32),
        const SizedBox(height: 8),
        Text(
          label,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 14,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}
