import 'package:flutter/material.dart';

// ── Light Color Tokens ────────────────────────────────────────────────────────
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
  static const lavender = Color(0xFFF3E9FF);
  static const brown = Color(0xFF3A2C29);
  static const hint = Color(0xFFB3A6C2);
  static const toastText = Color(0xFFF4EEFB);
  static const warmPeach = Color(0xFFFFE9D6);
  static const cardShadow = Color(0x245A4678);
  static const toastShadow = Color(0x4D1E142D);
  static const line = Color(0x17382C46);
  static const lineStrong = Color(0x29382C46);
  static const glass = Color(0x8CFFFFFF);
  static const glassStrong = Color(0xB8FFFFFF);
  static const creamBlur = Color(0xDBFBF7F0);
}

// ── Dark Color Tokens ─────────────────────────────────────────────────────────
class InnerscapeColorsDark {
  static const cream = Color(0xFF1A1525);
  static const card = Color(0xFF241D35);
  static const violet = Color(0xFFC6AEE8); // same
  static const peach = Color(0xFFF6C39A); // same
  static const violetSoft = Color(0xFF4A3D72);
  static const peachSoft = Color(0xFF5C3A50);
  static const ink = Color(0xFFEAE0FA);
  static const inkSoft = Color(0xFFC5B8DD);
  static const mauve = Color(0xFFB0A2C8);
  static const lavender = Color(0xFF2A2040);
  static const brown = Color(0xFFEAE0FA); // reuse ink for dark
  static const hint = Color(0xFF8A7DA0);
  static const toastText = Color(0xFFF4EEFB); // same
  static const warmPeach = Color(0xFF3A2840);
  static const cardShadow = Color(0x59000000);
  static const toastShadow = Color(0x80000000);
  static const line = Color(0x17C6AEE8);
  static const lineStrong = Color(0x29C6AEE8);
  static const glass = Color(0xA6322446);
  static const glassStrong = Color(0xCC322446);
  static const creamBlur = Color(0xE01A1525);
}

// ── Runtime Color Extension ───────────────────────────────────────────────────
class InnerscapeThemeColors extends ThemeExtension<InnerscapeThemeColors> {
  final Color cream, card, violet, peach, violetSoft, peachSoft;
  final Color ink, inkSoft, mauve, lavender, brown, hint;
  final Color toastText, warmPeach, cardShadow, toastShadow;
  final Color line, lineStrong, glass, glassStrong, creamBlur;

  const InnerscapeThemeColors({
    required this.cream, required this.card, required this.violet, required this.peach,
    required this.violetSoft, required this.peachSoft, required this.ink, required this.inkSoft,
    required this.mauve, required this.lavender, required this.brown, required this.hint,
    required this.toastText, required this.warmPeach, required this.cardShadow, required this.toastShadow,
    required this.line, required this.lineStrong, required this.glass, required this.glassStrong, required this.creamBlur,
  });

  static const light = InnerscapeThemeColors(
    cream: InnerscapeColors.cream,
    card: InnerscapeColors.card,
    violet: InnerscapeColors.violet,
    peach: InnerscapeColors.peach,
    violetSoft: InnerscapeColors.violetSoft,
    peachSoft: InnerscapeColors.peachSoft,
    ink: InnerscapeColors.ink,
    inkSoft: InnerscapeColors.inkSoft,
    mauve: InnerscapeColors.mauve,
    lavender: InnerscapeColors.lavender,
    brown: InnerscapeColors.brown,
    hint: InnerscapeColors.hint,
    toastText: InnerscapeColors.toastText,
    warmPeach: InnerscapeColors.warmPeach,
    cardShadow: InnerscapeColors.cardShadow,
    toastShadow: InnerscapeColors.toastShadow,
    line: InnerscapeColors.line,
    lineStrong: InnerscapeColors.lineStrong,
    glass: InnerscapeColors.glass,
    glassStrong: InnerscapeColors.glassStrong,
    creamBlur: InnerscapeColors.creamBlur,
  );

