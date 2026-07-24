import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../order/data/models/order_model.dart';
import '../../../data/repo/admin_repo.dart';

part 'admin_orders_state.dart';

class AdminOrdersCubit extends Cubit<AdminOrdersState> {
  AdminOrdersCubit(this._repo) : super(AdminOrdersInitial());

  final AdminRepo _repo;

  Future<void> getOrders({String? status}) async {
    emit(AdminOrdersLoading());
    final result = await _repo.getAllOrders(status: status);
    result.fold(
      (failure) => emit(AdminOrdersFailure(failure.errorMessage)),
      (orders) => emit(AdminOrdersLoaded(orders)),
    );
  }

  Future<void> updateStatus(int orderId, String status) async {
    final result = await _repo.updateOrderStatus(orderId, status);
    result.fold(
      (failure) => emit(AdminOrdersFailure(failure.errorMessage)),
      (_) => getOrders(),
    );
  }
}
