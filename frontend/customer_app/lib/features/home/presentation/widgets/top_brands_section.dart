import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/widgets/custom_image_view.dart';
import '../../../products/data/models/brand_model.dart';

class TopBrandsSection extends StatelessWidget {
  final List<BrandModel> brands;

  const TopBrandsSection({
    super.key,
    required this.brands,
  });

  @override
  Widget build(BuildContext context) {
    if (brands.isEmpty) {
      return const SizedBox();
    }

    final brandColors = [
      const Color(0xFF1E3A8A),
      const Color(0xFF047857),
      const Color(0xFF991B1B),
      const Color(0xFF4C1D95),
      const Color(0xFFD97706),
      const Color(0xFF0284C7),
      const Color(0xFFBE185D),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Section Header
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Row(
                children: [
                  Icon(
                    Icons.stars_rounded,
                    color: AppColors.brandOrange,
                    size: 20,
                  ),
                  SizedBox(width: 6),
                  Text(
                    'Top Brands',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF11261B),
                      letterSpacing: -0.2,
                    ),
                  ),
                ],
              ),
              TextButton(
                onPressed: () => context.push('/products'),
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

        // Dynamic Brand Avatars List
        SizedBox(
          height: 96,
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            scrollDirection: Axis.horizontal,
            itemCount: brands.length,
            itemBuilder: (context, index) {
              final brand = brands[index];
              final themeColor = brandColors[index % brandColors.length];
              final initial = brand.name.isNotEmpty ? brand.name[0].toUpperCase() : 'B';

              return InkWell(
                onTap: () {
                  context.push('/products', extra: brand.name);
                },
                borderRadius: BorderRadius.circular(30),
                child: Container(
                  width: 78,
                  margin: const EdgeInsets.symmetric(horizontal: 6),
                  child: Column(
                    children: [
                      Container(
                        width: 60,
                        height: 60,
                        padding: const EdgeInsets.all(3),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.white,
                          border: Border.all(
                            color: themeColor.withValues(alpha: 0.25),
                            width: 1.5,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: themeColor.withValues(alpha: 0.12),
                              blurRadius: 8,
                              offset: const Offset(0, 3),
                            ),
                          ],
                        ),
                        child: ClipOval(
                          child: (brand.image != null && brand.image!.trim().isNotEmpty)
                              ? CustomImageView(
                                  imageUrl: brand.image,
                                  width: 54,
                                  height: 54,
                                  fit: BoxFit.cover,
                                  placeholderIcon: Icons.storefront_rounded,
                                )
                              : Container(
                                  color: themeColor.withValues(alpha: 0.12),
                                  child: Center(
                                    child: Text(
                                      initial,
                                      style: TextStyle(
                                        fontSize: 22,
                                        fontWeight: FontWeight.w900,
                                        color: themeColor,
                                      ),
                                    ),
                                  ),
                                ),
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        brand.name,
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
            },
          ),
        ),
      ],
    );
  }
}
