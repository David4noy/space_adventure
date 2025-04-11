import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'package:space_adventure/game_main.dart';
import 'package:space_adventure/overlays/game_over_overlay.dart';
import 'package:space_adventure/overlays/title_overlay.dart';

void main() {
  final game = GameMain();
  runApp(GameWidget(
    game:  game,
    overlayBuilderMap: {
      'GameOver' : (context, GameMain game) => GameOverOverlay(game: game),
      'Title' : (context, GameMain game) => TitleOverlay(game: game)
    },
    initialActiveOverlays: const ['Title'],
  ));
}
