import '../../domain/repositories/inventory_repository.dart';
import '../datasource/inventory_remote_datasource.dart';
import '../models/inventory_model.dart';
import '../models/inventory_history_model.dart';

class InventoryRepositoryImpl implements InventoryRepository {
  final InventoryRemoteDataSource _remoteDataSource;

  InventoryRepositoryImpl({required InventoryRemoteDataSource remoteDataSource})
      : _remoteDataSource = remoteDataSource;

  @override
  Future<List<InventoryModel>> getProductInventory(String productId) {
    return _remoteDataSource.getProductInventory(productId);
  }

  @override
  Future<InventoryModel> updateVariantInventory({
    required String productId,
    required String variantId,
    required int currentStock,
    int? minimumStock,
    String? remarks,
  }) {
    return _remoteDataSource.updateVariantInventory(
      productId: productId,
      variantId: variantId,
      currentStock: currentStock,
      minimumStock: minimumStock,
      remarks: remarks,
    );
  }

  @override
  Future<List<InventoryHistoryModel>> getVariantHistory(String productId, String variantId) {
    return _remoteDataSource.getVariantHistory(productId, variantId);
  }
}
