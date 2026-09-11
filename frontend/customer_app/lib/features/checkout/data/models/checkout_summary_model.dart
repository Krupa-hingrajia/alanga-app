import '../../../addresses/data/models/address_model.dart';

class CheckoutItemModel {
  final String cartItemId;
  final String productId;
  final String variantId;
  final String productName;
  final String variantName;
  final String sku;
  final int quantity;
  final double unitPrice;
  final double itemSubtotal;
  final double itemShippingFee;
  final double totalItemCost;
  final String imageUrl;
  final int stock;
  final bool isOutOfStock;
  final Map<String, dynamic> variantAttributes;

  CheckoutItemModel({
    required this.cartItemId,
    required this.productId,
    required this.variantId,
    required this.productName,
    required this.variantName,
    required this.sku,
    required this.quantity,
    required this.unitPrice,
    required this.itemSubtotal,
    required this.itemShippingFee,
    required this.totalItemCost,
    required this.imageUrl,
    required this.stock,
    required this.isOutOfStock,
    required this.variantAttributes,
  });

  factory CheckoutItemModel.fromJson(Map<String, dynamic> json) {
    return CheckoutItemModel(
      cartItemId: json['cartItemId'] as String? ?? '',
      productId: json['productId'] as String? ?? '',
      variantId: json['variantId'] as String? ?? '',
      productName: json['productName'] as String? ?? '',
      variantName: json['variantName'] as String? ?? 'Default Variant',
      sku: json['sku'] as String? ?? '',
      quantity: (json['quantity'] as num?)?.toInt() ?? 1,
      unitPrice: (json['unitPrice'] as num?)?.toDouble() ?? 0.0,
      itemSubtotal: (json['itemSubtotal'] as num?)?.toDouble() ?? 0.0,
      itemShippingFee: (json['itemShippingFee'] as num?)?.toDouble() ?? 0.0,
      totalItemCost: (json['totalItemCost'] as num?)?.toDouble() ?? 0.0,
      imageUrl: json['imageUrl'] as String? ?? '',
      stock: (json['stock'] as num?)?.toInt() ?? 0,
      isOutOfStock: json['isOutOfStock'] as bool? ?? false,
      variantAttributes: json['variantAttributes'] is Map
          ? Map<String, dynamic>.from(json['variantAttributes'] as Map)
          : {},
    );
  }
}

class EstimatedDeliveryModel {
  final int minDays;
  final int maxDays;
  final String displayRange;

  EstimatedDeliveryModel({
    required this.minDays,
    required this.maxDays,
    required this.displayRange,
  });

  factory EstimatedDeliveryModel.fromJson(Map<String, dynamic> json) {
    return EstimatedDeliveryModel(
      minDays: (json['minDays'] as num?)?.toInt() ?? 3,
      maxDays: (json['maxDays'] as num?)?.toInt() ?? 7,
      displayRange: json['displayRange'] as String? ?? '3 - 7 Business Days',
    );
  }
}

class CheckoutSummaryModel {
  final List<CheckoutItemModel> items;
  final int itemCount;
  final double subtotal;
  final double shippingCharge;
  final double grandTotal;
  final bool hasOutOfStockItems;
  final AddressModel? defaultAddress;
  final int savedAddressesCount;
  final EstimatedDeliveryModel estimatedDelivery;

  CheckoutSummaryModel({
    required this.items,
    required this.itemCount,
    required this.subtotal,
    required this.shippingCharge,
    required this.grandTotal,
    required this.hasOutOfStockItems,
    this.defaultAddress,
    required this.savedAddressesCount,
    required this.estimatedDelivery,
  });

  factory CheckoutSummaryModel.fromJson(Map<String, dynamic> json) {
    final rawItems = json['items'] as List? ?? [];
    final itemsList = rawItems
        .map((item) => CheckoutItemModel.fromJson(item as Map<String, dynamic>))
        .toList();

    return CheckoutSummaryModel(
      items: itemsList,
      itemCount: (json['itemCount'] as num?)?.toInt() ?? itemsList.length,
      subtotal: (json['subtotal'] as num?)?.toDouble() ?? 0.0,
      shippingCharge: (json['shippingCharge'] as num?)?.toDouble() ?? 0.0,
      grandTotal: (json['grandTotal'] as num?)?.toDouble() ?? 0.0,
      hasOutOfStockItems: json['hasOutOfStockItems'] as bool? ?? false,
      defaultAddress: json['defaultAddress'] != null
          ? AddressModel.fromJson(json['defaultAddress'] as Map<String, dynamic>)
          : null,
      savedAddressesCount: (json['savedAddressesCount'] as num?)?.toInt() ?? 0,
      estimatedDelivery: json['estimatedDelivery'] != null
          ? EstimatedDeliveryModel.fromJson(json['estimatedDelivery'] as Map<String, dynamic>)
          : EstimatedDeliveryModel(minDays: 3, maxDays: 7, displayRange: '3 - 7 Business Days'),
    );
  }
}
