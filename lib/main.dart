import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'package:space_adventure/game_main.dart';

void main() {
  final game = GameMain();
  runApp(GameWidget(game:  game));
}
