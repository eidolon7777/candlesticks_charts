import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../chart/controller/chart_controller.dart';
import '../../chart/render/grid_painter.dart';
import '../../chart/render/candle_painter.dart';
import '../../chart/render/annotation_painter.dart';
import '../../chart/gesture/chart_gesture_detector.dart';
import '../../core/models/annotation.dart';
import '../../chart/render/crosshair_painter.dart';
import '../../core/models/candle.dart';

/// The main chart widget that composes all the chart components
class ChartWidget extends ConsumerWidget {
  final String symbol;
  final double height;
  final double width;
  
  const ChartWidget({
    required this.symbol,
    this.height = 400,
    this.width = double.infinity,
    super.key,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Watch minimal state slices to avoid rebuilds
    final transform = ref.watch(transformDataProvider);
    final visibleData = ref.watch(visibleCandlesProvider);
    final annotations = ref.watch(chartControllerProvider).annotations;
    
    return SizedBox(
      height: height,
      width: width,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final controller = ref.read(chartControllerProvider.notifier);
          final size = Size(constraints.maxWidth, constraints.maxHeight);
          
          // Update size and Y-scale after build is complete to avoid state update during build
          SchedulerBinding.instance.addPostFrameCallback((_) {
            ref.read(chartCanvasSizeProvider.notifier).state = size;
            controller.recalcYScaleWithWidth(size.width);
          });
          
          return ChartGestureDetector(
            child: Stack(
              children: [
                // Grid layer
                CustomPaint(
                  size: Size.infinite,
                  painter: GridPainter(transform: transform),
                ),
                
                // Candle layer
                CustomPaint(
                  size: Size.infinite,
                  painter: CandlePainter(
                    transform: transform,
                    data: visibleData,
                  ),
                ),
                
                // Annotation layer
            CustomPaint(
              size: Size.infinite,
              painter: AnnotationPainter(
                transform: transform,
                annotations: annotations,
              ),
            ),

            // Crosshair overlay (dashed lines on selected candle)
            CustomPaint(
              size: Size.infinite,
              painter: CrosshairPainter(
                transform: transform,
                candle: _selectedCandle(ref),
                selectedIndex: ref.watch(chartControllerProvider.select((s) => s.selectedCandleIndex)),
              ),
            ),
            
            // Toolbar overlay
            Positioned(
              top: 8,
              right: 8,
              child: _buildToolbar(ref),
            ),
                
                // Info overlay
                // Removed to use the separate UI component instead
              ],
            ),
          );
        },
      ),
    );
  }
  
  Widget _buildToolbar(WidgetRef ref) {
    final controller = ref.read(chartControllerProvider.notifier);
    final activeTool = ref.watch(chartControllerProvider.select((s) => s.activeTool));
    
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Row(
          children: [
            IconButton(
              icon: Icon(
                Icons.show_chart,
                color: activeTool == ToolType.trendline ? Colors.blue : Colors.grey,
              ),
              onPressed: () => controller.setActiveTool(
                activeTool == ToolType.trendline ? null : ToolType.trendline,
              ),
            ),
            IconButton(
              icon: Icon(
                Icons.horizontal_rule,
                color: activeTool == ToolType.horizontal ? Colors.blue : Colors.grey,
              ),
              onPressed: () => controller.setActiveTool(
                activeTool == ToolType.horizontal ? null : ToolType.horizontal,
              ),
            ),
            IconButton(
              icon: Icon(
                Icons.stacked_line_chart,
                color: activeTool == ToolType.fibonacci ? Colors.blue : Colors.grey,
              ),
              onPressed: () => controller.setActiveTool(
                activeTool == ToolType.fibonacci ? null : ToolType.fibonacci,
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  // Widget _buildInfoOverlay(WidgetRef ref) {
  //   final selectedIndex = ref.watch(chartControllerProvider.select((s) => s.selectedCandleIndex));
  //   final data = ref.watch(chartControllerProvider.select((s) => s.data));
    
  //   if (selectedIndex == null || selectedIndex < 0 || selectedIndex >= data.length) {
  //     return const SizedBox.shrink();
  //   }
    
  //   final candle = data[selectedIndex];
    
  //   return Card(
  //     elevation: 4,
  //     child: Padding(
  //       padding: const EdgeInsets.all(8.0),
  //       child: Column(
  //         crossAxisAlignment: CrossAxisAlignment.start,
  //         children: [
  //           Text('Date: ${candle.time.toString().substring(0, 16)}'),
  //           Text('Open: ${candle.open.toStringAsFixed(2)}'),
  //           Text('High: ${candle.high.toStringAsFixed(2)}'),
  //           Text('Low: ${candle.low.toStringAsFixed(2)}'),
  //           Text('Close: ${candle.close.toStringAsFixed(2)}'),
  //           Text('Volume: ${candle.volume.toStringAsFixed(0)}'),
  //         ],
  //       ),
  //     ),
  //   );
  // }

  Candle? _selectedCandle(WidgetRef ref) {
    final idx = ref.watch(chartControllerProvider.select((s) => s.selectedCandleIndex));
    final data = ref.watch(chartControllerProvider.select((s) => s.data));
    if (idx == null || idx < 0 || idx >= data.length) return null;
    return data[idx];
  }
}