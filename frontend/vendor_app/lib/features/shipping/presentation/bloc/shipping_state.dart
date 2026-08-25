import 'package:equatable/equatable.dart';
import '../../data/models/product_shipping_model.dart';

abstract class ShippingState extends Equatable {
  const ShippingState();

  @override
  List<Object?> get props => [];
}

class ShippingInitial extends ShippingState {}

class ShippingLoading extends ShippingState {}

class ShippingLoaded extends ShippingState {
  final ProductShippingModel? shipping;

  const ShippingLoaded({this.shipping});

  @override
  List<Object?> get props => [shipping];
}

class ShippingSaving extends ShippingState {}

class ShippingSaved extends ShippingState {
  final ProductShippingModel shipping;
  final String message;

  const ShippingSaved({required this.shipping, required this.message});

  @override
  List<Object?> get props => [shipping, message];
}

class ShippingError extends ShippingState {
  final String message;

  const ShippingError({required this.message});

  @override
  List<Object?> get props => [message];
}
