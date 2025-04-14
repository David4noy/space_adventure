import 'dart:async';
import 'dart:math';
import 'dart:ui';
import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flame/effects.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:space_adventure/components/asteroid.dart';
import 'package:space_adventure/components/bomb.dart';
import 'package:space_adventure/components/explosion.dart';
import 'package:space_adventure/components/laser.dart';
import 'package:space_adventure/components/pickup.dart';
import 'package:space_adventure/game_main.dart';
import 'package:space_adventure/components/shield.dart';

class Player extends SpriteAnimationComponent 
    with HasGameReference<GameMain>, KeyboardHandler, CollisionCallbacks {

  bool _isShooting = true;
  final double _fireCooldown = 0.25;
  double _elapsedFireTime = 0.0;
  final _keyboardMovements = Vector2.zero();
  bool _isDestroyed = false;
  final _random = Random();
  late Timer _explosionTimer;
  late Timer _laserPowerupTimer;
  Shield? activeShield;
  // late String _color;

  Player() {
    _explosionTimer = Timer(
      0.1, 
      onTick:  _createRandomExplosion,
      repeat: true,
      autoStart: false,
    );

    _laserPowerupTimer = Timer(
      10.0,
      autoStart: false,
    );
  }

  @override
  Future<void> onLoad() async {
    // _color = game.playerColor[game.playerColorIndex];

    animation = await _loadAnimation();

    size *= 0.08;

    add(RectangleHitbox.relative(
        Vector2(0.6, 0.9), 
        parentSize: size,
        anchor: Anchor.center,
      )
    );
    return super.onLoad();
  }

  @override
  void update(double dt) {
    super.update(dt);

    if (_isDestroyed) {
      _explosionTimer.update(dt);
      return;
    }

    if (_laserPowerupTimer.isRunning()) {
      _laserPowerupTimer.update(dt);
    }

    final Vector2 movements = game.joystick.relativeDelta + _keyboardMovements;
    position += movements.normalized() * 350 * dt;
    if (movements.x < -0.1) {
      angle = -0.1; // Lean slightly left
    } else if (movements.x > 0.1) {
      angle = 0.1; // Lean slightly right
    } else {
      angle = 0; // Reset tilt
    }
    _handleScreenBounds();

    _elapsedFireTime += dt;
    if (_isShooting && _elapsedFireTime >= _fireCooldown) {
      _fireLaser();
      _elapsedFireTime = 0.0;
    }
  }

  @override
  void onCollision(Set<Vector2> intersectionPoints, PositionComponent other) {
    super.onCollision(intersectionPoints, other);

    if (_isDestroyed) return;

    if (other is Asteroid) {
      if (activeShield == null) _handleDestruction();
    } else if (other is Pickup) {
      game.audioManager.playSound('collect');
      other.removeFromParent();
      game.incrementScore(1);

      switch (other.pickupType) {
        case PickupType.bomb:
          game.add(Bomb(position: position.clone()));
          break;
        case PickupType.laser:
          _laserPowerupTimer.start();
          break;
        case PickupType.shield:
          if (activeShield != null) {
            remove(activeShield!);
          }

          activeShield = Shield();
          add(activeShield!);
          break;
      }
    }
  }

  void _handleDestruction() async {
    animation = SpriteAnimation.spriteList(
      [
        // await game.loadSprite('player_${_color}_off.png'),
        await game.loadSprite('ship0.png'),
      ], 
      stepTime: double.infinity,
    );

    add(ColorEffect(
      Colors.white, 
        EffectController(duration: 0.1)
      )
    );

    add(OpacityEffect.fadeOut(
      EffectController(duration: 3.0),
      onComplete: () => _explosionTimer.stop(),
      )
    );

    add(MoveEffect.by(
        Vector2(0, 200),
        EffectController(duration: 3.0) 
      )
    );

    add(RemoveEffect(
        delay: 4.0,
        onComplete: () => game.onPlayerDied(),
      ));

    _isDestroyed = true;
    _explosionTimer.start();
  }

  void _createRandomExplosion() {
    final explosionPosotion = Vector2(
      position.x - size.x / 2 + _random.nextDouble() * size.x, 
      position.y - size.y / 2 + _random.nextDouble() * size.y,
    );

    final explosionType = _random.nextBool() ? ExplosionType.smoke : ExplosionType.fire;
    final explosion = Explosion(
      position: explosionPosotion, 
      explosionType: explosionType, 
      explosionSize: size.x * 0.7,
      image: 'asteroid1.png',
    );

    game.add(explosion);
  }

  @override
  bool onKeyEvent(KeyEvent event, Set<LogicalKeyboardKey> keysPressed) {
    _keyboardMovements.x = 0;
    _keyboardMovements.x += keysPressed.contains(LogicalKeyboardKey.arrowLeft) ? -1 : 0;
    _keyboardMovements.x += keysPressed.contains(LogicalKeyboardKey.arrowRight) ? 1 : 0;

    _keyboardMovements.y = 0;
    _keyboardMovements.y += keysPressed.contains(LogicalKeyboardKey.arrowUp) ? -1 : 0;
    _keyboardMovements.y += keysPressed.contains(LogicalKeyboardKey.arrowDown) ? 1 : 0;
    return true;
  }

  Future<SpriteAnimation> _loadAnimation() async {
    return SpriteAnimation.spriteList(
      [
        await game.loadSprite('ship1.png'),
        await game.loadSprite('ship2.png'),
        // await game.loadSprite('player_${_color}_on0.png'),
        // await game.loadSprite('player_${_color}_on1.png'),
      ], 
      stepTime: 0.1,
      loop: true,
    );
  }

  void _handleScreenBounds() {
    final screenWidth = game.size.x;
    final screenHeight = game.size.y;

    position.y = clampDouble(
      position.y, 
      size.y, 
      screenHeight - size.y / 2
    );

    position.x = clampDouble(
      position.x, 
      size.x, 
      screenWidth - size.x / 2
    );

    // if (position.x < 0) {
    //   position.x = screenWidth;
    // } else if (position.x > screenWidth) {
    //   position.x = 0;
    // }
  }

  void setIsShooting(bool isShooting) {
    _isShooting = isShooting;
  }

  void startShooting() {
    _isShooting = true;
  }

  void stopShooting() {
    _isShooting = false;
  }

  void _fireLaser() {
    game.add(Laser(position: position.clone() + Vector2(0, -size.y / 2)));

    if (_laserPowerupTimer.isRunning()) {
      game.add(
        Laser(
          position: position.clone() + Vector2(0, -size.y / 2), 
          angle: 15 * degrees2Radians,
        )
      );
      game.add(
        Laser(
          position: position.clone() + Vector2(0, -size.y / 2), 
          angle: -15 * degrees2Radians,
        )
      );
    }
  }
}