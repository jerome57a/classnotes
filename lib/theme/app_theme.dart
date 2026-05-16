// THEME LOCK: dark — source: domain signal (student productivity, night use) + reference image
// Scaffold.backgroundColor = AppTheme.backgroundDark — ALL screens

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // Primary palette
  static const Color primary = Color(0xFF7C6AFA);
  static const Color primaryLight = Color(0xFFA78BFA);
  static const Color primaryContainer = Color(0xFF2D2550);

  // Semantic colors
  static const Color success = Color(0xFF22C55E);
  static const Color warning = Color(0xFFF59E0B);
  static const Color error = Color(0xFFEF4444);
  static const Color info = Color(0xFF38BDF8);

  // Subject accent colors
  static const Color subjectMath = Color(0xFF7C6AFA);
  static const Color subjectPhysics = Color(0xFF38BDF8);
  static const Color subjectChemistry = Color(0xFF22C55E);
  static const Color subjectBiology = Color(0xFFF59E0B);
  static const Color subjectHistory = Color(0xFFF97316);
  static const Color subjectLiterature = Color(0xFFEC4899);
  static const Color subjectCS = Color(0xFF06B6D4);
  static const Color subjectDefault = Color(0xFF94A3B8);

  // Light theme surfaces
  static const Color surfaceLight = Color(0xFFF8F7FF);
  static const Color backgroundLight = Color(0xFFF1F0F9);
  static const Color cardLight = Color(0xFFFFFFFF);

  // ----------------------------------------------------
  // CHANGE DASHBOARD BACKGROUND COLORS HERE
  // ----------------------------------------------------
  static const Color backgroundDark = Color(0xFF13111E);      // Main background screen canvas color
  static const Color surfaceDark = Color(0xFF1E1A2E);         // Base surface container card backgrounds
  static const Color surfaceVariantDark = Color(0xFF252238);  // Alternate input selection & navigation bar fills
  static const Color cardDark = Color(0xCC1E1A2E);            // Translucent glass card background blends
  // ----------------------------------------------------

  static ThemeData get lightTheme => ThemeData(
    useMaterial3: true,
    colorScheme: const ColorScheme.light(
      primary: primary,
      onPrimary: Colors.white,
      primaryContainer: Color(0xFFEDE9FF),
      onPrimaryContainer: Color(0xFF2D2550),
      secondary: primaryLight,
      onSecondary: Colors.white,
      surface: surfaceLight,
      onSurface: Color(0xFF1A1A2E),
      surfaceContainerHighest: Color(0xFFE8E4FF),
      error: error,
      onError: Colors.white,
      outline: Color(0xFFCBD5E1),
      outlineVariant: Color(0xFFE2E8F0),
    ),
    scaffoldBackgroundColor: backgroundLight,
    textTheme: GoogleFonts.manropeTextTheme().copyWith(
      displayLarge: GoogleFonts.manrope(
        fontSize: 40,
        fontWeight: FontWeight.w800,
        color: const Color(0xFF1A1A2E),
      ),
      displayMedium: GoogleFonts.manrope(
        fontSize: 32,
        fontWeight: FontWeight.w700,
        color: const Color(0xFF1A1A2E),
      ),
      headlineLarge: GoogleFonts.manrope(
        fontSize: 24,
        fontWeight: FontWeight.w700,
        color: const Color(0xFF1A1A2E),
      ),
      headlineMedium: GoogleFonts.manrope(
        fontSize: 20,
        fontWeight: FontWeight.w600,
        color: const Color(0xFF1A1A2E),
      ),
      titleLarge: GoogleFonts.manrope(
        fontSize: 18,
        fontWeight: FontWeight.w600,
        color: const Color(0xFF1A1A2E),
      ),
      titleMedium: GoogleFonts.manrope(
        fontSize: 15,
        fontWeight: FontWeight.w600,
        color: const Color(0xFF1A1A2E),
      ),
      bodyLarge: GoogleFonts.manrope(
        fontSize: 14,
        fontWeight: FontWeight.w400,
        color: const Color(0xFF334155),
      ),
      bodyMedium: GoogleFonts.manrope(
        fontSize: 13,
        fontWeight: FontWeight.w400,
        color: const Color(0xFF475569),
      ),
      labelSmall: GoogleFonts.manrope(
        fontSize: 11,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.3,
        color: const Color(0xFF64748B),
      ),
    ),
    appBarTheme: AppBarThemeData(
      backgroundColor: Colors.transparent,
      elevation: 0,
      scrolledUnderElevation: 0,
      titleTextStyle: GoogleFonts.manrope(
        fontSize: 18,
        fontWeight: FontWeight.w600,
        color: const Color(0xFF1A1A2E),
      ),
      iconTheme: const IconThemeData(color: Color(0xFF1A1A2E)),
    ),
    cardTheme: CardThemeData(
      color: cardLight,
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
    ),
    inputDecorationTheme: InputDecorationThemeData(
      filled: true,
      fillColor: const Color(0xFFF1F0F9),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: primary, width: 1.5),
      ),
    ),
  );

  static ThemeData get darkTheme => ThemeData(
    useMaterial3: true,
    colorScheme: const ColorScheme.dark(
      primary: primary,
      onPrimary: Colors.white,
      primaryContainer: primaryContainer,
      onPrimaryContainer: Color(0xFFEDE9FF),
      secondary: primaryLight,
      onSecondary: Colors.white,
      surface: surfaceDark,
      onSurface: Color(0xFFE2E8F0),
      surfaceContainerHighest: surfaceVariantDark,
      error: Color(0xFFFCA5A5),
      onError: Color(0xFF7F1D1D),
      outline: Color(0xFF3A3554),
      outlineVariant: Color(0xFF2A2640),
    ),
    scaffoldBackgroundColor: backgroundDark,
    textTheme: GoogleFonts.manropeTextTheme().copyWith(
      displayLarge: GoogleFonts.manrope(
        fontSize: 40,
        fontWeight: FontWeight.w800,
        color: const Color(0xFFE2E8F0),
      ),
      displayMedium: GoogleFonts.manrope(
        fontSize: 32,
        fontWeight: FontWeight.w700,
        color: const Color(0xFFE2E8F0),
      ),
      headlineLarge: GoogleFonts.manrope(
        fontSize: 24,
        fontWeight: FontWeight.w700,
        color: const Color(0xFFE2E8F0),
      ),
      headlineMedium: GoogleFonts.manrope(
        fontSize: 20,
        fontWeight: FontWeight.w600,
        color: const Color(0xFFE2E8F0),
      ),
      titleLarge: GoogleFonts.manrope(
        fontSize: 18,
        fontWeight: FontWeight.w600,
        color: const Color(0xFFE2E8F0),
      ),
      titleMedium: GoogleFonts.manrope(
        fontSize: 15,
        fontWeight: FontWeight.w600,
        color: const Color(0xFFE2E8F0),
      ),
      bodyLarge: GoogleFonts.manrope(
        fontSize: 14,
        fontWeight: FontWeight.w400,
        color: const Color(0xFFCBD5E1),
      ),
      bodyMedium: GoogleFonts.manrope(
        fontSize: 13,
        fontWeight: FontWeight.w400,
        color: const Color(0xFF94A3B8),
      ),
      labelSmall: GoogleFonts.manrope(
        fontSize: 11,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.3,
        color: const Color(0xFF64748B),
      ),
    ),
    appBarTheme: AppBarThemeData(
      backgroundColor: Colors.transparent,
      elevation: 0,
      scrolledUnderElevation: 0,
      titleTextStyle: GoogleFonts.manrope(
        fontSize: 18,
        fontWeight: FontWeight.w600,
        color: const Color(0xFFE2E8F0),
      ),
      iconTheme: const IconThemeData(color: Color(0xFFE2E8F0)),
    ),
    cardTheme: CardThemeData(
      color: surfaceDark,
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
    ),
    inputDecorationTheme: InputDecorationThemeData(
      filled: true,
      fillColor: surfaceVariantDark,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: primary, width: 1.5),
      ),
      labelStyle: GoogleFonts.manrope(color: const Color(0xFF94A3B8), fontSize: 14),
      hintStyle: GoogleFonts.manrope(color: const Color(0xFF64748B), fontSize: 14),
      errorStyle: GoogleFonts.manrope(color: const Color(0xFFFCA5A5), fontSize: 12),
    ),
    dividerTheme: const DividerThemeData(color: Color(0xFF2A2640), thickness: 1),
    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      backgroundColor: Colors.transparent,
      selectedItemColor: primary,
      unselectedItemColor: Color(0xFF64748B),
    ),
  );

  static Color subjectColor(String subject) {
    switch (subject.toLowerCase()) {
      case 'mathematics':
      case 'math':
        return subjectMath;
      case 'physics':
        return subjectPhysics;
      case 'chemistry':
        return subjectChemistry;
      case 'biology':
        return subjectBiology;
      case 'history':
        return subjectHistory;
      case 'literature':
      case 'english':
        return subjectLiterature;
      case 'computer science':
      case 'cs':
        return subjectCS;
      default:
        return subjectDefault;
    }
  }
}