  static const dark = InnerscapeThemeColors(
    cream: InnerscapeColorsDark.cream,
    card: InnerscapeColorsDark.card,
    violet: InnerscapeColorsDark.violet,
    peach: InnerscapeColorsDark.peach,
    violetSoft: InnerscapeColorsDark.violetSoft,
    peachSoft: InnerscapeColorsDark.peachSoft,
    ink: InnerscapeColorsDark.ink,
    inkSoft: InnerscapeColorsDark.inkSoft,
    mauve: InnerscapeColorsDark.mauve,
    lavender: InnerscapeColorsDark.lavender,
    brown: InnerscapeColorsDark.brown,
    hint: InnerscapeColorsDark.hint,
    toastText: InnerscapeColorsDark.toastText,
    warmPeach: InnerscapeColorsDark.warmPeach,
    cardShadow: InnerscapeColorsDark.cardShadow,
    toastShadow: InnerscapeColorsDark.toastShadow,
    line: InnerscapeColorsDark.line,
    lineStrong: InnerscapeColorsDark.lineStrong,
    glass: InnerscapeColorsDark.glass,
    glassStrong: InnerscapeColorsDark.glassStrong,
    creamBlur: InnerscapeColorsDark.creamBlur,
  );

  @override
  InnerscapeThemeColors copyWith({
    Color? cream, Color? card, Color? violet, Color? peach, Color? violetSoft, Color? peachSoft,
    Color? ink, Color? inkSoft, Color? mauve, Color? lavender, Color? brown, Color? hint,
    Color? toastText, Color? warmPeach, Color? cardShadow, Color? toastShadow,
    Color? line, Color? lineStrong, Color? glass, Color? glassStrong, Color? creamBlur,
  }) {
    return InnerscapeThemeColors(
      cream: cream ?? this.cream,
      card: card ?? this.card,
      violet: violet ?? this.violet,
      peach: peach ?? this.peach,
      violetSoft: violetSoft ?? this.violetSoft,
      peachSoft: peachSoft ?? this.peachSoft,
      ink: ink ?? this.ink,
      inkSoft: inkSoft ?? this.inkSoft,
      mauve: mauve ?? this.mauve,
      lavender: lavender ?? this.lavender,
      brown: brown ?? this.brown,
      hint: hint ?? this.hint,
      toastText: toastText ?? this.toastText,
      warmPeach: warmPeach ?? this.warmPeach,
      cardShadow: cardShadow ?? this.cardShadow,
      toastShadow: toastShadow ?? this.toastShadow,
      line: line ?? this.line,
      lineStrong: lineStrong ?? this.lineStrong,
      glass: glass ?? this.glass,
      glassStrong: glassStrong ?? this.glassStrong,
      creamBlur: creamBlur ?? this.creamBlur,
    );
  }

  @override
  InnerscapeThemeColors lerp(ThemeExtension<InnerscapeThemeColors>? other, double t) {
    if (other is! InnerscapeThemeColors) return this;
    return InnerscapeThemeColors(
      cream: Color.lerp(cream, other.cream, t)!,
      card: Color.lerp(card, other.card, t)!,
      violet: Color.lerp(violet, other.violet, t)!,
      peach: Color.lerp(peach, other.peach, t)!,
      violetSoft: Color.lerp(violetSoft, other.violetSoft, t)!,
      peachSoft: Color.lerp(peachSoft, other.peachSoft, t)!,
      ink: Color.lerp(ink, other.ink, t)!,
      inkSoft: Color.lerp(inkSoft, other.inkSoft, t)!,
      mauve: Color.lerp(mauve, other.mauve, t)!,
      lavender: Color.lerp(lavender, other.lavender, t)!,
      brown: Color.lerp(brown, other.brown, t)!,
      hint: Color.lerp(hint, other.hint, t)!,
      toastText: Color.lerp(toastText, other.toastText, t)!,
      warmPeach: Color.lerp(warmPeach, other.warmPeach, t)!,
      cardShadow: Color.lerp(cardShadow, other.cardShadow, t)!,
      toastShadow: Color.lerp(toastShadow, other.toastShadow, t)!,
      line: Color.lerp(line, other.line, t)!,
      lineStrong: Color.lerp(lineStrong, other.lineStrong, t)!,
      glass: Color.lerp(glass, other.glass, t)!,
      glassStrong: Color.lerp(glassStrong, other.glassStrong, t)!,
      creamBlur: Color.lerp(creamBlur, other.creamBlur, t)!,
    );
  }
}

