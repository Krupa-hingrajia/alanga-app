import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../bloc/home_bloc.dart';
import '../bloc/home_event.dart';
import '../bloc/home_state.dart';
import '../widgets/home_header.dart';
import '../widgets/home_search_bar.dart';
import '../widgets/banner_carousel.dart';
import '../widgets/category_horizontal_list.dart';
import '../widgets/flash_deals_section.dart';
import '../widgets/top_brands_section.dart';
import '../widgets/today_offers_section.dart';
import '../../../products/data/models/product_model.dart';
import '../../../products/presentation/widgets/customer_product_card.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/dependency_injection/injection.dart';
import '../../../../core/storage/secure_storage_service.dart';
import '../../../../core/widgets/empty_state_widget.dart';

import '../../../wishlist/presentation/bloc/wishlist_bloc.dart';
import '../../../wishlist/presentation/bloc/wishlist_event.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String _customerName = 'Customer';
  final _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadProfile();
    sl<WishlistBloc>().add(const FetchWishlistEvent());
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadProfile() async {
    final userData = await sl<SecureStorageService>().getUserData();
    if (userData != null && userData.containsKey('fullName')) {
      final name = userData['fullName'] as String;
      if (name.isNotEmpty) {
        setState(() {
          _customerName = name;
        });
      }
    }
  }

  void _onSearchSubmitted(String query) {
    if (query.trim().isNotEmpty) {
      context.push('/products', extra: query.trim());
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<HomeBloc>()..add(const LoadHomeDataEvent()),
      child: Scaffold(
        backgroundColor: const Color(0xFFF3F6F4),
        body: Column(
          children: [
            // 1. Top Fixed Header (Does NOT Scroll, Edge-to-Edge Status Bar)
            HomeHeader(
              customerName: _customerName,
              deliveryAddress: 'Navi Mumbai, 400706',
              notificationCount: 3,
              cartCount: 2,
              onNotificationTap: () {},
              onCartTap: () {},
            ),

            // 2. Scrollable Content (Starting from Search Bar)
            Expanded(
              child: BlocBuilder<HomeBloc, HomeState>(
                builder: (context, state) {
                  if (state is HomeLoading) {
                    return _buildSkeletonLoader();
                  } else if (state is HomeError) {
                    return EmptyStateWidget(
                      icon: Icons.wifi_off_rounded,
                      title: 'Unable to Load Dashboard',
                      description: state.message,
                      buttonText: 'Retry',
                      onButtonPressed: () {
                        context.read<HomeBloc>().add(const LoadHomeDataEvent());
                      },
                    );
                  } else if (state is HomeLoaded) {
                    final allProducts = state.products;

                    // Section filters
                    final flashDealProducts = allProducts.where((p) => p.mrp > p.sellingPrice).toList();
                    final newlyAddedProducts = List<ProductModel>.from(allProducts)
                      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
                    final recommendedProducts = allProducts.take(8).toList();
                    final trendingProducts = List<ProductModel>.from(allProducts)..shuffle();

                    return RefreshIndicator(
                      color: AppColors.primaryGreen,
                      backgroundColor: Colors.white,
                      onRefresh: () async {
                        context.read<HomeBloc>().add(const LoadHomeDataEvent(isRefresh: true));
                      },
                      child: SingleChildScrollView(
                        physics: const AlwaysScrollableScrollPhysics(),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            const SizedBox(height: 14),

                            // Search Bar
                            HomeSearchBar(
                              controller: _searchController,
                              onSubmitted: _onSearchSubmitted,
                            ),
                            const SizedBox(height: 18),

                            // Banner Carousel
                            const BannerCarousel(),
                            const SizedBox(height: 22),

                            // Today's Offers & Coupons
                            const TodayOffersSection(),
                            const SizedBox(height: 24),

                            // Shop by Category
                            CategoryHorizontalList(
                              categories: state.categories,
                              onViewAllTap: () {},
                            ),
                            const SizedBox(height: 24),

                            // Flash Deals
                            if (flashDealProducts.isNotEmpty) ...[
                              FlashDealsSection(products: flashDealProducts),
                              const SizedBox(height: 24),
                            ],

                            // Recommended for You
                            _buildSectionHeader(
                              icon: Icons.thumb_up_alt_rounded,
                              iconColor: AppColors.brandOrange,
                              title: 'Recommended for You',
                              onViewAll: () => context.push('/products'),
                            ),
                            const SizedBox(height: 12),
                            _buildHorizontalProductList(recommendedProducts),
                            const SizedBox(height: 24),

                            // Top Brands
                            const TopBrandsSection(),
                            const SizedBox(height: 24),

                            // Newly Added Products
                            if (newlyAddedProducts.isNotEmpty) ...[
                              _buildSectionHeader(
                                icon: Icons.new_releases_rounded,
                                iconColor: AppColors.brandRed,
                                title: 'Newly Added',
                                onViewAll: () => context.push('/products'),
                              ),
                              const SizedBox(height: 12),
                              _buildHorizontalProductList(newlyAddedProducts.take(8).toList()),
                              const SizedBox(height: 24),
                            ],

                            // Trending Products
                            if (trendingProducts.isNotEmpty) ...[
                              _buildSectionHeader(
                                icon: Icons.trending_up_rounded,
                                iconColor: AppColors.primaryGreen,
                                title: 'Trending Products',
                                onViewAll: () => context.push('/products'),
                              ),
                              const SizedBox(height: 12),
                              _buildHorizontalProductList(trendingProducts.take(8).toList()),
                              const SizedBox(height: 24),
                            ],

                            // Continue Shopping (Recently Viewed)
                            if (allProducts.length > 2) ...[
                              _buildSectionHeader(
                                icon: Icons.history_rounded,
                                iconColor: const Color(0xFF6B7280),
                                title: 'Continue Shopping',
                              ),
                              const SizedBox(height: 12),
                              _buildHorizontalProductList(allProducts.skip(2).take(6).toList()),
                              const SizedBox(height: 24),
                            ],

                            const SizedBox(height: 30),
                          ],
                        ),
                      ),
                    );
                  }

                  return const SizedBox();
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader({
    required IconData icon,
    required Color iconColor,
    required String title,
    VoidCallback? onViewAll,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Icon(icon, color: iconColor, size: 20),
              const SizedBox(width: 6),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF11261B),
                  letterSpacing: -0.2,
                ),
              ),
            ],
          ),
          if (onViewAll != null)
            TextButton(
              onPressed: onViewAll,
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
    );
  }

  Widget _buildHorizontalProductList(List<ProductModel> products) {
    if (products.isEmpty) return const SizedBox();

    return SizedBox(
      height: 250,
      child: ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        scrollDirection: Axis.horizontal,
        itemCount: products.length,
        itemBuilder: (context, index) {
          return CustomerProductCard(
            product: products[index],
            width: 165,
          );
        },
      ),
    );
  }

  Widget _buildSkeletonLoader() {
    return SingleChildScrollView(
      child: Column(
        children: [
          Container(
            height: 120,
            color: AppColors.darkGreen,
          ),
          const SizedBox(height: 16),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Container(
              height: 50,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Container(
            height: 140,
            margin: const EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(
              color: Colors.grey.shade200,
              borderRadius: BorderRadius.circular(20),
            ),
          ),
          const SizedBox(height: 24),
          const Center(
            child: CircularProgressIndicator(color: AppColors.primaryGreen),
          ),
        ],
      ),
    );
  }
}
