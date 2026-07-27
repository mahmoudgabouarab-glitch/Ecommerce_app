import 'package:equatable/equatable.dart';

class ProductsResponse extends Equatable {
  final List<ProductModel> data;
  final int currentPage;
  final int lastPage;
  final double? maxPrice;

  const ProductsResponse({
    required this.data,
    this.currentPage = 1,
    this.lastPage = 1,
    this.maxPrice,
  });

  factory ProductsResponse.fromJson(Map<String, dynamic> json) {
    final meta = json['meta'] as Map<String, dynamic>?;
    final rawMax = json['max_price'];
    return ProductsResponse(
      data: (json['data'] as List<dynamic>? ?? [])
          .map((e) => ProductModel.fromJson(e as Map<String, dynamic>))
          .toList(),
      currentPage: meta?['current_page'] as int? ?? 1,
      lastPage: meta?['last_page'] as int? ?? 1,
      maxPrice: rawMax == null
          ? null
          : (rawMax is num ? rawMax.toDouble() : double.tryParse('$rawMax')),
    );
  }

  @override
  List<Object?> get props => [data, currentPage, lastPage, maxPrice];
}

class ProductModel extends Equatable {
  final int id;
  final String title;
  final String description;
  final String? brand;
  final double price;
  final double? salePrice;
  final double effectivePrice;
  final bool onSale;
  final int stock;
  final bool inStock;
  final List<String> images;
  final double rating;
  final int ratingCount;
  final bool isFeatured;
  final String? categoryName;
  final List<ProductVariantModel> variants;
  final DateTime? dealEndsAt;
  final bool onDeal;

  const ProductModel({
    required this.id,
    required this.title,
    required this.description,
    required this.brand,
    required this.price,
    required this.salePrice,
    required this.effectivePrice,
    required this.onSale,
    required this.stock,
    required this.inStock,
    required this.images,
    required this.rating,
    required this.ratingCount,
    required this.isFeatured,
    required this.categoryName,
    this.variants = const [],
    this.dealEndsAt,
    this.onDeal = false,
  });

  int get discountPercent => (salePrice != null && price > 0)
      ? (((price - salePrice!) / price) * 100).round()
      : 0;

  String get image => images.isNotEmpty ? images.first : '';

  factory ProductModel.fromJson(Map<String, dynamic> json) {
    final category = json['category'] as Map<String, dynamic>?;
    return ProductModel(
      id: json['id'] as int? ?? 0,
      title: json['title'] as String? ?? '',
      description: json['description'] as String? ?? '',
      brand: json['brand'] as String?,
      price: _toDouble(json['price']),
      salePrice: json['sale_price'] == null ? null : _toDouble(json['sale_price']),
      effectivePrice: _toDouble(json['effective_price']),
      onSale: json['on_sale'] as bool? ?? false,
      stock: json['stock'] as int? ?? 0,
      inStock: json['in_stock'] as bool? ?? false,
      images: (json['images'] as List<dynamic>? ?? [])
          .map((e) => e.toString())
          .toList(),
      rating: _toDouble(json['rating']),
      ratingCount: json['rating_count'] as int? ?? 0,
      isFeatured: json['is_featured'] as bool? ?? false,
      categoryName: category?['name'] as String?,
      variants: (json['variants'] as List<dynamic>? ?? [])
          .map((e) => ProductVariantModel.fromJson(e as Map<String, dynamic>))
          .toList(),
      dealEndsAt: json['deal_ends_at'] == null
          ? null
          : DateTime.tryParse('${json['deal_ends_at']}'),
      onDeal: json['on_deal'] as bool? ?? false,
    );
  }

  static double _toDouble(dynamic v) {
    if (v == null) return 0;
    if (v is num) return v.toDouble();
    return double.tryParse(v.toString()) ?? 0;
  }

  @override
  List<Object?> get props => [id, title, price, salePrice, stock, rating];
}

class ProductVariantModel extends Equatable {
  final int id;
  final String? size;
  final String? color;
  final int stock;
  final double priceDiff;

  const ProductVariantModel({
    required this.id,
    required this.size,
    required this.color,
    required this.stock,
    required this.priceDiff,
  });

  String get label => [size, color].where((e) => e != null && e.isNotEmpty).join(' / ');

  factory ProductVariantModel.fromJson(Map<String, dynamic> json) {
    double toD(dynamic v) => v is num ? v.toDouble() : double.tryParse('$v') ?? 0;
    return ProductVariantModel(
      id: json['id'] as int? ?? 0,
      size: json['size'] as String?,
      color: json['color'] as String?,
      stock: json['stock'] as int? ?? 0,
      priceDiff: toD(json['price_diff']),
    );
  }

  @override
  List<Object?> get props => [id, size, color, stock, priceDiff];
}
