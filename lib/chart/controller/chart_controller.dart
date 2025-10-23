import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/models/candle.dart';
import '../../core/models/annotation.dart';
import '../../core/models/transform_data.dart';

/// Represents the state of the chart
class ChartState {
  /// The candle data (immutable snapshot)
  final List<Candle> data;
  
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
  
  /// List of annotations (drawings)
  final List<Annotation> annotations;
  
  /// Currently active drawing tool
  final ToolType? activeTool;
  
  /// Currently selected candle index
  final int? selectedCandleIndex;
  
  /// The transform data for coordinate conversion
  TransformData get transformData => TransformData(
    viewportStart: viewportStart,
    pixelsPerCandle: pixelsPerCandle,
    topPrice: topPrice,
    bottomPrice: bottomPrice,
    leftPadding: leftPadding,
    // These will be set by the chart widget
    height: 0,
    width: 0,
  );

  const ChartState({
    this.data = const [],
    this.viewportStart = 0.0,
    this.pixelsPerCandle = 8.0,
    this.topPrice = 0.0,
    this.bottomPrice = 0.0,
    this.leftPadding = 50.0,
    this.annotations = const [],
    this.activeTool,
    this.selectedCandleIndex,
  });

  /// Create a copy of this ChartState with some fields replaced
  ChartState copyWith({
    List<Candle>? data,
    double? viewportStart,
    double? pixelsPerCandle,
    double? topPrice,
    double? bottomPrice,
    double? leftPadding,
    List<Annotation>? annotations,
    ToolType? activeTool,
    bool clearActiveTool = false,
    int? selectedCandleIndex,
    bool clearSelectedCandleIndex = false,
  }) {
    return ChartState(
      data: data ?? this.data,
      viewportStart: viewportStart ?? this.viewportStart,
      pixelsPerCandle: pixelsPerCandle ?? this.pixelsPerCandle,
      topPrice: topPrice ?? this.topPrice,
      bottomPrice: bottomPrice ?? this.bottomPrice,
      leftPadding: leftPadding ?? this.leftPadding,
      annotations: annotations ?? this.annotations,
      activeTool: clearActiveTool ? null : (activeTool ?? this.activeTool),
      selectedCandleIndex: clearSelectedCandleIndex ? null : (selectedCandleIndex ?? this.selectedCandleIndex),
    );
  }
}

/// Controller for the chart, manages state and provides methods for interaction
class ChartController extends StateNotifier<ChartState> {
  ChartController() : super(const ChartState(
    data: [],
    viewportStart: 0.0,
    pixelsPerCandle: 25.0, // Increased size to make candles more visible
    topPrice: 160.0, // Increased to show more price range
    bottomPrice: 60.0, // Decreased to show more price range
    leftPadding: 50.0,
    annotations: [],
    activeTool: null,
    selectedCandleIndex: null,
  ));

  /// Load candle data into the chart
  void loadData(List<Candle> candles) {
    if (candles.isEmpty) return;
    
    state = state.copyWith(
      data: List.unmodifiable(candles),
      viewportStart: 0.0,
      // Keep the current pixelsPerCandle setting instead of overriding it
    );
    
    _recalcYScale();
  }

  /// Pan the chart by a number of pixels
  void pan(double deltaPixels) {
    if (state.data.isEmpty) return;
    
    final deltaIndex = deltaPixels / state.pixelsPerCandle;
    final newStart = (state.viewportStart - deltaIndex)
        .clamp(0.0, state.data.length - 1.0);
    
    if (newStart != state.viewportStart) {
      state = state.copyWith(viewportStart: newStart);
      _recalcYScale();
    }
  }

  /// Zoom the chart at a focal point
  void zoom(double focalPixelX, double scale) {
    if (state.data.isEmpty) return;
    
    final focalIndex = state.viewportStart + focalPixelX / state.pixelsPerCandle;
    final newPixels = (state.pixelsPerCandle * scale).clamp(1.0, 50.0);
    
    if (newPixels != state.pixelsPerCandle) {
      final newStart = focalIndex - focalPixelX / newPixels;
      state = state.copyWith(
        pixelsPerCandle: newPixels,
        viewportStart: newStart.clamp(0.0, state.data.length - 1.0),
      );
      _recalcYScale();
    }
  }

