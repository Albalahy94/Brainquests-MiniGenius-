import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';
import '../../core/models/game_info.dart';
import '../../core/services/storage_service.dart';
import '../widgets/level_card.dart';

class BaseGameSelectScreen extends StatelessWidget {
  final GameInfo gameInfo;
  final StorageService storageService;

  const BaseGameSelectScreen({
    super.key,
    required this.gameInfo,
    required this.storageService,
  });

  @override
  Widget build(BuildContext context) {
    final progress = storageService.getOrCreateGameProgress(gameInfo.id);

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
              // Game Description
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

              // Levels Grid
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
                      final levelProgress = progress.levels[levelNumber];
                      bool isUnlocked = false;
                      if (levelNumber == 1) {
                        isUnlocked = true;
                      } else {
                        isUnlocked = true;
                        for (int i = 1; i < levelNumber; i++) {
                          if (!(progress.levels[i]?.isCompleted ?? false)) {
                            isUnlocked = false;
                            break;
                          }
                        }
                      }

                      return LevelCard(
                        levelNumber: levelNumber,
                        isUnlocked: isUnlocked,
                        stars: levelProgress?.stars ?? 0,
                        onTap: isUnlocked
                            ? () {
                                // Navigate to game level
                                // This will be overridden by specific game screens
                              }
                            : null,
                      );
                    },
                  ),
                ),
              ),

              // Start Button (for first unlocked level)
              Padding(
                padding: const EdgeInsets.all(20.0),
                child: SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      // Navigate to game - to be implemented by child
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
