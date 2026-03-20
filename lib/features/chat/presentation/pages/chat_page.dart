import 'package:flutter/material.dart';
import 'package:sweet_mobile_app/core/theme/app_colors.dart';

// TODO Fase 12: Chat con WebSocket + filtro de datos de contacto
class ChatPage extends StatelessWidget {
  const ChatPage({super.key, required this.conversationId});
  final String conversationId;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: const Text('Chat')),
      body: Center(child: Text('Conversation: $conversationId — Fase 12')),
    );
  }
}
