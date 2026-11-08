import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'app.dart';
import 'data/repositories/deck_repository.dart';
import 'providers/deck_provider.dart';
import 'providers/locale_provider.dart';
import 'providers/quiz_provider.dart';
import 'providers/study_provider.dart';
import 'providers/theme_provider.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final prefs = await SharedPreferences.getInstance();
  runApp(AppProviders(prefs: prefs, child: const FlashcardApp()));
}

/// Đăng ký toàn bộ Provider; tách riêng để widget test dùng lại.
class AppProviders extends StatelessWidget {
  const AppProviders({super.key, required this.prefs, required this.child});

  final SharedPreferences prefs;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => DeckProvider(DeckRepository(prefs)),
        ),
        ChangeNotifierProxyProvider<DeckProvider, StudyProvider>(
          create: (ctx) => StudyProvider(ctx.read<DeckProvider>()),
          update: (_, deckProvider, study) =>
              (study ?? StudyProvider(deckProvider))
                ..updateDeckProvider(deckProvider),
        ),
        ChangeNotifierProvider(create: (_) => QuizProvider()),
        ChangeNotifierProvider(create: (_) => LocaleProvider(prefs)),
        ChangeNotifierProvider(create: (_) => ThemeProvider(prefs)),
      ],
      child: child,
    );
  }
}
