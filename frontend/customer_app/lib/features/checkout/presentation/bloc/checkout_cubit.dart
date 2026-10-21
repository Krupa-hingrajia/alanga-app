import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/repositories/checkout_repository.dart';
import 'checkout_state.dart';

class CheckoutCubit extends Cubit<CheckoutState> {
  final CheckoutRepository repository;

  CheckoutCubit({required this.repository}) : super(CheckoutInitial());

  Future<void> fetchCheckoutSummary() async {
    emit(CheckoutLoading());
    try {
      final summary = await repository.getCheckoutSummary();
      emit(CheckoutLoaded(summary: summary));
    } catch (e) {
      emit(CheckoutError(message: e.toString().replaceAll('Exception: ', '')));
    }
  }

  Future<void> placeOrder({
    required String addressId,
    String paymentMethod = 'COD',
    String? notes,
  }) async {
    if (state is! CheckoutLoaded) return;
    final currentSummary = (state as CheckoutLoaded).summary;

    emit(PlaceOrderLoading(summary: currentSummary));
    try {
      final order = await repository.placeOrder(
        addressId: addressId,
        paymentMethod: paymentMethod,
        notes: notes,
      );
      emit(PlaceOrderSuccess(order: order));
    } catch (e) {
      emit(CheckoutLoaded(summary: currentSummary));
      rethrow;
    }
  }

  Future<Map<String, dynamic>> createPaymentOrder({
    required String gateway,
    required String addressId,
    String? notes,
  }) async {
    return repository.createPaymentOrder(
      gateway: gateway,
      addressId: addressId,
      notes: notes,
    );
  }

  Future<void> verifyPayment({
    required String gateway,
    required String gatewayOrderId,
    String? gatewayPaymentId,
    String? gatewaySignature,
    required String addressId,
    String? notes,
  }) async {
    if (state is! CheckoutLoaded && state is! PlaceOrderLoading) return;
    final currentSummary = state is CheckoutLoaded
        ? (state as CheckoutLoaded).summary
        : (state as PlaceOrderLoading).summary;

    emit(PlaceOrderLoading(summary: currentSummary));
    try {
      final order = await repository.verifyPayment(
        gateway: gateway,
        gatewayOrderId: gatewayOrderId,
        gatewayPaymentId: gatewayPaymentId,
        gatewaySignature: gatewaySignature,
        addressId: addressId,
        notes: notes,
      );
      emit(PlaceOrderSuccess(order: order));
    } catch (e) {
      emit(CheckoutLoaded(summary: currentSummary));
      rethrow;
    }
  }
}
