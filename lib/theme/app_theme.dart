import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class FireflyTheme {
  // Palette
  static const Color black = Color(0xFF000000);
  static const Color white = Color(0xFFFFFFFF);
  static const Color red = Color(0xFFD71921);
  static const Color grey = Color(0xFF262626);

  static ThemeData get theme {
    return ThemeData(
      scaffoldBackgroundColor: black,
      brightness: Brightness.dark,
      primaryColor: red,

      // Text Styles
      fontFamily: GoogleFonts.inter().fontFamily,
      textTheme: TextTheme(
        headlineLarge: GoogleFonts.dotGothic16(
          fontSize: 32,
          fontWeight: FontWeight.bold,
          color: white,
        ),
        bodyMedium: GoogleFonts.inter(color: white),
      ),

      // Input Fields (Login/Search)
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: grey,
        hintStyle: TextStyle(color: white.withOpacity(0.5)),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 20,
          vertical: 18,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(
            0,
          ), // Sharp corners for industrial look
          borderSide: BorderSide.none,
        ),
        focusedBorder: const OutlineInputBorder(
          borderRadius: BorderRadius.zero,
          borderSide: BorderSide(color: red, width: 1), // Red accent on focus
        ),
      ),

      // Buttons
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: red,
          foregroundColor: white,
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.zero,
          ), // Rectangular buttons
          padding: const EdgeInsets.symmetric(vertical: 16),
          textStyle: GoogleFonts.dotGothic16(fontSize: 18, letterSpacing: 1),
        ),
      ),
    );
  }
}
