import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../bloc/home_bloc.dart';
import '../bloc/home_event.dart';
import '../bloc/home_state.dart';
import '../widgets/home_header.dart';
import '../widgets/banner_carousel.dart';
import '../widgets/category_horizontal_list.dart';
import '../widgets/flash_deals_section.dart';
import '../widgets/top_brands_section.dart';
import '../widgets/coupons_offers_section.dart';
import '../../../products/data/models/product_model.dart';
import '../../../products/presentation/widgets/customer_product_card.dart';
import '../../../cart/presentation/bloc/cart_cubit.dart';
import '../../../cart/presentation/bloc/cart_state.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/dependency_injection/injection.dart';
import '../../../../core/storage/secure_storage_service.dart';
import '../../../../core/widgets/empty_state_widget.dart';
import '../../../../core/widgets/shimmer_effect.dart';

import '../../../wishlist/presentation/bloc/wishlist_bloc.dart';
import '../../../wishlist/presentation/bloc/wishlist_event.dart';
import '../../../addresses/presentation/bloc/address_cubit.dart';
import '../../../addresses/presentation/bloc/address_state.dart';
import '../../../addresses/data/models/address_model.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String _customerName = 'Customer';
  final _searchController = TextEditingController();
  String? _selectedCategoryFilter; // null means 'All Items'

  @override
  void initState() {
    super.initState();
    _loadProfile();
    sl<WishlistBloc>().add(const FetchWishlistEvent());
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        context.read<AddressCubit>().fetchAddresses();
      }
    });
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
    final cartState = context.watch<CartCubit>().state;
    int cartCount = 0;
    if (cartState is CartLoaded) {
      cartCount = cartState.summary.totalItems;
    }

    final addressState = context.watch<AddressCubit>().state;
    String deliveryAddress = 'Select Location';
    if (addressState is AddressLoaded) {
      final AddressModel? active = addressState.selectedAddress ??
          (addressState.addresses.isNotEmpty
              ? addressState.addresses.firstWhere((a) => a.isDefault, orElse: () => addressState.addresses.first)
              : null);
      if (active != null) {
        final locationCity = active.city.trim().isNotEmpty
            ? active.city.trim()
            : active.addressLine1.trim();
        final pin = active.postalCode.trim();
        final type = active.addressType.trim().toUpperCase();

        if (type.isNotEmpty && locationCity.isNotEmpty) {
          deliveryAddress = pin.isNotEmpty
              ? '$type • $locationCity, $pin'
              : '$type • $locationCity';
        } else if (locationCity.isNotEmpty) {
          deliveryAddress = pin.isNotEmpty ? '$locationCity, $pin' : locationCity;
        } else if (pin.isNotEmpty) {
          deliveryAddress = 'Pincode $pin';
        }
      }
    }

    return BlocProvider(
      create: (_) => sl<HomeBloc>()..add(const LoadHomeDataEvent()),
      child: AnnotatedRegion<SystemUiOverlayStyle>(
        value: const SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
          statusBarIconBrightness: Brightness.dark, // Clean dark status bar icons (Time, Battery, Wifi)
          statusBarBrightness: Brightness.light,    // Clean dark status bar text/icons on iOS
          systemNavigationBarColor: Colors.white,
          systemNavigationBarIconBrightness: Brightness.dark,
        ),
        child: Scaffold(
          backgroundColor: const Color(0xFFF7FAF8),
          body: Column(
            children: [
              // 1. Top Fixed Header with Integrated Search (Blinkit / Zepto Style)
              HomeHeader(
                customerName: _customerName,
                deliveryAddress: deliveryAddress,
                notificationCount: 3,
                cartCount: cartCount,
                onNotificationTap: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('You have no new notifications'),
                      duration: Duration(seconds: 2),
                    ),
                  );
                },
                onCartTap: () => context.push('/cart'),
                onAddressTap: () => context.push('/addresses'),
                searchController: _searchController,
                onSearchSubmitted: _onSearchSubmitted,
              ),

            // 2. Scrollable Content
            Expanded(
              child: BlocBuilder<HomeBloc, HomeState>(
                builder: (context, state) {
                  if (state is HomeLoading) {
                    return _buildShimmerLoader();
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

                    // Genuine Flash Deals (only products where MRP > sellingPrice)
                    final flashDealProducts = allProducts.where((p) => p.mrp > p.sellingPrice).toList();

                    // Filtered products for the Zepto-style category tabs section
                    final filteredProducts = _selectedCategoryFilter == null
                        ? allProducts
                        : allProducts.where((p) => p.categoryId == _selectedCategoryFilter).toList();

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

                            // 1. Banner Carousel
                            const BannerCarousel(),
                            const SizedBox(height: 22),

                            // 2. Zepto-Style Coupons & Offers
                            const CouponsOffersSection(),
                            const SizedBox(height: 24),

                            // 3. Shop by Category (Horizontal circles)
                            CategoryHorizontalList(
                              categories: state.categories,
                              onViewAllTap: () => context.push('/products'),
                            ),
                            const SizedBox(height: 24),

                            // 4. Flash Deals (Only if discounted products actually exist)
                            if (flashDealProducts.isNotEmpty) ...[
                              FlashDealsSection(products: flashDealProducts),
                              const SizedBox(height: 24),
                            ],

                            // 5. Zepto "Buy Again & Curated Picks" with Interactive Category Tabs
                            _buildSectionHeader(
                              icon: Icons.auto_awesome_rounded,
                              iconColor: AppColors.primaryGreen,
                              title: 'Top Picks For You',
                              onViewAll: () => context.push('/products'),
                            ),
                            const SizedBox(height: 10),

                            // Category Filter Chips (Zepto Style)
                            SizedBox(
                              height: 38,
                              child: ListView(
                                scrollDirection: Axis.horizontal,
                                padding: const EdgeInsets.symmetric(horizontal: 16),
                                children: [
                                  _buildCategoryFilterChip(
                                    label: 'All Items',
                                    isSelected: _selectedCategoryFilter == null,
                                    onTap: () {
                                      setState(() {
                                        _selectedCategoryFilter = null;
                                      });
                                    },
                                  ),
                                  ...state.categories.map((cat) {
                                    final isSelected = _selectedCategoryFilter == cat.id;
                                    return _buildCategoryFilterChip(
                                      label: cat.name,
                                      isSelected: isSelected,
                                      onTap: () {
                                        setState(() {
                                          _selectedCategoryFilter = isSelected ? null : cat.id;
                                        });
                                      },
                                    );
                                  }),
                                ],
                              ),
                            ),
                            const SizedBox(height: 12),

                            // Products for Selected Tab
                            if (filteredProducts.isNotEmpty)
                              _buildHorizontalProductList(filteredProducts)
                            else
                              Container(
                                height: 120,
                                margin: const EdgeInsets.symmetric(horizontal: 16),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(16),
                                  border: Border.all(color: const Color(0xFFE5EDE8)),
                                ),
                                child: Center(
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(
                                        Icons.inventory_2_outlined,
                                        size: 32,
                                        color: Colors.grey.shade400,
                                      ),
                                      const SizedBox(height: 6),
                                      Text(
                                        'No items in this category yet',
                                        style: TextStyle(
                                          fontSize: 13,
                                          fontWeight: FontWeight.w600,
                                          color: Colors.grey.shade600,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            const SizedBox(height: 24),

                            // 6. Top Brands (Dynamic from Admin)
                            if (state.brands.isNotEmpty) ...[
                              TopBrandsSection(brands: state.brands),
                              const SizedBox(height: 24),
                            ],

                            // 7. Recently Added (only if more than 3 products to avoid repeating same items)
                            if (allProducts.length > 3) ...[
                              _buildSectionHeader(
                                icon: Icons.trending_up_rounded,
                                iconColor: AppColors.brandOrange,
                                title: 'Trending This Week',
                                onViewAll: () => context.push('/products'),
                              ),
                              const SizedBox(height: 12),
                              _buildHorizontalProductList(allProducts.reversed.take(6).toList()),
                              const SizedBox(height: 24),
                            ],

                            const SizedBox(height: 40),
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
      ),
    );
  }

  Widget _buildCategoryFilterChip({
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          decoration: BoxDecoration(
            gradient: isSelected ? AppColors.brandEmeraldGradient : null,
            color: isSelected ? null : Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: isSelected ? Colors.transparent : const Color(0xFFD6E2DA),
              width: 1.2,
            ),
            boxShadow: isSelected
                ? [
                    BoxShadow(
                      color: AppColors.primaryGreen.withValues(alpha: 0.35),
                      blurRadius: 10,
                      offset: const Offset(0, 3),
                    ),
                  ]
                : [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.02),
                      blurRadius: 4,
                      offset: const Offset(0, 1),
                    ),
                  ],
          ),
          child: Center(
            child: Text(
              label,
              style: TextStyle(
                fontSize: 12.5,
                fontWeight: isSelected ? FontWeight.w900 : FontWeight.w600,
                color: isSelected ? Colors.white : const Color(0xFF1E3A2B),
              ),
            ),
          ),
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
              Container(
                width: 3.5,
                height: 16,
                decoration: BoxDecoration(
                  gradient: AppColors.logoRibbonGradient,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(width: 8),
              Icon(icon, color: iconColor, size: 19),
              const SizedBox(width: 6),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 16.5,
                  fontWeight: FontWeight.w900,
                  color: Color(0xFF0C2417),
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

  Widget _buildShimmerLoader() {
    return SingleChildScrollView(
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.only(top: 14, bottom: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // 1. Banner Carousel Shimmer
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16),
            child: ShimmerEffect.rectangular(
              height: 155,
              borderRadius: BorderRadius.all(Radius.circular(20)),
            ),
          ),
          const SizedBox(height: 22),

          // 3. Category Circles Shimmer
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                ShimmerEffect.rectangular(width: 130, height: 16, borderRadius: BorderRadius.all(Radius.circular(6))),
                ShimmerEffect.rectangular(width: 55, height: 14, borderRadius: BorderRadius.all(Radius.circular(6))),
              ],
            ),
          ),
          const SizedBox(height: 14),
          SizedBox(
            height: 90,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 12),
              itemCount: 5,
              itemBuilder: (context, index) {
                return const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 8),
                  child: Column(
                    children: [
                      ShimmerEffect.circular(width: 60, height: 60),
                      SizedBox(height: 6),
                      ShimmerEffect.rectangular(width: 50, height: 10, borderRadius: BorderRadius.all(Radius.circular(4))),
                    ],
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 22),

          // 4. Products Section Shimmer
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                ShimmerEffect.rectangular(width: 160, height: 18, borderRadius: BorderRadius.all(Radius.circular(6))),
                ShimmerEffect.rectangular(width: 55, height: 14, borderRadius: BorderRadius.all(Radius.circular(6))),
              ],
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: 230,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: 3,
              itemBuilder: (context, index) {
                return Container(
                  width: 165,
                  margin: const EdgeInsets.only(right: 12),
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: const Color(0xFFE5EDE8)),
                  ),
                  child: const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ShimmerEffect.rectangular(height: 120, borderRadius: BorderRadius.all(Radius.circular(12))),
                      SizedBox(height: 8),
                      ShimmerEffect.rectangular(width: 60, height: 10, borderRadius: BorderRadius.all(Radius.circular(4))),
                      SizedBox(height: 6),
                      ShimmerEffect.rectangular(width: 130, height: 12, borderRadius: BorderRadius.all(Radius.circular(4))),
                      Spacer(),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          ShimmerEffect.rectangular(width: 60, height: 16, borderRadius: BorderRadius.all(Radius.circular(4))),
                          ShimmerEffect.rectangular(width: 48, height: 26, borderRadius: BorderRadius.all(Radius.circular(8))),
                        ],
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
