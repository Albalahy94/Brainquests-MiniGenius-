import 'package:flutter/material.dart';

class NatureLandscapePainter extends CustomPainter {
  final int level;
  final List<Color> colors;

  NatureLandscapePainter({
    required this.level,
    required this.colors,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    // 1. Sky Gradient
    final skyPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: colors.length >= 2
            ? [colors[0], colors[1]]
            : [const Color(0xFF64B5F6), const Color(0xFFE1F5FE)],
      ).createShader(Rect.fromLTWH(0, 0, w, h * 0.7));
    canvas.drawRect(Rect.fromLTWH(0, 0, w, h), skyPaint);

    // 2. Sun
    final sunCenter = Offset(w * 0.82, h * 0.18);
    final sunGlow = Paint()
      ..color = Colors.amber.withValues(alpha: 0.3)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 12);
    canvas.drawCircle(sunCenter, 24, sunGlow);
    final sunPaint = Paint()..color = const Color(0xFFFFD54F);
    canvas.drawCircle(sunCenter, 18, sunPaint);

    // 3. Clouds
    _drawCloud(canvas, Offset(w * 0.22, h * 0.15), 26);
    _drawCloud(canvas, Offset(w * 0.58, h * 0.12), 20);

    // 4. Distant Mountains / Hills
    final mountainPaint = Paint()..color = colors.last.withValues(alpha: 0.45);
    final mPath = Path()
      ..moveTo(0, h * 0.6)
      ..quadraticBezierTo(w * 0.25, h * 0.45, w * 0.5, h * 0.58)
      ..quadraticBezierTo(w * 0.75, h * 0.48, w, h * 0.62)
      ..lineTo(w, h)
      ..lineTo(0, h)
      ..close();
    canvas.drawPath(mPath, mountainPaint);

    // 5. Foreground Rolling Green Hill / Ground
    final groundPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          const Color(0xFF81C784),
          const Color(0xFF388E3C),
        ],
      ).createShader(Rect.fromLTWH(0, h * 0.55, w, h * 0.45));

    final gPath = Path()
      ..moveTo(0, h * 0.65)
      ..quadraticBezierTo(w * 0.35, h * 0.58, w * 0.7, h * 0.68)
      ..quadraticBezierTo(w * 0.88, h * 0.72, w, h * 0.66)
      ..lineTo(w, h)
      ..lineTo(0, h)
      ..close();
    canvas.drawPath(gPath, groundPaint);

    // 6. Illustrated Trees
    _drawTree(canvas, Offset(w * 0.15, h * 0.68), 34, const Color(0xFF2E7D32));
    _drawTree(canvas, Offset(w * 0.32, h * 0.72), 26, const Color(0xFF43A047));
    _drawTree(canvas, Offset(w * 0.88, h * 0.7), 32, const Color(0xFF1B5E20));

    // 7. Small River / Pond in certain levels
    if (level % 2 == 0) {
      final riverPaint = Paint()
        ..color = const Color(0xFF4FC3F7).withValues(alpha: 0.8);
      final rPath = Path()
        ..moveTo(w * 0.4, h)
        ..quadraticBezierTo(w * 0.48, h * 0.82, w * 0.6, h * 0.75)
        ..quadraticBezierTo(w * 0.65, h * 0.82, w * 0.65, h)
        ..close();
      canvas.drawPath(rPath, riverPaint);
    }
  }

  void _drawCloud(Canvas canvas, Offset center, double radius) {
    final cloudPaint = Paint()..color = Colors.white.withValues(alpha: 0.85);
    canvas.drawCircle(center, radius, cloudPaint);
    canvas.drawCircle(
        Offset(center.dx - radius * 0.6, center.dy + radius * 0.2),
        radius * 0.7,
        cloudPaint);
    canvas.drawCircle(
        Offset(center.dx + radius * 0.6, center.dy + radius * 0.2),
        radius * 0.75,
        cloudPaint);
  }

  void _drawTree(
      Canvas canvas, Offset base, double canopyRadius, Color foliageColor) {
    // Trunk
    final trunkPaint = Paint()..color = const Color(0xFF6D4C41);
    final trunkRect = Rect.fromCenter(
      center: Offset(base.dx, base.dy - canopyRadius * 0.6),
      width: canopyRadius * 0.28,
      height: canopyRadius * 1.2,
    );
    canvas.drawRRect(
        RRect.fromRectAndRadius(trunkRect, const Radius.circular(4)),
        trunkPaint);

    // Foliage Circles
    final foliagePaint = Paint()..color = foliageColor;
    final topCenter = Offset(base.dx, base.dy - canopyRadius * 1.3);
    canvas.drawCircle(topCenter, canopyRadius, foliagePaint);
    canvas.drawCircle(
        Offset(topCenter.dx - canopyRadius * 0.35,
            topCenter.dy + canopyRadius * 0.2),
        canopyRadius * 0.75,
        foliagePaint);
    canvas.drawCircle(
        Offset(topCenter.dx + canopyRadius * 0.35,
            topCenter.dy + canopyRadius * 0.2),
        canopyRadius * 0.75,
        foliagePaint);

    // Highlight
    final highlightPaint = Paint()..color = Colors.white.withValues(alpha: 0.2);
    canvas.drawCircle(
        Offset(topCenter.dx - canopyRadius * 0.25,
            topCenter.dy - canopyRadius * 0.25),
        canopyRadius * 0.4,
        highlightPaint);
  }

  @override
  bool shouldRepaint(covariant NatureLandscapePainter oldDelegate) {
    return oldDelegate.level != level;
  }
}
