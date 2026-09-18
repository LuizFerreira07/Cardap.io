import 'package:flutter/material.dart';

/// Paleta central do Cardap.io extraída do logo: azul-marinho, laranja e ciano.
class AppColors {
  AppColors._();

  static const Color background = Color(0xFFF4FAFC);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color cream = Color(0xFFE8F5F8);

  static const Color brandNavy = Color(0xFF064065);
  static const Color brandBlue = Color(0xFF0B5A82);
  static const Color brandOrange = Color(0xFFFF6B2C);
  static const Color brandCyan = Color(0xFF3BC0D2);

  // Aliases semânticos mantidos para os componentes existentes.
  static const Color brownDark = brandNavy;
  static const Color brown = brandBlue;
  static const Color brownMedium = Color(0xFF277E99);
  static const Color brownLight = Color(0xFF82D2DC);

  static const Color textPrimary = Color(0xFF07324A);
  static const Color textSecondary = Color(0xFF5B7582);
  static const Color textMuted = Color(0xFF8FAAB4);

  static const Color border = Color(0xFFD7E9EE);
  static const Color divider = Color(0xFFE4F0F3);

  static const Color green = Color(0xFF3F7A5C);
  static const Color greenLight = Color(0xFFE7F2EC);
  static const Color red = Color(0xFFD9534F);
  static const Color redLight = Color(0xFFFBEAEA);
  static const Color amber = brandOrange;
  static const Color star = brandOrange;
}

class AppTheme {
  AppTheme._();

  static ThemeData get light {
    final base = ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppColors.brandNavy,
        primary: AppColors.brownDark,
        background: AppColors.background,
        surface: AppColors.surface,
      ),
      scaffoldBackgroundColor: AppColors.background,
      fontFamily: 'Roboto',
    );

    return base.copyWith(
      textTheme: base.textTheme.apply(
        bodyColor: AppColors.textPrimary,
        displayColor: AppColors.textPrimary,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.background,
        foregroundColor: AppColors.textPrimary,
        elevation: 0,
        centerTitle: true,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.brownDark,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          textStyle: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
        ),
      ),
      cardTheme: CardThemeData(
        color: AppColors.surface,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(18),
          side: const BorderSide(color: AppColors.border),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.surface,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.brownDark, width: 1.5),
        ),
      ),
    );
  }
}

class BrandLogo extends StatelessWidget {
  const BrandLogo({super.key, this.height = 42});

  final double height;

  @override
  Widget build(BuildContext context) {
    return Image.asset(
      'assets/cardapio_logo.png',
      height: height,
      fit: BoxFit.contain,
      semanticLabel: 'Cardap.io — Cardápio Online',
      // Se o asset não estiver disponível (ex.: não declarado no
      // pubspec.yaml), mostra um logo textual em vez de quebrar a tela
      // com o ícone de erro padrão do Flutter.
      errorBuilder: (context, error, stackTrace) => Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.restaurant_rounded, color: AppColors.brownDark, size: height * 0.8),
          const SizedBox(width: 6),
          Text(
            'Cardap.io',
            style: TextStyle(
              fontSize: height * 0.45,
              fontWeight: FontWeight.w900,
              color: AppColors.brownDark,
            ),
          ),
        ],
      ),
    );
  }
}

/// Card decorado com a borda arredondada padrão usada em quase
/// todas as telas (métodos de pagamento, pedidos, itens de cardápio...).
class SectionCard extends StatelessWidget {
  const SectionCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(16),
    this.selected = false,
    this.onTap,
    this.borderColor,
  });

  final Widget child;
  final EdgeInsets padding;
  final bool selected;
  final VoidCallback? onTap;
  final Color? borderColor;

  @override
  Widget build(BuildContext context) {
    final color = borderColor ??
        (selected ? AppColors.green : AppColors.border);
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(18),
      child: Container(
        padding: padding,
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: color,
            width: selected ? 1.6 : 1,
          ),
        ),
        child: child,
      ),
    );
  }
}

class StatPill extends StatelessWidget {
  const StatPill({super.key, required this.value, required this.label, this.color});
  final String value;
  final String label;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 8),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        children: [
          Text(
            value,
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: color ?? AppColors.brownDark,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
          ),
        ],
      ),
    );
  }
}
