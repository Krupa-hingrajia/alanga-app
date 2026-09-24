import 'package:equatable/equatable.dart';
import 'product_image_model.dart';
import 'product_variant_model.dart';

class ProductModel extends Equatable {
  final String id;
  final String sku;
  final String name;
  final String? description;
  final String? shortDescription;
  final String categoryId;
  final String subCategoryId;
  final String brandId;
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
  final String? rejectedReason;
  final String? createdByVendorId;
  final DateTime createdAt;
  final DateTime updatedAt;
  final List<ProductImageModel> images;
  final List<ProductVariantModel> variants;

  final String? categoryName;
  final String? subCategoryName;

  const ProductModel({
    required this.id,
    required this.sku,
    required this.name,
    this.description,
    this.shortDescription,
    required this.categoryId,
    required this.subCategoryId,
    required this.brandId,
    this.categoryName,
    this.subCategoryName,
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
    this.rejectedReason,
    this.createdByVendorId,
    required this.createdAt,
    required this.updatedAt,
    this.images = const [],
    this.variants = const [],
  });

  String? get primaryImageUrl {
    if (image != null && image!.trim().isNotEmpty) return image;
    if (images.isNotEmpty) {
      final primary = images.firstWhere(
        (img) => img.isPrimary,
        orElse: () => images.first,
      );
      return primary.imageUrl;
    }
    return null;
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

    String? catName;
    if (json['category'] != null && json['category'] is Map && json['category']['name'] != null) {
      catName = json['category']['name'] as String;
    } else if (json['categoryName'] != null) {
      catName = json['categoryName'] as String;
    }

    String? subCatName;
    if (json['subCategory'] != null && json['subCategory'] is Map && json['subCategory']['name'] != null) {
      subCatName = json['subCategory']['name'] as String;
    } else if (json['subCategoryName'] != null) {
      subCatName = json['subCategoryName'] as String;
    }

    return ProductModel(
      id: json['id'] as String,
      sku: json['sku'] as String? ?? '',
      name: json['name'] as String,
      description: json['description'] as String?,
      shortDescription: json['shortDescription'] as String?,
      categoryId: json['categoryId'] as String,
      subCategoryId: json['subCategoryId'] as String? ?? '',
      brandId: json['brandId'] as String,
      categoryName: catName,
      subCategoryName: subCatName,
      sellingPrice: (json['sellingPrice'] as num).toDouble(),
      mrp: (json['mrp'] as num).toDouble(),
      taxPercentage: json['taxPercentage'] != null ? (json['taxPercentage'] as num).toDouble() : null,
      stock: json['stock'] as int?,
      weight: json['weight'] != null ? (json['weight'] as num).toDouble() : null,
      length: json['length'] != null ? (json['length'] as num).toDouble() : null,
      width: json['width'] != null ? (json['width'] as num).toDouble() : null,
      height: json['height'] != null ? (json['height'] as num).toDouble() : null,
      status: json['status'] as String? ?? 'DRAFT',
      image: json['image'] as String?,
      rejectedReason: json['rejectedReason'] as String?,
      createdByVendorId: json['createdByVendorId'] as String?,
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'] as String)
          : DateTime.now(),
      updatedAt: json['updatedAt'] != null
          ? DateTime.parse(json['updatedAt'] as String)
          : DateTime.now(),
      images: parsedImages,
      variants: parsedVariants,
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
      'subCategoryId': subCategoryId,
      'brandId': brandId,
      if (categoryName != null) 'categoryName': categoryName,
      if (subCategoryName != null) 'subCategoryName': subCategoryName,
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
      'rejectedReason': rejectedReason,
      'createdByVendorId': createdByVendorId,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'images': images.map((img) => img.toJson()).toList(),
      'variants': variants.map((v) => v.toJson()).toList(),
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
        subCategoryId,
        brandId,
        categoryName,
        subCategoryName,
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
        rejectedReason,
        createdByVendorId,
        createdAt,
        updatedAt,
        images,
        variants,
      ];
}
