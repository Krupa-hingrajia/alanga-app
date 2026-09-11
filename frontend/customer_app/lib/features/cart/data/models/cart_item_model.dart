class CartItemModel {
  final String id;
  final String productId;
  final String productVariantId;
  final int quantity;
  final double unitPrice;
  final double itemTotal;
  final String selectedImageUrl;
  final bool isOutOfStock;
  final int stock;
  final String stockStatus;
  final String productName;
  final String productSku;
  final String brandName;
  final String categoryName;
  final String variantName;
  final String variantSku;
  final String? color;
  final String? size;
  final String? storage;
  final Map<String, dynamic> variantAttributes;
  final Map<String, dynamic>? shipping;
  final DateTime createdAt;
  final DateTime updatedAt;

  CartItemModel({
    required this.id,
    required this.productId,
    required this.productVariantId,
    required this.quantity,
    required this.unitPrice,
    required this.itemTotal,
    required this.selectedImageUrl,
    required this.isOutOfStock,
    required this.stock,
    required this.stockStatus,
    required this.productName,
    required this.productSku,
    required this.brandName,
    required this.categoryName,
    required this.variantName,
    required this.variantSku,
    this.color,
    this.size,
    this.storage,
    required this.variantAttributes,
    this.shipping,
    required this.createdAt,
    required this.updatedAt,
  });

  factory CartItemModel.fromJson(Map<String, dynamic> json) {
    final productMap = json['product'] as Map<String, dynamic>? ?? {};
    final variantMap = json['variant'] as Map<String, dynamic>? ?? {};
    final brandMap = productMap['brand'] as Map<String, dynamic>? ?? {};
    final categoryMap = productMap['category'] as Map<String, dynamic>? ?? {};

    return CartItemModel(
      id: json['id'] as String? ?? '',
      productId: json['productId'] as String? ?? '',
      productVariantId: json['productVariantId'] as String? ?? '',
      quantity: (json['quantity'] as num?)?.toInt() ?? 1,
      unitPrice: (json['unitPrice'] as num?)?.toDouble() ?? 0.0,
      itemTotal: (json['itemTotal'] as num?)?.toDouble() ?? 0.0,
      selectedImageUrl: json['selectedImageUrl'] as String? ?? '',
      isOutOfStock: json['isOutOfStock'] as bool? ?? false,
      stock: (json['stock'] as num?)?.toInt() ?? 0,
      stockStatus: json['stockStatus'] as String? ?? 'IN_STOCK',
      productName: productMap['name'] as String? ?? 'Product',
      productSku: productMap['sku'] as String? ?? '',
      brandName: brandMap['name'] as String? ?? '',
      categoryName: categoryMap['name'] as String? ?? '',
      variantName: variantMap['variantName'] as String? ?? 'Default Variant',
      variantSku: variantMap['sku'] as String? ?? '',
      color: variantMap['color'] as String?,
      size: variantMap['size'] as String?,
      storage: variantMap['storage'] as String?,
      variantAttributes: variantMap['attributes'] is Map
          ? Map<String, dynamic>.from(variantMap['attributes'] as Map)
          : {},
      shipping: json['shipping'] is Map
          ? Map<String, dynamic>.from(json['shipping'] as Map)
          : null,
      createdAt: json['createdAt'] != null
          ? DateTime.tryParse(json['createdAt'].toString()) ?? DateTime.now()
          : DateTime.now(),
      updatedAt: json['updatedAt'] != null
          ? DateTime.tryParse(json['updatedAt'].toString()) ?? DateTime.now()
          : DateTime.now(),
    );
  }
}
