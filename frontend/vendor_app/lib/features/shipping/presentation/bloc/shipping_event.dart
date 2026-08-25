import 'package:equatable/equatable.dart';
import '../../data/models/product_shipping_model.dart';

abstract class ShippingEvent extends Equatable {
  const ShippingEvent();

  @override
  List<Object?> get props => [];
}

class FetchShippingEvent extends ShippingEvent {
  final String productId;

  const FetchShippingEvent({required this.productId});

  @override
  List<Object?> get props => [productId];
}

class SaveShippingEvent extends ShippingEvent {
  final String productId;
  final ProductShippingModel shipping;

  const SaveShippingEvent({required this.productId, required this.shipping});

  @override
  List<Object?> get props => [productId, shipping];
}
