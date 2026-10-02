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
  final String? brandName;

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
    this.rejectedReason,
    this.createdByVendorId,
    required this.createdAt,
    required this.updatedAt,
    this.images = const [],
    this.variants = const [],
  });

  String? get primaryImageUrl {
    if (image != null && image!.trim().isNotEmpty) return image;
    final common = images.where((img) => img.productVariantId == null || img.productVariantId!.isEmpty).toList();
    if (common.isNotEmpty) {
      final primary = common.firstWhere(
        (img) => img.isPrimary,
        orElse: () => common.first,
      );
      return primary.imageUrl;
    }
    if (images.isNotEmpty) {
      return images.first.imageUrl;
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

    final commonImages = parsedImages
        .where((img) => img.productVariantId == null || img.productVariantId!.isEmpty)
        .toList();

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

    String? bName;
    if (json['brand'] != null && json['brand'] is Map && json['brand']['name'] != null) {
      bName = json['brand']['name'] as String;
    } else if (json['brandName'] != null) {
      bName = json['brandName'] as String;
    }

    // Specifications (weight & dimensions) with fallback to shipping record
    double? w = json['weight'] != null ? (json['weight'] as num).toDouble() : null;
    double? l = json['length'] != null ? (json['length'] as num).toDouble() : null;
    double? wi = json['width'] != null ? (json['width'] as num).toDouble() : null;
    double? h = json['height'] != null ? (json['height'] as num).toDouble() : null;
    if (json['shipping'] != null && json['shipping'] is Map) {
      final s = json['shipping'] as Map;
      if (w == null && s['weight'] != null) w = (s['weight'] as num).toDouble();
      if (l == null && s['length'] != null) l = (s['length'] as num).toDouble();
      if (wi == null && s['width'] != null) wi = (s['width'] as num).toDouble();
      if (h == null && s['height'] != null) h = (s['height'] as num).toDouble();
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
      brandName: bName,
      sellingPrice: (json['sellingPrice'] as num).toDouble(),
      mrp: (json['mrp'] as num).toDouble(),
      taxPercentage: json['taxPercentage'] != null ? (json['taxPercentage'] as num).toDouble() : null,
      stock: json['stock'] as int?,
      weight: w,
      length: l,
      width: wi,
      height: h,
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
      images: commonImages.isNotEmpty ? commonImages : parsedImages,
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
      if (brandName != null) 'brandName': brandName,
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

  ProductModel copyWith({
    String? id,
    String? sku,
    String? name,
    String? description,
    String? shortDescription,
    String? categoryId,
    String? subCategoryId,
    String? brandId,
    String? categoryName,
    String? subCategoryName,
    String? brandName,
    double? sellingPrice,
    double? mrp,
    double? taxPercentage,
    int? stock,
    double? weight,
    double? length,
    double? width,
    double? height,
    String? status,
    String? image,
    String? rejectedReason,
    String? createdByVendorId,
    DateTime? createdAt,
    DateTime? updatedAt,
    List<ProductImageModel>? images,
    List<ProductVariantModel>? variants,
  }) {
    return ProductModel(
      id: id ?? this.id,
      sku: sku ?? this.sku,
      name: name ?? this.name,
      description: description ?? this.description,
      shortDescription: shortDescription ?? this.shortDescription,
      categoryId: categoryId ?? this.categoryId,
      subCategoryId: subCategoryId ?? this.subCategoryId,
      brandId: brandId ?? this.brandId,
      categoryName: categoryName ?? this.categoryName,
      subCategoryName: subCategoryName ?? this.subCategoryName,
      brandName: brandName ?? this.brandName,
      sellingPrice: sellingPrice ?? this.sellingPrice,
      mrp: mrp ?? this.mrp,
      taxPercentage: taxPercentage ?? this.taxPercentage,
      stock: stock ?? this.stock,
      weight: weight ?? this.weight,
      length: length ?? this.length,
      width: width ?? this.width,
      height: height ?? this.height,
      status: status ?? this.status,
      image: image ?? this.image,
      rejectedReason: rejectedReason ?? this.rejectedReason,
      createdByVendorId: createdByVendorId ?? this.createdByVendorId,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      images: images ?? this.images,
      variants: variants ?? this.variants,
    );
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
        rejectedReason,
        createdByVendorId,
        createdAt,
        updatedAt,
        images,
        variants,
      ];
}
