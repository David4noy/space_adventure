import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'package:space_adventure/Utiles/overlay_item.dart';
import 'package:space_adventure/game_main.dart';
import 'package:space_adventure/overlays/game_over_overlay.dart';
import 'package:space_adventure/overlays/main_manu_overlay.dart';
import 'package:space_adventure/overlays/pause_overlay.dart';

void main() {
  final game = GameMain();
  runApp(GameWidget(
    game:  game,
    overlayBuilderMap: {
      Overlayitem.gameOver.title : (context, GameMain game) => GameOverOverlay(game: game),
      Overlayitem.mainMenu.title : (context, GameMain game) => MainMenuOverlay(game: game),
      Overlayitem.pause.title : (context, GameMain game) => PauseOverlay(game: game),
    },
    initialActiveOverlays: [Overlayitem.mainMenu.title],
  ));
}
