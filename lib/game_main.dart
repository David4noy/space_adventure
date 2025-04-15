import 'dart:async';
import 'dart:math';
import 'package:flame/components.dart';
import 'package:flame/effects.dart';
import 'package:flame/flame.dart';
import 'package:flame/game.dart';
import 'package:flame/input.dart';
import 'package:flutter/material.dart';
import 'package:space_adventure/Utiles/overlay_item.dart';
import 'package:space_adventure/components/asteroid.dart';
import 'package:space_adventure/components/audio_manager.dart';
import 'package:space_adventure/components/pause_button.dart';
import 'package:space_adventure/components/pickup.dart';
import 'package:space_adventure/components/player.dart';
// import 'package:space_adventure/components/shoot_button.dart';
import 'package:space_adventure/components/star.dart';

class GameMain extends FlameGame with HasKeyboardHandlerComponents, HasCollisionDetection {

  late Player player;
  late JoystickComponent joystick;
  late SpawnComponent _asteroidSpawner;
  late SpawnComponent _pickupSpawner;
  final _random = Random();
  // late ShootButton _shootButton;
  int _score = 0;
  late TextComponent _scoreDisplay;
  late TextComponent _lifeDisplay;
  final List<String> playerColor = ['blue', 'red', 'green', 'purple'];
  int playerColorIndex = 0;
  late AudioManager audioManager;
  int get score => _score;
  int _playerLifes = 3;
  int get playerLifes => _playerLifes;

  final _lifeDisplayStyle = const TextStyle(
    color: Color.fromARGB(255, 104, 240, 14),
    fontSize: 24,
    fontWeight: FontWeight.bold,
    shadows: [
      Shadow(
        color: Colors.black, 
        offset: Offset(2, 2),
        blurRadius: 2,
      )
    ]
  );

  @override
  Future<void> onLoad() async {

    await Flame.device.fullScreen();
    await Flame.device.setPortrait();

    audioManager = AudioManager();
    await add(audioManager);
    audioManager.playMusic();

    _createStars();

    return super.onLoad();
  }

  void startGame() async {
    await _createJoystick();
    await _createPlayer();
    // _createShootButton();
    _createAsteroidSpawner();
    _createPickupSpawner();
    _createScoreDisplay();
    _createLifeDisplay();
    _addPauseButton();
  }

  Future<void> _createPlayer() async {
    _playerLifes = 3;
    
    player = Player()
    ..anchor = Anchor.center
    ..position = Vector2(size.x / 2, size.y * 0.6);

    add(player);
  }

  Future<void> _createJoystick() async {
    joystick = JoystickComponent(
      knob: SpriteComponent(
        sprite: await loadSprite('joystick_background.png'),
        size: Vector2.all(100),
      ),
      background: SpriteComponent(
        sprite: await loadSprite('joystick_background.png'),
        size: Vector2.all(140),
      ),
      anchor: Anchor.bottomRight,
      position: Vector2(size.x - 80, size.y - 100),
      priority: 10
    );
    add(joystick);
  }

  // void _createShootButton() {
  //   _shootButton = ShootButton()
  //   ..anchor = Anchor.bottomLeft
  //   ..position = Vector2(20, size.y - 20)
  //   ..priority = 10;
  //   add(_shootButton);
  // }

  void _createAsteroidSpawner() {
    _asteroidSpawner = SpawnComponent.periodRange(
      factory: (index) => Asteroid(position: _generateSpawnPosition()),
      minPeriod: 0.7, 
      maxPeriod: 1.2,
      selfPositioning: true,
    );
    
    add(_asteroidSpawner);
  }

  void _createPickupSpawner() {
    _pickupSpawner = SpawnComponent.periodRange(
      factory: (index) => Pickup(
        position: _generateSpawnPosition(), 
        pickupType: PickupType.values[_random.nextInt(PickupType.values.length)]
      ),
      minPeriod: 1, 
      maxPeriod: 3,
      selfPositioning: true,
    );
    
    add(_pickupSpawner);
  }

