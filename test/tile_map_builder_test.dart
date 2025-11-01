import 'dart:math';

import 'package:test/test.dart';
import 'package:tile_map_builder/src/tile_map_builder.dart';

/// Pretend terrain types.
enum TerrainType {
  water('w'),
  sand('s'),
  grass('g'),
  forest('f');

  const TerrainType(this.letter);

  /// The letter to use.
  final String letter;
}

const gameMap = '''
wwwwww
wgggsw
wsffsw
wgggsw
wwwwww
''';

void main() {
  group('Tile maps', () {
    const exclamation = 'Dart is great.';
    final builder = TileMapBuilder(
      buildTile: (final point, final letter) => letter,
      buildOverflowTile: (final point) => '\t',
    );

    test('Lines of same length', () {
      final map = builder.buildLines(['Hello', 'world']);
      expect(map.tileAt(const Point(0, 0)), 'w');
      expect(map.tileAt(const Point(1, 0)), 'o');
      expect(map.tileAt(const Point(2, 0)), 'r');
      expect(map.tileAt(const Point(3, 0)), 'l');
      expect(map.tileAt(const Point(4, 0)), 'd');
      expect(map.tileAt(const Point(0, 1)), 'H');
      expect(map.tileAt(const Point(1, 1)), 'e');
      expect(map.tileAt(const Point(2, 1)), 'l');
      expect(map.tileAt(const Point(3, 1)), 'l');
      expect(map.tileAt(const Point(4, 1)), 'o');
    });

    test('First line longer', () {
      final map = builder.buildLines(['Hello ', 'world']);
      expect(map.tileAt(const Point(0, 1)), 'H');
      expect(map.tileAt(const Point(1, 1)), 'e');
      expect(map.tileAt(const Point(2, 1)), 'l');
      expect(map.tileAt(const Point(3, 1)), 'l');
      expect(map.tileAt(const Point(4, 1)), 'o');
      expect(map.tileAt(const Point(5, 1)), ' ');
      expect(map.tileAt(const Point(0, 0)), 'w');
      expect(map.tileAt(const Point(1, 0)), 'o');
      expect(map.tileAt(const Point(2, 0)), 'r');
      expect(map.tileAt(const Point(3, 0)), 'l');
      expect(map.tileAt(const Point(4, 0)), 'd');
      expect(map.tileAt(const Point(5, 0)), '\t');
    });

    test('Second line longer', () {
      final map = builder.buildLines(['Hello', 'world.']);
      expect(map.tileAt(const Point(0, 0)), 'w');
      expect(map.tileAt(const Point(1, 0)), 'o');
      expect(map.tileAt(const Point(2, 0)), 'r');
      expect(map.tileAt(const Point(3, 0)), 'l');
      expect(map.tileAt(const Point(4, 0)), 'd');
      expect(map.tileAt(const Point(5, 0)), '.');
      expect(map.tileAt(const Point(0, 1)), 'H');
      expect(map.tileAt(const Point(1, 1)), 'e');
      expect(map.tileAt(const Point(2, 1)), 'l');
      expect(map.tileAt(const Point(3, 1)), 'l');
      expect(map.tileAt(const Point(4, 1)), 'o');
      expect(map.tileAt(const Point(5, 1)), '\t');
    });

    test('With line endings', () {
      final map = builder.buildLines(['Hello\n\r\n', 'world.\n\r\n']);
      expect(map.tileAt(const Point(0, 0)), 'w');
      expect(map.tileAt(const Point(1, 0)), 'o');
      expect(map.tileAt(const Point(2, 0)), 'r');
      expect(map.tileAt(const Point(3, 0)), 'l');
      expect(map.tileAt(const Point(4, 0)), 'd');
      expect(map.tileAt(const Point(5, 0)), '.');
      expect(map.tileAt(const Point(6, 0)), null);
      expect(map.tileAt(const Point(0, 1)), 'H');
      expect(map.tileAt(const Point(1, 1)), 'e');
      expect(map.tileAt(const Point(2, 1)), 'l');
      expect(map.tileAt(const Point(3, 1)), 'l');
      expect(map.tileAt(const Point(4, 1)), 'o');
      expect(map.tileAt(const Point(5, 1)), '\t');
      expect(map.tileAt(const Point(6, 1)), null);
    });

    test('Ensure .size is correct', () {
      final map = builder.buildLines([exclamation, 'Yes it is!']);
      expect(map.width, exclamation.length);
      expect(map.height, 2);
    });

    test('Map size with comments', () {
      final map = builder.buildLines([
        '# This is a comment.',
        exclamation,
        'Yes.',
        '# Another comment.',
      ]);
      expect(map.width, exclamation.length);
      expect(map.height, 2);
    });

    test('.findFirst', () {
      final map = builder.buildLines(['Elephant']);
      final result = map.firstWhere((final tile) => tile == 'l');
      if (result == null) {
        throw StateError('Could not find tile.');
      }
      expect(result.point, const Point(1, 0));
      expect(result.tile, 'l');
    });

    test('.where', () {
      final map = builder.buildLines(['Elephants are not', 'zebras.']);
      final a = map.where((final tile) => tile == 'a').toList();
      expect(a.length, 3);
      expect(a[0].point, const Point(4, 0));
      expect(a[1].point, const Point(5, 1));
      expect(a[2].point, const Point(10, 1));
    });

    test('.tilesInRange', () {
      final builder = TileMapBuilder(
        buildTile: (final point, final letter) =>
            TerrainType.values.firstWhere((final t) => t.letter == letter),
        buildOverflowTile: (final point) => TerrainType.forest,
      );
      final map = builder.buildLines(gameMap.split('\n'));
      const center = Point<int>(2, 2);
      final tiles = map.tilesInRange(center, 1);
      expect(tiles.length, 9);
      final first = tiles.first;
      expect(first.point, const Point(1, 1));
      expect(first.tile, TerrainType.grass);
      final last = tiles.last;
      expect(last.point, const Point(3, 3));
      expect(last.tile, TerrainType.grass);
    });

    test('Repeats', () {
      final map = builder.buildLines([
        'I know a song that will get on your nerves',
        ':2:Get on your nerves.',
      ]);
      expect(map.height, 3);
    });

    test('Pad character', () {
      final map = builder.buildLines([';;Hello', ';;;;;;;;;;world']);
      expect(map.width, 5);
      expect(map.tileAt(const Point(0, 0)), 'w');
      expect(map.tileAt(const Point(0, 1)), 'H');
    });
  });
}
