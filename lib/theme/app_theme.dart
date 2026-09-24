import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppColors {
  static const bg = Color(0xFF07070D);
  static const surface = Color(0xFF10101A);
  static const card = Color(0xFF151522);
  static const border = Color(0xFF26263A);
  static const primary = Color(0xFF7C5CFF); // violet
  static const secondary = Color(0xFF00D1B2); // teal (Flutter-ish)
  static const accent = Color(0xFF4DA3FF); // blue
  static const text = Color(0xFFEDEDF7);
  static const muted = Color(0xFF9A9AB5);

  static const gradient = LinearGradient(
    colors: [primary, accent, secondary],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}

class AppTheme {
  static ThemeData get dark {
    final base = ThemeData(
      brightness: Brightness.dark,
      useMaterial3: true,
      scaffoldBackgroundColor: AppColors.bg,
      colorScheme: const ColorScheme.dark(
        primary: AppColors.primary,
        secondary: AppColors.secondary,
        surface: AppColors.surface,
      ),
    );
    return base.copyWith(
      textTheme: GoogleFonts.interTextTheme(base.textTheme).apply(
        bodyColor: AppColors.text,
        displayColor: AppColors.text,
      ),
      textSelectionTheme: TextSelectionThemeData(
        selectionColor: AppColors.primary.withOpacity(0.35),
      ),
    );
  }

  /// Headline font — geometric, techy.
  static TextStyle display(double size, {FontWeight weight = FontWeight.w800}) =>
      GoogleFonts.spaceGrotesk(
        fontSize: size,
        fontWeight: weight,
        color: AppColors.text,
        height: 1.05,
        letterSpacing: -0.5,
      );

  static TextStyle mono(double size, {Color color = AppColors.secondary}) =>
      GoogleFonts.jetBrainsMono(fontSize: size, color: color);
}

/// Breakpoints
class Responsive {
  static bool isMobile(BuildContext c) => MediaQuery.sizeOf(c).width < 720;
  static bool isTablet(BuildContext c) {
    final w = MediaQuery.sizeOf(c).width;
    return w >= 720 && w < 1100;
  }

  static double hPad(BuildContext c) {
    final w = MediaQuery.sizeOf(c).width;
    if (w < 720) return 20;
    if (w < 1100) return 48;
    return (w - 1100) / 2 + 48;
  }
}
