import 'package:equatable/equatable.dart';

class CouponModel extends Equatable {
  final int id;
  final String code;
  final String discountType;
  final double amount;
  final double? minTotal;
  final DateTime? expiresAt;
  final bool isActive;

  const CouponModel({
    required this.id,
    required this.code,
    required this.discountType,
    required this.amount,
    required this.minTotal,
    required this.expiresAt,
    required this.isActive,
  });

  bool get isPercent => discountType == 'percent';

  factory CouponModel.fromJson(Map<String, dynamic> json) {
    double? toD(dynamic v) =>
        v == null ? null : (v is num ? v.toDouble() : double.tryParse('$v'));
    return CouponModel(
      id: json['id'] as int? ?? 0,
      code: json['code'] as String? ?? '',
      discountType: json['discount_type'] as String? ?? 'percent',
      amount: toD(json['amount']) ?? 0,
      minTotal: toD(json['min_total']),
      expiresAt: json['expires_at'] == null
          ? null
          : DateTime.tryParse('${json['expires_at']}'),
      isActive: json['is_active'] as bool? ?? true,
    );
  }

  @override
  List<Object?> get props =>
      [id, code, discountType, amount, minTotal, expiresAt, isActive];
}
