import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/repositories/review_repository.dart';
import '../../data/models/review_model.dart';
import 'customer_reviews_state.dart';

class CustomerReviewsCubit extends Cubit<CustomerReviewsState> {
  final ReviewRepository _reviewRepository;

  CustomerReviewsCubit({required ReviewRepository repository})
      : _reviewRepository = repository,
        super(const CustomerReviewsState());

  Future<void> loadCustomerReviews() async {
    try {
      emit(state.copyWith(status: CustomerReviewsStatus.loading));
      final items = await _reviewRepository.getCustomerReviews(page: 1, limit: 100);
      final map = <String, ReviewModel>{};
      for (final r in items) {
        map[r.productId] = r;
      }
      emit(state.copyWith(
        status: CustomerReviewsStatus.loaded,
        reviews: items,
        reviewsByProductId: map,
      ));
    } catch (e) {
      emit(state.copyWith(
        status: CustomerReviewsStatus.error,
        errorMessage: e.toString(),
      ));
    }
  }

  Future<bool> createReview({
    required String productId,
    required String orderId,
    String? variantId,
    required int rating,
    String? title,
    required String description,
    List<String>? images,
  }) async {
    try {
      emit(state.copyWith(status: CustomerReviewsStatus.submitting));
      final newReview = await _reviewRepository.createReview(
        productId: productId,
        orderId: orderId,
        variantId: variantId,
        rating: rating,
        title: title,
        description: description,
        images: images,
      );

      final updatedReviews = [newReview, ...state.reviews];
      final updatedMap = Map<String, ReviewModel>.from(state.reviewsByProductId);
      updatedMap[productId] = newReview;

      emit(state.copyWith(
        status: CustomerReviewsStatus.success,
        reviews: updatedReviews,
        reviewsByProductId: updatedMap,
        successMessage: 'Thank you for your review.',
      ));
      return true;
    } catch (e) {
      emit(state.copyWith(
        status: CustomerReviewsStatus.error,
        errorMessage: _extractErrorMessage(e),
      ));
      return false;
    }
  }

  Future<bool> updateReview({
    required String reviewId,
    required String productId,
    required int rating,
    String? title,
    required String description,
    List<String>? images,
  }) async {
    try {
      emit(state.copyWith(status: CustomerReviewsStatus.submitting));
      final updated = await _reviewRepository.updateReview(
        reviewId: reviewId,
        rating: rating,
        title: title,
        description: description,
        images: images,
      );

      final updatedReviews = state.reviews
          .map((r) => r.id == reviewId ? updated : r)
          .toList();
      final updatedMap = Map<String, ReviewModel>.from(state.reviewsByProductId);
      updatedMap[productId] = updated;

      emit(state.copyWith(
        status: CustomerReviewsStatus.success,
        reviews: updatedReviews,
        reviewsByProductId: updatedMap,
        successMessage: 'Review updated successfully.',
      ));
      return true;
    } catch (e) {
      emit(state.copyWith(
        status: CustomerReviewsStatus.error,
        errorMessage: _extractErrorMessage(e),
      ));
      return false;
    }
  }

  Future<bool> deleteReview({
    required String reviewId,
    required String productId,
  }) async {
    try {
      emit(state.copyWith(status: CustomerReviewsStatus.submitting));
      await _reviewRepository.deleteReview(reviewId);

      final updatedReviews = state.reviews.where((r) => r.id != reviewId).toList();
      final updatedMap = Map<String, ReviewModel>.from(state.reviewsByProductId);
      updatedMap.remove(productId);

      emit(state.copyWith(
        status: CustomerReviewsStatus.success,
        reviews: updatedReviews,
        reviewsByProductId: updatedMap,
        successMessage: 'Review deleted successfully.',
      ));
      return true;
    } catch (e) {
      emit(state.copyWith(
        status: CustomerReviewsStatus.error,
        errorMessage: _extractErrorMessage(e),
      ));
      return false;
    }
  }

  String _extractErrorMessage(dynamic error) {
    final str = error.toString();
    if (str.contains('409') || str.contains('already submitted')) {
      return 'You have already submitted a review for this product.';
    }
    if (str.contains('delivered order')) {
      return 'You can only review products from a delivered order.';
    }
    return 'Failed to process review. Please try again.';
  }
}
