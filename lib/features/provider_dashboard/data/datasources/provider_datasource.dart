import 'package:sweet_mobile_app/core/network/dio_client.dart';
import 'package:sweet_mobile_app/features/bookings/data/models/booking_model.dart';
import 'package:sweet_mobile_app/shared/models/category_model.dart';
import 'package:sweet_mobile_app/shared/models/service_model.dart';

class ProviderDataSource {
  const ProviderDataSource(this._client);
  final DioClient _client;

  // ── Bookings ──────────────────────────────────────────────

  Future<List<BookingModel>> getMyBookings() async {
    final list = await _client.get<List<dynamic>>(
      '/bookings',
      fromJson: (json) => json as List<dynamic>,
    );
    return list.cast<Map<String, dynamic>>().map(BookingModel.fromJson).toList();
  }

  Future<BookingModel> updateBookingStatus(
    String bookingId,
    String status, {
    DateTime? scheduledAt,
  }) async {
    return _client.patch<BookingModel>(
      '/bookings/$bookingId/status',
      data: {
        'status': status,
        if (scheduledAt != null) 'scheduledAt': scheduledAt.toIso8601String(),
      },
      fromJson: (json) => BookingModel.fromJson(json as Map<String, dynamic>),
    );
  }

  // ── Services ──────────────────────────────────────────────

  Future<List<ServiceModel>> getMyServices(String providerId) async {
    final list = await _client.get<List<dynamic>>(
      '/services?providerId=$providerId',
      fromJson: (json) => json as List<dynamic>,
    );
    return list.cast<Map<String, dynamic>>().map(ServiceModel.fromJson).toList();
  }

  Future<List<CategoryModel>> getCategories() async {
    final list = await _client.get<List<dynamic>>(
      '/services/categories',
      fromJson: (json) => json as List<dynamic>,
    );
    return list
        .cast<Map<String, dynamic>>()
        .map(CategoryModel.fromJson)
        .toList();
  }

  Future<ServiceModel> createService(Map<String, dynamic> data) async {
    return _client.post<ServiceModel>(
      '/services',
      data: data,
      fromJson: (json) => ServiceModel.fromJson(json as Map<String, dynamic>),
    );
  }

  Future<ServiceModel> updateService(
    String id,
    Map<String, dynamic> data,
  ) async {
    return _client.patch<ServiceModel>(
      '/services/$id',
      data: data,
      fromJson: (json) => ServiceModel.fromJson(json as Map<String, dynamic>),
    );
  }

  Future<void> deleteService(String id) async {
    await _client.delete('/services/$id');
  }

  // ── Chat ─────────────────────────────────────────────────

  Future<List<Map<String, dynamic>>> getMyConversations() async {
    final list = await _client.get<List<dynamic>>(
      '/chat/conversations',
      fromJson: (json) => json as List<dynamic>,
    );
    return list.cast<Map<String, dynamic>>();
  }

  // ── Profile ──────────────────────────────────────────────

  Future<Map<String, dynamic>> getMyProfile() async {
    return _client.get<Map<String, dynamic>>(
      '/users/profile',
      fromJson: (json) => json as Map<String, dynamic>,
    );
  }

  Future<Map<String, dynamic>> getMyProviderProfile() async {
    return _client.get<Map<String, dynamic>>(
      '/users/provider-profile',
      fromJson: (json) => json as Map<String, dynamic>,
    );
  }

  Future<void> updateProfile(Map<String, dynamic> data) async {
    await _client.patch<Map<String, dynamic>>(
      '/users/profile',
      data: data,
      fromJson: (json) => json as Map<String, dynamic>,
    );
  }

  Future<void> updateAvailability({required bool isAvailable}) async {
    await _client.patch<Map<String, dynamic>>(
      '/users/provider-profile/availability',
      data: {'isAvailable': isAvailable},
      fromJson: (json) => json as Map<String, dynamic>,
    );
  }
}
