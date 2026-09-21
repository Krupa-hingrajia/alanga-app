import 'package:equatable/equatable.dart';
import '../../data/models/vendor_order_model.dart';

abstract class VendorOrderEvent extends Equatable {
  const VendorOrderEvent();

  @override
  List<Object?> get props => [];
}

class InitOrderDetailEvent extends VendorOrderEvent {
  final VendorOrderModel order;

  const InitOrderDetailEvent({required this.order});

  @override
  List<Object?> get props => [order];
}

class FetchVendorOrdersEvent extends VendorOrderEvent {
  final bool isRefresh;

  const FetchVendorOrdersEvent({this.isRefresh = false});

  @override
  List<Object?> get props => [isRefresh];
}

class FilterOrdersByStatusEvent extends VendorOrderEvent {
  final String? status; // null means 'ALL'

  const FilterOrdersByStatusEvent({this.status});

  @override
  List<Object?> get props => [status];
}

class SearchOrdersEvent extends VendorOrderEvent {
  final String query;

  const SearchOrdersEvent({required this.query});

  @override
  List<Object?> get props => [query];
}

class UpdateOrderStatusEvent extends VendorOrderEvent {
  final String orderId;
  final String newStatus;

  const UpdateOrderStatusEvent({
    required this.orderId,
    required this.newStatus,
  });

  @override
  List<Object?> get props => [orderId, newStatus];
}
