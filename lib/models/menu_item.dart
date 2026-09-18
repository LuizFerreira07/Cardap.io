import 'category.dart';

/// Uma opção de tamanho/variação de um item (ex.: Single, Double, Triple),
/// com um acréscimo de preço sobre o preço-base do item.
class ProductSize {
  final String name;
  final double priceDelta;

  const ProductSize({required this.name, this.priceDelta = 0});

  Map<String, dynamic> toJson() => {'name': name, 'priceDelta': priceDelta};

  factory ProductSize.fromJson(Map<String, dynamic> json) =>
      ProductSize(name: json['name'] as String, priceDelta: (json['priceDelta'] as num).toDouble());
}

class MenuItem {
  final String id;
  final String name;
  final String description;
  final double price;
  final MenuCategory category;
  final String emoji;
  /// URL da foto do produto (pode ser http(s) ou vazio para usar o emoji).
  final String imageUrl;
  final bool available;
  final bool popular;
  final double rating;
  final int reviewCount;
  final int stockUnits;
  final int lowStockThreshold;
  final List<String> ingredients;
  final List<ProductSize> sizes;

  const MenuItem({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    required this.category,
    required this.emoji,
    this.imageUrl = '',
    this.available = true,
    this.popular = false,
    this.rating = 4.5,
    this.reviewCount = 0,
    this.stockUnits = 20,
    this.lowStockThreshold = 5,
    this.ingredients = const [],
    this.sizes = const [],
  });

  bool get isLowStock => stockUnits <= lowStockThreshold && stockUnits > 0;
  bool get isOutOfStock => stockUnits <= 0;

  MenuItem copyWith({
    String? name,
    String? description,
    double? price,
    MenuCategory? category,
    String? emoji,
    String? imageUrl,
    bool? available,
    bool? popular,
    double? rating,
    int? reviewCount,
    int? stockUnits,
    int? lowStockThreshold,
    List<String>? ingredients,
    List<ProductSize>? sizes,
  }) {
    return MenuItem(
      id: id,
      name: name ?? this.name,
      description: description ?? this.description,
      price: price ?? this.price,
      category: category ?? this.category,
      emoji: emoji ?? this.emoji,
      imageUrl: imageUrl ?? this.imageUrl,
      available: available ?? this.available,
      popular: popular ?? this.popular,
      rating: rating ?? this.rating,
      reviewCount: reviewCount ?? this.reviewCount,
      stockUnits: stockUnits ?? this.stockUnits,
      lowStockThreshold: lowStockThreshold ?? this.lowStockThreshold,
      ingredients: ingredients ?? this.ingredients,
      sizes: sizes ?? this.sizes,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'description': description,
        'price': price,
        'category': category.name,
        'emoji': emoji,
        'imageUrl': imageUrl,
        'available': available,
        'popular': popular,
        'rating': rating,
        'reviewCount': reviewCount,
        'stockUnits': stockUnits,
        'lowStockThreshold': lowStockThreshold,
        'ingredients': ingredients,
        'sizes': sizes.map((s) => s.toJson()).toList(),
      };

  factory MenuItem.fromJson(Map<String, dynamic> json) => MenuItem(
        id: json['id'] as String,
        name: json['name'] as String,
        description: json['description'] as String,
        price: (json['price'] as num).toDouble(),
        category: MenuCategoryX.fromName(json['category'] as String),
        emoji: json['emoji'] as String,
        imageUrl: json['imageUrl'] as String? ?? '',
        available: json['available'] as bool? ?? true,
        popular: json['popular'] as bool? ?? false,
        rating: (json['rating'] as num?)?.toDouble() ?? 4.5,
        reviewCount: json['reviewCount'] as int? ?? 0,
        stockUnits: json['stockUnits'] as int? ?? 20,
        lowStockThreshold: json['lowStockThreshold'] as int? ?? 5,
        ingredients: (json['ingredients'] as List?)?.map((e) => e as String).toList() ?? const [],
        sizes: (json['sizes'] as List?)?.map((e) => ProductSize.fromJson(e as Map<String, dynamic>)).toList() ?? const [],
      );
}
