import 'dart:math';

import 'package:falling_sand/connection_widget.dart';
import 'package:falling_sand/falling_sand_painter.dart';
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

class FallingSand extends StatefulWidget {
  const FallingSand({super.key});

  @override
  State<FallingSand> createState() => _FallingSandState();
}

class _FallingSandState extends State<FallingSand>
    with TickerProviderStateMixin {
  late final rng = Random();
  late Ticker ticker;

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

  void positionToCellUpdate(Offset offset) {
    var x = max(0, offset.dx) ~/ cellSize.width;
    var y = max(0, offset.dy) ~/ cellSize.height;

    if (!tetrominoEnabled) {
      x = min(x, cellCount - 1);
      y = min(y, cellCount - 1);

      if (state[x][y] != null) return;

      setState(() => state[x][y] = color);

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
              for (var i = 0; i < Colors.primaries.length; i++)
                IconButton(
                  icon: const Icon(Icons.square),
                  tooltip: i < 9 ? '${i + 1}' : null,
                  color: Colors.primaries[i],
                  onPressed: () => setState(() => color = Colors.primaries[i]),
                ),
              IconButton(
                icon: const Icon(Icons.square),
                color: Colors.black,
                onPressed: () => setState(() => color = Colors.black),
              ),
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
              IconButton.outlined(
                tooltip: 'Tetromino',
                icon: SizedBox(
                  height: 20,
                  width: 25,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Expanded(
                        child: ColoredBox(
                          color:
                              tetrominoEnabled ? Colors.black : Colors.black26,
                        ),
                      ),
                      Expanded(
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            const Spacer(),
                            Expanded(
                              child: ColoredBox(
                                color: tetrominoEnabled
                                    ? Colors.black
                                    : Colors.black26,
                              ),
                            ),
                            const Spacer(),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                onPressed: () =>
                    setState(() => tetrominoEnabled = !tetrominoEnabled),
              ),
              const SizedBox(width: 8),
              IconButton.outlined(
                icon: const Icon(Icons.clear),
                onPressed: () => setState(() => state = emptyState(cellCount)),
              ),
            ],
          ),
        ),
        DecoratedBox(
          decoration: BoxDecoration(border: Border.all()),
          child: Padding(
            padding: const EdgeInsets.all(1),
            child: ConstrainedBox(
              constraints: BoxConstraints.tight(size),
              child: Listener(
                child: CustomPaint(
                  size: size,
                  painter: FallingSandPainter(state),
                ),
                onPointerHover: (event) =>
                    positionToCellUpdate(event.localPosition),
                onPointerMove: (event) =>
                    positionToCellUpdate(event.localPosition),
                onPointerDown: (event) =>
                    positionToCellUpdate(event.localPosition),
                onPointerUp: (event) =>
                    positionToCellUpdate(event.localPosition),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Size buildCellSize() {
    return Size(
      size.width / cellCount,
      size.height / cellCount,
    );
  }
}
