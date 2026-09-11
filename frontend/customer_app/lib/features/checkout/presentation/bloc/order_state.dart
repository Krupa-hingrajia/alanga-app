import '../../data/models/order_model.dart';

abstract class OrderState {}

class OrderInitial extends OrderState {}

class OrderLoading extends OrderState {}

class OrderListLoaded extends OrderState {
  final List<OrderModel> orders;

  OrderListLoaded({required this.orders});
}

class OrderDetailLoaded extends OrderState {
  final OrderModel order;

  OrderDetailLoaded({required this.order});
}

class OrderError extends OrderState {
  final String message;

  OrderError({required this.message});
}
