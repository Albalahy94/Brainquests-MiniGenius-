import 'package:flutter/material.dart';
import '../models/puzzle_theme.dart';

class PuzzlePieceWidget extends StatelessWidget {
  final PuzzleScene scene;
  final int pieceId;
  final int correctRow;
  final int correctCol;
  final int gridSize;
  final double size;
  final bool isSelected;
  final bool isCorrectlyPlaced;

  const PuzzlePieceWidget({
    super.key,
    required this.scene,
    required this.pieceId,
    required this.correctRow,
    required this.correctCol,
    required this.gridSize,
    required this.size,
    this.isSelected = false,
    this.isCorrectlyPlaced = false,
  });

  @override
  Widget build(BuildContext context) {
    // Each piece size
    final fullImageSize = size * gridSize;
    final offsetX = -correctCol * size;
    final offsetY = -correctRow * size;

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: isSelected
              ? Colors.yellowAccent
              : (isCorrectlyPlaced ? Colors.greenAccent : Colors.white30),
          width: isSelected ? 3 : (isCorrectlyPlaced ? 2.5 : 1.5),
        ),
        boxShadow: [
          BoxShadow(
            color: isSelected
                ? Colors.yellow.withOpacity(0.5)
                : Colors.black.withOpacity(0.2),
            blurRadius: isSelected ? 8 : 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: Stack(
          children: [
            // Clipped full scene shifted to show this exact slice
            Positioned(
              left: offsetX,
              top: offsetY,
              width: fullImageSize,
              height: fullImageSize,
              child: FullSceneArtwork(scene: scene, size: fullImageSize),
            ),

            // Number tag on top left
            Positioned(
              top: 3,
              left: 3,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1.5),
                decoration: BoxDecoration(
                  color: Colors.black54,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  '${pieceId + 1}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),

            if (isCorrectlyPlaced)
              const Positioned(
                bottom: 3,
                right: 3,
                child: Icon(Icons.check_circle, color: Colors.greenAccent, size: 16),
              ),
          ],
        ),
      ),
    );
  }
}

class FullSceneArtwork extends StatelessWidget {
  final PuzzleScene scene;
  final double size;

  const FullSceneArtwork({
    super.key,
    required this.scene,
    required this.size,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: scene.backgroundGradient,
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
      child: Stack(
        children: scene.elements.map((el) {
          final posX = el.x * size - (el.size / 2);
          final posY = el.y * size - (el.size / 2);

          return Positioned(
            left: posX.clamp(0.0, size - el.size),
            top: posY.clamp(0.0, size - el.size),
            child: Icon(
              el.icon,
              color: el.color,
              size: el.size * (size / 260.0).clamp(0.6, 1.8),
            ),
          );
        }).toList(),
      ),
    );
  }
}

