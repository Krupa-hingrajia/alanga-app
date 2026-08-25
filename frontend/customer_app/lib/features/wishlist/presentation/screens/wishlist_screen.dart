import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/dependency_injection/injection.dart';
import '../bloc/wishlist_bloc.dart';
import '../bloc/wishlist_event.dart';
import '../bloc/wishlist_state.dart';
import '../widgets/wishlist_card.dart';
import '../widgets/empty_wishlist_widget.dart';

class WishlistScreen extends StatefulWidget {
  const WishlistScreen({super.key});

  @override
  State<WishlistScreen> createState() => _WishlistScreenState();
}

class _WishlistScreenState extends State<WishlistScreen> {
  late WishlistBloc _wishlistBloc;

  @override
  void initState() {
    super.initState();
    _wishlistBloc = sl<WishlistBloc>();
    _wishlistBloc.add(const FetchWishlistEvent());
  }

  void _showRemoveConfirmationDialog(BuildContext context, String wishlistId, String productName) {
    showDialog(
      context: context,
      builder: (dialogCtx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Row(
          children: [
            Icon(Icons.heart_broken_rounded, color: AppColors.brandRed, size: 24),
            SizedBox(width: 10),
            Text(
              'Remove from Wishlist',
              style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold, color: Color(0xFF11261B)),
            ),
          ],
        ),
        content: Text(
          'Are you sure you want to remove "$productName" from your Wishlist?',
          style: const TextStyle(fontSize: 13.5, color: Color(0xFF4C6656), height: 1.4),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogCtx),
            child: const Text('CANCEL', style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold)),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(dialogCtx);
              _wishlistBloc.add(RemoveWishlistItemEvent(wishlistId: wishlistId));
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.brandRed,
              foregroundColor: Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            child: const Text('REMOVE', style: TextStyle(fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: _wishlistBloc,
      child: Scaffold(
        backgroundColor: const Color(0xFFF6F8F6),
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          title: BlocBuilder<WishlistBloc, WishlistState>(
            builder: (context, state) {
              int count = 0;
              if (state is WishlistLoaded) {
                count = state.items.length;
              }
              return Text(
                count > 0 ? 'My Wishlist ($count)' : 'My Wishlist',
                style: const TextStyle(
                  color: Color(0xFF11261B),
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              );
            },
          ),
          centerTitle: true,
          iconTheme: const IconThemeData(color: Color(0xFF11261B)),
          actions: [
            IconButton(
              icon: const Icon(Icons.share_outlined, color: Color(0xFF11261B)),
              onPressed: () {
                ScaffoldMessenger.of(context).hideCurrentSnackBar();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Wishlist share link copied!'),
                    backgroundColor: AppColors.primaryGreen,
                    behavior: SnackBarBehavior.floating,
                  ),
                );
              },
            ),
          ],
        ),
        body: BlocConsumer<WishlistBloc, WishlistState>(
          listener: (context, state) {
            if (state is WishlistActionSuccess) {
              ScaffoldMessenger.of(context).hideCurrentSnackBar();
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(state.message),
                  backgroundColor: AppColors.primaryGreen,
                  behavior: SnackBarBehavior.floating,
                  duration: const Duration(seconds: 2),
                ),
              );
            } else if (state is WishlistError) {
              ScaffoldMessenger.of(context).hideCurrentSnackBar();
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(state.message),
                  backgroundColor: AppColors.brandRed,
                  behavior: SnackBarBehavior.floating,
                ),
              );
            }
          },
          builder: (context, state) {
            if (state is WishlistLoading && state is! WishlistLoaded) {
              return _buildShimmerLoading();
            }

            if (state is WishlistError && state is! WishlistLoaded) {
              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.wifi_off_rounded, size: 48, color: Colors.grey),
                      const SizedBox(height: 14),
                      Text(
                        state.message,
                        style: const TextStyle(fontSize: 14, color: Colors.grey),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: () => _wishlistBloc.add(const FetchWishlistEvent()),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primaryGreen,
                          foregroundColor: Colors.white,
                        ),
                        child: const Text('RETRY'),
                      ),
                    ],
                  ),
                ),
              );
            }

            final items = state is WishlistLoaded ? state.items : [];

            if (items.isEmpty) {
              return RefreshIndicator(
                color: AppColors.primaryGreen,
                onRefresh: () async {
                  _wishlistBloc.add(const FetchWishlistEvent());
                },
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  child: SizedBox(
                    height: MediaQuery.of(context).size.height * 0.75,
                    child: EmptyWishlistWidget(
                      onContinueShopping: () {
                        context.go('/products');
                      },
                    ),
                  ),
                ),
              );
            }

            return RefreshIndicator(
              color: AppColors.primaryGreen,
              onRefresh: () async {
                _wishlistBloc.add(const FetchWishlistEvent());
              },
              child: ListView.builder(
                padding: const EdgeInsets.all(16),
                physics: const AlwaysScrollableScrollPhysics(),
                itemCount: items.length + 1,
                itemBuilder: (context, index) {
                  if (index == 0) {
                    // Header Bar: Move All to Cart & Quick Summary
                    return Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: const Color(0xFFE4ECE8)),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.favorite_rounded, color: AppColors.brandRed, size: 18),
                          const SizedBox(width: 8),
                          Text(
                            '${items.length} Saved Items',
                            style: const TextStyle(
                              fontSize: 12.5,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF11261B),
                            ),
                          ),
                          const Spacer(),
                          TextButton.icon(
                            onPressed: () {
                              ScaffoldMessenger.of(context).hideCurrentSnackBar();
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('All available Wishlist items moved to Cart!'),
                                  backgroundColor: AppColors.primaryGreen,
                                  behavior: SnackBarBehavior.floating,
                                ),
                              );
                            },
                            icon: const Icon(Icons.shopping_cart_checkout_rounded, size: 14),
                            label: const Text(
                              'MOVE ALL TO CART',
                              style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold),
                            ),
                            style: TextButton.styleFrom(
                              foregroundColor: AppColors.primaryGreen,
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            ),
                          ),
                        ],
                      ),
                    );
                  }

                  final item = items[index - 1];
                  return WishlistCard(
                    key: ValueKey(item.id),
                    item: item,
                    onTap: () {
                      context.push('/products/details', extra: item.product);
                    },
                    onRemove: () {
                      _showRemoveConfirmationDialog(context, item.id, item.product.name);
                    },
                    onVariantChanged: (newVariant) {
                      _wishlistBloc.add(ToggleWishlistEvent(
                        productId: item.productId,
                        productVariantId: newVariant.id,
                      ));
                    },
                    onMoveToCart: (selectedVariant) {
                      final variantInfo = ' (${selectedVariant.variantName})';
                      ScaffoldMessenger.of(context).hideCurrentSnackBar();
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Moved ${item.product.name}$variantInfo to Cart!'),
                          backgroundColor: AppColors.primaryGreen,
                          behavior: SnackBarBehavior.floating,
                        ),
                      );
                    },
                  );
                },
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildShimmerLoading() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: 4,
      itemBuilder: (context, index) {
        return Container(
          margin: const EdgeInsets.only(bottom: 14),
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: const Color(0xFFE4ECE8)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 90,
                    height: 90,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade200,
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(width: 60, height: 10, color: Colors.grey.shade200),
                        const SizedBox(height: 8),
                        Container(width: 150, height: 14, color: Colors.grey.shade200),
                        const SizedBox(height: 8),
                        Container(width: 80, height: 14, color: Colors.grey.shade200),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Container(width: double.infinity, height: 32, color: Colors.grey.shade100),
            ],
          ),
        );
      },
    );
  }
}
