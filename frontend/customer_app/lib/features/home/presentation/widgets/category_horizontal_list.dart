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
    // Curated brand-matched fallback categories
    final List<Map<String, dynamic>> fallbackCategories = [
      {'name': 'Groceries', 'icon': Icons.shopping_basket_rounded, 'gradient': [Color(0xFFE8F5E9), Color(0xFFC8E6C9)]},
      {'name': 'Fresh Veggies', 'icon': Icons.eco_rounded, 'gradient': [Color(0xFFF1F8E9), Color(0xFFDCEDC8)]},
      {'name': 'Dairy & Bread', 'icon': Icons.egg_alt_rounded, 'gradient': [Color(0xFFFFF8E1), Color(0xFFFFECB3)]},
      {'name': 'Fruits & Juices', 'icon': Icons.lunch_dining_rounded, 'gradient': [Color(0xFFFBE9E7), Color(0xFFFFCCBC)]},
      {'name': 'Snacks & Drinks', 'icon': Icons.local_cafe_rounded, 'gradient': [Color(0xFFEDE7F6), Color(0xFFD1C4E9)]},
      {'name': 'Personal Care', 'icon': Icons.clean_hands_rounded, 'gradient': [Color(0xFFE0F7FA), Color(0xFFB2EBF2)]},
      {'name': 'Home Essentials', 'icon': Icons.home_mini_rounded, 'gradient': [Color(0xFFFFF3E0), Color(0xFFFFE0B2)]},
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
              Row(
                children: [
                  Container(
                    width: 4,
                    height: 18,
                    decoration: BoxDecoration(
                      gradient: AppColors.logoRibbonGradient,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  const SizedBox(width: 8),
                  const Text(
                    'Explore Categories',
                    style: TextStyle(
                      fontSize: 16.5,
                      fontWeight: FontWeight.w900,
                      color: Color(0xFF0C2417),
                      letterSpacing: -0.2,
                    ),
                  ),
                ],
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
                        fontSize: 12.5,
                        fontWeight: FontWeight.w800,
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

        // Horizontal Category Carousel
        SizedBox(
          height: 104,
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            scrollDirection: Axis.horizontal,
            itemCount: hasRealCategories ? categories.length : fallbackCategories.length,
            itemBuilder: (context, index) {
              if (hasRealCategories) {
                final category = categories[index];
                return Container(
                  width: 76,
                  margin: const EdgeInsets.symmetric(horizontal: 6),
                  child: InkWell(
                    onTap: () {
                      context.push('/categories/products', extra: category);
                    },
                    borderRadius: BorderRadius.circular(38),
                    child: Column(
                      children: [
                        // Logo ribbon ambient ring
                        Container(
                          width: 66,
                          height: 66,
                          padding: const EdgeInsets.all(2.5),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: LinearGradient(
                              colors: [
                                AppColors.primaryGreen.withValues(alpha: 0.6),
                                AppColors.ribbonAmber.withValues(alpha: 0.4),
                              ],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: AppColors.darkGreen.withValues(alpha: 0.08),
                                blurRadius: 10,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Container(
                            decoration: const BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colors.white,
                            ),
                            padding: const EdgeInsets.all(2),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(30),
                              child: CustomImageView(
                                imageUrl: category.image,
                                fit: BoxFit.cover,
                                placeholderIcon: Icons.category_rounded,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 7),
                        Text(
                          category.name,
                          textAlign: TextAlign.center,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 11.5,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF0C2417),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              } else {
                final item = fallbackCategories[index];
                final grad = item['gradient'] as List<Color>;
                return Container(
                  width: 76,
                  margin: const EdgeInsets.symmetric(horizontal: 6),
                  child: InkWell(
                    onTap: () {
                      context.push('/products', extra: item['name'] as String);
                    },
                    borderRadius: BorderRadius.circular(38),
                    child: Column(
                      children: [
                        Container(
                          width: 66,
                          height: 66,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: LinearGradient(
                              colors: grad,
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            border: Border.all(color: Colors.white, width: 2),
                            boxShadow: [
                              BoxShadow(
                                color: AppColors.darkGreen.withValues(alpha: 0.08),
                                blurRadius: 8,
                                offset: const Offset(0, 3),
                              ),
                            ],
                          ),
                          child: Icon(
                            item['icon'] as IconData,
                            color: const Color(0xFF0C2417),
                            size: 26,
                          ),
                        ),
                        const SizedBox(height: 7),
                        Text(
                          item['name'] as String,
                          textAlign: TextAlign.center,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 11.5,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF0C2417),
                          ),
                        ),
                      ],
                    ),
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