  /// Select a candle by index
  void selectCandle(int? index) {
    if (index != state.selectedCandleIndex) {
      state = state.copyWith(selectedCandleIndex: index);
    }
  }

  /// Set the active drawing tool
  void setActiveTool(ToolType? tool) {
    if (tool != state.activeTool) {
      state = state.copyWith(activeTool: tool);
    }
  }

  /// Add an annotation to the chart
  void addAnnotation(Annotation annotation) {
    final newAnnotations = [...state.annotations, annotation];
    state = state.copyWith(annotations: newAnnotations);
  }

  /// Update an existing annotation
  void updateAnnotation(Annotation annotation) {
    final index = state.annotations.indexWhere((a) => a.id == annotation.id);
    if (index >= 0) {
      final newAnnotations = [...state.annotations];
      newAnnotations[index] = annotation;
      state = state.copyWith(annotations: newAnnotations);
    }
  }

  /// Remove an annotation from the chart
  void removeAnnotation(String id) {
    final newAnnotations = state.annotations.where((a) => a.id != id).toList();
    state = state.copyWith(annotations: newAnnotations);
  }

  /// Recalculate the Y scale (price range) for the visible candles
  void _recalcYScale() {
    if (state.data.isEmpty) return;
    
    // Fallback: compute based on a reasonable default width if none known yet
    final defaultWidth = 800.0; // used only before widget reports actual size
    final startIdx = state.viewportStart.floor().clamp(0, state.data.length - 1);
    final endIdx = (state.viewportStart + (defaultWidth / state.pixelsPerCandle).ceil()).ceil().clamp(0, state.data.length - 1);
    
    if (startIdx > endIdx) return;
    
    double minPrice = double.infinity;
    double maxPrice = -double.infinity;
    
    for (int i = startIdx; i <= endIdx; i++) {
      final candle = state.data[i];
      if (candle.low < minPrice) minPrice = candle.low;
      if (candle.high > maxPrice) maxPrice = candle.high;
    }
    
    final padding = (maxPrice - minPrice) * 0.1;
    
    state = state.copyWith(
      topPrice: maxPrice + padding,
      bottomPrice: minPrice - padding,
    );
  }
  
  void recalcYScaleWithWidth(double width) {
    if (state.data.isEmpty) return;
    final startIdx = state.viewportStart.floor().clamp(0, state.data.length - 1);
    final endIdx = (state.viewportStart + (width / state.pixelsPerCandle).ceil()).ceil().clamp(0, state.data.length - 1);
    if (startIdx > endIdx) return;
    double minPrice = double.infinity;
    double maxPrice = -double.infinity;
    for (int i = startIdx; i <= endIdx; i++) {
      final candle = state.data[i];
      if (candle.low < minPrice) minPrice = candle.low;
      if (candle.high > maxPrice) maxPrice = candle.high;
    }
    final padding = (maxPrice - minPrice) * 0.1;
    state = state.copyWith(
      topPrice: maxPrice + padding,
      bottomPrice: minPrice - padding,
    );
  }
}

/// Provider for the chart controller
final chartControllerProvider = StateNotifierProvider<ChartController, ChartState>((ref) {
  return ChartController();
});

/// Provider to store current chart canvas size
final chartCanvasSizeProvider = StateProvider<Size?>((ref) => const Size(400, 300));

/// Provider for the transform data
final transformDataProvider = Provider<TransformData>((ref) {
  final state = ref.watch(chartControllerProvider);
  final size = ref.watch(chartCanvasSizeProvider) ?? const Size(400, 300);
  final base = state.transformData;
  return base.copyWith(height: size.height, width: size.width);
});

/// Provider for visible candles
final visibleCandlesProvider = Provider<List<Candle>>((ref) {
  final state = ref.watch(chartControllerProvider);
  final transform = ref.watch(transformDataProvider);
  
  if (state.data.isEmpty) return [];
  
  // If width is not yet available, fallback to full data
  if (transform.width <= 0) {
    return state.data;
  }
  
  final startIdx = transform.visibleStartIndex.clamp(0, state.data.length - 1);
  final endIdx = transform.visibleEndIndex.clamp(0, state.data.length - 1);
  
  if (startIdx > endIdx) return [];
  
  return state.data.sublist(startIdx, endIdx + 1);
});