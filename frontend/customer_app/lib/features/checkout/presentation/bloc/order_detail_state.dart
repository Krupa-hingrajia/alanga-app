import 'package:equatable/equatable.dart';
import '../../data/models/order_model.dart';

abstract class OrderDetailState extends Equatable {
  const OrderDetailState();

  @override
  List<Object?> get props => [];
}

class OrderDetailInitial extends OrderDetailState {}

class OrderDetailLoading extends OrderDetailState {
  final OrderModel? previousOrder;

  const OrderDetailLoading({this.previousOrder});

  @override
  List<Object?> get props => [previousOrder];
}

class OrderDetailSuccess extends OrderDetailState {
  final OrderModel order;

  const OrderDetailSuccess({required this.order});

  @override
  List<Object?> get props => [order];
}

class OrderDetailFailure extends OrderDetailState {
  final String message;
  final OrderModel? previousOrder;

  const OrderDetailFailure({required this.message, this.previousOrder});

  @override
  List<Object?> get props => [message, previousOrder];
}
