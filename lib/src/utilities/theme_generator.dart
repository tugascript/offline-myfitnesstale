import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../models/enums.dart';

const MaterialColor _orangeSwatch = MaterialColor(
  _orangePrimaryValue,
  <int, Color>{
    50: Color(0xFFF9E6E1),
    100: Color(0xFFF3CFC5),
    200: Color(0xFFEDB8A9),
    300: Color(0xFFE7A08C),
    400: Color(0xFFE18970),
    500: Color(_orangePrimaryValue),
    600: Color(0xFFD86F4D),
    700: Color(0xFFD26441),
    800: Color(0xFFCC5935),
    900: Color(0xFFC14B23),
  },
);
const int _orangePrimaryValue =
    0xFFDB7B5B; // Choose the primary orange you'll use

sealed class ThemeGenerator {
  static ThemeData themeFromContext(
    BuildContext context, {
    ThemeType? themeOverride,
  }) {
    final theme = MediaQuery.of(context).platformBrightness == Brightness.dark
        ? _darkTheme
        : _lightTheme;

    if (themeOverride == null) {
      return theme;
    }

    switch (themeOverride) {
      case ThemeType.light:
        return _lightTheme;
      case ThemeType.dark:
        return _darkTheme;
      case ThemeType.system:
        return theme;
    }
  }

  static ThemeData get defaultTheme => _lightTheme;

  static ThemeData themeFromSystemSettings({
    required BuildContext context,
    ThemeType? savedTheme,
  }) {
    // If no saved theme, use system theme
    if (savedTheme == null) {
      return themeFromContext(context);
    }

    // Use saved theme preference
    switch (savedTheme) {
      case ThemeType.light:
        return _lightTheme;
      case ThemeType.dark:
        return _darkTheme;
      case ThemeType.system:
        return themeFromContext(context);
    }
  }

  static final ThemeData _darkTheme = ThemeData(
    // Define the default brightness and colors.
    useMaterial3: true,
    brightness: Brightness.dark,
    primarySwatch: _orangeSwatch,
    primaryColorDark: Colors.black,
    primaryColor: const Color(_orangePrimaryValue),
    colorScheme: ColorScheme.fromSwatch(
      primarySwatch: _orangeSwatch,
      accentColor: Colors.orangeAccent,
      brightness: Brightness.dark,
      backgroundColor: Colors.black,
      cardColor: Colors.black, // Dark grey card background
    ).copyWith(
      secondary:
          Colors.orangeAccent, // Use for UI elements that need to stand out
    ),

    // Define the default font family using Google Fonts
    textTheme:
        GoogleFonts.robotoMonoTextTheme(ThemeData.dark().textTheme).copyWith(
      displayLarge: GoogleFonts.majorMonoDisplay(
        fontSize: 72.0,
        fontWeight: FontWeight.bold,
      ),
      titleLarge: GoogleFonts.majorMonoDisplay(
        fontSize: 36.0,
        fontStyle: FontStyle.italic,
      ),
      bodyMedium: GoogleFonts.robotoMono(
        fontSize: 14.0,
        color: Colors.white,
      ),
    ),

    // Define the default `InputDecorationTheme`.
    inputDecorationTheme: InputDecorationTheme(
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(25.0),
        borderSide: const BorderSide(color: Colors.orange),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(25.0),
        borderSide: const BorderSide(color: Colors.orange),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(25.0),
        borderSide: const BorderSide(color: Colors.orangeAccent),
      ),
      labelStyle: const TextStyle(color: Colors.orange),
    ),

