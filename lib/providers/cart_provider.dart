import 'package:flutter/material.dart';
import '../models/category.dart';
import '../models/menu_item.dart';
import '../models/order.dart';

/// Linha do carrinho. Guarda uma chave própria (menuItemId + tamanho, se houver)
/// para permitir que o mesmo item apareça com tamanhos diferentes no carrinho.
class CartLine {
  final String key;
  final String menuItemId;
  final String name;
  final double unitPrice;
  final int quantity;
  final MenuCategory category;
  final String? sizeName;

  const CartLine({
    required this.key,
    required this.menuItemId,
    required this.name,
    required this.unitPrice,
    required this.quantity,
    required this.category,
    this.sizeName,
  });

  double get subtotal => unitPrice * quantity;

  CartLine copyWith({int? quantity}) => CartLine(
        key: key,
        menuItemId: menuItemId,
        name: name,
        unitPrice: unitPrice,
        quantity: quantity ?? this.quantity,
        category: category,
        sizeName: sizeName,
      );

  OrderItem toOrderItem() => OrderItem(menuItemId: menuItemId, name: name, unitPrice: unitPrice, quantity: quantity, category: category);
}

class CartProvider extends ChangeNotifier {
  final Map<String, CartLine> _lines = {};

  List<CartLine> get lines => _lines.values.toList();
  bool get isEmpty => _lines.isEmpty;
  int get totalItems => _lines.values.fold(0, (sum, l) => sum + l.quantity);
  double get subtotal => _lines.values.fold(0.0, (sum, l) => sum + l.subtotal);

  double _discount = 0;
  double get discount => _discount;
  double get total => (subtotal - _discount).clamp(0, double.infinity).toDouble();

  /// Soma a quantidade do item em todas as variações de tamanho (usado no badge do card).
  int quantityOf(String menuItemId) =>
      _lines.values.where((l) => l.menuItemId == menuItemId).fold(0, (sum, l) => sum + l.quantity);

  void add(MenuItem item, {int quantity = 1, ProductSize? size}) {
    final key = size != null ? '${item.id}::${size.name}' : item.id;
    final unitPrice = item.price + (size?.priceDelta ?? 0);
    final name = size != null ? '${item.name} (${size.name})' : item.name;
    final existing = _lines[key];
    if (existing != null) {
      _lines[key] = existing.copyWith(quantity: existing.quantity + quantity);
    } else {
      _lines[key] = CartLine(
        key: key,
        menuItemId: item.id,
        name: name,
        unitPrice: unitPrice,
        quantity: quantity,
        category: item.category,
        sizeName: size?.name,
      );
    }
    notifyListeners();
  }

  void increment(String key) {
    final existing = _lines[key];
    if (existing == null) return;
    _lines[key] = existing.copyWith(quantity: existing.quantity + 1);
    notifyListeners();
  }

  void decrement(String key) {
    final existing = _lines[key];
    if (existing == null) return;
    if (existing.quantity <= 1) {
      _lines.remove(key);
    } else {
      _lines[key] = existing.copyWith(quantity: existing.quantity - 1);
    }
    notifyListeners();
  }

  void remove(String key) {
    _lines.remove(key);
    notifyListeners();
  }

  /// Aplica um cupom de desconto simples (demonstração). Retorna true se válido.
  bool applyCoupon(String code) {
    final normalized = code.trim().toUpperCase();
    if (normalized == 'SABOR10') {
      _discount = subtotal * 0.10;
      notifyListeners();
      return true;
    }
    _discount = 0;
    notifyListeners();
    return false;
  }

  void clear() {
    _lines.clear();
    _discount = 0;
    notifyListeners();
  }
}
