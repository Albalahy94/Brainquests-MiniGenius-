import 'dart:async';
import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';

enum TimerMode {
  stopwatch, // Count up from 0
  countdown, // Count down from initial value
}

/// A reusable timer widget for games
/// Supports both stopwatch (count up) and countdown (count down) modes
class GameTimer extends StatefulWidget {
  final TimerMode mode;
  final int? initialSeconds; // Required for countdown mode
  final Function(int)? onTick; // Called every second with current time
  final VoidCallback? onComplete; // Called when countdown reaches 0
  final bool autoStart;
  final TextStyle? textStyle;
  final Color? iconColor;

  const GameTimer({
    super.key,
    this.mode = TimerMode.stopwatch,
    this.initialSeconds,
    this.onTick,
    this.onComplete,
    this.autoStart = true,
    this.textStyle,
    this.iconColor,
  }) : assert(
          mode == TimerMode.stopwatch || initialSeconds != null,
          'initialSeconds is required for countdown mode',
        );

  @override
  State<GameTimer> createState() => GameTimerState();
}

class GameTimerState extends State<GameTimer> {
  Timer? _timer;
  late int _currentSeconds;
  bool _isRunning = false;

  @override
  void initState() {
    super.initState();
    _currentSeconds =
        widget.mode == TimerMode.countdown ? widget.initialSeconds! : 0;

    if (widget.autoStart) {
      start();
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  /// Start or resume the timer
  void start() {
    if (_isRunning) return;

    _isRunning = true;
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }

      setState(() {
        if (widget.mode == TimerMode.countdown) {
          _currentSeconds--;

          if (_currentSeconds <= 0) {
            _currentSeconds = 0;
            _timer?.cancel();
            _isRunning = false;
            widget.onComplete?.call();
          }
        } else {
          _currentSeconds++;
        }
      });

      widget.onTick?.call(_currentSeconds);
    });
  }

  /// Pause the timer
  void pause() {
    _timer?.cancel();
    _isRunning = false;
  }

  /// Reset the timer to initial value
  void reset() {
    _timer?.cancel();
    _isRunning = false;
    setState(() {
      _currentSeconds =
          widget.mode == TimerMode.countdown ? widget.initialSeconds! : 0;
    });
  }

  /// Get current time in seconds
  int get currentSeconds => _currentSeconds;

  /// Format seconds to MM:SS
  String _formatTime(int seconds) {
    final minutes = seconds ~/ 60;
    final secs = seconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${secs.toString().padLeft(2, '0')}';
  }

  /// Get color based on remaining time (for countdown)
  Color _getTimerColor() {
    if (widget.mode == TimerMode.countdown && widget.initialSeconds != null) {
      final percentage = _currentSeconds / widget.initialSeconds!;
      if (percentage <= 0.2) {
        return Colors.red;
      } else if (percentage <= 0.5) {
        return Colors.orange;
      }
    }
    return widget.iconColor ?? AppTheme.white;
  }

  @override
  Widget build(BuildContext context) {
    final color = _getTimerColor();
    final defaultTextStyle = TextStyle(
      color: color,
      fontSize: 16,
      fontWeight: FontWeight.bold,
    );

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          Icons.timer,
          color: color,
          size: 20,
        ),
        const SizedBox(width: 4),
        Text(
          _formatTime(_currentSeconds),
          style: widget.textStyle ?? defaultTextStyle,
        ),
      ],
    );
  }
}
