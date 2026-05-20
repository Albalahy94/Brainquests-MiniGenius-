import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/services/storage_service.dart';
import '../../../../core/models/game_progress.dart';
import '../../../results/ui/result_screen.dart';
import '../../widgets/game_header.dart';

class WordPuzzleGameScreen extends StatefulWidget {
  final int level;
  final StorageService storageService;
  final String? worldId;

  const WordPuzzleGameScreen({
    super.key,
    required this.level,
    required this.storageService,
    this.worldId,
  });

  @override
  State<WordPuzzleGameScreen> createState() => _WordPuzzleGameScreenState();
}

class _WordPuzzleGameScreenState extends State<WordPuzzleGameScreen> {
  // Words database (Arabic and English)
  final List<Map<String, dynamic>> _words = [
    {
      'word': 'CAT',
      'wordAr': 'قط',
      'hint': 'حيوان أليف',
      'letters': ['C', 'A', 'T']
    },
    {
      'word': 'DOG',
      'wordAr': 'كلب',
      'hint': 'صديق الإنسان',
      'letters': ['D', 'O', 'G']
    },
    {
      'word': 'SUN',
      'wordAr': 'شمس',
      'hint': 'نجم قريب',
      'letters': ['S', 'U', 'N']
    },
    {
      'word': 'MOON',
      'wordAr': 'قمر',
      'hint': 'في السماء ليلاً',
      'letters': ['M', 'O', 'O', 'N']
    },
    {
      'word': 'STAR',
      'wordAr': 'نجمة',
      'hint': 'تلمع في السماء',
      'letters': ['S', 'T', 'A', 'R']
    },
    {
      'word': 'TREE',
      'wordAr': 'شجرة',
      'hint': 'نبات كبير',
      'letters': ['T', 'R', 'E', 'E']
    },
    {
      'word': 'FISH',
      'wordAr': 'سمكة',
      'hint': 'يعيش في الماء',
      'letters': ['F', 'I', 'S', 'H']
    },
    {
      'word': 'BIRD',
      'wordAr': 'طائر',
      'hint': 'يطير في السماء',
      'letters': ['B', 'I', 'R', 'D']
    },
    {
      'word': 'BOOK',
      'wordAr': 'كتاب',
      'hint': 'نقرأه',
      'letters': ['B', 'O', 'O', 'K']
    },
    {
      'word': 'HOUSE',
      'wordAr': 'بيت',
      'hint': 'مكان السكن',
      'letters': ['H', 'O', 'U', 'S', 'E']
    },
    {
      'word': 'CAR',
      'wordAr': 'سيارة',
      'hint': 'وسيلة نقل',
      'letters': ['C', 'A', 'R']
    },
    {
      'word': 'APPLE',
      'wordAr': 'تفاحة',
      'hint': 'فاكهة حمراء',
      'letters': ['A', 'P', 'P', 'L', 'E']
    },
  ];

  String _currentWord = '';
  String _currentWordAr = '';
  String _currentHint = '';
  List<String> _availableLetters = [];
  List<String> _selectedLetters = [];
  int _score = 0;
  int _round = 0;
  int _correctAnswers = 0;
  late int _totalRounds;
  int _timeRemaining = 60;
  bool _isGameActive = true;
  Timer? _timer;
  bool _showHint = false;
  late DateTime _gameStartTime;

