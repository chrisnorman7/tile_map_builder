import 'dart:math';

import 'package:test/test.dart';
import 'package:tile_map_builder/src/tile_map_builder.dart';

void main() {
  group('Tile maps', () {
    final builder = TileMapBuilder(
      buildTile: (final point, final letter) => letter,
      buildPadTile: (final point) => '\t',
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
  });
}
