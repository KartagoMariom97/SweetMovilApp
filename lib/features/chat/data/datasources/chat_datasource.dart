import 'package:sweet_mobile_app/core/network/dio_client.dart';
import 'package:sweet_mobile_app/features/chat/data/models/message_model.dart';

class ChatDataSource {
  const ChatDataSource(this._client);
  final DioClient _client;

  Future<Map<String, dynamic>> getOrCreateConversation({
    required String providerId,
    String? bookingId,
  }) async {
    return _client.post<Map<String, dynamic>>(
      '/chat/conversations',
      data: {
        'providerId': providerId,
        if (bookingId != null) 'bookingId': bookingId,
      },
      fromJson: (json) => json as Map<String, dynamic>,
    );
  }

  Future<List<MessageModel>> getMessages(String conversationId) async {
    final list = await _client.get<List<dynamic>>(
      '/chat/conversations/$conversationId/messages',
      fromJson: (json) => json as List<dynamic>,
    );
    return list
        .cast<Map<String, dynamic>>()
        .map(MessageModel.fromJson)
        .toList();
  }

  Future<MessageModel> sendMessage(
    String conversationId,
    String content,
  ) async {
    return _client.post<MessageModel>(
      '/chat/conversations/$conversationId/messages',
      data: {'content': content, 'type': 'TEXT'},
      fromJson: (json) => MessageModel.fromJson(json as Map<String, dynamic>),
    );
  }
}
