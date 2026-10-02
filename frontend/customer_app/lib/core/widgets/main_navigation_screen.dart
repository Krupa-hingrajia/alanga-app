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
              // Floating Zepto Bottom Cart Pill (visible when cart has items and not on cart tab)
              if (cartCount > 0 && _selectedIndex != 3)
                Positioned(
                  left: 14,
                  right: 14,
                  bottom: 12,
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.25),
                          blurRadius: 18,
                          offset: const Offset(0, 6),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        // Left: Free Delivery Progress Bar (Dark themed like Zepto)
                        Expanded(
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                            decoration: const BoxDecoration(
                              color: Color(0xFF1E293B),
                              borderRadius: BorderRadius.only(
                                topLeft: Radius.circular(16),
                                bottomLeft: Radius.circular(16),
                              ),
                            ),
                            child: Row(
                              children: [
                                Container(
                                  width: 32,
                                  height: 32,
                                  decoration: BoxDecoration(
                                    color: isFreeDelivery
                                        ? const Color(0xFF10B981)
                                        : Colors.white.withValues(alpha: 0.15),
                                    shape: BoxShape.circle,
                                  ),
                                  child: Icon(
                                    isFreeDelivery
                                        ? Icons.check_circle_rounded
                                        : Icons.two_wheeler_rounded,
                                    color: Colors.white,
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
                                            ? 'Free delivery unlocked! 🎉'
                                            : 'Unlock free delivery',
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 12,
                                        ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      const SizedBox(height: 2),
                                      Text(
                                        isFreeDelivery
                                            ? 'No shipping fee on this order'
                                            : 'Shop for ₹${remainingAmount.toStringAsFixed(0)} more',
                                        style: TextStyle(
                                          color: isFreeDelivery
                                              ? const Color(0xFF6EE7B7)
                                              : Colors.white.withValues(alpha: 0.7),
                                          fontSize: 10.5,
                                          fontWeight: FontWeight.w500,
                                        ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        // Right: Cart Button (Vibrant Zepto/Blinkit Pink CTA)
                        InkWell(
                          onTap: () {
                            setState(() {
                              _selectedIndex = 3;
                            });
                          },
                          borderRadius: const BorderRadius.only(
                            topRight: Radius.circular(16),
                            bottomRight: Radius.circular(16),
                          ),
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
                            decoration: const BoxDecoration(
                              gradient: LinearGradient(
                                colors: [Color(0xFFFF007A), Color(0xFFE60067)],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                              borderRadius: BorderRadius.only(
                                topRight: Radius.circular(16),
                                bottomRight: Radius.circular(16),
                              ),
                            ),
                            child: Row(
                              children: [
                                const Icon(
                                  Icons.shopping_cart_rounded,
                                  color: Colors.white,
                                  size: 18,
                                ),
                                const SizedBox(width: 6),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    const Text(
                                      'Cart',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.w900,
                                        fontSize: 12,
                                      ),
                                    ),
                                    Text(
                                      '$cartCount ${cartCount == 1 ? 'item' : 'items'}',
                                      style: const TextStyle(
                                        color: Colors.white70,
                                        fontWeight: FontWeight.w600,
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
              boxShadow: [
                BoxShadow(
                  color: AppColors.darkGreen.withValues(alpha: 0.06),
                  blurRadius: 16,
                  offset: const Offset(0, -4),
                ),
              ],
            ),
            child: BottomNavigationBar(
              currentIndex: _selectedIndex,
              onTap: (index) {
                setState(() {
                  _selectedIndex = index;
                });
              },
              backgroundColor: Colors.white,
              selectedItemColor: AppColors.primaryGreen,
              unselectedItemColor: const Color(0xFF7A9A86),
              selectedLabelStyle: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 11,
              ),
              unselectedLabelStyle: const TextStyle(fontSize: 11),
              type: BottomNavigationBarType.fixed,
              elevation: 0,
              items: [
                const BottomNavigationBarItem(
                  icon: Icon(Icons.home_outlined),
                  activeIcon: Icon(Icons.home_rounded),
                  label: 'Home',
                ),
                const BottomNavigationBarItem(
                  icon: Icon(Icons.grid_view_outlined),
                  activeIcon: Icon(Icons.grid_view_rounded),
                  label: 'Categories',
                ),
                BottomNavigationBarItem(
                  icon: wishlistCount > 0
                      ? Badge(
                          label: Text('$wishlistCount'),
                          backgroundColor: AppColors.brandRed,
                          child: const Icon(Icons.favorite_outline_rounded),
                        )
                      : const Icon(Icons.favorite_outline_rounded),
                  activeIcon: wishlistCount > 0
                      ? Badge(
                          label: Text('$wishlistCount'),
                          backgroundColor: AppColors.brandRed,
                          child: const Icon(Icons.favorite_rounded),
                        )
                      : const Icon(Icons.favorite_rounded),
                  label: 'Wishlist',
                ),
                BottomNavigationBarItem(
                  icon: cartCount > 0
                      ? Badge(
                          label: Text('$cartCount'),
                          backgroundColor: AppColors.primaryGreen,
                          child: const Icon(Icons.shopping_bag_outlined),
                        )
                      : const Icon(Icons.shopping_bag_outlined),
                  activeIcon: cartCount > 0
                      ? Badge(
                          label: Text('$cartCount'),
                          backgroundColor: AppColors.primaryGreen,
                          child: const Icon(Icons.shopping_bag_rounded),
                        )
                      : const Icon(Icons.shopping_bag_rounded),
                  label: 'Cart',
                ),
                const BottomNavigationBarItem(
                  icon: Icon(Icons.person_outline_rounded),
                  activeIcon: Icon(Icons.person_rounded),
                  label: 'Profile',
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
