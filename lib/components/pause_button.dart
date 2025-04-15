import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flame/input.dart';
import 'package:flutter/material.dart';
import 'package:space_adventure/game_main.dart';

class PauseButton extends ButtonComponent with HasGameReference<GameMain> {
  late TextComponent _label;

  final Vector2 buttonSize;
  final Vector2 buttonPosition;
  final Anchor buttonAnchor;
  final Color backgroundColor;
  final Color textColor;
  final double fontSize;
  final Function() onClick;

  PauseButton({
    required this.buttonSize,
    required this.buttonPosition,
    this.buttonAnchor = Anchor.topLeft,
    this.backgroundColor = Colors.transparent,
    this.textColor = Colors.white,
    this.fontSize = 18,
    required this.onClick,
  }) : super(
          priority: 2,
          size: buttonSize,
          position: buttonPosition,
          anchor: buttonAnchor,
          button: PositionComponent(
            children: [
              RoundedRectComponent(
                size: buttonSize,
                color: backgroundColor,
                borderRadius: 12,
              ),
              RoundedRectComponent(
                size: buttonSize,
                color: Colors.blue.withAlpha(60),
                borderColor: Colors.blue,
                borderWidth: 2,
                borderRadius: 12,
              ),
            ],
          ),

        );

  @override
  Future<void> onLoad() async {
    await super.onLoad();

    _label = TextComponent(
      priority: 3,
      text: 'Pause',
      anchor: Anchor.center,
      position: size / 2,
      textRenderer: TextPaint(
        style: TextStyle(
          color: textColor,
          fontSize: fontSize,
        ),
      ),
    );

    add(_label);
  }

  @override
  void onTapDown(TapDownEvent event) {
    super.onTapDown(event);

    onClick.call();
  }
}

class RoundedRectComponent extends PositionComponent {
  final Color color;
  final double borderRadius;
  final double borderWidth;
  final Color borderColor;

  RoundedRectComponent({
    required Vector2 super.size,
    required this.color,
    this.borderRadius = 12,
    this.borderWidth = 0,
    this.borderColor = Colors.white,
    super.position,
    Anchor super.anchor = Anchor.topLeft,
  });

  @override
  void render(Canvas canvas) {
    final rect = size.toRect();
    final rrect = RRect.fromRectAndRadius(rect, Radius.circular(borderRadius));

    final fillPaint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    canvas.drawRRect(rrect, fillPaint);

    if (borderWidth > 0) {
      final strokePaint = Paint()
        ..color = borderColor
        ..style = PaintingStyle.stroke
        ..strokeWidth = borderWidth;
      canvas.drawRRect(rrect, strokePaint);
    }
  }
}
