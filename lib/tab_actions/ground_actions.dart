import 'dart:math';

import 'package:collection/collection.dart';
import 'package:flutter/material.dart';

enum PixelElement { dirt, water, sand, grass }

PixelElement? getElementByColor(Color? color) => elementColors.entries
    .firstWhereOrNull(
      (element) => element.value.contains(color),
    )
    ?.key;

// kg/m3
final density = <PixelElement, int>{
  PixelElement.water: 997,
  PixelElement.dirt: 1250,
  PixelElement.sand: 1850,
  PixelElement.grass: 1250, // idk probably like dirt
};

enum ElementState { gaz, liquid, solid }

final elementState = <PixelElement, ElementState>{
  PixelElement.water: ElementState.liquid,
  PixelElement.dirt: ElementState.solid,
  PixelElement.sand: ElementState.solid,
  PixelElement.grass: ElementState.solid,
};

final _random = Random();

Map<PixelElement, List<Color>> elementColors = {
  PixelElement.dirt: const [
    Color(0xff645244),
    Color(0xff796353),
    Color(0xff866D5B),
  ],
  PixelElement.water: const [
    Color(0xff109ee5),
    Color(0xff2DAFF0),
    Color(0xff0D84BF),
  ],
  PixelElement.sand: const [
    Color(0xffF5DEB3),
    Color(0xffF1D093),
    Color(0xffEFC881),
  ],
  PixelElement.grass: const [
    Color(0xff3B684D),
    Color(0xff51906A),
    Color(0xff6FAE89),
  ],
};

Color getElementColor(PixelElement element) {
  return elementColors[element]![
      _random.nextInt(elementColors[element]!.length)];
}

class GroundActions extends StatelessWidget {
  const GroundActions({required this.onElementChanged, super.key});

  final void Function(PixelElement selectedElement) onElementChanged;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      spacing: 4,
      children: [
        FilledButton(
          onPressed: () {
            onElementChanged(PixelElement.dirt);
          },
          style: ButtonStyle(
            backgroundColor: WidgetStatePropertyAll(Colors.brown.shade300),
          ),
          child: const Text('Dirt'),
        ),
        FilledButton(
          onPressed: () {
            onElementChanged(PixelElement.water);
          },
          style: const ButtonStyle(
            backgroundColor: WidgetStatePropertyAll(Color(0xff109ee5)),
          ),
          child: const Text('Water'),
        ),
        FilledButton(
          onPressed: () {
            onElementChanged(PixelElement.sand);
          },
          style: const ButtonStyle(
            backgroundColor: WidgetStatePropertyAll(Color(0xffF5DEB3)),
          ),
          child: const Text('Sand'),
        ),
        FilledButton(
          onPressed: () {
            onElementChanged(PixelElement.grass);
          },
          style: const ButtonStyle(
            backgroundColor: WidgetStatePropertyAll(Color(0xff3B684D)),
          ),
          child: const Text('Grass'),
        ),
      ],
    );
  }
}
