import 'dart:async';

import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flame/effects.dart';
import 'package:flutter/material.dart';
import 'package:space_adventure/components/asteroid.dart';
import 'package:space_adventure/game_main.dart';

class Bomb extends SpriteComponent with HasGameReference<GameMain>, CollisionCallbacks {
  Bomb({required super.position}) 
    : super(
      size: Vector2.all(1),
      anchor: Anchor.center,
      priority: -1,
    );
  
  @override
  FutureOr<void> onLoad() async {
    game.audioManager.playSound('fire');
    sprite = await game.loadSprite('bomb.png');

    add(CircleHitbox(isSolid: true));

    _addSequenceEffect();

    return super.onLoad();
  }

  @override
  void onCollision(Set<Vector2> intersectionPoints, PositionComponent other) {
    super.onCollision(intersectionPoints, other);

    if (other is Asteroid) {
      other.takeDamage(damage: 1);
    }
  }

  void _addSequenceEffect() {
    add(SequenceEffect([
      SizeEffect.to(
        Vector2.all(800),
        EffectController(
          duration: 1.0,
          curve: Curves.easeInOut,
        ),
      ),
      OpacityEffect.fadeOut(
        EffectController(duration: 0.5),
      ),
      RemoveEffect(),
    ]));
  }
}