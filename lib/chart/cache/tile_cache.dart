import 'dart:ui' as ui;

/// Represents a key for a tile in the cache
class TileKey {
  final int start;
  final int end;
  final double pixelsPerCandle;
  
  const TileKey({
    required this.start,
    required this.end,
    required this.pixelsPerCandle,
  });
  
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is TileKey &&
        other.start == start &&
        other.end == end &&
        other.pixelsPerCandle == pixelsPerCandle;
  }
  
  @override
  int get hashCode => Object.hash(start, end, pixelsPerCandle);
}

/// A cache for storing rendered tiles
class TileCache {
  // Singleton instance
  static final TileCache instance = TileCache._();
  
  // Private constructor
  TileCache._();
  
  // Cache of rendered tiles
  final Map<TileKey, ui.Picture> _cache = {};
  
  // Maximum number of tiles to keep in cache
  final int maxCacheSize = 50;
  
  // Recently used keys for LRU eviction
  final List<TileKey> _recentlyUsed = [];
  
  /// Get a tile from the cache
  ui.Picture? get(TileKey key) {
    final picture = _cache[key];
    
    if (picture != null) {
      // Update recently used
      _recentlyUsed.remove(key);
      _recentlyUsed.add(key);
    }
    
    return picture;
  }
  
  /// Put a tile in the cache
  void put(TileKey key, ui.Picture picture) {
    // Evict least recently used if cache is full
    if (_cache.length >= maxCacheSize && !_cache.containsKey(key)) {
      _evictLRU();
    }
    
    _cache[key] = picture;
    
    // Update recently used
    _recentlyUsed.remove(key);
    _recentlyUsed.add(key);
  }
  
  /// Clear the cache
  void clear() {
    _cache.clear();
    _recentlyUsed.clear();
  }
  
  /// Evict least recently used tile
  void _evictLRU() {
    if (_recentlyUsed.isNotEmpty) {
      final key = _recentlyUsed.removeAt(0);
      _cache.remove(key);
    }
  }
  
  /// Compute tile keys for the current viewport
  List<TileKey> computeTileKeys(int visibleStartIndex, int visibleEndIndex, double pixelsPerCandle, int tileSize) {
    final keys = <TileKey>[];
    
    // Round to tile boundaries
    final startTile = (visibleStartIndex / tileSize).floor() * tileSize;
    final endTile = ((visibleEndIndex / tileSize).ceil() * tileSize) - 1;
    
    // Create keys for each tile
    for (int start = startTile; start <= endTile; start += tileSize) {
      final end = start + tileSize - 1;
      keys.add(TileKey(
        start: start,
        end: end,
        pixelsPerCandle: pixelsPerCandle,
      ));
    }
    
    return keys;
  }
}