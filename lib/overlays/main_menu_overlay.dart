import 'package:flutter/material.dart';
import 'package:space_adventure/Utiles/overlay_item.dart';
import 'package:space_adventure/Utiles/storage_manager.dart';
import 'package:space_adventure/game_main.dart';
import 'package:space_adventure/overlays/score_bug_dialog.dart';
import 'package:space_adventure/overlays/reset_best_score_dialog.dart';

class MainMenuOverlay extends StatefulWidget {
  final GameMain game;
  const MainMenuOverlay({super.key, required this.game});

  @override
  State<MainMenuOverlay> createState() => _MainMenuOverlayState();
}

class _MainMenuOverlayState extends State<MainMenuOverlay> {
  double _opacity = 0.0;
  String _bestScore = 'Not set yet!\nPlay to get the best score';
  bool _scoreBugDialogChecked = false;

  // Internal modals (no Navigator / no Overlay.of)
  bool _aboutOpen = false;
  bool _termsOpen = false;

  @override
  void initState() {
    super.initState();
    _getBestScore();
    Future.microtask(() {
      if (mounted) setState(() => _opacity = 1.0);
    });
    // Show score bug dialog after first build
    WidgetsBinding.instance.addPostFrameCallback((_) => _checkScoreBugDialog());
  }

  void _checkScoreBugDialog() async {
    print('_scoreBugDialogChecked: $_scoreBugDialogChecked');
    if (_scoreBugDialogChecked) return;
    _scoreBugDialogChecked = true;
    final bestScore = await StorageManager().getSavedInt(StorageKey.score) ?? 0;
    if (!mounted) return;
    // ignore: use_build_context_synchronously
    await ScoreBugDialog.showIfNeeded(context, bestScore, _resetScore);
  }

  void _resetScore() async {
    await StorageManager().saveInt(StorageKey.score, 0);
    if (!mounted) return;
    setState(() => _bestScore = '0');
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedOpacity(
      onEnd: () {
        if (_opacity == 0) {
          widget.game.overlays.remove(Overlayitem.mainMenu.title);
        }
      },
      opacity: _opacity,
      duration: const Duration(milliseconds: 500),
      child: Padding(
        padding: const EdgeInsets.only(bottom: 24.0),
        child: Stack(
          fit: StackFit.expand, 
          children: [
            // Main centered content
            _buildMainContent(),
        
            // Bottom simple row: About (left), Terms (center), Music (right)
            _buildBottomRow(),
        
            // About modal (internal)
            if (_aboutOpen) _buildBackdropModal(child: _buildAboutCard()),
        
            // Terms modal (internal)
            if (_termsOpen) _buildBackdropModal(child: _buildTermsCard()),
          ],
        ),
      ),
    );
  }

  // ---------------- Data / logic ----------------

  void _getBestScore() async {
    final newScore = widget.game.score;
    int bestScore = await StorageManager().getSavedInt(StorageKey.score) ?? 0;

    if (newScore > bestScore) {
      bestScore = newScore;
      await StorageManager().saveInt(StorageKey.score, newScore);
    }

    if (!mounted) return;
    setState(() => _bestScore = bestScore.toString());
  }

  // ---------------- UI: main content ----------------

