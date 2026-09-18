import 'package:flutter/material.dart';
import '../models/menu_item.dart';
import '../models/category.dart';
import '../theme/app_theme.dart';
import 'product_image.dart';
import '../utils/currency_formatter.dart';

/// Card de produto no estilo "Cardap.io": foto no topo com nota em destaque,
/// nome, descrição, preço e botão "Adicionar ao Pedido" + favorito.
class MenuItemCard extends StatelessWidget {
  final MenuItem item;
  final int quantityInCart;
  final VoidCallback onTap;
  final VoidCallback onAdd;
  final bool isFavorite;
  final VoidCallback onToggleFavorite;

  const MenuItemCard({
    super.key,
    required this.item,
    required this.onTap,
    required this.onAdd,
    required this.isFavorite,
    required this.onToggleFavorite,
    this.quantityInCart = 0,
  });

  @override
  Widget build(BuildContext context) {
    final color = item.category.color;
    final outOfStock = item.isOutOfStock;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 14, offset: const Offset(0, 6))],
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              children: [
                ProductImage(
                  item: item,
                  height: 120,
                  width: double.infinity,
                  emojiSize: 48,
                ),
                Positioned(
                  top: 8,
                  right: 8,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20)),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.star, size: 13, color: Color(0xFFC9A24B)),
                        const SizedBox(width: 3),
                        Text(item.rating.toStringAsFixed(1), style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
                      ],
                    ),
                  ),
                ),
                if (outOfStock)
                  Positioned(
                    top: 8,
                    left: 8,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(color: AppTheme.danger, borderRadius: BorderRadius.circular(20)),
                      child: const Text('Esgotado', style: TextStyle(fontSize: 10, color: Colors.white, fontWeight: FontWeight.bold)),
                    ),
                  )
                else if (item.popular)
                  Positioned(
                    top: 8,
                    left: 8,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20)),
                      child: const Text('🔥 Popular', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold)),
                    ),
                  ),
              ],
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(item.name,
                        maxLines: 1, overflow: TextOverflow.ellipsis, style: AppTheme.heading(14.5, weight: FontWeight.w700)),
                    const SizedBox(height: 3),
                    Text(item.description,
                        maxLines: 2, overflow: TextOverflow.ellipsis, style: TextStyle(fontSize: 11.5, color: Colors.grey[600])),
                    const Spacer(),
                    Row(
                      children: [
                        Expanded(
                          child: Text(CurrencyFormatter.format(item.price),
                              style: TextStyle(fontWeight: FontWeight.bold, color: color, fontSize: 14)),
                        ),
                        InkWell(
                          onTap: onToggleFavorite,
                          borderRadius: BorderRadius.circular(20),
                          child: Padding(
                            padding: const EdgeInsets.all(2),
                            child: Icon(isFavorite ? Icons.favorite : Icons.favorite_border,
                                size: 18, color: isFavorite ? AppTheme.danger : Colors.grey[400]),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    SizedBox(
                      width: double.infinity,
                      height: 34,
                      child: ElevatedButton.icon(
                        onPressed: outOfStock ? null : onAdd,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.primary,
                          padding: EdgeInsets.zero,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        ),
                        icon: quantityInCart > 0
                            ? Text('$quantityInCart', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold))
                            : const Icon(Icons.add, size: 16),
                        label: Text(outOfStock ? 'Indisponível' : 'Adicionar', style: const TextStyle(fontSize: 11.5)),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
