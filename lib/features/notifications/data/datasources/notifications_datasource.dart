import 'package:sweet_mobile_app/core/network/dio_client.dart';

class NotificationModel {
  const NotificationModel({
    required this.id,
    required this.title,
    required this.message,
    required this.isRead,
    required this.createdAt,
    this.linkUrl,
  });

  final String id;
  final String title;
  final String message;
  final bool isRead;
  final DateTime createdAt;
  final String? linkUrl;

  factory NotificationModel.fromJson(Map<String, dynamic> json) {
    return NotificationModel(
      id: json['id'] as String,
      title: json['title'] as String,
      message: json['message'] as String,
      isRead: json['isRead'] as bool? ?? json['is_read'] as bool? ?? false,
      createdAt: DateTime.parse(
          json['createdAt'] as String? ?? json['created_at'] as String),
      linkUrl: json['linkUrl'] as String? ?? json['link_url'] as String?,
    );
  }

  NotificationModel copyWith({bool? isRead}) => NotificationModel(
        id: id,
        title: title,
        message: message,
        isRead: isRead ?? this.isRead,
        createdAt: createdAt,
        linkUrl: linkUrl,
      );
}

class NotificationsDataSource {
  const NotificationsDataSource(this._client);
  final DioClient _client;

  Future<List<NotificationModel>> getMyNotifications() async {
    final list = await _client.get<List<dynamic>>(
      '/notifications',
      fromJson: (json) => json as List<dynamic>,
    );
    return list
        .cast<Map<String, dynamic>>()
        .map(NotificationModel.fromJson)
        .toList();
  }

  Future<void> markRead(String id) async {
    await _client.patch<Map<String, dynamic>>(
      '/notifications/$id/read',
      fromJson: (json) => json as Map<String, dynamic>,
    );
  }

  Future<void> markAllRead() async {
    await _client.patch<Map<String, dynamic>>(
      '/notifications/read-all',
      fromJson: (json) => json as Map<String, dynamic>,
    );
  }
}
