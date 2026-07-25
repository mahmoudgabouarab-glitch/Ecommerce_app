part of 'admin_categories_cubit.dart';

sealed class AdminCategoriesState extends Equatable {
  const AdminCategoriesState();

  @override
  List<Object> get props => [];
}

final class AdminCategoriesInitial extends AdminCategoriesState {}

final class AdminCategoriesLoading extends AdminCategoriesState {}

final class AdminCategoriesLoaded extends AdminCategoriesState {
  final List<CategoryModel> categories;
  const AdminCategoriesLoaded(this.categories);

  @override
  List<Object> get props => [categories];
}

final class AdminCategorySaving extends AdminCategoriesState {}

final class AdminCategorySaved extends AdminCategoriesState {}

final class AdminCategoriesFailure extends AdminCategoriesState {
  final String error;
  const AdminCategoriesFailure(this.error);

  @override
  List<Object> get props => [error];
}
