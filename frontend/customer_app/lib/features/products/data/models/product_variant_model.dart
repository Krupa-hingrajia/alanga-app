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
  final Map<String, String> attributes;
  final List<ProductImageModel> images;

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
    this.attributes = const {},
    this.images = const [],
  });

  factory ProductVariantModel.fromJson(Map<String, dynamic> json) {
    Map<String, String> dynamicAttrs = {};

    if (json['color'] != null && (json['color'] as String).trim().isNotEmpty) {
      dynamicAttrs['Color'] = (json['color'] as String).trim();
    }
    if (json['size'] != null && (json['size'] as String).trim().isNotEmpty) {
      dynamicAttrs['Size'] = (json['size'] as String).trim();
    }
    if (json['storage'] != null && (json['storage'] as String).trim().isNotEmpty) {
      dynamicAttrs['Storage'] = (json['storage'] as String).trim();
    }

    if (json['attributes'] != null && json['attributes'] is Map) {
      (json['attributes'] as Map).forEach((key, value) {
        if (value != null && value.toString().trim().isNotEmpty) {
          dynamicAttrs[key.toString().trim()] = value.toString().trim();
        }
      });
    }

    // Fallback: If no explicit attribute key-values were set, use variantName
    final vName = json['variantName'] as String? ?? '';
    if (dynamicAttrs.isEmpty && vName.trim().isNotEmpty) {
      if (vName.contains('/')) {
        final parts = vName.split('/');
        for (int i = 0; i < parts.length; i++) {
          final part = parts[i].trim();
          if (part.isNotEmpty) {
            dynamicAttrs['Option ${i + 1}'] = part;
          }
        }
      } else {
        dynamicAttrs['Variant'] = vName.trim();
      }
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
      variantName: vName.isNotEmpty ? vName : 'Default Variant',
      color: json['color'] as String?,
      size: json['size'] as String?,
      storage: json['storage'] as String?,
      price: (json['price'] as num?)?.toDouble() ?? 0.0,
      stock: (json['stock'] as num?)?.toInt() ?? 0,
      status: json['status'] as String? ?? 'ACTIVE',
      attributes: dynamicAttrs,
      images: parsedImages,
    );
  }

  String get primaryImageUrl {
    if (images.isNotEmpty) {
      final primary = images.firstWhere((img) => img.isPrimary, orElse: () => images.first);
      if (primary.imageUrl.isNotEmpty) {
        return primary.imageUrl;
      }
    }
    return '';
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
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'productId': productId,
      'sku': sku,
      'variantName': variantName,
      'color': color,
      'size': size,
      'storage': storage,
      'price': price,
      'stock': stock,
      'status': status,
      'images': images.map((img) => img.toJson()).toList(),
    };
  }
}
