import 'package:equatable/equatable.dart';

class PublicProfileModel extends Equatable {
  final int id;
  final String name;
  final String? avatar;
  final String? memberSince; // 'YYYY-MM'
  final int reviewsCount;

  const PublicProfileModel({
    required this.id,
    required this.name,
    required this.avatar,
    required this.memberSince,
    required this.reviewsCount,
  });

  factory PublicProfileModel.fromJson(Map<String, dynamic> json) =>
      PublicProfileModel(
        id: json['id'] as int? ?? 0,
        name: json['name'] as String? ?? '',
        avatar: json['avatar'] as String?,
        memberSince: json['member_since'] as String?,
        reviewsCount: json['reviews_count'] as int? ?? 0,
      );

  @override
  List<Object?> get props => [id, name, avatar, memberSince, reviewsCount];
}
