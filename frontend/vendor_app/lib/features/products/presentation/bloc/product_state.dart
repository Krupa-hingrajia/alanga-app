import 'package:equatable/equatable.dart';
import '../../data/models/product_model.dart';
import '../../data/models/product_image_model.dart';
import '../../data/models/product_variant_model.dart';
import '../../data/models/attribute_model.dart';

abstract class ProductState extends Equatable {
  const ProductState();

  @override
  List<Object?> get props => [];
}

class ProductInitial extends ProductState {}

class ProductListLoading extends ProductState {}

class ProductListLoaded extends ProductState {
  final List<ProductModel> products;
  const ProductListLoaded({required this.products});

  @override
  List<Object?> get props => [products];
}

class ProductListError extends ProductState {
  final String message;
  const ProductListError({required this.message});

  @override
  List<Object?> get props => [message];
}

class ProductActionLoading extends ProductState {
  final String? message;
  const ProductActionLoading({this.message});

  @override
  List<Object?> get props => [message];
}

class ProductActionSuccess extends ProductState {
  final ProductModel product;
  final String message;
  const ProductActionSuccess({required this.product, required this.message});

  @override
  List<Object?> get props => [product, message];
}

class ProductActionError extends ProductState {
  final String message;
  const ProductActionError({required this.message});

  @override
  List<Object?> get props => [message];
}

// Product Image Management States
class ProductImagesLoading extends ProductState {}

class ProductImagesLoaded extends ProductState {
  final List<ProductImageModel> images;
  final String? productVariantId;
  const ProductImagesLoaded({required this.images, this.productVariantId});

  @override
  List<Object?> get props => [images, productVariantId];
}

class ProductImagesUploading extends ProductState {
  final double progress;
  const ProductImagesUploading({required this.progress});

  @override
  List<Object?> get props => [progress];
}

class ProductImageActionSuccess extends ProductState {
  final String message;
  final List<ProductImageModel> images;
  final String? productVariantId;
  const ProductImageActionSuccess({
    required this.message,
    required this.images,
    this.productVariantId,
  });

  @override
  List<Object?> get props => [message, images, productVariantId];
}

class ProductImageActionError extends ProductState {
  final String message;
  const ProductImageActionError({required this.message});

  @override
  List<Object?> get props => [message];
}

// Dynamic Attributes & Product Variant States
class AttributesLoadedState extends ProductState {
  final List<AttributeModel> attributes;
  const AttributesLoadedState({required this.attributes});

  @override
  List<Object?> get props => [attributes];
}

class ProductVariantsLoadingState extends ProductState {}

class ProductVariantsLoadedState extends ProductState {
  final List<ProductVariantModel> variants;
  const ProductVariantsLoadedState({required this.variants});

  @override
  List<Object?> get props => [variants];
}

class ProductVariantActionSuccess extends ProductState {
  final String message;
  final List<ProductVariantModel> variants;
  const ProductVariantActionSuccess({required this.message, required this.variants});

  @override
  List<Object?> get props => [message, variants];
}

class ProductVariantActionError extends ProductState {
  final String message;
  const ProductVariantActionError({required this.message});

  @override
  List<Object?> get props => [message];
}
