import 'package:flutter/material.dart';
import '../../../../core/services/storage_service.dart';
import '../../../../core/models/game_progress.dart';
import '../../../widgets/level_card.dart';
import 'maze_runner_game_screen.dart';

class MazeRunnerSelectScreen extends StatefulWidget {
  const MazeRunnerSelectScreen({super.key});

  @override
  State<MazeRunnerSelectScreen> createState() => _MazeRunnerSelectScreenState();
}

class _MazeRunnerSelectScreenState extends State<MazeRunnerSelectScreen> {
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
          _progress = _storageService.getOrCreateGameProgress('maze_runner');
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
        builder: (context) => MazeRunnerGameScreen(
          level: levelNumber,
          storageService: _storageService,
          worldId: _worldId,
        ),
      ),
    ).then((_) {
      if (mounted) {
        setState(() {
          _progress = _storageService.getOrCreateGameProgress('maze_runner');
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_progress == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Maze Runner'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF4DB7FF), Color(0xFF5ADBB5)],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              const Padding(
                padding: EdgeInsets.all(20.0),
                child: Text(
                  'Find the correct path',
                  style: TextStyle(color: Colors.white, fontSize: 18),
                  textAlign: TextAlign.center,
                ),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: GridView.builder(
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 5,
                      crossAxisSpacing: 12,
                      mainAxisSpacing: 12,
                      childAspectRatio: 1.0,
                    ),
                    itemCount: 10,
                    itemBuilder: (context, index) {
                      final levelNumber = index + 1;
                      final levelProgress = _progress!.levels[levelNumber];
                      bool isUnlocked = levelNumber == 1;
                      if (levelNumber > 1) {
                        isUnlocked = _progress!.levels[levelNumber - 1]?.isCompleted ?? false;
                      }
                      return LevelCard(
                        levelNumber: levelNumber,
                        isUnlocked: isUnlocked,
                        stars: levelProgress?.stars ?? 0,
                        onTap: isUnlocked ? () => _startLevel(levelNumber) : null,
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

