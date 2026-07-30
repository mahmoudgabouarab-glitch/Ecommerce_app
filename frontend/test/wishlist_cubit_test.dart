import 'package:dartz/dartz.dart';
import 'package:ecommerce_app/core/errors/failure.dart';
import 'package:ecommerce_app/features/home/data/models/product_model.dart';
import 'package:ecommerce_app/features/wishlist/data/repo/wishlist_repo.dart';
import 'package:ecommerce_app/features/wishlist/presentation/view_model/wishlist_cubit/wishlist_cubit.dart';
import 'package:flutter_test/flutter_test.dart';

ProductModel _product(int id) => ProductModel(
      id: id,
      title: 'Product $id',
      description: '',
      brand: null,
      price: 100,
      salePrice: null,
      effectivePrice: 100,
      onSale: false,
      stock: 10,
      inStock: true,
      images: const [],
      rating: 0,
      ratingCount: 0,
      isFeatured: false,
      categoryName: null,
    );

class _FakeWishlistRepo implements WishlistRepo {
  Either<Failure, List<ProductModel>> getResult = right(<ProductModel>[]);
  Either<Failure, bool> toggleResult = right(true);

  @override
  Future<Either<Failure, List<ProductModel>>> getWishlist() async => getResult;

  @override
  Future<Either<Failure, bool>> toggle(int productId) async => toggleResult;
}

void main() {
  late _FakeWishlistRepo repo;

  setUp(() => repo = _FakeWishlistRepo());

  test('getWishlist success loads favorites', () async {
    repo.getResult = right([_product(1), _product(2)]);
    final cubit = WishlistCubit(repo);

    await cubit.getWishlist();

    expect(cubit.state, isA<WishlistLoaded>());
    expect(cubit.isFavorite(1), isTrue);
    expect(cubit.isFavorite(99), isFalse);
    await cubit.close();
  });

  test('getWishlist failure emits WishlistError', () async {
    repo.getResult = left(ServiseFailure('down'));
    final cubit = WishlistCubit(repo);

    await cubit.getWishlist();

    expect(cubit.state, isA<WishlistError>());
    await cubit.close();
  });

  test('successful toggle marks the product as favorite', () async {
    repo.getResult = right([_product(5)]);
    repo.toggleResult = right(true);
    final cubit = WishlistCubit(repo);

    await cubit.toggle(5);
    await Future<void>.delayed(const Duration(milliseconds: 10));

    expect(cubit.isFavorite(5), isTrue);
    await cubit.close();
  });

  test('failed toggle reverts the optimistic change', () async {
    repo.toggleResult = left(ServiseFailure('offline'));
    final cubit = WishlistCubit(repo);

    await cubit.toggle(7);

    expect(cubit.isFavorite(7), isFalse);
    await cubit.close();
  });
}
