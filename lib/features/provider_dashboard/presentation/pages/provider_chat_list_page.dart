import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:sweet_mobile_app/core/router/route_names.dart';
import 'package:sweet_mobile_app/core/theme/app_colors.dart';
import 'package:sweet_mobile_app/features/provider_dashboard/presentation/providers/provider_chat_list_notifier.dart';
import 'package:sweet_mobile_app/shared/widgets/empty_state.dart';

class ProviderChatListPage extends ConsumerWidget {
  const ProviderChatListPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final convsAsync = ref.watch(providerChatListProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        title: const Text('Mensajes'),
      ),
      body: convsAsync.when(
        loading: () => const Center(
            child: CircularProgressIndicator(color: AppColors.primary)),
        error: (e, _) => EmptyState(
          icon: Icons.error_outline_rounded,
          title: 'Error al cargar mensajes',
          subtitle: e.toString(),
          actionLabel: 'Reintentar',
          onAction: () =>
              ref.read(providerChatListProvider.notifier).refresh(),
        ),
        data: (conversations) => conversations.isEmpty
            ? const EmptyState(
                icon: Icons.chat_bubble_outline_rounded,
                title: 'Sin conversaciones aún',
                subtitle:
                    'Cuando un cliente te escriba, aparecerá aquí.',
              )
            : RefreshIndicator(
                color: AppColors.primary,
                onRefresh: () =>
                    ref.read(providerChatListProvider.notifier).refresh(),
                child: ListView.separated(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  itemCount: conversations.length,
                  separatorBuilder: (_, __) => Divider(
                    color: AppColors.outlineVariant.withOpacity(0.3),
                    indent: 72,
                  ),
                  itemBuilder: (context, i) {
                    final conv = conversations[i];
                    return ListTile(
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 4),
                      leading: CircleAvatar(
                        backgroundColor: AppColors.primary.withOpacity(0.2),
                        child: Text(
                          conv.otherPartyEmail.isNotEmpty
                              ? conv.otherPartyEmail[0].toUpperCase()
                              : '?',
                          style: const TextStyle(
                              color: AppColors.primary,
                              fontWeight: FontWeight.bold),
                        ),
                      ),
                      title: Text(
                        conv.otherPartyEmail,
                        style: const TextStyle(
                            color: AppColors.onSurface,
                            fontWeight: FontWeight.w600),
                      ),
                      subtitle: Text(
                        conv.lastMessage ?? 'Sin mensajes aún',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                            color: AppColors.onSurfaceVariant, fontSize: 12),
                      ),
                      trailing: Text(
                        _timeAgo(conv.updatedAt),
                        style: const TextStyle(
                            color: AppColors.onSurfaceVariant, fontSize: 11),
                      ),
                      onTap: () => context.goNamed(
                        RouteNames.chat,
                        pathParameters: {'id': conv.id},
                      ),
                    );
                  },
                ),
              ),
      ),
    );
  }

  String _timeAgo(DateTime dt) {
    final diff = DateTime.now().difference(dt);
    if (diff.inMinutes < 1) return 'ahora';
    if (diff.inHours < 1) return '${diff.inMinutes}m';
    if (diff.inDays < 1) return '${diff.inHours}h';
    return '${diff.inDays}d';
  }
}
