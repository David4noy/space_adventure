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
  double _fireCooldown = 0.27;
  double _elapsedFireTime = 0.0;
  final _keyboardMovements = Vector2.zero();
  bool _isDestroyed = false;
  final _random = Random();
  late Timer _explosionTimer;
  late Timer _laserPowerupTimer;
  Shield? activeShield;
  int playerLifes = 3;
  // late String _color;

  Player() {
    _explosionTimer = Timer(
      0.1, 
      onTick:  _createRandomExplosion,
      repeat: true,
      autoStart: false,
    );

    _laserPowerupTimer = Timer(
      8.0,
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
      _fireCooldown = 0.15;
      _laserPowerupTimer.update(dt);
    } else {
      _fireCooldown = 0.27;
    }

    final Vector2 movements = game.joystick.relativeDelta + _keyboardMovements;
    position += movements.normalized() * 350 * dt;
    if (movements.x < -0.1) {
      angle = -0.2; // Lean slightly left
    } else if (movements.x > 0.1) {
      angle = 0.2; // Lean slightly right
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
      _handleAsteroidCollision(intersectionPoints, other);
    } else if (other is Pickup) {
      _handlePickupCollision(other);
    }
  }

  void _handleAsteroidCollision(Set<Vector2> intersectionPoints, Asteroid asteroid) {
    if (activeShield == null) {
      _applyDamageToPlayer();
      asteroid.takeDamage(damage: 3);
      if (game.playerLifes <= 0) {
        _handleDestruction();
      } else {
        _spawnBombAtCollisionPoint(intersectionPoints);
      }
    }
  }

  void _applyDamageToPlayer() {
    game.playerTakeDamage();
  }

  void _handlePickupCollision(Pickup pickup) {
    game.audioManager.playSound('collect');
    pickup.removeFromParent();
    game.incrementScore(1);

    _handlePickupType(pickup);
  }

  void _handlePickupType(Pickup pickup) {
    switch (pickup.pickupType) {
      case PickupType.bomb:
        _spawnBomb();
        break;
      case PickupType.laser:
        _activateLaserPowerup();
        break;
      case PickupType.shield:
        _equipShield();
        break;
    }
  }

  void _spawnBomb() {
    game.add(Bomb(position: position.clone()));
  }

  void _activateLaserPowerup() {
    _laserPowerupTimer.start();
  }

  void _equipShield() {
    if (activeShield != null) {
      remove(activeShield!);
    }

    activeShield = Shield();
    add(activeShield!);
  }

  void _spawnBombAtCollisionPoint(Set<Vector2> intersectionPoints) {
    // Use the first intersection point as the spawn point for the bomb
    if (intersectionPoints.isNotEmpty) {
      final collisionPoint = intersectionPoints.first;
      collisionPoint.y -= 10;

      // Create a bomb with maxSize 20, duration 0.5, and priority 5 at the collision point
      game.add(Bomb(
        position: collisionPoint,
        maxSize: 80,
        duration: 0.3,
      )..priority = 5);
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
      EffectController(duration: 1.5),
      onComplete: () => _explosionTimer.stop(),
      )
    );

    add(MoveEffect.by(
        Vector2(0, 200),
        EffectController(duration: 2.0) 
      )
    );

    add(RemoveEffect(
        delay: 2.5,
        onComplete: () => game.onPlayerDied(),
      ));

    game.add(Bomb(
      position: position.clone(),
      maxSize: 400,
    )..priority = 20);

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
      size.x - size.x / 2, 
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
    game.add(
      Laser(
        position: position.clone() + Vector2(0, -size.y / 2), 
        isMulti: _laserPowerupTimer.isRunning()
      )
    );

    if (_laserPowerupTimer.isRunning()) {
      game.add(
        Laser(
          position: position.clone(), // + Vector2(0, -size.y / 2), 
          angle: 20 * degrees2Radians,
          isMulti: true,
        )
      );
      game.add(
        Laser(
          position: position.clone(), // + Vector2(0, -size.y / 2), 
          angle: -20 * degrees2Radians, 
          isMulti: true,
        )
      );
    }
  }
}