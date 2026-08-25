import '../../data/models/category_model.dart';

abstract class CategoryRepository {
  Future<List<CategoryModel>> getCategories();
  Future<CategoryModel> createCategory({
    required String name,
    String? description,
    String? image,
  });
  Future<CategoryModel> updateCategory({
    required String id,
    required String name,
    String? description,
    String? image,
  });
  Future<void> deleteCategory(String id);
}
