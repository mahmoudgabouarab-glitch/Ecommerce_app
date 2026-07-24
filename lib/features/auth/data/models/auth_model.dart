import 'package:equatable/equatable.dart';

/// Response of `/register` and `/login`: `{ user: {...}, token: "..." }`.
class AuthModel extends Equatable {
  final UserModel user;
  final String token;

  const AuthModel({required this.user, required this.token});

  factory AuthModel.fromJson(Map<String, dynamic> json) => AuthModel(
        user: UserModel.fromJson(json['user'] as Map<String, dynamic>? ?? {}),
        token: json['token'] as String? ?? '',
      );

  @override
  List<Object?> get props => [user, token];
}

class UserModel extends Equatable {
  final int id;
  final String name;
  final String email;
  final String role;
  final String? phone;
  final String? avatar;
  final String? gender;
  final String? birthDate;
  final String? bio;

  const UserModel({
    required this.id,
    required this.name,
    required this.email,
    required this.role,
    this.phone,
    this.avatar,
    this.gender,
    this.birthDate,
    this.bio,
  });

  bool get isAdmin => role == 'admin';

  factory UserModel.fromJson(Map<String, dynamic> json) => UserModel(
        id: json['id'] as int? ?? 0,
        name: json['name'] as String? ?? '',
        email: json['email'] as String? ?? '',
        role: json['role'] as String? ?? 'customer',
        phone: json['phone'] as String?,
        avatar: json['avatar'] as String?,
        gender: json['gender'] as String?,
        birthDate: json['birth_date'] as String?,
        bio: json['bio'] as String?,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'email': email,
        'role': role,
        'phone': phone,
        'avatar': avatar,
        'gender': gender,
        'birth_date': birthDate,
        'bio': bio,
      };

  @override
  List<Object?> get props =>
      [id, name, email, role, phone, avatar, gender, birthDate, bio];
}
