import 'package:flutter/material.dart';
import 'package:space_adventure/Utiles/storage_manager.dart';
import 'package:space_adventure/game_main.dart';

class TitleOverlay extends StatefulWidget {
  final GameMain game;
  const TitleOverlay({super.key, required this.game});

  @override
  State<TitleOverlay> createState() => _TitleOverlayState();
}

class _TitleOverlayState extends State<TitleOverlay> {
  double _opacity = 0.0;
  String _bestScore = 'Not set yet!\nPlay to get the best score';

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
    // final playerColor = widget.game.playerColor[widget.game.playerColorIndex];
    return AnimatedOpacity(
      onEnd: () {
        if (_opacity == 0) {
          widget.game.overlays.remove('Title');
        }
      },
      opacity: _opacity,
      duration: const Duration(milliseconds: 500),
      child: Container(
        alignment: Alignment.center,
        child: Column(
          children: [
            const SizedBox(height: 120),

            _bestScoreText(),

            const SizedBox(height: 60),

            SizedBox(
              width: 270,
              child: Image.asset('assets/images/title.png'),
            ),

            // const SizedBox(height: 60),

            // Row(
            //   mainAxisSize: MainAxisSize.min,
            //   children: [

            //     GestureDetector(
            //       onTap: (){
            //         widget.game.audioManager.playSound('click');
            //         setState(() {
            //           widget.game.playerColorIndex--;
            //           if (widget.game.playerColorIndex < 0) {
            //             widget.game.playerColorIndex = widget.game.playerColor.length - 1;
            //           }
            //         });
            //       },
            //       child: Transform.flip(
            //         flipX: true,
            //         child: SizedBox(
            //           width: 30,
            //           child: Image.asset('assets/images/arrow_button.png'),
            //         ),
            //       ),
            //     ),

            //     Padding(
            //       padding: const EdgeInsets.only(left: 30, right: 30, top: 30),
            //       child: SizedBox(
            //         width: 100,
            //         child: Image.asset(
            //           'assets/images/player_${playerColor}_off.png',
            //           gaplessPlayback: true,
            //         ),
            //       ),
            //     ),

            //     GestureDetector(
            //       onTap: (){
            //         widget.game.audioManager.playSound('click');
            //         setState(() {
            //           widget.game.playerColorIndex++;
            //           if (widget.game.playerColorIndex == widget.game.playerColor.length) {
            //             widget.game.playerColorIndex = 0;
            //           }
            //         });
            //       },
            //       child: SizedBox(
            //         width: 30,
            //         child: Image.asset('assets/images/arrow_button.png'),
            //       ),
            //     ),

                
            //   ],
            // ),

            const SizedBox(height: 10),

            GestureDetector(
              onTap: (){
                widget.game.audioManager.playSound('start');
                widget.game.startGame();
                setState(() {
                  _opacity = 0.0;
                });
              },
              child: SizedBox(
                width: 200,
                child: Image.asset('assets/images/start_button.png'),
              ),
            ),

            Expanded(
              child: Align(
                alignment: Alignment.bottomRight,
                child: Padding(
                  padding: const EdgeInsets.all(30),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        onPressed: (){
                          setState(() {
                            widget.game.audioManager.toggleMusic();
                          });
                        }, 
                        icon: Icon(
                          widget.game.audioManager.musicEnabled ? 
                          Icons.music_note_rounded :
                          Icons.music_off_rounded,
                          color: widget.game.audioManager.musicEnabled ? 
                                Colors.white :
                                Colors.grey,
                          size: 30,
                        ),
                      ),

                      // IconButton(
                      //   onPressed: (){
                      //     setState(() {
                      //       widget.game.audioManager.toggleSounds();
                      //     });
                      //   }, 
                      //   icon: Icon(
                      //     widget.game.audioManager.soundsEnabled ? 
                      //     Icons.volume_up_rounded :
                      //     Icons.volume_off_rounded,
                      //     color: widget.game.audioManager.soundsEnabled ? 
                      //           Colors.white :
                      //           Colors.grey,
                      //     size: 30,
                      //   ),
                      // ),
                    ],
                  ),
                ),
              )
            ),
          ],
        )
      ),
    );
  }

  void _getBestScore() async {
    final newScore = widget.game.score;
    int bestScore = await StorageManager().getSavedInt(StorageKey.score) ?? 0;

    if (newScore > bestScore) {
      bestScore = newScore;
      await StorageManager().saveInt(StorageKey.score, newScore);
    }
    
    setState(() {
      _bestScore = bestScore.toString();
    });
  }

  Widget _bestScoreText() {
    return Text(
      'Best Score: $_bestScore!',
      textAlign: TextAlign.center, // centers each line
      style: const TextStyle(
        color: Color.fromARGB(255, 187, 230, 32),
        fontSize: 24,
        fontWeight: FontWeight.bold,
      ),
    );
  }
}