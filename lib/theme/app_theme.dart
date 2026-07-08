import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

// ── Color Tokens ──────────────────────────────────────────────────────────────
class InnerscapeColors {
  static const cream = Color(0xFFFBF7F0);
  static const card = Color(0xFFFEFCF9);
  static const violet = Color(0xFFC6AEE8);
  static const peach = Color(0xFFF6C39A);
  static const violetSoft = Color(0xFFE7DCF6);
  static const peachSoft = Color(0xFFFBE3CB);
  static const ink = Color(0xFF382C46);
  static const inkSoft = Color(0xFF5B4E6C);
  static const mauve = Color(0xFF8D8093);
  static const line = Color(0x17382C46);
  static const lineStrong = Color(0x29382C46);
  static const glass = Color(0x8CFFFFFF);
  static const glassStrong = Color(0xB8FFFFFF);
}

// ── Text Styles ───────────────────────────────────────────────────────────────
class InnerscapeText {
  static TextStyle eyebrow({Color? color}) => GoogleFonts.inter(
        fontSize: 10.5,
        letterSpacing: 0.13 * 10.5,
        fontWeight: FontWeight.w600,
        color: color ?? InnerscapeColors.mauve,
      );

  static TextStyle heading({double size = 22, Color? color}) =>
      GoogleFonts.fraunces(
        fontSize: size,
        fontWeight: FontWeight.w500,
        color: color ?? InnerscapeColors.ink,
      );

  static TextStyle headingItalic({double size = 30, Color? color}) =>
      GoogleFonts.fraunces(
        fontSize: size,
        fontWeight: FontWeight.w500,
        fontStyle: FontStyle.italic,
        color: color ?? InnerscapeColors.ink,
      );

  static TextStyle serifItalic({double size = 16, Color? color}) =>
      GoogleFonts.newsreader(
        fontSize: size,
        fontStyle: FontStyle.italic,
        fontWeight: FontWeight.w400,
        color: color ?? InnerscapeColors.inkSoft,
      );

  static TextStyle bodyInter({
    double size = 13,
    FontWeight weight = FontWeight.w400,
    Color? color,
  }) =>
      GoogleFonts.inter(
        fontSize: size,
        fontWeight: weight,
        color: color ?? InnerscapeColors.ink,
      );
}

// ── App Theme ─────────────────────────────────────────────────────────────────
class InnerscapeTheme {
  static ThemeData get theme => ThemeData(
        useMaterial3: false,
        scaffoldBackgroundColor: InnerscapeColors.cream,
        colorScheme: const ColorScheme.light(
          primary: InnerscapeColors.violet,
          secondary: InnerscapeColors.peach,
          surface: InnerscapeColors.cream,
        ),
        textTheme: GoogleFonts.interTextTheme(),
        appBarTheme: AppBarTheme(
          backgroundColor: InnerscapeColors.cream,
          elevation: 0,
          titleTextStyle: InnerscapeText.heading(),
          iconTheme: const IconThemeData(color: InnerscapeColors.ink),
        ),
      );
}
