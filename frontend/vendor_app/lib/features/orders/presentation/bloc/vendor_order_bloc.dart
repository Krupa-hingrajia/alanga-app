import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/models/vendor_order_model.dart';
import '../../domain/repositories/vendor_order_repository.dart';
import 'vendor_order_event.dart';
import 'vendor_order_state.dart';

class VendorOrderBloc extends Bloc<VendorOrderEvent, VendorOrderState> {
  final VendorOrderRepository _repository;
  List<VendorOrderModel> _cachedOrders = [];

  VendorOrderBloc({required VendorOrderRepository repository})
      : _repository = repository,
        super(VendorOrderInitial()) {
    on<InitOrderDetailEvent>(_onInitOrderDetail);
    on<FetchVendorOrdersEvent>(_onFetchVendorOrders);
    on<FilterOrdersByStatusEvent>(_onFilterOrdersByStatus);
    on<SearchOrdersEvent>(_onSearchOrders);
    on<UpdateOrderStatusEvent>(_onUpdateOrderStatus);
  }

  void _onInitOrderDetail(
    InitOrderDetailEvent event,
    Emitter<VendorOrderState> emit,
  ) {
    final index = _cachedOrders.indexWhere((o) => o.id == event.order.id);
    if (index != -1) {
      _cachedOrders[index] = event.order;
    } else {
      _cachedOrders = [event.order];
    }
    final counts = _calculateStatusCounts(_cachedOrders);
    emit(VendorOrderLoaded(
      allOrders: List.from(_cachedOrders),
      filteredOrders: List.from(_cachedOrders),
      statusCounts: counts,
    ));
  }

  Future<void> _onFetchVendorOrders(
    FetchVendorOrdersEvent event,
    Emitter<VendorOrderState> emit,
  ) async {
    if (!event.isRefresh) {
      emit(VendorOrderLoading());
    }

    try {
      final orders = await _repository.getOrders();
      _cachedOrders = orders;

      final currentSelectedStatus = (state is VendorOrderLoaded)
          ? (state as VendorOrderLoaded).selectedStatus
          : null;
      final currentSearchQuery = (state is VendorOrderLoaded)
          ? (state as VendorOrderLoaded).searchQuery
          : '';

      final counts = _calculateStatusCounts(orders);
      final filtered = _applyFilter(
        orders: orders,
        status: currentSelectedStatus,
        query: currentSearchQuery,
      );

      emit(VendorOrderLoaded(
        allOrders: orders,
        filteredOrders: filtered,
        selectedStatus: currentSelectedStatus,
        searchQuery: currentSearchQuery,
        statusCounts: counts,
      ));
    } catch (e) {
      emit(VendorOrderError(message: e.toString().replaceAll('Exception: ', '')));
    }
  }

  void _onFilterOrdersByStatus(
    FilterOrdersByStatusEvent event,
    Emitter<VendorOrderState> emit,
  ) {
    if (state is VendorOrderLoaded) {
      final currentState = state as VendorOrderLoaded;
      final filtered = _applyFilter(
        orders: _cachedOrders,
        status: event.status,
        query: currentState.searchQuery,
      );

      emit(currentState.copyWith(
        selectedStatus: event.status,
        clearStatusFilter: event.status == null,
        filteredOrders: filtered,
        clearActionMessage: true,
        clearErrorMessage: true,
      ));
    }
  }

  void _onSearchOrders(
    SearchOrdersEvent event,
    Emitter<VendorOrderState> emit,
  ) {
    if (state is VendorOrderLoaded) {
      final currentState = state as VendorOrderLoaded;
      final filtered = _applyFilter(
        orders: _cachedOrders,
        status: currentState.selectedStatus,
        query: event.query,
      );

      emit(currentState.copyWith(
        searchQuery: event.query,
        filteredOrders: filtered,
        clearActionMessage: true,
        clearErrorMessage: true,
      ));
    }
  }

  Future<void> _onUpdateOrderStatus(
    UpdateOrderStatusEvent event,
    Emitter<VendorOrderState> emit,
  ) async {
    final currentLoaded = (state is VendorOrderLoaded) ? (state as VendorOrderLoaded) : null;
    final selectedStatus = currentLoaded?.selectedStatus;
    final searchQuery = currentLoaded?.searchQuery ?? '';

    if (currentLoaded != null) {
      emit(currentLoaded.copyWith(
        isUpdating: true,
        updatingOrderId: event.orderId,
        clearActionMessage: true,
        clearErrorMessage: true,
      ));
    } else {
      emit(VendorOrderLoading());
    }

    try {
      final updatedOrder = await _repository.updateOrderStatus(
        orderId: event.orderId,
        status: event.newStatus,
      );

      // Update in cached list
      final index = _cachedOrders.indexWhere((o) => o.id == event.orderId);
      if (index != -1) {
        _cachedOrders[index] = updatedOrder;
      } else {
        _cachedOrders.insert(0, updatedOrder);
      }

      final counts = _calculateStatusCounts(_cachedOrders);
      final filtered = _applyFilter(
        orders: _cachedOrders,
        status: selectedStatus,
        query: searchQuery,
      );

      emit(VendorOrderLoaded(
        allOrders: List.from(_cachedOrders),
        filteredOrders: filtered,
        selectedStatus: selectedStatus,
        searchQuery: searchQuery,
        statusCounts: counts,
        isUpdating: false,
        updatingOrderId: null,
        actionMessage: 'Order status updated to ${event.newStatus}',
      ));
    } catch (e) {
      if (currentLoaded != null) {
        emit(currentLoaded.copyWith(
          isUpdating: false,
          updatingOrderId: null,
          errorMessage: e.toString().replaceAll('Exception: ', ''),
        ));
      } else {
        emit(VendorOrderError(message: e.toString().replaceAll('Exception: ', '')));
      }
    }
  }

  Map<String, int> _calculateStatusCounts(List<VendorOrderModel> orders) {
    final counts = <String, int>{
      'ALL': orders.length,
      'PENDING': 0,
      'CONFIRMED': 0,
      'PROCESSING': 0,
      'PACKED': 0,
      'SHIPPED': 0,
      'DELIVERED': 0,
      'CANCELLED': 0,
    };

    for (final order in orders) {
      final s = order.status.toUpperCase();
      if (counts.containsKey(s)) {
        counts[s] = (counts[s] ?? 0) + 1;
      }
    }

    return counts;
  }

  List<VendorOrderModel> _applyFilter({
    required List<VendorOrderModel> orders,
    required String? status,
    required String query,
  }) {
    final cleanQuery = query.toLowerCase().trim();

    return orders.where((order) {
      // 1. Status Filter
      if (status != null && status.isNotEmpty && status.toUpperCase() != 'ALL') {
        if (order.status.toUpperCase() != status.toUpperCase()) {
          return false;
        }
      }

      // 2. Search Filter (by order number, customer name, customer phone, product name)
      if (cleanQuery.isNotEmpty) {
        final matchesOrderNumber = order.orderNumber.toLowerCase().contains(cleanQuery);
        final matchesCustomer = order.customer?.fullName.toLowerCase().contains(cleanQuery) ?? false;
        final matchesPhone = order.customer?.phoneNumber.toLowerCase().contains(cleanQuery) ?? false;
        final matchesProduct = order.orderItems.any(
          (item) => item.productName.toLowerCase().contains(cleanQuery) ||
              (item.sku?.toLowerCase().contains(cleanQuery) ?? false),
        );

        if (!matchesOrderNumber && !matchesCustomer && !matchesPhone && !matchesProduct) {
          return false;
        }
      }

      return true;
    }).toList();
  }
}
