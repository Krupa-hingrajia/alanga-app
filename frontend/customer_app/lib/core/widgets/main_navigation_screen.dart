import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../features/home/presentation/screens/home_screen.dart';
import '../../features/categories/presentation/screens/category_grid_screen.dart';
import '../../features/wishlist/presentation/screens/wishlist_screen.dart';
import '../../features/cart/presentation/screens/cart_screen.dart';
import '../../features/profile/presentation/screens/profile_screen.dart';
import '../../features/wishlist/presentation/bloc/wishlist_bloc.dart';
import '../../features/wishlist/presentation/bloc/wishlist_state.dart';
import '../../features/cart/presentation/bloc/cart_cubit.dart';
import '../../features/cart/presentation/bloc/cart_state.dart';
import '../constants/app_colors.dart';
import '../dependency_injection/injection.dart';

class MainNavigationScreen extends StatefulWidget {
  final int initialIndex;

  const MainNavigationScreen({super.key, this.initialIndex = 0});

  @override
  State<MainNavigationScreen> createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends State<MainNavigationScreen> {
  late int _selectedIndex;

  final List<Widget> _screens = const [
    HomeScreen(),
    CategoryGridScreen(),
    WishlistScreen(),
    CartScreen(),
    ProfileScreen(),
  ];

  @override
  void initState() {
    super.initState();
    _selectedIndex = widget.initialIndex;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocBuilder<CartCubit, CartState>(
        builder: (context, cartState) {
          int cartCount = 0;
          double subtotal = 0.0;
          if (cartState is CartLoaded) {
            cartCount = cartState.summary.totalItems;
            subtotal = cartState.summary.subtotal;
          }

          const freeDeliveryThreshold = 499.0;
          final isFreeDelivery = subtotal >= freeDeliveryThreshold;
          final remainingAmount = (freeDeliveryThreshold - subtotal).clamp(0.0, freeDeliveryThreshold);

          return Stack(
            children: [
              IndexedStack(
                index: _selectedIndex,
                children: _screens,
              ),

              // Floating Alanga Luxury Bottom Cart Pill (visible when cart has items and not on cart tab)
              if (cartCount > 0 && _selectedIndex != 3)
                Positioned(
                  left: 14,
                  right: 14,
                  bottom: 12,
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(18),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.darkGreen.withValues(alpha: 0.35),
                          blurRadius: 22,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        // Left: Free Delivery Progress Bar (Themed with Alanga Forest & Amber)
                        Expanded(
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                            decoration: const BoxDecoration(
                              color: Color(0xFF0F2B1C),
                              borderRadius: BorderRadius.only(
                                topLeft: Radius.circular(18),
                                bottomLeft: Radius.circular(18),
                              ),
                            ),
                            child: Row(
                              children: [
                                Container(
                                  width: 34,
                                  height: 34,
                                  decoration: BoxDecoration(
                                    color: isFreeDelivery
                                        ? AppColors.primaryGreen
                                        : AppColors.brandOrange.withValues(alpha: 0.2),
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                      color: isFreeDelivery
                                          ? Colors.white.withValues(alpha: 0.4)
                                          : AppColors.brandOrange,
                                      width: 1.2,
                                    ),
                                  ),
                                  child: Icon(
                                    isFreeDelivery
                                        ? Icons.check_circle_rounded
                                        : Icons.electric_bolt_rounded,
                                    color: isFreeDelivery ? Colors.white : AppColors.brandYellow,
                                    size: 18,
                                  ),
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Text(
                                        isFreeDelivery
                                            ? 'FREE DELIVERY UNLOCKED!'
                                            : 'Add ₹${remainingAmount.toStringAsFixed(0)} for FREE Delivery',
                                        style: TextStyle(
                                          color: isFreeDelivery
                                              ? const Color(0xFF6EE7B7)
                                              : AppColors.brandYellow,
                                          fontWeight: FontWeight.w800,
                                          fontSize: 11,
                                          letterSpacing: 0.2,
                                        ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      const SizedBox(height: 4),
                                      ClipRRect(
                                        borderRadius: BorderRadius.circular(4),
                                        child: LinearProgressIndicator(
                                          value: (subtotal / freeDeliveryThreshold).clamp(0.0, 1.0),
                                          minHeight: 4,
                                          backgroundColor: Colors.white.withValues(alpha: 0.15),
                                          valueColor: AlwaysStoppedAnimation<Color>(
                                            isFreeDelivery
                                                ? AppColors.primaryGreen
                                                : AppColors.brandOrange,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),

                        // Right: View Cart Button with Alanga Ribbon Gradient
                        InkWell(
                          onTap: () {
                            setState(() {
                              _selectedIndex = 3;
                            });
                          },
                          borderRadius: const BorderRadius.only(
                            topRight: Radius.circular(18),
                            bottomRight: Radius.circular(18),
                          ),
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
                            decoration: const BoxDecoration(
                              gradient: AppColors.logoRibbonGradient,
                              borderRadius: BorderRadius.only(
                                topRight: Radius.circular(18),
                                bottomRight: Radius.circular(18),
                              ),
                            ),
                            child: Row(
                              children: [
                                const Icon(
                                  Icons.shopping_bag_rounded,
                                  color: Colors.white,
                                  size: 18,
                                ),
                                const SizedBox(width: 6),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    const Text(
                                      'View Cart',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.w900,
                                        fontSize: 12,
                                      ),
                                    ),
                                    Text(
                                      '$cartCount ${cartCount == 1 ? 'item' : 'items'}',
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.w700,
                                        fontSize: 10,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
            ],
          );
        },
      ),

      // Elevated Modern Dock Navigation Bar
      bottomNavigationBar: BlocBuilder<WishlistBloc, WishlistState>(
        bloc: sl<WishlistBloc>(),
        builder: (context, wishlistState) {
          int wishlistCount = 0;
          if (wishlistState is WishlistLoaded) {
            wishlistCount = wishlistState.items.length;
          } else {
            wishlistCount = sl<WishlistBloc>().wishlistedProductIds.length;
          }

          final cartState = context.watch<CartCubit>().state;
          int cartCount = 0;
          if (cartState is CartLoaded) {
            cartCount = cartState.summary.totalItems;
          }

          return Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(22),
                topRight: Radius.circular(22),
              ),
              boxShadow: [
                BoxShadow(
                  color: AppColors.darkGreen.withValues(alpha: 0.08),
                  blurRadius: 18,
                  offset: const Offset(0, -4),
                ),
              ],
            ),
            child: SafeArea(
              top: false,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildNavItem(
                      index: 0,
                      label: 'Home',
                      icon: Icons.home_outlined,
                      activeIcon: Icons.home_rounded,
                    ),
                    _buildNavItem(
                      index: 1,
                      label: 'Categories',
                      icon: Icons.grid_view_outlined,
                      activeIcon: Icons.grid_view_rounded,
                    ),
                    _buildNavItem(
                      index: 2,
                      label: 'Wishlist',
                      icon: Icons.favorite_outline_rounded,
                      activeIcon: Icons.favorite_rounded,
                      badgeCount: wishlistCount,
                      badgeColor: AppColors.brandRed,
                    ),
                    _buildNavItem(
                      index: 3,
                      label: 'Cart',
                      icon: Icons.shopping_bag_outlined,
                      activeIcon: Icons.shopping_bag_rounded,
                      badgeCount: cartCount,
                      badgeColor: AppColors.brandOrange,
                    ),
                    _buildNavItem(
                      index: 4,
                      label: 'Profile',
                      icon: Icons.person_outline_rounded,
                      activeIcon: Icons.person_rounded,
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildNavItem({
    required int index,
    required String label,
    required IconData icon,
    required IconData activeIcon,
    int badgeCount = 0,
    Color badgeColor = AppColors.primaryGreen,
  }) {
    final isSelected = _selectedIndex == index;

    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedIndex = index;
        });
      },
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOutCubic,
        padding: EdgeInsets.symmetric(
          horizontal: isSelected ? 14 : 10,
          vertical: 6,
        ),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.primaryGreen.withValues(alpha: 0.12)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Stack(
              clipBehavior: Clip.none,
              children: [
                AnimatedScale(
                  scale: isSelected ? 1.15 : 1.0,
                  duration: const Duration(milliseconds: 220),
                  curve: Curves.easeOutBack,
                  child: Icon(
                    isSelected ? activeIcon : icon,
                    size: 22,
                    color: isSelected
                        ? const Color(0xFF0C2417)
                        : const Color(0xFF7A9688),
                  ),
                ),
                if (badgeCount > 0)
                  Positioned(
                    top: -4,
                    right: -6,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1.5),
                      decoration: BoxDecoration(
                        color: badgeColor,
                        borderRadius: BorderRadius.circular(10),
                        boxShadow: [
                          BoxShadow(
                            color: badgeColor.withValues(alpha: 0.4),
                            blurRadius: 4,
                            offset: const Offset(0, 1),
                          ),
                        ],
                      ),
                      constraints: const BoxConstraints(minWidth: 16, minHeight: 16),
                      child: Text(
                        badgeCount > 99 ? '99+' : '$badgeCount',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 8.5,
                          fontWeight: FontWeight.w900,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 3),
            AnimatedDefaultTextStyle(
              duration: const Duration(milliseconds: 200),
              style: TextStyle(
                fontSize: 10.5,
                fontWeight: isSelected ? FontWeight.w800 : FontWeight.w500,
                color: isSelected
                    ? const Color(0xFF0C2417)
                    : const Color(0xFF7A9688),
              ),
              child: Text(label),
            ),
          ],
        ),
      ),
    );
  }
}
