import 'package:flutter/material.dart';
import '../../core/models/transform_data.dart';

/// CustomPainter for rendering the chart grid and axes
class GridPainter extends CustomPainter {
  final TransformData transform;
  final Color gridColor;
  final Color axisColor;
  final Color textColor;
  final int horizontalLineCount;
  final int verticalLineCount;
  
  GridPainter({
    required this.transform,
    this.gridColor = const Color(0x11000000),
    this.axisColor = const Color(0x33000000),
    this.textColor = const Color(0xFF666666),
    this.horizontalLineCount = 5,
    this.verticalLineCount = 5,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final t = transform.copyWith(height: size.height, width: size.width);
    _drawHorizontalLines(canvas, size, t);
    _drawVerticalLines(canvas, size, t);
    _drawPriceAxis(canvas, size, t);
    _drawTimeAxis(canvas, size, t);
  }
  
  void _drawHorizontalLines(Canvas canvas, Size size, TransformData transform) {
    final paint = Paint()
      ..color = gridColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;
    
    final priceRange = transform.topPrice - transform.bottomPrice;
    final step = priceRange / horizontalLineCount;
    
    for (int i = 0; i <= horizontalLineCount; i++) {
      final price = transform.bottomPrice + (step * i);
      final y = transform.priceToY(price);
      
      canvas.drawLine(
        Offset(transform.leftPadding, y),
        Offset(size.width, y),
        paint,
      );
    }
  }
  
  void _drawVerticalLines(Canvas canvas, Size size, TransformData transform) {
    final paint = Paint()
      ..color = gridColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;
    
    final visibleCount = transform.visibleCount;
    final step = visibleCount / verticalLineCount;
    
    for (int i = 0; i <= verticalLineCount; i++) {
      final index = transform.visibleStartIndex + (step * i);
      final x = transform.indexToX(index);
      
      if (x >= transform.leftPadding && x <= size.width) {
        canvas.drawLine(
          Offset(x, 0),
          Offset(x, size.height),
          paint,
        );
      }
    }
  }
  
  void _drawPriceAxis(Canvas canvas, Size size, TransformData transform) {
    final paint = Paint()
      ..color = axisColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;
    
    // Draw price axis line
    canvas.drawLine(
      Offset(transform.leftPadding, 0),
      Offset(transform.leftPadding, size.height),
      paint,
    );
    
    // Draw price labels
    final textStyle = TextStyle(
      color: textColor,
      fontSize: 10,
    );
    final textPainter = TextPainter(
      textDirection: TextDirection.ltr,
    );
    
    final priceRange = transform.topPrice - transform.bottomPrice;
    final step = priceRange / horizontalLineCount;
    
    for (int i = 0; i <= horizontalLineCount; i++) {
      final price = transform.bottomPrice + (step * i);
      final y = transform.priceToY(price);
      
      textPainter.text = TextSpan(
        text: price.toStringAsFixed(2),
        style: textStyle,
      );
      
      textPainter.layout();
      textPainter.paint(
        canvas,
        Offset(5, y - (textPainter.height / 2)),
      );
    }
  }
  
  void _drawTimeAxis(Canvas canvas, Size size, TransformData transform) {
    final paint = Paint()
      ..color = axisColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;
    
    // Draw time axis line
    canvas.drawLine(
      Offset(transform.leftPadding, size.height),
      Offset(size.width, size.height),
      paint,
    );
    
    // Time labels would be drawn here, but we need actual DateTime data
    // from the candles, which we don't have access to in this painter
    // This would be implemented in a real application
  }

  @override
  bool shouldRepaint(covariant GridPainter oldDelegate) {
    return oldDelegate.transform != transform ||
           oldDelegate.gridColor != gridColor ||
           oldDelegate.axisColor != axisColor ||
           oldDelegate.textColor != textColor ||
           oldDelegate.horizontalLineCount != horizontalLineCount ||
           oldDelegate.verticalLineCount != verticalLineCount;
  }
}