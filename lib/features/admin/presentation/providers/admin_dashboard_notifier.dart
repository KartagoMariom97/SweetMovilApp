import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sweet_mobile_app/core/di/providers.dart';
import 'package:sweet_mobile_app/features/admin/data/datasources/admin_datasource.dart';

// ── Infraestructura ─────────────────────────────────────────

final adminDsProvider = Provider<AdminDataSource>(
  (ref) => AdminDataSource(ref.read(dioClientProvider)),
);

// ── Stats model ─────────────────────────────────────────────

class AdminStats {
  const AdminStats({
    this.totalUsers = 0,
    this.totalClients = 0,
    this.totalProviders = 0,
    this.activeUsers = 0,
    this.bannedUsers = 0,
    this.totalBookings = 0,
    this.pendingBookings = 0,
    this.completedBookings = 0,
    this.disputedBookings = 0,
    this.pendingReports = 0,
    this.totalReports = 0,
  });

  final int totalUsers;
  final int totalClients;
  final int totalProviders;
  final int activeUsers;
  final int bannedUsers;
  final int totalBookings;
  final int pendingBookings;
  final int completedBookings;
  final int disputedBookings;
  final int pendingReports;
  final int totalReports;
}

// ── Notifier ────────────────────────────────────────────────

final adminDashboardProvider =
    AsyncNotifierProvider<AdminDashboardNotifier, AdminStats>(
  AdminDashboardNotifier.new,
);

class AdminDashboardNotifier extends AsyncNotifier<AdminStats> {
  @override
  Future<AdminStats> build() => _load();

  Future<AdminStats> _load() async {
    final results = await Future.wait([
      ref.read(adminDsProvider).getUsers(),
      ref.read(adminDsProvider).getAllBookings(),
      ref.read(adminDsProvider).getTrustReports(),
    ]);

    final users = results[0];
    final bookings = results[1];
    final reports = results[2];

    return AdminStats(
      totalUsers: users.length,
      totalClients:
          users.where((u) => u.role == 'CLIENT').length,
      totalProviders:
          users.where((u) => u.role == 'PROVIDER').length,
      activeUsers: users.where((u) => u.isActive).length,
      bannedUsers: users.where((u) => !u.isActive).length,
      totalBookings: bookings.length,
      pendingBookings:
          bookings.where((b) => b.status == 'PENDING').length,
      completedBookings:
          bookings.where((b) => b.status == 'COMPLETED').length,
      disputedBookings:
          bookings.where((b) => b.status == 'DISPUTED').length,
      pendingReports:
          reports.where((r) => r.status == 'PENDING').length,
      totalReports: reports.length,
    );
  }

  Future<void> refresh() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(_load);
  }
}
