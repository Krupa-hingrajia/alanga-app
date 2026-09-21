import '../../../../core/network/api_service.dart';
import '../models/review_model.dart';

abstract class ReviewRemoteDataSource {
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

class ReviewRemoteDataSourceImpl implements ReviewRemoteDataSource {
  final ApiService _apiService;

  ReviewRemoteDataSourceImpl({required ApiService apiService}) : _apiService = apiService;

  @override
  Future<ReviewModel> createReview({
    required String productId,
    required String orderId,
    String? variantId,
    required int rating,
    String? title,
    required String description,
    List<String>? images,
  }) async {
    final payload = {
      'productId': productId,
      'orderId': orderId,
      if (variantId != null && variantId.isNotEmpty) 'variantId': variantId,
      'rating': rating,
      if (title != null && title.trim().isNotEmpty) 'title': title.trim(),
      'description': description.trim(),
      if (images != null && images.isNotEmpty) 'images': images,
    };

    final response = await _apiService.post(
      '/customer/reviews',
      data: payload,
    );

    final data = response.data['data'] as Map<String, dynamic>;
    return ReviewModel.fromJson(data);
  }

  @override
  Future<ReviewModel> updateReview({
    required String reviewId,
    required int rating,
    String? title,
    required String description,
    List<String>? images,
  }) async {
    final payload = {
      'rating': rating,
      'title': (title != null && title.trim().isNotEmpty) ? title.trim() : null,
      'description': description.trim(),
      'images': images ?? [],
    };

    final response = await _apiService.put(
      '/customer/reviews/$reviewId',
      data: payload,
    );

    final data = response.data['data'] as Map<String, dynamic>;
    return ReviewModel.fromJson(data);
  }

  @override
  Future<void> deleteReview(String reviewId) async {
    await _apiService.delete('/customer/reviews/$reviewId');
  }

  @override
  Future<List<ReviewModel>> getCustomerReviews({int page = 1, int limit = 50}) async {
    final response = await _apiService.get(
      '/customer/reviews',
      queryParameters: {'page': page, 'limit': limit},
    );

    final data = response.data['data'];
    if (data != null && data['items'] is List) {
      return (data['items'] as List)
          .map((item) => ReviewModel.fromJson(item as Map<String, dynamic>))
          .toList();
    }
    return [];
  }

  @override
  Future<List<Map<String, dynamic>>> getEligibleProducts() async {
    final response = await _apiService.get('/customer/reviews/eligible');
    final data = response.data['data'];
    if (data is List) {
      return data.cast<Map<String, dynamic>>();
    }
    return [];
  }

  @override
  Future<ProductReviewsResponse> getProductReviews(
    String productId, {
    int page = 1,
    int limit = 10,
    int? rating,
    String sortBy = 'newest',
  }) async {
    final queryParams = <String, dynamic>{
      'page': page,
      'limit': limit,
      'sortBy': sortBy,
    };
    if (rating != null) {
      queryParams['rating'] = rating;
    }

    final response = await _apiService.get(
      '/products/$productId/reviews',
      queryParameters: queryParams,
    );

    final data = response.data['data'] as Map<String, dynamic>;
    return ProductReviewsResponse.fromJson(data);
  }

  @override
  Future<RatingSummaryModel> getRatingSummary(String productId) async {
    final response = await _apiService.get('/products/$productId/rating-summary');
    final data = response.data['data'] as Map<String, dynamic>;
    return RatingSummaryModel.fromJson(data);
  }
}
