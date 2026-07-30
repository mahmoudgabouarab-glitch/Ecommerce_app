import '../../../home/data/models/product_model.dart';

abstract class CompareRepo {
  List<ProductModel> items();

  bool contains(int productId);

  void add(ProductModel product);

  void remove(int productId);

  void clear();
}
