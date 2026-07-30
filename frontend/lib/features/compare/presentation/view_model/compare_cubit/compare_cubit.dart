import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../home/data/models/product_model.dart';
import '../../../data/repo/compare_repo.dart';

part 'compare_state.dart';

class CompareCubit extends Cubit<CompareState> {
  CompareCubit(this._repo) : super(const CompareUpdated([])) {
    emit(CompareUpdated(_repo.items()));
  }

  static const int maxItems = 4;

  final CompareRepo _repo;

  List<ProductModel> get items => _repo.items();
  int get count => items.length;
  bool get isFull => count >= maxItems;
  bool isSelected(int productId) => _repo.contains(productId);

  bool toggle(ProductModel product) {
    final selected = _repo.contains(product.id);
    if (!selected && isFull) return false;

    selected ? _repo.remove(product.id) : _repo.add(product);
    emit(CompareUpdated(_repo.items()));
    return !selected;
  }

  void remove(int productId) {
    _repo.remove(productId);
    emit(CompareUpdated(_repo.items()));
  }

  void clear() {
    _repo.clear();
    emit(CompareUpdated(_repo.items()));
  }
}
