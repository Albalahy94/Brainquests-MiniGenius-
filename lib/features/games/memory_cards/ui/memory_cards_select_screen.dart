import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/models/game_info.dart';
import '../../../../core/services/storage_service.dart';
import '../../../../core/models/game_progress.dart';
import '../../../widgets/level_card.dart';
import '../ui/memory_cards_game_screen.dart';

class MemoryCardsSelectScreen extends StatefulWidget {
  const MemoryCardsSelectScreen({super.key});

  @override
  State<MemoryCardsSelectScreen> createState() =>
      _MemoryCardsSelectScreenState();
}

class _MemoryCardsSelectScreenState extends State<MemoryCardsSelectScreen> {
  late final StorageService _storageService;
  GameProgress? _progress;
  String? _worldId; // Store worldId if coming from world

  @override
  void initState() {
    super.initState();
    _storageService = StorageService();
    _storageService.init().then((_) {
      if (mounted) {
        setState(() {
          _progress = _storageService.getOrCreateGameProgress('memory_cards');
        });
        
        // Check if we have arguments (from world levels)
        final args = ModalRoute.of(context)?.settings.arguments;
        if (args != null && args is Map<String, dynamic>) {
          final level = args['level'] as int?;
          _worldId = args['worldId'] as String?;
          if (level != null) {
            // Start the specified level directly
            Future.delayed(const Duration(milliseconds: 300), () {
              if (mounted) {
                _startLevel(level);
              }
            });
          }
        }
      }
    });
  }

  void _startLevel(int levelNumber) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => MemoryCardsGameScreen(
          level: levelNumber,
          storageService: _storageService,
          worldId: _worldId,
        ),
      ),
    ).then((_) {
      // Refresh progress after returning from game
      if (mounted) {
        setState(() {
          _progress = _storageService.getOrCreateGameProgress('memory_cards');
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final gameInfo = GameDefinitions.allGames.firstWhere(
      (g) => g.id == 'memory_cards',
    );

    if (_progress == null) {
      return Scaffold(
        appBar: AppBar(
          title: Text(gameInfo.name),
        ),
        body: const Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(gameInfo.name),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: AppTheme.blueGradient,
        ),
        child: SafeArea(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(20.0),
                child: Text(
                  gameInfo.description,
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        color: AppTheme.white,
                      ),
                  textAlign: TextAlign.center,
                ),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: GridView.builder(
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 5,
                      crossAxisSpacing: 12,
                      mainAxisSpacing: 12,
                      childAspectRatio: 1.0,
                    ),
                    itemCount: 10,
                    itemBuilder: (context, index) {
                      final levelNumber = index + 1;
                      final levelProgress = _progress!.levels[levelNumber];
                      bool isUnlocked = false;
                      if (levelNumber == 1) {
                        isUnlocked = true;
                      } else {
                        // Strict sequential check:
                        // 1. Previous level must be completed
                        // 2. AND Previous level must be unlocked (to prevent gaps)
                        // Since we can't easily check 'unlocked' state of previous without recursion,
                        // we can rely on the fact that if level N is unlocked, N-1 must be completed.
                        // So checking ALL previous levels are completed? No, too expensive.

                        // Better approach:
                        // Level N is unlocked if (Level N-1 is Completed) AND (Level N-1 is Unlocked).
                        // But calculating this per item is tricky.

                        // Let's use the robust logic:
                        // A level is unlocked if ALL previous levels are completed.
                        // This ensures no gaps.
                        isUnlocked = true;
                        for (int i = 1; i < levelNumber; i++) {
                          if (!(_progress!.levels[i]?.isCompleted ?? false)) {
                            isUnlocked = false;
                            break;
                          }
                        }
                      }

                      return LevelCard(
                        levelNumber: levelNumber,
                        isUnlocked: isUnlocked,
                        stars: levelProgress?.stars ?? 0,
                        onTap:
                            isUnlocked ? () => _startLevel(levelNumber) : null,
                      );
                    },
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(20.0),
                child: SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      final firstUnlocked = _progress!.unlockedLevels == 0
                          ? 1
                          : _progress!.completedLevels + 1;
                      if (firstUnlocked <= 10) {
                        _startLevel(firstUnlocked);
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.yellowAccent,
                      foregroundColor: AppTheme.darkText,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    child: Text(
                      'Start',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
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
