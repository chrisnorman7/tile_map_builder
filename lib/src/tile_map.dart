import 'dart:math';

/// A class which holds tiles.
class TileMap<T> {
  /// Create an instance.
  const TileMap({required final List<List<T>> tiles}) : _tiles = tiles;

  /// The tiles in this map.
  final List<List<T>> _tiles;

  /// Get the tile which resides at [point].
  T? tileAt(final Point<int> point) {
    if (point.y < 0 || point.y >= _tiles.length) {
      return null;
    }
    final row = _tiles[point.y];
    if (point.x < 0 || point.x >= row.length) {
      return null;
    }
    return row[point.x];
  }
}
