import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import '../data/order_repository.dart';
import '../data/table_session_service.dart';
import '../models/category.dart';
import '../models/order.dart';

class OrderProvider extends ChangeNotifier {
  final OrderRepository _repository = OrderRepository();
  final TableSessionService _tableSessionService = TableSessionService();
  final _uuid = const Uuid();

  List<RestaurantOrder> _orders = [];
  bool _loading = true;

  List<RestaurantOrder> get orders => List.unmodifiable(_orders.reversed);
  bool get isLoading => _loading;

  OrderProvider() {
    _load();
  }

  Future<void> reload() => _load();

  Future<void> _load() async {
    try {
      _orders = await _repository.loadOrders();
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  Future<RestaurantOrder> placeOrder(
    List<OrderItem> items, {
    String? customerName,
    String? mesa,
    String? tableSessionId,
    OrderType type = OrderType.salao,
    PaymentMethod paymentMethod = PaymentMethod.fisico,
    String? address,
    double deliveryFee = 0,
    double discount = 0,
  }) async {
    final order = RestaurantOrder(
      id: _uuid.v4().substring(0, 8),
      items: items,
      createdAt: DateTime.now(),
      customerName: customerName,
      status: OrderStatus.pendente,
      mesa: mesa,
      tableSessionId: tableSessionId,
      type: type,
      paymentMethod: paymentMethod,
      address: address,
      deliveryFee: deliveryFee,
      discount: discount,
    );
    _orders = [..._orders, order];
    await _repository.saveOrder(order);
    notifyListeners();
    return order;
  }

  RestaurantOrder? byId(String orderId) {
    for (final order in _orders) {
      if (order.id == orderId) return order;
    }
    return null;
  }

  Future<void> updateStatus(String orderId, OrderStatus status) async {
    final current = byId(orderId);
    if (current == null) return;
    final closesTable = current.type == OrderType.salao && (status == OrderStatus.entregue || status == OrderStatus.cancelado);
    final updated = current.copyWith(status: status, closedAt: closesTable ? DateTime.now() : null);
    _orders = _orders.map((o) => o.id == orderId ? updated : o).toList();
    await _repository.updateOrder(updated);
    if (closesTable) {
      final tableNumber = _tableNumber(current.mesa);
      if (tableNumber != null) {
        await _tableSessionService.releaseTable(tableNumber, sessionId: current.tableSessionId);
      }
    }
    notifyListeners();
  }

  int? _tableNumber(String? mesa) {
    if (mesa == null) return null;
    final match = RegExp(r'\d+').firstMatch(mesa);
    return match == null ? null : int.tryParse(match.group(0)!);
  }

  double get totalRevenue => _orders.where((o) => o.status != OrderStatus.cancelado).fold(0.0, (sum, o) => sum + o.total);
  int get totalOrders => _orders.length;
  double get averageTicket => totalOrders == 0 ? 0 : totalRevenue / totalOrders;

  int get ordersToday {
    final now = DateTime.now();
    return _orders.where((o) => o.createdAt.year == now.year && o.createdAt.month == now.month && o.createdAt.day == now.day).length;
  }

  Map<MenuCategory, double> get revenueByCategory {
    final map = <MenuCategory, double>{for (final c in MenuCategory.values) c: 0};
    for (final order in _orders) {
      if (order.status == OrderStatus.cancelado) continue;
      for (final item in order.items) map[item.category] = (map[item.category] ?? 0) + item.subtotal;
    }
    return map;
  }

  List<MapEntry<String, int>> get topSellingItems {
    final map = <String, int>{};
    for (final order in _orders) {
      if (order.status == OrderStatus.cancelado) continue;
      for (final item in order.items) map[item.name] = (map[item.name] ?? 0) + item.quantity;
    }
    final entries = map.entries.toList()..sort((a, b) => b.value.compareTo(a.value));
    return entries.take(5).toList();
  }

  int get pendingCount => _orders.where((o) => o.status == OrderStatus.pendente).length;
  int get preparingCount => _orders.where((o) => o.status == OrderStatus.preparando).length;
  int get readyCount => _orders.where((o) => o.status == OrderStatus.pronto).length;

  double get todayRevenue {
    final now = DateTime.now();
    return _orders.where((o) => o.status != OrderStatus.cancelado && o.createdAt.year == now.year && o.createdAt.month == now.month && o.createdAt.day == now.day).fold(0.0, (sum, o) => sum + o.total);
  }

  List<MapEntry<int, int>> ordersByHour({int startHour = 10, int endHour = 22}) {
    final buckets = <int, int>{for (int h = startHour; h <= endHour; h++) h: 0};
    for (final order in _orders) {
      final h = order.createdAt.hour;
      if (buckets.containsKey(h)) buckets[h] = buckets[h]! + 1;
    }
    return buckets.entries.toList();
  }

  List<MapEntry<DateTime, double>> get revenueLast7Days {
    final now = DateTime.now();
    final result = <MapEntry<DateTime, double>>[];
    for (int i = 6; i >= 0; i--) {
      final day = DateTime(now.year, now.month, now.day).subtract(Duration(days: i));
      final revenue = _orders.where((o) => o.status != OrderStatus.cancelado && o.createdAt.year == day.year && o.createdAt.month == day.month && o.createdAt.day == day.day).fold(0.0, (sum, o) => sum + o.total);
      result.add(MapEntry(day, revenue));
    }
    return result;
  }
}
