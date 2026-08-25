import 'package:equatable/equatable.dart';

import '../../data/models/product_variant_model.dart';

abstract class ProductEvent extends Equatable {
  const ProductEvent();

  @override
  List<Object?> get props => [];
}

class FetchProductsEvent extends ProductEvent {
  final bool isRefresh;
  const FetchProductsEvent({this.isRefresh = false});

  @override
  List<Object?> get props => [isRefresh];
}

class CreateProductSubmittedEvent extends ProductEvent {
  final Map<String, dynamic> data;
  final List<String> pendingImagePaths;
  final List<ProductVariantModel> variants;
  const CreateProductSubmittedEvent({
    required this.data,
    this.pendingImagePaths = const [],
    this.variants = const [],
  });

  @override
  List<Object?> get props => [data, pendingImagePaths, variants];
}

class UpdateProductSubmittedEvent extends ProductEvent {
  final String id;
  final Map<String, dynamic> data;
  final List<String> pendingImagePaths;
  const UpdateProductSubmittedEvent({required this.id, required this.data, this.pendingImagePaths = const []});

  @override
  List<Object?> get props => [id, data, pendingImagePaths];
}

class DeleteProductSubmittedEvent extends ProductEvent {
  final String id;
  const DeleteProductSubmittedEvent({required this.id});

  @override
  List<Object?> get props => [id];
}

class SubmitProductForApprovalEvent extends ProductEvent {
  final String id;
  const SubmitProductForApprovalEvent({required this.id});

  @override
  List<Object?> get props => [id];
}

// Product Image Management Events
class FetchProductImagesEvent extends ProductEvent {
  final String productId;
  final String? productVariantId;
  const FetchProductImagesEvent({required this.productId, this.productVariantId});

  @override
  List<Object?> get props => [productId, productVariantId];
}

class UploadProductImagesEvent extends ProductEvent {
  final String productId;
  final List<String> filePaths;
  final String? productVariantId;
  const UploadProductImagesEvent({
    required this.productId,
    required this.filePaths,
    this.productVariantId,
  });

  @override
  List<Object?> get props => [productId, filePaths, productVariantId];
}

class SetPrimaryProductImageEvent extends ProductEvent {
  final String productId;
  final String imageId;
  final String? productVariantId;
  const SetPrimaryProductImageEvent({
    required this.productId,
    required this.imageId,
    this.productVariantId,
  });

  @override
  List<Object?> get props => [productId, imageId, productVariantId];
}

class DeleteProductImageEvent extends ProductEvent {
  final String productId;
  final String imageId;
  final String? productVariantId;
  const DeleteProductImageEvent({
    required this.productId,
    required this.imageId,
    this.productVariantId,
  });

  @override
  List<Object?> get props => [productId, imageId, productVariantId];
}

class ReorderProductImagesEvent extends ProductEvent {
  final String productId;
  final List<Map<String, dynamic>> orders;
  const ReorderProductImagesEvent({required this.productId, required this.orders});

  @override
  List<Object?> get props => [productId, orders];
}

// Product Variant & Dynamic Attributes Events
class FetchAttributesEvent extends ProductEvent {
  const FetchAttributesEvent();
}

class FetchProductVariantsEvent extends ProductEvent {
  final String productId;
  const FetchProductVariantsEvent({required this.productId});

  @override
  List<Object?> get props => [productId];
}

class CreateProductVariantEvent extends ProductEvent {
  final String productId;
  final Map<String, dynamic> data;
  final List<String> pendingImagePaths;
  const CreateProductVariantEvent({
    required this.productId,
    required this.data,
    this.pendingImagePaths = const [],
  });

  @override
  List<Object?> get props => [productId, data, pendingImagePaths];
}

class UpdateProductVariantEvent extends ProductEvent {
  final String productId;
  final String variantId;
  final Map<String, dynamic> data;
  const UpdateProductVariantEvent({
    required this.productId,
    required this.variantId,
    required this.data,
  });

  @override
  List<Object?> get props => [productId, variantId, data];
}

class DeleteProductVariantEvent extends ProductEvent {
  final String productId;
  final String variantId;
  const DeleteProductVariantEvent({required this.productId, required this.variantId});

  @override
  List<Object?> get props => [productId, variantId];
}
