import 'package:flutter/material.dart';
import 'package:space_adventure/Utiles/storage_manager.dart';
import 'package:space_adventure/game_main.dart';

class GameOverOverlay extends StatefulWidget {
  final GameMain game;

  const GameOverOverlay({super.key, required this.game});

  @override
  State<GameOverOverlay> createState() => _GameOverOverlayState();
}

class _GameOverOverlayState extends State<GameOverOverlay> {
  bool _isNewScore = false;
  String _bestScore = 'Not set yet';
  double _opacity = 0.0;

  @override
  void initState() {
    super.initState();
    _getBestScore();

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
          widget.game.overlays.remove('GameOver');
        }
      },
      opacity: _opacity,
      duration: const Duration(milliseconds: 500),
      child: Container(
        color: Colors.black.withAlpha(150),
        alignment: Alignment.center,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [

            _bestScoreText(),

            const SizedBox(height: 50),

            _gameOverText(),
      
            const SizedBox(height: 50),
      
            _playAgainButton(),
      
            const SizedBox(height: 15),
      
            _mainMenuButton(),
          ],
        ),
      ),
    );
  }

  void _getBestScore() async {
    final newScore = widget.game.score;
    int bestScore = await StorageManager().getSavedInt(StorageKey.score) ?? 0;

    if (newScore > bestScore) {
      bestScore = newScore;
      await StorageManager().saveInt(StorageKey.score, newScore);
      _isNewScore = true;
    }
    
    setState(() {
      _bestScore = bestScore.toString();
    });
  }

  Widget _bestScoreText() {
    return Text(
      _isNewScore 
        ? 'NEW BEST SCORE!!\n$_bestScore!' 
        : 'Best Score:\n$_bestScore!',
      textAlign: TextAlign.center, // centers each line
      style: const TextStyle(
        color: Color.fromARGB(255, 187, 230, 32),
        fontSize: 36,
        fontWeight: FontWeight.bold,
      ),
    );
  }

  Widget _gameOverText() {
    return const Text(
      'GAME OVER',
      style: TextStyle(
        color: Colors.white,
        fontSize: 48,
        fontWeight: FontWeight.bold,
      ),
    );
  }

  Widget _playAgainButton() {
    return TextButton(
      onPressed: () {
        widget.game.audioManager.playSound('click');
        widget.game.restarGame();
        setState(() {
          _opacity = 0;
        });
      }, 
      style: TextButton.styleFrom(
        padding: EdgeInsets.symmetric(vertical: 10, horizontal: 25),
        backgroundColor: Colors.blue,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(50))
      ),
      child: Text(
        'PLAY AGAIN',
        style: TextStyle(
          color: Colors.white,
          fontSize: 28,
        ),
      )
    );
  }

  Widget _mainMenuButton() {
    return TextButton(
      onPressed: () {
        widget.game.audioManager.playSound('click');
        widget.game.quitGame();
        setState(() {
          _opacity = 0;
        });
      }, 
      style: TextButton.styleFrom(
        padding: EdgeInsets.symmetric(vertical: 10, horizontal: 25),
        backgroundColor: Colors.blue,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(50))
      ),
      child: Text(
        'MAIN MENU',
        style: TextStyle(
          color: Colors.white,
          fontSize: 28,
        ),
      )
    );
  }
}