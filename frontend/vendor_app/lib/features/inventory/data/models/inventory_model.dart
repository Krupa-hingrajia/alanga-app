import '../../../products/data/models/product_variant_model.dart';

class InventoryModel {
  final ProductVariantModel variant;
  final String sku;
  final int currentStock;
  final int reservedStock;
  final int availableStock;
  final int minimumStock;
  final String inventoryStatus;
  final DateTime? lastStockUpdatedAt;
  final String? lastStockUpdatedBy;

  InventoryModel({
    required this.variant,
    required this.sku,
    required this.currentStock,
    required this.reservedStock,
    required this.availableStock,
    required this.minimumStock,
    required this.inventoryStatus,
    this.lastStockUpdatedAt,
    this.lastStockUpdatedBy,
  });

  factory InventoryModel.fromJson(Map<String, dynamic> json) {
    ProductVariantModel parsedVariant;
    if (json['variant'] != null && json['variant'] is Map<String, dynamic>) {
      parsedVariant = ProductVariantModel.fromJson(json['variant'] as Map<String, dynamic>);
    } else {
      parsedVariant = ProductVariantModel(
        id: json['variantId'] as String? ?? '',
        productId: json['productId'] as String? ?? '',
        sku: json['sku'] as String? ?? '',
        variantName: json['variantName'] as String? ?? 'Variant',
        price: 0,
        stock: (json['currentStock'] as num?)?.toInt() ?? 0,
      );
    }

    DateTime? parsedDate;
    if (json['lastStockUpdatedAt'] != null) {
      parsedDate = DateTime.tryParse(json['lastStockUpdatedAt'].toString());
    }

    return InventoryModel(
      variant: parsedVariant,
      sku: json['sku'] as String? ?? parsedVariant.sku,
      currentStock: (json['currentStock'] as num?)?.toInt() ?? 0,
      reservedStock: (json['reservedStock'] as num?)?.toInt() ?? 0,
      availableStock: (json['availableStock'] as num?)?.toInt() ?? 0,
      minimumStock: (json['minimumStock'] as num?)?.toInt() ?? 5,
      inventoryStatus: json['inventoryStatus'] as String? ?? 'OUT_OF_STOCK',
      lastStockUpdatedAt: parsedDate,
      lastStockUpdatedBy: json['lastStockUpdatedBy'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'variant': variant.toJson(),
      'sku': sku,
      'currentStock': currentStock,
      'reservedStock': reservedStock,
      'availableStock': availableStock,
      'minimumStock': minimumStock,
      'inventoryStatus': inventoryStatus,
      'lastStockUpdatedAt': lastStockUpdatedAt?.toIso8601String(),
      'lastStockUpdatedBy': lastStockUpdatedBy,
    };
  }
}
