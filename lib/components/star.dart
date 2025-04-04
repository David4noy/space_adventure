import 'dart:math';
import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import 'package:space_adventure/game_main.dart';

class Star extends CircleComponent with HasGameReference<GameMain> {
  final _random = Random();
  final int _maxSise = 3;
  late double _speed;

  @override
  Future<void> onLoad() {
    size = Vector2.all(1.0 + _random.nextInt(_maxSise));

    position = Vector2(
      _random.nextDouble() * game.size.x, 
      _random.nextDouble() * game.size.y,
    );

    _speed = size.x * (40 + _random.nextInt(10));

    paint.color = Color.fromRGBO(255, 255, 255, size.x / _maxSise);


    return super.onLoad();
  }

  @override
  void update(double dt) {
    super.update(dt);

    position.y += _speed * dt;

    if (position.y > game.size.y + size.y / 2) {
      position.y = -size.y / 2;
      _random.nextDouble() * game.size.x;
    }
  }

}