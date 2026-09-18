import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

enum MenuCategory { lanches, pratos, drinks, bebidas }

extension MenuCategoryX on MenuCategory {
  String get label {
    switch (this) {
      case MenuCategory.lanches:
        return 'Lanches';
      case MenuCategory.pratos:
        return 'Pratos Prontos';
      case MenuCategory.drinks:
        return 'Drinks';
      case MenuCategory.bebidas:
        return 'Bebidas';
    }
  }

  IconData get icon {
    switch (this) {
      case MenuCategory.lanches:
        return Icons.lunch_dining;
      case MenuCategory.pratos:
        return Icons.restaurant;
      case MenuCategory.drinks:
        return Icons.local_bar;
      case MenuCategory.bebidas:
        return Icons.local_drink;
    }
  }

  Color get color {
    switch (this) {
      case MenuCategory.lanches:
        return AppTheme.primary;
      case MenuCategory.pratos:
        return AppTheme.olive;
      case MenuCategory.drinks:
        return AppTheme.terracotta;
      case MenuCategory.bebidas:
        return AppTheme.mustard;
    }
  }

  static MenuCategory fromName(String name) =>
      MenuCategory.values.firstWhere((c) => c.name == name, orElse: () => MenuCategory.lanches);
}
