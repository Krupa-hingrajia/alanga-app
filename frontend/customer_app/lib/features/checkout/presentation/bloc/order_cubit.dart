import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/repositories/checkout_repository.dart';
import '../../data/models/order_model.dart';
import 'order_state.dart';

class OrderCubit extends Cubit<OrderState> {
  final CheckoutRepository repository;
  List<OrderModel> _cachedOrders = [];

  OrderCubit({required this.repository}) : super(OrderInitial());

  List<OrderModel> get cachedOrders => _cachedOrders;

  Future<void> fetchCustomerOrders({bool showLoading = true}) async {
    if (showLoading || _cachedOrders.isEmpty) {
      emit(OrderLoading(previousOrders: _cachedOrders));
    }
    try {
      final orders = await repository.getCustomerOrders();
      _cachedOrders = orders;
      emit(OrderListLoaded(orders: orders));
    } catch (e) {
      emit(OrderError(
        message: e.toString().replaceAll('Exception: ', ''),
        previousOrders: _cachedOrders,
      ));
    }
  }

  void restoreOrderList() {
    if (_cachedOrders.isNotEmpty) {
      emit(OrderListLoaded(orders: _cachedOrders));
    } else {
      fetchCustomerOrders();
    }
  }
}
