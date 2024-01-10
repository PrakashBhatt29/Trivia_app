import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';

import 'providers/data_provider.dart';
import 'screens/home_page.dart';
import 'screens/prompt_page.dart';
import 'screens/game_page.dart';
import 'screens/score_page.dart';
import 'screens/credits_page.dart';

void main() {
  runApp(
    ChangeNotifierProvider(
      child: const MainApp(),
      create: (context) {
        return DataProvider();
      },
    ),
  );
}

// remove scrolling glow effect since it would appear when you can't actually scroll
// https://stackoverflow.com/questions/51119795/how-to-remove-scroll-glow
class MyScrollBehavior extends ScrollBehavior {
  @override
  Widget buildOverscrollIndicator(
      BuildContext context, Widget child, ScrollableDetails details) {
    return child;
  }
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,

      // uses class to remove scrolling glow effect from entire application
      builder: (context, child) {
        return ScrollConfiguration(
          behavior: MyScrollBehavior(),
          child: child!,
        );
      },

      // overall theme
      theme: ThemeData(
        scaffoldBackgroundColor: const Color.fromARGB(255, 206, 206, 206),
        appBarTheme: const AppBarTheme(
          backgroundColor: Color.fromARGB(255, 93, 0, 206),
        ),
        textTheme: TextTheme(
          titleLarge: GoogleFonts.vt323(
            textStyle: TextStyle(
              fontSize: MediaQuery.of(context).size.width / 7,
              color: const Color.fromARGB(255, 214, 180, 255),
            ),
          ),
          titleMedium: GoogleFonts.vt323(
            textStyle: TextStyle(
              fontSize: MediaQuery.of(context).size.width / 12,
            ),
          ),
          titleSmall: GoogleFonts.vt323(
            textStyle: TextStyle(
              fontSize: MediaQuery.of(context).size.width / 14,
              fontWeight: FontWeight.normal,
            ),
          ),
          displayLarge: GoogleFonts.vt323(
            textStyle: TextStyle(
              fontSize: MediaQuery.of(context).size.width / 12,
              color: const Color.fromARGB(255, 93, 0, 206),
              fontWeight: FontWeight.bold,
            ),
          ),
          displayMedium: GoogleFonts.vt323(
            textStyle: TextStyle(
              fontSize: MediaQuery.of(context).size.width / 13,
              color: const Color.fromARGB(255, 214, 180, 255),
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ButtonStyle(
            padding: const MaterialStatePropertyAll(EdgeInsets.all(8.0)),
            foregroundColor: const MaterialStatePropertyAll(Colors.white),
            backgroundColor:
                const MaterialStatePropertyAll(Color.fromARGB(255, 107, 33, 197)),
            shadowColor: const MaterialStatePropertyAll(Colors.black),
            elevation: const MaterialStatePropertyAll(10),
            minimumSize: MaterialStatePropertyAll(
              Size(
                MediaQuery.of(context).size.width / 2,
                MediaQuery.of(context).size.height / 13,
              ),
            ),
            side: const MaterialStatePropertyAll(
              BorderSide(
                width: 2,
                color: Colors.grey,
              ),
            ),
            textStyle: MaterialStatePropertyAll(
              GoogleFonts.vt323(
                textStyle: TextStyle(
                  fontSize: MediaQuery.of(context).size.width / 10,
                ),
              ),
            ),
          ),
        ),
      ),

      initialRoute: "/",
      routes: {
        // Main Page with Title, Play button, Highscore button, and Exit button
        "/": (context) => const HomePage(),

        // Prompt Page will prompt user for Username, Question Count, Category and Difficulty, and Start Game
        "/prompt": (context) => const PromptPage(),

        // Game Page will show Questions, Answers, Submit button, Next button, and a Game Over view
        "/game": (context) => const GamePage(),

        // Score Page will show top 10 highscores
        "/score": (context) => const ScorePage(),

        // Credits Page for documentation
        "/credits": (context) => const CreditsPage(),
      },
    );
  }
}
