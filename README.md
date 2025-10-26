# Tile Map Builder

## Description

This package is my answer to the question "Can I make maps easier?" It lets you convert text files into maps, by using individual characters to represent tile types.

## Map Composition

Maps can be composed of any symbols which you can type on a keyboard. The only exceptions are the values of `TileMapBuilder.padCharacter`, `TileMapBuilder.commentCharacter`, `TileMapBuilder.repeatStart`, and `TileMapBuilder.repeatEnd`.

Consider the following very small map:

```text
wwwwf
fffwf
fffwf
fffff
fffff
```

It is quite hard to know what this map does. Luckily, the package lets you use comments, which are configurable via the `TileMapBuilder.commentCharacter` property. Let's rewrite the above map with comments:

```text
# Water (w) leads almost to the east edge, where forest (f) takes over.
wwwwf
# The stream continues south through forest.
fffwf
# The stream continues south through more forest.
fffwf
# Now the forest takes over completely.
fffff
# And one more row of forest.
fffff
```

Now that's easier. What about if we want to expand the stream southwards? We could copy and paste the lines, but we can do better.

```text
# Water (w) leads almost to the east edge, where forest (f) takes over.
wwwwf
# The stream continues south through forest for 3 rows.
:3:fffwf
# Now the forest takes over completely for 2 more rows.
:2:fffff
```

That is better, but now the rows are no longer visually aligned. Let's pad them:

```text
# Water (w) leads almost to the east edge, where forest (f) takes over.
;;;wwwwf
# The stream continues south through forest for 3 rows.
:3:fffwf
# Now the forest takes over completely for 2 more rows.
:2:fffff
```

Finally, we have an easy-to-read, concise map. Just one more thing: The east side of the map is all forest. Why write that in all the time? This is where `TileMapBuilder.buildOverflowTile` comes into its own.

When building the map, the system finds the longest "row". Any row which is shorter than this will get expanded out, using the `TileMapBuilder.buildOverflowTile` function to create an appropriate tile.

Using this system, we have this final version of the map:

```text
# Water (w) leads almost to the east edge, where forest (f) takes over.
;;;wwwwf
# The stream continues south through forest for 3 rows.
:3:fffw
# Now the forest takes over completely for 2 more rows.
:2:ffff
```

## Using Maps

This package gives you the ability to parse maps. What you do with them is completely up to you. Consider this minimal example which uses the above map and is contained in `example/tile_map_example.dart`:

```dart
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
```
