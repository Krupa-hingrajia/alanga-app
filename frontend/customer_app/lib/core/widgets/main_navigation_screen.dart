import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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
  bool _isCartBannerDismissed = false;
  int _lastCartCount = 0;

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
    const overlayStyle = SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark, // Clean dark status bar icons across all light screens
      statusBarBrightness: Brightness.light,
      systemNavigationBarColor: Colors.white,
      systemNavigationBarIconBrightness: Brightness.dark,
    );

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: overlayStyle,
      child: Scaffold(
      body: BlocConsumer<CartCubit, CartState>(
        listener: (context, cartState) {
          if (cartState is CartLoaded) {
            if (cartState.summary.totalItems != _lastCartCount) {
              setState(() {
                _lastCartCount = cartState.summary.totalItems;
                _isCartBannerDismissed = false;
              });
            }
          }
        },
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

              // Modern Light Floating Bottom Cart Pill (Swipeable Left/Right to Close)
              if (cartCount > 0 && _selectedIndex != 3 && !_isCartBannerDismissed)
                Positioned(
                  left: 14,
                  right: 14,
                  bottom: 12,
                  child: Dismissible(
                    key: ValueKey('floating_cart_banner_${cartCount}_${subtotal.toInt()}'),
                    direction: DismissDirection.horizontal,
                    onDismissed: (direction) {
                      setState(() {
                        _isCartBannerDismissed = true;
                      });
                      ScaffoldMessenger.of(context).clearSnackBars();
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: const Text(
                            'Cart bar dismissed. Tap Cart tab below anytime.',
                            style: TextStyle(fontSize: 12.5),
                          ),
                          behavior: SnackBarBehavior.floating,
                          duration: const Duration(seconds: 3),
                          action: SnackBarAction(
                            label: 'UNDO',
                            textColor: AppColors.brandOrange,
                            onPressed: () {
                              setState(() {
                                _isCartBannerDismissed = false;
                              });
                            },
                          ),
                        ),
                      );
                    },
                    background: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      alignment: Alignment.centerLeft,
                      decoration: BoxDecoration(
                        color: const Color(0xFFEF4444).withValues(alpha: 0.9),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Row(
                        children: [
                          Icon(Icons.close_rounded, color: Colors.white, size: 20),
                          SizedBox(width: 8),
                          Text(
                            'Swipe to close',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ),
                    ),
                    secondaryBackground: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      alignment: Alignment.centerRight,
                      decoration: BoxDecoration(
                        color: const Color(0xFFEF4444).withValues(alpha: 0.9),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Text(
                            'Swipe to close',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 13,
                            ),
                          ),
                          SizedBox(width: 8),
                          Icon(Icons.close_rounded, color: Colors.white, size: 20),
                        ],
                      ),
                    ),
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: const Color(0xFFD2E8DB),
                          width: 1.2,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.08),
                            blurRadius: 20,
                            offset: const Offset(0, 6),
                          ),
                          BoxShadow(
                            color: AppColors.primaryGreen.withValues(alpha: 0.12),
                            blurRadius: 10,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Row(
                        children: [
                          // Left: Free Delivery Progress Bar (Clean Mint Pearl Aesthetic)
                          Expanded(
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                              decoration: const BoxDecoration(
                                color: Color(0xFFF5FAF7),
                                borderRadius: BorderRadius.only(
                                  topLeft: Radius.circular(19),
                                  bottomLeft: Radius.circular(19),
                                ),
                              ),
                              child: Row(
                                children: [
                                  Container(
                                    width: 34,
                                    height: 34,
                                    decoration: BoxDecoration(
                                      color: isFreeDelivery
                                          ? const Color(0xFFDCFCE7)
                                          : const Color(0xFFFEF3C7),
                                      shape: BoxShape.circle,
                                      border: Border.all(
                                        color: isFreeDelivery
                                            ? const Color(0xFF86EFAC)
                                            : const Color(0xFFFCD34D),
                                        width: 1.2,
                                      ),
                                    ),
                                    child: Icon(
                                      isFreeDelivery
                                          ? Icons.check_circle_rounded
                                          : Icons.electric_bolt_rounded,
                                      color: isFreeDelivery
                                          ? const Color(0xFF16A34A)
                                          : const Color(0xFFD97706),
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
                                                ? const Color(0xFF15803D)
                                                : const Color(0xFFB45309),
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
                                            backgroundColor: const Color(0xFFE2EFE7),
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

                          // Right: View Cart Button with Alanga Ribbon Gradient + Close Option
                          Material(
                            color: Colors.transparent,
                            child: InkWell(
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
                                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                                decoration: const BoxDecoration(
                                  gradient: AppColors.logoRibbonGradient,
                                  borderRadius: BorderRadius.only(
                                    topRight: Radius.circular(18),
                                    bottomRight: Radius.circular(18),
                                  ),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
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
                                    const SizedBox(width: 8),
                                    // Direct Close "X" Button
                                    GestureDetector(
                                      onTap: () {
                                        setState(() {
                                          _isCartBannerDismissed = true;
                                        });
                                      },
                                      child: Container(
                                        padding: const EdgeInsets.all(3),
                                        decoration: BoxDecoration(
                                          color: Colors.white.withValues(alpha: 0.22),
                                          shape: BoxShape.circle,
                                        ),
                                        child: const Icon(
                                          Icons.close_rounded,
                                          color: Colors.white,
                                          size: 14,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
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
