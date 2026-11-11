import 'dart:math' show pi;

import 'package:flutter/material.dart';

import '../../core/theme/app_theme.dart';
import '../../data/models/word.dart';
import '../../l10n/app_localizations.dart';

class FlashcardWidget extends StatefulWidget {
  final Word word;
  final VoidCallback onSpeak;

  const FlashcardWidget({super.key, required this.word, required this.onSpeak});

  @override
  State<FlashcardWidget> createState() => _FlashcardWidgetState();
}

class _FlashcardWidgetState extends State<FlashcardWidget> {
  bool _showFront = true;

  void _flipCard() {
    setState(() {
      _showFront = !_showFront;
    });
  }

  @override
  Widget build(BuildContext context) {
    final phonetic = widget.word.phonetic ?? '';
    final example = widget.word.example ?? '';
    final meaning = widget.word.meaning;

    return GestureDetector(
      onTap: _flipCard,
      child: Card(
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 300),
          transitionBuilder: (Widget child, Animation<double> animation) {
            final rotateAnim = Tween(begin: pi, end: 0.0).animate(animation);
            return AnimatedBuilder(
              animation: rotateAnim,
              child: child,
              builder: (context, child) {
                final isUnder = (ValueKey(_showFront) != child?.key);
                var tilt = ((animation.value - 0.5).abs() - 0.5) * 0.003;
                tilt *= isUnder ? -1.0 : 1.0;
                final val = Matrix4.rotationY(rotateAnim.value)
                  ..setEntry(3, 2, tilt);
                return Transform(
                  transform: val,
                  alignment: Alignment.center,
                  child: child,
                );
              },
            );
          },
          child: _showFront
              ? Container(
                  key: const ValueKey(true),
                  width: double.infinity,
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        widget.word.term,
                        style: Theme.of(context).textTheme.headlineMedium
                            ?.copyWith(fontWeight: FontWeight.bold),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 24),
                      IconButton(
                        icon: const Icon(Icons.volume_up),
                        onPressed: widget.onSpeak,
                      ),
                    ],
                  ),
                )
              : Container(
                  key: const ValueKey(false),
                  width: double.infinity,
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        meaning,
                        style: Theme.of(context).textTheme.headlineSmall
                            ?.copyWith(fontWeight: FontWeight.w500),
                        textAlign: TextAlign.center,
                      ),
                      // Mặt sau: nghĩa, phiên âm, ví dụ (UC07 bước 3 trong báo cáo)
                      if (phonetic.isNotEmpty) ...[
                        const SizedBox(height: 12),
                        Text(
                          phonetic,
                          style: AppTheme.monoStyle(fontSize: 18),
                          textAlign: TextAlign.center,
                        ),
                      ],
                      const SizedBox(height: 16),
                      if (example.isNotEmpty)
                        Text(
                          AppLocalizations.of(context).study_example(example),
                          style: Theme.of(context).textTheme.bodyLarge,
                          textAlign: TextAlign.center,
                        ),
                    ],
                  ),
                ),
        ),
      ),
    );
  }
}
