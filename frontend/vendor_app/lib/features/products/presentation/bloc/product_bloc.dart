import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/repositories/product_repository.dart';
import 'product_event.dart';
import 'product_state.dart';
import '../../../../core/error/failures.dart';

class ProductBloc extends Bloc<ProductEvent, ProductState> {
  final ProductRepository _productRepository;

  ProductBloc({required ProductRepository productRepository})
      : _productRepository = productRepository,
        super(ProductInitial()) {
    on<FetchProductsEvent>(_onFetchProducts);
    on<CreateProductSubmittedEvent>(_onCreateProduct);
    on<UpdateProductSubmittedEvent>(_onUpdateProduct);
    on<DeleteProductSubmittedEvent>(_onDeleteProduct);
    on<FetchProductImagesEvent>(_onFetchProductImages);
    on<UploadProductImagesEvent>(_onUploadProductImages);
    on<SetPrimaryProductImageEvent>(_onSetPrimaryImage);
    on<DeleteProductImageEvent>(_onDeleteProductImage);
    on<ReorderProductImagesEvent>(_onReorderProductImages);
    on<FetchAttributesEvent>(_onFetchAttributes);
    on<FetchProductVariantsEvent>(_onFetchProductVariants);
    on<CreateProductVariantEvent>(_onCreateVariant);
    on<UpdateProductVariantEvent>(_onUpdateVariant);
    on<DeleteProductVariantEvent>(_onDeleteVariant);
  }

  Future<void> _onFetchProducts(
    FetchProductsEvent event,
    Emitter<ProductState> emit,
  ) async {
    emit(ProductListLoading());
    try {
      final products = await _productRepository.getProducts();
      emit(ProductListLoaded(products: products));
    } catch (e) {
      String message = 'Failed to load products';
      if (e is ServerFailure) {
        message = e.message;
      }
      emit(ProductListError(message: message));
    }
  }

  Future<void> _onCreateProduct(
    CreateProductSubmittedEvent event,
    Emitter<ProductState> emit,
  ) async {
    emit(const ProductActionLoading(message: 'Creating product...'));
    try {
      final product = await _productRepository.createProduct(event.data);

      if (event.pendingImagePaths.isNotEmpty) {
        emit(const ProductActionLoading(message: 'Uploading common images...'));
        try {
          await _productRepository.uploadProductImages(product.id, event.pendingImagePaths);
        } catch (e) {
          debugPrint('Upload product images error: $e');
        }
      }

      if (event.variants.isNotEmpty) {
        for (int i = 0; i < event.variants.length; i++) {
          final v = event.variants[i];
          final vName = v.variantName.isNotEmpty ? v.variantName : 'Variant ${i + 1}';
          emit(ProductActionLoading(message: 'Creating $vName...'));
          try {
            final createdVariant = await _productRepository.createProductVariant(product.id, v.toJson());
            if (v.pendingLocalPaths.isNotEmpty) {
              emit(ProductActionLoading(message: 'Uploading images for $vName...'));
              try {
                await _productRepository.uploadProductImages(
                  product.id,
                  v.pendingLocalPaths,
                  productVariantId: createdVariant.id,
                );
              } catch (e) {
                debugPrint('Upload variant images error for $vName: $e');
              }
            }
          } catch (e) {
            debugPrint('Create variant error for $vName: $e');
          }
        }
      }

      final refreshed = await _productRepository.getProductById(product.id);
      emit(ProductActionSuccess(
        product: refreshed,
        message: 'Product created successfully as ${refreshed.status}.',
      ));
    } catch (e) {
      String message = 'An error occurred';
      if (e is ServerFailure) {
        message = e.message;
      }
      emit(ProductActionError(message: message));
    }
  }

