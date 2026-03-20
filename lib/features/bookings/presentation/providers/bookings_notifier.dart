import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sweet_mobile_app/core/di/providers.dart';
import 'package:sweet_mobile_app/features/bookings/data/datasources/bookings_datasource.dart';
import 'package:sweet_mobile_app/features/bookings/data/models/booking_model.dart';
import 'package:sweet_mobile_app/shared/models/service_model.dart';

// ── Provider de infraestructura ─────────────────────────────

final bookingsDsProvider = Provider<BookingsDataSource>(
  (ref) => BookingsDataSource(ref.read(dioClientProvider)),
);

// ── Lista de reservas del usuario ───────────────────────────

final bookingsProvider =
    AsyncNotifierProvider<BookingsNotifier, List<BookingModel>>(
        BookingsNotifier.new);

class BookingsNotifier extends AsyncNotifier<List<BookingModel>> {
  @override
  Future<List<BookingModel>> build() =>
      ref.read(bookingsDsProvider).fetchMyBookings();

  Future<void> refresh() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(
      () => ref.read(bookingsDsProvider).fetchMyBookings(),
    );
  }
}

// ── Detalle de una reserva ──────────────────────────────────

final bookingDetailProvider =
    AsyncNotifierProviderFamily<BookingDetailNotifier, BookingModel, String>(
        BookingDetailNotifier.new);

class BookingDetailNotifier
    extends FamilyAsyncNotifier<BookingModel, String> {
  @override
  Future<BookingModel> build(String bookingId) =>
      ref.read(bookingsDsProvider).fetchBooking(bookingId);
}

// ── Crear reserva ───────────────────────────────────────────

sealed class CreateBookingState {}
final class CreateBookingIdle extends CreateBookingState {}
final class CreateBookingLoading extends CreateBookingState {}
final class CreateBookingSuccess extends CreateBookingState {
  CreateBookingSuccess(this.booking);
  final BookingModel booking;
}
final class CreateBookingError extends CreateBookingState {
  CreateBookingError(this.message);
  final String message;
}

final createBookingProvider =
    NotifierProvider<CreateBookingNotifier, CreateBookingState>(
        CreateBookingNotifier.new);

class CreateBookingNotifier extends Notifier<CreateBookingState> {
  @override
  CreateBookingState build() => CreateBookingIdle();

  Future<bool> create({
    required ServiceModel service,
    required String providerId,
    DateTime? scheduledAt,
    String? notes,
  }) async {
    state = CreateBookingLoading();
    try {
      final booking = await ref.read(bookingsDsProvider).createBooking(
            serviceId: service.id,
            providerId: providerId,
            scheduledAt: scheduledAt?.toIso8601String(),
            notes: notes,
          );
      state = CreateBookingSuccess(booking);
      // Invalidar la lista para refrescar
      ref.invalidate(bookingsProvider);
      return true;
    } catch (e) {
      state = CreateBookingError(e.toString());
      return false;
    }
  }

  void reset() => state = CreateBookingIdle();
}
