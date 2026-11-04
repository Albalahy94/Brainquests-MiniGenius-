import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

class LevelCard extends StatelessWidget {
  final int levelNumber;
  final bool isUnlocked;
  final int stars;
  final VoidCallback? onTap;
  final bool isVip;

  const LevelCard({
    super.key,
    required this.levelNumber,
    required this.isUnlocked,
    this.stars = 0,
    this.onTap,
    this.isVip = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    // Distinctive color palettes for VIP levels vs Free levels
    final Color backgroundColor;
    final Color borderColor;
    final List<BoxShadow>? shadows;

    if (isVip) {
      if (isUnlocked) {
        // VIP unlocked: rich gold gradient look
        backgroundColor = const Color(0xFFFFF8E1);
        borderColor = const Color(0xFFFFB300);
        shadows = [
          BoxShadow(
            color: const Color(0xFFFFB300).withOpacity(0.3),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ];
      } else {
        // VIP locked: subtle golden bronze outline
        backgroundColor = const Color(0xFF2C2416).withOpacity(0.6);
        borderColor = const Color(0xFFFFB300).withOpacity(0.4);
        shadows = null;
      }
    } else {
      if (isUnlocked) {
        backgroundColor = colorScheme.primaryContainer;
        borderColor = colorScheme.primary.withOpacity(0.5);
        shadows = [
          BoxShadow(
            color: colorScheme.primary.withOpacity(0.2),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ];
      } else {
        backgroundColor = colorScheme.surfaceVariant.withOpacity(0.5);
        borderColor = colorScheme.outline.withOpacity(0.2);
        shadows = null;
      }
    }

    return GestureDetector(
      onTap: onTap,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Container(
            margin: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: backgroundColor,
              borderRadius: BorderRadius.circular(24),
              border: Border.all(
                color: borderColor,
                width: isVip ? 2.5 : 2,
              ),
              boxShadow: shadows,
            ),
            child: Padding(
              padding: const EdgeInsets.all(4.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Flexible(
                    child: FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Text(
                        '$levelNumber',
                        style: theme.textTheme.headlineSmall?.copyWith(
                          color: isVip
                              ? (isUnlocked ? const Color(0xFF8D6E63) : const Color(0xFFFFD54F))
                              : (isUnlocked
                                  ? colorScheme.onPrimaryContainer
                                  : colorScheme.onSurfaceVariant),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 2),
                  if (isUnlocked)
                    Flexible(
                      child: FittedBox(
                        fit: BoxFit.scaleDown,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          mainAxisSize: MainAxisSize.min,
                          children: List.generate(
                            3,
                            (index) => Icon(
                              index < stars ? Icons.star_rounded : Icons.star_outline_rounded,
                              color: index < stars ? Colors.amber : colorScheme.outline,
                              size: 14,
                            ),
                          ),
                        ),
                      ),
                    )
                  else
                    Icon(
                      isVip ? Icons.workspace_premium : Icons.lock_rounded,
                      color: isVip
                          ? const Color(0xFFFFCA28)
                          : colorScheme.onSurfaceVariant.withOpacity(0.5),
                      size: isVip ? 22 : 20,
                    ),
                ],
              ),
            ),
          ),

          // VIP Badge indicator on top corner
          if (isVip)
            Positioned(
              top: 2,
              right: 2,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFFFFD54F), Color(0xFFFF8F00)],
                  ),
                  borderRadius: BorderRadius.circular(10),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.2),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.star, size: 8, color: Colors.white),
                    SizedBox(width: 2),
                    Text(
                      'PRO',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 8,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    )
        .animate(target: isUnlocked ? 1 : 0)
        .scale(duration: 400.ms, curve: Curves.easeOutBack)
        .fadeIn();
  }
}
