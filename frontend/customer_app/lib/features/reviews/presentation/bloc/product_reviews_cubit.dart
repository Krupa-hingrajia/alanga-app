import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/repositories/review_repository.dart';
import 'product_reviews_state.dart';

class ProductReviewsCubit extends Cubit<ProductReviewsState> {
  final ReviewRepository _reviewRepository;

  ProductReviewsCubit({required ReviewRepository repository})
      : _reviewRepository = repository,
        super(const ProductReviewsState());

  Future<void> fetchProductReviews(
    String productId, {
    int? rating,
    String? sortBy,
  }) async {
    try {
      emit(state.copyWith(
        status: ProductReviewsStatus.loading,
        selectedRating: () => rating ?? state.selectedRating,
        sortBy: sortBy ?? state.sortBy,
      ));

      final res = await _reviewRepository.getProductReviews(
        productId,
        page: 1,
        limit: 20,
        rating: rating ?? state.selectedRating,
        sortBy: sortBy ?? state.sortBy,
      );

      emit(state.copyWith(
        status: ProductReviewsStatus.loaded,
        response: res,
      ));
    } catch (e) {
      emit(state.copyWith(
        status: ProductReviewsStatus.error,
        errorMessage: e.toString(),
      ));
    }
  }

  void filterByRating(String productId, int? rating) {
    // If clicking same rating again, toggle off
    final newRating = state.selectedRating == rating ? null : rating;
    fetchProductReviews(productId, rating: newRating);
  }

  void changeSortBy(String productId, String sortBy) {
    if (state.sortBy == sortBy) return;
    fetchProductReviews(productId, sortBy: sortBy);
  }
}
