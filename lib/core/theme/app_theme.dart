import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // Brand Colors
  static const Color primaryBlue = Color(0xFF4DB7FF);
  static const Color yellowAccent = Color(0xFFFFE45C);
  static const Color mintGreen = Color(0xFF5ADBB5);
  static const Color white = Color(0xFFFFFFFF);
  static const Color darkText = Color(0xFF222222);
  static const Color lightGrey = Color(0xFFF5F5F5);
  static const Color grey = Color(0xFF9E9E9E);

  // Dark Space Theme Colors
  static const Color spaceDark = Color(0xFF0F172A);
  static const Color spaceSurface = Color(0xFF1E293B);
  static const Color spaceText = Color(0xFFF8FAFC);
  static const Color neonBlue = Color(0xFF38BDF8);
  static const Color neonPurple = Color(0xFFA78BFA);

  static ThemeData getLightTheme(String langCode) {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      colorScheme: ColorScheme.light(
        primary: primaryBlue,
        secondary: yellowAccent,
        tertiary: mintGreen,
        surface: white,
        onPrimary: white,
        onSecondary: darkText,
        onSurface: darkText,
      ),
      scaffoldBackgroundColor: white,
      appBarTheme: AppBarTheme(
        backgroundColor: primaryBlue,
        foregroundColor: white,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: _getFont(langCode, 24, FontWeight.bold, white),
      ),
      textTheme: _textTheme(langCode, darkText),
      elevatedButtonTheme: _elevatedButtonTheme(langCode),
      textButtonTheme: _textButtonTheme(langCode),
      cardTheme: _cardTheme(white),
    );
  }

  static ThemeData getDarkTheme(String langCode) {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: ColorScheme.dark(
        primary: neonBlue,
        secondary: neonPurple,
        tertiary: mintGreen,
        surface: spaceSurface,
        onPrimary: spaceDark,
        onSecondary: spaceText,
        onSurface: spaceText,
      ),
      scaffoldBackgroundColor: spaceDark,
      appBarTheme: AppBarTheme(
        backgroundColor: spaceDark,
        foregroundColor: neonBlue,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: _getFont(langCode, 24, FontWeight.bold, neonBlue),
      ),
      textTheme: _textTheme(langCode, spaceText),
      elevatedButtonTheme: _elevatedButtonTheme(langCode),
      textButtonTheme: _textButtonTheme(langCode),
      cardTheme: _cardTheme(spaceSurface),
    );
  }

  static TextStyle _getFont(String langCode, double size, FontWeight weight, Color color) {
    if (langCode == 'ar') {
      return GoogleFonts.cairo(fontSize: size, fontWeight: weight, color: color);
    }
    return GoogleFonts.fredoka(fontSize: size, fontWeight: weight, color: color);
  }

  static TextStyle _getSecondaryFont(String langCode, double size, FontWeight weight, Color color) {
    if (langCode == 'ar') {
      return GoogleFonts.tajawal(fontSize: size, fontWeight: weight, color: color);
    }
    return GoogleFonts.poppins(fontSize: size, fontWeight: weight, color: color);
  }

  static TextStyle _getBodyFont(String langCode, double size, Color color) {
    if (langCode == 'ar') {
      return GoogleFonts.cairo(fontSize: size, color: color);
    }
    return GoogleFonts.quicksand(fontSize: size, color: color);
  }

  static TextTheme _textTheme(String langCode, Color textColor) => TextTheme(
        displayLarge: _getFont(langCode, 32, FontWeight.bold, textColor),
        displayMedium: _getFont(langCode, 28, FontWeight.bold, textColor),
        displaySmall: _getFont(langCode, 24, FontWeight.bold, textColor),
        headlineMedium: _getFont(langCode, 20, FontWeight.w600, textColor),
        titleLarge: _getSecondaryFont(langCode, 18, FontWeight.w600, textColor),
        titleMedium: _getSecondaryFont(langCode, 16, FontWeight.w500, textColor),
        titleSmall: _getSecondaryFont(langCode, 14, FontWeight.w600, textColor),
        bodyLarge: _getBodyFont(langCode, 16, textColor),
        bodyMedium: _getBodyFont(langCode, 14, textColor),
        bodySmall: _getBodyFont(langCode, 12, textColor),
      );

  static ElevatedButtonThemeData _elevatedButtonTheme(String langCode) => ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryBlue,
          foregroundColor: white,
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          elevation: 4,
          textStyle: _getFont(langCode, 18, FontWeight.w600, white),
        ),
      );

  static TextButtonThemeData _textButtonTheme(String langCode) => TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: primaryBlue,
          textStyle: _getSecondaryFont(langCode, 16, FontWeight.w600, primaryBlue),
        ),
      );

  static CardThemeData _cardTheme(Color bgColor) => CardThemeData(
        color: bgColor,
        elevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      );

  // Gradient backgrounds
  static const LinearGradient blueGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [primaryBlue, mintGreen],
  );

  static const LinearGradient yellowGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [yellowAccent, Color(0xFFFFD54F)],
  );

  static const LinearGradient spaceGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [spaceDark, Color(0xFF080B1A)],
  );
}

