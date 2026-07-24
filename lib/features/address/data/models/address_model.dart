import 'package:equatable/equatable.dart';

class AddressModel extends Equatable {
  final int id;
  final String fullName;
  final String phone;
  final String line1;
  final String city;
  final String country;
  final bool isDefault;

  const AddressModel({
    required this.id,
    required this.fullName,
    required this.phone,
    required this.line1,
    required this.city,
    required this.country,
    required this.isDefault,
  });

  factory AddressModel.fromJson(Map<String, dynamic> json) => AddressModel(
        id: json['id'] as int? ?? 0,
        fullName: json['full_name'] as String? ?? '',
        phone: json['phone'] as String? ?? '',
        line1: json['line1'] as String? ?? '',
        city: json['city'] as String? ?? '',
        country: json['country'] as String? ?? 'Egypt',
        isDefault: json['is_default'] as bool? ?? false,
      );

  @override
  List<Object?> get props => [id, fullName, phone, line1, city, isDefault];
}
