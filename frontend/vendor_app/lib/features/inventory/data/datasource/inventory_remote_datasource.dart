import '../../../../core/network/api_service.dart';
import '../models/inventory_model.dart';
import '../models/inventory_history_model.dart';

abstract class InventoryRemoteDataSource {
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

class InventoryRemoteDataSourceImpl implements InventoryRemoteDataSource {
  final ApiService _apiService;

  InventoryRemoteDataSourceImpl({required ApiService apiService}) : _apiService = apiService;

  @override
  Future<List<InventoryModel>> getProductInventory(String productId) async {
    final response = await _apiService.get('/vendor/products/$productId/inventory');
    final data = response.data['data'] as List<dynamic>;
    return data.map((json) => InventoryModel.fromJson(json as Map<String, dynamic>)).toList();
  }

  @override
  Future<InventoryModel> updateVariantInventory({
    required String productId,
    required String variantId,
    required int currentStock,
    int? minimumStock,
    String? remarks,
  }) async {
    final payload = <String, dynamic>{
      'currentStock': currentStock,
    };
    if (minimumStock != null) {
      payload['minimumStock'] = minimumStock;
    }
    if (remarks != null && remarks.trim().isNotEmpty) {
      payload['remarks'] = remarks.trim();
    }

    final response = await _apiService.put(
      '/vendor/products/$productId/variants/$variantId/inventory',
      data: payload,
    );

    return InventoryModel.fromJson(response.data['data'] as Map<String, dynamic>);
  }

  @override
  Future<List<InventoryHistoryModel>> getVariantHistory(String productId, String variantId) async {
    final response = await _apiService.get(
      '/vendor/products/$productId/variants/$variantId/inventory/history',
    );

    final data = response.data['data'] as List<dynamic>;
    return data.map((json) => InventoryHistoryModel.fromJson(json as Map<String, dynamic>)).toList();
  }
}
