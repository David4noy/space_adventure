import 'dart:async';
import 'dart:math';
import 'package:flame/components.dart';
import 'package:space_adventure/game_main.dart';

class Asteroid extends SpriteComponent with HasGameReference<GameMain>  {
  final _random = Random();
  static const double _maxSize = 120;
  late Vector2 _velocity;
  late double _spinSpeed;

  Asteroid({required super.position, double size = _maxSize}) 
    : super (
        size: Vector2.all(size), 
        anchor: Anchor.center,
        priority: -1,
      ) {
        _velocity = _generateVelocity();
        _spinSpeed = _random.nextDouble() * 1.5 - 0.75;
      }

  @override
  FutureOr<void> onLoad() async {
    final imageNum = _random.nextInt(3) + 1;
    sprite = await game.loadSprite('asteroid$imageNum.png');

    return super.onLoad();
  }
  @override
  void update(double dt) {
    position += _velocity *dt;
    _handleScreenBounds();
    angle += _spinSpeed * dt;
    super.update(dt);
  }

  Vector2 _generateVelocity() {
    final forceSize = _maxSize / size.x;

    return Vector2(
      _random.nextDouble() * 120 - 60, 
      100 + _random.nextDouble() * 50,
    ) * forceSize;
  }

  void _handleScreenBounds() {
    if (position.y > game.size.y + size.y / 2) {
      removeFromParent();
    }

    final screenWidth = game.size.x;
        if (position.x < -size.x / 2) {
      position.x = screenWidth + size.x / 2;
    } else if (position.x > screenWidth + size.x / 2) {
      position.x = -size.x / 2;
    }
  }
}