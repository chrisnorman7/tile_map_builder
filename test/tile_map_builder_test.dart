import 'dart:math';

import 'package:test/test.dart';
import 'package:tile_map_builder/tile_map_builder.dart';

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

  group('tilesInRange', () {
    test('Range 0 returns only center tile', () {
      const map = TileMap(
        tiles: [
          ['a', 'b', 'c'],
          ['d', 'e', 'f'],
          ['g', 'h', 'i'],
        ],
      );

      final tiles = map.tilesInRange(const Point(1, 1), 0).toList();

      expect(tiles.length, 1);
      expect(tiles[0].point, const Point(1, 1));
      expect(tiles[0].tile, 'e');
    });

    test('Range 1 returns 3x3 grid around center', () {
      const map = TileMap(
        tiles: [
          ['a', 'b', 'c'],
          ['d', 'e', 'f'],
          ['g', 'h', 'i'],
        ],
      );

      final tiles = map.tilesInRange(const Point(1, 1), 1).toList();

      expect(tiles.length, 9);
      expect(tiles[0].point, const Point(0, 0));
      expect(tiles[0].tile, 'a');
      expect(tiles[4].point, const Point(1, 1));
      expect(tiles[4].tile, 'e');
      expect(tiles[8].point, const Point(2, 2));
      expect(tiles[8].tile, 'i');
    });

    test('Range at top-left corner', () {
      const map = TileMap(
        tiles: [
          ['a', 'b', 'c'],
          ['d', 'e', 'f'],
          ['g', 'h', 'i'],
        ],
      );

      final tiles = map.tilesInRange(const Point(0, 0), 1).toList();

      expect(tiles.length, 4);
      expect(tiles.map((final t) => t.point).toList(), [
        const Point(0, 0),
        const Point(1, 0),
        const Point(0, 1),
        const Point(1, 1),
      ]);
    });

    test('Range at bottom-right corner', () {
      const map = TileMap(
        tiles: [
          ['a', 'b', 'c'],
          ['d', 'e', 'f'],
          ['g', 'h', 'i'],
        ],
      );

      final tiles = map.tilesInRange(const Point(2, 2), 1).toList();

      expect(tiles.length, 4);
      expect(tiles.map((final t) => t.point).toList(), [
        const Point(1, 1),
        const Point(2, 1),
        const Point(1, 2),
        const Point(2, 2),
      ]);
    });

    test('Range larger than map', () {
      const map = TileMap(
        tiles: [
          ['a', 'b'],
          ['c', 'd'],
        ],
      );

      final tiles = map.tilesInRange(const Point(0, 0), 5).toList();

      expect(tiles.length, 4);
      expect(tiles.map((final t) => t.tile).toList(), ['a', 'b', 'c', 'd']);
    });

    test('Point outside map bounds', () {
      const map = TileMap(
        tiles: [
          ['a', 'b'],
          ['c', 'd'],
        ],
      );

      final tiles = map.tilesInRange(const Point(-1, -1), 1).toList();

      expect(tiles.length, 1);
      expect(tiles[0].point, const Point(0, 0));
      expect(tiles[0].tile, 'a');
    });

    test('Empty map returns no tiles', () {
      const map = TileMap<String>(tiles: []);

      final tiles = map.tilesInRange(const Point(0, 0), 1).toList();

      expect(tiles.length, 0);
    });

    test('Map with empty rows', () {
      const map = TileMap<String>(tiles: [[]]);

      final tiles = map.tilesInRange(const Point(0, 0), 1).toList();

      expect(tiles.length, 0);
    });

    test('Results are ordered top-to-bottom, left-to-right', () {
      const map = TileMap(
        tiles: [
          ['1', '2', '3'],
          ['4', '5', '6'],
          ['7', '8', '9'],
        ],
      );

      final tiles = map.tilesInRange(const Point(1, 1), 1).toList();

      final expectedOrder = [
        const Point(0, 0),
        const Point(1, 0),
        const Point(2, 0),
        const Point(0, 1),
        const Point(1, 1),
        const Point(2, 1),
        const Point(0, 2),
        const Point(1, 2),
        const Point(2, 2),
      ];

      expect(tiles.map((final t) => t.point).toList(), expectedOrder);
    });

    test('Large range value', () {
      const map = TileMap(
        tiles: [
          ['a', 'b'],
          ['c', 'd'],
        ],
      );

      final tiles = map.tilesInRange(const Point(0, 0), 100).toList();

      expect(tiles.length, 4);
    });

    test('Range 2 with 5x5 map', () {
      const map = TileMap(
        tiles: [
          ['a', 'b', 'c', 'd', 'e'],
          ['f', 'g', 'h', 'i', 'j'],
          ['k', 'l', 'm', 'n', 'o'],
          ['p', 'q', 'r', 's', 't'],
          ['u', 'v', 'w', 'x', 'y'],
        ],
      );

      final tiles = map.tilesInRange(const Point(2, 2), 2).toList();

      expect(tiles.length, 25); // All tiles in 5x5 map
      expect(tiles.first.tile, 'a');
      expect(tiles.last.tile, 'y');
    });
  });
}
