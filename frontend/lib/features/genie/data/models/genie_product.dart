class GenieProduct {
  final int id;
  final String title;
  final String? brand;
  final String? image;
  final double price;
  final double? salePrice;
  final double rating;

  const GenieProduct({
    required this.id,
    required this.title,
    required this.brand,
    required this.image,
    required this.price,
    required this.salePrice,
    required this.rating,
  });

  double get effectivePrice => salePrice ?? price;

  factory GenieProduct.fromJson(Map<String, dynamic> json) {
    return GenieProduct(
      id: json['id'] as int,
      title: json['title'] as String? ?? '',
      brand: json['brand'] as String?,
      image: json['image'] as String?,
      price: (json['price'] as num?)?.toDouble() ?? 0,
      salePrice: (json['sale_price'] as num?)?.toDouble(),
      rating: (json['rating'] as num?)?.toDouble() ?? 0,
    );
  }
}
