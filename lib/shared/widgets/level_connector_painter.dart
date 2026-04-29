import 'package:flutter/material.dart';
import 'dart:math' as math;

/// Pinta las líneas LED que conectan los niveles
class LevelConnectorPainter extends CustomPainter {
  final List<Offset> nodePositions;
  final int currentLevel;
  final Color activeColor;
  final Color inactiveColor;

  LevelConnectorPainter({
    required this.nodePositions,
    required this.currentLevel,
    required this.activeColor,
    required this.inactiveColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (nodePositions.length < 2) return;

    for (int i = 0; i < nodePositions.length - 1; i++) {
      final start = nodePositions[i];
      final end = nodePositions[i + 1];
      final isActive = (i + 1) < currentLevel;

      final color = isActive ? activeColor : inactiveColor;

      // Línea exterior (glow)
      if (isActive) {
        final glowPaint = Paint()
          ..color = color.withOpacity(0.3)
          ..strokeWidth = 12
          ..strokeCap = StrokeCap.round
          ..style = PaintingStyle.stroke
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8);
        canvas.drawLine(start, end, glowPaint);
      }

      // Línea principal
      final mainPaint = Paint()
        ..color = color.withOpacity(isActive ? 0.8 : 0.25)
        ..strokeWidth = 6
        ..strokeCap = StrokeCap.round
        ..style = PaintingStyle.stroke;
      canvas.drawLine(start, end, mainPaint);

      // Línea interior brillante (efecto LED)
      if (isActive) {
        final innerPaint = Paint()
          ..color = Colors.white.withOpacity(0.4)
          ..strokeWidth = 2
          ..strokeCap = StrokeCap.round
          ..style = PaintingStyle.stroke;
        canvas.drawLine(start, end, innerPaint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant LevelConnectorPainter oldDelegate) {
    return oldDelegate.currentLevel != currentLevel ||
        oldDelegate.activeColor != activeColor;
  }
}
