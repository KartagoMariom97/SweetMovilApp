import 'package:sweet_mobile_app/core/network/dio_client.dart';
import 'package:sweet_mobile_app/features/admin/data/models/trust_report_model.dart';
import 'package:sweet_mobile_app/features/admin/data/models/user_admin_model.dart';
import 'package:sweet_mobile_app/features/bookings/data/models/booking_model.dart';

class AdminDataSource {
  const AdminDataSource(this._client);
  final DioClient _client;

  // ── Users ────────────────────────────────────────────────

  Future<List<UserAdminModel>> getUsers() async {
    final list = await _client.get<List<dynamic>>(
      '/users',
      fromJson: (json) => json as List<dynamic>,
    );
    return list
        .cast<Map<String, dynamic>>()
        .map(UserAdminModel.fromJson)
        .toList();
  }

  Future<void> toggleUserActive(String userId, {required bool isActive}) async {
    await _client.patch<Map<String, dynamic>>(
      '/users/$userId/active',
      data: {'isActive': isActive},
      fromJson: (json) => json as Map<String, dynamic>,
    );
  }

  // ── Bookings ─────────────────────────────────────────────

  Future<List<BookingModel>> getAllBookings() async {
    final list = await _client.get<List<dynamic>>(
      '/bookings',
      fromJson: (json) => json as List<dynamic>,
    );
    return list
        .cast<Map<String, dynamic>>()
        .map(BookingModel.fromJson)
        .toList();
  }

  // ── Trust Reports ────────────────────────────────────────

  Future<List<TrustReportModel>> getTrustReports() async {
    final list = await _client.get<List<dynamic>>(
      '/trust-reports',
      fromJson: (json) => json as List<dynamic>,
    );
    return list
        .cast<Map<String, dynamic>>()
        .map(TrustReportModel.fromJson)
        .toList();
  }

  Future<TrustReportModel> updateReportStatus(
    String reportId,
    String status, {
    String? adminNote,
  }) async {
    return _client.patch<TrustReportModel>(
      '/trust-reports/$reportId/status',
      data: {
        'status': status,
        if (adminNote != null && adminNote.isNotEmpty) 'adminNote': adminNote,
      },
      fromJson: (json) =>
          TrustReportModel.fromJson(json as Map<String, dynamic>),
    );
  }

  // ── Profile ──────────────────────────────────────────────

  Future<Map<String, dynamic>> getMyProfile() async {
    return _client.get<Map<String, dynamic>>(
      '/users/profile',
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
}
