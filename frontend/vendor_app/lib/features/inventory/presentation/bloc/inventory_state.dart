import 'package:equatable/equatable.dart';
import '../../data/models/inventory_model.dart';
import '../../data/models/inventory_history_model.dart';

abstract class InventoryState extends Equatable {
  const InventoryState();

  @override
  List<Object?> get props => [];
}

class InventoryInitial extends InventoryState {}

class InventoryLoading extends InventoryState {}

class InventoryLoaded extends InventoryState {
  final List<InventoryModel> inventories;
  final List<InventoryModel> filteredInventories;
  final String searchQuery;

  const InventoryLoaded({
    required this.inventories,
    required this.filteredInventories,
    this.searchQuery = '',
  });

  InventoryLoaded copyWith({
    List<InventoryModel>? inventories,
    List<InventoryModel>? filteredInventories,
    String? searchQuery,
  }) {
    return InventoryLoaded(
      inventories: inventories ?? this.inventories,
      filteredInventories: filteredInventories ?? this.filteredInventories,
      searchQuery: searchQuery ?? this.searchQuery,
    );
  }

  @override
  List<Object?> get props => [inventories, filteredInventories, searchQuery];
}

class InventoryUpdating extends InventoryState {
  final String variantId;

  const InventoryUpdating({required this.variantId});

  @override
  List<Object?> get props => [variantId];
}

class InventoryUpdated extends InventoryState {
  final InventoryModel updatedInventory;
  final String message;

  const InventoryUpdated({required this.updatedInventory, required this.message});

  @override
  List<Object?> get props => [updatedInventory, message];
}

class InventoryHistoryLoading extends InventoryState {}

class InventoryHistoryLoaded extends InventoryState {
  final List<InventoryHistoryModel> history;

  const InventoryHistoryLoaded({required this.history});

  @override
  List<Object?> get props => [history];
}

class InventoryError extends InventoryState {
  final String message;

  const InventoryError({required this.message});

  @override
  List<Object?> get props => [message];
}
