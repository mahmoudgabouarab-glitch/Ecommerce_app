import 'package:equatable/equatable.dart';

class ReviewModel extends Equatable {
  final int id;
  final int rating;
  final String comment;
  final int userId;
  final String userName;
  final String? userAvatar;
  final String? createdAt;

  const ReviewModel({
    required this.id,
    required this.rating,
    required this.comment,
    required this.userId,
    required this.userName,
    this.userAvatar,
    this.createdAt,
  });

  factory ReviewModel.fromJson(Map<String, dynamic> json) => ReviewModel(
        id: json['id'] as int? ?? 0,
        rating: json['rating'] as int? ?? 0,
        comment: json['comment'] as String? ?? '',
        userId: json['user_id'] as int? ?? 0,
        userName: json['user_name'] as String? ?? 'Anonymous',
        userAvatar: json['user_avatar'] as String?,
        createdAt: json['created_at']?.toString(),
      );

  @override
  List<Object?> get props => [id, rating, comment, userId, userName];
}