  Widget _buildMainContent() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildBestScoreText(),
          const SizedBox(height: 40),
          SizedBox(width: 200, child: Image.asset('assets/images/menu_icon.png')),
          buildStartButton(),
          const SizedBox(height: 16),
          buildResetBestScoreButton(),
          const SizedBox(height: 40),
        ],
      ),
    );
  }

  Widget buildStartButton() {
    return GestureDetector(
      onTap: () {
        widget.game.audioManager.playSound('start');
        widget.game.startGame();
        setState(() => _opacity = 0.0);
      },
      child: SizedBox(
        width: 200,
        child: Image.asset('assets/images/start_button.png'),
      ),
    );
  }

  Widget buildResetBestScoreButton() {
    return SizedBox(
      width: 200,
      child: DecoratedBox(
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color.fromARGB(180, 40, 0, 80),
              Color.fromARGB(180, 74, 13, 104),
              Color.fromARGB(180, 40, 0, 80),
            ],
          ),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: const Color.fromARGB(255, 89, 17, 120),
            width: 2.2,
          ),
          boxShadow: const [
            BoxShadow(
              color: Colors.black54,
              blurRadius: 10,
              spreadRadius: 1,
              offset: Offset(0, 4),
            ),
          ],
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(12),
            onTap: _showResetBestScoreDialog,
            child: Container(
              alignment: Alignment.center,
              padding: const EdgeInsets.symmetric(vertical: 14),
              child: const Text(
                'Reset Best Score',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  decoration: TextDecoration.none,
                  letterSpacing: 0.5,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _showResetBestScoreDialog() async {
    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        return ResetBestScoreDialog(onConfirm: _resetScore);
      },
    );
  }

  Widget _buildBestScoreText() {
    return Text(
      'Best Score: $_bestScore!',
      textAlign: TextAlign.center,
      style: const TextStyle(
        color: Color.fromARGB(255, 187, 230, 32),
        fontSize: 24,
        fontWeight: FontWeight.bold,
        decoration: TextDecoration.none,
      ),
    );
  }

  // ---------------- UI: bottom row ----------------

  // Three equal Expanded areas → center is truly centered, regardless of side widths.
  Widget _buildBottomRow() {
    return Positioned(
      left: 24,
      right: 24,
      bottom: 24,
      child: Row(
        children: [
          // Left: About
          Expanded(
            child: Align(
              alignment: Alignment.centerLeft,
              child: _menuTextButton(
                label: 'About',
                onPressed: () => setState(() => _aboutOpen = true),
              ),
            ),
          ),

          // Center: Terms (kept in one line; scales down if tight)
          Expanded(
            child: Center(
              child: FittedBox(
                fit: BoxFit.scaleDown,
                child: _menuTextButton(
                  label: 'Terms of Use',
                  onPressed: () => setState(() => _termsOpen = true),
                ),
              ),
            ),
          ),

          // Right: Music toggle
          Expanded(
            child: Align(
              alignment: Alignment.centerRight,
              child: IconButton(
                onPressed: () {
                  setState(() {
                    widget.game.audioManager.toggleMusic();
                  });
                },
                icon: Icon(
                  widget.game.audioManager.musicEnabled
                      ? Icons.music_note_rounded
                      : Icons.music_off_rounded,
                  color: widget.game.audioManager.musicEnabled ? Colors.white : Colors.grey,
                  size: 30,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  TextButton _menuTextButton({
    required String label,
    required VoidCallback onPressed,
  }) {
    return TextButton(
      onPressed: onPressed,
      style: TextButton.styleFrom(
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600, decoration: TextDecoration.none),
      ),
      child: Text(
        label,
        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600, decoration: TextDecoration.none),
      ),
    );
  }

  // ---------------- Internal modals (no Navigator / no Overlay) ----------------

  Widget _buildBackdropModal({required Widget child}) {
    return Positioned.fill(
      child: GestureDetector(
        onTap: () {
          setState(() {
            _aboutOpen = false;
            _termsOpen = false;
          });
        },
        child: Container(
          color: Colors.black54,
          child: Center(
            child: GestureDetector(
              onTap: () {}, // prevent closing when tapping inside the card
              child: child,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAboutCard() {
    final size = MediaQuery.of(context).size;
    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 520),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: const Color(0xFF101218),
          borderRadius: BorderRadius.circular(14),
          boxShadow: const [
            BoxShadow(
              color: Colors.black87,
              blurRadius: 20,
              spreadRadius: 2,
              offset: Offset(0, 8),
            ),
          ],
        ),
        child: ConstrainedBox(
          constraints: BoxConstraints(maxHeight: size.height * 0.8),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'About Space Adventure',
                style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 20),
              ),
              const SizedBox(height: 12),
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: const [
                      Text(
                        "Blast through an asteroid field in a fast, arcade-style shooter inspired by the classics. It's simple to pick up, but mastery takes focus and a cool head.",
                        style: TextStyle(color: Colors.white70, height: 1.3),
                      ),
                      SizedBox(height: 16),
                      Text(
                        "Quick Tips:",
                        style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700),
                      ),
                      SizedBox(height: 8),
                      _Bullet(text: "Do not move all the time—only when there is a reason."),
                      _Bullet(text: "Avoid staying too high or too low; keep a balanced lane."),
                      _Bullet(text: "Dodging asteroids is more important than destroying them."),
                      _Bullet(text: "Most important: have fun!"),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: () => setState(() => _aboutOpen = false),
                  style: TextButton.styleFrom(
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                    textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600, decoration: TextDecoration.none),
                  ),
                  child: const Text('Close'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTermsCard() {
    final size = MediaQuery.of(context).size;
    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 520),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: const Color(0xFF101218),
          borderRadius: BorderRadius.circular(14),
          boxShadow: const [
            BoxShadow(
              color: Colors.black87,
              blurRadius: 20,
              spreadRadius: 2,
              offset: Offset(0, 8),
            ),
          ],
        ),
        child: ConstrainedBox(
          constraints: BoxConstraints(maxHeight: size.height * 0.8),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Terms of Use',
                style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 20),
              ),
              const SizedBox(height: 12),
              const Expanded(
                child: SingleChildScrollView(
                  child: Text(
                    "This game is provided “as is” for entertainment only. The creators and publishers make no warranties, express or implied, including but not limited to fitness for a particular purpose or non-infringement. "
                    "By playing, you agree that the creators and publishers are not liable for any damages, losses, or issues arising from the use of the game, including data loss, device problems, or any other direct or indirect consequences. "
                    "You are responsible for your own gameplay decisions and for complying with your local laws. "
                    "If you do not agree with these terms, please do not play.",
                    style: TextStyle(color: Colors.white70, height: 1.35),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: () => setState(() => _termsOpen = false),
                  style: TextButton.styleFrom(
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                    textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600, decoration: TextDecoration.none),
                  ),
                  child: const Text('Agree & Close'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ---------------- Small reusable widgets ----------------

class _Bullet extends StatelessWidget {
  final String text;
  const _Bullet({required this.text});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("• ", style: TextStyle(color: Colors.white70, height: 1.35)),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(color: Colors.white70, height: 1.35),
            ),
          ),
        ],
      ),
    );
  }
}
