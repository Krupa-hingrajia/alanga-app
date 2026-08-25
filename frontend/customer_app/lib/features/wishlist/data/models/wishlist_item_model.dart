import 'package:equatable/equatable.dart';
import '../../../products/data/models/product_model.dart';
import '../../../products/data/models/product_variant_model.dart';
import '../../../products/data/models/product_shipping_model.dart';

class WishlistItemModel extends Equatable {
  final String id;
  final String customerId;
  final String productId;
  final String? productVariantId;
  final ProductModel product;
  final ProductVariantModel? selectedVariant;
  final double sellingPrice;
  final double mrp;
  final int discountPercentage;
  final String stockStatus;
  final ProductShippingModel? shipping;
  final String? brandName;
  final String? categoryName;

  const WishlistItemModel({
    required this.id,
    required this.customerId,
    required this.productId,
    this.productVariantId,
    required this.product,
    this.selectedVariant,
    required this.sellingPrice,
    required this.mrp,
    required this.discountPercentage,
    required this.stockStatus,
    this.shipping,
    this.brandName,
    this.categoryName,
  });

  factory WishlistItemModel.fromJson(Map<String, dynamic> json) {
    final rawProduct = json['product'] as Map<String, dynamic>? ?? {};
    final parsedProduct = ProductModel.fromJson(rawProduct);

    ProductVariantModel? parsedVariant;
    if (json['selectedVariant'] != null && json['selectedVariant'] is Map<String, dynamic>) {
      parsedVariant = ProductVariantModel.fromJson(json['selectedVariant'] as Map<String, dynamic>);
    }

    ProductShippingModel? parsedShipping;
    if (json['shipping'] != null && json['shipping'] is Map<String, dynamic>) {
      parsedShipping = ProductShippingModel.fromJson(json['shipping'] as Map<String, dynamic>);
    }

    String? brandN = json['brand'] != null && json['brand'] is Map ? json['brand']['name'] as String? : null;
    String? catN = json['category'] != null && json['category'] is Map ? json['category']['name'] as String? : null;

    return WishlistItemModel(
      id: json['id'] as String? ?? '',
      customerId: json['customerId'] as String? ?? '',
      productId: json['productId'] as String? ?? '',
      productVariantId: json['productVariantId'] as String?,
      product: parsedProduct,
      selectedVariant: parsedVariant,
      sellingPrice: (json['sellingPrice'] as num?)?.toDouble() ?? parsedProduct.sellingPrice,
      mrp: (json['mrp'] as num?)?.toDouble() ?? parsedProduct.mrp,
      discountPercentage: (json['discountPercentage'] as num?)?.toInt() ?? parsedProduct.discountPercentage,
      stockStatus: json['stockStatus'] as String? ?? 'IN_STOCK',
      shipping: parsedShipping,
      brandName: brandN ?? parsedProduct.brandName,
      categoryName: catN ?? parsedProduct.categoryName,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'customerId': customerId,
      'productId': productId,
      'productVariantId': productVariantId,
      'product': product.toJson(),
      if (selectedVariant != null) 'selectedVariant': selectedVariant!.toJson(),
      'sellingPrice': sellingPrice,
      'mrp': mrp,
      'discountPercentage': discountPercentage,
      'stockStatus': stockStatus,
      if (shipping != null) 'shipping': shipping!.toJson(),
      if (brandName != null) 'brand': {'name': brandName},
      if (categoryName != null) 'category': {'name': categoryName},
    };
  }

  @override
  List<Object?> get props => [
        id,
        customerId,
        productId,
        productVariantId,
        product,
        selectedVariant,
        sellingPrice,
        mrp,
        discountPercentage,
        stockStatus,
        shipping,
        brandName,
        categoryName,
      ];
}
