import 'package:flutter/material.dart';

class GlowPainter extends CustomPainter {
  final Color color;
  final double opacity;
  final double radius;

  GlowPainter({
    required this.color,
    this.opacity = 0.6,
    this.radius = 1.0,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final maxRadius = size.shortestSide * 0.5 * radius;

    // Outer soft glow
    final outerPaint = Paint()
      ..shader = RadialGradient(
        colors: [
          color.withAlpha((opacity * 60).toInt()),
          color.withAlpha(0),
        ],
        stops: const [0.0, 1.0],
      ).createShader(Rect.fromCircle(center: center, radius: maxRadius * 1.5));
    canvas.drawCircle(center, maxRadius * 1.5, outerPaint);

    // Main glow - more saturated
    final mainPaint = Paint()
      ..shader = RadialGradient(
        colors: [
          color.withAlpha((opacity * 220).toInt()),
          color.withAlpha((opacity * 120).toInt()),
          color.withAlpha((opacity * 40).toInt()),
          color.withAlpha(0),
        ],
        stops: const [0.0, 0.3, 0.65, 1.0],
      ).createShader(Rect.fromCircle(center: center, radius: maxRadius));
    canvas.drawCircle(center, maxRadius, mainPaint);

    // Hot core
    final corePaint = Paint()
      ..shader = RadialGradient(
        colors: [
          Colors.white.withAlpha((opacity * 100).toInt()),
          color.withAlpha((opacity * 160).toInt()),
          color.withAlpha(0),
        ],
        stops: const [0.0, 0.3, 1.0],
      ).createShader(Rect.fromCircle(center: center, radius: maxRadius * 0.4));
    canvas.drawCircle(center, maxRadius * 0.4, corePaint);
  }

  @override
  bool shouldRepaint(GlowPainter oldDelegate) =>
      oldDelegate.color != color ||
      oldDelegate.opacity != opacity ||
      oldDelegate.radius != radius;
}
