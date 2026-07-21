import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class FireflyTheme {
  static const Color canvasColor = Color(0xFFFF3B00);
  static const Color darkBlock = Color(0xFF000000);
  static const Color lightBlock = Color(0xFFE5E5E5);
  static const Color textOnDark = Color(0xFFFFFFFF);
  static const Color textOnLight = Color(0xFF000000);

  static ThemeData get theme {
    return ThemeData(
      scaffoldBackgroundColor: canvasColor,
      brightness: Brightness.dark,
      primaryColor: darkBlock,
      fontFamily: GoogleFonts.shareTechMono().fontFamily,

      appBarTheme: AppBarTheme(
        backgroundColor: darkBlock,
        foregroundColor: textOnDark,
        titleTextStyle: GoogleFonts.anton(
          fontSize: 22,
          letterSpacing: 2,
          color: textOnDark,
        ),
        elevation: 0,
      ),

      textTheme: TextTheme(
        headlineLarge: GoogleFonts.anton(
          fontSize: 52,
          letterSpacing: 6,
          color: textOnDark,
        ),
        titleLarge: GoogleFonts.anton(
          fontSize: 22,
          letterSpacing: 2,
          color: textOnDark,
        ),
        bodyLarge: GoogleFonts.shareTechMono(color: textOnDark),
        bodyMedium: GoogleFonts.shareTechMono(color: textOnDark),
        bodySmall: GoogleFonts.shareTechMono(color: textOnDark),
        labelLarge: GoogleFonts.shareTechMono(color: textOnDark),
      ),

      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: darkBlock,
        hintStyle: GoogleFonts.shareTechMono(
          color: textOnDark.withValues(alpha: 0.5),
        ),
        labelStyle: GoogleFonts.shareTechMono(color: textOnDark),
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
        border: const OutlineInputBorder(
          borderRadius: BorderRadius.zero,
          borderSide: BorderSide.none,
        ),
        focusedBorder: const OutlineInputBorder(
          borderRadius: BorderRadius.zero,
          borderSide: BorderSide(color: darkBlock, width: 2),
        ),
        enabledBorder: const OutlineInputBorder(
          borderRadius: BorderRadius.zero,
          borderSide: BorderSide.none,
        ),
      ),

      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: darkBlock,
          foregroundColor: textOnDark,
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.zero,
          ),
          padding: const EdgeInsets.symmetric(vertical: 20),
          textStyle: GoogleFonts.anton(fontSize: 20, letterSpacing: 2),
        ),
      ),

      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: textOnDark,
          textStyle: GoogleFonts.shareTechMono(fontSize: 14),
        ),
      ),

      snackBarTheme: const SnackBarThemeData(
        backgroundColor: darkBlock,
        behavior: SnackBarBehavior.fixed,
        elevation: 0,
      ),
    );
  }
}
