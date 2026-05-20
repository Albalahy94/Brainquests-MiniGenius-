import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/services/storage_service.dart';
import '../../../../core/models/game_progress.dart';
import '../../../results/ui/result_screen.dart';
import '../../widgets/game_header.dart';

class MazeRunnerGameScreen extends StatefulWidget {
  final int level;
  final StorageService storageService;
  final String? worldId;

  const MazeRunnerGameScreen({
    super.key,
    required this.level,
    required this.storageService,
    this.worldId,
  });

  @override
  State<MazeRunnerGameScreen> createState() => _MazeRunnerGameScreenState();
}

class _MazeRunnerGameScreenState extends State<MazeRunnerGameScreen> {
  late List<List<bool>> _maze; // true = wall, false = path
  int _playerRow = 0;
  int _playerCol = 0;
  int _endRow = 0;
  int _endCol = 0;
  int _mazeSize = 5;
  int _timeRemaining = 60;
  int _score = 0;
  bool _isGameActive = true;
  bool _isComplete = false;
  Timer? _timer;
  late DateTime _gameStartTime;

  @override
  void initState() {
    super.initState();
    _gameStartTime = DateTime.now();
    _mazeSize = 5 + (widget.level ~/ 2); // 5x5 to 10x10
    _timeRemaining = 90 - (widget.level * 3);
    _generateMaze();
    _startTimer();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!_isGameActive || _isComplete) {
        timer.cancel();
        return;
      }
      if (mounted) {
        setState(() {
          _timeRemaining--;
        });
        if (_timeRemaining <= 0) {
          _gameComplete(false);
          timer.cancel();
        }
      }
    });
  }

  void _generateMaze() {
    // Simple maze generation - create a path from start to end
    _maze =
        List.generate(_mazeSize, (i) => List.generate(_mazeSize, (j) => true));

    // Start at top-left, end at bottom-right
    _playerRow = 0;
    _playerCol = 0;
    _endRow = _mazeSize - 1;
    _endCol = _mazeSize - 1;

    // Create a simple path (snake-like)
    final random = Random();
    int currentRow = 0;
    int currentCol = 0;

    _maze[currentRow][currentCol] = false; // Start

    while (currentRow < _mazeSize - 1 || currentCol < _mazeSize - 1) {
      if (currentRow < _mazeSize - 1 &&
          (currentCol == _mazeSize - 1 || random.nextBool())) {
        currentRow++;
      } else {
        currentCol++;
      }
      _maze[currentRow][currentCol] = false;
    }

    // Add some extra paths for variety
    for (int i = 0; i < _mazeSize * 2; i++) {
      final row = random.nextInt(_mazeSize);
      final col = random.nextInt(_mazeSize);
      if (!(row == 0 && col == 0) &&
          !(row == _mazeSize - 1 && col == _mazeSize - 1)) {
        _maze[row][col] = false;
      }
    }

    // Ensure start and end are open
    _maze[0][0] = false;
    _maze[_mazeSize - 1][_mazeSize - 1] = false;
  }

  void _movePlayer(int deltaRow, int deltaCol) {
    if (!_isGameActive || _isComplete) return;

    final newRow = _playerRow + deltaRow;
    final newCol = _playerCol + deltaCol;

    if (newRow >= 0 &&
        newRow < _mazeSize &&
        newCol >= 0 &&
        newCol < _mazeSize &&
        !_maze[newRow][newCol]) {
      setState(() {
        _playerRow = newRow;
        _playerCol = newCol;
        _score += 5;
      });

      if (_playerRow == _endRow && _playerCol == _endCol) {
        _gameComplete(true);
      }
    }
  }

  void _gameComplete(bool success) {
    _isGameActive = false;
    _isComplete = true;
    _timer?.cancel();

    int stars = success ? 3 : 1;
    if (success) {
      if (_timeRemaining < 30) stars = 2;
      if (_timeRemaining < 15) stars = 1;
    }

    int points = _score + (_timeRemaining * 3);

    final progress =
        widget.storageService.getOrCreateGameProgress('maze_runner');
    final levelProgress = LevelProgress(
      levelNumber: widget.level,
      stars: stars,
      points: points,
      isCompleted: success,
      isUnlocked: true,
      completedAt: DateTime.now(),
    );
    progress.updateLevel(widget.level, levelProgress);

    if (success && widget.level < 10) {
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
      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => ResultScreen(
              stars: stars,
              points: points,
              level: widget.level,
              gameId: 'maze_runner',
              storageService: widget.storageService,
              gameStartTime: _gameStartTime,
              worldId: widget.worldId,
            ),
          ),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final cellSize = (MediaQuery.of(context).size.width - 80) / _mazeSize;

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: AppTheme.blueGradient,
        ),
        child: Column(
          children: [
            GameHeader(
              level: widget.level,
              score: 'Score: $_score',
              timer:
                  '${_timeRemaining ~/ 60}:${(_timeRemaining % 60).toString().padLeft(2, '0')}',
              onExit: () => Navigator.pop(context),
            ),
            // Maze
            Expanded(
              child: Center(
                child: Container(
                  margin: const EdgeInsets.all(20),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(_mazeSize, (row) {
                      return Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: List.generate(_mazeSize, (col) {
                          final isWall = _maze[row][col];
                          final isPlayer =
                              _playerRow == row && _playerCol == col;
                          final isEnd = _endRow == row && _endCol == col;

                          return Container(
                            width: cellSize,
                            height: cellSize,
                            margin: const EdgeInsets.all(1),
                            decoration: BoxDecoration(
                              color: isWall
                                  ? Colors.brown[800]
                                  : isPlayer
                                      ? Colors.blue
                                      : isEnd
                                          ? Colors.green
                                          : Colors.white,
                              borderRadius: BorderRadius.circular(4),
                              border: Border.all(
                                color: isWall
                                    ? Colors.brown[900]!
                                    : Colors.grey[300]!,
                                width: 1,
                              ),
                            ),
                            child: isPlayer
                                ? const Icon(Icons.person,
                                    color: Colors.white, size: 20)
                                : isEnd
                                    ? const Icon(Icons.flag,
                                        color: Colors.white, size: 20)
                                    : null,
                          );
                        }),
                      );
                    }),
                  ),
                ),
              ),
            ),

            // Controls
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                children: [
                  // Up
                  IconButton(
                    icon: const Icon(Icons.arrow_upward, size: 40),
                    color: Colors.white,
                    onPressed: () => _movePlayer(-1, 0),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Left
                      IconButton(
                        icon: const Icon(Icons.arrow_back, size: 40),
                        color: Colors.white,
                        onPressed: () => _movePlayer(0, -1),
                      ),
                      const SizedBox(width: 60),
                      // Right
                      IconButton(
                        icon: const Icon(Icons.arrow_forward, size: 40),
                        color: Colors.white,
                        onPressed: () => _movePlayer(0, 1),
                      ),
                    ],
                  ),
                  // Down
                  IconButton(
                    icon: const Icon(Icons.arrow_downward, size: 40),
                    color: Colors.white,
                    onPressed: () => _movePlayer(1, 0),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
