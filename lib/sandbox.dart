import 'dart:math';

import 'package:falling_sand/falling_sand_painter.dart';
import 'package:flutter/material.dart';

class Sandbox extends StatelessWidget {
  const Sandbox({
    required this.state,
    required this.onPointerHover,
    required this.onPointerMove,
    required this.onPointerDown,
    required this.onPointerUp,
    required this.cellCount,
    required this.sandKey,
    super.key,
  });

  final List<List<Color?>> state;
  final int cellCount;
  final GlobalKey sandKey;

  final ValueSetter<Offset> onPointerHover;
  final ValueSetter<Offset> onPointerMove;
  final ValueSetter<Offset> onPointerDown;
  final ValueSetter<Offset> onPointerUp;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(border: Border.all()),
      child: Padding(
        padding: const EdgeInsets.all(1),
        child: Listener(
          child: LayoutBuilder(
            builder: (context, constraints) => CustomPaint(
              key: sandKey,
              size:
                  Size.square(min(constraints.maxHeight, constraints.maxWidth)),
              painter: FallingSandPainter(state, cellCount),
            ),
          ),
          onPointerHover: (e) => onPointerHover(e.localPosition),
          onPointerMove: (e) => onPointerMove(e.localPosition),
          onPointerDown: (e) => onPointerDown(e.localPosition),
          onPointerUp: (e) => onPointerUp(e.localPosition),
        ),
      ),
    );
  }
}
