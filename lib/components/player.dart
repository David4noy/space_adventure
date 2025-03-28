import 'dart:async';
import 'dart:ui';
import 'package:flame/components.dart';
import 'package:space_adventure/game_main.dart';

class Player extends SpriteComponent with HasGameReference<GameMain> {
  @override
  Future<void> onLoad() async {

    sprite = await game.loadSprite('player_blue_on0.png');

    size *= 0.3;
    return super.onLoad();
  }

  @override
  void update(double dt) {
    super.update(dt);
    position += game.joystick.relativeDelta.normalized() *200 * dt;
    _handleScreenBounds();
  }

  void _handleScreenBounds() {
    final screenWidth = game.size.x;
    final screenHeight = game.size.y;

    position.y = clampDouble(
      position.y, 
      size.y, 
      screenHeight - size.y / 2
    );

    if (position.x < 0) {
      position.x = screenWidth;
    } else if (position.x > screenWidth) {
      position.x = 0;
    }
  }
}