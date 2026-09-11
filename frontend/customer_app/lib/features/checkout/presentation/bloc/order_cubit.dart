import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/repositories/checkout_repository.dart';
import 'order_state.dart';

class OrderCubit extends Cubit<OrderState> {
  final CheckoutRepository repository;

  OrderCubit({required this.repository}) : super(OrderInitial());

  Future<void> fetchCustomerOrders() async {
    emit(OrderLoading());
    try {
      final orders = await repository.getCustomerOrders();
      emit(OrderListLoaded(orders: orders));
    } catch (e) {
      emit(OrderError(message: e.toString().replaceAll('Exception: ', '')));
    }
  }

  Future<void> fetchOrderById(String orderId) async {
    emit(OrderLoading());
    try {
      final order = await repository.getOrderById(orderId);
      emit(OrderDetailLoaded(order: order));
    } catch (e) {
      emit(OrderError(message: e.toString().replaceAll('Exception: ', '')));
    }
  }
}
