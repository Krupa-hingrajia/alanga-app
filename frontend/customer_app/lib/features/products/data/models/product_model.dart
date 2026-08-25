import 'package:equatable/equatable.dart';
import 'product_image_model.dart';
import 'product_variant_model.dart';
import 'product_shipping_model.dart';

class ProductModel extends Equatable {
  final String id;
  final String sku;
  final String name;
  final String? description;
  final String? shortDescription;
  final String categoryId;
  final String? categoryName;
  final String subCategoryId;
  final String? subCategoryName;
  final String brandId;
  final String? brandName;
  final double sellingPrice;
  final double mrp;
  final double? taxPercentage;
  final int? stock;
  final double? weight;
  final double? length;
  final double? width;
  final double? height;
  final String status;
  final String? image;
  final List<ProductImageModel> images;
  final List<ProductVariantModel> variants;
  final ProductShippingModel? shipping;
  final bool? isWishlisted;
  final DateTime createdAt;
  final DateTime updatedAt;

  const ProductModel({
    required this.id,
    required this.sku,
    required this.name,
    this.description,
    this.shortDescription,
    required this.categoryId,
    this.categoryName,
    required this.subCategoryId,
    this.subCategoryName,
    required this.brandId,
    this.brandName,
    required this.sellingPrice,
    required this.mrp,
    this.taxPercentage,
    this.stock,
    this.weight,
    this.length,
    this.width,
    this.height,
    required this.status,
    this.image,
    this.images = const [],
    this.variants = const [],
    this.shipping,
    this.isWishlisted = false,
    required this.createdAt,
    required this.updatedAt,
  });

  String get primaryImageUrl {
    if (images.isNotEmpty) {
      final primary = images.firstWhere((img) => img.isPrimary, orElse: () => images.first);
      if (primary.imageUrl.isNotEmpty) {
        return primary.imageUrl;
      }
    }
    if (image != null && image!.isNotEmpty) {
      return image!;
    }
    return '';
  }

  int get discountPercentage {
    if (mrp <= 0 || sellingPrice >= mrp) return 0;
    return (((mrp - sellingPrice) / mrp) * 100).round();
  }

  factory ProductModel.fromJson(Map<String, dynamic> json) {
    var rawImages = (json['images'] as List<dynamic>?) ?? (json['productImages'] as List<dynamic>?) ?? [];
    List<ProductImageModel> parsedImages = rawImages
        .map((img) => ProductImageModel.fromJson(img as Map<String, dynamic>))
        .toList();

    var rawVariants = (json['variants'] as List<dynamic>?) ?? (json['productVariants'] as List<dynamic>?) ?? [];
    List<ProductVariantModel> parsedVariants = rawVariants.map((v) {
      final variantModel = ProductVariantModel.fromJson(v as Map<String, dynamic>);
      final variantSpecificImages = parsedImages
          .where((img) => img.productVariantId == variantModel.id)
          .toList();
      final finalImages = variantSpecificImages.isNotEmpty
          ? variantSpecificImages
          : variantModel.images.where((img) => img.productVariantId == variantModel.id).toList();

      return variantModel.copyWith(images: finalImages);
    }).toList();

    ProductShippingModel? parsedShipping;
    if (json['shipping'] != null && json['shipping'] is Map<String, dynamic>) {
      parsedShipping = ProductShippingModel.fromJson(json['shipping'] as Map<String, dynamic>);
    }

    String? brandN;
    if (json['brand'] != null && json['brand'] is Map && json['brand']['name'] != null) {
      brandN = json['brand']['name'] as String;
    } else if (json['brandName'] != null) {
      brandN = json['brandName'] as String;
    }

    String? catN;
    if (json['category'] != null && json['category'] is Map && json['category']['name'] != null) {
      catN = json['category']['name'] as String;
    } else if (json['categoryName'] != null) {
      catN = json['categoryName'] as String;
    }

    String? subCatN;
    if (json['subCategory'] != null && json['subCategory'] is Map && json['subCategory']['name'] != null) {
      subCatN = json['subCategory']['name'] as String;
    } else if (json['subCategoryName'] != null) {
      subCatN = json['subCategoryName'] as String;
    }

    return ProductModel(
      id: json['id'] as String,
      sku: json['sku'] as String? ?? '',
      name: json['name'] as String,
      description: json['description'] as String?,
      shortDescription: json['shortDescription'] as String?,
      categoryId: json['categoryId'] as String? ?? '',
      categoryName: catN,
      subCategoryId: json['subCategoryId'] as String? ?? '',
      subCategoryName: subCatN,
      brandId: json['brandId'] as String? ?? '',
      brandName: brandN,
      sellingPrice: (json['sellingPrice'] as num).toDouble(),
      mrp: (json['mrp'] as num).toDouble(),
      taxPercentage: json['taxPercentage'] != null ? (json['taxPercentage'] as num).toDouble() : null,
      stock: json['stock'] as int?,
      weight: json['weight'] != null ? (json['weight'] as num).toDouble() : null,
      length: json['length'] != null ? (json['length'] as num).toDouble() : null,
      width: json['width'] != null ? (json['width'] as num).toDouble() : null,
      height: json['height'] != null ? (json['height'] as num).toDouble() : null,
      status: json['status'] as String? ?? 'ACTIVE',
      image: json['image'] as String?,
      images: parsedImages,
      variants: parsedVariants,
      shipping: parsedShipping,
      isWishlisted: json['isWishlisted'] as bool? ?? false,
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'] as String)
          : DateTime.now(),
      updatedAt: json['updatedAt'] != null
          ? DateTime.parse(json['updatedAt'] as String)
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'sku': sku,
      'name': name,
      'description': description,
      'shortDescription': shortDescription,
      'categoryId': categoryId,
      'categoryName': categoryName,
      'subCategoryId': subCategoryId,
      'subCategoryName': subCategoryName,
      'brandId': brandId,
      'brandName': brandName,
      'sellingPrice': sellingPrice,
      'mrp': mrp,
      if (taxPercentage != null) 'taxPercentage': taxPercentage,
      if (stock != null) 'stock': stock,
      if (weight != null) 'weight': weight,
      if (length != null) 'length': length,
      if (width != null) 'width': width,
      if (height != null) 'height': height,
      'status': status,
      'image': image,
      'images': images.map((img) => img.toJson()).toList(),
      'variants': variants.map((v) => v.toJson()).toList(),
      if (shipping != null) 'shipping': shipping!.toJson(),
      'isWishlisted': isWishlisted,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  @override
  List<Object?> get props => [
        id,
        sku,
        name,
        description,
        shortDescription,
        categoryId,
        categoryName,
        subCategoryId,
        subCategoryName,
        brandId,
        brandName,
        sellingPrice,
        mrp,
        taxPercentage,
        stock,
        weight,
        length,
        width,
        height,
        status,
        image,
        images,
        variants,
        shipping,
        isWishlisted,
        createdAt,
        updatedAt,
      ];
}
