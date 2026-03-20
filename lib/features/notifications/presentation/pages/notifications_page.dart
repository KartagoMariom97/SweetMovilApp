import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sweet_mobile_app/core/theme/app_colors.dart';
import 'package:sweet_mobile_app/features/notifications/data/datasources/notifications_datasource.dart';
import 'package:sweet_mobile_app/features/notifications/presentation/providers/notifications_notifier.dart';
import 'package:sweet_mobile_app/shared/widgets/empty_state.dart';

class NotificationsPage extends ConsumerWidget {
  const NotificationsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notifAsync = ref.watch(notificationsProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        title: const Text('Notificaciones'),
        actions: [
          notifAsync.whenData((list) {
            final hasUnread = list.any((n) => !n.isRead);
            if (!hasUnread) return const SizedBox.shrink();
            return TextButton(
              onPressed: () =>
                  ref.read(notificationsProvider.notifier).markAllRead(),
              child: const Text(
                'Leer todas',
                style: TextStyle(color: AppColors.secondary, fontSize: 13),
              ),
            );
          }).value ??
              const SizedBox.shrink(),
        ],
      ),
      body: notifAsync.when(
        loading: () => const Center(
            child: CircularProgressIndicator(color: AppColors.primary)),
        error: (e, _) => EmptyState(
          icon: Icons.error_outline_rounded,
          title: 'Error al cargar',
          subtitle: e.toString(),
          actionLabel: 'Reintentar',
          onAction: () => ref.read(notificationsProvider.notifier).refresh(),
        ),
        data: (notifications) => notifications.isEmpty
            ? const EmptyState(
                icon: Icons.notifications_none_rounded,
                title: 'Sin notificaciones',
                subtitle: 'Aquí aparecerán las alertas del sistema.',
              )
            : RefreshIndicator(
                color: AppColors.primary,
                onRefresh: () =>
                    ref.read(notificationsProvider.notifier).refresh(),
                child: ListView.separated(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  itemCount: notifications.length,
                  separatorBuilder: (_, __) => Divider(
                    height: 1,
                    color: AppColors.outlineVariant.withOpacity(0.3),
                    indent: 16,
                    endIndent: 16,
                  ),
                  itemBuilder: (context, i) {
                    final n = notifications[i];
                    return _NotificationTile(
                      notification: n,
                      onTap: () => n.isRead
                          ? null
                          : ref
                              .read(notificationsProvider.notifier)
                              .markRead(n.id),
                    ).animate().fadeIn(delay: (i * 30).ms);
                  },
                ),
              ),
      ),
    );
  }
}

// ── Notification Tile ─────────────────────────────────────────

class _NotificationTile extends StatelessWidget {
  const _NotificationTile({
    required this.notification,
    required this.onTap,
  });

  final NotificationModel notification;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final isRead = notification.isRead;

    return InkWell(
      onTap: onTap,
      child: Container(
        color: isRead ? Colors.transparent : AppColors.primary.withOpacity(0.05),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Indicador de no leído
            Container(
              width: 8,
              height: 8,
              margin: const EdgeInsets.only(top: 6, right: 10),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isRead
                    ? Colors.transparent
                    : AppColors.primary,
              ),
            ),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    notification.title,
                    style: TextStyle(
                      color: AppColors.onSurface,
                      fontWeight:
                          isRead ? FontWeight.normal : FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    notification.message,
                    style: const TextStyle(
                        color: AppColors.onSurfaceVariant, fontSize: 13),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _timeAgo(notification.createdAt),
                    style: const TextStyle(
                        color: AppColors.onSurfaceVariant, fontSize: 11),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _timeAgo(DateTime dt) {
    final diff = DateTime.now().difference(dt);
    if (diff.inMinutes < 1) return 'Ahora mismo';
    if (diff.inHours < 1) return 'Hace ${diff.inMinutes} min';
    if (diff.inDays < 1) return 'Hace ${diff.inHours} h';
    if (diff.inDays == 1) return 'Ayer';
    return 'Hace ${diff.inDays} días';
  }
}
