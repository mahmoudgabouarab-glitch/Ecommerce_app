import 'package:equatable/equatable.dart';

class BannerModel extends Equatable {
  final int id;
  final String image;
  final String? title;
  final String? subtitle;
  final String linkType;
  final int? linkValue;
  final bool isActive;
  final int sortOrder;

  const BannerModel({
    required this.id,
    required this.image,
    required this.title,
    required this.subtitle,
    required this.linkType,
    required this.linkValue,
    required this.isActive,
    required this.sortOrder,
  });

  factory BannerModel.fromJson(Map<String, dynamic> json) => BannerModel(
        id: json['id'] as int? ?? 0,
        image: json['image'] as String? ?? '',
        title: json['title'] as String?,
        subtitle: json['subtitle'] as String?,
        linkType: json['link_type'] as String? ?? 'none',
        linkValue: json['link_value'] as int?,
        isActive: json['is_active'] as bool? ?? true,
        sortOrder: json['sort_order'] as int? ?? 0,
      );

  @override
  List<Object?> get props =>
      [id, image, title, subtitle, linkType, linkValue, isActive, sortOrder];
}
