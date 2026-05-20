import 'dart:math';
import 'package:flutter/material.dart';

class AnimatedBackground extends StatefulWidget {
  final bool isDarkMode;
  
  const AnimatedBackground({super.key, required this.isDarkMode});

  @override
  State<AnimatedBackground> createState() => _AnimatedBackgroundState();
}

class _AnimatedBackgroundState extends State<AnimatedBackground> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  final List<Particle> _particles = [];
  final Random _random = Random();

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 15),
    )..repeat();

    // Initialize particles (soft orbs/bubbles)
    for (int i = 0; i < 20; i++) {
      _particles.add(Particle(
        x: _random.nextDouble(),
        y: _random.nextDouble(),
        speed: 0.2 + _random.nextDouble() * 0.3,
        radius: 30 + _random.nextDouble() * 80,
        color: Colors.white.withOpacity(0.02 + _random.nextDouble() * 0.08),
      ));
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return CustomPaint(
          painter: BackgroundPainter(
            particles: _particles,
            animationValue: _controller.value,
            isDarkMode: widget.isDarkMode,
          ),
          child: Container(),
        );
      },
    );
  }
}

class Particle {
  double x;
  double y;
  final double speed;
  final double radius;
  final Color color;

  Particle({
    required this.x,
    required this.y,
    required this.speed,
    required this.radius,
    required this.color,
  });
}

class BackgroundPainter extends CustomPainter {
  final List<Particle> particles;
  final double animationValue;
  final bool isDarkMode;

  BackgroundPainter({
    required this.particles,
    required this.animationValue,
    required this.isDarkMode,
  });

  @override
  void paint(Canvas canvas, Size size) {
    // Draw background gradient
    final Rect rect = Offset.zero & size;
    final Paint bgPaint = Paint();
    
    if (isDarkMode) {
      bgPaint.shader = const LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [Color(0xFF0F172A), Color(0xFF080B1A)],
      ).createShader(rect);
    } else {
      bgPaint.shader = const LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [Color(0xFF4DB7FF), Color(0xFF5ADBB5)],
      ).createShader(rect);
    }
    
    canvas.drawRect(rect, bgPaint);

    // Draw moving orbs
    for (var particle in particles) {
      // Calculate new position using a sine wave for smooth floating
      double offset = sin((animationValue + particle.x) * pi * 2) * 0.1;
      double newY = (particle.y - (animationValue * particle.speed)) % 1.2;
      // if it goes above the screen, wrap around (modulo handles this, but let's shift it)
      if (newY < -0.2) newY += 1.4;

      final paint = Paint()
        ..color = isDarkMode ? const Color(0xFF38BDF8).withOpacity(0.05) : particle.color
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 40); // Soft glowing orbs

      canvas.drawCircle(
        Offset((particle.x + offset) * size.width, newY * size.height),
        particle.radius,
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant BackgroundPainter oldDelegate) => true;
}
