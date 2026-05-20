import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';
import 'exit_game_dialog.dart';

/// A standardized header widget for all games
/// Provides consistent UI with level info, score, timer, and exit button
class GameHeader extends StatelessWidget {
  final int level;
  final String? score;
  final String? timer;
  final String? additionalInfo;
  final VoidCallback? onExit;
  final Color backgroundColor;
  final bool showExitConfirmation;

  const GameHeader({
    super.key,
    required this.level,
    this.score,
    this.timer,
    this.additionalInfo,
    this.onExit,
    this.backgroundColor = AppTheme.primaryBlue,
    this.showExitConfirmation = true,
  });

  Future<void> _handleExit(BuildContext context) async {
    if (showExitConfirmation) {
      final shouldExit = await showDialog<bool>(
        context: context,
        builder: (context) => const ExitGameDialog(),
      );
      if (shouldExit == true && onExit != null) {
        onExit!();
      }
    } else {
      onExit?.call();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: backgroundColor,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: SafeArea(
        bottom: false,
        child: Row(
          children: [
            // Exit button
            IconButton(
              icon: const Icon(Icons.close, color: AppTheme.white, size: 24),
              onPressed: onExit != null ? () => _handleExit(context) : null,
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(),
            ),

            const SizedBox(width: 8),

            // Level info - Wrapped in Flexible/FittedBox
            Flexible(
              flex: 2,
              child: FittedBox(
                fit: BoxFit.scaleDown,
                alignment: Alignment.centerLeft,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppTheme.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    'المستوى $level',
                    style: const TextStyle(
                      color: AppTheme.white,
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),

            const Spacer(),

            // Stats group - Wrapped in Flexible/FittedBox
            Flexible(
              flex: 3,
              child: FittedBox(
                fit: BoxFit.scaleDown,
                alignment: Alignment.centerRight,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Additional info
                    if (additionalInfo != null) ...[
                      Text(
                        additionalInfo!,
                        style: const TextStyle(
                          color: AppTheme.white,
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(width: 8),
                    ],

                    // Score
                    if (score != null) ...[
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.star,
                              color: AppTheme.yellowAccent, size: 18),
                          const SizedBox(width: 2),
                          Text(
                            score!,
                            style: const TextStyle(
                              color: AppTheme.white,
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(width: 8),
                    ],

                    // Timer
                    if (timer != null) ...[
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.timer, color: AppTheme.white, size: 18),
                          const SizedBox(width: 2),
                          Text(
                            timer!,
                            style: const TextStyle(
                              color: AppTheme.white,
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ],
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
