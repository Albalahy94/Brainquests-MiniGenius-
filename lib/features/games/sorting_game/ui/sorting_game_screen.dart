import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/services/storage_service.dart';
import '../../../../core/models/game_progress.dart';
import '../../../results/ui/result_screen.dart';
import '../../widgets/game_header.dart';

class SortingGameScreen extends StatefulWidget {
  final int level;
  final StorageService storageService;
  final String? worldId;

  const SortingGameScreen({
    super.key,
    required this.level,
    required this.storageService,
    this.worldId,
  });

  @override
  State<SortingGameScreen> createState() => _SortingGameScreenState();
}

class _SortingGameScreenState extends State<SortingGameScreen> {
  // Items to sort
  final List<SortItem> _items = [];
  final List<SortItem> _sortedItems = [];
  SortCategory _currentCategory = SortCategory.color;
  int _score = 0;
  int _round = 0;
  int _correctAnswers = 0;
  late int _totalRounds;
  int _timeRemaining = 60;
  bool _isGameActive = true;
  Timer? _timer;
  late DateTime _gameStartTime;

  @override
  void initState() {
    super.initState();
    _gameStartTime = DateTime.now();
    _totalRounds = 5 + (widget.level ~/ 2);
    _timeRemaining = 60 - (widget.level * 2);
    _generateRound();
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

  void _generateRound() {
    final random = Random();
    final categories = [
      SortCategory.color,
      SortCategory.size,
      SortCategory.shape
    ];
    _currentCategory = categories[random.nextInt(categories.length)];

    _items.clear();
    _sortedItems.clear();

    final itemCount = 6 + (widget.level ~/ 2);

    if (_currentCategory == SortCategory.color) {
      final colors = [
        Colors.red,
        Colors.blue,
        Colors.green,
        Colors.yellow,
        Colors.orange,
        Colors.purple
      ];
      for (int i = 0; i < itemCount; i++) {
        final color = colors[random.nextInt(colors.length)];
        _items.add(SortItem(
          color: color,
          size: ItemSize.medium,
          shape: ItemShape.circle,
        ));
      }
    } else if (_currentCategory == SortCategory.size) {
      final sizes = [ItemSize.small, ItemSize.medium, ItemSize.large];
      for (int i = 0; i < itemCount; i++) {
        final size = sizes[random.nextInt(sizes.length)];
        _items.add(SortItem(
          color: Colors.blue,
          size: size,
          shape: ItemShape.circle,
        ));
      }
    } else {
      final shapes = [ItemShape.circle, ItemShape.square, ItemShape.triangle];
      for (int i = 0; i < itemCount; i++) {
        final shape = shapes[random.nextInt(shapes.length)];
        _items.add(SortItem(
          color: Colors.blue,
          size: ItemSize.medium,
          shape: shape,
        ));
      }
    }

    _items.shuffle(random);
  }

  void _onItemTap(SortItem item) {
    if (!_isGameActive) return;

    setState(() {
      _items.remove(item);
      _sortedItems.add(item);
    });

    _checkSort();
  }

  void _onSortedItemTap(SortItem item) {
    if (!_isGameActive) return;

    setState(() {
      _sortedItems.remove(item);
      _items.add(item);
    });
  }

  void _checkSort() {
    // Check if all items are sorted
    if (_items.isNotEmpty) return; // Still have items to sort

    if (_sortedItems.isEmpty) return; // No items sorted yet

    // Check if items are grouped correctly by category
    // All items of the same category should be grouped together
    bool isCorrect = true;

    if (_currentCategory == SortCategory.color) {
      Set<int> seenColors = {};
      int? currentColorValue;
      for (var item in _sortedItems) {
        if (currentColorValue == null) {
          currentColorValue = item.color.value;
          seenColors.add(item.color.value);
        } else if (item.color.value != currentColorValue) {
          if (seenColors.contains(item.color.value)) {
            isCorrect = false;
            break;
          }
          currentColorValue = item.color.value;
          seenColors.add(item.color.value);
        }
      }
    } else if (_currentCategory == SortCategory.size) {
      Set<ItemSize> seenSizes = {};
      ItemSize? currentSize;
      for (var item in _sortedItems) {
        if (currentSize == null) {
          currentSize = item.size;
          seenSizes.add(item.size);
        } else if (item.size != currentSize) {
          if (seenSizes.contains(item.size)) {
            isCorrect = false;
            break;
          }
          currentSize = item.size;
          seenSizes.add(item.size);
        }
      }
    } else {
      Set<ItemShape> seenShapes = {};
      ItemShape? currentShape;
      for (var item in _sortedItems) {
        if (currentShape == null) {
          currentShape = item.shape;
          seenShapes.add(item.shape);
        } else if (item.shape != currentShape) {
          if (seenShapes.contains(item.shape)) {
            isCorrect = false;
            break;
          }
          currentShape = item.shape;
          seenShapes.add(item.shape);
        }
      }
    }

    if (isCorrect) {
      // All sorted correctly!
      setState(() {
        _score += 30 * widget.level;
        _correctAnswers++;
        _round++;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('ممتاز!', style: TextStyle(color: Colors.white)),
          backgroundColor: Colors.green,
          duration: Duration(milliseconds: 800),
        ),
      );

      if (_round >= _totalRounds) {
        _gameComplete();
      } else {
        Future.delayed(const Duration(milliseconds: 1000), () {
          if (mounted && _isGameActive) {
            setState(() {
              _generateRound();
            });
          }
        });
      }
    }
  }

  void _gameComplete() {
    _isGameActive = false;
    _timer?.cancel();

    int stars = 3;
    double accuracy = _round > 0 ? _correctAnswers / _round : 0;
    if (_round < _totalRounds) {
      accuracy = _correctAnswers / _totalRounds;
    }

    if (accuracy < 0.8) stars = 2;
    if (accuracy < 0.5) stars = 1;

    int points = _score + (_timeRemaining * 2);

    final progress =
        widget.storageService.getOrCreateGameProgress('sorting_game');
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
      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => ResultScreen(
              stars: stars,
              points: points,
              level: widget.level,
              gameId: 'sorting_game',
              storageService: widget.storageService,
              gameStartTime: _gameStartTime,
              worldId: widget.worldId,
            ),
          ),
        );
      }
    });
  }

  String _getCategoryName() {
    switch (_currentCategory) {
      case SortCategory.color:
        return 'اللون';
      case SortCategory.size:
        return 'الحجم';
      case SortCategory.shape:
        return 'الشكل';
    }
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
            // Instructions
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                'رتب حسب: ${_getCategoryName()}',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
            ),

            // Sorted items area
            if (_sortedItems.isNotEmpty)
              Container(
                height: 100,
                margin:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: _sortedItems.map((item) {
                      return GestureDetector(
                        onTap: () => _onSortedItemTap(item),
                        child: Container(
                          margin: const EdgeInsets.symmetric(horizontal: 4),
                          child: _buildItemWidget(item, size: 60),
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ),

            // Items to sort
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Wrap(
                  spacing: 16,
                  runSpacing: 16,
                  alignment: WrapAlignment.center,
                  children: _items.map((item) {
                    return GestureDetector(
                      onTap: () => _onItemTap(item),
                      child: _buildItemWidget(item, size: 80),
                    );
                  }).toList(),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildItemWidget(SortItem item, {required double size}) {
    Widget shape;
    switch (item.shape) {
      case ItemShape.circle:
        shape = Container(
          width: size *
              (item.size == ItemSize.small
                  ? 0.6
                  : item.size == ItemSize.medium
                      ? 0.8
                      : 1.0),
          height: size *
              (item.size == ItemSize.small
                  ? 0.6
                  : item.size == ItemSize.medium
                      ? 0.8
                      : 1.0),
          decoration: BoxDecoration(
            color: item.color,
            shape: BoxShape.circle,
          ),
        );
        break;
      case ItemShape.square:
        shape = Container(
          width: size *
              (item.size == ItemSize.small
                  ? 0.6
                  : item.size == ItemSize.medium
                      ? 0.8
                      : 1.0),
          height: size *
              (item.size == ItemSize.small
                  ? 0.6
                  : item.size == ItemSize.medium
                      ? 0.8
                      : 1.0),
          decoration: BoxDecoration(
            color: item.color,
            borderRadius: BorderRadius.circular(8),
          ),
        );
        break;
      case ItemShape.triangle:
        shape = CustomPaint(
          size: Size(size, size),
          painter: TrianglePainter(item.color),
        );
        break;
    }

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Center(child: shape),
    );
  }
}

enum SortCategory { color, size, shape }

enum ItemSize { small, medium, large }

enum ItemShape { circle, square, triangle }

class SortItem {
  final Color color;
  final ItemSize size;
  final ItemShape shape;

  SortItem({
    required this.color,
    required this.size,
    required this.shape,
  });
}

class TrianglePainter extends CustomPainter {
  final Color color;

  TrianglePainter(this.color);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = color;
    final path = Path()
      ..moveTo(size.width / 2, 0)
      ..lineTo(size.width, size.height)
      ..lineTo(0, size.height)
      ..close();
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
