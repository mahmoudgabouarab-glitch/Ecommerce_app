import 'package:easy_localization/easy_localization.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../../core/network/service_locator.dart';
import '../../../../../core/utils/app_colors.dart';
import '../../../../../core/utils/app_functions.dart';
import '../../../../../core/utils/styles.dart';
import '../../../../../core/widgets/state_views.dart';
import '../../../data/models/stats_model.dart';
import '../../../data/repo/admin_repo_impl.dart';
import '../../view_model/stats_cubit/stats_cubit.dart';
import '../../../../../core/utils/spacing.dart';

class OverviewTab extends StatelessWidget {
  const OverviewTab({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => StatsCubit(getIt<AdminRepoImpl>())..getStats(),
      child: BlocBuilder<StatsCubit, StatsState>(
        builder: (context, state) {
          if (state is StatsLoading || state is StatsInitial) {
            return const Center(
                child: CircularProgressIndicator(color: AppColors.primary));
          }
          if (state is StatsFailure) {
            return ErrorState(
              message: state.error,
              onRetry: () => context.read<StatsCubit>().getStats(),
            );
          }
          final stats = (state as StatsSuccess).stats;
          return ListView(
            padding: EdgeInsets.all(16.w),
            children: [
              GridView.count(
                crossAxisCount: 2,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisSpacing: 12.w,
                mainAxisSpacing: 12.h,
                childAspectRatio: 1.35,
                children: [
                  _StatCard(
                    label: 'revenue'.tr(),
                    value: formatPrice(stats.revenue),
                    icon: Icons.payments_outlined,
                    color: AppColors.success,
                  ),
                  _StatCard(
                    label: 'orders'.tr(),
                    value: '${stats.ordersCount}',
                    icon: Icons.receipt_long_outlined,
                    color: AppColors.primary,
                  ),
                  _StatCard(
                    label: 'pending'.tr(),
                    value: '${stats.pendingOrders}',
                    icon: Icons.schedule,
                    color: AppColors.warning,
                  ),
                  _StatCard(
                    label: 'customers'.tr(),
                    value: '${stats.customersCount}',
                    icon: Icons.people_outline,
                    color: AppColors.info,
                  ),
                ],
              ),
              if (stats.sales.isNotEmpty) ...[
                spaceH(20),
                _SalesChart(sales: stats.sales),
              ],
              spaceH(20),
              Text('top_products'.tr(), style: AppStyles.bold20),
              spaceH(12),
              if (stats.topProducts.isEmpty)
                Text('no_sales'.tr(),
                    style: AppStyles.regular14
                        .copyWith(color: AppStyles.muted(context)))
              else
                ...stats.topProducts.map((p) => _TopProductTile(product: p)),
            ],
          );
        },
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
  });

  final String label;
  final String value;
  final IconData icon;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: cs.surface,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: cs.outlineVariant),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Container(
            padding: EdgeInsets.all(8.r),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(10.r),
            ),
            child: Icon(icon, color: color, size: 20.r),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              FittedBox(
                fit: BoxFit.scaleDown,
                alignment: AlignmentDirectional.centerStart,
                child: Text(value, maxLines: 1, style: AppStyles.bold20),
              ),
              Text(label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppStyles.regular12
                      .copyWith(color: cs.onSurfaceVariant)),
            ],
          ),
        ],
      ),
    );
  }
}

class _SalesChart extends StatelessWidget {
  const _SalesChart({required this.sales});
  final List<SalesPoint> sales;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final maxVal = sales.map((e) => e.total).fold<double>(0, (a, b) => b > a ? b : a);
    final maxY = maxVal <= 0 ? 100.0 : maxVal * 1.25;

    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: cs.surface,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: cs.outlineVariant),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('sales_last_7'.tr(), style: AppStyles.semiBold16),
          spaceH(18),
          SizedBox(
            height: 170.h,
            child: BarChart(
              BarChartData(
                maxY: maxY,
                alignment: BarChartAlignment.spaceAround,
                gridData: const FlGridData(show: false),
                borderData: FlBorderData(show: false),
                barTouchData: BarTouchData(
                  touchTooltipData: BarTouchTooltipData(
                    getTooltipItem: (group, _, rod, _) => BarTooltipItem(
                      formatPrice(rod.toY),
                      const TextStyle(
                          color: Colors.white, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
                titlesData: FlTitlesData(
                  leftTitles:
                      const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  rightTitles:
                      const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  topTitles:
                      const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (value, meta) {
                        final i = value.toInt();
                        if (i < 0 || i >= sales.length) return const SizedBox();
                        return Padding(
                          padding: EdgeInsets.only(top: 6.h),
                          child: Text(sales[i].label,
                              style: AppStyles.regular12
                                  .copyWith(color: cs.onSurfaceVariant)),
                        );
                      },
                    ),
                  ),
                ),
                barGroups: sales.asMap().entries.map((e) {
                  return BarChartGroupData(
                    x: e.key,
                    barRods: [
                      BarChartRodData(
                        toY: e.value.total,
                        width: 16.w,
                        borderRadius: BorderRadius.circular(6.r),
                        gradient: const LinearGradient(
                          colors: AppColors.brandGradient,
                          begin: Alignment.bottomCenter,
                          end: Alignment.topCenter,
                        ),
                      ),
                    ],
                  );
                }).toList(),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _TopProductTile extends StatelessWidget {
  const _TopProductTile({required this.product});
  final TopProduct product;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Container(
      margin: EdgeInsets.only(bottom: 10.h),
      padding: EdgeInsets.all(14.w),
      decoration: BoxDecoration(
        color: cs.surface,
        borderRadius: BorderRadius.circular(14.r),
        border: Border.all(color: cs.outlineVariant),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(product.title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: AppStyles.medium14),
          ),
          spaceW(10),
          Text('sold'.tr(args: ['${product.sold}']),
              style: AppStyles.semiBold14.copyWith(color: AppColors.primary)),
        ],
      ),
    );
  }
}
