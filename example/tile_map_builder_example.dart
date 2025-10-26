// ignore_for_file: avoid_print

import 'dart:io';
import 'dart:math';

import 'package:tile_map_builder/src/tile_map_builder.dart';

/// The map to use.
const littleMap = '''
# Water (w) leads almost to the east edge, where forest (f) takes over.
;;;wwwwf
# The stream continues south through forest for 3 rows.
:3:fffw
# Now the forest takes over completely for 2 more rows.
:2:ffff
''';

/// The terrain types.
enum TerrainType {
  water('w'),
  forest('f');

  const TerrainType(this.letter);

  /// The letter to use.
  final String letter;
}

void main() {
  final builder = TileMapBuilder(
    buildTile: (final point, final letter) =>
        TerrainType.values.firstWhere((final t) => t.letter == letter),
    buildOverflowTile: (final point) => TerrainType.forest,
  );
  final map = builder.buildLines(littleMap.split('\n'));
  var coordinates = const Point(0, 0);
  while (true) {
    final tile = map.tileAt(coordinates);
    stdout.write('${coordinates.x}, ${coordinates.y}: ${tile!.name} ');
    final line = stdin.readLineSync();
    stdout.write('\n');
    if (line == null || line == 'q') {
      print('Goodbye.');
      break;
    } else if (line == 'l') {
      print('You are starting on ${tile.name}');
    } else if (line == 'n') {
      if (coordinates.y + 1 >= map.height) {
        print('You cannot go north.');
      } else {
        coordinates = Point(coordinates.x, coordinates.y + 1);
      }
    } else if (line == 's') {
      if (coordinates.y - 1 < 0) {
        print('You cannot go south.');
      } else {
        coordinates = Point(coordinates.x, coordinates.y - 1);
      }
    } else if (line == 'e') {
      if (coordinates.x + 1 >= map.width) {
        print('You cannot go east.');
      } else {
        coordinates = Point(coordinates.x + 1, coordinates.y);
      }
    } else if (line == 'w') {
      if (coordinates.x - 1 < 0) {
        print('You cannot go west.');
      } else {
        coordinates = Point(coordinates.x - 1, coordinates.y);
      }
    } else {
      print('Unrecognised command: $line.');
    }
  }
}
