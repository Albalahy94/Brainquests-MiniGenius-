import 'dart:math';
import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/services/storage_service.dart';
import '../../../../core/models/game_progress.dart';
import '../../../results/ui/result_screen.dart';
import '../../widgets/game_header.dart';

class FindDifferenceGameScreen extends StatefulWidget {
  final int level;
  final StorageService storageService;
  final String? worldId;

  const FindDifferenceGameScreen({
    super.key,
    required this.level,
    required this.storageService,
    this.worldId,
  });

  @override
  State<FindDifferenceGameScreen> createState() =>
      _FindDifferenceGameScreenState();
}

class DifferenceItem {
  final int id;
  final Offset position; // Relative position 0.0 - 1.0
  final Widget overlay;
  final double size;
  bool isFound;

  DifferenceItem({
    required this.id,
    required this.position,
    required this.overlay,
    this.size = 40.0,
    this.isFound = false,
  });
}

class _FindDifferenceGameScreenState extends State<FindDifferenceGameScreen> {
  late List<DifferenceItem> _differences;
  int _foundDifferences = 0;
  int _timeElapsed = 0;
  bool _isGameComplete = false;
  late int _totalDifferences;
  late DateTime _gameStartTime;

  // Default image
  final String _imagePath = 'assets/images/cartoon_park.png';

  @override
  void initState() {
    super.initState();
    _gameStartTime = DateTime.now();
    _initializeGame();
    _startTimer();
  }

  void _initializeGame() {
    _differences = _getLevelDifferences(widget.level);
    _totalDifferences = _differences.length;
  }

  List<DifferenceItem> _getLevelDifferences(int level) {
    // Example differences (extra items on Image B)
    final List<DifferenceItem> allPossible = [
      DifferenceItem(
        id: 0,
        position: const Offset(0.15, 0.25),
        overlay: const Icon(Icons.cloud, color: Colors.white, size: 30),
      ),
      DifferenceItem(
        id: 1,
        position: const Offset(0.65, 0.65),
        overlay: const Icon(Icons.local_florist, color: Colors.pink, size: 25),
      ),
      DifferenceItem(
        id: 2,
        position: const Offset(0.85, 0.35),
        overlay: const Icon(Icons.air, color: Colors.lightBlueAccent, size: 30),
      ),
      DifferenceItem(
        id: 3,
        position: const Offset(0.3, 0.8),
        overlay: const Icon(Icons.grass, color: Colors.greenAccent, size: 28),
      ),
      DifferenceItem(
        id: 4,
        position: const Offset(0.5, 0.5),
        overlay: const Icon(Icons.star, color: Colors.yellow, size: 25),
      ),
      DifferenceItem(
        id: 5,
        position: const Offset(0.2, 0.55),
        overlay: const Icon(Icons.pets, color: Colors.brown, size: 22),
      ),
    ];

    // Fixed seed per level for consistency
    final random = Random(level);
    final count = level <= 3 ? 3 : (level <= 6 ? 4 : 5);

    // Shuffle and take 'count' items
    List<DifferenceItem> selected = List.from(allPossible)..shuffle(random);
    return selected.take(count).toList();
  }

  void _startTimer() {
    Future.delayed(const Duration(seconds: 1), () {
      if (!_isGameComplete && mounted) {
        setState(() {
          _timeElapsed++;
        });
        _startTimer();
      }
    });
  }

  void _onSpotTap(DifferenceItem item) {
    if (item.isFound || _isGameComplete) return;

    setState(() {
      item.isFound = true;
      _foundDifferences++;
    });

    if (_foundDifferences == _totalDifferences) {
      _gameComplete();
    }
  }

