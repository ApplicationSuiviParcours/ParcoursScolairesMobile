import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  static const Color primaryColor = Color(0xFF6366F1);
  static const Color darkBg = Color(0xFF0F172A);
  static const Color darkSurface = Color(0xFF1E293B);

  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: primaryColor,
        brightness: Brightness.light,
      ),
      scaffoldBackgroundColor: const Color(0xFFF8FAFC),
      textTheme: _textTheme(const Color(0xFF0F172A), const Color(0xFF64748B)),
      appBarTheme: const AppBarTheme(
        elevation: 0,
        centerTitle: true,
        backgroundColor: Colors.white,
        foregroundColor: Color(0xFF0F172A),
      ),
    );
  }

  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: primaryColor,
        brightness: Brightness.dark,
      ),
      scaffoldBackgroundColor: darkBg,
      textTheme: _textTheme(const Color(0xFFF8FAFC), const Color(0xFF94A3B8)),
      appBarTheme: const AppBarTheme(
        elevation: 0,
        centerTitle: true,
        backgroundColor: darkSurface,
        foregroundColor: Color(0xFFF8FAFC),
      ),
    );
  }

  static TextTheme _textTheme(Color primary, Color secondary) {
    return TextTheme(
      displayLarge: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 32, color: primary),
      headlineMedium: GoogleFonts.poppins(fontWeight: FontWeight.w700, fontSize: 20, color: primary),
      titleLarge: GoogleFonts.poppins(fontWeight: FontWeight.w600, fontSize: 18, color: primary),
      bodyLarge: GoogleFonts.inter(color: primary, fontSize: 16),
      bodyMedium: GoogleFonts.inter(color: secondary, fontSize: 14),
    );
  }
}

