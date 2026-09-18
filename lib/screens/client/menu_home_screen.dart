import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/category.dart';
import '../../providers/cart_provider.dart';
import '../../providers/favorites_provider.dart';
import '../../providers/menu_provider.dart';
import '../../theme/app_theme.dart';
import '../../widgets/category_tab_bar.dart';
import '../../widgets/menu_item_card.dart';
import '../admin/admin_login_screen.dart';
import 'cart_screen.dart';
import 'product_detail_screen.dart';

class MenuHomeScreen extends StatefulWidget {
  final int? tableNumber;
  final bool isDelivery;

  const MenuHomeScreen({super.key, this.tableNumber, this.isDelivery = false});

  @override
  State<MenuHomeScreen> createState() => _MenuHomeScreenState();
}

class _MenuHomeScreenState extends State<MenuHomeScreen> {
  MenuCategory? _selectedCategory;
  String _query = '';
  final _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _openCart() => Navigator.push(context, MaterialPageRoute(builder: (_) => CartScreen(tableNumber: widget.tableNumber, isDelivery: widget.isDelivery)));

  @override
  Widget build(BuildContext context) {
    final menu = context.watch<MenuProvider>();
    final cart = context.watch<CartProvider>();
    final favorites = context.watch<FavoritesProvider>();
    final items = menu.search(_query, category: _selectedCategory);

    return Scaffold(
      body: SafeArea(
        child: menu.isLoading
            ? const Center(child: CircularProgressIndicator())
            : CustomScrollView(
                slivers: [
                  SliverToBoxAdapter(child: _header(context, cart.totalItems)),
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(16, 4, 16, 10),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                        decoration: BoxDecoration(color: AppTheme.primary.withOpacity(.08), borderRadius: BorderRadius.circular(14)),
                        child: Row(children: [
                          Icon(widget.tableNumber != null ? Icons.table_restaurant_outlined : Icons.delivery_dining_outlined, color: AppTheme.primary, size: 20),
                          const SizedBox(width: 8),
                          Expanded(child: Text(widget.tableNumber != null ? 'Pedido na Mesa ${widget.tableNumber}' : 'Pedido para delivery', style: const TextStyle(fontWeight: FontWeight.w600, color: AppTheme.primary))),
                          Text(widget.tableNumber != null ? 'QR conectado' : 'Entrega', style: TextStyle(color: Colors.grey[600], fontSize: 12)),
                        ]),
                      ),
                    ),
                  ),
                  SliverToBoxAdapter(child: Padding(padding: const EdgeInsets.fromLTRB(16, 4, 16, 12), child: TextField(
                    controller: _searchController,
                    onChanged: (value) => setState(() => _query = value),
                    decoration: InputDecoration(hintText: 'Buscar no cardápio', prefixIcon: const Icon(Icons.search), suffixIcon: _query.isEmpty ? null : IconButton(icon: const Icon(Icons.close), onPressed: () { _searchController.clear(); setState(() => _query = ''); })),
                  ))),
                  const SliverToBoxAdapter(child: SizedBox(height: 2)),
                  SliverToBoxAdapter(child: CategoryTabBar(selected: _selectedCategory, onSelect: (category) => setState(() => _selectedCategory = category))),
                  const SliverToBoxAdapter(child: SizedBox(height: 14)),
                  if (items.isEmpty)
                    const SliverFillRemaining(hasScrollBody: false, child: Center(child: Text('Nenhum item encontrado')))
                  else
                    SliverPadding(
                      padding: const EdgeInsets.fromLTRB(16, 0, 16, 100),
                      sliver: SliverLayoutBuilder(builder: (context, constraints) {
                        final columns = constraints.crossAxisExtent >= 700 ? 4 : constraints.crossAxisExtent >= 480 ? 3 : 2;
                        return SliverGrid(
                          delegate: SliverChildBuilderDelegate((context, index) {
                            final item = items[index];
                            return MenuItemCard(
                              item: item,
                              quantityInCart: cart.quantityOf(item.id),
                              isFavorite: favorites.isFavorite(item.id),
                              onToggleFavorite: () => context.read<FavoritesProvider>().toggle(item.id),
                              onAdd: () {
                                context.read<CartProvider>().add(item);
                                ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('${item.name} adicionado'), duration: const Duration(milliseconds: 900), behavior: SnackBarBehavior.floating));
                              },
                              onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => ProductDetailScreen(item: item))),
                            );
                          }, childCount: items.length),
                          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: columns, crossAxisSpacing: 12, mainAxisSpacing: 12, childAspectRatio: columns == 2 ? 0.68 : 0.72),
                        );
                      }),
                    ),
                ],
              ),
      ),
      floatingActionButton: cart.isEmpty ? null : FloatingActionButton.extended(onPressed: _openCart, label: Text('Carrinho (${cart.totalItems})'), icon: const Icon(Icons.shopping_cart)),
    );
  }

  Widget _header(BuildContext context, int itemCount) => Padding(
        padding: const EdgeInsets.fromLTRB(16, 12, 12, 8),
        child: Row(children: [
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text('Cardáp.io', style: AppTheme.heading(25)), Text(widget.tableNumber != null ? 'Peça direto da sua mesa' : 'Receba onde estiver', style: TextStyle(color: Colors.grey[600], fontSize: 12))])),
          IconButton(tooltip: 'Painel administrativo', icon: const Icon(Icons.admin_panel_settings_outlined), onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const AdminLoginScreen()))),
          Stack(clipBehavior: Clip.none, children: [IconButton(tooltip: 'Carrinho', icon: const Icon(Icons.shopping_bag_outlined), onPressed: _openCart), if (itemCount > 0) Positioned(right: 2, top: 1, child: Container(padding: const EdgeInsets.all(4), constraints: const BoxConstraints(minWidth: 18, minHeight: 18), decoration: const BoxDecoration(color: AppTheme.danger, shape: BoxShape.circle), child: Text('$itemCount', textAlign: TextAlign.center, style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold))))]),
        ]),
      );
}