    // Define the default `ButtonTheme`.
    buttonTheme: ButtonThemeData(
      buttonColor: const Color(_orangePrimaryValue),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18.0)),
      textTheme: ButtonTextTheme.primary,
    ),

    // Define other custom defaults.
    scaffoldBackgroundColor: Colors.grey[900],
    appBarTheme: AppBarTheme(
      elevation: 0,
      backgroundColor: Colors.black,
      titleTextStyle: GoogleFonts.majorMonoDisplay(
        color: _orangeSwatch,
        fontSize: 20,
        fontWeight: FontWeight.bold,
      ),
    ),
    // Define the default `CardTheme`.
    cardTheme: CardThemeData(
      color: Colors.black,
      shape: const BeveledRectangleBorder(),
      elevation: 1,
    ),

    // Define the default `IconTheme`.
    iconTheme: const IconThemeData(
      color: Colors.orangeAccent,
    ),

    // Define the default `BottomNavigationBarTheme`.
    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      selectedItemColor: Colors.orangeAccent,
      unselectedItemColor: Colors.grey,
      backgroundColor: Colors.black,
      type: BottomNavigationBarType.shifting,
    ),

    // Define the floating action button theme
    floatingActionButtonTheme: const FloatingActionButtonThemeData(
      foregroundColor: Colors.black,
      backgroundColor: Colors.orangeAccent,
    ),
  );

  static final ThemeData _lightTheme = ThemeData(
    // Use Material 3
    useMaterial3: true,
    // Define the default brightness and colors.
    brightness: Brightness.light,
    primarySwatch: _orangeSwatch,
    primaryColor: const Color(_orangePrimaryValue),
    colorScheme: ColorScheme.fromSwatch(
      primarySwatch: _orangeSwatch,
      accentColor: Colors.orangeAccent,
      brightness: Brightness.light,
      backgroundColor: Colors.white,
      cardColor: Colors.white, // Light grey card background
    ).copyWith(
      secondary:
          Colors.orangeAccent, // Use for UI elements that need to stand out
    ),

    // Define the default font family using Google Fonts
    textTheme:
        GoogleFonts.robotoMonoTextTheme(ThemeData.light().textTheme).copyWith(
      displayLarge: GoogleFonts.majorMonoDisplay(
          fontSize: 72.0, fontWeight: FontWeight.bold, color: Colors.black),
      titleLarge: GoogleFonts.majorMonoDisplay(
          fontSize: 36.0, fontStyle: FontStyle.italic, color: Colors.black),
      bodyMedium: GoogleFonts.robotoMono(
        fontSize: 14.0,
        color: Colors.black,
      ),
    ),

    // Define the default `InputDecorationTheme`.
    inputDecorationTheme: InputDecorationTheme(
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(25.0),
        borderSide: const BorderSide(color: Colors.orange),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(25.0),
        borderSide: const BorderSide(color: Colors.orange),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(25.0),
        borderSide: const BorderSide(color: Colors.orangeAccent),
      ),
      labelStyle: const TextStyle(color: Colors.orange),
    ),

    // Define the default `ButtonTheme`.
    buttonTheme: ButtonThemeData(
      buttonColor: const Color(_orangePrimaryValue),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18.0)),
      textTheme: ButtonTextTheme.primary,
    ),

    // Define other custom defaults.
    scaffoldBackgroundColor: Colors.grey[100],
    appBarTheme: AppBarTheme(
      elevation: 0,
      backgroundColor: Colors.white,
      titleTextStyle: GoogleFonts.majorMonoDisplay(
        color: Colors.black,
        fontSize: 20,
        fontWeight: FontWeight.bold,
      ),
      iconTheme: IconThemeData(color: Colors.black),
    ),

    // Define the default `CardTheme`.
    cardTheme: CardThemeData(
      color: Colors.white,
      shape: const BeveledRectangleBorder(),
      elevation: 1,
    ),

    // Define the default `IconTheme`.
    iconTheme: const IconThemeData(
      color: Colors.black,
    ),

    // Define the default `BottomNavigationBarTheme`.
    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      selectedItemColor: Colors.orangeAccent,
      unselectedItemColor: Colors.grey,
      backgroundColor: Colors.white,
      type: BottomNavigationBarType.shifting,
    ),

    // Define the floating action button theme
    floatingActionButtonTheme: const FloatingActionButtonThemeData(
      foregroundColor: Colors.white,
      backgroundColor: Colors.orangeAccent,
    ),
  );
}
