import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/widgets/custom_image_view.dart';
import '../../../categories/data/models/category_model.dart';

class CategoryHorizontalList extends StatelessWidget {
  final List<CategoryModel> categories;
  final VoidCallback? onViewAllTap;

  const CategoryHorizontalList({
    super.key,
    required this.categories,
    this.onViewAllTap,
  });

  @override
  Widget build(BuildContext context) {
    // Default fallback categories if empty
    final List<Map<String, dynamic>> fallbackCategories = [
      {'name': 'Beauty', 'icon': Icons.face_retouching_natural_rounded, 'color': const Color(0xFFFCE7F3)},
      {'name': 'Fashion', 'icon': Icons.checkroom_rounded, 'color': const Color(0xFFE0E7FF)},
      {'name': 'Electronics', 'icon': Icons.devices_other_rounded, 'color': const Color(0xFFFEF3C7)},
      {'name': 'Groceries', 'icon': Icons.shopping_basket_rounded, 'color': const Color(0xFFD1FAE5)},
      {'name': 'Home', 'icon': Icons.home_mini_rounded, 'color': const Color(0xFFF3E8FF)},
      {'name': 'Sports', 'icon': Icons.sports_soccer_rounded, 'color': const Color(0xFFFFEDD5)},
      {'name': 'Books', 'icon': Icons.menu_book_rounded, 'color': const Color(0xFFE0F2FE)},
    ];

    final hasRealCategories = categories.isNotEmpty;

    return Column(
      children: [
        // Section Header
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Shop by Category',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF11261B),
                  letterSpacing: -0.2,
                ),
              ),
              TextButton(
                onPressed: onViewAllTap,
                style: TextButton.styleFrom(
                  padding: EdgeInsets.zero,
                  minimumSize: Size.zero,
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
                child: const Row(
                  children: [
                    Text(
                      'View All',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primaryGreen,
                      ),
                    ),
                    Icon(
                      Icons.chevron_right_rounded,
                      size: 16,
                      color: AppColors.primaryGreen,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),

        // Horizontal Category List
        SizedBox(
          height: 95,
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            scrollDirection: Axis.horizontal,
            itemCount: hasRealCategories ? categories.length : fallbackCategories.length,
            itemBuilder: (context, index) {
              if (hasRealCategories) {
                final category = categories[index];
                return Container(
                  width: 72,
                  margin: const EdgeInsets.symmetric(horizontal: 6),
                  child: InkWell(
                    onTap: () {
                      context.push('/categories/products', extra: category);
                    },
                    borderRadius: BorderRadius.circular(36),
                    child: Column(
                      children: [
                        Container(
                          width: 62,
                          height: 62,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: const LinearGradient(
                              colors: [Color(0xFFE6F4EB), Color(0xFFFFFFFF)],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            border: Border.all(color: AppColors.primaryGreen.withValues(alpha: 0.3), width: 1.5),
                            boxShadow: [
                              BoxShadow(
                                color: AppColors.darkGreen.withValues(alpha: 0.05),
                                blurRadius: 8,
                                offset: const Offset(0, 3),
                              ),
                            ],
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(30),
                            child: CustomImageView(
                              imageUrl: category.image,
                              fit: BoxFit.cover,
                              placeholderIcon: Icons.category_rounded,
                            ),
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          category.name,
                          textAlign: TextAlign.center,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF11261B),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              } else {
                final item = fallbackCategories[index];
                return Container(
                  width: 72,
                  margin: const EdgeInsets.symmetric(horizontal: 6),
                  child: Column(
                    children: [
                      Container(
                        width: 62,
                        height: 62,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: item['color'] as Color,
                          border: Border.all(color: Colors.white, width: 2),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.04),
                              blurRadius: 6,
                            ),
                          ],
                        ),
                        child: Icon(
                          item['icon'] as IconData,
                          color: AppColors.darkGreen,
                          size: 26,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        item['name'] as String,
                        textAlign: TextAlign.center,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF11261B),
                        ),
                      ),
                    ],
                  ),
                );
              }
            },
          ),
        ),
      ],
    );
  }
}
