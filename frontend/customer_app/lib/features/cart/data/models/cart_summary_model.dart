class CartSummaryModel {
  final double subtotal;
  final double shippingCharge;
  final double estimatedTotal;
  final int totalItems;
  final int itemCount;
  final bool hasOutOfStockItems;

  CartSummaryModel({
    required this.subtotal,
    required this.shippingCharge,
    required this.estimatedTotal,
    required this.totalItems,
    required this.itemCount,
    required this.hasOutOfStockItems,
  });

  factory CartSummaryModel.fromJson(Map<String, dynamic> json) {
    return CartSummaryModel(
      subtotal: (json['subtotal'] as num?)?.toDouble() ?? 0.0,
      shippingCharge: (json['shippingCharge'] as num?)?.toDouble() ?? 0.0,
      estimatedTotal: (json['estimatedTotal'] as num?)?.toDouble() ?? 0.0,
      totalItems: (json['totalItems'] as num?)?.toInt() ?? 0,
      itemCount: (json['itemCount'] as num?)?.toInt() ?? 0,
      hasOutOfStockItems: json['hasOutOfStockItems'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'subtotal': subtotal,
      'shippingCharge': shippingCharge,
      'estimatedTotal': estimatedTotal,
      'totalItems': totalItems,
      'itemCount': itemCount,
      'hasOutOfStockItems': hasOutOfStockItems,
    };
  }

  factory CartSummaryModel.empty() {
    return CartSummaryModel(
      subtotal: 0.0,
      shippingCharge: 0.0,
      estimatedTotal: 0.0,
      totalItems: 0,
      itemCount: 0,
      hasOutOfStockItems: false,
    );
  }
}
