import 'dart:math';

import 'package:characters/characters.dart';
import 'package:tile_map_builder/tile_map_builder.dart';

/// A class which allows building tile maps from text files.
class TileMapBuilder<T> {
  /// Create an instance.
  const TileMapBuilder({
    required this.buildTile,
    required this.buildOverflowTile,
    this.padCharacter = ';',
    this.commentCharacter = '#',
    this.repeatStart = ':',
    this.repeatEnd = ':',
  });

  /// Convert `letter` into an instance of [T].
  final T Function(Point<int> point, String letter) buildTile;

  /// The function which returns a tile to be used when the east side of the map
  /// needs to be levelled off.
  ///
  /// The point provided is the location where the overflow tile will be
  /// situated.
  final T Function(Point<int> point) buildOverflowTile;

  /// The character which starts a comment line.
  ///
  /// Lines starting with [commentCharacter] will be ignored.
  final String commentCharacter;

  /// The character which represents the start of a repeatable block.
  ///
  /// A line which starts with a repeating block indicator will be repeated the
  /// given number of times.
  final String repeatStart;

  /// The character which represents the end of a repeatable block.
  final String repeatEnd;

  /// The character which will be ignored at the start of a line to allow for
  /// visual alignment.
  ///
  /// Lines which start with 0 or more [padCharacter]s will have those
  /// characters ignored.
  final String padCharacter;

  /// Build a tile map from the given [lines].
  ///
  /// Lines will be read bottom-to-top to allow for easier visual
  /// representation.
  TileMap<T> buildLines(final List<String> lines) {
    final tiles = <List<T>>[];
    var maxLineLength = 0;
    for (var i = lines.length - 1; i >= 0; i--) {
      var line = lines[i];
      while (line.endsWith('\n') || line.endsWith('\r')) {
        line = line.substring(0, line.length - 1);
      }
      if (line.isEmpty || line.startsWith(commentCharacter)) {
        continue;
      }
      while (line.startsWith(padCharacter)) {
        line = line.substring(padCharacter.length);
      }
      final int count;
      if (line.startsWith(repeatStart)) {
        final endIndex = line.indexOf(repeatEnd, repeatStart.length);
        if (endIndex == -1) {
          throw ArgumentError('No matching $repeatEnd found on line ${i + 1}.');
        }
        final countString = line.substring(repeatStart.length, endIndex).trim();
        line = line.substring(endIndex + 1);
        final convertedCount = int.tryParse(countString);
        if (convertedCount == null) {
          throw ArgumentError(
            'Invalid repeat count on line ${i + 1}: $countString.',
          );
        }
        count = convertedCount;
      } else {
        count = 1;
      }
      for (var j = 0; j < count; j++) {
        if (line.length > maxLineLength) {
          maxLineLength = line.length;
          for (var x = 0; x < tiles.length; x++) {
            final row = tiles[x];
            while (row.length < maxLineLength) {
              final padTile = buildOverflowTile(Point<int>(row.length, x));
              row.add(padTile);
            }
          }
        }
        final row = <T>[];
        for (final character in line.characters) {
          final tile = buildTile(
            Point<int>(tiles.length, tiles.length),
            character,
          );
          row.add(tile);
        }
        while (row.length < maxLineLength) {
          final padTile = buildOverflowTile(
            Point<int>(row.length, tiles.length),
          );
          row.add(padTile);
        }
        tiles.add(row);
      }
    }
    return TileMap(tiles: tiles);
  }
}
