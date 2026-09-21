import '../../data/datasources/review_remote_datasource.dart';
import '../../data/models/review_model.dart';
import '../../domain/repositories/review_repository.dart';

class ReviewRepositoryImpl implements ReviewRepository {
  final ReviewRemoteDataSource _remoteDataSource;

  ReviewRepositoryImpl({required ReviewRemoteDataSource remoteDataSource})
      : _remoteDataSource = remoteDataSource;

  @override
  Future<ReviewModel> createReview({
    required String productId,
    required String orderId,
    String? variantId,
    required int rating,
    String? title,
    required String description,
    List<String>? images,
  }) {
    return _remoteDataSource.createReview(
      productId: productId,
      orderId: orderId,
      variantId: variantId,
      rating: rating,
      title: title,
      description: description,
      images: images,
    );
  }

  @override
  Future<ReviewModel> updateReview({
    required String reviewId,
    required int rating,
    String? title,
    required String description,
    List<String>? images,
  }) {
    return _remoteDataSource.updateReview(
      reviewId: reviewId,
      rating: rating,
      title: title,
      description: description,
      images: images,
    );
  }

  @override
  Future<void> deleteReview(String reviewId) {
    return _remoteDataSource.deleteReview(reviewId);
  }

  @override
  Future<List<ReviewModel>> getCustomerReviews({int page = 1, int limit = 50}) {
    return _remoteDataSource.getCustomerReviews(page: page, limit: limit);
  }

  @override
  Future<List<Map<String, dynamic>>> getEligibleProducts() {
    return _remoteDataSource.getEligibleProducts();
  }

  @override
  Future<ProductReviewsResponse> getProductReviews(
    String productId, {
    int page = 1,
    int limit = 10,
    int? rating,
    String sortBy = 'newest',
  }) {
    return _remoteDataSource.getProductReviews(
      productId,
      page: page,
      limit: limit,
      rating: rating,
      sortBy: sortBy,
    );
  }

  @override
  Future<RatingSummaryModel> getRatingSummary(String productId) {
    return _remoteDataSource.getRatingSummary(productId);
  }
}