  Future<void> _onUpdateProduct(
    UpdateProductSubmittedEvent event,
    Emitter<ProductState> emit,
  ) async {
    emit(const ProductActionLoading(message: 'Updating product...'));
    try {
      final product = await _productRepository.updateProduct(event.id, event.data);
      if (event.pendingImagePaths.isNotEmpty) {
        emit(const ProductActionLoading(message: 'Uploading new images...'));
        try {
          await _productRepository.uploadProductImages(product.id, event.pendingImagePaths);
        } catch (e) {
          debugPrint('Upload product images error on update: $e');
        }
      }

      final refreshed = await _productRepository.getProductById(product.id);
      emit(ProductActionSuccess(
        product: refreshed,
        message: 'Product updated successfully.',
      ));
    } catch (e) {
      String message = 'An error occurred';
      if (e is ServerFailure) {
        message = e.message;
      }
      emit(ProductActionError(message: message));
    }
  }

  Future<void> _onDeleteProduct(
    DeleteProductSubmittedEvent event,
    Emitter<ProductState> emit,
  ) async {
    emit(const ProductActionLoading(message: 'Deleting product...'));
    try {
      final product = await _productRepository.deleteProduct(event.id);
      emit(ProductActionSuccess(
        product: product,
        message: 'Product deleted successfully.',
      ));
    } catch (e) {
      String message = 'Failed to delete product';
      if (e is ServerFailure) {
        message = e.message;
      }
      emit(ProductActionError(message: message));
    }
  }

  Future<void> _onFetchProductImages(
    FetchProductImagesEvent event,
    Emitter<ProductState> emit,
  ) async {
    emit(ProductImagesLoading());
    try {
      final images = await _productRepository.getProductImages(
        event.productId,
        productVariantId: event.productVariantId,
      );
      emit(ProductImagesLoaded(images: images, productVariantId: event.productVariantId));
    } catch (e) {
      String message = 'Failed to load product images';
      if (e is ServerFailure) {
        message = e.message;
      }
      emit(ProductImageActionError(message: message));
    }
  }

  Future<void> _onUploadProductImages(
    UploadProductImagesEvent event,
    Emitter<ProductState> emit,
  ) async {
    emit(const ProductActionLoading(message: 'Uploading images...'));
    try {
      final images = await _productRepository.uploadProductImages(
        event.productId,
        event.filePaths,
        productVariantId: event.productVariantId,
        onProgress: (sent, total) {
          final progress = total > 0 ? sent / total : 0.0;
          emit(ProductImagesUploading(progress: progress));
        },
      );

      final variants = await _productRepository.getProductVariants(event.productId);
      emit(ProductVariantsLoadedState(variants: variants));
      emit(ProductImageActionSuccess(
        images: images,
        message: '${images.length} image(s) uploaded successfully.',
        productVariantId: event.productVariantId,
      ));
    } catch (e) {
      String message = 'Failed to upload images';
      if (e is ServerFailure) {
        message = e.message;
      }
      emit(ProductActionError(message: message));
    }
  }

  Future<void> _onSetPrimaryImage(
    SetPrimaryProductImageEvent event,
    Emitter<ProductState> emit,
  ) async {
    try {
      await _productRepository.setPrimaryProductImage(
        event.productId,
        event.imageId,
        productVariantId: event.productVariantId,
      );
      final product = await _productRepository.getProductById(event.productId);
      emit(ProductVariantsLoadedState(variants: product.variants));
      emit(ProductActionSuccess(
        product: product,
        message: 'Primary image updated.',
      ));
    } catch (e) {
      String message = 'Failed to set primary image';
      if (e is ServerFailure) {
        message = e.message;
      }
      emit(ProductActionError(message: message));
    }
  }

  Future<void> _onDeleteProductImage(
    DeleteProductImageEvent event,
    Emitter<ProductState> emit,
  ) async {
    try {
      await _productRepository.deleteProductImage(event.productId, event.imageId);
      final product = await _productRepository.getProductById(event.productId);
      emit(ProductVariantsLoadedState(variants: product.variants));
      emit(ProductActionSuccess(
        product: product,
        message: 'Image deleted.',
      ));
    } catch (e) {
      String message = 'Failed to delete image';
      if (e is ServerFailure) {
        message = e.message;
      }
      emit(ProductActionError(message: message));
    }
  }

