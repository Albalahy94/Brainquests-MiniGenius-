import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/services/storage_service.dart';
import '../../../../core/models/game_progress.dart';
import '../../../results/ui/result_screen.dart';
import '../../widgets/game_header.dart';

class ShapeMatcherGameScreen extends StatefulWidget {
  final int level;
  final StorageService storageService;
  final String? worldId;

  const ShapeMatcherGameScreen({
    super.key,
    required this.level,
    required this.storageService,
    this.worldId,
  });

  @override
  State<ShapeMatcherGameScreen> createState() => _ShapeMatcherGameScreenState();
}

class _ShapeMatcherGameScreenState extends State<ShapeMatcherGameScreen> {
  late List<ShapeOption> _options;
  late ShapeData _targetShape;
  int _score = 0;
  int _round = 0;
  int _correctAnswers = 0;
  late int _totalRounds;
  Timer? _timer;
  int _timeRemaining = 45;
  late DateTime _gameStartTime;

  @override
  void initState() {
    super.initState();
    _gameStartTime = DateTime.now();
    _totalRounds = 5 + (widget.level ~/ 2); // 5-10 rounds
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

    // More shapes for higher levels
    List<ShapeType> availableShapes = [
      ShapeType.circle,
      ShapeType.square,
      ShapeType.triangle,
      ShapeType.star
    ];

    if (widget.level >= 5) {
      availableShapes.addAll([ShapeType.pentagon, ShapeType.heart]);
    }
    if (widget.level >= 8) {
      availableShapes.add(ShapeType.hexagon);
    }

    List<Color> availableColors = [
      AppTheme.primaryBlue,
      AppTheme.yellowAccent,
      AppTheme.mintGreen,
      Colors.purple,
      Colors.orange,
      Colors.pink,
    ];

    _targetShape = ShapeData(
      type: availableShapes[random.nextInt(availableShapes.length)],
      color: availableColors[random.nextInt(availableColors.length)],
    );

    // Generate unique wrong options
    Set<String> usedCombinations = {_targetShape.key};
    List<ShapeOption> wrongOptions = [];

    // Strategy 1: Same color, different shape
    while (wrongOptions.length < 1) {
      final wrongShape =
          availableShapes[random.nextInt(availableShapes.length)];
      final candidate = ShapeData(type: wrongShape, color: _targetShape.color);
      if (!usedCombinations.contains(candidate.key)) {
        wrongOptions.add(ShapeOption(shape: candidate, isCorrect: false));
        usedCombinations.add(candidate.key);
      }
    }

    // Strategy 2: Same shape, different color
    while (wrongOptions.length < 2) {
      final wrongColor =
          availableColors[random.nextInt(availableColors.length)];
      final candidate = ShapeData(type: _targetShape.type, color: wrongColor);
      if (!usedCombinations.contains(candidate.key)) {
        wrongOptions.add(ShapeOption(shape: candidate, isCorrect: false));
        usedCombinations.add(candidate.key);
      }
    }

    // Strategy 3: Different shape AND color
    while (wrongOptions.length < 3) {
      final wrongShape =
          availableShapes[random.nextInt(availableShapes.length)];
      final wrongColor =
          availableColors[random.nextInt(availableColors.length)];
      final candidate = ShapeData(type: wrongShape, color: wrongColor);
      if (!usedCombinations.contains(candidate.key)) {
        wrongOptions.add(ShapeOption(shape: candidate, isCorrect: false));
        usedCombinations.add(candidate.key);
      }
    }

    _options = [
      ShapeOption(shape: _targetShape, isCorrect: true),
      ...wrongOptions,
    ];
    _options.shuffle(random);
  }

  void _onShapeSelected(ShapeOption option) {
    if (option.isCorrect) {
      setState(() {
        _score += 15 * widget.level;
        _correctAnswers++;
        _round++;
      });

      if (_round >= _totalRounds) {
        _gameComplete();
      } else {
        Future.delayed(const Duration(milliseconds: 400), () {
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
        if (_score >= 10) _score -= 10;
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
        widget.storageService.getOrCreateGameProgress('shape_matcher');
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
            gameId: 'shape_matcher',
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
            // Target shape
            Expanded(
              flex: 2,
              child: Center(
                child: Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'طابق هذا الشكل:', // Translated "Match this shape:"
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              color: AppTheme.white,
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                      const SizedBox(height: 20),
                      _buildShape(_targetShape, size: 100),
                    ],
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
                      onTap: () => _onShapeSelected(_options[index]),
                      child: Container(
                        decoration: BoxDecoration(
                          color: AppTheme.white,
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.15),
                              blurRadius: 8,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Center(
                          child: _buildShape(_options[index].shape, size: 60),
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

  Widget _buildShape(ShapeData shape, {required double size}) {
    Widget shapeWidget;
    switch (shape.type) {
      case ShapeType.circle:
        shapeWidget = Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            color: shape.color,
            shape: BoxShape.circle,
          ),
        );
        break;
      case ShapeType.square:
        shapeWidget = Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            color: shape.color,
            borderRadius: BorderRadius.circular(8),
          ),
        );
        break;
      case ShapeType.triangle:
        shapeWidget = CustomPaint(
          size: Size(size, size),
          painter: TrianglePainter(shape.color),
        );
        break;
      case ShapeType.star:
        shapeWidget = Icon(
          Icons.star,
          size: size,
          color: shape.color,
        );
        break;
      case ShapeType.pentagon:
        shapeWidget = CustomPaint(
          size: Size(size, size),
          painter: PentagonPainter(shape.color),
        );
        break;
      case ShapeType.hexagon:
        shapeWidget = CustomPaint(
          size: Size(size, size),
          painter: HexagonPainter(shape.color),
        );
        break;
      case ShapeType.heart:
        shapeWidget = Icon(
          Icons.favorite,
          size: size,
          color: shape.color,
        );
        break;
    }
    return shapeWidget;
  }
}

class ShapeData {
  final ShapeType type;
  final Color color;

  ShapeData({required this.type, required this.color});

  String get key => '${type.name}_${color.value}';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ShapeData &&
          runtimeType == other.runtimeType &&
          type == other.type &&
          color == other.color;

  @override
  int get hashCode => type.hashCode ^ color.hashCode;
}

class ShapeOption {
  final ShapeData shape;
  final bool isCorrect;

  ShapeOption({required this.shape, required this.isCorrect});
}

enum ShapeType { circle, square, triangle, star, pentagon, hexagon, heart }

class TrianglePainter extends CustomPainter {
  final Color color;

  TrianglePainter(this.color);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = color;
    final path = Path()
      ..moveTo(size.width / 2, 0)
      ..lineTo(0, size.height)
      ..lineTo(size.width, size.height)
      ..close();
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class PentagonPainter extends CustomPainter {
  final Color color;

  PentagonPainter(this.color);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = color;
    final path = Path();
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;

    for (int i = 0; i < 5; i++) {
      final angle = (i * 2 * pi / 5) - (pi / 2);
      final x = center.dx + radius * cos(angle);
      final y = center.dy + radius * sin(angle);
      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }
    path.close();
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class HexagonPainter extends CustomPainter {
  final Color color;

  HexagonPainter(this.color);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = color;
    final path = Path();
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;

    for (int i = 0; i < 6; i++) {
      final angle = (i * 2 * pi / 6) - (pi / 2);
      final x = center.dx + radius * cos(angle);
      final y = center.dy + radius * sin(angle);
      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }
    path.close();
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
