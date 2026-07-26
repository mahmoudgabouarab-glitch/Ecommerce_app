import 'package:equatable/equatable.dart';

class CategoriesResponse extends Equatable {
  final List<CategoryModel> data;

  const CategoriesResponse({required this.data});

  factory CategoriesResponse.fromJson(Map<String, dynamic> json) =>
      CategoriesResponse(
        data: (json['data'] as List<dynamic>? ?? [])
            .map((e) => CategoryModel.fromJson(e as Map<String, dynamic>))
            .toList(),
      );

  @override
  List<Object?> get props => [data];
}

class CategoryModel extends Equatable {
  final int id;
  final String name;
  final String slug;
  final String? imageUrl;
  final int? productsCount;

  const CategoryModel({
    required this.id,
    required this.name,
    required this.slug,
    this.imageUrl,
    this.productsCount,
  });

  factory CategoryModel.fromJson(Map<String, dynamic> json) => CategoryModel(
        id: json['id'] as int? ?? 0,
        name: json['name'] as String? ?? '',
        slug: json['slug'] as String? ?? '',
        imageUrl: json['image_url'] as String?,
        productsCount: json['products_count'] as int?,
      );

  @override
  List<Object?> get props => [id, name, slug, imageUrl, productsCount];
}
