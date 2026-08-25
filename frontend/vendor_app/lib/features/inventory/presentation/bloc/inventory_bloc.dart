import 'package:flutter_bloc/flutter_bloc.dart';
import 'inventory_event.dart';
import 'inventory_state.dart';
import '../../domain/repositories/inventory_repository.dart';
import '../../data/models/inventory_model.dart';

class InventoryBloc extends Bloc<InventoryEvent, InventoryState> {
  final InventoryRepository _inventoryRepository;

  List<InventoryModel> _allInventories = [];

  InventoryBloc({required InventoryRepository inventoryRepository})
      : _inventoryRepository = inventoryRepository,
        super(InventoryInitial()) {
    on<FetchProductInventoryEvent>(_onFetchProductInventory);
    on<SearchInventoryEvent>(_onSearchInventory);
    on<UpdateVariantInventoryEvent>(_onUpdateVariantInventory);
    on<FetchVariantHistoryEvent>(_onFetchVariantHistory);
  }

  Future<void> _onFetchProductInventory(
    FetchProductInventoryEvent event,
    Emitter<InventoryState> emit,
  ) async {
    if (!event.isRefresh) {
      emit(InventoryLoading());
    }
    try {
      final inventories = await _inventoryRepository.getProductInventory(event.productId);
      _allInventories = inventories;
      emit(InventoryLoaded(
        inventories: _allInventories,
        filteredInventories: _allInventories,
      ));
    } catch (e) {
      emit(InventoryError(message: e.toString().replaceAll('Exception: ', '')));
    }
  }

  void _onSearchInventory(
    SearchInventoryEvent event,
    Emitter<InventoryState> emit,
  ) {
    final query = event.query.toLowerCase().trim();
    if (state is InventoryLoaded) {
      if (query.isEmpty) {
        emit((state as InventoryLoaded).copyWith(
          filteredInventories: _allInventories,
          searchQuery: '',
        ));
      } else {
        final filtered = _allInventories.where((inv) {
          final skuMatch = inv.sku.toLowerCase().contains(query);
          final nameMatch = inv.variant.variantName.toLowerCase().contains(query);
          return skuMatch || nameMatch;
        }).toList();

        emit((state as InventoryLoaded).copyWith(
          filteredInventories: filtered,
          searchQuery: query,
        ));
      }
    }
  }

  Future<void> _onUpdateVariantInventory(
    UpdateVariantInventoryEvent event,
    Emitter<InventoryState> emit,
  ) async {
    emit(InventoryUpdating(variantId: event.variantId));
    try {
      final updated = await _inventoryRepository.updateVariantInventory(
        productId: event.productId,
        variantId: event.variantId,
        currentStock: event.currentStock,
        minimumStock: event.minimumStock,
        remarks: event.remarks,
      );

      // Refresh full list locally
      final updatedList = _allInventories.map((item) {
        if (item.variant.id == event.variantId) {
          return updated;
        }
        return item;
      }).toList();
      _allInventories = updatedList;

      emit(InventoryUpdated(
        updatedInventory: updated,
        message: 'Inventory updated successfully!',
      ));

      // Emit re-loaded state immediately
      emit(InventoryLoaded(
        inventories: _allInventories,
        filteredInventories: _allInventories,
      ));
    } catch (e) {
      emit(InventoryError(message: e.toString().replaceAll('Exception: ', '')));
    }
  }

  Future<void> _onFetchVariantHistory(
    FetchVariantHistoryEvent event,
    Emitter<InventoryState> emit,
  ) async {
    emit(InventoryHistoryLoading());
    try {
      final history = await _inventoryRepository.getVariantHistory(
        event.productId,
        event.variantId,
      );
      emit(InventoryHistoryLoaded(history: history));
    } catch (e) {
      emit(InventoryError(message: e.toString().replaceAll('Exception: ', '')));
    }
  }
}
