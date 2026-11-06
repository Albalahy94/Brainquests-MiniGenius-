import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/services/vip_service.dart';
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
    final isVip = VipService.isVipLevel(level);
    final isAr = Localizations.localeOf(context).languageCode == 'ar';

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: isVip ? null : backgroundColor,
        gradient: isVip
            ? const LinearGradient(
                colors: [Color(0xFF1E1B4B), Color(0xFF312E81)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              )
            : null,
        border: isVip
            ? const Border(
                bottom: BorderSide(color: Color(0xFFFFD54F), width: 2.5),
              )
            : null,
        boxShadow: [
          BoxShadow(
            color: isVip
                ? const Color(0xFFFFD54F).withOpacity(0.25)
                : Colors.black.withOpacity(0.1),
            blurRadius: isVip ? 8 : 4,
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
                alignment: isAr ? Alignment.centerRight : Alignment.centerLeft,
                child: isVip
                    ? Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 5),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [Color(0xFFFFD54F), Color(0xFFFFA000)],
                          ),
                          borderRadius: BorderRadius.circular(10),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.amber.withOpacity(0.4),
                              blurRadius: 6,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons.workspace_premium,
                              color: Color(0xFF3E2723),
                              size: 16,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              isAr
                                  ? 'VIP المحترف • $level'
                                  : 'VIP PRO • $level',
                              style: const TextStyle(
                                color: Color(0xFF3E2723),
                                fontSize: 13,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                          ],
                        ),
                      )
                    : Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: AppTheme.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          isAr ? 'المستوى $level' : 'Level $level',
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
