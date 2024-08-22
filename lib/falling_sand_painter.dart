import 'package:flutter/material.dart';

class FallingSandPainter extends CustomPainter {
  FallingSandPainter(this.state, this.cellCount);
  final List<List<Color?>> state;
  Paint paintBrush = Paint();
  final int cellCount;

  @override
  void paint(Canvas canvas, Size size) {
    final width = cellCount;
    final height = cellCount;
    final divisionX = size.width / width;
    final divisionY = size.height / height;

    // add 1 to account for ghost lines
    final cellSize = Size(divisionX + 1, divisionY + 1);

    for (var col = 0; col < width; col++) {
      for (var row = 0; row < height; row++) {
        final color = state[col][row];
        if (color != null) {
          final rect = Offset(col * divisionX, row * divisionY) & cellSize;
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
