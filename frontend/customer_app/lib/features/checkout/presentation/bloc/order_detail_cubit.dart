import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/repositories/checkout_repository.dart';
import 'order_detail_state.dart';

class OrderDetailCubit extends Cubit<OrderDetailState> {
  final CheckoutRepository repository;

  OrderDetailCubit({required this.repository}) : super(OrderDetailInitial());

  Future<void> fetchOrderById(String orderId) async {
    final prev = state is OrderDetailSuccess ? (state as OrderDetailSuccess).order : null;
    emit(OrderDetailLoading(previousOrder: prev));
    try {
      final order = await repository.getOrderById(orderId);
      emit(OrderDetailSuccess(order: order));
    } catch (e) {
      emit(OrderDetailFailure(
        message: e.toString().replaceAll('Exception: ', ''),
        previousOrder: prev,
      ));
    }
  }
}
