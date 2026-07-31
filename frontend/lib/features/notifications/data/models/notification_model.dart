import 'package:equatable/equatable.dart';

class NotificationsResponse extends Equatable {
  final List<NotificationModel> items;
  final int unreadCount;

  const NotificationsResponse({required this.items, required this.unreadCount});

  factory NotificationsResponse.fromJson(Map<String, dynamic> json) =>
      NotificationsResponse(
        items: (json['data'] as List<dynamic>? ?? [])
            .map((e) => NotificationModel.fromJson(e as Map<String, dynamic>))
            .toList(),
        unreadCount: json['unread_count'] as int? ?? 0,
      );

  @override
  List<Object?> get props => [items, unreadCount];
}

class NotificationModel extends Equatable {
  final int id;
  final String title;
  final String body;
  final String type;
  final String? key;
  final int? orderId;
  final int? productId;
  final String? imageUrl;
  final bool isRead;
  final DateTime? createdAt;

  const NotificationModel({
    required this.id,
    required this.title,
    required this.body,
    required this.type,
    required this.key,
    required this.orderId,
    this.productId,
    this.imageUrl,
    required this.isRead,
    required this.createdAt,
  });

  factory NotificationModel.fromJson(Map<String, dynamic> json) =>
      NotificationModel(
        id: json['id'] as int? ?? 0,
        title: json['title'] as String? ?? '',
        body: json['body'] as String? ?? '',
        type: json['type'] as String? ?? 'order',
        key: json['key'] as String?,
        orderId: json['order_id'] as int?,
        productId: json['product_id'] as int?,
        imageUrl: json['image_url'] as String?,
        isRead: json['is_read'] as bool? ?? false,
        createdAt: json['created_at'] == null
            ? null
            : DateTime.tryParse('${json['created_at']}'),
      );

  NotificationModel copyAsRead() => NotificationModel(
        id: id,
        title: title,
        body: body,
        type: type,
        key: key,
        orderId: orderId,
        productId: productId,
        imageUrl: imageUrl,
        isRead: true,
        createdAt: createdAt,
      );

  @override
  List<Object?> get props =>
      [id, title, body, type, key, orderId, productId, imageUrl, isRead, createdAt];
}
