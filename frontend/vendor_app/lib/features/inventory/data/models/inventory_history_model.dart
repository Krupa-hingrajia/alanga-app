class InventoryHistoryModel {
  final String id;
  final String variantId;
  final int previousStock;
  final int newStock;
  final int quantityChanged;
  final String actionType;
  final String? remarks;
  final String updatedBy;
  final DateTime createdAt;

  InventoryHistoryModel({
    required this.id,
    required this.variantId,
    required this.previousStock,
    required this.newStock,
    required this.quantityChanged,
    required this.actionType,
    this.remarks,
    required this.updatedBy,
    required this.createdAt,
  });

  factory InventoryHistoryModel.fromJson(Map<String, dynamic> json) {
    DateTime parsedDate = DateTime.now();
    if (json['createdAt'] != null) {
      parsedDate = DateTime.tryParse(json['createdAt'].toString()) ?? DateTime.now();
    }

    return InventoryHistoryModel(
      id: json['id'] as String? ?? '',
      variantId: json['variantId'] as String? ?? '',
      previousStock: (json['previousStock'] as num?)?.toInt() ?? 0,
      newStock: (json['newStock'] as num?)?.toInt() ?? 0,
      quantityChanged: (json['quantityChanged'] as num?)?.toInt() ?? 0,
      actionType: json['actionType'] as String? ?? 'MANUAL_UPDATE',
      remarks: json['remarks'] as String?,
      updatedBy: json['updatedBy'] as String? ?? '',
      createdAt: parsedDate,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'variantId': variantId,
      'previousStock': previousStock,
      'newStock': newStock,
      'quantityChanged': quantityChanged,
      'actionType': actionType,
      'remarks': remarks,
      'updatedBy': updatedBy,
      'createdAt': createdAt.toIso8601String(),
    };
  }
}
