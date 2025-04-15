import 'package:flutter/material.dart';
import 'package:space_adventure/Utiles/overlay_item.dart';
import 'package:space_adventure/game_main.dart';

class PauseOverlay extends StatefulWidget {
  final GameMain game;

  const PauseOverlay({super.key, required this.game});

  @override
  State<PauseOverlay> createState() => _PauseOverlayState();
}

class _PauseOverlayState extends State<PauseOverlay> {
  double _opacity = 0.0;

  @override
  void initState() {
    super.initState();

    Future.delayed(
      Duration(milliseconds: 0),
      () {
        setState(() {
          _opacity = 1.0;
        });
      }
    ); 
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedOpacity(
      onEnd: () {
        if (_opacity == 0) {
          widget.game.overlays.remove(Overlayitem.pause.title);
        }
      },
      opacity: _opacity,
      duration: const Duration(milliseconds: 500),
      child: Container(
        color: Colors.black.withAlpha(150),
        alignment: Alignment.center,
        child: Center(
          child:  _resumeButton(),
        ),
      ),
    );
  }

  Widget _resumeButton() {
    return TextButton(
      onPressed: () {
        widget.game.resumeEngine();
        setState(() {
          _opacity = 0;
        });
      }, 
      style: TextButton.styleFrom(
        padding: EdgeInsets.symmetric(vertical: 20, horizontal: 25),
        backgroundColor: Colors.green.withAlpha(120),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(50),
          side: BorderSide( 
            color: Colors.green, 
            width: 2.0, 
          ),
        )
      ),
      child: Text(
        'RESUME GAME',
        style: TextStyle(
          color: Colors.white,
          fontSize: 36,
        ),
      )
    );
  }
}