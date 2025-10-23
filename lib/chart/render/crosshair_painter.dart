import 'package:flutter/material.dart';
import '../../core/models/candle.dart';
import '../../core/models/transform_data.dart';

/// Painter to draw dashed crosshair lines at the selected candle
class CrosshairPainter extends CustomPainter {
  final TransformData transform;
  final Candle? candle;
  final int? selectedIndex;
  final Color color;
  final double strokeWidth;

  CrosshairPainter({
    required this.transform,
    required this.candle,
    required this.selectedIndex,
    this.color = const Color(0xFF666666),
    this.strokeWidth = 1.0,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (candle == null || selectedIndex == null) return;

    final t = transform.copyWith(height: size.height, width: size.width);
    final x = t.indexToX(selectedIndex!.toDouble());
    final y = t.priceToY(candle!.close);

    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth;

    // Draw dashed horizontal line across grid area
    _drawDashedLine(
      canvas,
      Offset(t.leftPadding, y),
      Offset(size.width, y),
      6, 4,
      paint,
    );

    // Draw dashed vertical line across chart height
    _drawDashedLine(
      canvas,
      Offset(x, 0),
      Offset(x, size.height),
      6, 4,
      paint,
    );

    // Draw a small dot at intersection
    final dotPaint = Paint()..color = color;
    canvas.drawCircle(Offset(x, y), 3, dotPaint);
  }

  void _drawDashedLine(
    Canvas canvas,
    Offset p1,
    Offset p2,
    double dashLength,
    double dashGap,
    Paint paint,
  ) {
    final totalLength = (p2 - p1).distance;
    final direction = (p2 - p1) / totalLength;
    double current = 0;
    while (current < totalLength) {
      final start = p1 + direction * current;
      current += dashLength;
      final end = p1 + direction * (current.clamp(0, totalLength));
      canvas.drawLine(start, end, paint);
      current += dashGap;
    }
  }

  @override
  bool shouldRepaint(covariant CrosshairPainter oldDelegate) {
    return oldDelegate.transform != transform ||
        oldDelegate.candle != candle ||
        oldDelegate.selectedIndex != selectedIndex ||
        oldDelegate.color != color ||
        oldDelegate.strokeWidth != strokeWidth;
  }
}