  @override
  void initState() {
    super.initState();
    _gameStartTime = DateTime.now();
    _totalRounds = 5 + (widget.level ~/ 2);
    _timeRemaining = 60 - (widget.level * 2);
    _generateWord();
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

  void _generateWord() {
    final random = Random();
    final wordData = _words[random.nextInt(_words.length)];
    _currentWord = wordData['word'] as String;
    _currentWordAr = wordData['wordAr'] as String;
    _currentHint = wordData['hint'] as String;
    final correctLetters = List<String>.from(wordData['letters'] as List);

    // Add some extra letters to make it harder
    final extraLetters = [
      'A',
      'E',
      'I',
      'O',
      'U',
      'B',
      'C',
      'D',
      'F',
      'G',
      'H',
      'K',
      'L',
      'M',
      'N',
      'P',
      'R',
      'S',
      'T'
    ];
    final shuffled = List<String>.from(correctLetters);
    final extraCount = widget.level <= 3
        ? 2
        : widget.level <= 6
            ? 4
            : 6;
    for (int i = 0; i < extraCount; i++) {
      shuffled.add(extraLetters[random.nextInt(extraLetters.length)]);
    }
    shuffled.shuffle(random);

    setState(() {
      _availableLetters = shuffled;
      _selectedLetters = [];
      _showHint = false;
    });
  }

  void _onLetterTap(String letter) {
    if (!_isGameActive) return;

    setState(() {
      _availableLetters.remove(letter);
      _selectedLetters.add(letter);
    });

    _checkWord();
  }

  void _onSelectedLetterTap(String letter) {
    if (!_isGameActive) return;

    setState(() {
      _selectedLetters.remove(letter);
      _availableLetters.add(letter);
      _availableLetters.sort();
    });
  }

  void _checkWord() {
    final selectedWord = _selectedLetters.join();
    if (selectedWord.length == _currentWord.length) {
      if (selectedWord.toUpperCase() == _currentWord.toUpperCase()) {
        // Correct!
        setState(() {
          _score += 20 * widget.level;
          _correctAnswers++;
          _round++;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('صحيح! $_currentWordAr',
                style: const TextStyle(color: Colors.white)),
            backgroundColor: Colors.green,
            duration: const Duration(milliseconds: 800),
          ),
        );

        if (_round >= _totalRounds) {
          _gameComplete();
        } else {
          Future.delayed(const Duration(milliseconds: 1000), () {
            if (mounted && _isGameActive) {
              setState(() {
                _generateWord();
              });
            }
          });
        }
      } else {
        // Wrong - shake animation could be added
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content:
                Text('حاول مرة أخرى!', style: TextStyle(color: Colors.white)),
            backgroundColor: Colors.redAccent,
            duration: Duration(milliseconds: 500),
          ),
        );
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
        widget.storageService.getOrCreateGameProgress('word_puzzle');
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
              gameId: 'word_puzzle',
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
            // Word to guess
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    // Hint
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Column(
                        children: [
                          Text(
                            _currentWordAr,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 32,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            _currentHint,
                            style: const TextStyle(
                                color: Colors.white70, fontSize: 16),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 24),

                    // Selected letters
                    Container(
                      height: 80,
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: _selectedLetters.map((letter) {
                          return GestureDetector(
                            onTap: () => _onSelectedLetterTap(letter),
                            child: Container(
                              margin: const EdgeInsets.symmetric(horizontal: 4),
                              width: 50,
                              height: 50,
                              decoration: BoxDecoration(
                                color: AppTheme.primaryBlue,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Center(
                                child: Text(
                                  letter,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 24,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ),

                    const SizedBox(height: 24),

                    // Available letters
                    Wrap(
                      spacing: 12,
                      runSpacing: 12,
                      alignment: WrapAlignment.center,
                      children: _availableLetters.map((letter) {
                        return GestureDetector(
                          onTap: () => _onLetterTap(letter),
                          child: Container(
                            width: 60,
                            height: 60,
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
                            child: Center(
                              child: Text(
                                letter,
                                style: TextStyle(
                                  color: AppTheme.primaryBlue,
                                  fontSize: 28,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    ),

                    const SizedBox(height: 24),

                    // Hint button
                    ElevatedButton.icon(
                      onPressed: _showHint
                          ? null
                          : () {
                              setState(() {
                                _showHint = true;
                              });
                            },
                      icon: const Icon(Icons.lightbulb),
                      label: Text(_showHint ? '$_currentWord' : 'تلميح'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.orange,
                        foregroundColor: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
