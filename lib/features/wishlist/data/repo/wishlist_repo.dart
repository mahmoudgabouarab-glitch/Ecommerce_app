import 'package:dartz/dartz.dart';

import '../../../../core/errors/failure.dart';
import '../../../home/data/models/product_model.dart';

abstract class WishlistRepo {
  Future<Either<Failure, List<ProductModel>>> getWishlist();

  /// Toggle a product in the wishlist; returns whether it is now in the list.
  Future<Either<Failure, bool>> toggle(int productId);
}
