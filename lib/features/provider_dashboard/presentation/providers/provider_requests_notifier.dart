import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sweet_mobile_app/features/bookings/data/models/booking_model.dart';
import 'package:sweet_mobile_app/features/provider_dashboard/data/datasources/provider_datasource.dart';
import 'package:sweet_mobile_app/features/provider_dashboard/presentation/providers/provider_dashboard_notifier.dart';

// ── Action state ─────────────────────────────────────────────

sealed class RequestActionState {}

final class RequestActionIdle extends RequestActionState {}

final class RequestActionLoading extends RequestActionState {}

final class RequestActionSuccess extends RequestActionState {}

final class RequestActionError extends RequestActionState {
  RequestActionError(this.message);
  final String message;
}

// ── Providers ────────────────────────────────────────────────

/// Lista de reservas con estado PENDING para este proveedor.
final providerRequestsProvider =
    AsyncNotifierProvider<ProviderRequestsNotifier, List<BookingModel>>(
  ProviderRequestsNotifier.new,
);

final requestActionProvider =
    NotifierProvider<RequestActionNotifier, RequestActionState>(
  RequestActionNotifier.new,
);

// ── Requests Notifier ────────────────────────────────────────

class ProviderRequestsNotifier extends AsyncNotifier<List<BookingModel>> {
  @override
  Future<List<BookingModel>> build() => _load();

  Future<List<BookingModel>> _load() async {
    final all = await ref.read(providerDsProvider).getMyBookings();
    return all.where((b) => b.status == 'PENDING').toList()
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
  }

  Future<void> refresh() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(_load);
  }
}

// ── Action Notifier ──────────────────────────────────────────

class RequestActionNotifier extends Notifier<RequestActionState> {
  @override
  RequestActionState build() => RequestActionIdle();

  /// Aprueba la solicitud y agenda la cita.
  Future<bool> approve(String bookingId, DateTime scheduledAt) async {
    state = RequestActionLoading();
    try {
      await ref.read(providerDsProvider).updateBookingStatus(
            bookingId,
            'CONFIRMED',
            scheduledAt: scheduledAt,
          );
      state = RequestActionSuccess();
      ref.invalidate(providerRequestsProvider);
      ref.invalidate(providerDashboardProvider);
      return true;
    } catch (e) {
      state = RequestActionError(e.toString());
      return false;
    }
  }

  /// Rechaza la solicitud (CANCELLED).
  Future<bool> reject(String bookingId) async {
    state = RequestActionLoading();
    try {
      await ref
          .read(providerDsProvider)
          .updateBookingStatus(bookingId, 'CANCELLED');
      state = RequestActionSuccess();
      ref.invalidate(providerRequestsProvider);
      ref.invalidate(providerDashboardProvider);
      return true;
    } catch (e) {
      state = RequestActionError(e.toString());
      return false;
    }
  }

  void reset() => state = RequestActionIdle();
}
