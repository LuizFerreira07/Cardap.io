import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import '../data/menu_repository.dart';
import '../models/category.dart';
import '../models/menu_item.dart';

class MenuProvider extends ChangeNotifier {
  final MenuRepository _repository = MenuRepository();
  final _uuid = const Uuid();

  List<MenuItem> _items = [];
  bool _loading = true;

  List<MenuItem> get items => _items;
  bool get isLoading => _loading;

  MenuProvider() {
    _load();
  }

  Future<void> syncCurrentItems() async {
    if (_items.isNotEmpty) await _repository.saveItems(_items);
  }

  Future<void> _load() async {
    _items = await _repository.loadItems();
    _loading = false;
    notifyListeners();
  }

  List<MenuItem> byCategory(MenuCategory category) =>
      _items.where((i) => i.category == category && i.available).toList();

  /// Busca itens disponíveis por texto e, opcionalmente, categoria.
  List<MenuItem> search(String query, {MenuCategory? category}) {
    final q = query.toLowerCase();
    return _items.where((i) {
      final matchesCategory = category == null || i.category == category;
      final matchesQuery = q.isEmpty ||
          i.name.toLowerCase().contains(q) ||
          i.description.toLowerCase().contains(q);
      return matchesCategory && matchesQuery && i.available;
    }).toList();
  }

  MenuItem? byId(String id) {
    for (final item in _items) {
      if (item.id == id) return item;
    }
    return null;
  }

  Future<void> addItem({
    required String name,
    required String description,
    required double price,
    required MenuCategory category,
    required String emoji,
    String imageUrl = '',
    bool popular = false,
    int stockUnits = 20,
  }) async {
    final item = MenuItem(
      id: _uuid.v4(),
      name: name,
      description: description,
      price: price,
      category: category,
      emoji: emoji,
      imageUrl: imageUrl,
      popular: popular,
      stockUnits: stockUnits,
    );
    _items = [..._items, item];
    await _repository.saveItems(_items);
    notifyListeners();
  }

  Future<void> updateItem(MenuItem updated) async {
    _items = _items.map((i) => i.id == updated.id ? updated : i).toList();
    await _repository.saveItems(_items);
    notifyListeners();
  }

  Future<void> deleteItem(String id) async {
    _items = _items.where((i) => i.id != id).toList();
    await _repository.saveItems(_items);
    notifyListeners();
  }

  Future<void> toggleAvailability(String id) async {
    _items = _items.map((i) => i.id == id ? i.copyWith(available: !i.available) : i).toList();
    await _repository.saveItems(_items);
    notifyListeners();
  }
}
