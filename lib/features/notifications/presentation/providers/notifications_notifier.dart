import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sweet_mobile_app/core/di/providers.dart';
import 'package:sweet_mobile_app/features/notifications/data/datasources/notifications_datasource.dart';

// ── Infraestructura ─────────────────────────────────────────

final notificationsDsProvider = Provider<NotificationsDataSource>(
  (ref) => NotificationsDataSource(ref.read(dioClientProvider)),
);

// ── Provider ─────────────────────────────────────────────────

final notificationsProvider =
    AsyncNotifierProvider<NotificationsNotifier, List<NotificationModel>>(
  NotificationsNotifier.new,
);

class NotificationsNotifier extends AsyncNotifier<List<NotificationModel>> {
  @override
  Future<List<NotificationModel>> build() => _load();

  Future<List<NotificationModel>> _load() async {
    final list =
        await ref.read(notificationsDsProvider).getMyNotifications();
    return list..sort((a, b) => b.createdAt.compareTo(a.createdAt));
  }

  Future<void> refresh() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(_load);
  }

  Future<void> markRead(String id) async {
    await ref.read(notificationsDsProvider).markRead(id);
    state = state.whenData((list) => list
        .map((n) => n.id == id ? n.copyWith(isRead: true) : n)
        .toList());
  }

  Future<void> markAllRead() async {
    await ref.read(notificationsDsProvider).markAllRead();
    state = state.whenData(
        (list) => list.map((n) => n.copyWith(isRead: true)).toList());
  }

  int get unreadCount =>
      state.valueOrNull?.where((n) => !n.isRead).length ?? 0;
}
