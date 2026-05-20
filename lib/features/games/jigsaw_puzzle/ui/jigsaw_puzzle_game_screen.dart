import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/services/storage_service.dart';
import '../../../../core/models/game_progress.dart';
import '../../../results/ui/result_screen.dart';
import '../../widgets/game_header.dart';

class JigsawPuzzleGameScreen extends StatefulWidget {
  final int level;
  final StorageService storageService;
  final String? worldId;

  const JigsawPuzzleGameScreen({
    super.key,
    required this.level,
    required this.storageService,
    this.worldId,
  });

  @override
  State<JigsawPuzzleGameScreen> createState() => _JigsawPuzzleGameScreenState();
}

class _JigsawPuzzleGameScreenState extends State<JigsawPuzzleGameScreen> {
  late int _gridSize; // 2x2, 3x3, 4x4
  late List<PuzzlePiece> _pieces;
  List<PuzzlePiece> _placedPieces = [];
  int _score = 0;
  int _timeElapsed = 0;
  bool _isGameActive = true;
  bool _isComplete = false;
  Timer? _timer;
  PuzzlePiece? _selectedPiece;
  late DateTime _gameStartTime;

  @override
  void initState() {
    super.initState();
    _gameStartTime = DateTime.now();
    // Determine grid size based on level
    if (widget.level <= 2) {
      _gridSize = 2; // 4 pieces
    } else if (widget.level <= 5) {
      _gridSize = 3; // 9 pieces
    } else if (widget.level <= 8) {
      _gridSize = 4; // 16 pieces
    } else {
      _gridSize = 4; // 16 pieces (max)
    }
    _initializePuzzle();
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
          _timeElapsed++;
        });
      }
    });
  }

  void _initializePuzzle() {
    final totalPieces = _gridSize * _gridSize;
    _pieces = [];
    _placedPieces = [];

    // Create pieces with positions
    for (int i = 0; i < totalPieces; i++) {
      final row = i ~/ _gridSize;
      final col = i % _gridSize;
      _pieces.add(PuzzlePiece(
        id: i,
        correctRow: row,
        correctCol: col,
        color: _getColorForPiece(i),
      ));
    }

    // Shuffle pieces
    _pieces.shuffle(Random());
  }

  Color _getColorForPiece(int index) {
    final colors = [
      Colors.red,
      Colors.blue,
      Colors.green,
      Colors.yellow,
      Colors.orange,
      Colors.purple,
      Colors.pink,
      Colors.teal,
      Colors.cyan,
      Colors.amber,
      Colors.indigo,
      Colors.brown,
      Colors.lime,
      Colors.deepOrange,
      Colors.deepPurple,
      Colors.lightBlue,
    ];
    return colors[index % colors.length];
  }

  void _onPieceTap(PuzzlePiece piece) {
    if (!_isGameActive || _isComplete) return;

    setState(() {
      if (_selectedPiece == piece) {
        _selectedPiece = null;
      } else {
        _selectedPiece = piece;
      }
    });
  }

  void _onGridCellTap(int row, int col) {
    if (!_isGameActive || _isComplete) return;

    // If no piece is selected, check if we can select a piece from this cell
    if (_selectedPiece == null) {
      final pieceAtCell = _placedPieces.firstWhere(
        (p) => p.currentRow == row && p.currentCol == col,
        orElse: () => PuzzlePiece(
            id: -1, correctRow: -1, correctCol: -1, color: Colors.transparent),
      );
      if (pieceAtCell.id != -1) {
        // Remove piece from grid and add back to available pieces
        setState(() {
          _placedPieces.remove(pieceAtCell);
          pieceAtCell.currentRow = -1;
          pieceAtCell.currentCol = -1;
          _pieces.add(pieceAtCell);
        });
      }
      return;
    }

    // Check if cell is already occupied
    if (_placedPieces.any((p) => p.currentRow == row && p.currentCol == col)) {
      // If cell is occupied, swap pieces or remove the existing one
      final existingPiece = _placedPieces.firstWhere(
        (p) => p.currentRow == row && p.currentCol == col,
      );
      setState(() {
        // Remove existing piece and add it back to available
        _placedPieces.remove(existingPiece);
        existingPiece.currentRow = -1;
        existingPiece.currentCol = -1;
        _pieces.add(existingPiece);

        // Place selected piece
        _selectedPiece!.currentRow = row;
        _selectedPiece!.currentCol = col;
        _pieces.remove(_selectedPiece!);
        _placedPieces.add(_selectedPiece!);

        // Check if piece is in correct position
        final isCorrect =
            _selectedPiece!.currentRow == _selectedPiece!.correctRow &&
                _selectedPiece!.currentCol == _selectedPiece!.correctCol;

        if (isCorrect) {
          _score += 20; // Bonus for correct placement
        } else {
          _score += 5; // Small points for placement
        }

        _selectedPiece = null;
      });
      _checkCompletion();
      return;
    }

    // Place the selected piece in the empty cell
    setState(() {
      _selectedPiece!.currentRow = row;
      _selectedPiece!.currentCol = col;
      _pieces.remove(_selectedPiece!);
      _placedPieces.add(_selectedPiece!);

      // Check if piece is in correct position
      final isCorrect =
          _selectedPiece!.currentRow == _selectedPiece!.correctRow &&
              _selectedPiece!.currentCol == _selectedPiece!.correctCol;

      if (isCorrect) {
        _score += 20; // Bonus for correct placement
      } else {
        _score += 5; // Small points for placement
      }

      _selectedPiece = null;
    });

    _checkCompletion();
  }

  void _checkCompletion() {
    // Check if all pieces are placed
    if (_placedPieces.length == _gridSize * _gridSize) {
      bool allCorrect = true;
      for (final piece in _placedPieces) {
        if (piece.currentRow != piece.correctRow ||
            piece.currentCol != piece.correctCol) {
          allCorrect = false;
          break;
        }
      }

      if (allCorrect && _isGameActive && !_isComplete) {
        // Add bonus points for completing
        setState(() {
          _score += 50;
        });
        _gameComplete();
      }
    }
  }

  void _gameComplete() {
    _isGameActive = false;
    _isComplete = true;
    _timer?.cancel();

    int stars = 3;
    int maxTime = _gridSize * _gridSize * 5; // 5 seconds per piece
    if (_timeElapsed > maxTime * 0.8) stars = 2;
    if (_timeElapsed > maxTime * 1.2) stars = 1;

    int points = _score + ((maxTime - _timeElapsed) * 2);
    if (points < 10) points = 10;

    final progress =
        widget.storageService.getOrCreateGameProgress('jigsaw_puzzle');
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
              gameId: 'jigsaw_puzzle',
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
    final cellSize = (MediaQuery.of(context).size.width - 80) / _gridSize;

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
                  '${_timeElapsed ~/ 60}:${(_timeElapsed % 60).toString().padLeft(2, '0')}',
              onExit: () => Navigator.pop(context),
            ),
            // Puzzle Grid
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    // Grid
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Column(
                        children: List.generate(_gridSize, (row) {
                          return Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: List.generate(_gridSize, (col) {
                              final placedPiecesAtCell = _placedPieces
                                  .where(
                                    (p) =>
                                        p.currentRow == row &&
                                        p.currentCol == col,
                                  )
                                  .toList();
                              final placedPiece = placedPiecesAtCell.isEmpty
                                  ? null
                                  : placedPiecesAtCell.first;

                              // Calculate which piece ID should be in this cell (for hint)
                              // The correct piece ID for cell (row, col) is: row * _gridSize + col
                              final correctPieceId = row * _gridSize + col;
                              // Check if this piece is still available (not placed)
                              final isPieceAvailable =
                                  _pieces.any((p) => p.id == correctPieceId);
                              final showHint =
                                  placedPiece == null && isPieceAvailable;

                              return GestureDetector(
                                onTap: () => _onGridCellTap(row, col),
                                child: Container(
                                  width: cellSize,
                                  height: cellSize,
                                  margin: const EdgeInsets.all(2),
                                  decoration: BoxDecoration(
                                    color: placedPiece != null
                                        ? placedPiece.color
                                        : Colors.grey[200],
                                    borderRadius: BorderRadius.circular(8),
                                    border: Border.all(
                                      color: placedPiece != null
                                          ? (placedPiece.currentRow ==
                                                      placedPiece.correctRow &&
                                                  placedPiece.currentCol ==
                                                      placedPiece.correctCol
                                              ? Colors.green
                                              : Colors.orange)
                                          : (showHint
                                              ? Colors.blue.withOpacity(0.5)
                                              : Colors.grey[400]!),
                                      width: placedPiece != null
                                          ? 3
                                          : (showHint ? 2 : 2),
                                    ),
                                  ),
                                  child: placedPiece != null
                                      ? Center(
                                          child: Column(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            children: [
                                              Text(
                                                '${placedPiece.id + 1}',
                                                style: const TextStyle(
                                                  fontSize: 20,
                                                  fontWeight: FontWeight.bold,
                                                  color: Colors.white,
                                                ),
                                              ),
                                              if (placedPiece.currentRow ==
                                                      placedPiece.correctRow &&
                                                  placedPiece.currentCol ==
                                                      placedPiece.correctCol)
                                                const Icon(
                                                  Icons.check,
                                                  color: Colors.white,
                                                  size: 16,
                                                ),
                                            ],
                                          ),
                                        )
                                      : showHint
                                          ? Center(
                                              child: Text(
                                                '${correctPieceId + 1}',
                                                style: TextStyle(
                                                  fontSize: 16,
                                                  fontWeight: FontWeight.bold,
                                                  color: Colors.blue
                                                      .withOpacity(0.5),
                                                ),
                                              ),
                                            )
                                          : null,
                                ),
                              );
                            }),
                          );
                        }),
                      ),
                    ),

                    const SizedBox(height: 24),

                    // Available pieces
                    Text(
                      'القطع المتاحة (اضغط لاختيار، ثم اضغط على الخلية لوضعها)',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 12),
                    if (_pieces.isEmpty)
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.green.withOpacity(0.3),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Text(
                          'جميع القطع موضوعة! تحقق من أن كل قطعة في مكانها الصحيح.',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      )
                    else
                      Wrap(
                        spacing: 12,
                        runSpacing: 12,
                        alignment: WrapAlignment.center,
                        children: _pieces.map((piece) {
                          final isSelected = _selectedPiece == piece;
                          return GestureDetector(
                            onTap: () => _onPieceTap(piece),
                            child: Container(
                              width: 60,
                              height: 60,
                              decoration: BoxDecoration(
                                color: piece.color,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color:
                                      isSelected ? Colors.yellow : Colors.white,
                                  width: isSelected ? 3 : 1,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.2),
                                    blurRadius: 4,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: Center(
                                child: Text(
                                  '${piece.id + 1}',
                                  style: const TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ),
                          );
                        }).toList(),
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

class PuzzlePiece {
  final int id;
  final int correctRow;
  final int correctCol;
  final Color color;
  int currentRow = -1;
  int currentCol = -1;

  PuzzlePiece({
    required this.id,
    required this.correctRow,
    required this.correctCol,
    required this.color,
  });
}
