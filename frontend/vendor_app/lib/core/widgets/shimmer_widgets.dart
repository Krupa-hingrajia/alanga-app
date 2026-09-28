import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

/// A single shimmer-animated rectangle/rounded box.
class ShimmerBox extends StatelessWidget {
  final double? width;
  final double? height;
  final double radius;

  const ShimmerBox({
    super.key,
    this.width,
    this.height,
    this.radius = 8,
  });

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: const Color(0xFFE8EFE9),
      highlightColor: const Color(0xFFF5F9F6),
      child: Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(radius),
        ),
      ),
    );
  }
}

/// Shimmer skeleton for the Dashboard's stats section (4 cards in 2x2 grid).
class DashboardStatsSkeleton extends StatelessWidget {
  const DashboardStatsSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: const Color(0xFFE8EFE9),
      highlightColor: const Color(0xFFF5F9F6),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: GridView.count(
          crossAxisCount: 2,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          childAspectRatio: 1.7,
          children: List.generate(
            4,
            (_) => Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
              ),
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(8))),
                  const Spacer(),
                  Container(
                      width: 60,
                      height: 20,
                      decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(6))),
                  const SizedBox(height: 6),
                  Container(
                      width: 90,
                      height: 12,
                      decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(5))),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Shimmer skeleton for Dashboard pending approvals / activity list rows.
class DashboardListSkeleton extends StatelessWidget {
  final int itemCount;
  const DashboardListSkeleton({super.key, this.itemCount = 3});

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: const Color(0xFFE8EFE9),
      highlightColor: const Color(0xFFF5F9F6),
      child: Column(
        children: List.generate(itemCount, (i) {
          return Container(
            margin: const EdgeInsets.only(bottom: 10),
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Row(
              children: [
                Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(10))),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                          width: double.infinity,
                          height: 13,
                          decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(6))),
                      const SizedBox(height: 7),
                      Container(
                          width: 130,
                          height: 11,
                          decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(5))),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                Container(
                    width: 56,
                    height: 24,
                    decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12))),
              ],
            ),
          );
        }),
      ),
    );
  }
}

/// Shimmer skeleton for the entire Add/Edit Product screen.
/// Accurately mirrors the real multi-step product creation form:
/// - Step 1: Product Classification (Category, Sub Category, Brand)
/// - Step 2: Basic Information (Product Name, Short Description, Full Description)
/// - Step 3: Pricing & Stock (MRP, Selling Price, Tax, Stock)
/// - Step 4: Media & Gallery upload zone
/// - Bottom sticky/action buttons (Save Draft & Submit Product)
class AddProductFormSkeleton extends StatelessWidget {
  const AddProductFormSkeleton({super.key});

