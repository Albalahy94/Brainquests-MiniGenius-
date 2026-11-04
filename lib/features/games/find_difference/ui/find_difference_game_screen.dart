import 'dart:math';
import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/services/storage_service.dart';
import '../../../../core/models/game_progress.dart';
import '../../../results/ui/result_screen.dart';
import '../../widgets/game_header.dart';
import '../models/difference_theme.dart';

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

class _FindDifferenceGameScreenState extends State<FindDifferenceGameScreen> {
  late DifferenceScene _scene;
  late List<DifferenceSpot> _differences;
  int _foundDifferences = 0;
  int _timeElapsed = 0;
  bool _isGameComplete = false;
  late int _totalDifferences;
  late DateTime _gameStartTime;
  int? _hintedSpotId;

  @override
  void initState() {
    super.initState();
    _gameStartTime = DateTime.now();
    _initializeGame();
    _startTimer();
  }

  void _initializeGame() {
    _scene = DifferenceLibrary.getSceneForLevel(widget.level);
    _differences = _scene.differences.map((d) => d.clone()).toList();
    _totalDifferences = _differences.length;
    _foundDifferences = 0;
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

  void _onSpotTap(DifferenceSpot item) {
    if (item.isFound || _isGameComplete) return;

    setState(() {
      item.isFound = true;
      _foundDifferences++;
      if (_hintedSpotId == item.id) {
        _hintedSpotId = null;
      }
    });

    if (_foundDifferences == _totalDifferences) {
      _gameComplete();
    }
  }

  void _onImageTap(TapUpDetails details, BoxConstraints constraints) {
    if (_isGameComplete) return;

    final clickX = details.localPosition.dx / constraints.maxWidth;
    final clickY = details.localPosition.dy / constraints.maxHeight;

    // Search for closest unfound difference within hit tolerance
    DifferenceSpot? nearest;
    double minDistance = 0.14; // normalized hit radius

    for (final spot in _differences) {
      if (spot.isFound) continue;
      final dist = sqrt(pow(clickX - spot.x, 2) + pow(clickY - spot.y, 2));
      if (dist < minDistance) {
        minDistance = dist;
        nearest = spot;
      }
    }

    if (nearest != null) {
      _onSpotTap(nearest);
    }
  }

  void _giveHint() {
    if (_isGameComplete) return;
    final unfound = _differences.where((d) => !d.isFound).toList();
    if (unfound.isEmpty) return;

    setState(() {
      _hintedSpotId = unfound.first.id;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          Directionality.of(context) == TextDirection.rtl
              ? 'تلميح: ابحث عن ${unfound.first.hintAr}'
              : 'Hint: Look for ${unfound.first.hintEn}',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: const Color(0xFFFF6B6B),
        duration: const Duration(seconds: 3),
      ),
    );
  }

  void _gameComplete() {
    _isGameComplete = true;

    // Calculate stars based on time
    int stars = 3;
    int maxTime = _totalDifferences * 12;
    if (_timeElapsed > maxTime * 0.8) stars = 2;
    if (_timeElapsed > maxTime * 1.3) stars = 1;

    // Calculate points
    int points = (160 * widget.level) - (_timeElapsed * 2);
    if (points < 20) points = 20;

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

    if (widget.level < 20) {
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

    Future.delayed(const Duration(milliseconds: 600), () {
      if (!mounted) return;
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

  Widget _buildSceneCanvas({required bool isImageB, required BoxConstraints constraints}) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTapUp: (details) => _onImageTap(details, constraints),
      child: Stack(
        fit: StackFit.expand,
        children: [
          // Background Gradient
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: _scene.backgroundGradient,
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
          ),

          // Ground / Horizon ambient styling
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            height: constraints.maxHeight * 0.35,
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Colors.black.withOpacity(0.0),
                    Colors.black.withOpacity(0.18),
                  ],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
            ),
          ),

          // Base Elements (Identical on both Image A and Image B)
          ..._scene.baseElements.map((el) {
            return Positioned(
              left: (el.x * constraints.maxWidth) - (el.size / 2),
              top: (el.y * constraints.maxHeight) - (el.size / 2),
              child: IgnorePointer(
                child: Icon(
                  el.icon,
                  color: el.color,
                  size: el.size,
                  shadows: [
                    Shadow(
                      color: Colors.black.withOpacity(0.35),
                      blurRadius: 4,
                      offset: const Offset(1, 2),
                    ),
                  ],
                ),
              ),
            );
          }),

          // Differences - ONLY rendered on Image B (Compare)
          if (isImageB)
            ..._differences.map((spot) {
              final isHinted = _hintedSpotId == spot.id && !spot.isFound;
              return Positioned(
                left: (spot.x * constraints.maxWidth) - (spot.size / 2),
                top: (spot.y * constraints.maxHeight) - (spot.size / 2),
                child: IgnorePointer(
                  child: Container(
                    padding: isHinted ? const EdgeInsets.all(4) : EdgeInsets.zero,
                    decoration: isHinted
                        ? BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.amber, width: 3),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.amber.withOpacity(0.6),
                                blurRadius: 10,
                                spreadRadius: 2,
                              ),
                            ],
                          )
                        : null,
                    child: Icon(
                      spot.icon,
                      color: spot.color,
                      size: spot.size,
                      shadows: [
                        Shadow(
                          color: Colors.black.withOpacity(0.4),
                          blurRadius: 6,
                          offset: const Offset(1, 2),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }),

          // Found Markers (Rendered on BOTH Image A and Image B with celebration checkmark ring)
          ..._differences.where((spot) => spot.isFound).map((spot) {
            final markerSize = spot.size + 14;
            return Positioned(
              left: (spot.x * constraints.maxWidth) - (markerSize / 2),
              top: (spot.y * constraints.maxHeight) - (markerSize / 2),
              child: IgnorePointer(
                child: Container(
                  width: markerSize,
                  height: markerSize,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: AppTheme.mintGreen, width: 3),
                    color: AppTheme.mintGreen.withOpacity(0.28),
                    boxShadow: [
                      BoxShadow(
                        color: AppTheme.mintGreen.withOpacity(0.5),
                        blurRadius: 6,
                        spreadRadius: 1,
                      ),
                    ],
                  ),
                  child: const Center(
                    child: Icon(
                      Icons.check_rounded,
                      color: Colors.white,
                      size: 20,
                    ),
                  ),
                ),
              ),
            );
          }),

          // Corner Label (Original vs Compare)
          Positioned(
            top: 6,
            left: 6,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.45),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                isImageB
                    ? (Directionality.of(context) == TextDirection.rtl ? 'الصورة ٢' : 'Image B')
                    : (Directionality.of(context) == TextDirection.rtl ? 'الأصلية' : 'Image A'),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isAr = Directionality.of(context) == TextDirection.rtl;
    final sceneTitle = isAr ? _scene.titleAr : _scene.titleEn;

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: AppTheme.blueGradient,
        ),
        child: SafeArea(
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

              // Level Theme Title Badge
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.18),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: Colors.white.withOpacity(0.3)),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(_scene.mainIcon, color: Colors.amber, size: 20),
                      const SizedBox(width: 8),
                      Text(
                        sceneTitle,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Game Comparison Area (Responsive side-by-side)
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 6.0),
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      final isLandscape = constraints.maxWidth > constraints.maxHeight;

                      if (isLandscape) {
                        return Row(
                          children: [
                            // Left Image
                            Expanded(
                              child: Container(
                                clipBehavior: Clip.hardEdge,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(16),
                                  border: Border.all(color: Colors.white, width: 2.5),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.25),
                                      blurRadius: 10,
                                      offset: const Offset(0, 4),
                                    ),
                                  ],
                                ),
                                child: LayoutBuilder(
                                  builder: (c, innerBox) => _buildSceneCanvas(
                                    isImageB: false,
                                    constraints: innerBox,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 10),
                            // Right Image
                            Expanded(
                              child: Container(
                                clipBehavior: Clip.hardEdge,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(16),
                                  border: Border.all(color: Colors.white, width: 2.5),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.25),
                                      blurRadius: 10,
                                      offset: const Offset(0, 4),
                                    ),
                                  ],
                                ),
                                child: LayoutBuilder(
                                  builder: (c, innerBox) => _buildSceneCanvas(
                                    isImageB: true,
                                    constraints: innerBox,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        );
                      } else {
                        // Portrait: stacked top and bottom
                        return Column(
                          children: [
                            // Top Image
                            Expanded(
                              child: Container(
                                clipBehavior: Clip.hardEdge,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(14),
                                  border: Border.all(color: Colors.white, width: 2.5),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.25),
                                      blurRadius: 8,
                                      offset: const Offset(0, 3),
                                    ),
                                  ],
                                ),
                                child: LayoutBuilder(
                                  builder: (c, innerBox) => _buildSceneCanvas(
                                    isImageB: false,
                                    constraints: innerBox,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(height: 8),
                            // Bottom Image
                            Expanded(
                              child: Container(
                                clipBehavior: Clip.hardEdge,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(14),
                                  border: Border.all(color: Colors.white, width: 2.5),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.25),
                                      blurRadius: 8,
                                      offset: const Offset(0, 3),
                                    ),
                                  ],
                                ),
                                child: LayoutBuilder(
                                  builder: (c, innerBox) => _buildSceneCanvas(
                                    isImageB: true,
                                    constraints: innerBox,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        );
                      }
                    },
                  ),
                ),
              ),

              // Bottom Bar: Instructions & Hint Button
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Status text
                    Text(
                      isAr
                          ? 'ابحث عن $_totalDifferences فروقات بين الصورتين!'
                          : 'Find $_totalDifferences differences!',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    // Hint Button
                    ElevatedButton.icon(
                      onPressed: _giveHint,
                      icon: const Icon(Icons.lightbulb_rounded, color: Colors.amber, size: 20),
                      label: Text(
                        isAr ? 'تلميح' : 'Hint',
                        style: TextStyle(
                          color: Color(0xFF2C3E50),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