  void _gameComplete() {
    _isGameComplete = true;

    // Calculate stars based on time
    int stars = 3;
    int maxTime = _totalDifferences * 10;
    if (_timeElapsed > maxTime * 0.8) stars = 2;
    if (_timeElapsed > maxTime * 1.2) stars = 1;

    // Calculate points
    int points = (150 * widget.level) - (_timeElapsed * 3);
    if (points < 10) points = 10;

    // Save progress
    final progress =
        widget.storageService.getOrCreateGameProgress('find_difference');
    final levelProgress = LevelProgress(
      levelNumber: widget.level,
      stars: stars,
      points: points,
      isCompleted: true,
      isUnlocked: true,
      completedAt: DateTime.now(),
    );
    progress.updateLevel(widget.level, levelProgress);

    if (widget.level < 10) {
      final nextLevelNum = widget.level + 1;
      var nextLevelProgress = progress.levels[nextLevelNum];

      if (nextLevelProgress == null) {
        nextLevelProgress = LevelProgress(
          levelNumber: nextLevelNum,
          isUnlocked: true,
        );
        progress.updateLevel(nextLevelNum, nextLevelProgress);
      } else if (!nextLevelProgress.isUnlocked) {
        nextLevelProgress = nextLevelProgress.copyWith(isUnlocked: true);
        progress.updateLevel(nextLevelNum, nextLevelProgress);
      }
    }

    widget.storageService.saveGameProgress(progress);

    Future.delayed(const Duration(milliseconds: 500), () {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => ResultScreen(
            stars: stars,
            points: points,
            level: widget.level,
            gameId: 'find_difference',
            storageService: widget.storageService,
            gameStartTime: _gameStartTime,
            worldId: widget.worldId,
          ),
        ),
      );
    });
  }

  Widget _buildImageStack({required bool isImageB}) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return Stack(
          fit: StackFit.loose,
          children: [
            // The Base Image
            Positioned.fill(
              child: Image.asset(
                _imagePath,
                fit: BoxFit.cover,
              ),
            ),

            // The Differences (Overlays) - Only shown on Image B
            if (isImageB)
              ..._differences.map((item) {
                return Positioned(
                  left: item.position.dx * constraints.maxWidth,
                  top: item.position.dy * constraints.maxHeight,
                  child: IgnorePointer(
                    child: item.overlay,
                  ),
                );
              }),

            // Hit Targets (Both images)
            ..._differences.map((item) {
              return Positioned(
                left: (item.position.dx * constraints.maxWidth) - 10,
                top: (item.position.dy * constraints.maxHeight) - 10,
                child: GestureDetector(
                  onTap: () => _onSpotTap(item),
                  child: Container(
                    width: item.size + 20,
                    height: item.size + 20,
                    color: Colors.transparent, // Hit test target
                    child: Center(
                      child: item.isFound
                          ? Container(
                              width: item.size + 10,
                              height: item.size + 10,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(
                                    color: AppTheme.mintGreen, width: 3),
                                color: AppTheme.mintGreen.withOpacity(0.3),
                              ),
                              child: const Icon(Icons.check,
                                  color: AppTheme.white, size: 20),
                            )
                          : null,
                    ),
                  ),
                ),
              );
            }),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: AppTheme.blueGradient,
        ),
        child: Column(
          children: [
            // Game Header
            GameHeader(
              level: widget.level,
              score: '$_foundDifferences/$_totalDifferences',
              timer:
                  '${_timeElapsed ~/ 60}:${(_timeElapsed % 60).toString().padLeft(2, '0')}',
              onExit: () => Navigator.pop(context),
            ),
            // Game Area
            Expanded(
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
                child: Row(
                  children: [
                    // Left Image
                    Expanded(
                      child: Container(
                        clipBehavior: Clip.hardEdge,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.white, width: 2),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.2),
                              blurRadius: 8,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: _buildImageStack(isImageB: false),
                      ),
                    ),

                    const SizedBox(width: 12),

                    // Right Image
                    Expanded(
                      child: Container(
                        clipBehavior: Clip.hardEdge,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.white, width: 2),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.2),
                              blurRadius: 8,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: _buildImageStack(isImageB: true),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                'Find $_totalDifferences differences!',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      color: AppTheme.white,
                      fontWeight: FontWeight.bold,
                    ),
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
