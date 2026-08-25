import 'package:equatable/equatable.dart';

class ProductImageModel extends Equatable {
  final String id;
  final String productId;
  final String? productVariantId;
  final String imageUrl;
  final bool isPrimary;
  final int displayOrder;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const ProductImageModel({
    required this.id,
    required this.productId,
    this.productVariantId,
    required this.imageUrl,
    required this.isPrimary,
    required this.displayOrder,
    this.createdAt,
    this.updatedAt,
  });

  factory ProductImageModel.fromJson(Map<String, dynamic> json) {
    return ProductImageModel(
      id: json['id'] as String? ?? '',
      productId: json['productId'] as String? ?? '',
      productVariantId: json['productVariantId'] as String?,
      imageUrl: json['imageUrl'] as String? ?? '',
      isPrimary: json['isPrimary'] as bool? ?? false,
      displayOrder: json['displayOrder'] as int? ?? 0,
      createdAt: json['createdAt'] != null ? DateTime.tryParse(json['createdAt'] as String) : null,
      updatedAt: json['updatedAt'] != null ? DateTime.tryParse(json['updatedAt'] as String) : null,
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
      if (createdAt != null) 'createdAt': createdAt!.toIso8601String(),
      if (updatedAt != null) 'updatedAt': updatedAt!.toIso8601String(),
    };
  }

  ProductImageModel copyWith({
    String? id,
    String? productId,
    String? productVariantId,
    String? imageUrl,
    bool? isPrimary,
    int? displayOrder,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return ProductImageModel(
      id: id ?? this.id,
      productId: productId ?? this.productId,
      productVariantId: productVariantId ?? this.productVariantId,
      imageUrl: imageUrl ?? this.imageUrl,
      isPrimary: isPrimary ?? this.isPrimary,
      displayOrder: displayOrder ?? this.displayOrder,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  List<Object?> get props => [
        id,
        productId,
        productVariantId,
        imageUrl,
        isPrimary,
        displayOrder,
        createdAt,
        updatedAt,
      ];
}
