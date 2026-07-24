import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../data/models/order_model.dart';
import '../../../data/repo/order_repo.dart';

part 'orders_state.dart';

class OrdersCubit extends Cubit<OrdersState> {
  OrdersCubit(this._repo) : super(OrdersInitial());

  final OrderRepo _repo;

  Future<void> getOrders() async {
    emit(OrdersLoading());
    final result = await _repo.getOrders();
    result.fold(
      (failure) => emit(OrdersFailure(failure.errorMessage)),
      (response) => emit(OrdersSuccess(response.data)),
    );
  }
}
