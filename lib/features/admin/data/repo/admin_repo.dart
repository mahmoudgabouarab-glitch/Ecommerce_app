import 'package:dartz/dartz.dart';

import '../../../../core/errors/failure.dart';
import '../../../home/data/models/product_model.dart';
import '../../../order/data/models/order_model.dart';
import '../models/admin_user_model.dart';
import '../models/coupon_model.dart';
import '../models/stats_model.dart';

abstract class AdminRepo {
  Future<Either<Failure, StatsModel>> getStats();

  Future<Either<Failure, List<OrderModel>>> getAllOrders({String? status});

  Future<Either<Failure, Unit>> updateOrderStatus(int orderId, String status);

  Future<Either<Failure, Unit>> saveProduct({
    int? id,
    required String title,
    required String description,
    required String brand,
    required double price,
    double? salePrice,
    required int stock,
    int? categoryId,
    List<String> newImagePaths, // local file paths of newly picked photos
    List<String> keepImageUrls, // existing image URLs to keep
    List<ProductVariantModel> variants, // full desired variant set
    bool isFeatured = false,
  });

  Future<Either<Failure, Unit>> deleteProduct(int id);

  // --- Categories ---
  Future<Either<Failure, Unit>> saveCategory({
    int? id,
    required String name,
    required String slug,
    String? imageUrl,
  });

  Future<Either<Failure, Unit>> deleteCategory(int id);

  // --- Coupons ---
  Future<Either<Failure, List<CouponModel>>> getCoupons();

  Future<Either<Failure, Unit>> createCoupon({
    required String code,
    required String discountType,
    required double amount,
    double? minTotal,
    DateTime? expiresAt,
    bool isActive,
  });

  Future<Either<Failure, Unit>> deleteCoupon(int id);

  // --- Users ---
  Future<Either<Failure, List<AdminUserModel>>> getUsers({String? search});

  Future<Either<Failure, AdminUserModel>> updateUserRole(int id, String role);
}
