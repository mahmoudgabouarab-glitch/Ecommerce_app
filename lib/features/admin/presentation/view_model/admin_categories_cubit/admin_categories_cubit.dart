import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../home/data/models/category_model.dart';
import '../../../../home/data/repo/home_repo.dart';
import '../../../data/repo/admin_repo.dart';

part 'admin_categories_state.dart';

class AdminCategoriesCubit extends Cubit<AdminCategoriesState> {
  AdminCategoriesCubit(this._adminRepo, this._homeRepo)
      : super(AdminCategoriesInitial());

  final AdminRepo _adminRepo;
  final HomeRepo _homeRepo;

  Future<void> getCategories() async {
    emit(AdminCategoriesLoading());
    final result = await _homeRepo.getCategories();
    result.fold(
      (failure) => emit(AdminCategoriesFailure(failure.errorMessage)),
      (response) => emit(AdminCategoriesLoaded(response.data)),
    );
  }

  Future<void> saveCategory({
    int? id,
    required String name,
    String? imageUrl,
  }) async {
    emit(AdminCategorySaving());
    final result = await _adminRepo.saveCategory(
      id: id,
      name: name,
      slug: _slugify(name),
      imageUrl: imageUrl,
    );
    result.fold(
      (failure) => emit(AdminCategoriesFailure(failure.errorMessage)),
      (_) {
        emit(AdminCategorySaved());
        getCategories();
      },
    );
  }

  Future<void> deleteCategory(int id) async {
    final result = await _adminRepo.deleteCategory(id);
    result.fold(
      (failure) => emit(AdminCategoriesFailure(failure.errorMessage)),
      (_) => getCategories(),
    );
  }

  /// Build a URL-safe slug from the name (falls back to a unique value when
  /// the name has no ASCII letters, e.g. an Arabic-only name).
  String _slugify(String name) {
    final slug = name
        .toLowerCase()
        .trim()
        .replaceAll(RegExp(r'[^a-z0-9]+'), '-')
        .replaceAll(RegExp(r'(^-+|-+$)'), '');
    return slug.isEmpty
        ? 'category-${DateTime.now().millisecondsSinceEpoch}'
        : slug;
  }
}
