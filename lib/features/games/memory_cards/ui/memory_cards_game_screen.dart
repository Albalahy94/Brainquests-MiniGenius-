import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/services/storage_service.dart';
import '../../../../core/models/game_progress.dart';
import '../widgets/memory_card.dart';
import '../../../results/ui/result_screen.dart';
import '../../widgets/game_header.dart';

class MemoryCardsGameScreen extends StatefulWidget {
  final int level;
  final StorageService storageService;
  final String? worldId; // Optional: if game was played from a world

  const MemoryCardsGameScreen({
    super.key,
    required this.level,
    required this.storageService,
    this.worldId,
  });

  @override
  State<MemoryCardsGameScreen> createState() => _MemoryCardsGameScreenState();
}

class _MemoryCardsGameScreenState extends State<MemoryCardsGameScreen> {
  late List<MemoryCardData> _cards;
  MemoryCardData? _firstCard;
  MemoryCardData? _secondCard;
  int _matches = 0;
  int _moves = 0;
  bool _isProcessing = false;
  late int _totalPairs;
  Timer? _timer;
  int _timeElapsed = 0;
  late DateTime _gameStartTime;

  @override
  void initState() {
    super.initState();
    _gameStartTime = DateTime.now();
    _startTimer();
    _initializeGame();
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
          _timeElapsed++;
        });
      }
    });
  }

  void _initializeGame() {
    // Determine grid size based on level
    // ensuring always even number of cards
    int totalCards;
    if (widget.level <= 2) {
      totalCards = 6; // 3 pairs
    } else if (widget.level <= 4) {
      totalCards = 8; // 4 pairs
    } else if (widget.level <= 6) {
      totalCards = 12; // 6 pairs
    } else if (widget.level <= 8) {
      totalCards = 16; // 8 pairs
    } else if (widget.level <= 10) {
      totalCards = 20; // 10 pairs
    } else {
      totalCards = 24; // 12 pairs (Harder level)
    }

    _totalPairs = totalCards ~/ 2;
    final icons = _getIconsForLevel();

    // Ensure we don't exceed available icons
    final pairsCount = min(_totalPairs, icons.length);
    final cardValues = icons.take(pairsCount).toList();

    final allCards = [...cardValues, ...cardValues];
    allCards.shuffle(Random());

    _cards = allCards.asMap().entries.map((entry) {
      return MemoryCardData(
        id: entry.key,
        value: entry.value,
        isFlipped: false,
        isMatched: false,
      );
    }).toList();
  }

  List<IconData> _getIconsForLevel() {
    return [
      Icons.star,
      Icons.favorite,
      Icons.thumb_up,
      Icons.emoji_emotions,
      Icons.cake,
      Icons.icecream,
      Icons.local_pizza,
      Icons.airplanemode_active,
      Icons.directions_car,
      Icons.pets,
      Icons.sports_soccer,
      Icons.music_note,
      Icons.lightbulb,
      Icons.diamond,
      Icons.anchor,
      Icons.bolt,
    ];
  }

  void _onCardTap(MemoryCardData card) {
    if (_isProcessing || card.isFlipped || card.isMatched) return;

    setState(() {
      card.isFlipped = true;
      if (_firstCard == null) {
        _firstCard = card;
      } else if (_secondCard == null) {
        _secondCard = card;
        _moves++;
        _checkMatch();
      }
    });
  }

  void _checkMatch() {
    if (_firstCard?.value == _secondCard?.value) {
      // Match found
      setState(() {
        _firstCard?.isMatched = true;
        _secondCard?.isMatched = true;
        _matches++;
        _firstCard = null;
        _secondCard = null;
      });

      if (_matches == _totalPairs) {
        _gameComplete();
      }
    } else {
      // No match
      _isProcessing = true;
      Future.delayed(const Duration(milliseconds: 1000), () {
        if (mounted) {
          setState(() {
            _firstCard?.isFlipped = false;
            _secondCard?.isFlipped = false;
            _firstCard = null;
            _secondCard = null;
            _isProcessing = false;
          });
        }
      });
    }
  }

  void _gameComplete() {
    _timer?.cancel();

    // Calculate stars based on moves and level
    int stars = 3;
    // Base allowance: perfect game is _totalPairs moves.
    // Allow some error margin.
    int maxMoves3Stars = _totalPairs + (_totalPairs ~/ 2);
    int maxMoves2Stars = _totalPairs * 2;

    if (_moves > maxMoves2Stars)
      stars = 1;
    else if (_moves > maxMoves3Stars) stars = 2;

    // Calculate points
    // Base points + speed bonus
    int basePoints = 100 * widget.level;
    int movePenalty = _moves * 5;
    int timeBonus = max(0, (60 - _timeElapsed) * 2); // Bonus if under a minute

    int points = basePoints - movePenalty + timeBonus;
    if (points < 10) points = 10;

    // Save progress
    final progress =
        widget.storageService.getOrCreateGameProgress('memory_cards');
    final levelProgress = LevelProgress(
      levelNumber: widget.level,
      stars: stars,
      points: points,
      isCompleted: true,
      isUnlocked: true,
      completedAt: DateTime.now(),
    );
    progress.updateLevel(widget.level, levelProgress);

    // Check for Achievements
    // Note: In a real app we might inject this, but for now we instantitae or use a provider
    // Since we don't have dependency injection set up in the widget tree easily here without context refactor,
    // we'll update the UserProgress totals here or let the ResultScreen handle it.
    // However, to ensure data consistency, let's update totals here.

    // Update Global User Progress (Stars/Points)
    final userProgress = widget.storageService.getUserProgress();
    // Logic to avoid double counting if replaying needs to be considered,
    // but usually totalStars is a sum of best stars or cumulative.
    // GameProgress handles 'recalculateTotals', so we should trust GameProgress totalStars.

    // Actually, explicit achievement check is best done after saving game progress.

    // Unlock next level (Non-destructive)
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
    } else {
      // Endless/Loop logic if needed
    }

    widget.storageService.saveGameProgress(progress);

    // Update User Progress for Achievements
    // We need to sync the total stars from all games to the UserProgress
    // For now, let's just trigger a simple check in ResultScreen or here.
    // Let's rely on ResultScreen to do the heavy lifting of UI notification,
    // but the data should be correct.

    // Navigate to result screen
    Future.delayed(const Duration(milliseconds: 500), () {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => ResultScreen(
            stars: stars,
            points: points,
            level: widget.level,
            gameId: 'memory_cards',
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
    int crossAxisCount = 3;
    if (_cards.length >= 20) {
      crossAxisCount = 5;
    } else if (_cards.length >= 16) {
      crossAxisCount = 4;
    } else if (_cards.length == 8) {
      crossAxisCount = 4; // 2x4
    }
    // 6 cards -> 3 cols (2 rows)
    // 12 cards -> 3 cols (4 rows) or 4 cols (3 rows) -> 3 is safer for vertical space? 3x4 fits.

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
              score: '$_matches/$_totalPairs',
              timer:
                  '${_timeElapsed ~/ 60}:${(_timeElapsed % 60).toString().padLeft(2, '0')}',
              additionalInfo: 'محاولات: $_moves',
              onExit: () => Navigator.pop(context),
            ),
            // Game grid
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: GridView.builder(
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: crossAxisCount,
                    crossAxisSpacing: 8,
                    mainAxisSpacing: 8,
                    childAspectRatio: 0.85,
                  ),
                  itemCount: _cards.length,
                  itemBuilder: (context, index) {
                    return MemoryCardWidget(
                      card: _cards[index],
                      onTap: () => _onCardTap(_cards[index]),
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

class MemoryCardData {
  final int id;
  final IconData value;
  bool isFlipped;
  bool isMatched;

  MemoryCardData({
    required this.id,
    required this.value,
    this.isFlipped = false,
    this.isMatched = false,
  });
}
