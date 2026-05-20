import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';
import '../ui/memory_cards_game_screen.dart';

class MemoryCardWidget extends StatelessWidget {
  final MemoryCardData card;
  final VoidCallback onTap;

  const MemoryCardWidget({
    super.key,
    required this.card,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
        decoration: BoxDecoration(
          color: card.isMatched
              ? AppTheme.mintGreen.withOpacity(0.5)
              : card.isFlipped
                  ? AppTheme.white
                  : AppTheme.primaryBlue,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: card.isMatched
                ? AppTheme.mintGreen
                : AppTheme.primaryBlue,
            width: 2,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: card.isFlipped || card.isMatched
            ? Icon(
                card.value,
                size: 40,
                color: AppTheme.primaryBlue,
              )
            : Icon(
                Icons.help_outline,
                size: 40,
                color: AppTheme.white,
              ),
      ),
    );
  }
}

