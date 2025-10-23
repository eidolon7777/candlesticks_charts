/// Represents the transformation data needed to convert between
/// data coordinates (index, price) and screen coordinates (pixels)
class TransformData {
  /// The starting index in the viewport (can be fractional)
  final double viewportStart;
  
  /// Number of pixels per candle (zoom level)
  final double pixelsPerCandle;
  
  /// The highest price in the current viewport
  final double topPrice;
  
  /// The lowest price in the current viewport
  final double bottomPrice;
  
  /// Left padding in pixels
  final double leftPadding;
  
  /// The height of the chart in pixels
  final double height;
  
  /// The width of the chart in pixels
  final double width;
  
  /// The starting index of visible candles (integer)
  int get visibleStartIndex => viewportStart.floor();
  
  /// The ending index of visible candles (integer)
  int get visibleEndIndex => (viewportStart + (width / pixelsPerCandle).ceil()).ceil();
  
  /// The number of visible candles
  int get visibleCount => visibleEndIndex - visibleStartIndex + 1;
  
  /// The price range in the viewport
  double get priceRange => topPrice - bottomPrice;
  
  /// The number of pixels per price unit
  double get priceToPixel => height / (priceRange == 0 ? 1 : priceRange);

  const TransformData({
    required this.viewportStart,
    required this.pixelsPerCandle,
    required this.topPrice,
    required this.bottomPrice,
    required this.leftPadding,
    required this.height,
    required this.width,
  });
  
  /// Convert a price to a y-coordinate
  double priceToY(double price) {
    return height - ((price - bottomPrice) * priceToPixel);
  }
  
  /// Convert an index to an x-coordinate
  double indexToX(double index) {
    return (index - viewportStart) * pixelsPerCandle + leftPadding;
  }
  
  /// Convert an x-coordinate to an index
  double xToIndex(double x) {
    return ((x - leftPadding) / pixelsPerCandle) + viewportStart;
  }
  
  /// Convert a y-coordinate to a price
  double yToPrice(double y) {
    return bottomPrice + ((height - y) / priceToPixel);
  }
  
  /// Create a copy of this TransformData with some fields replaced
  TransformData copyWith({
    double? viewportStart,
    double? pixelsPerCandle,
    double? topPrice,
    double? bottomPrice,
    double? leftPadding,
    double? height,
    double? width,
  }) {
    return TransformData(
      viewportStart: viewportStart ?? this.viewportStart,
      pixelsPerCandle: pixelsPerCandle ?? this.pixelsPerCandle,
      topPrice: topPrice ?? this.topPrice,
      bottomPrice: bottomPrice ?? this.bottomPrice,
      leftPadding: leftPadding ?? this.leftPadding,
      height: height ?? this.height,
      width: width ?? this.width,
    );
  }
  
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is TransformData &&
        other.viewportStart == viewportStart &&
        other.pixelsPerCandle == pixelsPerCandle &&
        other.topPrice == topPrice &&
        other.bottomPrice == bottomPrice &&
        other.leftPadding == leftPadding &&
        other.height == height &&
        other.width == width;
  }
  
  @override
  int get hashCode => Object.hash(
        viewportStart,
        pixelsPerCandle,
        topPrice,
        bottomPrice,
        leftPadding,
        height,
        width,
      );
}