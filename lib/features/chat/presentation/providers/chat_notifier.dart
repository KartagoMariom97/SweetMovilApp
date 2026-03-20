import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:socket_io_client/socket_io_client.dart' as sio;
import 'package:sweet_mobile_app/core/config/app_config.dart';
import 'package:sweet_mobile_app/core/di/providers.dart';
import 'package:sweet_mobile_app/features/chat/data/datasources/chat_datasource.dart';
import 'package:sweet_mobile_app/features/chat/data/models/message_model.dart';

// ── Infraestructura ─────────────────────────────────────────

final chatDsProvider = Provider<ChatDataSource>(
  (ref) => ChatDataSource(ref.read(dioClientProvider)),
);

// ── Estado del chat ─────────────────────────────────────────

class ChatState {
  const ChatState({
    this.conversationId,
    this.messages = const [],
    this.isLoading = false,
    this.isSending = false,
    this.error,
    this.isConnected = false,
  });

  final String? conversationId;
  final List<MessageModel> messages;
  final bool isLoading;
  final bool isSending;
  final String? error;
  final bool isConnected;

  ChatState copyWith({
    String? conversationId,
    List<MessageModel>? messages,
    bool? isLoading,
    bool? isSending,
    String? error,
    bool? isConnected,
    bool clearError = false,
  }) =>
      ChatState(
        conversationId: conversationId ?? this.conversationId,
        messages: messages ?? this.messages,
        isLoading: isLoading ?? this.isLoading,
        isSending: isSending ?? this.isSending,
        error: clearError ? null : error ?? this.error,
        isConnected: isConnected ?? this.isConnected,
      );
}

// ── Notifier ────────────────────────────────────────────────

final chatProvider = NotifierProviderFamily<ChatNotifier, ChatState, String>(
  ChatNotifier.new,
);

/// `arg` puede ser un conversationId existente
/// o "new?providerId=X&bookingId=Y" para crear una nueva.
class ChatNotifier extends FamilyNotifier<ChatState, String> {
  sio.Socket? _socket;

  @override
  ChatState build(String arg) {
    ref.onDispose(_disconnect);
    Future.microtask(() => _init(arg));
    return const ChatState(isLoading: true);
  }

  Future<void> _init(String arg) async {
    try {
      String conversationId;

      if (arg.startsWith('new')) {
        // Parsear "new?providerId=X&bookingId=Y"
        final uri = Uri.parse('http://x/$arg');
        final providerId = uri.queryParameters['providerId']!;
        final bookingId = uri.queryParameters['bookingId'];
        final result = await ref.read(chatDsProvider).getOrCreateConversation(
              providerId: providerId,
              bookingId: bookingId,
            );
        conversationId = result['id'] as String;
      } else {
        conversationId = arg;
      }

      final messages =
          await ref.read(chatDsProvider).getMessages(conversationId);

      state = state.copyWith(
        conversationId: conversationId,
        messages: messages,
        isLoading: false,
      );

      await _connectSocket(conversationId);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<void> _connectSocket(String conversationId) async {
    final token = await ref.read(secureStorageProvider).getAccessToken();
    if (token == null) return;

    _socket = sio.io(
      '${AppConfig.wsUrl}/chat',
      sio.OptionBuilder()
          .setTransports(['websocket'])
          .setAuth({'token': token})
          .disableAutoConnect()
          .build(),
    );

    _socket!
      ..connect()
      ..onConnect((_) {
        state = state.copyWith(isConnected: true);
        _socket!.emit('joinConversation', conversationId);
      })
      ..onDisconnect((_) => state = state.copyWith(isConnected: false))
      ..on('newMessage', (data) {
        final msg = MessageModel.fromJson(
            Map<String, dynamic>.from(data as Map));
        if (msg.conversationId == state.conversationId) {
          state = state.copyWith(messages: [...state.messages, msg]);
        }
      });
  }

  Future<void> sendMessage(String content) async {
    final trimmed = content.trim();
    if (trimmed.isEmpty || state.conversationId == null) return;

    state = state.copyWith(isSending: true, clearError: true);
    try {
      if (_socket != null && (state.isConnected)) {
        // Enviar por WebSocket — el servidor hace broadcast
        _socket!.emit('sendMessage', {
          'conversationId': state.conversationId,
          'content': trimmed,
          'type': 'TEXT',
        });
        state = state.copyWith(isSending: false);
      } else {
        // Fallback REST si no hay socket
        final msg = await ref
            .read(chatDsProvider)
            .sendMessage(state.conversationId!, trimmed);
        state = state.copyWith(
          messages: [...state.messages, msg],
          isSending: false,
        );
      }
    } catch (e) {
      state = state.copyWith(isSending: false, error: e.toString());
    }
  }

  void _disconnect() {
    _socket?.disconnect();
    _socket?.dispose();
    _socket = null;
  }
}
