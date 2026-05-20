import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/models/badge.dart' as models;
import '../../../core/models/user_progress.dart';
import '../../../core/services/storage_service.dart';

class AchievementsScreen extends StatefulWidget {
  const AchievementsScreen({super.key});

  @override
  State<AchievementsScreen> createState() => _AchievementsScreenState();
}

class _AchievementsScreenState extends State<AchievementsScreen> {
  late final StorageService _storageService;
  UserProgress? _userProgress;

  @override
  void initState() {
    super.initState();
    _storageService = StorageService();
    _loadProgress();
  }

  Future<void> _loadProgress() async {
    await _storageService.init();
    if (mounted) {
      setState(() {
        _userProgress = _storageService.getUserProgress();
      });
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Reload progress when screen becomes visible again
    _loadProgress();
  }

  bool _isBadgeUnlocked(models.Badge badge) {
    if (_userProgress == null) return false;
    
    switch (badge.type) {
      case models.BadgeType.totalStars:
        return _userProgress!.totalStars >= (badge.requiredValue ?? 0);
      case models.BadgeType.totalPoints:
        return _userProgress!.totalPoints >= (badge.requiredValue ?? 0);
      case models.BadgeType.levelsCompleted:
        return _userProgress!.totalLevelsCompleted >= (badge.requiredValue ?? 0);
      case models.BadgeType.consecutiveDays:
        return _userProgress!.consecutiveDays >= (badge.requiredValue ?? 0);
      case models.BadgeType.gameSpecific:
        return _userProgress!.hasBadge(badge.id);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_userProgress == null) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }
    
    final badges = models.BadgeDefinitions.getAllBadges();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Achievements'),
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: badges.length,
        itemBuilder: (context, index) {
          final badge = badges[index];
          final isUnlocked = _isBadgeUnlocked(badge);

          return Card(
            margin: const EdgeInsets.only(bottom: 12),
            child: ListTile(
              leading: Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: isUnlocked
                      ? AppTheme.primaryBlue.withOpacity(0.2)
                      : AppTheme.grey.withOpacity(0.2),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  isUnlocked ? Icons.emoji_events : Icons.lock,
                  size: 30,
                  color: isUnlocked ? AppTheme.primaryBlue : AppTheme.grey,
                ),
              ),
              title: Text(
                badge.name,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: isUnlocked ? AppTheme.darkText : AppTheme.grey,
                    ),
              ),
              subtitle: Text(
                badge.description,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: isUnlocked ? AppTheme.darkText : AppTheme.grey,
                    ),
              ),
              trailing: isUnlocked
                  ? Icon(Icons.check_circle, color: AppTheme.mintGreen)
                  : null,
            ),
          );
        },
      ),
    );
  }
}

