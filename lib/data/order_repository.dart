import 'dart:convert';
import 'dart:math';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/order.dart';
import '../models/category.dart';
import 'supabase_service.dart';

class OrderRepository {
  static const _key = 'orders_v1';

  Future<List<RestaurantOrder>> loadOrders() async {
    if (SupabaseService.isConfigured) {
      if (SupabaseService.client!.auth.currentSession == null) return [];
      final rows = await SupabaseService.client!.from('orders').select('*, order_items(*)').order('created_at', ascending: false);
      return rows.map((row) => _fromRemote(asMap(row))).toList();
    }

    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_key);
    if (raw == null) {
      final seed = _seedOrders();
      await saveOrders(seed);
      return seed;
    }
    final list = jsonDecode(raw) as List;
    return list.map((e) => RestaurantOrder.fromJson(Map<String, dynamic>.from(e as Map))).toList();
  }

  Future<void> saveOrders(List<RestaurantOrder> orders) async {
    if (SupabaseService.isConfigured) {
      for (final order in orders) {
        await SupabaseService.client!.from('orders').upsert(_toRemote(order));
        await SupabaseService.client!.from('order_items').delete().eq('order_id', order.id);
        if (order.items.isNotEmpty) {
          await SupabaseService.client!.from('order_items').insert(order.items.map((item) => {
                'order_id': order.id,
                'menu_item_id': item.menuItemId,
                'name': item.name,
                'unit_price': item.unitPrice,
                'quantity': item.quantity,
                'category': item.category.name,
              }).toList());
        }
      }
      return;
    }

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_key, jsonEncode(orders.map((e) => e.toJson()).toList()));
  }

  Future<void> saveOrder(RestaurantOrder order) async {
    if (SupabaseService.isConfigured) {
      await SupabaseService.client!.from('orders').insert(_toRemote(order));
      if (order.items.isNotEmpty) {
        await SupabaseService.client!.from('order_items').insert(order.items.map((item) => {
              'order_id': order.id,
              'menu_item_id': item.menuItemId,
              'name': item.name,
              'unit_price': item.unitPrice,
              'quantity': item.quantity,
              'category': item.category.name,
            }).toList());
      }
      return;
    }
    final orders = await loadOrders();
    await saveOrders([...orders, order]);
  }

  Future<void> updateOrder(RestaurantOrder order) async {
    if (SupabaseService.isConfigured) {
      await SupabaseService.client!.from('orders').update(_toRemote(order)).eq('id', order.id);
      return;
    }
    final orders = await loadOrders();
    await saveOrders(orders.map((item) => item.id == order.id ? order : item).toList());
  }

  Map<String, dynamic> _toRemote(RestaurantOrder order) => {
        'id': order.id,
        'created_at': order.createdAt.toUtc().toIso8601String(),
        'status': order.status.name,
        'customer_name': order.customerName,
        'table_number': _tableNumber(order.mesa),
        'table_session_id': order.tableSessionId,
        'closed_at': order.closedAt?.toUtc().toIso8601String(),
        'order_type': order.type.name,
        'payment_method': order.paymentMethod.name,
        'address': order.address,
        'delivery_fee': order.deliveryFee,
        'discount': order.discount,
      };

  RestaurantOrder _fromRemote(Map<String, dynamic> row) {
    final items = asList(row['order_items']).map((item) {
      final data = asMap(item);
      return {'menuItemId': data['menu_item_id'], 'name': data['name'], 'unitPrice': data['unit_price'], 'quantity': data['quantity'], 'category': data['category']};
    }).toList();
    final table = row['table_number'];
    return RestaurantOrder.fromJson({
      'id': row['id'],
      'items': items,
      'createdAt': row['created_at'],
      'status': row['status'],
      'customerName': row['customer_name'],
      'mesa': table == null ? null : 'Mesa $table',
      'tableSessionId': row['table_session_id'],
      'closedAt': row['closed_at'],
      'type': row['order_type'],
      'paymentMethod': row['payment_method'],
      'address': row['address'],
      'deliveryFee': row['delivery_fee'],
      'discount': row['discount'],
    });
  }

  int? _tableNumber(String? mesa) {
    if (mesa == null) return null;
    final match = RegExp(r'\d+').firstMatch(mesa);
    return match == null ? null : int.tryParse(match.group(0)!);
  }

  List<RestaurantOrder> _seedOrders() {
    final random = Random(42);
    final sampleItems = [
      const OrderItem(menuItemId: 'l1', name: 'X-Burger Clássico', unitPrice: 24.90, quantity: 1, category: MenuCategory.lanches),
      const OrderItem(menuItemId: 'l2', name: 'X-Bacon Duplo', unitPrice: 32.90, quantity: 1, category: MenuCategory.lanches),
      const OrderItem(menuItemId: 'p1', name: 'Filé à Parmegiana', unitPrice: 42.00, quantity: 1, category: MenuCategory.pratos),
      const OrderItem(menuItemId: 'p3', name: 'Frango Grelhado', unitPrice: 29.90, quantity: 1, category: MenuCategory.pratos),
      const OrderItem(menuItemId: 'd1', name: 'Caipirinha', unitPrice: 18.00, quantity: 1, category: MenuCategory.drinks),
      const OrderItem(menuItemId: 'b1', name: 'Refrigerante Lata', unitPrice: 6.50, quantity: 1, category: MenuCategory.bebidas),
      const OrderItem(menuItemId: 'b4', name: 'Cerveja Long Neck', unitPrice: 10.00, quantity: 1, category: MenuCategory.bebidas),
    ];

    final orders = <RestaurantOrder>[];
    final now = DateTime.now();
    for (int day = 6; day >= 0; day--) {
      final ordersToday = 3 + random.nextInt(6);
      for (int i = 0; i < ordersToday; i++) {
        final itemsCount = 1 + random.nextInt(3);
        final items = List.generate(itemsCount, (_) {
          final base = sampleItems[random.nextInt(sampleItems.length)];
          return base.copyWith(quantity: 1 + random.nextInt(2));
        });
        final date = now.subtract(Duration(days: day, hours: random.nextInt(10)));
        orders.add(RestaurantOrder(id: 'seed-$day-$i', items: items, createdAt: date, status: OrderStatus.entregue, mesa: random.nextBool() ? 'Mesa ${1 + random.nextInt(6)}' : null, closedAt: date));
      }
    }
    return orders;
  }
}
