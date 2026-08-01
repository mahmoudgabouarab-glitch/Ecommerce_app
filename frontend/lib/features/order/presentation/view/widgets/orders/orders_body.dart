import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../../../core/utils/app_functions.dart';
import '../../../../../../core/widgets/skeletons.dart';
import '../../../../../../core/widgets/state_views.dart';
import '../../../../../auth/presentation/view/widgets/login_required.dart';
import '../../../view_model/orders_cubit/orders_cubit.dart';
import 'order_card.dart';
import '../../../../../../core/utils/spacing.dart';

class OrdersBody extends StatelessWidget {
  const OrdersBody({super.key});

  @override
  Widget build(BuildContext context) {
    if (!isLoggedInUser()) {
      return GuestState(
          icon: Icons.receipt_long_outlined, title: 'my_orders'.tr());
    }
    return BlocBuilder<OrdersCubit, OrdersState>(
      builder: (context, state) {
        if (state is OrdersLoading || state is OrdersInitial) {
          return const ListRowsShimmer(rowHeight: 110);
        }
        if (state is OrdersFailure) {
          return ErrorState(
            message: state.error,
            onRetry: () => context.read<OrdersCubit>().getOrders(),
          );
        }
        final orders = (state as OrdersSuccess).orders;
        if (orders.isEmpty) {
          return EmptyState(
            icon: Icons.receipt_long_outlined,
            title: 'no_orders'.tr(),
            subtitle: 'orders_appear'.tr(),
          );
        }
        return ListView.separated(
          padding: EdgeInsets.all(16.w),
          itemCount: orders.length,
          separatorBuilder: (_, _) => spaceH(12),
          itemBuilder: (context, i) => OrderCard(order: orders[i]),
        );
      },
    );
  }
}
