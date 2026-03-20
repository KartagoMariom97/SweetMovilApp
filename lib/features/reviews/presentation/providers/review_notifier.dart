import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sweet_mobile_app/core/di/providers.dart';
import 'package:sweet_mobile_app/features/reviews/data/datasources/reviews_datasource.dart';

// ── Infraestructura ─────────────────────────────────────────

final reviewsDsProvider = Provider<ReviewsDataSource>(
  (ref) => ReviewsDataSource(ref.read(dioClientProvider)),
);

// ── State ────────────────────────────────────────────────────

sealed class ReviewState {}

final class ReviewIdle extends ReviewState {}

final class ReviewLoading extends ReviewState {}

final class ReviewSuccess extends ReviewState {}

final class ReviewError extends ReviewState {
  ReviewError(this.message);
  final String message;
}

// ── Provider ─────────────────────────────────────────────────

final reviewProvider =
    NotifierProvider<ReviewNotifier, ReviewState>(ReviewNotifier.new);

class ReviewNotifier extends Notifier<ReviewState> {
  @override
  ReviewState build() => ReviewIdle();

  Future<bool> submit({
    required String bookingId,
    required int rating,
    String? comment,
  }) async {
    state = ReviewLoading();
    try {
      await ref.read(reviewsDsProvider).createReview(
            bookingId: bookingId,
            rating: rating,
            comment: comment,
          );
      state = ReviewSuccess();
      return true;
    } catch (e) {
      state = ReviewError(e.toString());
      return false;
    }
  }

  void reset() => state = ReviewIdle();
}
