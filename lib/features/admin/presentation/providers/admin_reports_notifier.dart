import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sweet_mobile_app/features/admin/data/models/trust_report_model.dart';
import 'package:sweet_mobile_app/features/admin/presentation/providers/admin_dashboard_notifier.dart';
import 'package:sweet_mobile_app/features/bookings/data/models/booking_model.dart';

// ── Trust Reports ────────────────────────────────────────────

final adminReportsProvider =
    AsyncNotifierProvider<AdminReportsNotifier, List<TrustReportModel>>(
  AdminReportsNotifier.new,
);

class AdminReportsNotifier extends AsyncNotifier<List<TrustReportModel>> {
  @override
  Future<List<TrustReportModel>> build() => _load();

  Future<List<TrustReportModel>> _load() async {
    final reports = await ref.read(adminDsProvider).getTrustReports();
    return reports..sort((a, b) => b.createdAt.compareTo(a.createdAt));
  }

  Future<void> refresh() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(_load);
  }

  Future<bool> resolve(String reportId, {String? adminNote}) async {
    try {
      final updated = await ref
          .read(adminDsProvider)
          .updateReportStatus(reportId, 'REVIEWED', adminNote: adminNote);
      state = state.whenData(
          (reports) => reports.map((r) => r.id == reportId ? updated : r).toList());
      ref.invalidate(adminDashboardProvider);
      return true;
    } catch (_) {
      return false;
    }
  }

  Future<bool> dismiss(String reportId, {String? adminNote}) async {
    try {
      final updated = await ref
          .read(adminDsProvider)
          .updateReportStatus(reportId, 'DISMISSED', adminNote: adminNote);
      state = state.whenData(
          (reports) => reports.map((r) => r.id == reportId ? updated : r).toList());
      ref.invalidate(adminDashboardProvider);
      return true;
    } catch (_) {
      return false;
    }
  }
}

// ── Bookings (admin) ─────────────────────────────────────────

class AdminBookingsState {
  const AdminBookingsState({
    required this.all,
    required this.filtered,
    this.statusFilter = 'ALL',
  });
  final List<BookingModel> all;
  final List<BookingModel> filtered;
  final String statusFilter;
}

final adminBookingsProvider =
    AsyncNotifierProvider<AdminBookingsNotifier, AdminBookingsState>(
  AdminBookingsNotifier.new,
);

class AdminBookingsNotifier extends AsyncNotifier<AdminBookingsState> {
  String _statusFilter = 'ALL';

  @override
  Future<AdminBookingsState> build() => _load();

  Future<AdminBookingsState> _load() async {
    final bookings = await ref.read(adminDsProvider).getAllBookings();
    bookings.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return AdminBookingsState(
      all: bookings,
      filtered: _filter(bookings, _statusFilter),
      statusFilter: _statusFilter,
    );
  }

  Future<void> refresh() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(_load);
  }

  void setFilter(String status) {
    _statusFilter = status;
    state = state.whenData((s) => AdminBookingsState(
          all: s.all,
          filtered: _filter(s.all, status),
          statusFilter: status,
        ));
  }

  List<BookingModel> _filter(List<BookingModel> all, String filter) =>
      filter == 'ALL' ? all : all.where((b) => b.status == filter).toList();
}
