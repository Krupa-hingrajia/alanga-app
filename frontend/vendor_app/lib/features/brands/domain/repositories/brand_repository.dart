import '../../data/models/brand_model.dart';

abstract class BrandRepository {
  Future<List<BrandModel>> getBrands();
  Future<BrandModel> requestBrand({
    required String name,
    String? description,
    String? logo,
  });
  Future<BrandModel> createBrand({
    required String name,
    String? description,
    String? image,
  });
  Future<BrandModel> updateBrand({
    required String id,
    required String name,
    String? description,
    String? image,
  });
  Future<void> deleteBrand(String id);
}
