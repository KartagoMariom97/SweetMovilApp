import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sweet_mobile_app/core/di/providers.dart';
import 'package:sweet_mobile_app/features/bookings/data/models/booking_model.dart';
import 'package:sweet_mobile_app/features/provider_dashboard/data/datasources/provider_datasource.dart';

// ── Infraestructura ─────────────────────────────────────────

final providerDsProvider = Provider<ProviderDataSource>(
  (ref) => ProviderDataSource(ref.read(dioClientProvider)),
);

// ── Stats model ─────────────────────────────────────────────

class ProviderStats {
  const ProviderStats({
    this.total = 0,
    this.pending = 0,
    this.confirmed = 0,
    this.inProgress = 0,
    this.completed = 0,
    this.estimatedEarnings = 0,
    this.recentPending = const [],
  });

  final int total;
  final int pending;
  final int confirmed;
  final int inProgress;
  final int completed;
  final double estimatedEarnings;
  final List<BookingModel> recentPending;

  factory ProviderStats.fromBookings(List<BookingModel> bookings) {
    final pending = bookings.where((b) => b.status == 'PENDING').toList();
    final confirmed = bookings.where((b) => b.status == 'CONFIRMED').length;
    final inProgress = bookings.where((b) => b.status == 'IN_PROGRESS').length;
    final completed = bookings.where((b) => b.status == 'COMPLETED').toList();
    final earnings =
        completed.fold<double>(0, (sum, b) => sum + b.totalPrice);

    return ProviderStats(
      total: bookings.length,
      pending: pending.length,
      confirmed: confirmed,
      inProgress: inProgress,
      completed: completed.length,
      estimatedEarnings: earnings,
      recentPending: pending.take(3).toList(),
    );
  }
}

// ── Notifier ────────────────────────────────────────────────

final providerDashboardProvider =
    AsyncNotifierProvider<ProviderDashboardNotifier, ProviderStats>(
  ProviderDashboardNotifier.new,
);

class ProviderDashboardNotifier extends AsyncNotifier<ProviderStats> {
  @override
  Future<ProviderStats> build() => _load();

  Future<ProviderStats> _load() async {
    final bookings = await ref.read(providerDsProvider).getMyBookings();
    return ProviderStats.fromBookings(bookings);
  }

  Future<void> refresh() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(_load);
  }
}
