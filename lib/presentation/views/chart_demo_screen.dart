import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../chart/controller/chart_controller.dart';
import '../../core/models/candle.dart';
import '../widgets/chart_widget.dart';

class ChartDemoScreen extends ConsumerStatefulWidget {
  const ChartDemoScreen({super.key});

  @override
  ConsumerState<ChartDemoScreen> createState() => _ChartDemoScreenState();
}

class _ChartDemoScreenState extends ConsumerState<ChartDemoScreen> {
  @override
  void initState() {
    super.initState();
    // Load sample data when the screen initializes
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadSampleData();
    });
  }

  void _loadSampleData() {
    final controller = ref.read(chartControllerProvider.notifier);
    
    // Generate sample data with extremely pronounced price movements
    final now = DateTime.now();
    final sampleData = List.generate(30, (index) {
      final date = now.subtract(Duration(days: 30 - index));
      
      // Create very dramatic price movements for better visibility
      final basePrice = 100.0 + (index * 2.0);
      
      // Create a clear pattern of bullish and bearish candles with much larger bodies
      final isUpDay = index % 2 == 0;
      final open = isUpDay ? basePrice - 8.0 : basePrice + 8.0;
      final close = isUpDay ? basePrice + 12.0 : basePrice - 12.0;
      
      // Add extremely pronounced wicks
      final high = (open > close ? open : close) + (15.0 + (index % 5) * 3.0);
      final low = (open < close ? open : close) - (15.0 + (index % 4) * 3.0);
      final volume = 5000.0 + (index % 5) * 2000.0;
      
      return Candle(
        time: date,
        open: open,
        high: high,
        low: low,
        close: close,
        volume: volume,
      );
    });
    
    // Load data into the controller
    controller.loadData(sampleData);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Custom Candlestick Chart'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadSampleData,
          ),
        ],
      ),
      body: Column(
        children: [
          // Candle Data Panel
          _buildCandleDataPanel(),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: ChartWidget(symbol: 'DEMO'),
            ),
          ),
          _buildControls(),
        ],
      ),
    );
  }
  
  Widget _buildCandleDataPanel() {
    final selectedIndex = ref.watch(chartControllerProvider.select((s) => s.selectedCandleIndex));
    final data = ref.watch(chartControllerProvider.select((s) => s.data));
    
    if (selectedIndex == null || data.isEmpty || selectedIndex < 0 || selectedIndex >= data.length) {
      return Container(
        padding: const EdgeInsets.all(12.0),
        color: Colors.grey[200],
        width: double.infinity,
        child: const Text('Select a candle to view details', 
          style: TextStyle(fontStyle: FontStyle.italic)),
      );
    }
    
    final candle = data[selectedIndex];
    final bullish = candle.close > candle.open;
    
    return Container(
      padding: const EdgeInsets.all(12.0),
      color: Colors.grey[200],
      width: double.infinity,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text('Date: ${candle.time.toString().substring(0, 16)}', 
              style: const TextStyle(fontWeight: FontWeight.bold)),
          Row(
            children: [
              Text('O: ${candle.open.toStringAsFixed(2)} '),
              Text('H: ${candle.high.toStringAsFixed(2)} '),
              Text('L: ${candle.low.toStringAsFixed(2)} '),
              Text('C: ${candle.close.toStringAsFixed(2)}',
                  style: TextStyle(
                    color: bullish ? Colors.green : Colors.red,
                    fontWeight: FontWeight.bold
                  )),
            ],
          ),
          Text('Vol: ${candle.volume.toStringAsFixed(0)}'),
        ],
      ),
    );
  }

  Widget _buildControls() {
    final controller = ref.read(chartControllerProvider.notifier);
    
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          Text(
            'Chart Controls',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              ElevatedButton(
                onPressed: () {
                  controller.zoom(MediaQuery.of(context).size.width / 2, 1.2);
                },
                child: const Text('Zoom In'),
              ),
              ElevatedButton(
                onPressed: () {
                  controller.zoom(MediaQuery.of(context).size.width / 2, 0.8);
                },
                child: const Text('Zoom Out'),
              ),
              ElevatedButton(
                onPressed: () {
                  controller.pan(50); // Pan right
                },
                child: const Text('Pan Left'),
              ),
              ElevatedButton(
                onPressed: () {
                  controller.pan(-50); // Pan left
                },
                child: const Text('Pan Right'),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            'Gesture Instructions:',
            style: Theme.of(context).textTheme.titleSmall,
          ),
          const Text('• Drag horizontally to pan the chart'),
          const Text('• Pinch to zoom in/out'),
          const Text('• Tap to select a candle'),
          const Text('• Double-tap to reset zoom'),
          const Text('• Use toolbar to activate drawing tools'),
        ],
      ),
    );
  }
}