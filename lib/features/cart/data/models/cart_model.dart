import 'package:equatable/equatable.dart';

import '../../../home/data/models/product_model.dart';

/// Response of `GET /cart`: `{ items: [...], subtotal, count }`.
class CartResponse extends Equatable {
  final List<CartItemModel> items;
  final double subtotal;
  final int count;

  const CartResponse({
    required this.items,
    required this.subtotal,
    required this.count,
  });

  factory CartResponse.fromJson(Map<String, dynamic> json) => CartResponse(
        items: (json['items'] as List<dynamic>? ?? [])
            .map((e) => CartItemModel.fromJson(e as Map<String, dynamic>))
            .toList(),
        subtotal: _toDouble(json['subtotal']),
        count: json['count'] as int? ?? 0,
      );

  @override
  List<Object?> get props => [items, subtotal, count];
}

class CartItemModel extends Equatable {
  final int id;
  final int quantity;
  final double unitPrice;
  final double lineTotal;
  final ProductModel product;

  const CartItemModel({
    required this.id,
    required this.quantity,
    required this.unitPrice,
    required this.lineTotal,
    required this.product,
  });

  factory CartItemModel.fromJson(Map<String, dynamic> json) => CartItemModel(
        id: json['id'] as int? ?? 0,
        quantity: json['quantity'] as int? ?? 1,
        unitPrice: _toDouble(json['unit_price']),
        lineTotal: _toDouble(json['line_total']),
        product: ProductModel.fromJson(
          json['product'] as Map<String, dynamic>? ?? {},
        ),
      );

  @override
  List<Object?> get props => [id, quantity, unitPrice, lineTotal, product];
}

double _toDouble(dynamic v) {
  if (v == null) return 0;
  if (v is num) return v.toDouble();
  return double.tryParse(v.toString()) ?? 0;
}
