import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/menu_item.dart';
import '../../models/category.dart';
import '../../providers/cart_provider.dart';
import '../../providers/favorites_provider.dart';
import '../../theme/app_theme.dart';
import '../../widgets/product_image.dart';
import '../../utils/currency_formatter.dart';

class ProductDetailScreen extends StatefulWidget {
  final MenuItem item;
  const ProductDetailScreen({super.key, required this.item});

  @override
  State<ProductDetailScreen> createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends State<ProductDetailScreen> {
  int _quantity = 1;
  ProductSize? _selectedSize;

  @override
  void initState() {
    super.initState();
    if (widget.item.sizes.isNotEmpty) {
      _selectedSize = widget.item.sizes.firstWhere((s) => s.priceDelta > 0, orElse: () => widget.item.sizes.first);
    }
  }

  double get _unitPrice => widget.item.price + (_selectedSize?.priceDelta ?? 0);

  @override
  Widget build(BuildContext context) {
    final item = widget.item;
    final color = item.category.color;
    final favorites = context.watch<FavoritesProvider>();
    final isFavorite = favorites.isFavorite(item.id);

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            pinned: true,
            backgroundColor: AppTheme.background,
            expandedHeight: 220,
            leading: _circleButton(icon: Icons.arrow_back, onTap: () => Navigator.pop(context)),
            actions: [
              _circleButton(
                icon: isFavorite ? Icons.favorite : Icons.favorite_border,
                iconColor: isFavorite ? AppTheme.danger : AppTheme.textDark,
                onTap: () => context.read<FavoritesProvider>().toggle(item.id),
              ),
              const SizedBox(width: 12),
            ],
            flexibleSpace: FlexibleSpaceBar(
              background: ProductImage(
                item: item,
                width: double.infinity,
                height: 220,
                emojiSize: 84,
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 120),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(child: Text(item.name, style: AppTheme.heading(24))),
                      Text(CurrencyFormatter.format(_unitPrice), style: AppTheme.heading(22, color: color)),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Icon(Icons.star, size: 16, color: Color(0xFFC9A24B)),
                      const SizedBox(width: 4),
                      Text(item.rating.toStringAsFixed(1), style: const TextStyle(fontWeight: FontWeight.bold)),
                      Text('  (${item.reviewCount}+ avaliações)', style: TextStyle(color: Colors.grey[600])),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Text(item.description, style: TextStyle(color: Colors.grey[700], height: 1.5)),
                  if (item.ingredients.isNotEmpty) ...[
                    const Divider(height: 40),
                    Text('Ingredientes Principais', style: AppTheme.heading(16)),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 10,
                      runSpacing: 10,
                      children: [for (final ing in item.ingredients) _ingredientChip(ing)],
                    ),
                  ],
                  if (item.sizes.isNotEmpty) ...[
                    const SizedBox(height: 28),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Escolha o Tamanho', style: AppTheme.heading(16)),
                        Text('Obrigatório', style: TextStyle(color: Colors.grey[500], fontSize: 12)),
                      ],
                    ),
                    const SizedBox(height: 12),
                    for (final size in item.sizes) _sizeOption(size, color),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                decoration: BoxDecoration(color: AppTheme.background, borderRadius: BorderRadius.circular(14)),
                child: Row(
                  children: [
                    IconButton(onPressed: () => setState(() => _quantity = _quantity > 1 ? _quantity - 1 : 1), icon: const Icon(Icons.remove)),
                    Text('$_quantity', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                    IconButton(onPressed: () => setState(() => _quantity++), icon: const Icon(Icons.add)),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 18)),
                  onPressed: item.isOutOfStock
                      ? null
                      : () {
                          context.read<CartProvider>().add(item, quantity: _quantity, size: _selectedSize);
                          Navigator.pop(context);
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('${item.name} adicionado ao carrinho'), behavior: SnackBarBehavior.floating),
                          );
                        },
                  icon: const Icon(Icons.shopping_bag_outlined),
                  label: Text('Adicionar ao Carrinho • ${CurrencyFormatter.format(_unitPrice * _quantity)}'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _circleButton({required IconData icon, required VoidCallback onTap, Color? iconColor}) {
    return Padding(
      padding: const EdgeInsets.all(4),
      child: CircleAvatar(
        backgroundColor: Colors.white,
        child: IconButton(icon: Icon(icon, color: iconColor ?? AppTheme.textDark, size: 20), onPressed: onTap),
      ),
    );
  }

  Widget _ingredientChip(String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(borderRadius: BorderRadius.circular(24), border: Border.all(color: Colors.black.withOpacity(0.1))),
      child: Text(label, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500)),
    );
  }

  Widget _sizeOption(ProductSize size, Color color) {
    final selected = _selectedSize?.name == size.name;
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: () => setState(() => _selectedSize = size),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: selected ? color : Colors.black.withOpacity(0.1), width: selected ? 2 : 1),
          ),
          child: Row(
            children: [
              Icon(selected ? Icons.radio_button_checked : Icons.radio_button_off, color: selected ? color : Colors.grey[400]),
              const SizedBox(width: 12),
              Expanded(child: Text(size.name, style: const TextStyle(fontWeight: FontWeight.w600))),
              if (size.priceDelta > 0) Text('+${CurrencyFormatter.format(size.priceDelta)}', style: TextStyle(color: Colors.grey[600])),
            ],
          ),
        ),
      ),
    );
  }
}
