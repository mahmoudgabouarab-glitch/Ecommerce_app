import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';

import '../../../../core/errors/failure.dart';
import '../../../../core/network/api_service.dart';
import '../models/banner_model.dart';
import '../models/category_model.dart';
import '../models/product_model.dart';
import '../models/public_profile_model.dart';
import '../models/review_model.dart';
import 'home_repo.dart';

class HomeRepoImpl implements HomeRepo {
  final ApiServise _api;

  HomeRepoImpl(this._api);

  @override
  Future<Either<Failure, List<BannerModel>>> getBanners() async {
    try {
      final data = await _api.get(endpoint: "banners");
      final list = (data['data'] as List<dynamic>? ?? [])
          .map((e) => BannerModel.fromJson(e as Map<String, dynamic>))
          .toList();
      return Right(list);
    } catch (e) {
      return Left(_handle(e));
    }
  }

  @override
  Future<Either<Failure, CategoriesResponse>> getCategories() async {
    try {
      final data = await _api.get(endpoint: "categories");
      return Right(CategoriesResponse.fromJson(data));
    } catch (e) {
      return Left(_handle(e));
    }
  }

  @override
  Future<Either<Failure, ProductsResponse>> getProducts({
    int? categoryId,
    String? search,
    String? sort,
    bool? featured,
    double? minPrice,
    double? maxPrice,
    int page = 1,
    int perPage = 20,
  }) async {
    try {
      final data = await _api.get(
        endpoint: "products",
        queryParameters: {
          "page": page,
          "per_page": perPage,
          "category_id": ?categoryId,
          if (search != null && search.isNotEmpty) "search": search,
          "sort": ?sort,
          if (featured == true) "featured": 1,
          if (minPrice != null) "min_price": minPrice.round(),
          if (maxPrice != null) "max_price": maxPrice.round(),
        },
      );
      return Right(ProductsResponse.fromJson(data));
    } catch (e) {
      return Left(_handle(e));
    }
  }

  @override
  Future<Either<Failure, ProductModel>> getProductDetails(int id) async {
    try {
      final data = await _api.get(endpoint: "products/$id");
      final map = data['data'] as Map<String, dynamic>? ?? data;
      if (data['ratings_breakdown'] != null) {
        map['ratings_breakdown'] = data['ratings_breakdown'];
      }
      return Right(ProductModel.fromJson(map));
    } catch (e) {
      return Left(_handle(e));
    }
  }

  @override
  Future<Either<Failure, List<ProductModel>>> getRelated(int productId) async {
    try {
      final data = await _api.get(endpoint: "products/$productId/related");
      final list = (data['data'] as List<dynamic>? ?? [])
          .map((e) => ProductModel.fromJson(e as Map<String, dynamic>))
          .toList();
      return Right(list);
    } catch (e) {
      return Left(_handle(e));
    }
  }

  @override
  Future<Either<Failure, List<ProductModel>>> getDeals() async {
    try {
      final data = await _api.get(endpoint: "products/deals");
      final list = (data['data'] as List<dynamic>? ?? [])
          .map((e) => ProductModel.fromJson(e as Map<String, dynamic>))
          .toList();
      return Right(list);
    } catch (e) {
      return Left(_handle(e));
    }
  }

  @override
  Future<Either<Failure, List<ReviewModel>>> getReviews(int productId) async {
    try {
      final data = await _api.get(endpoint: "products/$productId/reviews");
      final list = (data['data'] as List<dynamic>? ?? [])
          .map((e) => ReviewModel.fromJson(e as Map<String, dynamic>))
          .toList();
      return Right(list);
    } catch (e) {
      return Left(_handle(e));
    }
  }

  @override
  Future<Either<Failure, ReviewModel>> addReview({
    required int productId,
    required int rating,
    required String comment,
  }) async {
    try {
      final data = await _api.post(
        endpoint: "products/$productId/reviews",
        data: {"rating": rating, "comment": comment},
      );
      final map = data['data'] as Map<String, dynamic>? ?? data;
      return Right(ReviewModel.fromJson(map));
    } catch (e) {
      return Left(_handle(e));
    }
  }

  @override
  Future<Either<Failure, PublicProfileModel>> getPublicProfile(
      int userId) async {
    try {
      final data = await _api.get(endpoint: "users/$userId/profile");
      return Right(PublicProfileModel.fromJson(data));
    } catch (e) {
      return Left(_handle(e));
    }
  }

  Failure _handle(Object e) {
    if (e is DioException) return ServiseFailure.fromDioException(e);
    return ServiseFailure(e.toString());
  }
}
