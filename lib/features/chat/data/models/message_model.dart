class MessageModel {
  const MessageModel({
    required this.id,
    required this.conversationId,
    required this.senderId,
    required this.content,
    required this.type,
    required this.createdAt,
    this.isRead = false,
  });

  final String id;
  final String conversationId;
  final String senderId;
  final String content;
  final String type; // TEXT | IMAGE | SYSTEM
  final DateTime createdAt;
  final bool isRead;

  bool get isSystem => type == 'SYSTEM';

  factory MessageModel.fromJson(Map<String, dynamic> json) => MessageModel(
        id: json['id'] as String,
        conversationId: json['conversationId'] as String? ??
            json['conversation_id'] as String,
        senderId: json['senderId'] as String? ?? json['sender_id'] as String,
        content: json['content'] as String,
        type: json['type'] as String? ?? 'TEXT',
        createdAt: DateTime.parse(
            json['createdAt'] as String? ?? json['created_at'] as String),
        isRead: json['isRead'] as bool? ?? json['is_read'] as bool? ?? false,
      );
}
