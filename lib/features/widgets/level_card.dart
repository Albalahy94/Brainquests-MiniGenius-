import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

class LevelCard extends StatelessWidget {
  final int levelNumber;
  final bool isUnlocked;
  final int stars;
  final VoidCallback? onTap;

  const LevelCard({
    super.key,
    required this.levelNumber,
    required this.isUnlocked,
    this.stars = 0,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return GestureDetector(
      onTap: isUnlocked ? onTap : null,
      child: Container(
        margin: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: isUnlocked
              ? colorScheme.primaryContainer
              : colorScheme.surfaceVariant.withOpacity(0.5),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: isUnlocked
                ? colorScheme.primary.withOpacity(0.5)
                : colorScheme.outline.withOpacity(0.2),
            width: 2,
          ),
          boxShadow: isUnlocked
              ? [
                  BoxShadow(
                    color: colorScheme.primary.withOpacity(0.2),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ]
              : null,
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
                      color: isUnlocked ? colorScheme.onPrimaryContainer : colorScheme.onSurfaceVariant,
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
                  Icons.lock_rounded,
                  color: colorScheme.onSurfaceVariant.withOpacity(0.5),
                  size: 20,
                ),
            ],
          ),
        ),
      ),
    )
    .animate(target: isUnlocked ? 1 : 0)
    .scale(duration: 400.ms, curve: Curves.easeOutBack)
    .fadeIn();
  }
}
