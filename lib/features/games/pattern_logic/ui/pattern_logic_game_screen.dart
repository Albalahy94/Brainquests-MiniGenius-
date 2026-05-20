import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/services/storage_service.dart';
import '../../../../core/models/game_progress.dart';
import '../../../results/ui/result_screen.dart';
import '../../widgets/game_header.dart';

class PatternLogicGameScreen extends StatefulWidget {
  final int level;
  final StorageService storageService;
  final String? worldId;

  const PatternLogicGameScreen({
    super.key,
    required this.level,
    required this.storageService,
    this.worldId,
  });

  @override
  State<PatternLogicGameScreen> createState() => _PatternLogicGameScreenState();
}

class _PatternLogicGameScreenState extends State<PatternLogicGameScreen> {
  late List<PatternItem> _pattern;
  late List<PatternItem> _options;
  int _round = 0;
  int _correctAnswers = 0;
  late int _totalRounds;
  Timer? _timer;
  int _timeRemaining = 50;
  int _score = 0;
  late DateTime _gameStartTime;

  final List<Color> _colors = [
    AppTheme.primaryBlue,
    AppTheme.yellowAccent,
    AppTheme.mintGreen,
    Colors.purple,
    Colors.orange,
    Colors.pink,
  ];

  final List<IconData> _shapes = [
    Icons.circle_outlined,
    Icons.square_outlined,
    Icons.star_outline,
    Icons.favorite_border,
    Icons.hexagon_outlined,
    Icons.change_history,
  ];

  @override
  void initState() {
    super.initState();
    _gameStartTime = DateTime.now();
    _totalRounds = 5 + (widget.level ~/ 2);
    _startTimer();
    _generateRound();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (mounted) {
        setState(() {
          _timeRemaining--;
        });
        if (_timeRemaining <= 0) {
          _gameComplete();
          timer.cancel();
        }
      }
    });
  }

  void _generateRound() {
    final random = Random();
    int patternLength = 3 + (widget.level ~/ 2);
    patternLength = min(patternLength, 8);

    // Simple repeating pattern
    int repeatLength = widget.level <= 3 ? 2 : (widget.level <= 6 ? 3 : 4);
    List<PatternItem> base = List.generate(repeatLength, (i) {
      return PatternItem(
        color: _colors[i % min(4 + widget.level ~/ 2, _colors.length)],
        icon: _shapes[i % min(4 + widget.level ~/ 2, _shapes.length)],
      );
    });

    _pattern = [];
    for (int i = 0; i < patternLength; i++) {
      _pattern.add(base[i % base.length]);
    }

    final correctAnswer = base[patternLength % base.length];

    Set<String> usedKeys = {correctAnswer.key};
    List<PatternItem> wrongOptions = [];

    while (wrongOptions.length < 3) {
      final wrongItem = PatternItem(
        color:
            _colors[random.nextInt(min(4 + widget.level ~/ 2, _colors.length))],
        icon:
            _shapes[random.nextInt(min(4 + widget.level ~/ 2, _shapes.length))],
      );
      if (!usedKeys.contains(wrongItem.key)) {
        wrongOptions.add(wrongItem);
        usedKeys.add(wrongItem.key);
      }
    }

    _options = [correctAnswer, ...wrongOptions];
    _options.shuffle(random);
  }

  void _onOptionSelected(PatternItem option) {
    final repeatLength = widget.level <= 3 ? 2 : (widget.level <= 6 ? 3 : 4);
    final correctIndex = _pattern.length % repeatLength;
    final correctAnswer = _pattern[correctIndex];

    final isCorrect = option.key == correctAnswer.key;

    if (isCorrect) {
      setState(() {
        _score += 20 * widget.level;
        _correctAnswers++;
        _round++;
      });

      if (_round >= _totalRounds) {
        _gameComplete();
      } else {
        Future.delayed(const Duration(milliseconds: 500), () {
          if (mounted) {
            setState(() {
              _generateRound();
            });
          }
        });
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Try again!', style: TextStyle(color: Colors.white)),
          backgroundColor: Colors.redAccent,
          duration: Duration(milliseconds: 500),
        ),
      );
      setState(() {
        if (_score >= 15) _score -= 15;
      });
    }
  }

  void _gameComplete() {
    _timer?.cancel();

    int stars = 3;
    double accuracy = _round > 0 ? _correctAnswers / _round : 0;
    if (_round < _totalRounds) {
      accuracy = _correctAnswers / _totalRounds;
    }

    if (accuracy < 0.85) stars = 2;
    if (accuracy < 0.6) stars = 1;

    int points = _score + (_timeRemaining * 2);

    final progress =
        widget.storageService.getOrCreateGameProgress('pattern_logic');
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
            gameId: 'pattern_logic',
            storageService: widget.storageService,
            gameStartTime: _gameStartTime,
            worldId: widget.worldId,
          ),
        ),
      );
    });
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
            GameHeader(
              level: widget.level,
              score: '$_score',
              timer:
                  '${_timeRemaining ~/ 60}:${(_timeRemaining % 60).toString().padLeft(2, '0')}',
              additionalInfo: 'جولة: $_round/$_totalRounds',
              onExit: () => Navigator.pop(context),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Text(
                'أكمل النمط:',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: AppTheme.white,
                    ),
              ),
            ),
            // Pattern display
            Expanded(
              flex: 2,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Center(
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        ..._pattern.map((item) => Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 6.0),
                              child: Container(
                                width: 55,
                                height: 55,
                                decoration: BoxDecoration(
                                  color: item.color,
                                  shape: BoxShape.circle,
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.2),
                                      blurRadius: 4,
                                      offset: const Offset(0, 2),
                                    ),
                                  ],
                                ),
                                child: Icon(item.icon,
                                    color: AppTheme.white, size: 28),
                              ),
                            )),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 6.0),
                          child: Container(
                            width: 55,
                            height: 55,
                            decoration: BoxDecoration(
                              color: AppTheme.white.withOpacity(0.3),
                              shape: BoxShape.circle,
                              border:
                                  Border.all(color: AppTheme.white, width: 3),
                            ),
                            child: const Icon(Icons.question_mark,
                                color: AppTheme.white, size: 28),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            // Options
            Expanded(
              flex: 3,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: GridView.builder(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                    childAspectRatio: 1.0,
                  ),
                  itemCount: _options.length,
                  itemBuilder: (context, index) {
                    return GestureDetector(
                      onTap: () => _onOptionSelected(_options[index]),
                      child: Container(
                        decoration: BoxDecoration(
                          color: _options[index].color,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.25),
                              blurRadius: 8,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Icon(_options[index].icon,
                            color: AppTheme.white, size: 50),
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

class PatternItem {
  final Color color;
  final IconData icon;

  PatternItem({required this.color, required this.icon});

  String get key => '${color.value}_${icon.codePoint}';
}
