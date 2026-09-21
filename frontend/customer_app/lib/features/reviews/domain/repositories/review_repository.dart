import '../../data/models/review_model.dart';

abstract class ReviewRepository {
  Future<ReviewModel> createReview({
    required String productId,
    required String orderId,
    String? variantId,
    required int rating,
    String? title,
    required String description,
    List<String>? images,
  });

  Future<ReviewModel> updateReview({
    required String reviewId,
    required int rating,
    String? title,
    required String description,
    List<String>? images,
  });

  Future<void> deleteReview(String reviewId);

  Future<List<ReviewModel>> getCustomerReviews({int page = 1, int limit = 50});

  Future<List<Map<String, dynamic>>> getEligibleProducts();

  Future<ProductReviewsResponse> getProductReviews(
    String productId, {
    int page = 1,
    int limit = 10,
    int? rating,
    String sortBy = 'newest',
  });

  Future<RatingSummaryModel> getRatingSummary(String productId);
}
