import '../../domain/repositories/shipping_repository.dart';
import '../datasource/shipping_remote_datasource.dart';
import '../models/product_shipping_model.dart';

class ShippingRepositoryImpl implements ShippingRepository {
  final ShippingRemoteDataSource _remoteDataSource;

  ShippingRepositoryImpl({required ShippingRemoteDataSource remoteDataSource})
      : _remoteDataSource = remoteDataSource;

  @override
  Future<ProductShippingModel?> getShipping(String productId) {
    return _remoteDataSource.getShipping(productId);
  }

  @override
  Future<ProductShippingModel> saveShipping(String productId, ProductShippingModel model) {
    return _remoteDataSource.saveShipping(productId, model);
  }
}
