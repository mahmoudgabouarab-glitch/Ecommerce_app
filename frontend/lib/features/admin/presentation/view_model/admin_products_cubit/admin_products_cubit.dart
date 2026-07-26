import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../home/data/models/product_model.dart';
import '../../../../home/data/repo/home_repo.dart';
import '../../../data/repo/admin_repo.dart';

part 'admin_products_state.dart';

class AdminProductsCubit extends Cubit<AdminProductsState> {
  AdminProductsCubit(this._adminRepo, this._homeRepo)
      : super(AdminProductsInitial());

  final AdminRepo _adminRepo;
  final HomeRepo _homeRepo;

  Future<void> getProducts() async {
    emit(AdminProductsLoading());
    final result = await _homeRepo.getProducts(perPage: 200);
    result.fold(
      (failure) => emit(AdminProductsFailure(failure.errorMessage)),
      (response) => emit(AdminProductsLoaded(response.data)),
    );
  }

  Future<void> saveProduct({
    int? id,
    required String title,
    required String description,
    required String brand,
    required double price,
    double? salePrice,
    required int stock,
    int? categoryId,
    List<String> newImagePaths = const [],
    List<String> keepImageUrls = const [],
    List<ProductVariantModel> variants = const [],
    bool isFeatured = false,
  }) async {
    emit(AdminProductSaving());
    final result = await _adminRepo.saveProduct(
      id: id,
      title: title,
      description: description,
      brand: brand,
      price: price,
      salePrice: salePrice,
      stock: stock,
      categoryId: categoryId,
      newImagePaths: newImagePaths,
      keepImageUrls: keepImageUrls,
      variants: variants,
      isFeatured: isFeatured,
    );
    result.fold(
      (failure) => emit(AdminProductsFailure(failure.errorMessage)),
      (_) {
        emit(AdminProductSaved());
        getProducts();
      },
    );
  }

  Future<void> deleteProduct(int id) async {
    final result = await _adminRepo.deleteProduct(id);
    result.fold(
      (failure) => emit(AdminProductsFailure(failure.errorMessage)),
      (_) => getProducts(),
    );
  }
}
