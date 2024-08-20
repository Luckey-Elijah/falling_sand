import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';

// https://en.wikipedia.org/wiki/Tetromino
const tetromino = [
  // t tetromino
  [
    [true, true, true],
    [false, true, false],
  ],
  // square tetromino
  [
    [true, true],
    [true, true],
  ],
  // skew tetromino
  [
    [false, true, true],
    [true, true, false],
  ],
  // straight tetromino
  [
    [true, true, true, true],
  ],
  // L-tetromino
  [
    [true, false],
    [true, false],
    [true, false],
    [true, true],
  ],
  // reverse L-tetromino
  [
    [false, true],
    [false, true],
    [true, true],
    [true, false],
  ],
  // J-tetromino
  [
    [true, false, false],
    [true, true, true],
  ],
  // reverse J-tetromino
  [
    [false, false, true],
    [true, true, true],
  ],
  // S-tetromino
  [
    [false, true, true],
    [true, true, false],
  ],
  // reverse S-tetromino
  [
    [true, true, false],
    [false, true, true],
  ],
  // Z-tetromino
  [
    [true, true, false],
    [false, true, true],
  ],
  // reverse Z-tetromino
  [
    [false, true, true],
    [true, true, false],
  ],
  // I-tetromino (vertical)
  [
    [true],
    [true],
    [true],
    [true],
  ],
  // I-tetromino (horizontal)
  [
    [true, true, true, true],
  ],
  // T-tetromino (rotated)
  [
    [false, true],
    [true, true, true],
  ],
  // T-tetromino (rotated reverse)
  [
    [true, true, true],
    [false, true],
  ],
  // L-tetromino (rotated)
  [
    [true, true],
    [true, false],
    [true, false],
  ],
  // reverse L-tetromino (rotated)
  [
    [false, true],
    [false, true],
    [true, true],
  ],
  // square tetromino (rotated)
  [
    [true, true],
    [true, true],
  ],
  // skew tetromino (rotated)
  [
    [true, true, false],
    [false, true, true],
  ],
  // reverse skew tetromino
  [
    [false, true, true],
    [true, true, false],
  ],
];

void main() => runApp(const App());

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: Material(
        child: FallingSand(
          height: 50,
          width: 50,
        ),
      ),
    );
  }
}

class FallingSand extends StatefulWidget {
  const FallingSand({super.key, required this.width, required this.height});
  final int width, height;

  @override
  State<FallingSand> createState() => _FallingSandState();
}

class _FallingSandState extends State<FallingSand>
    with SingleTickerProviderStateMixin {
  late final Ticker ticker;
  late final rng = Random();

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
    // iterate over the board and move every cell down if it is not at the bottom
    for (var col = 0; col < widget.width; col++) {
      for (var row = widget.height - 1; row >= 0; row--) {
        var value = state[col][row];
        if (value != null) {
          var canMoveDown = row + 1 < widget.height && //
              state[col][row + 1] == null;

          if (canMoveDown) {
            setState(() {
              state[col][row + 1] = value;
              state[col][row] = null;
            });
          }
        }
      }
    }
  }

  late var state = emptyState();

  List<List<Color?>> emptyState() => List.generate(
      widget.width, (i) => List.generate(widget.height, (j) => null));

  final size = const Size.square(1000);

  late final cellSize = Size(
    size.width / widget.width,
    size.height / widget.height,
  );

  Color? color = Colors.black;

  void positionToCellUpdate(Offset offset) {
    var x = max(0, offset.dx) ~/ cellSize.width;
    var y = max(0, offset.dy) ~/ cellSize.height;

    final tetrominoIndex = rng.nextInt(tetromino.length);

    for (final (i, shape) in tetromino[tetrominoIndex].indexed) {
      for (final (j, pixel) in shape.indexed) {
        if (!pixel) return;

        x = min(x + j, widget.width - 1);
        y = min(y + i, widget.height - 1);

        if (state[x][y] != null) continue;

        setState(() => state[x][y] = 1);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Container(
          constraints: BoxConstraints.tight(size),
          decoration: BoxDecoration(border: Border.all()),
          child: Listener(
            child: CustomPaint(
              size: size,
              painter: FallingSandPainter(state),
            ),
            onPointerHover: (event) =>
                positionToCellUpdate(event.localPosition),
            onPointerMove: (event) => positionToCellUpdate(event.localPosition),
            onPointerDown: (event) => positionToCellUpdate(event.localPosition),
            onPointerUp: (event) => positionToCellUpdate(event.localPosition),
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                icon: const Icon(Icons.clear),
                onPressed: () => setState(() => state = emptyState()),
              ),
              IconButton(
                icon: const Icon(Icons.square),
                color: Colors.black,
                onPressed: () => setState(() => color = Colors.black),
              ),
              for (var i = 0; i < Colors.primaries.length; i++)
                IconButton(
                  icon: const Icon(Icons.square),
                  color: Colors.primaries[i],
                  onPressed: () => setState(() => color = Colors.primaries[i]),
                ),
            ],
          ),
        ),
      ],
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
