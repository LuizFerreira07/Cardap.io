import 'category.dart';

enum OrderStatus { pendente, preparando, pronto, entregue, cancelado }

enum OrderType { salao, delivery }

enum PaymentMethod { fisico, pix, cartao }

extension OrderStatusX on OrderStatus {
  String get label {
    switch (this) {
      case OrderStatus.pendente:
        return 'Pendente';
      case OrderStatus.preparando:
        return 'Preparando';
      case OrderStatus.pronto:
        return 'Pronto';
      case OrderStatus.entregue:
        return 'Entregue / Fechado';
      case OrderStatus.cancelado:
        return 'Cancelado';
    }
  }
}

extension OrderTypeX on OrderType {
  String get label => this == OrderType.salao ? 'Salão' : 'Delivery';
}

extension PaymentMethodX on PaymentMethod {
  String get label {
    switch (this) {
      case PaymentMethod.fisico:
        return 'Pagamento físico';
      case PaymentMethod.pix:
        return 'Pix';
      case PaymentMethod.cartao:
        return 'Cartão';
    }
  }
}

class OrderItem {
  final String menuItemId;
  final String name;
  final double unitPrice;
  final int quantity;
  final MenuCategory category;

  const OrderItem({required this.menuItemId, required this.name, required this.unitPrice, required this.quantity, required this.category});

  double get subtotal => unitPrice * quantity;

  OrderItem copyWith({int? quantity}) => OrderItem(menuItemId: menuItemId, name: name, unitPrice: unitPrice, quantity: quantity ?? this.quantity, category: category);

  Map<String, dynamic> toJson() => {'menuItemId': menuItemId, 'name': name, 'unitPrice': unitPrice, 'quantity': quantity, 'category': category.name};

  factory OrderItem.fromJson(Map<String, dynamic> json) => OrderItem(menuItemId: json['menuItemId'] as String, name: json['name'] as String, unitPrice: (json['unitPrice'] as num).toDouble(), quantity: (json['quantity'] as num).toInt(), category: MenuCategoryX.fromName(json['category'] as String));
}

class RestaurantOrder {
  final String id;
  final List<OrderItem> items;
  final DateTime createdAt;
  final OrderStatus status;
  final String? customerName;
  final String? mesa;
  final String? tableSessionId;
  final DateTime? closedAt;
  final OrderType type;
  final PaymentMethod paymentMethod;
  final String? address;
  final double deliveryFee;
  final double discount;

  const RestaurantOrder({
    required this.id,
    required this.items,
    required this.createdAt,
    this.status = OrderStatus.pendente,
    this.customerName,
    this.mesa,
    this.tableSessionId,
    this.closedAt,
    this.type = OrderType.salao,
    this.paymentMethod = PaymentMethod.fisico,
    this.address,
    this.deliveryFee = 0,
    this.discount = 0,
  });

  double get subtotal => items.fold(0.0, (sum, item) => sum + item.subtotal);
  double get total => (subtotal - discount + (type == OrderType.delivery ? deliveryFee : 0)).clamp(0, double.infinity).toDouble();
  int get itemCount => items.fold(0, (sum, item) => sum + item.quantity);

  RestaurantOrder copyWith({OrderStatus? status, DateTime? closedAt}) => RestaurantOrder(id: id, items: items, createdAt: createdAt, status: status ?? this.status, customerName: customerName, mesa: mesa, tableSessionId: tableSessionId, closedAt: closedAt ?? this.closedAt, type: type, paymentMethod: paymentMethod, address: address, deliveryFee: deliveryFee, discount: discount);

  Map<String, dynamic> toJson() => {
        'id': id,
        'items': items.map((e) => e.toJson()).toList(),
        'createdAt': createdAt.toIso8601String(),
        'status': status.name,
        'customerName': customerName,
        'mesa': mesa,
        'tableSessionId': tableSessionId,
        'closedAt': closedAt?.toIso8601String(),
        'type': type.name,
        'paymentMethod': paymentMethod.name,
        'address': address,
        'deliveryFee': deliveryFee,
        'discount': discount,
      };

  factory RestaurantOrder.fromJson(Map<String, dynamic> json) => RestaurantOrder(
        id: json['id'] as String,
        items: (json['items'] as List).map((e) => OrderItem.fromJson(Map<String, dynamic>.from(e as Map))).toList(),
        createdAt: DateTime.parse(json['createdAt'] as String),
        status: OrderStatus.values.firstWhere((s) => s.name == json['status'], orElse: () => OrderStatus.pendente),
        customerName: json['customerName'] as String?,
        mesa: json['mesa'] as String?,
        tableSessionId: json['tableSessionId'] as String?,
        closedAt: json['closedAt'] == null ? null : DateTime.tryParse(json['closedAt'] as String),
        type: OrderType.values.firstWhere((t) => t.name == json['type'], orElse: () => OrderType.salao),
        paymentMethod: PaymentMethod.values.firstWhere((p) => p.name == json['paymentMethod'], orElse: () => PaymentMethod.fisico),
        address: json['address'] as String?,
        deliveryFee: (json['deliveryFee'] as num?)?.toDouble() ?? 0,
        discount: (json['discount'] as num?)?.toDouble() ?? 0,
      );
}
