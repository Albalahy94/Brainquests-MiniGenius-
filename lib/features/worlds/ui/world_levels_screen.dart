import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/services/world_service.dart';
import '../../../core/services/storage_service.dart';
import '../../../core/models/world.dart';
import '../../../core/models/game_info.dart';

class WorldLevelsScreen extends StatefulWidget {
  final String worldId;

  const WorldLevelsScreen({
    super.key,
    required this.worldId,
  });

  @override
  State<WorldLevelsScreen> createState() => _WorldLevelsScreenState();
}

class _WorldLevelsScreenState extends State<WorldLevelsScreen> {
  final WorldService _worldService = WorldService();
  final StorageService _storageService = StorageService();
  World? _world;
  WorldProgress? _worldProgress;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    try {
      await _worldService.init();
      await _storageService.init();

      // Check if world is unlocked (this will unlock it if user is premium)
      final totalStars = _storageService.getUserProgress().totalStars;
      final isUnlocked =
          _worldService.isWorldUnlocked(widget.worldId, totalStars);

      // If world is not unlocked, go back
      if (!isUnlocked) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('هذا العالم مقفل. يرجى فتحه أولاً.'),
              backgroundColor: Colors.orange,
              duration: Duration(seconds: 2),
            ),
          );
          Navigator.pop(context);
          return;
        }
      }

      if (mounted) {
        setState(() {
          _world = WorldService.allWorlds.firstWhere(
            (w) => w.id == widget.worldId,
            orElse: () => WorldService.allWorlds.first,
          );
          _worldProgress =
              _worldService.getOrCreateWorldProgress(widget.worldId);
          _isLoading = false;
        });
      }
    } catch (e, stackTrace) {
      debugPrint('❌ Error loading world levels: $e');
      debugPrint('Stack: $stackTrace');
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('خطأ في تحميل المستويات: $e'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 3),
          ),
        );
        // Go back if there's an error
        Navigator.pop(context);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading || _world == null) {
      return Scaffold(
        body: Container(
          decoration: const BoxDecoration(
            gradient: AppTheme.blueGradient,
          ),
          child: const Center(
            child: CircularProgressIndicator(color: AppTheme.white),
          ),
        ),
      );
    }

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              _world!.color,
              _world!.color.withOpacity(0.7),
            ],
          ),
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
                    const SizedBox(width: 8),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _world!.icon,
                            style: const TextStyle(fontSize: 32),
                          ),
                          Text(
                            _world!.nameAr,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            _world!.descriptionAr,
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.9),
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ),
                    // Stars count
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.star, color: AppTheme.yellowAccent),
                          const SizedBox(width: 4),
                          Text(
                            '${_worldProgress?.totalStars ?? 0}',
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              // Levels Grid
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: GridView.builder(
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 3,
                      crossAxisSpacing: 16,
                      mainAxisSpacing: 16,
                      childAspectRatio: 0.9,
                    ),
                    itemCount: _world!.totalLevels,
                    itemBuilder: (context, index) {
                      final levelNumber = index + 1;
                      final levelProgress = _worldProgress?.levels[levelNumber];
                      final isUnlocked = levelNumber == 1 ||
                          (_worldProgress
                                  ?.levels[levelNumber - 1]?.isCompleted ??
                              false);

                      return _LevelCard(
                        levelNumber: levelNumber,
                        isUnlocked: isUnlocked,
                        isCompleted: levelProgress?.isCompleted ?? false,
                        stars: levelProgress?.stars ?? 0,
                        worldColor: _world!.color,
                        onTap: isUnlocked
                            ? () {
                                // Navigate to game selection for this level
                                _navigateToLevel(levelNumber);
                              }
                            : null,
                      );
                    },
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _navigateToLevel(int levelNumber) {
    // Show dialog to select game for this level
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('اختر اللعبة - المستوى $levelNumber'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: _world!.gameIds.map((gameId) {
            final game = GameDefinitions.allGames.firstWhere(
              (g) => g.id == gameId,
              orElse: () => GameDefinitions.allGames.first,
            );
            return ListTile(
              leading: Icon(game.icon, color: game.color),
              title: Text(game.name),
              onTap: () {
                Navigator.pop(context);
                // Navigate to game with level parameter
                Navigator.pushNamed(
                  context,
                  game.route,
                  arguments: {'level': levelNumber, 'worldId': widget.worldId},
                );
              },
            );
          }).toList(),
        ),
      ),
    );
  }
}

class _LevelCard extends StatelessWidget {
  final int levelNumber;
  final bool isUnlocked;
  final bool isCompleted;
  final int stars;
  final Color worldColor;
  final VoidCallback? onTap;

  const _LevelCard({
    required this.levelNumber,
    required this.isUnlocked,
    required this.isCompleted,
    required this.stars,
    required this.worldColor,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: isUnlocked
              ? (isCompleted ? worldColor : Colors.white)
              : Colors.grey.withOpacity(0.5),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Stack(
          children: [
            // Lock overlay
            if (!isUnlocked)
              Container(
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.5),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Center(
                  child: Icon(
                    Icons.lock,
                    color: Colors.white,
                    size: 30,
                  ),
                ),
              ),

            // Content
            Center(
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                      '$levelNumber',
                      style: TextStyle(
                        color: isUnlocked
                            ? (isCompleted ? Colors.white : worldColor)
                            : Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    if (isCompleted && stars > 0) ...[
                      const SizedBox(height: 4),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: List.generate(
                          3,
                          (index) => Icon(
                            Icons.star,
                            size: 12,
                            color: index < stars
                                ? AppTheme.yellowAccent
                                : Colors.grey,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