  Vector2 _generateSpawnPosition() {
    return Vector2(_random.nextDouble() * (size.x - 20) + 10, -100);
  }

  void _addPauseButton() {
    add(
      PauseButton(
        buttonSize: Vector2(100, 40),
        buttonPosition: Vector2(10, 50),
        buttonAnchor: Anchor.topLeft,
        backgroundColor: Colors.transparent,
        textColor: Colors.white,
        fontSize: 20,
        onClick: () {
          pauseEngine();
          overlays.add(Overlayitem.pause.title);
        }
      ),
    );           // Add the button to the game
  }

  void _createScoreDisplay() {
    _score = 0;

    _scoreDisplay = TextComponent(
      text: '0',
      anchor: Anchor.topCenter,
      position: Vector2(size.x / 2, 40),
      priority: 10,
      textRenderer: TextPaint(
        style: const TextStyle(
          color: Colors.white,
          fontSize: 48,
          fontWeight: FontWeight.bold,
          shadows: [
            Shadow(
              color: Colors.black, 
              offset: Offset(2, 2),
              blurRadius: 2,
            )
          ]
          
        )
      )
    );

    add(_scoreDisplay);
  }

  void _createLifeDisplay() {
    _playerLifes = 3;

    _lifeDisplay = TextComponent(
      text: 'Life: $_playerLifes',
      anchor: Anchor.topRight,
      position: Vector2(size.x- 40, 55),
      priority: 10,
      textRenderer: TextPaint(
        style: _lifeDisplayStyle
      )
    );

    add(_lifeDisplay);
  }

  void playerTakeDamage() {
    Color color = Color.fromARGB(255, 104, 240, 14);

    _playerLifes--;
    if (_playerLifes <= 0) {
      _playerLifes = 0;
      color = Colors.red;
    } else if (_playerLifes == 2) {
      color = Colors.yellow;
    } else if (_playerLifes == 1) {
      color = Colors.red;
    } 

    _lifeDisplay.text = 'Life: $_playerLifes';
    
    _lifeDisplay.textRenderer = TextPaint(
      style: _lifeDisplayStyle.copyWith(
        color: color, // 🔁 change only the color
      ),
    );

  }

  void incrementScore(int amount) {
    _score += amount;
    _scoreDisplay.text = _score.toString();

    final popEffect = ScaleEffect.to(
      Vector2.all(1.2), 
      EffectController(
        duration: 0.05,
        alternate: true,
        curve: Curves.easeInOut,
      )
    );

    _scoreDisplay.add(popEffect);
  }

  void _createStars() {
    for (var i = 0; i < 50; i++) {
      add(Star()..priority = -10);
    }
  }

  void onPlayerDied() {
    overlays.add(Overlayitem.gameOver.title);
    pauseEngine();
  }

  void restarGame() {
    children.whereType<PositionComponent>().forEach((component){
      if (component is Asteroid || component is Pickup) {
        remove(component);
      }
    });

    _asteroidSpawner.timer.start();
    _pickupSpawner.timer.start();

    _score = 0;
    _scoreDisplay.text = '0';
    _playerLifes = 3;

    _lifeDisplay.text = 'Life: $_playerLifes';
    
    _lifeDisplay.textRenderer = TextPaint(
      style: _lifeDisplayStyle.copyWith(
        color: Color.fromARGB(255, 104, 240, 14), // 🔁 change only the color
      ),
    );


    _createPlayer();

    resumeEngine();
  }

  void quitGame() {
     children.whereType<PositionComponent>().forEach((component){
      if (component is! Star) {
        remove(component);
      }
    });

    remove(_asteroidSpawner);
    remove(_pickupSpawner);

    overlays.add(Overlayitem.mainMenu.title);
    resumeEngine();
  }
}