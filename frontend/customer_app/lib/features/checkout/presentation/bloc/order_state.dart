import '../../data/models/order_model.dart';

abstract class OrderState {}

class OrderInitial extends OrderState {}

class OrderLoading extends OrderState {
  final List<OrderModel>? previousOrders;

  OrderLoading({this.previousOrders});
}

class OrderListLoaded extends OrderState {
  final List<OrderModel> orders;

  OrderListLoaded({required this.orders});
}

class OrderDetailLoaded extends OrderState {
  final OrderModel order;
  final List<OrderModel> orders;

  OrderDetailLoaded({required this.order, this.orders = const []});
}

class OrderError extends OrderState {
  final String message;
  final List<OrderModel>? previousOrders;

  OrderError({required this.message, this.previousOrders});
}
