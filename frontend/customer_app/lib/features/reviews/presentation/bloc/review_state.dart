import 'package:equatable/equatable.dart';
import '../../data/models/review_model.dart';

enum ReviewStatus { initial, loading, loaded, submitting, success, error }

class ReviewState extends Equatable {
  final ReviewStatus status;

  // Product Reviews
  final List<ReviewModel> productReviews;
  final RatingSummaryModel? ratingSummary;
  final int currentPage;
  final int totalReviews;
  final int totalPages;
  final bool hasMore;
  final bool isLoadingMore;
  final int? selectedRating;
  final String sortBy;

  // Customer Reviews
  final List<ReviewModel> customerReviews;
  final Map<String, ReviewModel> customerReviewsByProductId;

  final String? successMessage;
  final String? errorMessage;

  const ReviewState({
    this.status = ReviewStatus.initial,
    this.productReviews = const [],
    this.ratingSummary,
    this.currentPage = 1,
    this.totalReviews = 0,
    this.totalPages = 1,
    this.hasMore = false,
    this.isLoadingMore = false,
    this.selectedRating,
    this.sortBy = 'newest',
    this.customerReviews = const [],
    this.customerReviewsByProductId = const {},
    this.successMessage,
    this.errorMessage,
  });

  ReviewState copyWith({
    ReviewStatus? status,
    List<ReviewModel>? productReviews,
    RatingSummaryModel? Function()? ratingSummary,
    int? currentPage,
    int? totalReviews,
    int? totalPages,
    bool? hasMore,
    bool? isLoadingMore,
    int? Function()? selectedRating,
    String? sortBy,
    List<ReviewModel>? customerReviews,
    Map<String, ReviewModel>? customerReviewsByProductId,
    String? successMessage,
    String? errorMessage,
  }) {
    return ReviewState(
      status: status ?? this.status,
      productReviews: productReviews ?? this.productReviews,
      ratingSummary: ratingSummary != null ? ratingSummary() : this.ratingSummary,
      currentPage: currentPage ?? this.currentPage,
      totalReviews: totalReviews ?? this.totalReviews,
      totalPages: totalPages ?? this.totalPages,
      hasMore: hasMore ?? this.hasMore,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      selectedRating: selectedRating != null ? selectedRating() : this.selectedRating,
      sortBy: sortBy ?? this.sortBy,
      customerReviews: customerReviews ?? this.customerReviews,
      customerReviewsByProductId: customerReviewsByProductId ?? this.customerReviewsByProductId,
      successMessage: successMessage,
      errorMessage: errorMessage,
    );
  }

  ReviewModel? getReviewForProduct(String productId) {
    return customerReviewsByProductId[productId];
  }

  bool hasReviewedProduct(String productId) {
    return customerReviewsByProductId.containsKey(productId);
  }

  @override
  List<Object?> get props => [
        status,
        productReviews,
        ratingSummary,
        currentPage,
        totalReviews,
        totalPages,
        hasMore,
        isLoadingMore,
        selectedRating,
        sortBy,
        customerReviews,
        customerReviewsByProductId,
        successMessage,
        errorMessage,
      ];
}
