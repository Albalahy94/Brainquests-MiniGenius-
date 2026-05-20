import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../core/models/game_info.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/glassmorphic_container.dart';

class GameCard extends StatefulWidget {
  final GameInfo game;
  final VoidCallback onTap;
  final bool isLocked;

  const GameCard({
    super.key,
    required this.game,
    required this.onTap,
    this.isLocked = false,
  });

  @override
  State<GameCard> createState() => _GameCardState();
}

class _GameCardState extends State<GameCard> {
  bool _isPressed = false;

  void _handleTapDown(TapDownDetails details) => setState(() => _isPressed = true);
  
  void _handleTapUp(TapUpDetails details) {
    setState(() => _isPressed = false);
    widget.onTap();
  }
  
  void _handleTapCancel() => setState(() => _isPressed = false);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    Widget cardContent = GlassmorphicContainer(
      color: widget.isLocked 
          ? (isDark ? Colors.grey.withOpacity(0.1) : Colors.grey.withOpacity(0.3))
          : (isDark ? AppTheme.spaceSurface.withOpacity(0.4) : Colors.white.withOpacity(0.6)),
      borderColor: isDark ? Colors.white.withOpacity(0.1) : Colors.white.withOpacity(0.5),
      child: Stack(
        children: [
          if (widget.isLocked)
            Positioned.fill(
              child: Container(
                color: Colors.black.withOpacity(0.4),
                child: const Center(
                  child: Icon(Icons.lock, color: Colors.white, size: 30),
                ),
              ),
            ),
          Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 16.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      color: widget.game.color.withOpacity(0.2),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(widget.game.icon, size: 30, color: widget.game.color),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    widget.game.name,
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                    ),
                    textAlign: TextAlign.center,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 6),
                  Text(
                    widget.game.description,
                    style: theme.textTheme.bodySmall?.copyWith(fontSize: 10, height: 1.2),
                    textAlign: TextAlign.center,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );

    return GestureDetector(
      onTapDown: _handleTapDown,
      onTapUp: _handleTapUp,
      onTapCancel: _handleTapCancel,
      child: Hero(
        tag: 'game_icon_${widget.game.id}',
        child: cardContent
            .animate(target: _isPressed ? 1 : 0)
            .scale(end: const Offset(0.95, 0.95), duration: 150.ms, curve: Curves.easeInOut)
            .shimmer(duration: 1000.ms, color: Colors.white.withOpacity(0.2)),
      ),
    );
  }
}

