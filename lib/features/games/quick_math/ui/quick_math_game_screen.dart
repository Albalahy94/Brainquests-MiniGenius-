import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/services/storage_service.dart';
import '../../../../core/models/game_progress.dart';
import '../../../results/ui/result_screen.dart';
import '../../widgets/game_header.dart';

class QuickMathGameScreen extends StatefulWidget {
  final int level;
  final StorageService storageService;
  final String? worldId;

  const QuickMathGameScreen({
    super.key,
    required this.level,
    required this.storageService,
    this.worldId,
  });

  @override
  State<QuickMathGameScreen> createState() => _QuickMathGameScreenState();
}

class _QuickMathGameScreenState extends State<QuickMathGameScreen> {
  late MathProblem _currentProblem;
  int _score = 0;
  int _round = 0;
  int _correctAnswers = 0;
  late int _totalRounds;
  int _timeRemaining = 60; // Increased base time
  bool _isGameActive = true;
  Timer? _timer;
  late DateTime _gameStartTime;

  @override
  void initState() {
    super.initState();
    _gameStartTime = DateTime.now();
    _totalRounds = 5 + (widget.level ~/ 2); // 5 to 10 rounds
    _generateProblem();
    _startTimer();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!_isGameActive) {
        timer.cancel();
        return;
      }
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

  void _generateProblem() {
    final random = Random();
    int num1 = 0;
    int num2 = 0;
    String operation = '+';
    int correctAnswer = 0;

    // Difficulty scaling
    // Level 1-3: Add/Sub, Max 20
    // Level 4-6: Add/Sub/Mul, Max 50
    // Level 7-9: All ops, Max 100
    // Level 10+: All ops, Max 200, harder Div

    int maxNum = 20;
    List<String> allowedOps = ['+', '-'];

    if (widget.level >= 4) {
      maxNum = 50;
      allowedOps.add('*');
    }
    if (widget.level >= 7) {
      maxNum = 100;
      allowedOps.add('/');
    }
    if (widget.level >= 10) {
      maxNum = 200;
    }

    operation = allowedOps[random.nextInt(allowedOps.length)];

    switch (operation) {
      case '+':
        num1 = random.nextInt(maxNum) + 1;
        num2 = random.nextInt(maxNum) + 1;
        correctAnswer = num1 + num2;
        break;
      case '-':
        num1 = random.nextInt(maxNum) + 1;
        num2 = random.nextInt(num1) + 1; // Ensure positive result
        correctAnswer = num1 - num2;
        break;
      case '*':
        // Keep multiplication result reasonable
        int limit = widget.level >= 7 ? 20 : 10;
        num1 = random.nextInt(limit) + 1;
        num2 = random.nextInt(10) + 1;
        correctAnswer = num1 * num2;
        break;
      case '/':
        // Create integer division
        num2 = random.nextInt(10) + 2; // Avoid divide by 1
        correctAnswer = random.nextInt(10) + 1;
        num1 = num2 * correctAnswer;
        break;
    }

    // Generate unique options
    final Set<int> options = {correctAnswer};
    while (options.length < 4) {
      int offset = random.nextInt(10) + 1;
      bool add = random.nextBool();
      int wrong = add ? correctAnswer + offset : correctAnswer - offset;
      if (wrong >= 0) {
        // No negative options
        options.add(wrong);
      }
    }

    final optionList = options.toList()..shuffle(random);

    _currentProblem = MathProblem(
      num1: num1,
      num2: num2,
      operation: operation,
      correctAnswer: correctAnswer,
      options: optionList,
    );
  }

  void _onAnswerSelected(int answer) {
    if (!_isGameActive) return;

    if (answer == _currentProblem.correctAnswer) {
      setState(() {
        _score += 10 * widget.level;
        _correctAnswers++;
        _round++;
      });

      if (_round >= _totalRounds) {
        _gameComplete();
      } else {
        Future.delayed(const Duration(milliseconds: 300), () {
          if (mounted && _isGameActive) {
            setState(() {
              _generateProblem();
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
      // Penalty for wrong answer?
      setState(() {
        if (_score >= 5) _score -= 5;
      });
    }
  }

  void _gameComplete() {
    _isGameActive = false;
    _timer?.cancel();

    int stars = 3;
    double accuracy = _round > 0 ? _correctAnswers / _round : 0;
    if (_round < _totalRounds) {
      // Did not finish all rounds (timeout)
      accuracy = _correctAnswers / _totalRounds;
    }

    if (accuracy < 0.8) stars = 2;
    if (accuracy < 0.5) stars = 1;

    int points = _score + (_timeRemaining * 1);

    final progress =
        widget.storageService.getOrCreateGameProgress('quick_math');
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
      if (!mounted) return;
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => ResultScreen(
            stars: stars,
            points: points,
            level: widget.level,
            gameId: 'quick_math',
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
            // Problem display
            Expanded(
              flex: 2,
              child: Center(
                child: Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        '${_currentProblem.num1} ${_currentProblem.operationDisplay} ${_currentProblem.num2}',
                        style:
                            Theme.of(context).textTheme.displayLarge?.copyWith(
                                  color: AppTheme.white,
                                  fontWeight: FontWeight.bold,
                                ),
                      ),
                      const SizedBox(height: 10),
                      const Icon(Icons.help_outline,
                          color: AppTheme.yellowAccent, size: 40),
                    ],
                  ),
                ),
              ),
            ),
            // Answer options
            Expanded(
              flex: 3,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: GridView.builder(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                    childAspectRatio: 1.8,
                  ),
                  itemCount: _currentProblem.options.length,
                  itemBuilder: (context, index) {
                    final answer = _currentProblem.options[index];
                    return ElevatedButton(
                      onPressed: () => _onAnswerSelected(answer),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.white,
                        foregroundColor: AppTheme.primaryBlue,
                        padding: const EdgeInsets.all(8),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        elevation: 4,
                      ),
                      child: Text(
                        '$answer',
                        style: Theme.of(context)
                            .textTheme
                            .headlineMedium
                            ?.copyWith(
                              color: AppTheme.primaryBlue,
                              fontWeight: FontWeight.bold,
                            ),
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

class MathProblem {
  final int num1;
  final int num2;
  final String operation;
  final int correctAnswer;
  final List<int> options;

  MathProblem({
    required this.num1,
    required this.num2,
    required this.operation,
    required this.correctAnswer,
    required this.options,
  });

  String get operationDisplay {
    switch (operation) {
      case '+':
        return '+';
      case '-':
        return '-';
      case '*':
        return '×';
      case '/':
        return '÷';
      default:
        return operation;
    }
  }
}
