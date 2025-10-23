import 'package:flutter/foundation.dart';

/// Types of drawing tools available
enum ToolType {
  trendline,
  horizontal,
  fibonacci,
}

/// Represents an anchor point for a drawing tool
class Anchor {
  /// The index position (can be fractional)
  final double index;
  
  /// The price at this anchor
  final double price;
  
  const Anchor({
    required this.index,
    required this.price,
  });
  
  Map<String, dynamic> toMap() => {
    'index': index,
    'price': price,
  };
  
  factory Anchor.fromMap(Map<String, dynamic> map) => Anchor(
    index: map['index']?.toDouble() ?? 0.0,
    price: map['price']?.toDouble() ?? 0.0,
  );
  
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Anchor && other.index == index && other.price == price;
  }
  
  @override
  int get hashCode => Object.hash(index, price);
}

/// Represents a drawing annotation on the chart
class Annotation {
  /// Unique identifier for the annotation
  final String id;
  
  /// Type of drawing tool
  final ToolType type;
  
  /// List of anchor points for the drawing
  final List<Anchor> anchors;
  
  /// Whether the annotation is visible
  final bool visible;
  
  /// Color of the annotation (as ARGB int)
  final int color;
  
  /// Line width of the annotation
  final double lineWidth;
  
  const Annotation({
    required this.id,
    required this.type,
    required this.anchors,
    this.visible = true,
    this.color = 0xFF000000, // Default black
    this.lineWidth = 1.0,
  });
  
  Map<String, dynamic> toMap() => {
    'id': id,
    'type': type.index,
    'anchors': anchors.map((a) => a.toMap()).toList(),
    'visible': visible,
    'color': color,
    'lineWidth': lineWidth,
  };
  
  factory Annotation.fromMap(Map<String, dynamic> map) => Annotation(
    id: map['id'] ?? '',
    type: ToolType.values[map['type'] ?? 0],
    anchors: List<Map<String, dynamic>>.from(map['anchors'] ?? [])
        .map((m) => Anchor.fromMap(m))
        .toList(),
    visible: map['visible'] ?? true,
    color: map['color'] ?? 0xFF000000,
    lineWidth: map['lineWidth']?.toDouble() ?? 1.0,
  );
  
  /// Create a copy of this Annotation with some fields replaced
  Annotation copyWith({
    String? id,
    ToolType? type,
    List<Anchor>? anchors,
    bool? visible,
    int? color,
    double? lineWidth,
  }) {
    return Annotation(
      id: id ?? this.id,
      type: type ?? this.type,
      anchors: anchors ?? this.anchors,
      visible: visible ?? this.visible,
      color: color ?? this.color,
      lineWidth: lineWidth ?? this.lineWidth,
    );
  }
  
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Annotation &&
        other.id == id &&
        other.type == type &&
        listEquals(other.anchors, anchors) &&
        other.visible == visible &&
        other.color == color &&
        other.lineWidth == lineWidth;
  }
  
  @override
  int get hashCode => Object.hash(
        id,
        type,
        Object.hashAll(anchors),
        visible,
        color,
        lineWidth,
      );
}