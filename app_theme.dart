import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  AppTheme._();

  // ── Backgrounds ─────────────────────────────
  static const Color background      = Color(0xFF07070E);
  static const Color surface         = Color(0xFF111119);
  static const Color surfaceElevated = Color(0xFF1A1A28);
  static const Color border          = Color(0xFF252538);
  static const Color borderBright    = Color(0xFF353555);

  // ── Accent ──────────────────────────────────
  /// Pharmacy  – vibrant teal-mint
  static const Color pharmacyColor  = Color(0xFF00D4B0);
  static const Color pharmacyDark   = Color(0xFF00A88C);

  /// ATM – rich amber-gold
  static const Color atmColor       = Color(0xFFFFBF47);
  static const Color atmDark        = Color(0xFFE09A00);

  /// Gas – vivid coral-red
  static const Color gasColor       = Color(0xFFFF4F6B);
  static const Color gasDark        = Color(0xFFCC2040);

  // ── Text ────────────────────────────────────
  static const Color textPrimary   = Color(0xFFF2F2FF);
  static const Color textSecondary = Color(0xFF8080A8);
  static const Color textMuted     = Color(0xFF44445C);

  // ── Status ──────────────────────────────────
  static const Color openColor   = Color(0xFF00D4B0);
  static const Color closedColor = Color(0xFFFF4F6B);

  // ── Gradient helpers ────────────────────────
  static LinearGradient pharmacyGradient({AlignmentGeometry begin = Alignment.topLeft, AlignmentGeometry end = Alignment.bottomRight}) =>
      LinearGradient(colors: const [pharmacyColor, pharmacyDark], begin: begin, end: end);

  static LinearGradient atmGradient({AlignmentGeometry begin = Alignment.topLeft, AlignmentGeometry end = Alignment.bottomRight}) =>
      LinearGradient(colors: const [atmColor, atmDark], begin: begin, end: end);

  static LinearGradient gasGradient({AlignmentGeometry begin = Alignment.topLeft, AlignmentGeometry end = Alignment.bottomRight}) =>
      LinearGradient(colors: const [gasColor, gasDark], begin: begin, end: end);

  static LinearGradient heroGradient() => const LinearGradient(
    colors: [Color(0xFF0E0E1E), Color(0xFF07070E)],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );

  /// Returns the gradient for a given color (used by service buttons & cards)
  static LinearGradient gradientFor(Color c) {
    if (c == pharmacyColor) return pharmacyGradient();
    if (c == atmColor) return atmGradient();
    return gasGradient();
  }

  // ── Shadows ─────────────────────────────────
  static List<BoxShadow> glowShadow(Color color, {double intensity = 0.25}) => [
    BoxShadow(color: color.withValues(alpha: intensity), blurRadius: 28, offset: const Offset(0, 8)),
    BoxShadow(color: color.withValues(alpha: intensity * 0.4), blurRadius: 60, offset: const Offset(0, 16)),
  ];

  static List<BoxShadow> cardShadow() => [
    BoxShadow(color: Colors.black.withValues(alpha: 0.35), blurRadius: 18, offset: const Offset(0, 6)),
  ];

  // ── Theme ────────────────────────────────────
  static ThemeData get darkTheme => ThemeData(
    brightness: Brightness.dark,
    scaffoldBackgroundColor: background,
    colorScheme: const ColorScheme.dark(
      primary: pharmacyColor,
      surface: surface,
      onSurface: textPrimary,
    ),
    textTheme: GoogleFonts.interTextTheme(
      const TextTheme(
        displayLarge: TextStyle(fontSize: 34, fontWeight: FontWeight.w800, color: textPrimary, letterSpacing: -1.2),
        displayMedium: TextStyle(fontSize: 26, fontWeight: FontWeight.w800, color: textPrimary, letterSpacing: -0.8),
        titleLarge:   TextStyle(fontSize: 20, fontWeight: FontWeight.w700, color: textPrimary, letterSpacing: -0.4),
        titleMedium:  TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: textPrimary),
        bodyLarge:    TextStyle(fontSize: 15, fontWeight: FontWeight.w400, color: textPrimary),
        bodyMedium:   TextStyle(fontSize: 13, fontWeight: FontWeight.w400, color: textSecondary),
        labelLarge:   TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: textPrimary),
      ),
    ),
    useMaterial3: true,
  );
}

