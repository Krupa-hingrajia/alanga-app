import 'package:equatable/equatable.dart';
import '../../data/models/review_model.dart';

enum CustomerReviewsStatus { initial, loading, loaded, submitting, success, error }

class CustomerReviewsState extends Equatable {
  final CustomerReviewsStatus status;
  final List<ReviewModel> reviews;
  final Map<String, ReviewModel> reviewsByProductId;
  final String? successMessage;
  final String? errorMessage;

  const CustomerReviewsState({
    this.status = CustomerReviewsStatus.initial,
    this.reviews = const [],
    this.reviewsByProductId = const {},
    this.successMessage,
    this.errorMessage,
  });

  CustomerReviewsState copyWith({
    CustomerReviewsStatus? status,
    List<ReviewModel>? reviews,
    Map<String, ReviewModel>? reviewsByProductId,
    String? successMessage,
    String? errorMessage,
  }) {
    return CustomerReviewsState(
      status: status ?? this.status,
      reviews: reviews ?? this.reviews,
      reviewsByProductId: reviewsByProductId ?? this.reviewsByProductId,
      successMessage: successMessage,
      errorMessage: errorMessage,
    );
  }

  ReviewModel? getReviewForProduct(String productId) {
    return reviewsByProductId[productId];
  }

  bool hasReviewedProduct(String productId) {
    return reviewsByProductId.containsKey(productId);
  }

  @override
  List<Object?> get props => [
        status,
        reviews,
        reviewsByProductId,
        successMessage,
        errorMessage,
      ];
}
