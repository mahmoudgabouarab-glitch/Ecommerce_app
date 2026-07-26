import 'package:equatable/equatable.dart';

class AdminUserModel extends Equatable {
  final int id;
  final String name;
  final String email;
  final String role;
  final String? avatar;

  const AdminUserModel({
    required this.id,
    required this.name,
    required this.email,
    required this.role,
    required this.avatar,
  });

  bool get isAdmin => role == 'admin';

  AdminUserModel copyWith({String? role}) => AdminUserModel(
        id: id,
        name: name,
        email: email,
        role: role ?? this.role,
        avatar: avatar,
      );

  factory AdminUserModel.fromJson(Map<String, dynamic> json) => AdminUserModel(
        id: json['id'] as int? ?? 0,
        name: json['name'] as String? ?? '',
        email: json['email'] as String? ?? '',
        role: json['role'] as String? ?? 'customer',
        avatar: json['avatar'] as String?,
      );

  @override
  List<Object?> get props => [id, name, email, role, avatar];
}
