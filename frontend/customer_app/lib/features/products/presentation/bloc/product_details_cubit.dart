import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../data/models/product_model.dart';
import '../../../../core/dependency_injection/injection.dart';
import '../../../../core/network/api_service.dart';

class ProductDetailsState extends Equatable {
  final ProductModel product;
  final String? selectedVariantId;
  final bool isLoading;
  final String? errorMessage;

  const ProductDetailsState({
    required this.product,
    this.selectedVariantId,
    this.isLoading = false,
    this.errorMessage,
  });

  ProductDetailsState copyWith({
    ProductModel? product,
    String? selectedVariantId,
    bool? isLoading,
    String? errorMessage,
  }) {
    return ProductDetailsState(
      product: product ?? this.product,
      selectedVariantId: selectedVariantId ?? this.selectedVariantId,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [product, selectedVariantId, isLoading, errorMessage];
}

class ProductDetailsCubit extends Cubit<ProductDetailsState> {
  ProductDetailsCubit({required ProductModel product})
      : super(ProductDetailsState(
          product: product,
          selectedVariantId: null, // Always start with no variant selected (Amazon Style Common Images)
        ));

  void selectVariant(String variantId) {
    emit(state.copyWith(selectedVariantId: variantId));
  }

  Future<void> fetchProductDetails() async {
    emit(state.copyWith(isLoading: true));
    try {
      final response = await sl<ApiService>().get('/customer/products/${state.product.id}');
      if (response.data != null && response.data['data'] != null) {
        final fetched = ProductModel.fromJson(response.data['data'] as Map<String, dynamic>);
        
        String? nextVariantId = state.selectedVariantId;
        if (nextVariantId != null && !fetched.variants.any((v) => v.id == nextVariantId)) {
          nextVariantId = null;
        }
        
        emit(state.copyWith(
          product: fetched,
          selectedVariantId: nextVariantId,
          isLoading: false,
        ));
      } else {
        emit(state.copyWith(isLoading: false));
      }
    } catch (e) {
      emit(state.copyWith(
        isLoading: false,
        errorMessage: e.toString(),
      ));
    }
  }
}
