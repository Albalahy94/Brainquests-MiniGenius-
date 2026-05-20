import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/services/storage_service.dart';
import '../../../../core/models/game_progress.dart';
import '../../../results/ui/result_screen.dart';
import '../../widgets/game_header.dart';

class ColorMemoryGameScreen extends StatefulWidget {
  final int level;
  final StorageService storageService;
  final String? worldId;

  const ColorMemoryGameScreen({
    super.key,
    required this.level,
    required this.storageService,
    this.worldId,
  });

  @override
  State<ColorMemoryGameScreen> createState() => _ColorMemoryGameScreenState();
}

class _ColorMemoryGameScreenState extends State<ColorMemoryGameScreen> {
  late List<Color> _sequence;
  List<int> _userSequence = [];
  int _currentStep = 0;
  bool _isShowingSequence = false;
  bool _isWaitingForInput = false;
  int _score = 0;
  late int _sequenceLength;
  int _round = 1;
  int _maxRounds = 5;
  Timer? _sequenceTimer;
  late DateTime _gameStartTime;

  final List<Color> _colors = [
    AppTheme.primaryBlue,
    AppTheme.yellowAccent,
    AppTheme.mintGreen,
    Colors.purple,
    Colors.orange,
    Colors.pink,
  ];

  @override
  void initState() {
    super.initState();
    _gameStartTime = DateTime.now();
    _sequenceLength = 3 + (widget.level ~/ 2); // 3-8 steps
    _sequenceLength = min(_sequenceLength, 10);
    _maxRounds = 3 + (widget.level ~/ 3);
    _startNewRound();
  }

  @override
  void dispose() {
    _sequenceTimer?.cancel();
    super.dispose();
  }

  void _startNewRound() {
    setState(() {
      _sequence = [];
      _userSequence = [];
      _currentStep = 0;
      _isShowingSequence = true;
      _isWaitingForInput = false;
    });

    // Generate sequence
    final random = Random();
    int colorCount = min(4 + (widget.level ~/ 3), _colors.length);
    for (int i = 0; i < _sequenceLength; i++) {
      _sequence.add(_colors[random.nextInt(colorCount)]);
    }

    // Show sequence
    _showSequence();
  }

  void _showSequence() {
    int step = 0;
    int delay = max(600 - (widget.level * 30), 300); // Faster for higher levels

    _sequenceTimer?.cancel();
    _sequenceTimer = Timer.periodic(Duration(milliseconds: delay), (timer) {
      if (step < _sequence.length) {
        if (mounted) {
          setState(() {
            _currentStep = step;
          });
        }
        step++;
      } else {
        timer.cancel();
        if (mounted) {
          setState(() {
            _isShowingSequence = false;
            _isWaitingForInput = true;
            _currentStep = -1;
          });
        }
      }
    });
  }

  void _onColorTap(int colorIndex) {
    if (!_isWaitingForInput || _isShowingSequence) return;

    setState(() {
      _userSequence.add(colorIndex);
    });

    // Check if correct
    int currentIndex = _userSequence.length - 1;
    if (_userSequence[currentIndex] !=
        _colors.indexOf(_sequence[currentIndex])) {
      // Wrong answer
      _gameOver(false);
      return;
    }

    // Check if sequence complete
    if (_userSequence.length == _sequence.length) {
      // Round complete
      _score += 25 * widget.level * _round;

      if (_round >= _maxRounds) {
        _gameOver(true);
      } else {
        setState(() {
          _round++;
          _sequenceLength++; // Increase difficulty
        });
        Future.delayed(const Duration(milliseconds: 800), () {
          if (mounted) {
            _startNewRound();
          }
        });
      }
    }
  }

  void _gameOver(bool completed) {
    _sequenceTimer?.cancel();

    // Calculate stars based on score
    int stars = 1;
    if (completed) {
      stars = 3;
      if (_round < _maxRounds) stars = 2;
    } else {
      if (_round >= _maxRounds * 0.7) stars = 2;
    }

    int points = _score;

    final progress =
        widget.storageService.getOrCreateGameProgress('color_memory');
    final levelProgress = LevelProgress(
      levelNumber: widget.level,
      stars: stars,
      points: points,
      isCompleted: true,
      isUnlocked: true,
      completedAt: DateTime.now(),
    );
    progress.updateLevel(widget.level, levelProgress);

    if (widget.level < 15) {
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
      if (!mounted) return;
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => ResultScreen(
            stars: stars,
            points: points,
            level: widget.level,
            gameId: 'color_memory',
            storageService: widget.storageService,
            gameStartTime: _gameStartTime,
          ),
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    int colorCount = min(4 + (widget.level ~/ 3), _colors.length);
    int crossAxisCount = colorCount <= 4 ? 2 : 3;

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
              score: '$_score',
              additionalInfo: 'جولة: $_round/$_maxRounds',
              onExit: () => Navigator.pop(context),
            ),
            // Instructions
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  _isShowingSequence
                      ? 'شاهد التسلسل...'
                      : 'كرر التسلسل! (${_userSequence.length}/${_sequence.length})',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: AppTheme.white,
                        fontWeight: FontWeight.bold,
                      ),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
            // Color grid
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: GridView.builder(
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: crossAxisCount,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                    childAspectRatio: 1.0,
                  ),
                  itemCount: colorCount,
                  itemBuilder: (context, index) {
                    final color = _colors[index];
                    final isHighlighted = _isShowingSequence &&
                        _currentStep < _sequence.length &&
                        _sequence[_currentStep] == color;

                    final wasJustTapped = _isWaitingForInput &&
                        _userSequence.isNotEmpty &&
                        _userSequence.last == index;

                    return GestureDetector(
                      onTap: () => _onColorTap(index),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        decoration: BoxDecoration(
                          color: isHighlighted || wasJustTapped
                              ? color.withOpacity(1.0)
                              : _isWaitingForInput
                                  ? color.withOpacity(0.7)
                                  : color.withOpacity(0.5),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: isHighlighted || wasJustTapped
                                ? Colors.white
                                : Colors.transparent,
                            width: 4,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: isHighlighted || wasJustTapped
                                  ? color.withOpacity(0.8)
                                  : Colors.black.withOpacity(0.2),
                              blurRadius:
                                  isHighlighted || wasJustTapped ? 20 : 4,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: wasJustTapped
                            ? const Icon(Icons.check,
                                color: AppTheme.white, size: 50)
                            : null,
                      ),
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
