import 'product_image_model.dart';

class ProductVariantModel {
  final String id;
  final String productId;
  final String sku;
  final String variantName;
  final String? color;
  final String? size;
  final String? storage;
  final double price;
  final int stock;
  final String status;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final Map<String, String> attributes;
  final List<ProductImageModel> images;
  final List<String> pendingLocalPaths;
  final bool isDefault;

  ProductVariantModel({
    required this.id,
    required this.productId,
    required this.sku,
    required this.variantName,
    this.color,
    this.size,
    this.storage,
    required this.price,
    required this.stock,
    this.status = 'ACTIVE',
    this.createdAt,
    this.updatedAt,
    this.attributes = const {},
    this.images = const [],
    this.pendingLocalPaths = const [],
    this.isDefault = false,
  });

  factory ProductVariantModel.fromJson(Map<String, dynamic> json) {
    Map<String, String> dynamicAttrs = {};

    if (json['color'] != null && (json['color'] as String).isNotEmpty) {
      dynamicAttrs['Color'] = json['color'];
    }
    if (json['size'] != null && (json['size'] as String).isNotEmpty) {
      dynamicAttrs['Size'] = json['size'];
    }
    if (json['storage'] != null && (json['storage'] as String).isNotEmpty) {
      dynamicAttrs['Storage'] = json['storage'];
    }

    if (json['attributes'] != null && json['attributes'] is Map) {
      (json['attributes'] as Map).forEach((key, value) {
        if (value != null && value.toString().isNotEmpty) {
          dynamicAttrs[key.toString()] = value.toString();
        }
      });
    }

    List<ProductImageModel> parsedImages = [];
    if (json['images'] != null && json['images'] is List) {
      parsedImages = (json['images'] as List<dynamic>)
          .map((img) => ProductImageModel.fromJson(img as Map<String, dynamic>))
          .toList();
    }

    return ProductVariantModel(
      id: json['id'] as String? ?? '',
      productId: json['productId'] as String? ?? '',
      sku: json['sku'] as String? ?? '',
      variantName: json['variantName'] as String? ?? '',
      color: json['color'] as String?,
      size: json['size'] as String?,
      storage: json['storage'] as String?,
      price: (json['price'] as num?)?.toDouble() ?? 0.0,
      stock: (json['stock'] as num?)?.toInt() ?? 0,
      status: json['status'] as String? ?? 'ACTIVE',
      createdAt: json['createdAt'] != null ? DateTime.tryParse(json['createdAt']) : null,
      updatedAt: json['updatedAt'] != null ? DateTime.tryParse(json['updatedAt']) : null,
      attributes: dynamicAttrs,
      images: parsedImages,
      isDefault: json['isDefault'] as bool? ?? false,
    );
  }

  /// Produces a payload conforming strictly to backend CreateProductVariantDto
  Map<String, dynamic> toCreateJson() {
    String? colorVal = (color != null && color!.trim().isNotEmpty) ? color!.trim() : attributes['Color']?.trim();
    String? sizeVal = (size != null && size!.trim().isNotEmpty) ? size!.trim() : attributes['Size']?.trim();
    String? storageVal = (storage != null && storage!.trim().isNotEmpty) ? storage!.trim() : attributes['Storage']?.trim();

    return {
      'sku': sku.trim().isNotEmpty ? sku.trim() : 'VAR-${DateTime.now().millisecondsSinceEpoch.toRadixString(36).toUpperCase()}',
      'variantName': variantName.trim().isNotEmpty ? variantName.trim() : 'Variant',
      'price': price,
      'stock': stock,
      if (colorVal != null && colorVal.isNotEmpty) 'color': colorVal,
      if (sizeVal != null && sizeVal.isNotEmpty) 'size': sizeVal,
      if (storageVal != null && storageVal.isNotEmpty) 'storage': storageVal,
      'status': status.isNotEmpty ? status : 'ACTIVE',
      'isDefault': isDefault,
    };
  }

  Map<String, dynamic> toJson() {
    String? colorVal = (color != null && color!.trim().isNotEmpty) ? color!.trim() : attributes['Color']?.trim();
    String? sizeVal = (size != null && size!.trim().isNotEmpty) ? size!.trim() : attributes['Size']?.trim();
    String? storageVal = (storage != null && storage!.trim().isNotEmpty) ? storage!.trim() : attributes['Storage']?.trim();

    return {
      if (id.isNotEmpty) 'id': id,
      if (productId.isNotEmpty) 'productId': productId,
      'sku': sku.trim().isNotEmpty ? sku.trim() : 'VAR-${DateTime.now().millisecondsSinceEpoch.toRadixString(36).toUpperCase()}',
      'variantName': variantName.trim().isNotEmpty ? variantName.trim() : 'Variant',
      if (colorVal != null && colorVal.isNotEmpty) 'color': colorVal,
      if (sizeVal != null && sizeVal.isNotEmpty) 'size': sizeVal,
      if (storageVal != null && storageVal.isNotEmpty) 'storage': storageVal,
      'price': price,
      'stock': stock,
      'status': status.isNotEmpty ? status : 'ACTIVE',
      if (images.isNotEmpty) 'images': images.map((img) => img.toJson()).toList(),
      'isDefault': isDefault,
    };
  }

  ProductVariantModel copyWith({
    String? id,
    String? productId,
    String? sku,
    String? variantName,
    String? color,
    String? size,
    String? storage,
    double? price,
    int? stock,
    String? status,
    Map<String, String>? attributes,
    List<ProductImageModel>? images,
    List<String>? pendingLocalPaths,
    bool? isDefault,
  }) {
    return ProductVariantModel(
      id: id ?? this.id,
      productId: productId ?? this.productId,
      sku: sku ?? this.sku,
      variantName: variantName ?? this.variantName,
      color: color ?? this.color,
      size: size ?? this.size,
      storage: storage ?? this.storage,
      price: price ?? this.price,
      stock: stock ?? this.stock,
      status: status ?? this.status,
      attributes: attributes ?? this.attributes,
      images: images ?? this.images,
      pendingLocalPaths: pendingLocalPaths ?? this.pendingLocalPaths,
      isDefault: isDefault ?? this.isDefault,
    );
  }
}
