import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/services/storage_service.dart';
import '../../../../core/models/game_progress.dart';
import '../../../results/ui/result_screen.dart';
import '../../widgets/game_header.dart';
import '../models/puzzle_theme.dart';
import '../widgets/puzzle_board_painter.dart';

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
  late int _gridSize; // 2x2, 3x3, 4x4, 5x5
  late List<PuzzlePiece> _pieces;
  List<PuzzlePiece> _placedPieces = [];
  int _score = 0;
  int _timeElapsed = 0;
  bool _isGameActive = true;
  bool _isComplete = false;
  Timer? _timer;
  PuzzlePiece? _selectedPiece;
  late DateTime _gameStartTime;
  late PuzzleScene _scene;

  @override
  void initState() {
    super.initState();
    _gameStartTime = DateTime.now();
    _scene = PuzzleLibrary.getSceneForLevel(widget.level);

    // Determine grid size based on level
    if (widget.level <= 2) {
      _gridSize = 2; // 4 pieces
    } else if (widget.level <= 5) {
      _gridSize = 3; // 9 pieces
    } else if (widget.level <= 10) {
      _gridSize = 4; // 16 pieces
    } else {
      _gridSize = 5; // 25 pieces (VIP Pro Master)
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
      ));
    }

    // Shuffle pieces
    _pieces.shuffle(Random());
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
        orElse: () => PuzzlePiece(id: -1, correctRow: -1, correctCol: -1),
      );
      if (pieceAtCell.id != -1) {
        setState(() {
          _selectedPiece = pieceAtCell;
          _placedPieces.remove(pieceAtCell);
          _pieces.add(pieceAtCell);
        });
      }
      return;
    }

    // A piece is selected, place it in the cell
    final pieceToPlace = _selectedPiece!;

    // Check if cell is already occupied
    final existingPieceIndex = _placedPieces.indexWhere(
      (p) => p.currentRow == row && p.currentCol == col,
    );

    setState(() {
      // If cell is occupied, return existing piece to available pieces
      if (existingPieceIndex != -1) {
        final existingPiece = _placedPieces.removeAt(existingPieceIndex);
        existingPiece.currentRow = -1;
        existingPiece.currentCol = -1;
        _pieces.add(existingPiece);
      }

      // Remove piece from available list
      _pieces.remove(pieceToPlace);

      // Place piece in cell
      pieceToPlace.currentRow = row;
      pieceToPlace.currentCol = col;
      _placedPieces.add(pieceToPlace);

      // Check if placement is correct
      final isCorrect = pieceToPlace.currentRow == pieceToPlace.correctRow &&
          pieceToPlace.currentCol == pieceToPlace.correctCol;

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
    int maxTime = _gridSize * _gridSize * 6;
    if (_timeElapsed > maxTime * 0.8) stars = 2;
    if (_timeElapsed > maxTime * 1.3) stars = 1;

    int points = _score + ((maxTime - _timeElapsed).clamp(0, 100) * 2);
    if (points < 20) points = 20;

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

  void _showImagePreviewDialog() {
    final isAr = Directionality.of(context) == TextDirection.rtl;
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(
          isAr ? _scene.titleAr : _scene.titleEn,
          textAlign: TextAlign.center,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: FullSceneArtwork(scene: _scene, size: 220),
            ),
            const SizedBox(height: 12),
            Text(
              isAr
                  ? 'هذه هي الصورة المطلوبة! رتب القطع لتطابقها.'
                  : 'Target picture! Arrange pieces to match it.',
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 13, color: Colors.grey),
            ),
          ],
        ),
        actions: [
          Center(
            child: ElevatedButton(
              onPressed: () => Navigator.pop(ctx),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.yellowAccent,
                foregroundColor: AppTheme.darkText,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: Text(isAr ? 'حسناً، فهمت' : 'Got it'),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isAr = Directionality.of(context) == TextDirection.rtl;
    final screenWidth = MediaQuery.of(context).size.width;
    final maxGridWidth = min(screenWidth - 48, 330.0);
    final cellSize = (maxGridWidth / _gridSize).floorToDouble();

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
                score: '$_score',
                timer:
                    '${_timeElapsed ~/ 60}:${(_timeElapsed % 60).toString().padLeft(2, '0')}',
                onExit: () => Navigator.pop(context),
              ),

              // Title bar of the current Scene & Preview Button
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 4.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Row(
                        children: [
                          Icon(_scene.mainIcon, color: const Color(0xFFFFD54F), size: 22),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              isAr ? _scene.titleAr : _scene.titleEn,
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 15,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ),
                    ElevatedButton.icon(
                      onPressed: _showImagePreviewDialog,
                      icon: const Icon(Icons.remove_red_eye_rounded, size: 16),
                      label: Text(
                        isAr ? 'معاينة الصورة' : 'Preview',
                        style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white.withOpacity(0.2),
                        foregroundColor: Colors.white,
                        elevation: 0,
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                          side: const BorderSide(color: Colors.white30),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // Puzzle Grid
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  child: Column(
                    children: [
                      // Board Container
                      Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: Colors.white30, width: 2),
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

                                final correctPieceId = row * _gridSize + col;
                                final isPieceAvailable =
                                    _pieces.any((p) => p.id == correctPieceId);
                                final showHint =
                                    placedPiece == null && isPieceAvailable;

                                final isCorrect = placedPiece != null &&
                                    placedPiece.currentRow ==
                                        placedPiece.correctRow &&
                                    placedPiece.currentCol ==
                                        placedPiece.correctCol;

                                return GestureDetector(
                                  onTap: () => _onGridCellTap(row, col),
                                  child: Container(
                                    width: cellSize,
                                    height: cellSize,
                                    margin: const EdgeInsets.all(2),
                                    decoration: BoxDecoration(
                                      color: placedPiece != null
                                          ? Colors.transparent
                                          : Colors.black26,
                                      borderRadius: BorderRadius.circular(8),
                                      border: Border.all(
                                        color: placedPiece != null
                                            ? (isCorrect
                                                ? Colors.greenAccent
                                                : Colors.orangeAccent)
                                            : (showHint
                                                ? Colors.amber.withOpacity(0.4)
                                                : Colors.white24),
                                        width: placedPiece != null ? 2 : 1,
                                      ),
                                    ),
                                    child: placedPiece != null
                                        ? PuzzlePieceWidget(
                                            scene: _scene,
                                            pieceId: placedPiece.id,
                                            correctRow: placedPiece.correctRow,
                                            correctCol: placedPiece.correctCol,
                                            gridSize: _gridSize,
                                            size: cellSize - 4,
                                            isCorrectlyPlaced: isCorrect,
                                          )
                                        : Center(
                                            child: Text(
                                              '${correctPieceId + 1}',
                                              style: TextStyle(
                                                fontSize: 13,
                                                fontWeight: FontWeight.bold,
                                                color: Colors.white.withOpacity(0.35),
                                              ),
                                            ),
                                          ),
                                  ),
                                );
                              }),
                            );
                          }),
                        ),
                      ),

                      const SizedBox(height: 16),

                      // Available pieces tray
                      Text(
                        isAr
                            ? 'القطع المتبقية (اضغط على قطعة ثم ضعها بالشبكة):'
                            : 'Remaining Pieces (Tap to pick & place):',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 10),

                      if (_pieces.isEmpty)
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.green.withOpacity(0.3),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: Colors.greenAccent),
                          ),
                          child: Text(
                            isAr
                                ? '🎉 أحسنت! جميع القطع موضوعة في مكانها.'
                                : '🎉 Great job! All pieces are placed.',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        )
                      else
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          alignment: WrapAlignment.center,
                          children: _pieces.map((piece) {
                            final isSelected = _selectedPiece == piece;
                            return GestureDetector(
                              onTap: () => _onPieceTap(piece),
                              child: PuzzlePieceWidget(
                                scene: _scene,
                                pieceId: piece.id,
                                correctRow: piece.correctRow,
                                correctCol: piece.correctCol,
                                gridSize: _gridSize,
                                size: min(cellSize, 54.0),
                                isSelected: isSelected,
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
      ),
    );
  }
}

class PuzzlePiece {
  final int id;
  final int correctRow;
  final int correctCol;
  int currentRow = -1;
  int currentCol = -1;

  PuzzlePiece({
    required this.id,
    required this.correctRow,
    required this.correctCol,
  });
}
