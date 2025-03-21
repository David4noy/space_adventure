import 'dart:async';
import 'package:flame/flame.dart';
import 'package:flame/game.dart';

class GameMain extends FlameGame {

  @override
  Future<void> onLoad() async {

    await Flame.device.fullScreen();
    await Flame.device.setPortrait();

    return super.onLoad();
  }
}