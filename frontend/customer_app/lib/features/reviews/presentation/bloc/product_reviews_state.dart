import 'package:equatable/equatable.dart';
import '../../data/models/review_model.dart';

enum ProductReviewsStatus { initial, loading, loaded, error }

class ProductReviewsState extends Equatable {
  final ProductReviewsStatus status;
  final ProductReviewsResponse? response;
  final int? selectedRating;
  final String sortBy;
  final String? errorMessage;

  const ProductReviewsState({
    this.status = ProductReviewsStatus.initial,
    this.response,
    this.selectedRating,
    this.sortBy = 'newest',
    this.errorMessage,
  });

  ProductReviewsState copyWith({
    ProductReviewsStatus? status,
    ProductReviewsResponse? response,
    int? Function()? selectedRating,
    String? sortBy,
    String? errorMessage,
  }) {
    return ProductReviewsState(
      status: status ?? this.status,
      response: response ?? this.response,
      selectedRating: selectedRating != null ? selectedRating() : this.selectedRating,
      sortBy: sortBy ?? this.sortBy,
      errorMessage: errorMessage,
    );
  }

  @override
  List<Object?> get props => [
        status,
        response,
        selectedRating,
        sortBy,
        errorMessage,
      ];
}
