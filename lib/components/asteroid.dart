import 'dart:async';
import 'dart:math';
import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flame/effects.dart';
import 'package:flutter/material.dart';
import 'package:space_adventure/components/explosion.dart';
import 'package:space_adventure/game_main.dart';

class Asteroid extends SpriteComponent with HasGameReference<GameMain> {
  final _random = Random();
  static const double _maxSize = 150;
  final int currnetScore;
  late Vector2 _velocity;
  final _originalVelocity = Vector2.zero();
  late double _spinSpeed;
  final double _maxHealth = 3;
  late double _health;
  bool _isKnockBack = false;
  String _image = 'asteroid1.png';
  double get health => _health;

  Asteroid({required super.position, required this.currnetScore,  double size = _maxSize}) 
    : super (
        size: Vector2.all(size), 
        anchor: Anchor.center,
        priority: -1,
      ) {

    _velocity = _generateVelocity();
    _originalVelocity.setFrom(_velocity);
    _spinSpeed = _random.nextDouble() * 1.5 - 0.75;
    _health = size / _maxSize * _maxHealth;
    add(CircleHitbox(collisionType: CollisionType.passive));
  }

  @override
  FutureOr<void> onLoad() async {
    final imageNum = _random.nextInt(3) + 1;
    sprite = await game.loadSprite('asteroid$imageNum.png');
    _image = 'asteroid$imageNum.png';

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
    final speedUp = (currnetScore ~/ 1000) * 25.0;

    final forceSize = _maxSize / size.x;

    // x in range [-40, 40)
    double x = _random.nextDouble() * 80 - 40;

    // y in range [50, 100)
    double y = 50 + _random.nextDouble() * 50;

    // First apply scaling
    Vector2 velocity = Vector2(x, y) * forceSize;

    // Then add fixed speedUp after scaling
    velocity.x += (velocity.x >= 0) ? speedUp : -speedUp;
    velocity.y += speedUp;

    return velocity;
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

  void takeDamage({int damage = 1}) {
    game.audioManager.playSound('hit');
    _health -= damage;

    if (_health <= 0) {
      game.incrementScore(3);
      removeFromParent();
      _createExplosion();
      _splitAsteroid();
    } else {
      game.incrementScore(_health > 1 ? 1 : 2);
      _flashWhite();
      _applyKnockBack();
    }
  }

  void _flashWhite() {
    final flashEffect = ColorEffect(
      Colors.white, 
      EffectController(
        duration: 0.1,
        alternate: true,
        curve: Curves.easeInOut,
      )
    );
    add(flashEffect);
  }

  void _applyKnockBack() {
    if (_isKnockBack) return;
    _isKnockBack = true;
    _velocity.setZero();

    final knockBackEffect = MoveByEffect(
      Vector2(0, -20), 
      EffectController(duration: 0.1),
      onComplete: _restoreVelocity
    );
    add(knockBackEffect);
  }

  void _restoreVelocity() {
    _velocity.setFrom(_originalVelocity);
    _isKnockBack = false;
  }

  void  _createExplosion() {
    final explosion = Explosion(
      position: position.clone(), 
      explosionType: ExplosionType.dust, 
      explosionSize: size.x, 
      image: _image,
    );

    game.add(explosion);
  }

  void _splitAsteroid() {
    if (size.x <= _maxSize / 3) return;

    for (var i = 0; i < 3; i++) {
      final fragment = Asteroid(
        position: position.clone(),
        size: size.x - _maxSize / 3, 
        currnetScore: currnetScore,
      );
      game.add(fragment);
    }
  }
}