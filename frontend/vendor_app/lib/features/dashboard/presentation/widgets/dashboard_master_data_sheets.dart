import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../brands/data/models/brand_model.dart';
import '../../../categories/data/models/category_model.dart';
import '../../../sub_categories/data/models/sub_category_model.dart';
import '../../../brands/presentation/widgets/request_brand_bottom_sheet.dart';

class DashboardMasterDataSheets {
  static void showCategoriesBottomSheet(
    BuildContext context, {
    required List<CategoryModel> categories,
    required List<SubCategoryModel> subCategories,
  }) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        final searchCtrl = TextEditingController();

        return StatefulBuilder(
          builder: (ctx, setModalState) {
            final query = searchCtrl.text.trim().toLowerCase();
            final filteredCategories = categories.where((cat) {
              final matchesCat = cat.name.toLowerCase().contains(query);
              final matchesSubCat = subCategories
                  .where((sc) => sc.categoryId == cat.id)
                  .any((sc) => sc.name.toLowerCase().contains(query));
              return matchesCat || matchesSubCat;
            }).toList();

            return Container(
              constraints: BoxConstraints(
                maxHeight: MediaQuery.of(context).size.height * 0.8,
              ),
              padding: EdgeInsets.only(
                left: 20,
                right: 20,
                top: 16,
                bottom: MediaQuery.of(ctx).viewInsets.bottom + 16,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      width: 38,
                      height: 4,
                      decoration: BoxDecoration(
                        color: Colors.grey.shade300,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Row(
                          children: [
                            const Icon(Icons.grid_view_rounded, color: Colors.purple),
                            const SizedBox(width: 8),
                            Flexible(
                              child: Text(
                                'Marketplace Categories (${categories.length})',
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF11261B),
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        onPressed: () => Navigator.pop(ctx),
                        icon: const Icon(Icons.close, color: Colors.grey),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'Master categories managed by Admin for marketplace product placement.',
                    style: TextStyle(fontSize: 12, color: AppColors.textSecondaryLight),
                  ),
                  const SizedBox(height: 14),

                  // Search Bar
                  Container(
                    decoration: BoxDecoration(
                      color: const Color(0xFFF3F6F4),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: const Color(0xFFDDE8E1)),
                    ),
                    child: TextField(
                      controller: searchCtrl,
                      onChanged: (_) => setModalState(() {}),
                      style: const TextStyle(fontSize: 13.5, color: Color(0xFF11261B)),
                      decoration: InputDecoration(
                        hintText: 'Search categories or sub-categories...',
                        hintStyle: const TextStyle(fontSize: 13, color: Color(0xFF7A9A86)),
                        prefixIcon: const Icon(Icons.search_rounded, size: 18, color: Color(0xFF7A9A86)),
                        suffixIcon: searchCtrl.text.isNotEmpty
                            ? GestureDetector(
                                onTap: () {
                                  searchCtrl.clear();
                                  setModalState(() {});
                                },
                                child: const Icon(Icons.close_rounded, size: 18, color: Color(0xFF7A9A86)),
                              )
                            : null,
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
                      ),
                    ),
                  ),
                  const SizedBox(height: 14),

                  Expanded(
                    child: filteredCategories.isEmpty
                        ? const Center(
                            child: Text(
                              'No matching categories found',
                              style: TextStyle(color: Colors.grey, fontSize: 13),
                            ),
                          )
                        : ListView.separated(
                            itemCount: filteredCategories.length,
                            separatorBuilder: (_, __) => const Divider(height: 1, color: Color(0xFFEFEFEF)),
                            itemBuilder: (ctx, index) {
                              final cat = filteredCategories[index];
                              final subCatsForCat = subCategories.where((sc) => sc.categoryId == cat.id).toList();

                              return ExpansionTile(
                                leading: Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: Colors.purple.withValues(alpha: 0.1),
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: const Icon(Icons.category_outlined, color: Colors.purple, size: 20),
                                ),
                                title: Text(
                                  cat.name,
                                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Color(0xFF11261B)),
                                ),
                                subtitle: Text(
                                  '${subCatsForCat.length} Sub Categories',
                                  style: const TextStyle(fontSize: 12, color: AppColors.textSecondaryLight),
                                ),
                                children: subCatsForCat.isEmpty
                                    ? [
                                        const Padding(
                                          padding: EdgeInsets.all(12.0),
                                          child: Text('No Sub Categories under this category.', style: TextStyle(fontSize: 12, color: Colors.grey)),
                                        )
                                      ]
                                    : subCatsForCat.map((sc) {
                                        return ListTile(
                                          contentPadding: const EdgeInsets.only(left: 48, right: 16),
                                          dense: true,
                                          leading: const Icon(Icons.subdirectory_arrow_right_rounded, size: 16, color: Colors.teal),
                                          title: Text(sc.name, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500)),
                                        );
                                      }).toList(),
                              );
                            },
                          ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  static void showSubCategoriesBottomSheet(
    BuildContext context, {
    required List<CategoryModel> categories,
    required List<SubCategoryModel> subCategories,
  }) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        final searchCtrl = TextEditingController();

        return StatefulBuilder(
          builder: (ctx, setModalState) {
            final query = searchCtrl.text.trim().toLowerCase();
            final filteredSubCategories = subCategories.where((sc) {
              final matchesSubCat = sc.name.toLowerCase().contains(query);
              final parentCat = categories.firstWhere(
                (c) => c.id == sc.categoryId,
                orElse: () => CategoryModel(id: '', name: '', status: 'APPROVED', createdAt: DateTime.now(), updatedAt: DateTime.now()),
              );
              final matchesParentCat = parentCat.name.toLowerCase().contains(query);
              return matchesSubCat || matchesParentCat;
            }).toList();

            return Container(
              constraints: BoxConstraints(
                maxHeight: MediaQuery.of(context).size.height * 0.8,
              ),
              padding: EdgeInsets.only(
                left: 20,
                right: 20,
                top: 16,
                bottom: MediaQuery.of(ctx).viewInsets.bottom + 16,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      width: 38,
                      height: 4,
                      decoration: BoxDecoration(
                        color: Colors.grey.shade300,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Row(
                          children: [
                            const Icon(Icons.folder_copy_outlined, color: Colors.teal),
                            const SizedBox(width: 8),
                            Flexible(
                              child: Text(
                                'Sub Categories (${subCategories.length})',
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF11261B),
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        onPressed: () => Navigator.pop(ctx),
                        icon: const Icon(Icons.close, color: Colors.grey),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'Active Sub Categories available for product assignment.',
                    style: TextStyle(fontSize: 12, color: AppColors.textSecondaryLight),
                  ),
                  const SizedBox(height: 14),

                  // Search Bar
                  Container(
                    decoration: BoxDecoration(
                      color: const Color(0xFFF3F6F4),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: const Color(0xFFDDE8E1)),
                    ),
                    child: TextField(
                      controller: searchCtrl,
                      onChanged: (_) => setModalState(() {}),
                      style: const TextStyle(fontSize: 13.5, color: Color(0xFF11261B)),
                      decoration: InputDecoration(
                        hintText: 'Search sub-categories...',
                        hintStyle: const TextStyle(fontSize: 13, color: Color(0xFF7A9A86)),
                        prefixIcon: const Icon(Icons.search_rounded, size: 18, color: Color(0xFF7A9A86)),
                        suffixIcon: searchCtrl.text.isNotEmpty
                            ? GestureDetector(
                                onTap: () {
                                  searchCtrl.clear();
                                  setModalState(() {});
                                },
                                child: const Icon(Icons.close_rounded, size: 18, color: Color(0xFF7A9A86)),
                              )
                            : null,
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
                      ),
                    ),
                  ),
                  const SizedBox(height: 14),

                  Expanded(
                    child: filteredSubCategories.isEmpty
                        ? const Center(
                            child: Text(
                              'No matching sub-categories found',
                              style: TextStyle(color: Colors.grey, fontSize: 13),
                            ),
                          )
                        : ListView.separated(
                            itemCount: filteredSubCategories.length,
                            separatorBuilder: (_, __) => const Divider(height: 1, color: Color(0xFFEFEFEF)),
                            itemBuilder: (ctx, index) {
                              final sc = filteredSubCategories[index];
                              final parentCat = categories.firstWhere(
                                (c) => c.id == sc.categoryId,
                                orElse: () => CategoryModel(id: '', name: 'Master Category', status: 'APPROVED', createdAt: DateTime.now(), updatedAt: DateTime.now()),
                              );

                              return ListTile(
                                leading: Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: Colors.teal.withValues(alpha: 0.1),
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: const Icon(Icons.folder_outlined, color: Colors.teal, size: 20),
                                ),
                                title: Text(
                                  sc.name,
                                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Color(0xFF11261B)),
                                ),
                                subtitle: Text(
                                  'Parent Category: ${parentCat.name}',
                                  style: const TextStyle(fontSize: 12, color: AppColors.textSecondaryLight),
                                ),
                              );
                            },
                          ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  static void showBrandsBottomSheet(
    BuildContext context, {
    required List<BrandModel> brands,
    required VoidCallback onRefresh,
  }) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        final searchCtrl = TextEditingController();

        return StatefulBuilder(
          builder: (ctx, setModalState) {
            final query = searchCtrl.text.trim().toLowerCase();
            final filteredBrands = brands.where((b) {
              final matchesName = b.name.toLowerCase().contains(query);
              final matchesDesc = b.description?.toLowerCase().contains(query) ?? false;
              return matchesName || matchesDesc;
            }).toList();

            return Container(
              constraints: BoxConstraints(
                maxHeight: MediaQuery.of(context).size.height * 0.85,
              ),
              padding: EdgeInsets.only(
                left: 20,
                right: 20,
                top: 16,
                bottom: MediaQuery.of(ctx).viewInsets.bottom + 16,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      width: 38,
                      height: 4,
                      decoration: BoxDecoration(
                        color: Colors.grey.shade300,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Row(
                          children: [
                            const Icon(Icons.label_outline_rounded, color: AppColors.brandOrange),
                            const SizedBox(width: 8),
                            Flexible(
                              child: Text(
                                'Marketplace Brands (${brands.length})',
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF11261B),
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        onPressed: () => Navigator.pop(ctx),
                        icon: const Icon(Icons.close, color: Colors.grey),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'Active marketplace brands. If your brand is not listed, submit a request below.',
                    style: TextStyle(fontSize: 12, color: AppColors.textSecondaryLight),
                  ),
                  const SizedBox(height: 14),

                  // Search Bar
                  Container(
                    decoration: BoxDecoration(
                      color: const Color(0xFFF3F6F4),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: const Color(0xFFDDE8E1)),
                    ),
                    child: TextField(
                      controller: searchCtrl,
                      onChanged: (_) => setModalState(() {}),
                      style: const TextStyle(fontSize: 13.5, color: Color(0xFF11261B)),
                      decoration: InputDecoration(
                        hintText: 'Search marketplace brands...',
                        hintStyle: const TextStyle(fontSize: 13, color: Color(0xFF7A9A86)),
                        prefixIcon: const Icon(Icons.search_rounded, size: 18, color: Color(0xFF7A9A86)),
                        suffixIcon: searchCtrl.text.isNotEmpty
                            ? GestureDetector(
                                onTap: () {
                                  searchCtrl.clear();
                                  setModalState(() {});
                                },
                                child: const Icon(Icons.close_rounded, size: 18, color: Color(0xFF7A9A86)),
                              )
                            : null,
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
                      ),
                    ),
                  ),
                  const SizedBox(height: 14),

                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      onPressed: () {
                        Navigator.pop(ctx);
                        RequestBrandBottomSheet.show(context, onRequestSubmitted: onRefresh);
                      },
                      icon: const Icon(Icons.add_circle_outline_rounded, size: 18),
                      label: const Text('Request New Brand'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: const Color(0xFF1A3827),
                        side: const BorderSide(color: Color(0xFF1A3827), width: 1.2),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                    ),
                  ),
                  const SizedBox(height: 14),
                  Expanded(
                    child: filteredBrands.isEmpty
                        ? const Center(
                            child: Text(
                              'No matching brands found',
                              style: TextStyle(color: Colors.grey, fontSize: 13),
                            ),
                          )
                        : ListView.separated(
                            itemCount: filteredBrands.length,
                            separatorBuilder: (_, __) => const Divider(height: 1, color: Color(0xFFEFEFEF)),
                            itemBuilder: (ctx, index) {
                              final brand = filteredBrands[index];
                              return ListTile(
                                leading: brand.image != null && brand.image!.isNotEmpty
                                    ? ClipRRect(
                                        borderRadius: BorderRadius.circular(8),
                                        child: Image.network(
                                          brand.image!,
                                          width: 36,
                                          height: 36,
                                          fit: BoxFit.cover,
                                          errorBuilder: (ctx, err, stack) => Container(
                                            width: 36,
                                            height: 36,
                                            color: AppColors.brandOrange.withValues(alpha: 0.1),
                                            child: const Icon(Icons.label, color: AppColors.brandOrange, size: 20),
                                          ),
                                        ),
                                      )
                                    : Container(
                                        width: 36,
                                        height: 36,
                                        decoration: BoxDecoration(
                                          color: AppColors.brandOrange.withValues(alpha: 0.1),
                                          borderRadius: BorderRadius.circular(8),
                                        ),
                                        child: const Icon(Icons.label_outline, color: AppColors.brandOrange, size: 20),
                                      ),
                                title: Text(
                                  brand.name,
                                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Color(0xFF11261B)),
                                ),
                                subtitle: brand.description != null && brand.description!.isNotEmpty
                                    ? Text(
                                        brand.description!,
                                        style: const TextStyle(fontSize: 12, color: AppColors.textSecondaryLight),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      )
                                    : null,
                              );
                            },
                          ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}
