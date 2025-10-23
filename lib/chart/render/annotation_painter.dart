import 'package:flutter/material.dart';
import '../../core/models/annotation.dart';
import '../../core/models/transform_data.dart';

/// CustomPainter for rendering annotations (drawing tools)
class AnnotationPainter extends CustomPainter {
  final TransformData transform;
  final List<Annotation> annotations;
  final Annotation? activeAnnotation;

  AnnotationPainter({
    required this.transform,
    required this.annotations,
    this.activeAnnotation,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final t = transform.copyWith(height: size.height, width: size.width);

    // Draw all annotations
    for (final annotation in annotations) {
      if (annotation.visible) {
        _drawAnnotation(canvas, size, t, annotation);
      }
    }

    // Draw active annotation if exists
    if (activeAnnotation != null) {
      _drawAnnotation(canvas, size, t, activeAnnotation!, isActive: true);
    }
  }

  void _drawAnnotation(
    Canvas canvas,
    Size size,
    TransformData transform,
    Annotation annotation, {
    bool isActive = false,
  }) {
    final paint =
        Paint()
          ..color = Color(annotation.color)
          ..style = PaintingStyle.stroke
          ..strokeWidth = annotation.lineWidth;

    if (isActive) {
      paint.color = paint.color.withValues(alpha: 0.7);
    }

    switch (annotation.type) {
      case ToolType.trendline:
        _drawTrendline(canvas, transform, annotation, paint, isActive);
        break;
      case ToolType.horizontal:
        _drawHorizontalLine(
          canvas,
          size,
          transform,
          annotation,
          paint,
          isActive,
        );
        break;
      case ToolType.fibonacci:
        _drawFibonacci(canvas, size, transform, annotation, paint, isActive);
        break;
    }
  }

  void _drawTrendline(
    Canvas canvas,
    TransformData transform,
    Annotation annotation,
    Paint paint,
    bool isActive,
  ) {
    if (annotation.anchors.length < 2) return;

    final start = annotation.anchors[0];
    final end = annotation.anchors[1];

    final startX = transform.indexToX(start.index);
    final startY = transform.priceToY(start.price);
    final endX = transform.indexToX(end.index);
    final endY = transform.priceToY(end.price);

    canvas.drawLine(Offset(startX, startY), Offset(endX, endY), paint);

    // Draw handles if active
    if (isActive) {
      _drawHandle(canvas, Offset(startX, startY));
      _drawHandle(canvas, Offset(endX, endY));
    }
  }

  void _drawHorizontalLine(
    Canvas canvas,
    Size size,
    TransformData transform,
    Annotation annotation,
    Paint paint,
    bool isActive,
  ) {
    if (annotation.anchors.isEmpty) return;

    final anchor = annotation.anchors[0];
    final y = transform.priceToY(anchor.price);

    canvas.drawLine(
      Offset(transform.leftPadding, y),
      Offset(size.width, y),
      paint,
    );

    // Draw handle if active
    if (isActive) {
      _drawHandle(canvas, Offset(transform.leftPadding + 50, y));
    }
  }

  void _drawFibonacci(
    Canvas canvas,
    Size size,
    TransformData transform,
    Annotation annotation,
    Paint paint,
    bool isActive,
  ) {
    if (annotation.anchors.length < 2) return;

    final start = annotation.anchors[0];
    final end = annotation.anchors[1];

    final startX = transform.indexToX(start.index);
    final startY = transform.priceToY(start.price);
    final endX = transform.indexToX(end.index);
    final endY = transform.priceToY(end.price);

    // Draw the main trend line
    canvas.drawLine(Offset(startX, startY), Offset(endX, endY), paint);

    // Calculate price range
    final priceRange = (start.price - end.price).abs();

    // Fibonacci levels: 0, 0.236, 0.382, 0.5, 0.618, 0.786, 1.0
    final levels = [0.0, 0.236, 0.382, 0.5, 0.618, 0.786, 1.0];

    // Draw horizontal lines at each level
    for (final level in levels) {
      final levelPrice =
          start.price > end.price
              ? start.price - (priceRange * level)
              : start.price + (priceRange * level);

      final levelY = transform.priceToY(levelPrice);

      // Use a different color for each level
      final levelPaint =
          Paint()
            ..color = Color(annotation.color).withValues(alpha: 0.7)
            ..style = PaintingStyle.stroke
            ..strokeWidth = annotation.lineWidth;

      canvas.drawLine(
        Offset(transform.leftPadding, levelY),
        Offset(size.width, levelY),
        levelPaint,
      );

      // Draw level text
      final textPainter = TextPainter(
        text: TextSpan(
          text: '${(level * 100).toStringAsFixed(1)}%',
          style: TextStyle(color: Color(annotation.color), fontSize: 10),
        ),
        textDirection: TextDirection.ltr,
      );

      textPainter.layout();
      textPainter.paint(
        canvas,
        Offset(transform.leftPadding + 5, levelY - textPainter.height / 2),
      );
    }

    // Draw handles if active
    if (isActive) {
      _drawHandle(canvas, Offset(startX, startY));
      _drawHandle(canvas, Offset(endX, endY));
    }
  }

  void _drawHandle(Canvas canvas, Offset position) {
    final handlePaint =
        Paint()
          ..color = Colors.white
          ..style = PaintingStyle.fill;

    final handleBorderPaint =
        Paint()
          ..color = Colors.black
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.0;

    canvas.drawCircle(position, 5, handlePaint);
    canvas.drawCircle(position, 5, handleBorderPaint);
  }

  @override
  bool shouldRepaint(covariant AnnotationPainter oldDelegate) {
    return oldDelegate.transform != transform ||
        oldDelegate.annotations != annotations ||
        oldDelegate.activeAnnotation != activeAnnotation;
  }
}
