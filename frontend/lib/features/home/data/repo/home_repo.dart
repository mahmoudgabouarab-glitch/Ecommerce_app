import 'package:dartz/dartz.dart';

import '../../../../core/errors/failure.dart';
import '../models/banner_model.dart';
import '../models/category_model.dart';
import '../models/product_model.dart';
import '../models/public_profile_model.dart';
import '../models/review_model.dart';

abstract class HomeRepo {
  Future<Either<Failure, List<BannerModel>>> getBanners();

  Future<Either<Failure, CategoriesResponse>> getCategories();

  Future<Either<Failure, ProductsResponse>> getProducts({
    int? categoryId,
    String? search,
    String? sort,
    bool? featured,
    double? minPrice,
    double? maxPrice,
    int page,
    int perPage,
  });

  Future<Either<Failure, ProductModel>> getProductDetails(int id);

  Future<Either<Failure, List<ProductModel>>> getRelated(int productId);

  Future<Either<Failure, List<ProductModel>>> getDeals();

  Future<Either<Failure, List<ReviewModel>>> getReviews(int productId);

  Future<Either<Failure, ReviewModel>> addReview({
    required int productId,
    required int rating,
    required String comment,
  });

  Future<Either<Failure, PublicProfileModel>> getPublicProfile(int userId);
}
