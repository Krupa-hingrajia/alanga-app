import 'package:equatable/equatable.dart';
import '../../data/models/vendor_order_model.dart';

abstract class VendorOrderState extends Equatable {
  const VendorOrderState();

  @override
  List<Object?> get props => [];
}

class VendorOrderInitial extends VendorOrderState {}

class VendorOrderLoading extends VendorOrderState {}

class VendorOrderLoaded extends VendorOrderState {
  final List<VendorOrderModel> allOrders;
  final List<VendorOrderModel> filteredOrders;
  final String? selectedStatus;
  final String searchQuery;
  final Map<String, int> statusCounts;
  final bool isUpdating;
  final String? updatingOrderId;
  final String? actionMessage;
  final String? errorMessage;

  const VendorOrderLoaded({
    required this.allOrders,
    required this.filteredOrders,
    this.selectedStatus,
    this.searchQuery = '',
    required this.statusCounts,
    this.isUpdating = false,
    this.updatingOrderId,
    this.actionMessage,
    this.errorMessage,
  });

  VendorOrderLoaded copyWith({
    List<VendorOrderModel>? allOrders,
    List<VendorOrderModel>? filteredOrders,
    String? selectedStatus,
    bool clearStatusFilter = false,
    String? searchQuery,
    Map<String, int>? statusCounts,
    bool? isUpdating,
    String? updatingOrderId,
    String? actionMessage,
    bool clearActionMessage = false,
    String? errorMessage,
    bool clearErrorMessage = false,
  }) {
    return VendorOrderLoaded(
      allOrders: allOrders ?? this.allOrders,
      filteredOrders: filteredOrders ?? this.filteredOrders,
      selectedStatus: clearStatusFilter ? null : (selectedStatus ?? this.selectedStatus),
      searchQuery: searchQuery ?? this.searchQuery,
      statusCounts: statusCounts ?? this.statusCounts,
      isUpdating: isUpdating ?? this.isUpdating,
      updatingOrderId: updatingOrderId ?? this.updatingOrderId,
      actionMessage: clearActionMessage ? null : (actionMessage ?? this.actionMessage),
      errorMessage: clearErrorMessage ? null : (errorMessage ?? this.errorMessage),
    );
  }

  @override
  List<Object?> get props => [
        allOrders,
        filteredOrders,
        selectedStatus,
        searchQuery,
        statusCounts,
        isUpdating,
        updatingOrderId,
        actionMessage,
        errorMessage,
      ];
}

class VendorOrderError extends VendorOrderState {
  final String message;

  const VendorOrderError({required this.message});

  @override
  List<Object?> get props => [message];
}
