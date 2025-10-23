import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../controller/chart_controller.dart';

/// A widget that handles gestures for the chart
class ChartGestureDetector extends ConsumerStatefulWidget {
  final Widget child;
  
  const ChartGestureDetector({
    required this.child,
    super.key,
  });

  @override
  ConsumerState<ChartGestureDetector> createState() => _ChartGestureDetectorState();
}

class _ChartGestureDetectorState extends ConsumerState<ChartGestureDetector> {
  // Initialize fields with default values
  double _lastFocalPoint = 0.0;
  double _lastScale = 1.0;
  
  @override
  Widget build(BuildContext context) {
    final controller = ref.read(chartControllerProvider.notifier);
    
    return GestureDetector(
      // Handle tap for selection
      onTapDown: (details) {
        _handleTap(details.localPosition, ref);
      },
      
      // Double tap to reset zoom
      onDoubleTap: () {
        // Reset to default zoom level
        final s = ref.read(chartControllerProvider);
        controller.zoom(0, 1.0 / s.pixelsPerCandle * 8.0);
      },
      
      // Use scale gesture for both panning and zooming
      onScaleStart: (details) {
        _lastFocalPoint = details.localFocalPoint.dx;
        _lastScale = 1.0;
      },
      
      onScaleUpdate: (details) {
        if (details.pointerCount >= 2) {
          // Zooming with two fingers
          final delta = details.scale / _lastScale;
          controller.zoom(_lastFocalPoint, delta);
          _lastScale = details.scale;
        } else {
          // Panning with one finger
          controller.pan(details.focalPointDelta.dx);
        }
      },
      
      child: widget.child,
    );
  }
  
  // Handle tap for selection
  void _handleTap(Offset position, WidgetRef ref) {
    final controller = ref.read(chartControllerProvider.notifier);
    final transform = ref.read(transformDataProvider);
    
    // Convert tap position to index
    final index = transform.xToIndex(position.dx).round();
    
    // Check if index is valid
    final s = ref.read(chartControllerProvider);
    if (index >= 0 && index < s.data.length) {
      controller.selectCandle(index);
    }
  }
}