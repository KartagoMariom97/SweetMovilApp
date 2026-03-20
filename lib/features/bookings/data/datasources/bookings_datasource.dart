import 'package:sweet_mobile_app/core/network/dio_client.dart';
import 'package:sweet_mobile_app/features/bookings/data/models/booking_model.dart';

class BookingsDataSource {
  const BookingsDataSource(this._client);
  final DioClient _client;

  Future<List<BookingModel>> fetchMyBookings() async {
    final list = await _client.get<List<dynamic>>(
      '/bookings',
      fromJson: (json) => json as List<dynamic>,
    );
    return list
        .cast<Map<String, dynamic>>()
        .map(BookingModel.fromJson)
        .toList();
  }

  Future<BookingModel> fetchBooking(String id) async {
    return _client.get<BookingModel>(
      '/bookings/$id',
      fromJson: (json) => BookingModel.fromJson(json as Map<String, dynamic>),
    );
  }

  Future<BookingModel> createBooking({
    required String serviceId,
    required String providerId,
    String? scheduledAt,
    String? notes,
  }) async {
    return _client.post<BookingModel>(
      '/bookings',
      data: {
        'serviceId': serviceId,
        'providerId': providerId,
        if (scheduledAt != null) 'scheduledAt': scheduledAt,
        if (notes != null && notes.isNotEmpty) 'notes': notes,
      },
      fromJson: (json) => BookingModel.fromJson(json as Map<String, dynamic>),
    );
  }
}
