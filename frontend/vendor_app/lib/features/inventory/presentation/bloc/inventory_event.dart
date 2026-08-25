import 'package:equatable/equatable.dart';

abstract class InventoryEvent extends Equatable {
  const InventoryEvent();

  @override
  List<Object?> get props => [];
}

class FetchProductInventoryEvent extends InventoryEvent {
  final String productId;
  final bool isRefresh;

  const FetchProductInventoryEvent({required this.productId, this.isRefresh = false});

  @override
  List<Object?> get props => [productId, isRefresh];
}

class SearchInventoryEvent extends InventoryEvent {
  final String query;

  const SearchInventoryEvent({required this.query});

  @override
  List<Object?> get props => [query];
}

class UpdateVariantInventoryEvent extends InventoryEvent {
  final String productId;
  final String variantId;
  final int currentStock;
  final int? minimumStock;
  final String? remarks;

  const UpdateVariantInventoryEvent({
    required this.productId,
    required this.variantId,
    required this.currentStock,
    this.minimumStock,
    this.remarks,
  });

  @override
  List<Object?> get props => [productId, variantId, currentStock, minimumStock, remarks];
}

class FetchVariantHistoryEvent extends InventoryEvent {
  final String productId;
  final String variantId;

  const FetchVariantHistoryEvent({required this.productId, required this.variantId});

  @override
  List<Object?> get props => [productId, variantId];
}
