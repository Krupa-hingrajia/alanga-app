import '../../data/models/inventory_model.dart';
import '../../data/models/inventory_history_model.dart';

abstract class InventoryRepository {
  Future<List<InventoryModel>> getProductInventory(String productId);
  Future<InventoryModel> updateVariantInventory({
    required String productId,
    required String variantId,
    required int currentStock,
    int? minimumStock,
    String? remarks,
  });
  Future<List<InventoryHistoryModel>> getVariantHistory(String productId, String variantId);
}
