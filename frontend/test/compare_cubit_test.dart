import 'package:ecommerce_app/features/compare/data/repo/compare_repo.dart';
import 'package:ecommerce_app/features/compare/presentation/view_model/compare_cubit/compare_cubit.dart';
import 'package:ecommerce_app/features/home/data/models/product_model.dart';
import 'package:flutter_test/flutter_test.dart';

ProductModel _product(int id) => ProductModel(
      id: id,
      title: 'Product $id',
      description: '',
      brand: 'BrandX',
      price: 100,
      salePrice: null,
      effectivePrice: 100,
      onSale: false,
      stock: 10,
      inStock: true,
      images: ['http://img/$id.png'],
      rating: 4,
      ratingCount: 3,
      isFeatured: false,
      categoryName: 'Cat',
    );

class _FakeCompareRepo implements CompareRepo {
  final List<ProductModel> _items = [];

  @override
  List<ProductModel> items() => List.of(_items);

  @override
  bool contains(int productId) => _items.any((p) => p.id == productId);

  @override
  void add(ProductModel product) {
    if (!contains(product.id)) _items.add(product);
  }

  @override
  void remove(int productId) => _items.removeWhere((p) => p.id == productId);

  @override
  void clear() => _items.clear();
}

void main() {
  late _FakeCompareRepo repo;

  setUp(() => repo = _FakeCompareRepo());

  test('starts from whatever the repo already holds', () {
    repo.add(_product(1));
    final cubit = CompareCubit(repo);

    expect(cubit.count, 1);
    expect(cubit.isSelected(1), isTrue);
    expect(cubit.state, isA<CompareUpdated>());
    return cubit.close();
  });

  test('toggle adds then removes a product', () async {
    final cubit = CompareCubit(repo);

    expect(cubit.toggle(_product(1)), isTrue);
    expect(cubit.isSelected(1), isTrue);
    expect(cubit.count, 1);

    expect(cubit.toggle(_product(1)), isFalse);
    expect(cubit.isSelected(1), isFalse);
    expect(cubit.count, 0);
    await cubit.close();
  });

  test('refuses to add beyond maxItems', () async {
    final cubit = CompareCubit(repo);

    for (var i = 1; i <= CompareCubit.maxItems; i++) {
      expect(cubit.toggle(_product(i)), isTrue);
    }

    expect(cubit.isFull, isTrue);
    expect(cubit.toggle(_product(99)), isFalse);
    expect(cubit.count, CompareCubit.maxItems);
    expect(cubit.isSelected(99), isFalse);
    await cubit.close();
  });

  test('clear empties the list', () async {
    final cubit = CompareCubit(repo);
    cubit.toggle(_product(1));
    cubit.toggle(_product(2));

    cubit.clear();

    expect(cubit.count, 0);
    await cubit.close();
  });
}
