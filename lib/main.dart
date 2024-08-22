import 'dart:math';

import 'package:falling_sand/components.dart';
import 'package:falling_sand/connection_widget.dart';
import 'package:falling_sand/sandbox.dart';
import 'package:falling_sand/tetromino_data.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:pocketbase/pocketbase.dart';

void main() => runApp(const App());

final creation = ValueNotifier(_FallingSandState.emptyState(50));

final pb = PocketBase('https://falling-san.pockethost.io');

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        body: ConnectionWidget(
          child: Material(
            child: FallingSand(),
          ),
        ),
      ),
    );
  }
}

const unselectedIconColor = Colors.black26;

enum EditAction { fall, erase, tetromino }

enum CursorSize { small, medium, big }

class FallingSand extends StatefulWidget {
  const FallingSand({super.key});

  @override
  State<FallingSand> createState() => _FallingSandState();
}

class _FallingSandState extends State<FallingSand>
    with TickerProviderStateMixin {
  late final rng = Random();
  late Ticker ticker;
  bool canMakeAction = false;
  EditAction action = EditAction.fall;
  CursorSize cursorSize = CursorSize.small;

  @override
  void initState() {
    super.initState();
    ticker = createTicker(tick)..start();
  }

  @override
  void dispose() {
    ticker.dispose();
    super.dispose();
  }

  Size buildCellSize() {
    return Size(
      size.width / cellCount,
      size.height / cellCount,
    );
  }

  void tick(Duration duration) {
    for (var col = 0; col < cellCount; col++) {
      for (var row = cellCount - 1; row >= 0; row--) {
        final color = state[col][row];
        if (color != null) {
          final canMoveDown =
              row + 1 < cellCount && state[col][row + 1] == null;
          if (canMoveDown) {
            setState(() {
              state[col][row + 1] = color;
              state[col][row] = null;
            });
          }
        }
      }
    }
  }

  int cellCount = 50;

  List<List<Color?>> get state => creation.value;
  set state(List<List<Color?>> val) => creation.value = val;

  static List<List<Color?>> emptyState(int size) =>
      List.generate(size, (i) => List.generate(size, (j) => null));

  final size = const Size.square(1000);

  late Size cellSize = Size(
    size.width / cellCount,
    size.height / cellCount,
  );

  Color? color = Colors.black;

  bool tetrominoEnabled = false;

  void applyEraser(int x, int y) {
    switch (cursorSize) {
      case CursorSize.small:
        // 1x1 square
        setState(() => state[x][y] = null);

      case CursorSize.medium:
        // 2x2 square and the top left corner is the mouse position
        setState(() {
          state[x][y] = null;

          if (state.length > x + 1) {
            state[x + 1][y] = null;
          }
          if (state[x].length > y + 1) {
            state[x][y + 1] = null;
          }
          if (state.length > x + 1 && state[x + 1].length > y + 1) {
            state[x + 1][y + 1] = null;
          }
        });

      case CursorSize.big:
        // 3x3 square and the center is the mouse position
        setState(() {
          // row above the mouse
          if (x - 1 >= 0 && y - 1 >= 0) {
            state[x - 1][y - 1] = null;
          }
          if (y - 1 >= 0) {
            state[x][y - 1] = null;
          }
          if (state.length > x + 1 && y - 1 >= 0) {
            state[x + 1][y - 1] = null;
          }

          // row at the same level than the mouse

          if (x - 1 >= 0) {
            state[x - 1][y] = null;
          }

          state[x][y] = null;

          if (state.length > x + 1) {
            state[x + 1][y] = null;
          }

          // row under the mouse

          if (x - 1 >= 0 && state[x - 1].length > y + 1) {
            state[x - 1][y + 1] = null;
          }

          if (state[x].length > y + 1) {
            state[x][y + 1] = null;
          }

          if (state.length > x + 1 && state[x + 1].length > y + 1) {
            state[x + 1][y + 1] = null;
          }
        });
    }
  }

  void applyPen(int x, int y, Color? value) {
    switch (cursorSize) {
      case CursorSize.small:
        // 1x1 square
        setState(() => state[x][y] = value);

      case CursorSize.medium:
        // 2x2 square and the top left corner is the mouse position
        setState(() {
          state[x][y] = value;

          if (state.length > x + 1 && state[x + 1][y] == null) {
            state[x + 1][y] = value;
          }
          if (state[x].length > y + 1 && state[x][y + 1] == null) {
            state[x][y + 1] = value;
          }
          if (state.length > x + 1 &&
              state[x + 1].length > y + 1 &&
              state[x + 1][y + 1] == null) {
            state[x + 1][y + 1] = value;
          }
        });

      case CursorSize.big:
        // 3x3 square and the center is the mouse position
        setState(() {
          // row above the mouse
          if (x - 1 >= 0 && y - 1 >= 0 && state[x - 1][y - 1] == null) {
            state[x - 1][y - 1] = value;
          }
          if (y - 1 >= 0 && state[x][y - 1] == null) {
            state[x][y - 1] = value;
          }
          if (state.length > x + 1 &&
              y - 1 >= 0 &&
              state[x + 1][y - 1] == null) {
            state[x + 1][y - 1] = value;
          }

          // row at the same level than the mouse

          if (x - 1 >= 0 && state[x - 1][y] == null) {
            state[x - 1][y] = value;
          }

          state[x][y] = value;

          if (state.length > x + 1 && state[x + 1][y] == null) {
            state[x + 1][y] = value;
          }

          // row under the mouse

          if (x - 1 >= 0 &&
              state[x - 1].length > y + 1 &&
              state[x - 1][y + 1] == null) {
            state[x - 1][y + 1] = value;
          }

          if (state[x].length > y + 1 && state[x][y + 1] == null) {
            state[x][y + 1] = value;
          }

          if (state.length > x + 1 &&
              state[x + 1].length > y + 1 &&
              state[x + 1][y + 1] == null) {
            state[x + 1][y + 1] = value;
          }
        });
    }
  }

  void positionToCellUpdate(Offset offset) {
    if (!canMakeAction) {
      return;
    }

    var x = max(0, offset.dx) ~/ cellSize.width;
    var y = max(0, offset.dy) ~/ cellSize.height;

    if (action != EditAction.tetromino) {
      x = min(x, cellCount - 1);
      y = min(y, cellCount - 1);

      if (action == EditAction.erase) {
        applyEraser(x, y);
        return;
      }

      applyPen(x, y, color);

      return;
    }

    final tetrominoIndex = rng.nextInt(tetromino.length);

    for (final (i, shape) in tetromino[tetrominoIndex].indexed) {
      for (final (j, pixel) in shape.indexed) {
        if (!pixel) return;

        x = min(x + j, cellCount - 1);
        y = min(y + i, cellCount - 1);

        if (state[x][y] != null) continue;

        state[x][y] = color;
      }
    }

    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Padding(
          padding: const EdgeInsets.all(8),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              DecoratedBox(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(),
                ),
                child: Row(
                  children: [
                    IconButton(
                      tooltip: 'Some Pixels',
                      icon: const Icon(Icons.density_large),
                      onPressed: () => setState(() {
                        cellCount = 50;
                        state = emptyState(cellCount);
                        cellSize = buildCellSize();
                      }),
                    ),
                    IconButton(
                      icon: const Icon(Icons.density_medium),
                      tooltip: 'More Pixels',
                      onPressed: () => setState(() {
                        cellCount = 250;
                        state = emptyState(cellCount);
                        cellSize = buildCellSize();
                      }),
                    ),
                    IconButton(
                      tooltip: 'Most Pixels',
                      icon: const Icon(Icons.density_small),
                      onPressed: () => setState(() {
                        cellCount = 500;
                        state = emptyState(cellCount);
                        cellSize = buildCellSize();
                      }),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              CursorSizeOptions(
                onSize: (s) => setState(() => cursorSize = s),
                size: cursorSize,
                color: color,
              ),
              const SizedBox(width: 8),
              EditActionOptions(
                onAction: (a) => setState(() => action = a),
                action: action,
                color: color,
              ),
              const SizedBox(width: 8),
              IconButton.outlined(
                icon: const Icon(Icons.delete_forever),
                tooltip: 'Empty Sandbox',
                onPressed: () => setState(() => state = emptyState(cellCount)),
              ),
            ],
          ),
        ),
        ColorOptions(onColor: (c) => setState(() => color = c)),
        Sandbox(
          state: state,
          size: size,
          onPointerHover: positionToCellUpdate,
          onPointerMove: positionToCellUpdate,
          onPointerDown: (position) {
            setState(() => canMakeAction = true);
            positionToCellUpdate(position);
          },
          onPointerUp: (position) {
            setState(() => canMakeAction = false);
            positionToCellUpdate(position);
          },
        ),
      ],
    );
  }
}
