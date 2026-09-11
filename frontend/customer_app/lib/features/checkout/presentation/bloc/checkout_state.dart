import '../../data/models/checkout_summary_model.dart';
import '../../data/models/order_model.dart';

abstract class CheckoutState {}

class CheckoutInitial extends CheckoutState {}

class CheckoutLoading extends CheckoutState {}

class CheckoutLoaded extends CheckoutState {
  final CheckoutSummaryModel summary;

  CheckoutLoaded({required this.summary});
}

class PlaceOrderLoading extends CheckoutState {
  final CheckoutSummaryModel summary;

  PlaceOrderLoading({required this.summary});
}

class PlaceOrderSuccess extends CheckoutState {
  final OrderModel order;

  PlaceOrderSuccess({required this.order});
}

class CheckoutError extends CheckoutState {
  final String message;

  CheckoutError({required this.message});
}
