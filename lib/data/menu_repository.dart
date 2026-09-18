import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/menu_item.dart';
import '../models/category.dart';
import 'supabase_service.dart';

class MenuRepository {
  static const _key = 'menu_items_v3';

  Future<List<MenuItem>> loadItems() async {
    if (SupabaseService.isConfigured) {
      final rows = await SupabaseService.client!.from('menu_items').select().order('sort_order');
      if (rows.isEmpty) return _seedItems();
      return rows.map((row) => _fromRemote(asMap(row))).toList();
    }

    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_key);
    if (raw == null) {
      final seed = _seedItems();
      await saveItems(seed);
      return seed;
    }
    final list = jsonDecode(raw) as List;
    return list.map((e) => MenuItem.fromJson(Map<String, dynamic>.from(e as Map))).toList();
  }

  Future<void> saveItems(List<MenuItem> items) async {
    if (SupabaseService.isConfigured) {
      final client = SupabaseService.client!;
      final existing = await client.from('menu_items').select('id');
      final ids = items.map((item) => item.id).toSet();
      final removed = existing.map((row) => row['id'] as String).where((id) => !ids.contains(id)).toList();
      if (removed.isNotEmpty) await client.from('menu_items').delete().inFilter('id', removed);
      if (items.isNotEmpty) await client.from('menu_items').upsert(items.asMap().entries.map((entry) => _toRemote(entry.value, entry.key)).toList());
      return;
    }

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_key, jsonEncode(items.map((e) => e.toJson()).toList()));
  }

  Map<String, dynamic> _toRemote(MenuItem item, int sortOrder) => {
        'id': item.id,
        'name': item.name,
        'description': item.description,
        'price': item.price,
        'category': item.category.name,
        'emoji': item.emoji,
        'image_url': item.imageUrl,
        'available': item.available,
        'popular': item.popular,
        'rating': item.rating,
        'review_count': item.reviewCount,
        'stock_units': item.stockUnits,
        'low_stock_threshold': item.lowStockThreshold,
        'ingredients': item.ingredients,
        'sizes': item.sizes.map((size) => size.toJson()).toList(),
        'sort_order': sortOrder,
      };

  MenuItem _fromRemote(Map<String, dynamic> row) => MenuItem.fromJson({
        'id': row['id'],
        'name': row['name'],
        'description': row['description'],
        'price': row['price'],
        'category': row['category'],
        'emoji': row['emoji'],
        'imageUrl': row['image_url'] ?? '',
        'available': row['available'],
        'popular': row['popular'],
        'rating': row['rating'],
        'reviewCount': row['review_count'],
        'stockUnits': row['stock_units'],
        'lowStockThreshold': row['low_stock_threshold'],
        'ingredients': row['ingredients'] ?? const [],
        'sizes': row['sizes'] ?? const [],
      });

  static String _photo(String id) => 'https://images.unsplash.com/$id?auto=format&fit=crop&w=800&q=70';

  List<MenuItem> _seedItems() => [
        MenuItem(id: 'l1', name: 'Smash Duplo da Casa', description: 'Dois discos de fraldinha smashados na chapa, cheddar inglês derretido, cebola caramelizada, picles e maionese defumada no pão brioche.', price: 36.90, category: MenuCategory.lanches, emoji: '🍔', imageUrl: _photo('photo-1572802419224-296b0aeee0d9'), popular: true, rating: 4.9, reviewCount: 214, stockUnits: 24, ingredients: const ['Pão Brioche', 'Fraldinha 180g', 'Cheddar Inglês', 'Maionese Defumada'], sizes: const [ProductSize(name: 'Simples (1 carne)', priceDelta: -6.00), ProductSize(name: 'Duplo (o clássico)', priceDelta: 0), ProductSize(name: 'Triplo', priceDelta: 9.00)]),
        MenuItem(id: 'l2', name: 'Bacon Crocante Supremo', description: 'Dois hambúrgueres, bacon caramelizado em melaço, queijo prato e molho barbecue artesanal.', price: 39.90, category: MenuCategory.lanches, emoji: '🥓', imageUrl: _photo('photo-1607013251379-e6eecfffe234'), popular: true, rating: 4.8, reviewCount: 168, stockUnits: 18, ingredients: const ['Bacon Artesanal', 'Queijo Prato', 'Barbecue da Casa']),
        MenuItem(id: 'l3', name: 'Cheddar Melt Trufado', description: 'Blend 200g, fondue de cheddar, cebola roxa confitada e um toque de azeite trufado.', price: 42.00, category: MenuCategory.lanches, emoji: '🧀', imageUrl: _photo('photo-1571091718767-18b5b1457add'), rating: 4.7, reviewCount: 96, stockUnits: 15, ingredients: const ['Blend 200g', 'Fondue de Cheddar', 'Cebola Confitada']),
        MenuItem(id: 'l4', name: 'Veggie da Horta', description: 'Burger de grão-de-bico e beterraba, queijo coalho grelhado, rúcula e molho de iogurte com ervas.', price: 32.00, category: MenuCategory.lanches, emoji: '🥗', imageUrl: _photo('photo-1550547660-d9450f859349'), rating: 4.5, reviewCount: 57, stockUnits: 4, lowStockThreshold: 5, ingredients: const ['Grão-de-bico', 'Queijo Coalho', 'Rúcula', 'Iogurte com Ervas']),
        MenuItem(id: 'l5', name: 'Dog Artesanal da Vila', description: 'Linguiça artesanal defumada, vinagrete de tomate, mostarda dijon, batata palha e queijo ralado.', price: 26.90, category: MenuCategory.lanches, emoji: '🌭', imageUrl: _photo('photo-1638368593249-7cadb261e8b3'), rating: 4.6, reviewCount: 74, stockUnits: 20, ingredients: const ['Linguiça Defumada', 'Vinagrete', 'Mostarda Dijon']),
        MenuItem(id: 'p1', name: 'Filé à Parmegiana', description: 'Filé empanado na crosta crocante, molho pomodoro da casa e muçarela gratinada. Acompanha arroz e fritas. Serve 2 pessoas.', price: 89.00, category: MenuCategory.pratos, emoji: '🍝', imageUrl: _photo('photo-1625940951329-4e8d09f87692'), popular: true, rating: 4.8, reviewCount: 143, stockUnits: 14, ingredients: const ['Filé Mignon', 'Molho Pomodoro', 'Muçarela', 'Arroz e Fritas']),
        MenuItem(id: 'p2', name: 'Costela no Bafo com Farofa', description: 'Costela bovina assada por 12 horas, farofa de bacon, vinagrete e mandioca dourada na manteiga.', price: 98.00, category: MenuCategory.pratos, emoji: '🍖', imageUrl: _photo('photo-1544025162-d76694265947'), rating: 4.9, reviewCount: 121, stockUnits: 10, ingredients: const ['Costela Bovina', 'Farofa de Bacon', 'Mandioca', 'Vinagrete']),
        MenuItem(id: 'p3', name: 'Ancho Grelhado com Legumes', description: 'Bife ancho na brasa no ponto que você pedir, legumes salteados na manteiga de ervas e purê rústico.', price: 76.00, category: MenuCategory.pratos, emoji: '🥩', imageUrl: _photo('photo-1600555379765-f82335a7b1b0'), rating: 4.7, reviewCount: 88, stockUnits: 22, ingredients: const ['Bife Ancho', 'Legumes Salteados', 'Purê Rústico']),
        MenuItem(id: 'p4', name: 'Balde de Frango Frito', description: 'Sobrecoxas marinadas no buttermilk, empanadas na hora e servidas com dois molhos da casa.', price: 62.00, category: MenuCategory.pratos, emoji: '🍗', imageUrl: _photo('photo-1426869981800-95ebf51ce900'), rating: 4.6, reviewCount: 95, stockUnits: 3, lowStockThreshold: 5, ingredients: const ['Sobrecoxa', 'Buttermilk', 'Molho Ranch', 'Molho Picante']),
        MenuItem(id: 'p5', name: 'Fritas com Cheddar e Bacon', description: 'Batatas rústicas crocantes cobertas com cheddar cremoso, bacon em cubos e cebolinha.', price: 34.00, category: MenuCategory.pratos, emoji: '🍟', imageUrl: _photo('photo-1639744210631-209fce3e256c'), popular: true, rating: 4.7, reviewCount: 132, stockUnits: 26, ingredients: const ['Batata Rústica', 'Cheddar Cremoso', 'Bacon', 'Cebolinha']),
        MenuItem(id: 'd1', name: 'Caipirinha de Limão', description: 'Cachaça artesanal envelhecida, limão taiti macerado na hora, açúcar e muito gelo.', price: 24.00, category: MenuCategory.drinks, emoji: '🍹', imageUrl: _photo('photo-1512144981474-0003a89c0165'), popular: true, rating: 4.8, reviewCount: 156, stockUnits: 30, ingredients: const ['Cachaça Envelhecida', 'Limão Taiti', 'Açúcar'], sizes: const [ProductSize(name: 'Copo (300ml)'), ProductSize(name: 'Jarra (1L)', priceDelta: 42.00)]),
        MenuItem(id: 'd2', name: 'Tropical de Maracujá', description: 'Polpa fresca de maracujá, xarope de gengibre, hortelã e espuma cítrica. Versão sem álcool disponível.', price: 26.00, category: MenuCategory.drinks, emoji: '🥭', imageUrl: _photo('photo-1708416817517-089fccf84b7d'), rating: 4.7, reviewCount: 84, stockUnits: 25, ingredients: const ['Maracujá', 'Gengibre', 'Hortelã']),
        MenuItem(id: 'd3', name: 'Autoral da Casa', description: 'Gim nacional, licor de flores, tônica artesanal e zest de laranja-baía. Servido bem gelado.', price: 32.00, category: MenuCategory.drinks, emoji: '🍸', imageUrl: _photo('photo-1706678459249-42b1c6f9c4ef'), rating: 4.9, reviewCount: 61, stockUnits: 0, ingredients: const ['Gim Nacional', 'Tônica Artesanal', 'Laranja-baía']),
        MenuItem(id: 'd4', name: 'Mojito de Hortelã', description: 'Rum branco, hortelã fresca macerada, limão e água com gás. Refrescante do começo ao fim.', price: 28.00, category: MenuCategory.drinks, emoji: '🌿', imageUrl: _photo('photo-1666355704386-93cf5f887404'), rating: 4.6, reviewCount: 49, stockUnits: 16, ingredients: const ['Rum Branco', 'Hortelã', 'Limão']),
        MenuItem(id: 'b1', name: 'Refrigerante Lata 350ml', description: 'Escolha entre cola, guaraná, laranja ou limão. Sempre bem gelado.', price: 7.50, category: MenuCategory.bebidas, emoji: '🥤', imageUrl: _photo('photo-1658754494329-584c437202e4'), popular: true, rating: 4.3, reviewCount: 38, stockUnits: 40),
        MenuItem(id: 'b2', name: 'Chope Pilsen 500ml', description: 'Chope gelado da torneira, colarinho na medida certa, servido em caneca congelada.', price: 18.00, category: MenuCategory.bebidas, emoji: '🍺', imageUrl: _photo('photo-1613478223984-2926776f434a'), popular: true, rating: 4.8, reviewCount: 112, stockUnits: 12),
        MenuItem(id: 'b3', name: 'Água Mineral 500ml', description: 'Com ou sem gás, servida gelada com rodela de limão.', price: 6.00, category: MenuCategory.bebidas, emoji: '💧', imageUrl: _photo('photo-1603798125737-03c2ba557c16'), rating: 4.4, reviewCount: 21, stockUnits: 50),
        MenuItem(id: 'b4', name: 'Suco Natural da Fruta 500ml', description: 'Feito na hora: laranja, abacaxi com hortelã, morango ou maracujá.', price: 15.00, category: MenuCategory.bebidas, emoji: '🧃', imageUrl: _photo('photo-1580745605325-5a9b36787c61'), rating: 4.6, reviewCount: 43, stockUnits: 20),
      ];
}
