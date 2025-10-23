
/// Represents a single OHLCV candlestick data point
class Candle {
  final DateTime time;
  final double open;
  final double high;
  final double low;
  final double close;
  final double volume;

  const Candle({
    required this.time,
    required this.open,
    required this.high,
    required this.low,
    required this.close,
    required this.volume,
  });

  /// Create a Candle from a map (typically from JSON)
  factory Candle.fromMap(Map<String, dynamic> map) {
    return Candle(
      time: map['time'] is DateTime 
          ? map['time'] 
          : DateTime.fromMillisecondsSinceEpoch(map['time'] ?? 0),
      open: (map['open'] ?? 0.0).toDouble(),
      high: (map['high'] ?? 0.0).toDouble(),
      low: (map['low'] ?? 0.0).toDouble(),
      close: (map['close'] ?? 0.0).toDouble(),
      volume: (map['volumeto'] ?? map['volume'] ?? 0.0).toDouble(),
    );
  }

  /// Convert Candle to a map (for serialization)
  Map<String, dynamic> toMap() {
    return {
      'time': time.millisecondsSinceEpoch,
      'open': open,
      'high': high,
      'low': low,
      'close': close,
      'volume': volume,
    };
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Candle &&
        other.time.isAtSameMomentAs(time) &&
        other.open == open &&
        other.high == high &&
        other.low == low &&
        other.close == close &&
        other.volume == volume;
  }

  @override
  int get hashCode => Object.hash(time, open, high, low, close, volume);
}