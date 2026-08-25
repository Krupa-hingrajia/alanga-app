import 'package:flutter_bloc/flutter_bloc.dart';
import 'shipping_event.dart';
import 'shipping_state.dart';
import '../../domain/repositories/shipping_repository.dart';

class ShippingBloc extends Bloc<ShippingEvent, ShippingState> {
  final ShippingRepository _shippingRepository;

  ShippingBloc({required ShippingRepository shippingRepository})
      : _shippingRepository = shippingRepository,
        super(ShippingInitial()) {
    on<FetchShippingEvent>(_onFetchShipping);
    on<SaveShippingEvent>(_onSaveShipping);
  }

  Future<void> _onFetchShipping(
    FetchShippingEvent event,
    Emitter<ShippingState> emit,
  ) async {
    emit(ShippingLoading());
    try {
      final shipping = await _shippingRepository.getShipping(event.productId);
      emit(ShippingLoaded(shipping: shipping));
    } catch (e) {
      emit(ShippingError(message: e.toString().replaceAll('Exception: ', '')));
    }
  }

  Future<void> _onSaveShipping(
    SaveShippingEvent event,
    Emitter<ShippingState> emit,
  ) async {
    emit(ShippingSaving());
    try {
      final saved = await _shippingRepository.saveShipping(event.productId, event.shipping);
      emit(ShippingSaved(
        shipping: saved,
        message: 'Shipping information saved successfully.',
      ));
    } catch (e) {
      emit(ShippingError(message: e.toString().replaceAll('Exception: ', '')));
    }
  }
}
