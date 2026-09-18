import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Paleta e tipografia inspiradas no design "SaborDigital":
/// fundo creme, marrom-café como cor primária, terracota e oliva como
/// acentos, títulos em serifada e corpo em sans-serif.
class AppTheme {
  static const Color background = Color(0xFFFBF3E6);
  static const Color surface = Colors.white;
  static const Color textDark = Color(0xFF3B2A20);
  static const Color primary = Color(0xFF5B3A29); // marrom café
  static const Color primaryDark = Color(0xFF3E2718);
  static const Color terracotta = Color(0xFFD98872); // drinks / destaque quente
  static const Color olive = Color(0xFF7C8C4B); // pratos / sucesso
  static const Color mustard = Color(0xFFC9A24B); // bebidas
  static const Color slate = Color(0xFF9C948A); // neutro (sides / cancelado)
  static const Color danger = Color(0xFFC0562F);

  static TextStyle heading(double size, {Color? color, FontWeight weight = FontWeight.w700}) =>
      GoogleFonts.playfairDisplay(fontSize: size, fontWeight: weight, color: color ?? textDark);

  static TextStyle body(double size, {Color? color, FontWeight weight = FontWeight.normal}) =>
      GoogleFonts.poppins(fontSize: size, fontWeight: weight, color: color ?? textDark);

  static ThemeData get light {
    final base = ThemeData(useMaterial3: true, brightness: Brightness.light);
    return base.copyWith(
      colorScheme: base.colorScheme.copyWith(
        primary: primary,
        secondary: terracotta,
        surface: surface,
        error: danger,
      ),
      scaffoldBackgroundColor: background,
      textTheme: GoogleFonts.poppinsTextTheme(base.textTheme).apply(bodyColor: textDark, displayColor: textDark),
      appBarTheme: AppBarTheme(
        backgroundColor: background,
        foregroundColor: textDark,
        elevation: 0,
        centerTitle: false,
        titleTextStyle: heading(20),
      ),
      cardTheme: CardThemeData(
        color: surface,
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20), side: BorderSide(color: Colors.black.withOpacity(0.04))),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primary,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          textStyle: GoogleFonts.poppins(fontWeight: FontWeight.w600),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: background,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide(color: Colors.black.withOpacity(0.06))),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide(color: Colors.black.withOpacity(0.06))),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: primary)),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: surface,
        indicatorColor: primary.withOpacity(0.14),
        labelTextStyle: MaterialStateProperty.all(GoogleFonts.poppins(fontSize: 11, fontWeight: FontWeight.w600)),
      ),
      navigationRailTheme: NavigationRailThemeData(
        backgroundColor: surface,
        selectedIconTheme: const IconThemeData(color: primary),
        selectedLabelTextStyle: GoogleFonts.poppins(color: primary, fontWeight: FontWeight.w600, fontSize: 12),
        unselectedLabelTextStyle: GoogleFonts.poppins(color: Colors.grey, fontSize: 12),
      ),
      chipTheme: base.chipTheme.copyWith(
        labelStyle: GoogleFonts.poppins(fontSize: 13, fontWeight: FontWeight.w600),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      ),
    );
  }
}
