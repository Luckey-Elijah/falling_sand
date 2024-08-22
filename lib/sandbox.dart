import 'package:falling_sand/falling_sand_painter.dart';
import 'package:flutter/material.dart';

class Sandbox extends StatelessWidget {
  const Sandbox({
    required this.state,
    required this.size,
    required this.onPointerHover,
    required this.onPointerMove,
    required this.onPointerDown,
    required this.onPointerUp,
    super.key,
  });

  final List<List<Color?>> state;
  final Size size;

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
        child: ConstrainedBox(
          constraints: BoxConstraints.tight(size),
          child: Listener(
            child: CustomPaint(
              size: size,
              painter: FallingSandPainter(state),
            ),
            onPointerHover: (e) => onPointerHover(e.localPosition),
            onPointerMove: (e) => onPointerMove(e.localPosition),
            onPointerDown: (e) => onPointerDown(e.localPosition),
            onPointerUp: (e) => onPointerUp(e.localPosition),
          ),
        ),
      ),
    );
  }
}
