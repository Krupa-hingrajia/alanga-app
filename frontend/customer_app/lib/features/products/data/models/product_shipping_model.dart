import 'package:equatable/equatable.dart';

class ProductShippingModel extends Equatable {
  final String? id;
  final String? productId;
  final double weight;
  final String weightUnit;
  final double length;
  final double width;
  final double height;
  final String dimensionUnit;
  final double shippingCharge;
  final bool isFreeShipping;
  final double? freeShippingAboveAmount;
  final int estimatedDeliveryMinDays;
  final int estimatedDeliveryMaxDays;
  final bool codAvailable;
  final String? estimatedDeliveryLabel;

  const ProductShippingModel({
    this.id,
    this.productId,
    this.weight = 0.0,
    this.weightUnit = 'kg',
    this.length = 0.0,
    this.width = 0.0,
    this.height = 0.0,
    this.dimensionUnit = 'cm',
    this.shippingCharge = 0.0,
    this.isFreeShipping = false,
    this.freeShippingAboveAmount,
    this.estimatedDeliveryMinDays = 3,
    this.estimatedDeliveryMaxDays = 7,
    this.codAvailable = true,
    this.estimatedDeliveryLabel,
  });

  factory ProductShippingModel.fromJson(Map<String, dynamic> json) {
    final minDays = (json['estimatedDeliveryMinDays'] as num?)?.toInt() ?? 3;
    final maxDays = (json['estimatedDeliveryMaxDays'] as num?)?.toInt() ?? 7;

    return ProductShippingModel(
      id: json['id'] as String?,
      productId: json['productId'] as String?,
      weight: (json['weight'] as num?)?.toDouble() ?? 0.0,
      weightUnit: json['weightUnit'] as String? ?? 'kg',
      length: (json['length'] as num?)?.toDouble() ?? 0.0,
      width: (json['width'] as num?)?.toDouble() ?? 0.0,
      height: (json['height'] as num?)?.toDouble() ?? 0.0,
      dimensionUnit: json['dimensionUnit'] as String? ?? 'cm',
      shippingCharge: (json['shippingCharge'] as num?)?.toDouble() ?? 0.0,
      isFreeShipping: json['isFreeShipping'] as bool? ?? false,
      freeShippingAboveAmount: (json['freeShippingAboveAmount'] as num?)?.toDouble(),
      estimatedDeliveryMinDays: minDays,
      estimatedDeliveryMaxDays: maxDays,
      codAvailable: json['codAvailable'] as bool? ?? true,
      estimatedDeliveryLabel: json['estimatedDeliveryLabel'] as String? ?? '$minDays-$maxDays Days',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'productId': productId,
      'weight': weight,
      'weightUnit': weightUnit,
      'length': length,
      'width': width,
      'height': height,
      'dimensionUnit': dimensionUnit,
      'shippingCharge': shippingCharge,
      'isFreeShipping': isFreeShipping,
      if (freeShippingAboveAmount != null) 'freeShippingAboveAmount': freeShippingAboveAmount,
      'estimatedDeliveryMinDays': estimatedDeliveryMinDays,
      'estimatedDeliveryMaxDays': estimatedDeliveryMaxDays,
      'codAvailable': codAvailable,
    };
  }

  @override
  List<Object?> get props => [
        id,
        productId,
        weight,
        weightUnit,
        length,
        width,
        height,
        dimensionUnit,
        shippingCharge,
        isFreeShipping,
        freeShippingAboveAmount,
        estimatedDeliveryMinDays,
        estimatedDeliveryMaxDays,
        codAvailable,
        estimatedDeliveryLabel,
      ];
}
