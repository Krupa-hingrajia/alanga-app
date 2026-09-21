import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/repositories/review_repository.dart';
import '../../data/models/review_model.dart';
import 'review_state.dart';

class ReviewCubit extends Cubit<ReviewState> {
  final ReviewRepository _reviewRepository;

  ReviewCubit({required ReviewRepository repository})
      : _reviewRepository = repository,
        super(const ReviewState());

  // ====================================================
  // PRODUCT REVIEWS & INFINITE SCROLL
  // ====================================================

  Future<void> loadProductReviews(
    String productId, {
    int? rating,
    String? sortBy,
    bool refresh = true,
  }) async {
    try {
      final activeRating = rating ?? state.selectedRating;
      final activeSort = sortBy ?? state.sortBy;

      if (refresh) {
        emit(state.copyWith(
          status: ReviewStatus.loading,
          selectedRating: () => activeRating,
          sortBy: activeSort,
        ));
      }

      // Map 'oldest' to 'newest' for backend API, then reverse locally if needed
      final backendSort = (activeSort == 'oldest') ? 'newest' : activeSort;

      final futures = await Future.wait([
        _reviewRepository.getProductReviews(
          productId,
          page: 1,
          limit: 10,
          rating: activeRating,
          sortBy: backendSort,
        ),
        _reviewRepository.getRatingSummary(productId).catchError((_) => RatingSummaryModel(
              productId: productId,
              averageRating: 0.0,
              totalReviews: 0,
            )),
      ]);

      final productReviewsRes = futures[0] as ProductReviewsResponse;
      final summaryRes = futures[1] as RatingSummaryModel;

      List<ReviewModel> items = List<ReviewModel>.from(productReviewsRes.items);
      if (activeSort == 'oldest') {
        items = items.reversed.toList();
      }

      emit(state.copyWith(
        status: ReviewStatus.loaded,
        productReviews: items,
        ratingSummary: () => summaryRes.totalReviews > 0
            ? summaryRes
            : RatingSummaryModel(
                productId: productId,
                averageRating: productReviewsRes.averageRating,
                totalReviews: productReviewsRes.totalReviews,
                ratingDistribution: productReviewsRes.ratingDistribution,
              ),
        currentPage: 1,
        totalReviews: productReviewsRes.total,
        totalPages: productReviewsRes.totalPages,
        hasMore: productReviewsRes.page < productReviewsRes.totalPages,
        isLoadingMore: false,
      ));
    } catch (e) {
      emit(state.copyWith(
        status: ReviewStatus.error,
        errorMessage: _extractErrorMessage(e),
      ));
    }
  }

  Future<void> loadMoreReviews(String productId) async {
    if (!state.hasMore || state.isLoadingMore || state.status == ReviewStatus.loading) {
      return;
    }

    try {
      emit(state.copyWith(isLoadingMore: true));

      final nextPage = state.currentPage + 1;
      final backendSort = (state.sortBy == 'oldest') ? 'newest' : state.sortBy;

      final res = await _reviewRepository.getProductReviews(
        productId,
        page: nextPage,
        limit: 10,
        rating: state.selectedRating,
        sortBy: backendSort,
      );

      List<ReviewModel> nextItems = List<ReviewModel>.from(res.items);
      if (state.sortBy == 'oldest') {
        nextItems = nextItems.reversed.toList();
      }

      final combined = [...state.productReviews, ...nextItems];

      emit(state.copyWith(
        productReviews: combined,
        currentPage: nextPage,
        hasMore: nextPage < res.totalPages,
        isLoadingMore: false,
      ));
    } catch (e) {
      emit(state.copyWith(isLoadingMore: false));
    }
  }

  void filterByRating(String productId, int? rating) {
    final newRating = state.selectedRating == rating ? null : rating;
    loadProductReviews(productId, rating: newRating, refresh: true);
  }

  void changeSortBy(String productId, String sortBy) {
    if (state.sortBy == sortBy) return;
    loadProductReviews(productId, sortBy: sortBy, refresh: true);
  }

  // ====================================================
  // CUSTOMER REVIEWS (MY REVIEWS & ORDER STATUS CHECKS)
  // ====================================================

  Future<void> loadCustomerReviews() async {
    try {
      emit(state.copyWith(status: ReviewStatus.loading));
      final items = await _reviewRepository.getCustomerReviews(page: 1, limit: 100);
      final map = <String, ReviewModel>{};
      for (final r in items) {
        map[r.productId] = r;
      }
      emit(state.copyWith(
        status: ReviewStatus.loaded,
        customerReviews: items,
        customerReviewsByProductId: map,
      ));
    } catch (e) {
      emit(state.copyWith(
        status: ReviewStatus.error,
        errorMessage: _extractErrorMessage(e),
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
      emit(state.copyWith(status: ReviewStatus.submitting));
      final newReview = await _reviewRepository.createReview(
        productId: productId,
        orderId: orderId,
        variantId: variantId,
        rating: rating,
        title: title,
        description: description,
        images: images,
      );

      final updatedCustomerReviews = [newReview, ...state.customerReviews];
      final updatedMap = Map<String, ReviewModel>.from(state.customerReviewsByProductId);
      updatedMap[productId] = newReview;

      final updatedProductReviews = [newReview, ...state.productReviews];

      emit(state.copyWith(
        status: ReviewStatus.success,
        customerReviews: updatedCustomerReviews,
        customerReviewsByProductId: updatedMap,
        productReviews: updatedProductReviews,
        successMessage: 'Thank you for your review.',
      ));
      return true;
    } catch (e) {
      emit(state.copyWith(
        status: ReviewStatus.error,
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
      emit(state.copyWith(status: ReviewStatus.submitting));
      final updated = await _reviewRepository.updateReview(
        reviewId: reviewId,
        rating: rating,
        title: title,
        description: description,
        images: images,
      );

      final updatedCustomerReviews = state.customerReviews
          .map((r) => r.id == reviewId ? updated : r)
          .toList();
      final updatedMap = Map<String, ReviewModel>.from(state.customerReviewsByProductId);
      updatedMap[productId] = updated;

      final updatedProductReviews = state.productReviews
          .map((r) => r.id == reviewId ? updated : r)
          .toList();

      emit(state.copyWith(
        status: ReviewStatus.success,
        customerReviews: updatedCustomerReviews,
        customerReviewsByProductId: updatedMap,
        productReviews: updatedProductReviews,
        successMessage: 'Review updated successfully.',
      ));
      return true;
    } catch (e) {
      emit(state.copyWith(
        status: ReviewStatus.error,
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
      emit(state.copyWith(status: ReviewStatus.submitting));
      await _reviewRepository.deleteReview(reviewId);

      final updatedCustomerReviews = state.customerReviews.where((r) => r.id != reviewId).toList();
      final updatedMap = Map<String, ReviewModel>.from(state.customerReviewsByProductId);
      updatedMap.remove(productId);

      final updatedProductReviews = state.productReviews.where((r) => r.id != reviewId).toList();

      emit(state.copyWith(
        status: ReviewStatus.success,
        customerReviews: updatedCustomerReviews,
        customerReviewsByProductId: updatedMap,
        productReviews: updatedProductReviews,
        successMessage: 'Review deleted successfully.',
      ));
      return true;
    } catch (e) {
      emit(state.copyWith(
        status: ReviewStatus.error,
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
    if (str.contains('delivered order') || str.contains('not delivered')) {
      return 'You can only review products from a delivered order.';
    }
    if (str.contains('at least 10 characters')) {
      return 'Review description must be at least 10 characters long.';
    }
    return 'Failed to process review. Please try again.';
  }
}
