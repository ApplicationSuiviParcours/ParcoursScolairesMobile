import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  static const Color primaryColor = Color(0xFF6B21A8); // Purple 800
  static const Color secondaryColor = Color(0xFF3B82F6); // Blue 500
  static const Color accentColor = Color(0xFF10B981); // Emerald 500
  static const Color backgroundColor = Color(0xFFF3F4F6); // Gray 100
  static const Color surfaceColor = Colors.white;
  static const Color errorColor = Color(0xFFEF4444); // Red 500
  static const Color textPrimaryColor = Color(0xFF111827); // Gray 900
  static const Color textSecondaryColor = Color(0xFF6B7280); // Gray 500

  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      colorScheme: ColorScheme.light(
        primary: const Color(0xFF6366F1), // Indigo 500
        secondary: const Color(0xFF8B5CF6), // Violet 500
        tertiary: const Color(0xFFF43F5E), // Rose 500
        surface: Colors.white,
        onSurface: textPrimaryColor,
        error: errorColor,
      ),
      scaffoldBackgroundColor: const Color(0xFFF8FAFC),
      textTheme: GoogleFonts.interTextTheme().copyWith(
        displayLarge: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 32, color: textPrimaryColor),
        displayMedium: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 24, color: textPrimaryColor),
        headlineMedium: GoogleFonts.poppins(fontWeight: FontWeight.w600, fontSize: 20, color: textPrimaryColor),
        titleLarge: GoogleFonts.poppins(fontWeight: FontWeight.w600, fontSize: 18, color: textPrimaryColor),
        bodyLarge: const TextStyle(color: textPrimaryColor, fontSize: 16),
        bodyMedium: const TextStyle(color: textSecondaryColor, fontSize: 14),
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.white,
        foregroundColor: textPrimaryColor,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: GoogleFonts.poppins(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: textPrimaryColor,
        ),
      ),
      cardTheme: CardThemeData(
        color: Colors.white,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: BorderSide(color: Colors.grey.shade100),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF6366F1),
          foregroundColor: Colors.white,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        ),
      ),
    );
  }

  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: const ColorScheme.dark(
        primary: Color(0xFF818CF8), // Indigo 400
        secondary: Color(0xFFA78BFA), // Violet 400
        tertiary: Color(0xFFFB7185), // Rose 400
        surface: Color(0xFF1E293B), // Slate 800
        onSurface: Colors.white,
        onSurfaceVariant: Color(0xFF94A3B8), // Slate 400
        error: Color(0xFFF87171), // Red 400
        background: Color(0xFF0F172A), // Slate 900
      ),
      scaffoldBackgroundColor: const Color(0xFF0F172A),
      textTheme: GoogleFonts.interTextTheme().copyWith(
        displayLarge: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 32, color: Colors.white),
        displayMedium: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 24, color: Colors.white),
        headlineMedium: GoogleFonts.poppins(fontWeight: FontWeight.w600, fontSize: 20, color: Colors.white),
        titleLarge: GoogleFonts.poppins(fontWeight: FontWeight.w600, fontSize: 18, color: Colors.white),
        bodyLarge: const TextStyle(color: Color(0xFFCBD5E1), fontSize: 16),
        bodyMedium: const TextStyle(color: Color(0xFF94A3B8), fontSize: 14),
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: Color(0xFF1E293B),
        foregroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
      ),
      cardTheme: CardThemeData(
        color: const Color(0xFF1E293B),
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: const BorderSide(color: Color(0xFF334155)),
        ),
      ),
    );
  }
}
