import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // Sefrou Colors - inspired by nature
  static const Color primaryGreen = Color(0xFF2D5016); // Olive green
  static const Color accentGreen = Color(0xFF4CAF50); // Bright green
  static const Color accentGreenLight = Color(0xFF66BB6A); // Light green
  static const Color mountainWhite = Color(0xFFF5F5F5); // Mountain white
  static const Color royalPurple = Color(0xFF8B4789); // Hab El Muluk (King's Love)
  static const Color purpleLight = Color(0xFFAB68C4); // Light purple
  static const Color darkBg = Color(0xFF0F1419); // Deep dark background
  static const Color cardBg = Color(0xFF1A1F2E); // Card background
  static const Color cardBgLight = Color(0xFF252D3D); // Lighter card background
  static const Color textPrimary = Color(0xFFE8E8E8); // Primary text
  static const Color textSecondary = Color(0xFF9CA3AF); // Secondary text
  static const Color dividerColor = Color(0xFF2D3748); // Divider
  static const Color accentBlue = Color(0xFF00BCD4); // Cyan accent
  static const Color accentOrange = Color(0xFFFF9800); // Orange for day duty

  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: darkBg,
      primaryColor: primaryGreen,

      // Color Scheme
      colorScheme: const ColorScheme.dark(
        primary: primaryGreen,
        secondary: accentGreen,
        tertiary: royalPurple,
        surface: cardBg,
        error: const Color(0xFFEF5350),
      ),

      // AppBar Theme
      appBarTheme: AppBarTheme(
        backgroundColor: cardBg,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: GoogleFonts.poppins(
          fontSize: 20,
          fontWeight: FontWeight.w700,
          color: textPrimary,
          letterSpacing: 0.5,
        ),
      ),

      // Text Theme
      textTheme: TextTheme(
        displayLarge: GoogleFonts.poppins(
          fontSize: 32,
          fontWeight: FontWeight.w700,
          color: textPrimary,
          letterSpacing: 0.5,
        ),
        displayMedium: GoogleFonts.poppins(
          fontSize: 28,
          fontWeight: FontWeight.w600,
          color: textPrimary,
          letterSpacing: 0.3,
        ),
        headlineSmall: GoogleFonts.poppins(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: textPrimary,
          letterSpacing: 0.2,
        ),
        bodyLarge: GoogleFonts.poppins(
          fontSize: 16,
          fontWeight: FontWeight.w500,
          color: textPrimary,
        ),
        bodyMedium: GoogleFonts.poppins(
          fontSize: 14,
          fontWeight: FontWeight.w400,
          color: textSecondary,
        ),
        labelSmall: GoogleFonts.poppins(
          fontSize: 12,
          fontWeight: FontWeight.w500,
          color: textSecondary,
        ),
      ),

      // Card Theme
      cardTheme: CardThemeData(
        color: cardBg,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(
            color: dividerColor,
            width: 1,
          ),
        ),
      ),

      // Button Themes
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: accentGreen,
          foregroundColor: mountainWhite,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          textStyle: GoogleFonts.poppins(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.3,
          ),
          elevation: 4,
          shadowColor: accentGreen.withOpacity(0.4),
        ),
      ),

      // Input Decoration Theme
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: cardBgLight,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: dividerColor),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: dividerColor),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: accentGreen, width: 2),
        ),
        hintStyle: GoogleFonts.poppins(
          color: textSecondary,
          fontSize: 14,
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      ),
    );
  }

  // Glassmorphism decoration
  static BoxDecoration glassDecoration({
    double opacity = 0.1,
    Color color = accentGreen,
    double borderRadius = 16,
  }) {
    return BoxDecoration(
      color: color.withOpacity(opacity),
      borderRadius: BorderRadius.circular(borderRadius),
      border: Border.all(
        color: color.withOpacity(opacity * 2),
        width: 1.5,
      ),
      boxShadow: [
        BoxShadow(
          color: color.withOpacity(opacity * 0.5),
          blurRadius: 20,
          spreadRadius: 0,
        ),
      ],
    );
  }

  // Gradient decoration
  static BoxDecoration gradientDecoration({
    Color startColor = accentGreen,
    Color endColor = royalPurple,
    double borderRadius = 16,
  }) {
    return BoxDecoration(
      gradient: LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [startColor.withOpacity(0.2), endColor.withOpacity(0.2)],
      ),
      borderRadius: BorderRadius.circular(borderRadius),
      border: Border.all(
        color: startColor.withOpacity(0.3),
        width: 1,
      ),
    );
  }

  // Surface color
  static const Color surfaceColor = cardBg;
}
