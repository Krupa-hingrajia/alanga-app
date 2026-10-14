import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../data/models/category_model.dart';
import '../../../products/presentation/bloc/product_bloc.dart';
import '../../../products/presentation/bloc/product_event.dart';
import '../../../products/presentation/bloc/product_state.dart';
import '../../../products/presentation/widgets/product_card.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/dependency_injection/injection.dart';
import '../../../../core/widgets/shimmer_effect.dart';

class CategoryProductsScreen extends StatelessWidget {
  final CategoryModel category;

  const CategoryProductsScreen({super.key, required this.category});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<ProductBloc>()..add(const FetchProductsEvent()),
      child: Scaffold(
        backgroundColor: const Color(0xFFF7FAF8),
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          title: Text(
            category.name,
            style: const TextStyle(
              color: Color(0xFF11261B),
              fontWeight: FontWeight.bold,
              fontSize: 18,
            ),
          ),
          centerTitle: true,
          iconTheme: const IconThemeData(color: Color(0xFF11261B)),
        ),
        body: BlocBuilder<ProductBloc, ProductState>(
          builder: (context, state) {
            if (state is ProductLoading) {
              return _buildProductGridShimmer();
            } else if (state is ProductLoaded) {
              final list = state.products
                  .where((p) => p.categoryId == category.id && p.status.toUpperCase() == 'ACTIVE')
                  .toList();

              if (list.isEmpty) {
                return _buildEmptyState();
              }

              return RefreshIndicator(
                color: AppColors.brandOrange,
                backgroundColor: Colors.white,
                onRefresh: () async {
                  context.read<ProductBloc>().add(const FetchProductsEvent(isRefresh: true));
                },
                child: GridView.builder(
                  padding: const EdgeInsets.all(16),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    mainAxisSpacing: 16,
                    crossAxisSpacing: 16,
                    childAspectRatio: 0.75,
                  ),
                  itemCount: list.length,
                  itemBuilder: (context, index) {
                    final product = list[index];
                    return ProductCard(
                      product: product,
                      onTap: () => context.push('/products/details', extra: product),
                    );
                  },
                ),
              );
            } else if (state is ProductError) {
              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.error_outline, color: AppColors.brandRed, size: 48),
                      const SizedBox(height: 12),
                      Text(state.message, style: const TextStyle(color: Color(0xFF11261B))),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: () {
                          context.read<ProductBloc>().add(const FetchProductsEvent());
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.brandOrange,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        ),
                        child: const Text('Retry'),
                      ),
                    ],
                  ),
                ),
              );
            }
            return const SizedBox();
          },
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.shopping_bag_outlined, size: 64, color: Color(0xFFD1DDD6)),
          SizedBox(height: 16),
          Text(
            'No Products Found',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Color(0xFF11261B),
            ),
          ),
          SizedBox(height: 6),
          Text(
            'No products are currently active in this category.',
            style: TextStyle(
              fontSize: 12,
              color: Color(0xFF4C6656),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProductGridShimmer() {
    return GridView.builder(
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: 16,
        crossAxisSpacing: 16,
        childAspectRatio: 0.72,
      ),
      itemCount: 6,
      itemBuilder: (context, index) {
        return Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFFE8F0EC)),
          ),
          child: const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ShimmerEffect.rectangular(
                height: 120,
                borderRadius: BorderRadius.all(Radius.circular(12)),
              ),
              SizedBox(height: 10),
              ShimmerEffect.rectangular(
                width: 60,
                height: 10,
                borderRadius: BorderRadius.all(Radius.circular(4)),
              ),
              SizedBox(height: 6),
              ShimmerEffect.rectangular(
                width: 120,
                height: 12,
                borderRadius: BorderRadius.all(Radius.circular(4)),
              ),
              Spacer(),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  ShimmerEffect.rectangular(
                    width: 50,
                    height: 14,
                    borderRadius: BorderRadius.all(Radius.circular(4)),
                  ),
                  ShimmerEffect.rectangular(
                    width: 28,
                    height: 28,
                    borderRadius: BorderRadius.all(Radius.circular(8)),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}
