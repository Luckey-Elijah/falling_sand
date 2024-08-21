import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';

void main() => runApp(const App());

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: Material(
        child: FallingSand(),
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
        var color = state[col][row];
        if (color != null) {
          var canMoveDown = row + 1 < cellCount && state[col][row + 1] == null;
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

  var cellCount = 50;
  late var state = emptyState(cellCount);

  static List<List<Color?>> emptyState(int size) =>
      List.generate(size, (i) => List.generate(size, (j) => null));

  final size = const Size.square(1000);

  late var cellSize = Size(
    size.width / cellCount,
    size.height / cellCount,
  );

  Color? color = Colors.black;

  void positionToCellUpdate(Offset offset) {
    var x = max(0, offset.dx) ~/ cellSize.width;
    var y = max(0, offset.dy) ~/ cellSize.height;

    x = min(x, cellCount - 1);
    y = min(y, cellCount - 1);

    if (state[x][y] != null) return;

    setState(() => state[x][y] = color);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Padding(
          padding: const EdgeInsets.all(8.0),
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

class FallingSandPainter extends CustomPainter {
  FallingSandPainter(this.state);
  final List<List<Color?>> state;
  var paintBrush = Paint();

  @override
  void paint(Canvas canvas, Size size) {
    var width = state.length;
    var height = state[0].length;
    var divisionX = size.width / width;
    var divisionY = size.height / height;

    // add 1 to account for ghost lines
    final cellSize = Size(divisionX + 1, divisionY + 1);

    for (var col = 0; col < width; col++) {
      for (var row = 0; row < height; row++) {
        var color = state[col][row];
        if (color != null) {
          var rect = Offset(col * divisionX, row * divisionY) & cellSize;

          canvas.drawRect(rect, paintBrush..color = color);
        }
      }
    }
  }

  @override
  bool shouldRepaint(FallingSandPainter oldDelegate) {
    return true;
  }
}
