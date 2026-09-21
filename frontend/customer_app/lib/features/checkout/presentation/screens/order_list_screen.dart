import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/widgets/custom_image_view.dart';
import '../../../../core/widgets/empty_state_widget.dart';
import '../../data/models/order_model.dart';
import '../bloc/order_cubit.dart';
import '../bloc/order_state.dart';
import '../widgets/order_status_badge.dart';
import '../../../reviews/presentation/bloc/customer_reviews_cubit.dart';

class OrderListScreen extends StatefulWidget {
  const OrderListScreen({super.key});

  @override
  State<OrderListScreen> createState() => _OrderListScreenState();
}

class _OrderListScreenState extends State<OrderListScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _selectedFilter = 'ALL';
  String _searchQuery = '';

  final List<String> _statusFilters = [
    'ALL',
    'PENDING',
    'CONFIRMED',
    'PROCESSING',
    'SHIPPED',
    'DELIVERED',
    'CANCELLED',
  ];

  @override
  void initState() {
    super.initState();
    context.read<OrderCubit>().fetchCustomerOrders();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  String _formatDate(DateTime dt) {
    final months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    return '${dt.day} ${months[dt.month - 1]} ${dt.year}';
  }

  List<OrderModel> _filterOrders(List<OrderModel> orders) {
    return orders.where((order) {
      // 1. Status Filter
      if (_selectedFilter != 'ALL') {
        final orderStatus = order.status.toUpperCase();
        if (_selectedFilter == 'PROCESSING') {
          if (orderStatus != 'PROCESSING' && orderStatus != 'PACKED') return false;
        } else if (orderStatus != _selectedFilter) {
          return false;
        }
      }

      // 2. Search Filter (by Order Number or Product Name)
      if (_searchQuery.isNotEmpty) {
        final query = _searchQuery.toLowerCase();
        final matchesOrderNum = order.orderNumber.toLowerCase().contains(query);
        final matchesProduct = order.orderItems.any(
          (item) => item.productNameSnapshot.toLowerCase().contains(query),
        );
        if (!matchesOrderNum && !matchesProduct) return false;
      }

      return true;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F7F5),
      appBar: AppBar(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.transparent,
        elevation: 0.5,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 18, color: Color(0xFF11261B)),
          onPressed: () {
            if (Navigator.of(context).canPop()) {
              Navigator.of(context).pop();
            } else {
              context.go('/home');
            }
          },
        ),
        title: const Text(
          'My Orders',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Color(0xFF11261B),
          ),
        ),
        centerTitle: true,
      ),
      body: BlocBuilder<OrderCubit, OrderState>(
        builder: (context, state) {
          final cubit = context.read<OrderCubit>();
          final List<OrderModel> allOrders = (state is OrderListLoaded)
              ? state.orders
              : (state is OrderDetailLoaded && state.orders.isNotEmpty
                  ? state.orders
                  : cubit.cachedOrders);

          if (state is OrderLoading && allOrders.isEmpty) {
            return const Center(
              child: CircularProgressIndicator(color: AppColors.primaryGreen),
            );
          }

          if (state is OrderError && allOrders.isEmpty) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(28),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.error_outline_rounded, color: AppColors.brandRed, size: 48),
                    const SizedBox(height: 14),
                    Text(
                      state.message,
                      textAlign: TextAlign.center,
                      style: const TextStyle(fontSize: 14, color: Color(0xFF4C6656)),
                    ),
                    const SizedBox(height: 18),
                    ElevatedButton.icon(
                      onPressed: () => context.read<OrderCubit>().fetchCustomerOrders(),
                      icon: const Icon(Icons.refresh_rounded, size: 18),
                      label: const Text('Retry'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primaryGreen,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                    ),
                  ],
                ),
              ),
            );
          }

          if (allOrders.isEmpty && state is! OrderLoading) {
            return EmptyStateWidget(
              icon: Icons.receipt_long_outlined,
              title: 'No Orders Yet',
              description: 'Explore our catalog and place your first order today!',
              buttonText: 'Start Shopping',
              onButtonPressed: () => context.go('/home'),
            );
          }

          final filteredOrders = _filterOrders(allOrders);

          return Column(
            children: [
                // SEARCH & FILTER BAR
                Container(
                  color: Colors.white,
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 10),
                  child: Column(
                    children: [
                      // Search by Order Number
                      TextField(
                        controller: _searchController,
                        onChanged: (val) => setState(() => _searchQuery = val.trim()),
                        decoration: InputDecoration(
                          hintText: 'Search by Order Number or Product...',
                          hintStyle: const TextStyle(fontSize: 13, color: Color(0xFF9EABA2)),
                          prefixIcon: const Icon(Icons.search_rounded, size: 20, color: Color(0xFF7A9A86)),
                          suffixIcon: _searchQuery.isNotEmpty
                              ? IconButton(
                                  icon: const Icon(Icons.clear_rounded, size: 18, color: Colors.grey),
                                  onPressed: () {
                                    _searchController.clear();
                                    setState(() => _searchQuery = '');
                                  },
                                )
                              : null,
                          filled: true,
                          fillColor: const Color(0xFFF4F7F5),
                          isDense: true,
                          contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide.none,
                          ),
                        ),
                      ),
                      const SizedBox(height: 10),

                      // Status Filter Horizontal Chips
                      SizedBox(
                        height: 32,
                        child: ListView.separated(
                          scrollDirection: Axis.horizontal,
                          itemCount: _statusFilters.length,
                          separatorBuilder: (context, index) => const SizedBox(width: 8),
                          itemBuilder: (context, index) {
                            final filter = _statusFilters[index];
                            final isSelected = _selectedFilter == filter;
                            final displayTitle = filter == 'ALL'
                                ? 'All Orders'
                                : OrderStatusBadge.getDisplayStatus(filter);

                            return ChoiceChip(
                              label: Text(displayTitle),
                              selected: isSelected,
                              selectedColor: AppColors.primaryGreen,
                              backgroundColor: const Color(0xFFF1F5F3),
                              showCheckmark: false,
                              labelStyle: TextStyle(
                                fontSize: 11.5,
                                fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                                color: isSelected ? Colors.white : const Color(0xFF4C6656),
                              ),
                              padding: const EdgeInsets.symmetric(horizontal: 4),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                                side: BorderSide(
                                  color: isSelected ? AppColors.primaryGreen : Colors.transparent,
                                ),
                              ),
                              onSelected: (_) => setState(() => _selectedFilter = filter),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),
                const Divider(height: 1, color: Color(0xFFE4ECE8)),

                // ORDER LIST
                Expanded(
                  child: filteredOrders.isEmpty
                      ? Center(
                          child: Padding(
                            padding: const EdgeInsets.all(24),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(Icons.search_off_rounded, size: 48, color: Colors.grey),
                                const SizedBox(height: 12),
                                const Text(
                                  'No matching orders found',
                                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: Color(0xFF11261B)),
                                ),
                                const SizedBox(height: 4),
                                const Text(
                                  'Try adjusting your search query or status filter.',
                                  style: TextStyle(fontSize: 12, color: Colors.grey),
                                ),
                                const SizedBox(height: 16),
                                TextButton(
                                  onPressed: () {
                                    _searchController.clear();
                                    setState(() {
                                      _searchQuery = '';
                                      _selectedFilter = 'ALL';
                                    });
                                  },
                                  child: const Text('Reset Filters'),
                                ),
                              ],
                            ),
                          ),
                        )
                      : RefreshIndicator(
                          color: AppColors.primaryGreen,
                          onRefresh: () => context.read<OrderCubit>().fetchCustomerOrders(),
                          child: ListView.builder(
                            padding: const EdgeInsets.fromLTRB(16, 14, 16, 24),
                            itemCount: filteredOrders.length,
                            itemBuilder: (context, index) {
                              final order = filteredOrders[index];
                              return _buildOrderCard(context, order);
                            },
                          ),
                        ),
                ),
              ],
            );
        },
      ),
    );
  }

  Widget _buildOrderCard(BuildContext context, OrderModel order) {
    final firstItem = order.orderItems.isNotEmpty ? order.orderItems.first : null;
    final totalQty = order.orderItems.fold<int>(0, (sum, item) => sum + item.quantity);
    final hasMultipleItems = order.orderItems.length > 1;

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2EBE6)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () async {
            await context.push('/orders/${order.id}');
            if (context.mounted) {
              context.read<OrderCubit>().restoreOrderList();
            }
          },
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Top row: Order number & Status badge
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.receipt_rounded, size: 16, color: AppColors.primaryGreen),
                        const SizedBox(width: 6),
                        Text(
                          order.orderNumber,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                            color: Color(0xFF11261B),
                          ),
                        ),
                      ],
                    ),
                    OrderStatusBadge(status: order.status),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  'Placed on ${_formatDate(order.createdAt)}',
                  style: const TextStyle(fontSize: 11.5, color: Color(0xFF7A9A86)),
                ),
                const Divider(height: 20, color: Color(0xFFEEF3F0)),

                // Item Details Row
                if (firstItem != null)
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Product Image with optional +X more badge
                      Stack(
                        children: [
                          Container(
                            width: 64,
                            height: 64,
                            decoration: BoxDecoration(
                              color: const Color(0xFFF7FAF8),
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(color: const Color(0xFFE6EFEA)),
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(10),
                              child: CustomImageView(
                                imageUrl: firstItem.imageUrl ?? '',
                                fit: BoxFit.cover,
                                placeholderIcon: Icons.shopping_bag_outlined,
                              ),
                            ),
                          ),
                          if (hasMultipleItems)
                            Positioned(
                              bottom: 2,
                              right: 2,
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                                decoration: BoxDecoration(
                                  color: Colors.black.withValues(alpha: 0.75),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Text(
                                  '+${order.orderItems.length - 1}',
                                  style: const TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.bold),
                                ),
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(width: 12),

                      // Product Name, Variant, Quantity
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              firstItem.productNameSnapshot,
                              style: const TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF11261B),
                                height: 1.25,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 3),
                            if (firstItem.variantNameSnapshot != null &&
                                firstItem.variantNameSnapshot!.isNotEmpty &&
                                firstItem.variantNameSnapshot != 'Default Variant') ...[
                              Text(
                                'Variant: ${firstItem.variantNameSnapshot}',
                                style: const TextStyle(fontSize: 11, color: Color(0xFF5A7265)),
                              ),
                              const SizedBox(height: 2),
                            ],
                            Text(
                              'Qty: $totalQty ${totalQty == 1 ? "item" : "items"}',
                              style: const TextStyle(fontSize: 11, color: Colors.grey),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),

                const SizedBox(height: 12),

                // Bottom row: Total Amount and "View Details"
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Total Amount',
                          style: TextStyle(fontSize: 11, color: Colors.grey),
                        ),
                        Text(
                          '₹${order.totalAmount.toStringAsFixed(0)}',
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                            color: AppColors.primaryGreen,
                          ),
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        if (order.status == 'DELIVERED' && firstItem != null) ...[
                          Builder(
                            builder: (context) {
                              final reviewsState = context.watch<CustomerReviewsCubit>().state;
                              final existingReview = reviewsState.getReviewForProduct(firstItem.productId);
                              final hasReviewed = existingReview != null;

                              return Padding(
                                padding: const EdgeInsets.only(right: 8.0),
                                child: OutlinedButton.icon(
                                  onPressed: () async {
                                    final res = await context.push('/reviews/write', extra: {
                                      'productId': firstItem.productId,
                                      'productName': firstItem.productNameSnapshot,
                                      'productImage': firstItem.imageUrl,
                                      'orderId': order.id,
                                      'variantId': firstItem.productVariantId,
                                      'variantName': firstItem.variantNameSnapshot,
                                      'existingReview': existingReview,
                                    });
                                    if (res == true && context.mounted) {
                                      context.read<CustomerReviewsCubit>().loadCustomerReviews();
                                    }
                                  },
                                  icon: Icon(
                                    hasReviewed ? Icons.edit_rounded : Icons.star_rounded,
                                    size: 13,
                                    color: const Color(0xFFD97706),
                                  ),
                                  label: Text(
                                    hasReviewed ? 'Edit Review' : 'Review',
                                    style: const TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.bold,
                                      color: Color(0xFFD97706),
                                    ),
                                  ),
                                  style: OutlinedButton.styleFrom(
                                    side: const BorderSide(color: Color(0xFFFDE68A)),
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                    visualDensity: VisualDensity.compact,
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                  ),
                                ),
                              );
                            },
                          ),
                        ],
                        OutlinedButton.icon(
                          onPressed: () async {
                            await context.push('/orders/${order.id}/track', extra: order);
                            if (context.mounted) {
                              context.read<OrderCubit>().restoreOrderList();
                            }
                          },
                          icon: const Icon(Icons.alt_route_rounded, size: 14, color: AppColors.primaryGreen),
                          label: const Text(
                            'Track',
                            style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.bold, color: AppColors.primaryGreen),
                          ),
                          style: OutlinedButton.styleFrom(
                            side: const BorderSide(color: AppColors.primaryGreen, width: 1),
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            visualDensity: VisualDensity.compact,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                          ),
                        ),
                        const SizedBox(width: 10),
                        const Row(
                          children: [
                            Text(
                              'Details',
                              style: TextStyle(
                                fontSize: 12.5,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF11261B),
                              ),
                            ),
                            SizedBox(width: 2),
                            Icon(
                              Icons.arrow_forward_ios_rounded,
                              size: 11,
                              color: Color(0xFF11261B),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