  static const _baseColor = Color(0xFFE4EDE7);
  static const _highlightColor = Color(0xFFF7FAF8);

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(16.0, 12.0, 16.0, 28.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // STEP 1: Product Classification
          _buildCard(
            stepNumber: '1',
            titleWidth: 160,
            subtitleWidth: 220,
            children: [
              _buildField(labelWidth: 75, placeholderWidth: 130, hasChevron: true),
              const SizedBox(height: 16),
              _buildField(labelWidth: 100, placeholderWidth: 160, hasChevron: true),
              const SizedBox(height: 16),
              _buildField(labelWidth: 60, placeholderWidth: 120, hasChevron: true),
            ],
          ),
          const SizedBox(height: 16),

          // STEP 2: Basic Information
          _buildCard(
            stepNumber: '2',
            titleWidth: 140,
            subtitleWidth: 210,
            children: [
              _buildField(labelWidth: 105, placeholderWidth: 180),
              const SizedBox(height: 16),
              _buildField(labelWidth: 120, placeholderWidth: 210),
              const SizedBox(height: 16),
              _buildTextarea(labelWidth: 110),
            ],
          ),
          const SizedBox(height: 16),

          // STEP 3: Pricing & Stock
          _buildCard(
            stepNumber: '3',
            titleWidth: 130,
            subtitleWidth: 180,
            children: [
              Row(
                children: [
                  Expanded(child: _buildField(labelWidth: 70, placeholderWidth: 75)),
                  const SizedBox(width: 14),
                  Expanded(child: _buildField(labelWidth: 110, placeholderWidth: 75)),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(child: _buildField(labelWidth: 50, placeholderWidth: 65)),
                  const SizedBox(width: 14),
                  Expanded(child: _buildField(labelWidth: 55, placeholderWidth: 65)),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),

          // STEP 4: Product Images
          _buildCard(
            stepNumber: '4',
            titleWidth: 120,
            subtitleWidth: 190,
            children: [
              Shimmer.fromColors(
                baseColor: _baseColor,
                highlightColor: _highlightColor,
                child: Container(
                  height: 105,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: const Color(0xFFD6E3DC), width: 1.2),
                  ),
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          width: 38,
                          height: 38,
                          decoration: const BoxDecoration(
                            color: Color(0xFFEFF5F1),
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Container(
                          width: 130,
                          height: 11,
                          decoration: BoxDecoration(
                            color: const Color(0xFFEFF5F1),
                            borderRadius: BorderRadius.circular(5),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // ACTION BUTTONS SKELETON
          Shimmer.fromColors(
            baseColor: _baseColor,
            highlightColor: _highlightColor,
            child: Row(
              children: [
                Expanded(
                  child: Container(
                    height: 52,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: const Color(0xFFD6E3DC), width: 1.5),
                    ),
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Container(
                    height: 52,
                    decoration: BoxDecoration(
                      color: const Color(0xFF1A3827).withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCard({
    required String stepNumber,
    required double titleWidth,
    required double subtitleWidth,
    required List<Widget> children,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: const Color(0xFFE6EFEA)),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF1A3827).withValues(alpha: 0.04),
            blurRadius: 18,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Shimmer.fromColors(
            baseColor: _baseColor,
            highlightColor: _highlightColor,
            child: Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: 52,
                        height: 18,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(6),
                        ),
                      ),
                      const SizedBox(height: 6),
                      Container(
                        width: titleWidth,
                        height: 16,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(5),
                        ),
                      ),
                      const SizedBox(height: 5),
                      Container(
                        width: subtitleWidth,
                        height: 11,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          ...children,
        ],
      ),
    );
  }

  Widget _buildField({
    required double labelWidth,
    required double placeholderWidth,
    bool hasChevron = false,
  }) {
    return Shimmer.fromColors(
      baseColor: _baseColor,
      highlightColor: _highlightColor,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: labelWidth,
            height: 12,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(4),
            ),
          ),
          const SizedBox(height: 8),
          Container(
            height: 52,
            padding: const EdgeInsets.symmetric(horizontal: 14),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: const Color(0xFFDCE6DF), width: 1.0),
            ),
            child: Row(
              children: [
                Container(
                  width: 18,
                  height: 18,
                  decoration: BoxDecoration(
                    color: const Color(0xFFEFF5F1),
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
                const SizedBox(width: 10),
                Container(
                  width: placeholderWidth,
                  height: 12,
                  decoration: BoxDecoration(
                    color: const Color(0xFFEFF5F1),
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
                const Spacer(),
                if (hasChevron)
                  Container(
                    width: 14,
                    height: 14,
                    decoration: const BoxDecoration(
                      color: Color(0xFFEFF5F1),
                      shape: BoxShape.circle,
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTextarea({required double labelWidth}) {
    return Shimmer.fromColors(
      baseColor: _baseColor,
      highlightColor: _highlightColor,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: labelWidth,
            height: 12,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(4),
            ),
          ),
          const SizedBox(height: 8),
          Container(
            height: 86,
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: const Color(0xFFDCE6DF), width: 1.0),
            ),
            child: Align(
              alignment: Alignment.topLeft,
              child: Container(
                width: 170,
                height: 12,
                decoration: BoxDecoration(
                  color: const Color(0xFFEFF5F1),
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Shimmer skeleton for the Add Product dropdowns section (backwards compatibility).
class DropdownSkeleton extends StatelessWidget {
  final int itemCount;
  const DropdownSkeleton({super.key, this.itemCount = 3});

  @override
  Widget build(BuildContext context) {
    return const AddProductFormSkeleton();
  }
}

/// Shimmer skeleton for Inventory Management list
class InventoryListSkeleton extends StatelessWidget {
  final int itemCount;
  const InventoryListSkeleton({super.key, this.itemCount = 4});

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: const Color(0xFFE8EFE9),
      highlightColor: const Color(0xFFF5F9F6),
      child: ListView.separated(
        padding: const EdgeInsets.all(16),
        physics: const NeverScrollableScrollPhysics(),
        itemCount: itemCount,
        separatorBuilder: (_, index) => const SizedBox(height: 12),
        itemBuilder: (_, index) {
          return Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(18),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            width: 140,
                            height: 15,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(6),
                            ),
                          ),
                          const SizedBox(height: 8),
                          Container(
                            width: 90,
                            height: 12,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(5),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      width: 60,
                      height: 24,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                Container(
                  height: 38,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

/// Shimmer skeleton for Shipping Management screen
class ShippingScreenSkeleton extends StatelessWidget {
  const ShippingScreenSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: const Color(0xFFE8EFE9),
      highlightColor: const Color(0xFFF5F9F6),
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        physics: const NeverScrollableScrollPhysics(),
        child: Column(
          children: [
            Container(
              height: 130,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(18),
              ),
            ),
            const SizedBox(height: 16),
            Container(
              height: 110,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(18),
              ),
            ),
            const SizedBox(height: 16),
            Container(
              height: 280,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(18),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
