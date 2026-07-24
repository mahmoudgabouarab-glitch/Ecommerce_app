import 'package:equatable/equatable.dart';

class ReviewModel extends Equatable {
  final int id;
  final int rating;
  final String comment;
  final String userName;
  final String? createdAt;

  const ReviewModel({
    required this.id,
    required this.rating,
    required this.comment,
    required this.userName,
    this.createdAt,
  });

  factory ReviewModel.fromJson(Map<String, dynamic> json) => ReviewModel(
        id: json['id'] as int? ?? 0,
        rating: json['rating'] as int? ?? 0,
        comment: json['comment'] as String? ?? '',
        userName: json['user_name'] as String? ?? 'Anonymous',
        createdAt: json['created_at']?.toString(),
      );

  @override
  List<Object?> get props => [id, rating, comment, userName];
}
