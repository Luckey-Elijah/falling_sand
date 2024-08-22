import 'package:falling_sand/main.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

class ActionGroup extends StatelessWidget {
  const ActionGroup({
    super.key,
    this.children = const [],
  });

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        border: Border.all(),
      ),
      child: Row(
        children: children,
      ),
    );
  }
}

class TetrominoIconButton extends StatelessWidget {
  const TetrominoIconButton({
    required this.enabled,
    required this.color,
    super.key,
    this.onPressed,
  });

  final bool enabled;
  final Color? color;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    final iconColor = enabled
        ? color ?? Theme.of(context).colorScheme.primary
        : unselectedIconColor;
    return IconButton(
      tooltip: 'Tetromino',
      icon: SizedBox(
        height: 20,
        width: 25,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(child: ColoredBox(color: iconColor)),
            Expanded(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Spacer(),
                  Expanded(child: ColoredBox(color: iconColor)),
                  const Spacer(),
                ],
              ),
            ),
          ],
        ),
      ),
      onPressed: onPressed,
    );
  }
}

class ColorOptions extends StatelessWidget {
  const ColorOptions({required this.onColor, super.key});

  final ValueSetter<Color> onColor;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          for (final color in [...Colors.primaries, Colors.black])
            IconButton(
              icon: const Icon(Icons.square),
              color: color,
              onPressed: () => onColor(color),
            ),
        ],
      ),
    );
  }
}

class EraserButton extends StatelessWidget {
  const EraserButton({
    required this.enabled,
    required this.color,
    required this.onPressed,
    super.key,
  });

  final bool enabled;
  final Color color;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return IconButton(
      color: enabled ? color : null,
      tooltip: 'Eraser',
      icon: SvgPicture.asset(
        'assets/icons/ink_eraser.svg',
        semanticsLabel: 'Eraser',
        height: 26,
        colorFilter: ColorFilter.mode(
          enabled ? color : unselectedIconColor,
          BlendMode.srcIn,
        ),
      ),
      isSelected: enabled,
      onPressed: onPressed,
    );
  }
}

class CursorSizeOptions extends StatelessWidget {
  const CursorSizeOptions({
    required this.onSize,
    required this.size,
    required this.color,
    super.key,
  });

  final ValueSetter<CursorSize> onSize;
  final CursorSize? size;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        border: Border.all(),
      ),
      child: Row(
        children: [
          IconButton(
            tooltip: 'Small Cursor',
            icon: Icon(
              Icons.circle,
              size: 12,
              color: size == CursorSize.small ? color : null,
            ),
            onPressed: () => onSize(CursorSize.small),
          ),
          IconButton(
            icon: Icon(
              Icons.circle,
              size: 16,
              color: size == CursorSize.medium ? color : null,
            ),
            tooltip: 'Medium Cursor',
            onPressed: () => onSize(CursorSize.medium),
          ),
          IconButton(
            tooltip: 'Big Cursor',
            icon: Icon(
              Icons.circle,
              size: 20,
              color: size == CursorSize.big ? color : null,
            ),
            isSelected: size == CursorSize.big,
            onPressed: () => onSize(CursorSize.big),
          ),
        ],
      ),
    );
  }
}

class EditActionOptions extends StatelessWidget {
  const EditActionOptions({
    required this.onAction,
    required this.action,
    required this.color,
    super.key,
  });

  final EditAction? action;
  final ValueSetter<EditAction> onAction;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        border: Border.all(),
      ),
      child: Row(
        children: [
          TetrominoIconButton(
            color: color,
            enabled: action == EditAction.tetromino,
            onPressed: () => onAction(EditAction.tetromino),
          ),
          IconButton(
            tooltip: 'Draw',
            color: action == EditAction.fall ? color : unselectedIconColor,
            icon: const Icon(Icons.edit),
            isSelected: action == EditAction.fall,
            onPressed: () => onAction(EditAction.fall),
          ),
          EraserButton(
            enabled: action == EditAction.erase,
            color: Colors.pink,
            onPressed: () => onAction(EditAction.erase),
          ),
        ],
      ),
    );
  }
}

class SandBehaviorOptions extends StatelessWidget {
  const SandBehaviorOptions({
    required this.sandBehavior,
    required this.color,
    required this.onBehavior,
    super.key,
  });

  final Color color;
  final SandBehavior sandBehavior;
  final ValueSetter<SandBehavior> onBehavior;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        border: Border.all(),
      ),
      child: Row(
        children: [
          IconButton(
            tooltip: 'Rolling/Gravity Sand',
            color: sandBehavior == SandBehavior.rolling
                ? color
                : unselectedIconColor,
            onPressed: () => onBehavior(SandBehavior.rolling),
            icon: const Icon(Icons.landscape),
          ),
          IconButton(
            tooltip: 'Stacking Sand',
            color: sandBehavior == SandBehavior.stacking
                ? color
                : unselectedIconColor,
            onPressed: () => onBehavior(SandBehavior.stacking),
            icon: const Icon(Icons.stacked_bar_chart),
          ),
        ],
      ),
    );
  }
}
