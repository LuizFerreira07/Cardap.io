import 'package:flutter/material.dart';
import '../../widgets/product_image.dart';
import 'package:provider/provider.dart';
import '../../models/category.dart';
import '../../models/menu_item.dart';
import '../../providers/menu_provider.dart';
import '../../theme/app_theme.dart';
import '../../utils/currency_formatter.dart';
import 'menu_item_form_dialog.dart';

class InventoryScreen extends StatefulWidget {
  const InventoryScreen({super.key});

  @override
  State<InventoryScreen> createState() => _InventoryScreenState();
}

class _InventoryScreenState extends State<InventoryScreen> {
  MenuCategory? _filter;
  String _query = '';

  @override
  Widget build(BuildContext context) {
    final menu = context.watch<MenuProvider>();
    final lowStockCount = menu.items.where((i) => i.isLowStock || i.isOutOfStock).length;

    final filtered = menu.items.where((i) {
      final matchesCategory = _filter == null || i.category == _filter;
      final matchesQuery = _query.isEmpty || i.name.toLowerCase().contains(_query.toLowerCase());
      return matchesCategory && matchesQuery;
    }).toList();

    return Scaffold(
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => showDialog(context: context, builder: (_) => const MenuItemFormDialog()),
        icon: const Icon(Icons.add),
        label: const Text('Novo item'),
      ),
      body: menu.isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
                  child: Row(
                    children: [
                      Expanded(child: _statBox('Total de Itens', '${menu.items.length}', Icons.inventory_2_outlined)),
                      const SizedBox(width: 12),
                      Expanded(child: _statBox('Estoque Baixo', '$lowStockCount', Icons.warning_amber_outlined, valueColor: AppTheme.danger)),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
                  child: TextField(
                    decoration: const InputDecoration(hintText: 'Buscar item...', prefixIcon: Icon(Icons.search, size: 20)),
                    onChanged: (v) => setState(() => _query = v),
                  ),
                ),
                const SizedBox(height: 14),
                SizedBox(
                  height: 40,
                  child: ListView(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    children: [
                      _catChip(null, 'Todos os Itens'),
                      for (final c in MenuCategory.values) _catChip(c, c.label),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.fromLTRB(20, 0, 20, 90),
                    itemCount: filtered.length,
                    itemBuilder: (context, index) => _itemTile(context, filtered[index]),
                  ),
                ),
              ],
            ),
    );
  }

  Widget _statBox(String title, String value, IconData icon, {Color? valueColor}) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(18)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: TextStyle(fontSize: 12, color: Colors.grey[600])),
          const SizedBox(height: 6),
          Text(value, style: AppTheme.heading(24, color: valueColor)),
        ],
      ),
    );
  }

  Widget _catChip(MenuCategory? category, String label) {
    final selected = _filter == category;
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: ChoiceChip(
        label: Row(mainAxisSize: MainAxisSize.min, children: [
          if (selected) const Padding(padding: EdgeInsets.only(right: 4), child: Icon(Icons.check, size: 14)),
          Text(label),
        ]),
        selected: selected,
        onSelected: (_) => setState(() => _filter = category),
        selectedColor: AppTheme.primary,
        labelStyle: TextStyle(color: selected ? Colors.white : AppTheme.textDark),
        backgroundColor: Colors.white,
      ),
    );
  }

  Widget _itemTile(BuildContext context, MenuItem item) {
    final statusLabel = item.isOutOfStock ? 'Esgotado' : (item.available ? 'Disponível' : 'Indisponível');
    final statusColor = item.isOutOfStock ? AppTheme.danger : (item.available ? AppTheme.olive : Colors.grey);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(18)),
      child: Row(
        children: [
          ProductImage(
            item: item,
            width: 56,
            height: 56,
            emojiSize: 24,
            borderRadius: BorderRadius.circular(14),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(child: Text(item.name, style: const TextStyle(fontWeight: FontWeight.w700), maxLines: 1, overflow: TextOverflow.ellipsis)),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(color: statusColor.withOpacity(0.12), borderRadius: BorderRadius.circular(20)),
                      child: Text(statusLabel, style: TextStyle(color: statusColor, fontSize: 10.5, fontWeight: FontWeight.bold)),
                    ),
                  ],
                ),
                Text(item.category.label, style: TextStyle(color: Colors.grey[500], fontSize: 12)),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Text(CurrencyFormatter.format(item.price), style: const TextStyle(fontWeight: FontWeight.bold)),
                    const Spacer(),
                    IconButton(
                      visualDensity: VisualDensity.compact,
                      icon: const Icon(Icons.edit_outlined, size: 19),
                      onPressed: () => showDialog(context: context, builder: (_) => MenuItemFormDialog(existing: item)),
                    ),
                    IconButton(
                      visualDensity: VisualDensity.compact,
                      icon: const Icon(Icons.delete_outline, size: 19, color: AppTheme.danger),
                      onPressed: () => _confirmDelete(context, item),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text('${item.stockUnits}', style: TextStyle(fontWeight: FontWeight.bold, color: item.isLowStock ? AppTheme.danger : AppTheme.textDark)),
                        Text('unid.', style: TextStyle(fontSize: 10, color: Colors.grey[500])),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _confirmDelete(BuildContext context, MenuItem item) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Excluir item'),
        content: Text('Deseja realmente excluir "${item.name}"?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(dialogContext), child: const Text('Cancelar')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppTheme.danger),
            onPressed: () {
              context.read<MenuProvider>().deleteItem(item.id);
              Navigator.pop(dialogContext);
            },
            child: const Text('Excluir'),
          ),
        ],
      ),
    );
  }
}
