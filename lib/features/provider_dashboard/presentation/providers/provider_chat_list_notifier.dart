import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sweet_mobile_app/features/provider_dashboard/data/datasources/provider_datasource.dart';
import 'package:sweet_mobile_app/features/provider_dashboard/presentation/providers/provider_dashboard_notifier.dart';

// ── Model ────────────────────────────────────────────────────

class ConversationSummary {
  const ConversationSummary({
    required this.id,
    required this.otherPartyEmail,
    this.lastMessage,
    required this.updatedAt,
  });

  final String id;
  final String otherPartyEmail;
  final String? lastMessage;
  final DateTime updatedAt;

  factory ConversationSummary.fromJson(
    Map<String, dynamic> json,
    String myId,
  ) {
    final client = json['client'] as Map<String, dynamic>?;
    final provider = json['provider'] as Map<String, dynamic>?;
    final clientId = json['clientId'] as String? ?? json['client_id'] as String?;

    // El "otro" es quien no soy yo
    final otherEmail = clientId == myId
        ? (provider?['email'] as String? ?? 'Proveedor')
        : (client?['email'] as String? ?? 'Cliente');

    final messages = json['messages'] as List<dynamic>?;
    final lastMsg = messages != null && messages.isNotEmpty
        ? (messages.last as Map<String, dynamic>)['content'] as String?
        : null;

    return ConversationSummary(
      id: json['id'] as String,
      otherPartyEmail: otherEmail,
      lastMessage: lastMsg,
      updatedAt: DateTime.parse(
          json['updatedAt'] as String? ?? json['updated_at'] as String),
    );
  }
}

// ── Provider ─────────────────────────────────────────────────

final providerChatListProvider =
    AsyncNotifierProvider<ProviderChatListNotifier, List<ConversationSummary>>(
  ProviderChatListNotifier.new,
);

class ProviderChatListNotifier
    extends AsyncNotifier<List<ConversationSummary>> {
  @override
  Future<List<ConversationSummary>> build() => _load();

  Future<List<ConversationSummary>> _load() async {
    final myId = await ref.read(providerDsProvider).getMyProfile().then(
          (p) => p['userId'] as String? ?? '',
        );
    final convs = await ref.read(providerDsProvider).getMyConversations();
    return convs
        .map((c) => ConversationSummary.fromJson(c, myId))
        .toList()
      ..sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
  }

  Future<void> refresh() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(_load);
  }
}
