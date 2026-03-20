import 'package:sweet_mobile_app/core/network/dio_client.dart';

class ReviewsDataSource {
  const ReviewsDataSource(this._client);
  final DioClient _client;

  Future<void> createReview({
    required String bookingId,
    required int rating,
    String? comment,
  }) async {
    await _client.post<Map<String, dynamic>>(
      '/reviews',
      data: {
        'bookingId': bookingId,
        'rating': rating,
        if (comment != null && comment.isNotEmpty) 'comment': comment,
      },
      fromJson: (json) => json as Map<String, dynamic>,
    );
  }
}
