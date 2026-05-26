import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

// ─────────────────────────────────────────
//  CHANGE COLORS ONLY HERE — rest auto updates
// ─────────────────────────────────────────
// class AppColors {
//   // Brand
//   static const Color primary = Color(0xFF4F46E5); // Indigo
//   static const Color primaryLight = Color(0xFF818CF8); // Light indigo
//   static const Color primaryDark = Color(0xFF3730A3); // Dark indigo
//   static const Color accent = Color(0xFF06B6D4); // Cyan

//   // Dark mode backgrounds
//   static const Color darkBg = Color(0xFF0F0F14);
//   static const Color darkSurface = Color(0xFF1A1A24);
//   static const Color darkSurfaceHigh = Color(0xFF22222F);
//   static const Color darkBorder = Color(0xFF2E2E3E);

//   // Light mode backgrounds
//   static const Color lightBg = Color(0xFFF8F9FC);
//   static const Color lightSurface = Color(0xFFFFFFFF);
//   static const Color lightSurfaceHigh = Color(0xFFF1F3F9);
//   static const Color lightBorder = Color(0xFFE2E5EF);

//   // Text — same for both modes (Flutter handles via Theme)
//   static const Color textPrimary = Color(0xFFFFFFFF);
//   static const Color textSecondary = Color(0xFF9094A8);
//   static const Color textHint = Color(0xFF5C5F73);
//   static const Color textDark = Color(0xFF0F0F14); // for light mode

//   // Status
//   static const Color success = Color(0xFF10B981);
//   static const Color error = Color(0xFFEF4444);
//   static const Color warning = Color(0xFFF59E0B);
//   static const Color info = Color(0xFF3B82F6);
// }

class AppColors {
  // Brand
  static const Color primary = Color(0xFF134E4A); // Deep Teal
  static const Color primaryLight = Color(0xFF0F766E); // Mid Teal
  static const Color primaryDark = Color(0xFF0D3B38); // Dark Teal
  static const Color accent = Color(0xFFFB7185); // Coral

  // Dark mode backgrounds
  static const Color darkBg = Color(0xFF0C1614); // Teal tinted dark
  static const Color darkSurface = Color(0xFF162420); // Cards
  static const Color darkSurfaceHigh = Color(0xFF1E3330); // Inputs
  static const Color darkBorder = Color(0xFF2A3F3C); // Borders

  // Light mode backgrounds
  static const Color lightBg = Color(0xFFF0FDFA); // Teal tint white
  static const Color lightSurface = Color(0xFFFFFFFF); // Cards
  static const Color lightSurfaceHigh = Color(0xFFE6FAF7); // Inputs
  static const Color lightBorder = Color(0xFFCCEDE9); // Borders

  // Text
  static const Color textPrimary = Color(0xFFFFFFFF);
  static const Color textSecondary = Color(0xFF8BA8A5); // Muted teal
  static const Color textHint = Color(0xFF4D6E6A);
  static const Color textDark = Color(0xFF0C1614);

  // Status
  static const Color success = Color(0xFF10B981);
  static const Color error = Color(0xFFEF4444);
  static const Color warning = Color(0xFFF59E0B);
  static const Color info = Color(0xFF0EA5E9);
}

