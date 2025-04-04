import 'dart:async';

import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flame/effects.dart';
import 'package:flutter/material.dart';
import 'package:space_adventure/components/asteroid.dart';
import 'package:space_adventure/game_main.dart';

class Shield extends SpriteComponent with HasGameReference<GameMain>, CollisionCallbacks {
  Shield() : super (
        size: Vector2.all(200), 
        anchor: Anchor.center,
      );

  @override
  FutureOr<void> onLoad() async {
    sprite = await game.loadSprite('shield.png');
    position = game.player.size / 2;

    add(CircleHitbox(isSolid: true));

    _addingScaleEffect();
    _addFadeOutEffect();
    
    return super.onLoad();
  }

  @override
  void onCollision(Set<Vector2> intersectionPoints, PositionComponent other) {
    super.onCollision(intersectionPoints, other);

    if (other is Asteroid) {
      other.takeDamage(damage: 3);
    }
  }

  void _addingScaleEffect() {
    final scaleEffect = ScaleEffect.to(
      Vector2.all(1.1), 
      EffectController(
        duration: 0.6,
        alternate: true,
        infinite: true,
        curve: Curves.easeInOut,
      )
    );

    add(scaleEffect);
  }

  void _addFadeOutEffect() {
    final fadeOutEffect = OpacityEffect.fadeOut(
      EffectController(
        duration: 2.0,
        startDelay: 3.0,
      ),
      onComplete: () {
        removeFromParent();
        game.player.activeShield = null;
      },
    );
    add(fadeOutEffect);
  }
}