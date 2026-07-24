import 'package:equatable/equatable.dart';

class StatsModel extends Equatable {
  final double revenue;
  final int ordersCount;
  final int pendingOrders;
  final int customersCount;
  final int productsCount;
  final List<TopProduct> topProducts;
  final List<SalesPoint> sales;

  const StatsModel({
    required this.revenue,
    required this.ordersCount,
    required this.pendingOrders,
    required this.customersCount,
    required this.productsCount,
    required this.topProducts,
    required this.sales,
  });

  factory StatsModel.fromJson(Map<String, dynamic> json) => StatsModel(
        revenue: _d(json['revenue']),
        ordersCount: json['orders_count'] as int? ?? 0,
        pendingOrders: json['pending_orders'] as int? ?? 0,
        customersCount: json['customers_count'] as int? ?? 0,
        productsCount: json['products_count'] as int? ?? 0,
        topProducts: (json['top_products'] as List<dynamic>? ?? [])
            .map((e) => TopProduct.fromJson(e as Map<String, dynamic>))
            .toList(),
        sales: (json['sales_last_7_days'] as List<dynamic>? ?? [])
            .map((e) => SalesPoint.fromJson(e as Map<String, dynamic>))
            .toList(),
      );

  @override
  List<Object?> get props =>
      [revenue, ordersCount, pendingOrders, customersCount, productsCount];
}

class TopProduct extends Equatable {
  final String title;
  final int sold;

  const TopProduct({required this.title, required this.sold});

  factory TopProduct.fromJson(Map<String, dynamic> json) => TopProduct(
        title: json['product_title'] as String? ?? '',
        sold: int.tryParse('${json['sold']}') ?? 0,
      );

  @override
  List<Object?> get props => [title, sold];
}

class SalesPoint extends Equatable {
  final String label; // Mon, Tue...
  final double total;

  const SalesPoint({required this.label, required this.total});

  factory SalesPoint.fromJson(Map<String, dynamic> json) => SalesPoint(
        label: json['label'] as String? ?? '',
        total: _d(json['total']),
      );

  @override
  List<Object?> get props => [label, total];
}

double _d(dynamic v) {
  if (v == null) return 0;
  if (v is num) return v.toDouble();
  return double.tryParse(v.toString()) ?? 0;
}
