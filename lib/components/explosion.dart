import 'dart:async';
import 'dart:math';
import 'package:flame/components.dart';
import 'package:flame/effects.dart';
import 'package:flame/flame.dart';
import 'package:flame/particles.dart';
import 'package:flutter/material.dart';
import 'package:space_adventure/game_main.dart';

enum ExplosionType {
  dust, smoke, fire;
  
List<Color> generatedColors() {
    switch (this) {
      case ExplosionType.dust:
        return [
          const Color(0xFF5A4632),
          const Color.fromARGB(255, 112, 89, 65),
          const Color.fromARGB(255, 132, 106, 80),
        ];
      case ExplosionType.smoke:
        return [
          const Color(0xFF404040),
          const Color.fromARGB(255, 107, 107, 107),
          const Color.fromARGB(255, 132, 132, 132),
        ];
      case ExplosionType.fire:
        return [
          const Color(0xFFFFD700),
          const Color.fromARGB(255, 246, 211, 16),
          const Color.fromARGB(255, 252, 218, 27),
        ];
    }
  }
}

class Explosion extends PositionComponent with HasGameReference<GameMain> {
  final ExplosionType explosionType;
  final double explosionSize;
  final String image;
  final _random = Random();

  Explosion({
    required super.position,
    required this.explosionType, 
    required this.explosionSize, 
    required this.image, 
  });

  @override
  FutureOr<void> onLoad() async {
    final num = 1 + _random.nextInt(2);
    game.audioManager.playSound('explode$num');
    
    _createFlash();
    await _createParticles();
    
    add(RemoveEffect(delay: 1.0));
    return super.onLoad();
  }

  void _createFlash() {
    final flash = CircleComponent(
      radius: explosionSize * 0.6,
      paint: Paint()..color = Colors.white,
      anchor: Anchor.center
    );

    final fadeOutEffect = OpacityEffect.fadeOut(
      EffectController(duration: 0.3)
    );

    flash.add(fadeOutEffect);
    add(flash);
  }

  Future<void> _createParticles()  async {
    final asteroidImage = await Flame.images.load(image);    

    final particles = ParticleSystemComponent(
      particle: Particle.generate(
        count: 8 + _random.nextInt(5),
        generator: (index) {
          return MovingParticle(
            child: ImageParticle(
              image: asteroidImage,
              size: Vector2.all(
                explosionSize * (0.1 + _random.nextDouble() * 0.05),
              ),
              lifespan: 0.5 + _random.nextDouble() * 0.5,
            ),
            to: Vector2(
              (_random.nextDouble() - 0.5) * explosionSize * 2,
              (_random.nextDouble() - 0.5) * explosionSize * 2,
            ),
            lifespan: 0.5 + _random.nextDouble() * 0.5,
          );
        },
      ),
    );


    add(particles);
  }
}