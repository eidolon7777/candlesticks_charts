import 'package:flutter/material.dart';
import 'dart:math' as math;
import '../../core/models/candle.dart';
import '../../core/models/transform_data.dart';

/// CustomPainter for rendering candlesticks
class CandlePainter extends CustomPainter {
  final TransformData transform;
  final List<Candle> data;
  final Color bullishColor;
  final Color bearishColor;

  CandlePainter({
    required this.transform,
    required this.data,
    this.bullishColor = const Color(0xFF26A69A),
    this.bearishColor = const Color(0xFFEF5350),
  });

  @override
  void paint(Canvas canvas, Size size) {
    final t = transform.copyWith(height: size.height, width: size.width);
    _drawCandles(canvas, size, t);
  }

  void _drawCandles(Canvas canvas, Size size, TransformData transform) {
    final wickPaint =
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2.0; // Thicker wicks for better visibility

    final bodyPaint = Paint()..style = PaintingStyle.fill;

    final candleWidth = transform.pixelsPerCandle * 0.8;
    final halfCandleWidth = candleWidth / 2;

    // Ensure we're showing all available candles if there are fewer than would fill the screen
    final availableWidth = size.width - transform.leftPadding;
    final canFitCount = (availableWidth / transform.pixelsPerCandle).ceil();

    int startIdx;
    int endIdx;

    // If we have fewer candles than can fit on screen, adjust viewport to show all
    if (data.length <= canFitCount) {
      // Draw all candles
      startIdx = 0;
      endIdx = data.length;
    } else {
      // Draw more candles to fill the screen
      final visibleCount = (size.width / transform.pixelsPerCandle).ceil() + 2;
      startIdx = math.max(0, transform.visibleStartIndex.floor() - 1);
      endIdx = math.min(data.length, startIdx + visibleCount);
    }

    for (int i = startIdx; i < endIdx; i++) {
      final candle = data[i];
      final x = transform.indexToX(i.toDouble());

      // Skip if outside visible area
      if (x + halfCandleWidth < transform.leftPadding ||
          x - halfCandleWidth > size.width) {
        continue;
      }

      final highY = transform.priceToY(candle.high);
      final lowY = transform.priceToY(candle.low);
      final openY = transform.priceToY(candle.open);
      final closeY = transform.priceToY(candle.close);

      // Determine if bullish or bearish
      final isBullish = candle.close >= candle.open;
      final color = isBullish ? bullishColor : bearishColor;

      wickPaint.color = color;
      bodyPaint.color = color;

      // Draw wick
      canvas.drawLine(Offset(x, highY), Offset(x, lowY), wickPaint);

      // Draw body
      final bodyTop = isBullish ? closeY : openY;
      final bodyBottom = isBullish ? openY : closeY;
      final bodyHeight = (bodyBottom - bodyTop).abs();

      canvas.drawRect(
        Rect.fromLTWH(
          x - halfCandleWidth,
          bodyTop,
          candleWidth,
          bodyHeight == 0 ? 1 : bodyHeight,
        ),
        bodyPaint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CandlePainter oldDelegate) {
    return oldDelegate.transform != transform ||
        oldDelegate.data != data ||
        oldDelegate.bullishColor != bullishColor ||
        oldDelegate.bearishColor != bearishColor;
  }
}
