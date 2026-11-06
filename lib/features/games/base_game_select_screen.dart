import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';
import '../../core/models/game_info.dart';
import '../../core/services/storage_service.dart';
import '../../core/services/vip_service.dart';
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
    final isVipUser = VipService().isUserVip(storageService);
    final isAr = Directionality.of(context) == TextDirection.rtl;

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
                padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 12.0),
                child: Column(
                  children: [
                    Text(
                      gameInfo.description,
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            color: AppTheme.white,
                          ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.12),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: FittedBox(
                        fit: BoxFit.scaleDown,
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.check_circle_outline, color: AppTheme.mintGreen, size: 16),
                            const SizedBox(width: 6),
                            Text(
                              isAr ? 'المراحل 1-10 مجانية' : 'Levels 1-10 Free',
                              style: const TextStyle(color: Colors.white, fontSize: 12),
                            ),
                            const SizedBox(width: 12),
                            const Icon(Icons.workspace_premium, color: Color(0xFFFFD54F), size: 16),
                            const SizedBox(width: 6),
                            Text(
                              isAr ? 'المراحل 11-20 للمحترفين VIP' : 'Levels 11-20 VIP Pro',
                              style: const TextStyle(color: Color(0xFFFFD54F), fontSize: 12, fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // Levels Grid
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: GridView.builder(
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 5,
                      crossAxisSpacing: 10,
                      mainAxisSpacing: 10,
                      childAspectRatio: 1.0,
                    ),
                    itemCount: VipService.totalLevelsPerGame,
                    itemBuilder: (context, index) {
                      final levelNumber = index + 1;
                      final isVip = VipService.isVipLevel(levelNumber);
                      final levelProgress = progress.levels[levelNumber];

                      bool isUnlocked = false;
                      if (!isVip) {
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
                      } else {
                        if (isVipUser) {
                          isUnlocked = true;
                          for (int i = 1; i < levelNumber; i++) {
                            if (!(progress.levels[i]?.isCompleted ?? false)) {
                              isUnlocked = false;
                              break;
                            }
                          }
                        } else {
                          isUnlocked = false;
                        }
                      }

                      return LevelCard(
                        levelNumber: levelNumber,
                        isUnlocked: isUnlocked,
                        isVip: isVip,
                        stars: levelProgress?.stars ?? 0,
                        onTap: () {
                          if (isVip && !isVipUser) {
                            VipService().showVipLockedDialog(
                              context,
                              gameName: gameInfo.name,
                              levelNumber: levelNumber,
                            );
                          }
                        },
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
}
