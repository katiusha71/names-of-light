import 'dart:math';
import 'package:flutter/material.dart';
import '../models/sephira_item.dart';
import '../data/tree_paths_data.dart';

class TreeOfLifePainter extends CustomPainter {
  final List<SephiraItem> sephirot;
  final Map<int, double> weights;
  final bool showDaat;
  final bool isRussian;

  TreeOfLifePainter({
    required this.sephirot,
    required this.weights,
    required this.showDaat,
    this.isRussian = false,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final visible = showDaat
        ? sephirot
        : sephirot.where((s) => !s.isHidden).toList();

    final sephiraMap = {for (var s in sephirot) s.id: s};

    // === PATHS ===
    for (final path in treePaths) {
      final from = sephiraMap[path.fromId];
      final to = sephiraMap[path.toId];
      if (from == null || to == null) continue;
      if (!showDaat && (from.isHidden || to.isHidden)) continue;

      final fromPos = Offset(from.x * size.width, from.y * size.height);
      final toPos = Offset(to.x * size.width, to.y * size.height);

      final wFrom = (weights[from.id] ?? 50.0) / 100.0;
      final wTo = (weights[to.id] ?? 50.0) / 100.0;
      final avgW = (wFrom + wTo) / 2.0;

      final blendedColor = Color.lerp(from.color, to.color, 0.5)!;

      // Energy line — cubic curve: weak paths nearly invisible,
      // strong paths bright. No skeleton — only energy flow.
      // avgW 0.3→alpha 5, 0.5→alpha 25, 0.7→alpha 69, 0.9→alpha 146
      final t3 = avgW * avgW * avgW;
      final energyAlpha = (t3 * 200).toInt().clamp(3, 200);
      final energyWidth = 0.5 + t3 * 3.0;
      final energyPaint = Paint()
        ..color = blendedColor.withAlpha(energyAlpha)
        ..strokeWidth = energyWidth
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round;
      canvas.drawLine(fromPos, toPos, energyPaint);

      // Glow — kicks in above 55%, strong above 75%
      if (avgW > 0.55) {
        final g = (avgW - 0.55) / 0.45; // 0..1
        final glowAlpha = (g * g * 80).toInt().clamp(0, 80);
        final glowPaint = Paint()
          ..color = blendedColor.withAlpha(glowAlpha)
          ..strokeWidth = 2.0 + g * 8.0
          ..style = PaintingStyle.stroke
          ..strokeCap = StrokeCap.round
          ..maskFilter = MaskFilter.blur(BlurStyle.normal, 3.0 + g * 6.0);
        canvas.drawLine(fromPos, toPos, glowPaint);
      }
    }

    // === NODES ===
    for (final sephira in visible) {
      final center = Offset(sephira.x * size.width, sephira.y * size.height);
      final w = (weights[sephira.id] ?? 50.0) / 100.0; // 0.0..1.0
      const r = 18.0;
      const ringWidth = 3.0;

      // --- Outer radial glow — always present, scales with weight ---
      // Weak nodes get a subtle halo; strong nodes get a wide bright aura.
      {
        final glowRadius = r * (2.0 + w * 3.0);
        final innerAlpha = (30 + w * w * 225).toInt().clamp(30, 255);
        final midAlpha = (10 + w * w * 140).toInt().clamp(10, 150);
        final glowPaint = Paint()
          ..shader = RadialGradient(
            colors: [
              sephira.color.withAlpha(innerAlpha),
              sephira.color.withAlpha(midAlpha),
              sephira.color.withAlpha(0),
            ],
            stops: const [0.0, 0.4, 1.0],
          ).createShader(Rect.fromCircle(center: center, radius: glowRadius));
        canvas.drawCircle(center, glowRadius, glowPaint);
      }

      // --- Second glow layer for strong nodes (>50%) — extra bloom ---
      if (w > 0.5) {
        final t = (w - 0.5) / 0.5;
        final bloomRadius = r * (2.5 + t * 2.5);
        final bloomPaint = Paint()
          ..color = sephira.color.withAlpha((t * 60).toInt().clamp(0, 60))
          ..maskFilter = MaskFilter.blur(BlurStyle.normal, 8.0 + t * 12.0);
        canvas.drawCircle(center, bloomRadius * 0.5, bloomPaint);
      }

      // --- Dark fill (hollow center) ---
      final bgPaint = Paint()
        ..color = const Color(0xFF0A0A1E)
        ..style = PaintingStyle.fill;
      canvas.drawCircle(center, r, bgPaint);

      // --- Dim base ring (skeleton — always visible) ---
      final baseRingPaint = Paint()
        ..color = sephira.color.withAlpha(40)
        ..style = PaintingStyle.stroke
        ..strokeWidth = ringWidth;
      canvas.drawCircle(center, r, baseRingPaint);

      // --- Progress arc: fills clockwise from top, proportional to weight ---
      final arcRect = Rect.fromCircle(center: center, radius: r);
      final sweepAngle = w * 2 * pi;
      final arcAlpha = (60 + w * w * 195).toInt().clamp(60, 255);
      final arcPaint = Paint()
        ..color = sephira.color.withAlpha(arcAlpha)
        ..style = PaintingStyle.stroke
        ..strokeWidth = ringWidth
        ..strokeCap = StrokeCap.round;
      canvas.drawArc(arcRect, -pi / 2, sweepAngle, false, arcPaint);

      // --- Arc glow — always present, intensifies with weight ---
      {
        final arcGlowAlpha = (15 + w * w * 160).toInt().clamp(15, 175);
        final arcGlowPaint = Paint()
          ..color = sephira.color.withAlpha(arcGlowAlpha)
          ..style = PaintingStyle.stroke
          ..strokeWidth = ringWidth + 4.0 + w * 4.0
          ..strokeCap = StrokeCap.round
          ..maskFilter = MaskFilter.blur(BlurStyle.normal, 3.0 + w * 6.0);
        canvas.drawArc(arcRect, -pi / 2, sweepAngle, false, arcGlowPaint);
      }

      // --- Center dot for strong nodes (>65%) ---
      if (w > 0.65) {
        final t = (w - 0.65) / 0.35;
        final dotPaint = Paint()
          ..color = sephira.color.withAlpha((t * 140).toInt().clamp(0, 140))
          ..style = PaintingStyle.fill;
        canvas.drawCircle(center, 2.5 + t * 2.5, dotPaint);
      }

      // === LABELS ===

      // Above the node: Hebrew name + translation
      final textAlpha = (110 + w * 145).toInt().clamp(110, 255);
      final subAlpha = (60 + w * 140).toInt().clamp(60, 200);

      final hebrewPainter = TextPainter(
        text: TextSpan(
          text: sephira.nameHebrew,
          style: TextStyle(
            color: Colors.white.withAlpha(textAlpha),
            fontSize: 13,
            fontFamily: 'NotoSansHebrew',
            fontWeight: FontWeight.bold,
          ),
        ),
        textDirection: TextDirection.rtl,
        textAlign: TextAlign.center,
      )..layout();

      final meaning = sephira.getMeaning(isRussian);
      final meaningPainter = TextPainter(
        text: TextSpan(
          text: meaning,
          style: TextStyle(
            color: sephira.color.withAlpha(subAlpha),
            fontSize: 9,
            fontWeight: FontWeight.w500,
          ),
        ),
        textDirection: TextDirection.ltr,
        textAlign: TextAlign.center,
      )..layout();

      const gap = 1.0;
      final totalAbove = hebrewPainter.height + gap + meaningPainter.height + 3;
      final hebrewY = center.dy - r - totalAbove;
      final meaningY = hebrewY + hebrewPainter.height + gap;

      hebrewPainter.paint(
        canvas,
        Offset(center.dx - hebrewPainter.width / 2, hebrewY),
      );
      if (meaning.isNotEmpty) {
        meaningPainter.paint(
          canvas,
          Offset(center.dx - meaningPainter.width / 2, meaningY),
        );
      }

      // Below the node: transliteration
      final transAlpha = (60 + w * 100).toInt().clamp(60, 160);
      final transPainter = TextPainter(
        text: TextSpan(
          text: sephira.getName(isRussian),
          style: TextStyle(
            color: Colors.white.withAlpha(transAlpha),
            fontSize: 10,
          ),
        ),
        textDirection: TextDirection.ltr,
        textAlign: TextAlign.center,
      )..layout();
      transPainter.paint(
        canvas,
        Offset(center.dx - transPainter.width / 2, center.dy + r + 4),
      );
    }
  }

  @override
  bool shouldRepaint(TreeOfLifePainter oldDelegate) =>
      oldDelegate.weights != weights ||
      oldDelegate.showDaat != showDaat ||
      oldDelegate.sephirot != sephirot ||
      oldDelegate.isRussian != isRussian;
}
