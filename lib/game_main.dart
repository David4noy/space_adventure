import 'dart:async';
import 'dart:math';
import 'package:flame/components.dart';
import 'package:flame/effects.dart';
import 'package:flame/events.dart';
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

class GameMain extends FlameGame with HasKeyboardHandlerComponents, HasCollisionDetection, TapCallbacks {

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
  final _playerMaxLife = 3;
  double _currenAsteroidtMinPeriod = 0.7;
  double _currentAsteroidMaxPeriod = 1.2;

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

  @override
  void render(Canvas canvas) {

    final rect = Rect.fromLTWH(0, 0, size.x, size.y);
    final paint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topRight,
        end: Alignment.bottomLeft,
        colors: [
          Colors.black,
          const Color(0xFF2C003E), // Deep dark purple
          Colors.black,
        ],
        stops: [0.0, 0.5, 1.0],
      ).createShader(rect);

    canvas.drawRect(rect, paint);
    super.render(canvas);
  }

  @override
  Future<void> onTapDown(TapDownEvent event) async {
    // Remove old joystick
    joystick.removeFromParent();

    // Create new joystick at tap position
    await _createJoystick(event.canvasPosition);
  }

  @override
  void onTapUp(TapUpEvent event) {
    // Remove joystick on tap up
    joystick.removeFromParent();
  }

  void startGame() async {
    await _createJoystick(Vector2(size.x - 120, size.y - 140));
    await _createPlayer();
    // _createShootButton();
    _createAsteroidSpawner();
    _createPickupSpawner();
    _createScoreDisplay();
    _createLifeDisplay();
    _addPauseButton();
  }

  Future<void> _createPlayer() async {
    _playerLifes = _playerMaxLife;
    
    player = Player()
    ..anchor = Anchor.center
    ..position = Vector2(size.x / 2, size.y * 0.6);

    add(player);
  }

  Future<void> _createJoystick(Vector2 position) async {
    joystick = JoystickComponent(
      knob: SpriteComponent(
        sprite: await loadSprite('joystick_background.png'),
        size: Vector2.all(70),
      ),
      background: SpriteComponent(
        sprite: await loadSprite('joystick_background.png'),
        size: Vector2.all(120),
      ),
      anchor: Anchor.center,
      position: position,
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
      factory: (index) => Asteroid(position: _generateSpawnPosition(), currnetScore: _score),
      minPeriod: 0.7, 
      maxPeriod: 1.2,
      selfPositioning: true,
    );
    
    add(_asteroidSpawner);
  }

  void _updateAsteroidSpawner(double newMin, double newMax) {
    if (_currenAsteroidtMinPeriod == newMin && _currentAsteroidMaxPeriod == newMax) return;

    _currenAsteroidtMinPeriod = newMin;
    _currentAsteroidMaxPeriod = newMax;

    remove(_asteroidSpawner);

    _asteroidSpawner = SpawnComponent.periodRange(
      factory: (index) => Asteroid(position: _generateSpawnPosition(), currnetScore: _score),
      minPeriod: newMin,
      maxPeriod: newMax,
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
    _playerLifes = _playerMaxLife;

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
        color: color, 
      ),
    );

    final popEffect = ScaleEffect.to(
      Vector2.all(1.5), 
      EffectController(
        duration: 0.25,
        alternate: true,
        curve: Curves.easeInOut,
      )
    );

    _lifeDisplay.add(popEffect);
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

    _handleAsteroidSpawnerUpdate();
  }

  void _handleAsteroidSpawnerUpdate() {
    final int baseScore = 4500;
    final int step = 400;

    final double startMin = 0.60;
    final double startMax = 1.10;
    final double endMin = 0.35;
    final double endMax = 0.60;

    final int steps = 20;
    final double minStepSize = (startMin - endMin) / steps;
    final double maxStepSize = (startMax - endMax) / steps;

    for (int i = steps; i >= 0; i--) {
      final int threshold = baseScore + i * step;
      if (_score > threshold) {
        final double newMin = startMin - i * minStepSize;
        final double newMax = startMax - i * maxStepSize;
        _updateAsteroidSpawner(newMin, newMax);
        break;
      }
    }
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
    _playerLifes = _playerMaxLife;

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