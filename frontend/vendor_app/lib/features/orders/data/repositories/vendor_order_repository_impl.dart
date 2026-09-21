import '../../domain/repositories/vendor_order_repository.dart';
import '../datasource/vendor_order_remote_datasource.dart';
import '../models/vendor_order_model.dart';

class VendorOrderRepositoryImpl implements VendorOrderRepository {
  final VendorOrderRemoteDataSource _remoteDataSource;

  VendorOrderRepositoryImpl({required VendorOrderRemoteDataSource remoteDataSource})
      : _remoteDataSource = remoteDataSource;

  @override
  Future<List<VendorOrderModel>> getOrders() async {
    try {
      return await _remoteDataSource.getVendorOrders();
    } catch (e) {
      throw Exception(e.toString().replaceAll('Exception: ', ''));
    }
  }

  @override
  Future<VendorOrderModel> updateOrderStatus({
    required String orderId,
    required String status,
  }) async {
    try {
      return await _remoteDataSource.updateOrderStatus(
        orderId: orderId,
        status: status,
      );
    } catch (e) {
      throw Exception(e.toString().replaceAll('Exception: ', ''));
    }
  }
}
