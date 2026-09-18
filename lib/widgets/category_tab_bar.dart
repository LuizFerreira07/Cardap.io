import 'package:flutter/material.dart';
import '../models/category.dart';
import '../theme/app_theme.dart';

class CategoryTabBar extends StatelessWidget {
  final MenuCategory? selected; // null = "Todos"
  final ValueChanged<MenuCategory?> onSelect;

  const CategoryTabBar({super.key, required this.selected, required this.onSelect});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 44,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        children: [
          _chip(null, 'Todos', Icons.grid_view_rounded),
          for (final c in MenuCategory.values) _chip(c, c.label, c.icon),
        ],
      ),
    );
  }

  Widget _chip(MenuCategory? category, String label, IconData icon) {
    final isSelected = selected == category;
    return Padding(
      padding: const EdgeInsets.only(right: 10),
      child: InkWell(
        onTap: () => onSelect(category),
        borderRadius: BorderRadius.circular(24),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          decoration: BoxDecoration(
            color: isSelected ? AppTheme.primary : Colors.white,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: isSelected ? AppTheme.primary : Colors.black.withOpacity(0.08)),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 16, color: isSelected ? Colors.white : AppTheme.textDark),
              const SizedBox(width: 6),
              Text(label,
                  style: TextStyle(
                      color: isSelected ? Colors.white : AppTheme.textDark, fontWeight: FontWeight.w600, fontSize: 13)),
            ],
          ),
        ),
      ),
    );
  }
}
