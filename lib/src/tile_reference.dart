import 'dart:math';

/// A reference to [tile] at [point] in a tile map.
class TileReference<T> {
  /// Create an instance.
  const TileReference({required this.tile, required this.point});

  /// The tile at this position.
  final T tile;

  /// The position of [tile].
  final Point<int> point;
}
