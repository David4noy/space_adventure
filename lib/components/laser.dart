import 'dart:async';
import 'dart:math';

import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:space_adventure/components/asteroid.dart';
import 'package:space_adventure/game_main.dart';

class Laser extends SpriteComponent with HasGameReference<GameMain>, CollisionCallbacks {
  final bool isMulti;
  Laser({required super.position, super.angle = 0.0, required this.isMulti})
    : super(
      anchor: Anchor.center,
      priority: -1
    );

  @override
  FutureOr<void> onLoad() async {

    sprite = await game.loadSprite(isMulti ? 'laser_multi.png' : 'laser.png');
    size *= 0.3;
    add(RectangleHitbox());
    return super.onLoad();
  }

  @override
  void update(double dt) {
    position += Vector2(sin(angle), -cos(angle)) * 500 * dt;

    if (position.y < -size.y / 2) {
      removeFromParent();
    }
    super.update(dt);
  }

  @override
  void onCollision(Set<Vector2> intersectionPoints, PositionComponent other) {
    super.onCollision(intersectionPoints, other);

    if (other is Asteroid) {
      removeFromParent();
      other.takeDamage();
    }
  }
}