class ProductImageModel {
  final String id;
  final String productId;
  final String? productVariantId;
  final String imageUrl;
  final bool isPrimary;
  final int displayOrder;

  ProductImageModel({
    required this.id,
    required this.productId,
    this.productVariantId,
    required this.imageUrl,
    required this.isPrimary,
    required this.displayOrder,
  });

  factory ProductImageModel.fromJson(Map<String, dynamic> json) {
    return ProductImageModel(
      id: json['id'] as String? ?? '',
      productId: json['productId'] as String? ?? '',
      productVariantId: json['productVariantId'] as String?,
      imageUrl: json['imageUrl'] as String? ?? '',
      isPrimary: json['isPrimary'] as bool? ?? false,
      displayOrder: (json['displayOrder'] as num?)?.toInt() ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'productId': productId,
      if (productVariantId != null) 'productVariantId': productVariantId,
      'imageUrl': imageUrl,
      'isPrimary': isPrimary,
      'displayOrder': displayOrder,
    };
  }
}