// ─────────────────────────────────────────
//  THEME — DO NOT CHANGE BELOW (use AppColors above)
// ─────────────────────────────────────────
class AppTheme {
  // ── DARK ──────────────────────────────
  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: AppColors.darkBg,
      colorScheme: const ColorScheme.dark(
        primary: AppColors.primaryLight,
        secondary: AppColors.accent,
        surface: AppColors.darkSurface,
        error: AppColors.error,
        onSurface: AppColors.textPrimary, // white
        onPrimary: Colors.white,
        onSecondary: Colors.white,
        onError: Colors.white, // ✅ yeh add karo
      ),
      textTheme: _textTheme(Colors.white),
      appBarTheme: _appBarTheme(AppColors.darkBg, Colors.white),
      inputDecorationTheme: _inputTheme(
        AppColors.darkSurfaceHigh,
        AppColors.darkBorder,
      ),
      elevatedButtonTheme: _buttonTheme(),
      cardTheme: _cardTheme(AppColors.darkSurface, AppColors.darkBorder),
      dividerTheme: const DividerThemeData(
        color: AppColors.darkBorder,
        thickness: 1,
      ),
      snackBarTheme: _snackBarTheme(AppColors.darkSurface),
    );
  }

  // ── LIGHT ─────────────────────────────
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      scaffoldBackgroundColor: AppColors.lightBg,
      colorScheme: const ColorScheme.light(
        primary: AppColors.primary,
        secondary: AppColors.accent,
        surface: AppColors.lightSurface,
        error: AppColors.error,
        onSurface: AppColors.textDark, // dark text
        onPrimary: Colors.white,
        onSecondary: Colors.white,
        onError: Colors.white,
      ),
      textTheme: _textTheme(AppColors.textDark),
      appBarTheme: _appBarTheme(AppColors.lightSurface, AppColors.textDark),
      inputDecorationTheme: _inputTheme(
        AppColors.lightSurface,
        AppColors.lightBorder,
      ),
      elevatedButtonTheme: _buttonTheme(),
      cardTheme: _cardTheme(AppColors.lightSurface, AppColors.lightBorder),
      dividerTheme: const DividerThemeData(
        color: AppColors.lightBorder,
        thickness: 1,
      ),
      snackBarTheme: _snackBarTheme(AppColors.lightSurface),
    );
  }

  // ── SHARED BUILDERS ───────────────────
  static TextTheme _textTheme(Color baseColor) {
    return GoogleFonts.interTextTheme(
      TextTheme(
        displayLarge: TextStyle(
          color: baseColor,
          fontWeight: FontWeight.w700,
          fontSize: 32,
        ),
        displayMedium: TextStyle(
          color: baseColor,
          fontWeight: FontWeight.w700,
          fontSize: 28,
        ),
        headlineLarge: TextStyle(
          color: baseColor,
          fontWeight: FontWeight.w600,
          fontSize: 24,
        ),
        headlineMedium: TextStyle(
          color: baseColor,
          fontWeight: FontWeight.w600,
          fontSize: 20,
        ),
        titleLarge: TextStyle(
          color: baseColor,
          fontWeight: FontWeight.w600,
          fontSize: 18,
        ),
        titleMedium: TextStyle(
          color: baseColor,
          fontWeight: FontWeight.w500,
          fontSize: 16,
        ),
        bodyLarge: TextStyle(color: baseColor, fontSize: 16),
        bodyMedium: TextStyle(color: AppColors.textSecondary, fontSize: 14),
        labelLarge: TextStyle(
          color: baseColor,
          fontWeight: FontWeight.w600,
          fontSize: 14,
        ),
      ),
    );
  }

  static AppBarTheme _appBarTheme(Color bg, Color fg) {
    return AppBarTheme(
      backgroundColor: bg,
      elevation: 0,
      centerTitle: false,
      titleTextStyle: TextStyle(
        color: fg,
        fontSize: 18,
        fontWeight: FontWeight.w600,
        fontFamily: GoogleFonts.inter().fontFamily,
      ),
      iconTheme: IconThemeData(color: fg),
    );
  }

  static InputDecorationTheme _inputTheme(Color fill, Color borderColor) {
    return InputDecorationTheme(
      filled: true,
      fillColor: fill,
      labelStyle: const TextStyle(color: AppColors.textSecondary),
      hintStyle: const TextStyle(color: AppColors.textHint, fontSize: 14),
      contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),

      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: borderColor),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: borderColor),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.error),
      ),
    );
  }

  static ElevatedButtonThemeData _buttonTheme() {
    return ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        minimumSize: const Size(double.infinity, 52),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        elevation: 0,
        textStyle: const TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.3,
        ),
      ),
    );
  }

  static CardThemeData _cardTheme(Color color, Color borderColor) {
    return CardThemeData(
      color: color,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
        side: BorderSide(color: borderColor),
      ),
      margin: EdgeInsets.zero,
    );
  }

  static SnackBarThemeData _snackBarTheme(Color bg) {
    return SnackBarThemeData(
      backgroundColor: bg,
      contentTextStyle: const TextStyle(color: Colors.white),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      behavior: SnackBarBehavior.floating,
    );
  }
}