  Future<void> _onReorderProductImages(
    ReorderProductImagesEvent event,
    Emitter<ProductState> emit,
  ) async {
    try {
      await _productRepository.reorderProductImages(event.productId, event.orders);
      final product = await _productRepository.getProductById(event.productId);
      emit(ProductActionSuccess(
        product: product,
        message: 'Image display order updated.',
      ));
    } catch (e) {
      String message = 'Failed to reorder images';
      if (e is ServerFailure) {
        message = e.message;
      }
      emit(ProductActionError(message: message));
    }
  }

  Future<void> _onFetchAttributes(
    FetchAttributesEvent event,
    Emitter<ProductState> emit,
  ) async {
    try {
      final attributes = await _productRepository.fetchAttributes();
      emit(AttributesLoadedState(attributes: attributes));
    } catch (e) {
      String message = 'Failed to load attributes';
      if (e is ServerFailure) {
        message = e.message;
      }
      emit(ProductActionError(message: message));
    }
  }

  Future<void> _onFetchProductVariants(
    FetchProductVariantsEvent event,
    Emitter<ProductState> emit,
  ) async {
    emit(ProductVariantsLoadingState());
    try {
      final variants = await _productRepository.getProductVariants(event.productId);
      emit(ProductVariantsLoadedState(variants: variants));
    } catch (e) {
      String message = 'Failed to load product variants';
      if (e is ServerFailure) {
        message = e.message;
      }
      emit(ProductVariantActionError(message: message));
    }
  }

  Future<void> _onCreateVariant(
    CreateProductVariantEvent event,
    Emitter<ProductState> emit,
  ) async {
    emit(const ProductActionLoading(message: 'Adding variant...'));
    try {
      final createdVariant = await _productRepository.createProductVariant(event.productId, event.data);
      if (event.pendingImagePaths.isNotEmpty) {
        emit(const ProductActionLoading(message: 'Uploading variant images...'));
        try {
          await _productRepository.uploadProductImages(
            event.productId,
            event.pendingImagePaths,
            productVariantId: createdVariant.id,
          );
        } catch (_) {}
      }
      final variants = await _productRepository.getProductVariants(event.productId);
      emit(ProductVariantsLoadedState(variants: variants));
      emit(ProductVariantActionSuccess(
        variants: variants,
        message: 'Variant added successfully.',
      ));
    } catch (e) {
      String message = 'Failed to add variant';
      if (e is ServerFailure) {
        message = e.message;
      }
      emit(ProductActionError(message: message));
    }
  }

  Future<void> _onUpdateVariant(
    UpdateProductVariantEvent event,
    Emitter<ProductState> emit,
  ) async {
    emit(const ProductActionLoading(message: 'Updating variant...'));
    try {
      await _productRepository.updateProductVariant(event.productId, event.variantId, event.data);
      final variants = await _productRepository.getProductVariants(event.productId);
      emit(ProductVariantsLoadedState(variants: variants));
      emit(ProductVariantActionSuccess(
        variants: variants,
        message: 'Variant updated successfully.',
      ));
    } catch (e) {
      String message = 'Failed to update variant';
      if (e is ServerFailure) {
        message = e.message;
      }
      emit(ProductActionError(message: message));
    }
  }

  Future<void> _onDeleteVariant(
    DeleteProductVariantEvent event,
    Emitter<ProductState> emit,
  ) async {
    emit(const ProductActionLoading(message: 'Deleting variant...'));
    try {
      await _productRepository.deleteProductVariant(event.productId, event.variantId);
      final variants = await _productRepository.getProductVariants(event.productId);
      emit(ProductVariantsLoadedState(variants: variants));
      emit(ProductVariantActionSuccess(
        variants: variants,
        message: 'Variant deleted successfully.',
      ));
    } catch (e) {
      String message = 'Failed to delete variant';
      if (e is ServerFailure) {
        message = e.message;
      }
      emit(ProductActionError(message: message));
    }
  }
}
