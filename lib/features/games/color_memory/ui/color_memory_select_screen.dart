import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/models/game_info.dart';
import '../../../../core/services/storage_service.dart';
import '../../../../core/services/tts_service.dart';
import '../../../../core/models/game_progress.dart';
import '../../../widgets/level_card.dart';
import 'color_memory_game_screen.dart';
import 'package:provider/provider.dart';
import '../../../../core/providers/app_state_provider.dart';

class ColorMemorySelectScreen extends StatefulWidget {
  const ColorMemorySelectScreen({super.key});

  @override
  State<ColorMemorySelectScreen> createState() =>
      _ColorMemorySelectScreenState();
}

class _ColorMemorySelectScreenState extends State<ColorMemorySelectScreen> {
  late final StorageService _storageService;
  GameProgress? _progress;
  String? _worldId;

  @override
  void initState() {
    super.initState();
    _storageService = StorageService();
    _storageService.init().then((_) {
      if (mounted) {
        setState(() {
          _progress = _storageService.getOrCreateGameProgress('color_memory');
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
            return;
          }
        }
        
        // Speak description
        Future.delayed(const Duration(milliseconds: 500), () {
          if (mounted) {
            final gameInfo = GameDefinitions.allGames.firstWhere((g) => g.id == 'color_memory');
            final appState = context.read<AppStateProvider>();
            TtsService().speak(gameInfo.description, appState.locale.languageCode);
          }
        });
      }
    });
  }

  @override
  void dispose() {
    TtsService().stop();
    super.dispose();
  }

  void _startLevel(int levelNumber) {
    TtsService().stop();
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ColorMemoryGameScreen(
          level: levelNumber,
          storageService: _storageService,
          worldId: _worldId,
        ),
      ),
    ).then((_) {
      if (mounted) {
        setState(() {
          _progress = _storageService.getOrCreateGameProgress('color_memory');
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final gameInfo = GameDefinitions.allGames.firstWhere(
      (g) => g.id == 'color_memory',
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
            ],
          ),
        ),
      ),
    );
  }
}
