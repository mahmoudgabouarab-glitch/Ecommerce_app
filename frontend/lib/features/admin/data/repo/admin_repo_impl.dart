import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';

import '../../../../core/errors/failure.dart';
import '../../../../core/network/api_service.dart';
import '../../../home/data/models/product_model.dart';
import '../../../order/data/models/order_model.dart';
import '../models/admin_user_model.dart';
import '../models/coupon_model.dart';
import '../models/stats_model.dart';
import 'admin_repo.dart';

class AdminRepoImpl implements AdminRepo {
  final ApiServise _api;

  AdminRepoImpl(this._api);

  @override
  Future<Either<Failure, StatsModel>> getStats() async {
    try {
      final data = await _api.get(endpoint: "admin/stats");
      return Right(StatsModel.fromJson(data));
    } catch (e) {
      return Left(_handle(e));
    }
  }

  @override
  Future<Either<Failure, List<OrderModel>>> getAllOrders({String? status}) async {
    try {
      final data = await _api.get(
        endpoint: "admin/orders",
        queryParameters: {"status": ?status},
      );
      final list = (data['data'] as List<dynamic>? ?? [])
          .map((e) => OrderModel.fromJson(e as Map<String, dynamic>))
          .toList();
      return Right(list);
    } catch (e) {
      return Left(_handle(e));
    }
  }

  @override
  Future<Either<Failure, Unit>> updateOrderStatus(
      int orderId, String status) async {
    try {
      await _api.patch(
        endpoint: "admin/orders/$orderId/status",
        data: {"status": status},
      );
      return const Right(unit);
    } catch (e) {
      return Left(_handle(e));
    }
  }

  @override
  Future<Either<Failure, Unit>> saveProduct({
    int? id,
    required String title,
    required String description,
    required String brand,
    required double price,
    double? salePrice,
    DateTime? dealEndsAt,
    required int stock,
    int? categoryId,
    List<String> newImagePaths = const [],
    List<String> keepImageUrls = const [],
    List<ProductVariantModel> variants = const [],
    bool isFeatured = false,
  }) async {
    try {
      final form = FormData();
      void field(String key, Object? value) {
        if (value != null) form.fields.add(MapEntry(key, '$value'));
      }

      field('title', title);
      field('description', description);
      field('brand', brand);
      field('price', price);
      field('sale_price', salePrice);
      form.fields.add(
          MapEntry('deal_ends_at', dealEndsAt?.toIso8601String() ?? ''));
      field('stock', stock);
      field('category_id', categoryId);
      field('is_featured', isFeatured ? 1 : 0);
      field('sync_images', 1);
      field('sync_variants', 1);

      for (var i = 0; i < keepImageUrls.length; i++) {
        field('existing_images[$i]', keepImageUrls[i]);
      }
      for (var i = 0; i < variants.length; i++) {
        final v = variants[i];
        if (v.id != 0) field('variants[$i][id]', v.id);
        field('variants[$i][size]', v.size ?? '');
        field('variants[$i][color]', v.color ?? '');
        field('variants[$i][stock]', v.stock);
        field('variants[$i][price_diff]', v.priceDiff);
      }
      for (final path in newImagePaths) {
        form.files.add(MapEntry('photos[]', await MultipartFile.fromFile(path)));
      }
      if (id != null) field('_method', 'PUT');

      await _api.post(
        endpoint: id == null ? "admin/products" : "admin/products/$id",
        data: form,
      );
      return const Right(unit);
    } catch (e) {
      return Left(_handle(e));
    }
  }

  @override
  Future<Either<Failure, Unit>> deleteProduct(int id) async {
    try {
      await _api.delete(endpoint: "admin/products/$id");
      return const Right(unit);
    } catch (e) {
      return Left(_handle(e));
    }
  }

  @override
  Future<Either<Failure, Unit>> saveCategory({
    int? id,
    required String name,
    required String slug,
    String? imagePath,
  }) async {
    try {
      final form = FormData();
      form.fields.add(MapEntry('name', name));
      form.fields.add(MapEntry('slug', slug));
      if (imagePath != null) {
        form.files
            .add(MapEntry('image', await MultipartFile.fromFile(imagePath)));
      }
      if (id != null) form.fields.add(const MapEntry('_method', 'PUT'));

      await _api.post(
        endpoint: id == null ? "admin/categories" : "admin/categories/$id",
        data: form,
      );
      return const Right(unit);
    } catch (e) {
      return Left(_handle(e));
    }
  }

  @override
  Future<Either<Failure, Unit>> deleteCategory(int id) async {
    try {
      await _api.delete(endpoint: "admin/categories/$id");
      return const Right(unit);
    } catch (e) {
      return Left(_handle(e));
    }
  }

  @override
  Future<Either<Failure, List<CouponModel>>> getCoupons() async {
    try {
      final data = await _api.get(endpoint: "admin/coupons");
      final list = (data['data'] as List<dynamic>? ?? [])
          .map((e) => CouponModel.fromJson(e as Map<String, dynamic>))
          .toList();
      return Right(list);
    } catch (e) {
      return Left(_handle(e));
    }
  }

  @override
  Future<Either<Failure, Unit>> createCoupon({
    required String code,
    required String discountType,
    required double amount,
    double? minTotal,
    DateTime? expiresAt,
    bool isActive = true,
  }) async {
    try {
      await _api.post(endpoint: "admin/coupons", data: {
        "code": code,
        "discount_type": discountType,
        "amount": amount,
        "min_total": ?minTotal,
        "expires_at": ?expiresAt?.toIso8601String().split('T').first,
        "is_active": isActive,
      });
      return const Right(unit);
    } catch (e) {
      return Left(_handle(e));
    }
  }

  @override
  Future<Either<Failure, Unit>> deleteCoupon(int id) async {
    try {
      await _api.delete(endpoint: "admin/coupons/$id");
      return const Right(unit);
    } catch (e) {
      return Left(_handle(e));
    }
  }

  @override
  Future<Either<Failure, List<AdminUserModel>>> getUsers({String? search}) async {
    try {
      final data = await _api.get(
        endpoint: "admin/users",
        queryParameters: {"search": ?search},
      );
      final list = (data['data'] as List<dynamic>? ?? [])
          .map((e) => AdminUserModel.fromJson(e as Map<String, dynamic>))
          .toList();
      return Right(list);
    } catch (e) {
      return Left(_handle(e));
    }
  }

  @override
  Future<Either<Failure, AdminUserModel>> updateUserRole(
      int id, String role) async {
    try {
      final data = await _api.patch(
        endpoint: "admin/users/$id/role",
        data: {"role": role},
      );
      final map = (data['data'] ?? data) as Map<String, dynamic>;
      return Right(AdminUserModel.fromJson(map));
    } catch (e) {
      return Left(_handle(e));
    }
  }

  Failure _handle(Object e) {
    if (e is DioException) return ServiseFailure.fromDioException(e);
    return ServiseFailure(e.toString());
  }
}
