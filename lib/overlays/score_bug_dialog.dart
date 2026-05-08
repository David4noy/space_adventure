import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ScoreBugDialog {
  static const String _dontShowAgainKey = 'score_bug_dont_show_again';

  static Future<void> showIfNeeded(BuildContext context, int score, VoidCallback onResetScore) async {
    final prefs = await SharedPreferences.getInstance();
    final dontShowAgain = prefs.getBool(_dontShowAgainKey) ?? false;
    if (dontShowAgain || score <= 500) return;
    if (!context.mounted) return;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        return Center(
          child: Material(
            color: Colors.transparent,
            child: Container(
              width: 340,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Color.fromARGB(90, 40, 0, 80),
                    Color.fromARGB(90, 68, 12, 96),
                    Color.fromARGB(90, 40, 0, 80),
                  ],
                ),
                borderRadius: BorderRadius.circular(18),
                boxShadow: const [
                  BoxShadow(
                    color: Colors.black87,
                    blurRadius: 20,
                    spreadRadius: 2,
                    offset: Offset(0, 8),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const _NoUnderlineText(
                    'Score Bug Detected',
                    style: TextStyle(
                      color: Color.fromARGB(255, 187, 230, 32),
                      fontWeight: FontWeight.bold,
                      fontSize: 22,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 18),
                  const _NoUnderlineText(
                    'It looks like you may have experienced a bug. Would you like to reset your score?',
                    style: TextStyle(color: Colors.white70, fontSize: 16, height: 1.3),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 28),
                  SizedBox(
                    width: double.infinity,
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            Color.fromARGB(255, 65, 2, 2),
                            Color.fromARGB(255, 108, 13, 13),
                            Color.fromARGB(255, 65, 2, 2),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Material(
                        color: Colors.transparent,
                        child: InkWell(
                          borderRadius: BorderRadius.circular(8),
                          onTap: () {
                            onResetScore();
                            Navigator.of(dialogContext).pop();
                          },
                          child: Container(
                            alignment: Alignment.center,
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            child: const Text(
                              'Reset Score',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 15,
                                fontWeight: FontWeight.w600,
                                decoration: TextDecoration.none,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            Color.fromARGB(255, 80, 80, 80),
                            Color.fromARGB(255, 127, 127, 127),
                            Color.fromARGB(255, 80, 80, 80),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Material(
                        color: Colors.transparent,
                        child: InkWell(
                          borderRadius: BorderRadius.circular(8),
                          onTap: () {
                            Navigator.of(dialogContext).pop();
                          },
                          child: Container(
                            alignment: Alignment.center,
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            child: const Text(
                              "Don't Reset",
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 15,
                                fontWeight: FontWeight.w600,
                                decoration: TextDecoration.none,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            Color.fromARGB(255, 30, 30, 30),
                            Color.fromARGB(255, 60, 60, 60),
                            Color.fromARGB(255, 30, 30, 30),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Material(
                        color: Colors.transparent,
                        child: InkWell(
                          borderRadius: BorderRadius.circular(8),
                          onTap: () async {
                            await prefs.setBool(_dontShowAgainKey, true);
                            if (dialogContext.mounted) {
                              Navigator.of(dialogContext).pop();
                            }
                          },
                          child: Container(
                            alignment: Alignment.center,
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            child: const Text(
                              "Don't Show Again",
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 15,
                                fontWeight: FontWeight.w600,
                                decoration: TextDecoration.none,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  // _customDialogButton is no longer needed; replaced by custom gradient buttons inline
}

class _NoUnderlineText extends StatelessWidget {
  final String data;
  final TextStyle? style;
  final TextAlign? textAlign;
  const _NoUnderlineText(this.data, {this.style, this.textAlign, super.key});
  @override
  Widget build(BuildContext context) {
    return Text(
      data,
      style: style?.copyWith(decoration: TextDecoration.none) ?? const TextStyle(decoration: TextDecoration.none),
      textAlign: textAlign,
    );
  }
}