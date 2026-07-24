import 'package:equatable/equatable.dart';

/// Wrapper for `/orders` list: `{ data: [...] }`.
class OrdersResponse extends Equatable {
  final List<OrderModel> data;

  const OrdersResponse({required this.data});

  factory OrdersResponse.fromJson(Map<String, dynamic> json) => OrdersResponse(
        data: (json['data'] as List<dynamic>? ?? [])
            .map((e) => OrderModel.fromJson(e as Map<String, dynamic>))
            .toList(),
      );

  @override
  List<Object?> get props => [data];
}

class OrderModel extends Equatable {
  final int id;
  final String status;
  final String paymentMethod;
  final double subtotal;
  final double discount;
  final double shippingFee;
  final double total;
  final String? couponCode;
  final List<OrderItemModel> items;
  final String? createdAt;

  const OrderModel({
    required this.id,
    required this.status,
    required this.paymentMethod,
    required this.subtotal,
    required this.discount,
    required this.shippingFee,
    required this.total,
    required this.couponCode,
    required this.items,
    required this.createdAt,
  });

  factory OrderModel.fromJson(Map<String, dynamic> json) => OrderModel(
        id: json['id'] as int? ?? 0,
        status: json['status'] as String? ?? 'pending',
        paymentMethod: json['payment_method'] as String? ?? 'cash',
        subtotal: _d(json['subtotal']),
        discount: _d(json['discount']),
        shippingFee: _d(json['shipping_fee']),
        total: _d(json['total']),
        couponCode: json['coupon_code'] as String?,
        items: (json['items'] as List<dynamic>? ?? [])
            .map((e) => OrderItemModel.fromJson(e as Map<String, dynamic>))
            .toList(),
        createdAt: json['created_at']?.toString(),
      );

  @override
  List<Object?> get props => [id, status, total];
}

class OrderItemModel extends Equatable {
  final int id;
  final int? productId;
  final String productTitle;
  final String? productImage;
  final double unitPrice;
  final int quantity;

  const OrderItemModel({
    required this.id,
    required this.productId,
    required this.productTitle,
    required this.productImage,
    required this.unitPrice,
    required this.quantity,
  });

  factory OrderItemModel.fromJson(Map<String, dynamic> json) => OrderItemModel(
        id: json['id'] as int? ?? 0,
        productId: json['product_id'] as int?,
        productTitle: json['product_title'] as String? ?? '',
        productImage: json['product_image'] as String?,
        unitPrice: _d(json['unit_price']),
        quantity: json['quantity'] as int? ?? 1,
      );

  @override
  List<Object?> get props => [id, productTitle, quantity];
}

double _d(dynamic v) {
  if (v == null) return 0;
  if (v is num) return v.toDouble();
  return double.tryParse(v.toString()) ?? 0;
}
