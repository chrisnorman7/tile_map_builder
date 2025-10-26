import 'dart:math';

import 'package:tile_map_builder/tile_map_builder.dart';

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

  /// Get the width of this tile map.
  int get width => _tiles.isEmpty ? 0 : _tiles[0].length;

  /// Get the height of this tile map.
  int get height => _tiles.length;

  /// Find a tile in this map which matches [test].
  TileReference<T>? firstWhere(final bool Function(T tile) test) {
    for (var y = 0; y < _tiles.length; y++) {
      final row = _tiles[y];
      for (var x = 0; x < row.length; x++) {
        final tile = row[x];
        if (test(tile)) {
          return TileReference(point: Point(x, y), tile: tile);
        }
      }
    }
    return null;
  }

  /// Return the tiles within [range] of [point].
  List<TileReference<T>> tilesInRange(final Point<int> point, final int range) {
    final foundTiles = <TileReference<T>>[];
    for (var y = point.y - range; y <= point.y + range; y++) {
      if (y < 0 || y >= height) {
        continue;
      }
      for (var x = point.x - range; x <= point.x + range; x++) {
        if (x < 0 || x >= width) {
          continue;
        }
        final point = Point(x, y);
        final tile = tileAt(point);
        if (tile != null) {
          foundTiles.add(TileReference(point: point, tile: tile));
        }
      }
    }
    return foundTiles;
  }

  /// Return all tile references which match [test].
  List<TileReference<T>> where(final bool Function(T tile) test) {
    final foundTiles = <TileReference<T>>[];
    for (var y = 0; y < _tiles.length; y++) {
      final row = _tiles[y];
      for (var x = 0; x < row.length; x++) {
        final tile = row[x];
        if (test(tile)) {
          foundTiles.add(TileReference(point: Point(x, y), tile: tile));
        }
      }
    }
    return foundTiles;
  }
}
