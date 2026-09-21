import '../../data/models/sub_category_model.dart';

abstract class SubCategoryRepository {
  Future<List<SubCategoryModel>> getSubCategories({String? categoryId});
  Future<SubCategoryModel> createSubCategory({
    required String categoryId,
    required String name,
    String? description,
    String? image,
  });
  Future<SubCategoryModel> updateSubCategory({
    required String id,
    required String categoryId,
    required String name,
    String? description,
    String? image,
  });
  Future<void> deleteSubCategory(String id);
}
