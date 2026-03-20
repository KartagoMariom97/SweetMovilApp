import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:sweet_mobile_app/core/di/providers.dart';
import 'package:sweet_mobile_app/core/theme/app_colors.dart';
import 'package:sweet_mobile_app/features/chat/presentation/providers/chat_notifier.dart';
import 'package:sweet_mobile_app/features/chat/presentation/widgets/message_bubble.dart';
import 'package:sweet_mobile_app/shared/widgets/empty_state.dart';

class ChatPage extends ConsumerStatefulWidget {
  const ChatPage({super.key, required this.conversationId});
  final String conversationId;

  @override
  ConsumerState<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends ConsumerState<ChatPage> {
  final _inputCtrl = TextEditingController();
  final _scrollCtrl = ScrollController();

  @override
  void dispose() {
    _inputCtrl.dispose();
    _scrollCtrl.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollCtrl.hasClients) {
        _scrollCtrl.animateTo(
          _scrollCtrl.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  Future<void> _send() async {
    final text = _inputCtrl.text.trim();
    if (text.isEmpty) return;
    _inputCtrl.clear();
    await ref
        .read(chatProvider(widget.conversationId).notifier)
        .sendMessage(text);
    _scrollToBottom();
  }

  @override
  Widget build(BuildContext context) {
    final chatState = ref.watch(chatProvider(widget.conversationId));
    final myId = ref.watch(authStateProvider);

    // Auto-scroll cuando llegan mensajes nuevos
    ref.listen(chatProvider(widget.conversationId), (_, next) {
      if (next.messages.isNotEmpty) _scrollToBottom();
    });

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_rounded),
          onPressed: () => context.pop(),
        ),
        title: Row(
          children: [
            const SizedBox(width: 8),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Chat'),
                if (chatState.isConnected)
                  Text(
                    'En línea',
                    style: const TextStyle(
                        color: AppColors.success, fontSize: 11),
                  ),
              ],
            ),
          ],
        ),
      ),
      body: chatState.isLoading
          ? const Center(
              child: CircularProgressIndicator(color: AppColors.primary))
          : chatState.error != null && chatState.messages.isEmpty
              ? EmptyState(
                  icon: Icons.wifi_off_rounded,
                  title: 'Error al cargar el chat',
                  subtitle: chatState.error,
                )
              : Column(
                  children: [
                    // ── Aviso de privacidad ─────────────────────────
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(
                          vertical: 8, horizontal: 16),
                      color: AppColors.warningContainer,
                      child: const Text(
                        '🔒 Los datos de contacto (teléfono, email) no están permitidos en el chat.',
                        style: TextStyle(
                            color: AppColors.warning, fontSize: 11),
                        textAlign: TextAlign.center,
                      ),
                    ),

                    // ── Mensajes ──────────────────────────────────────
                    Expanded(
                      child: chatState.messages.isEmpty
                          ? const EmptyState(
                              icon: Icons.chat_bubble_outline_rounded,
                              title: 'Sin mensajes aún',
                              subtitle: 'Inicia la conversación.',
                            )
                          : ListView.builder(
                              controller: _scrollCtrl,
                              padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
                              itemCount: chatState.messages.length,
                              itemBuilder: (context, i) {
                                final msg = chatState.messages[i];
                                // Usamos el userId almacenado para determinar si soy yo
                                final isMe = msg.senderId ==
                                    ref
                                        .read(secureStorageProvider)
                                        .getUserId()
                                        .toString();
                                return MessageBubble(
                                  message: msg,
                                  isMe: msg.senderId ==
                                      chatState.messages.first.senderId,
                                ).animate().fadeIn(delay: (i * 30).ms);
                              },
                            ),
                    ),

                    // ── Input ─────────────────────────────────────────
                    Container(
                      padding: EdgeInsets.fromLTRB(
                          16,
                          12,
                          16,
                          MediaQuery.viewInsetsOf(context).bottom + 12),
                      decoration: const BoxDecoration(
                        color: AppColors.surface,
                        border: Border(
                            top: BorderSide(color: AppColors.outlineVariant)),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: TextField(
                              controller: _inputCtrl,
                              maxLines: null,
                              textCapitalization:
                                  TextCapitalization.sentences,
                              decoration: const InputDecoration(
                                hintText: 'Escribe un mensaje...',
                                border: OutlineInputBorder(
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(24)),
                                ),
                                contentPadding: EdgeInsets.symmetric(
                                    horizontal: 16, vertical: 10),
                              ),
                              onSubmitted: (_) => _send(),
                            ),
                          ),
                          const SizedBox(width: 8),
                          AnimatedSwitcher(
                            duration: const Duration(milliseconds: 200),
                            child: chatState.isSending
                                ? const SizedBox.square(
                                    dimension: 44,
                                    child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        color: AppColors.primary),
                                  )
                                : IconButton.filled(
                                    onPressed: _send,
                                    icon: const Icon(Icons.send_rounded),
                                    style: IconButton.styleFrom(
                                      backgroundColor: AppColors.primary,
                                      foregroundColor: Colors.white,
                                    ),
                                  ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
    );
  }
}
