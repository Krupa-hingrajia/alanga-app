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
      body: IndexedStack(
        index: _selectedIndex,
        children: _screens,
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
