import 'package:flutter/material.dart';
import '../../models/flashcard_model.dart';

class FlashcardWidget extends StatelessWidget {
  final FlashcardModel card;

  const FlashcardWidget({Key? key, required this.card}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                card.term,
                style: theme.textTheme.headlineLarge?.copyWith(fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}