// ── Convenience extension on BuildContext ─────────────────────────────────────
extension InnerscapeThemeExt on BuildContext {
  InnerscapeThemeColors get colors => Theme.of(this).extension<InnerscapeThemeColors>()!;
}

// ── Text Styles ───────────────────────────────────────────────────────────────
class InnerscapeText {
  static TextStyle eyebrow({Color? color}) => TextStyle(
        fontFamily: 'BricolageGrotesque',
        fontSize: 10.5,
        letterSpacing: 0.15 * 10.5,
        fontWeight: FontWeight.w600,
        color: color ?? InnerscapeColors.mauve,
      );

  static TextStyle heading({double size = 22, Color? color}) => TextStyle(
        fontFamily: 'InstrumentSerif',
        fontSize: size,
        fontWeight: FontWeight.w400,
        color: color ?? InnerscapeColors.ink,
      );

  static TextStyle headingItalic({double size = 30, Color? color}) => TextStyle(
        fontFamily: 'InstrumentSerif',
        fontSize: size,
        fontWeight: FontWeight.w400,
        fontStyle: FontStyle.italic,
        color: color ?? InnerscapeColors.ink,
      );

  static TextStyle serifItalic({double size = 16, Color? color}) => TextStyle(
        fontFamily: 'InstrumentSerif',
        fontSize: size,
        fontStyle: FontStyle.italic,
        fontWeight: FontWeight.w400,
        color: color ?? InnerscapeColors.inkSoft,
      );

  static TextStyle body({
    double size = 13,
    FontWeight weight = FontWeight.w400,
    Color? color,
  }) =>
      TextStyle(
        fontFamily: 'BricolageGrotesque',
        fontSize: size,
        fontWeight: weight,
        color: color ?? InnerscapeColors.ink,
      );
}

// ── App Theme ─────────────────────────────────────────────────────────────────
class InnerscapeTheme {
  static ThemeData get theme => ThemeData(
        useMaterial3: false,
        brightness: Brightness.light,
        scaffoldBackgroundColor: InnerscapeColors.cream,
        colorScheme: const ColorScheme.light(
          primary: InnerscapeColors.violet,
          secondary: InnerscapeColors.peach,
          surface: InnerscapeColors.cream,
        ),
        extensions: const [InnerscapeThemeColors.light],
        fontFamily: 'BricolageGrotesque',
        appBarTheme: AppBarTheme(
          backgroundColor: InnerscapeColors.cream,
          elevation: 0,
          titleTextStyle: InnerscapeText.heading(),
          iconTheme: const IconThemeData(color: InnerscapeColors.ink),
        ),
      );

  static ThemeData get darkTheme => ThemeData(
        useMaterial3: false,
        brightness: Brightness.dark,
        scaffoldBackgroundColor: InnerscapeColorsDark.cream,
        colorScheme: const ColorScheme.dark(
          primary: InnerscapeColorsDark.violet,
          secondary: InnerscapeColorsDark.peach,
          surface: InnerscapeColorsDark.cream,
        ),
        extensions: const [InnerscapeThemeColors.dark],
        fontFamily: 'BricolageGrotesque',
        appBarTheme: AppBarTheme(
          backgroundColor: InnerscapeColorsDark.cream,
          elevation: 0,
          titleTextStyle: InnerscapeText.heading(color: InnerscapeColorsDark.ink),
          iconTheme: const IconThemeData(color: InnerscapeColorsDark.ink),
        ),
      );
}
