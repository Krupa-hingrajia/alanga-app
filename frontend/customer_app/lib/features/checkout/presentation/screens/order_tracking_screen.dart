import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/widgets/custom_image_view.dart';
import '../../../../core/dependency_injection/injection.dart';
import '../../data/models/order_model.dart';
import '../bloc/order_detail_cubit.dart';
import '../bloc/order_detail_state.dart';
import '../widgets/order_status_badge.dart';
import '../widgets/order_timeline_stepper.dart';

class OrderTrackingScreen extends StatefulWidget {
  final String orderId;
  final OrderModel? order;

  const OrderTrackingScreen({
    super.key,
    required this.orderId,
    this.order,
  });

  @override
  State<OrderTrackingScreen> createState() => _OrderTrackingScreenState();
}

class _OrderTrackingScreenState extends State<OrderTrackingScreen> {
  late final OrderDetailCubit _cubit;
  OrderModel? _cachedOrder;

  @override
  void initState() {
    super.initState();
    _cubit = sl<OrderDetailCubit>();
    _cachedOrder = widget.order;
    if (_cachedOrder == null) {
      _cubit.fetchOrderById(widget.orderId);
    }
  }

  @override
  void dispose() {
    _cubit.close();
    super.dispose();
  }

  String _formatDateTime(DateTime dt) {
    final months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    final hour = dt.hour > 12 ? dt.hour - 12 : (dt.hour == 0 ? 12 : dt.hour);
    final period = dt.hour >= 12 ? 'PM' : 'AM';
    final minute = dt.minute.toString().padLeft(2, '0');
    return '${dt.day} ${months[dt.month - 1]} ${dt.year}, $hour:$minute $period';
  }

  String _formatEstimatedDelivery(DateTime orderDate) {
    final start = orderDate.add(const Duration(days: 3));
    final end = orderDate.add(const Duration(days: 7));
    final months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    return '${start.day} ${months[start.month - 1]} - ${end.day} ${months[end.month - 1]} ${end.year}';
  }

  void _handleCancelOrder(OrderModel order) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.brandRed.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.cancel_outlined, color: AppColors.brandRed, size: 24),
            ),
            const SizedBox(width: 10),
            const Expanded(
              child: Text(
                'Cancel Order?',
                style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
        content: Text(
          'Are you sure you want to cancel Order #${order.orderNumber}?',
          style: const TextStyle(fontSize: 14, color: Color(0xFF4C6656)),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Back', style: TextStyle(color: Color(0xFF6B7280))),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: const Text('Order cancellation request submitted'),
                  backgroundColor: AppColors.primaryGreen,
                  behavior: SnackBarBehavior.floating,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.brandRed,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            child: const Text('Request Cancellation'),
          ),
        ],
      ),
    );
  }

  void _handleBuyAgain(OrderItemModel item) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Added "${item.productNameSnapshot}" to cart!'),
        backgroundColor: AppColors.primaryGreen,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        action: SnackBarAction(
          label: 'VIEW CART',
          textColor: Colors.white,
          onPressed: () => context.push('/cart'),
        ),
      ),
    );
  }

  void _handleReviewProduct(OrderItemModel item) async {
    await context.push('/reviews/write', extra: {
      'productId': item.productId,
      'productName': item.productNameSnapshot,
      'productImage': item.imageUrl,
      'orderId': widget.orderId,
      'variantId': item.productVariantId,
      'variantName': item.variantNameSnapshot,
    });
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: _cubit,
      child: Scaffold(
        backgroundColor: const Color(0xFFF4F7F5),
        appBar: AppBar(
          backgroundColor: Colors.white,
          surfaceTintColor: Colors.transparent,
          elevation: 0.5,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 18, color: Color(0xFF11261B)),
            onPressed: () => context.pop(),
          ),
          title: const Text(
            'Track Order',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Color(0xFF11261B),
            ),
          ),
          centerTitle: true,
          actions: [
            IconButton(
              icon: const Icon(Icons.refresh_rounded, color: AppColors.primaryGreen),
              tooltip: 'Refresh Status',
              onPressed: () => _cubit.fetchOrderById(widget.orderId),
            ),
          ],
        ),
        body: BlocConsumer<OrderDetailCubit, OrderDetailState>(
          listener: (context, state) {
            if (state is OrderDetailSuccess) {
              setState(() => _cachedOrder = state.order);
            }
          },
          builder: (context, state) {
            if (state is OrderDetailLoading && _cachedOrder == null) {
              return const Center(
                child: CircularProgressIndicator(color: AppColors.primaryGreen),
              );
            }

            if (state is OrderDetailFailure && _cachedOrder == null) {
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
                        onPressed: () => _cubit.fetchOrderById(widget.orderId),
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

          final order = _cachedOrder;
          if (order == null) return const SizedBox.shrink();

          final isPending = order.status.toUpperCase() == 'PENDING';
          final isDelivered = order.status.toUpperCase() == 'DELIVERED';

          return RefreshIndicator(
            color: AppColors.primaryGreen,
            onRefresh: () async {
              await _cubit.fetchOrderById(widget.orderId);
            },
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 1. ORDER SUMMARY & STATUS HEADER CARD
                  _buildHeaderCard(order),
                  const SizedBox(height: 16),

                  // 2. ESTIMATED DELIVERY CARD
                  _buildEstimatedDeliveryCard(order),
                  const SizedBox(height: 16),

                  // 3. VERTICAL TIMELINE ORDER STATUS
                  _buildTimelineCard(order),
                  const SizedBox(height: 16),

                  // 4. DELIVERY ADDRESS CARD
                  _buildAddressCard(order),
                  const SizedBox(height: 16),

                  // 5. ORDER ITEMS CARD
                  _buildOrderItemsCard(order, isDelivered),
                  const SizedBox(height: 16),

                  // 6. PRICE DETAILS CARD
                  _buildPriceDetailsCard(order),
                  const SizedBox(height: 16),

                  // 7. PAYMENT DETAILS CARD
                  _buildPaymentDetailsCard(order),
                  const SizedBox(height: 20),

                  // 8. ORDER ACTIONS (Pending: Cancel Order; Delivered: Buy Again)
                  if (isPending) ...[
                    SizedBox(
                      width: double.infinity,
                      height: 48,
                      child: OutlinedButton.icon(
                        onPressed: () => _handleCancelOrder(order),
                        icon: const Icon(Icons.cancel_outlined, color: AppColors.brandRed, size: 18),
                        label: const Text(
                          'CANCEL ORDER',
                          style: TextStyle(
                            color: AppColors.brandRed,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 0.5,
                          ),
                        ),
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(color: AppColors.brandRed, width: 1.4),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                      ),
                    ),
                    const SizedBox(height: 14),
                  ],

                  // Support assistance link
                  Center(
                    child: TextButton.icon(
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Support helpline: support@alanga.com | 1800-ALANGA'),
                            backgroundColor: Color(0xFF1A3827),
                          ),
                        );
                      },
                      icon: const Icon(Icons.support_agent_rounded, size: 18, color: Color(0xFF5A7265)),
                      label: const Text(
                        'Have questions about delivery? Contact Support',
                        style: TextStyle(fontSize: 12.5, color: Color(0xFF5A7265), fontWeight: FontWeight.w600),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    ),
  );
  }

  // ==========================================
  // 1. ORDER SUMMARY HEADER
  // ==========================================
  Widget _buildHeaderCard(OrderModel order) {
    return Container(
      padding: const EdgeInsets.all(16),
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Order Number', style: TextStyle(fontSize: 11, color: Colors.grey, fontWeight: FontWeight.w500)),
                  const SizedBox(height: 2),
                  Text(
                    order.orderNumber,
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Color(0xFF11261B)),
                  ),
                ],
              ),
              OrderStatusBadge(status: order.status, isLarge: true),
            ],
          ),
          const Divider(height: 20, color: Color(0xFFEEF3F0)),
          Row(
            children: [
              const Icon(Icons.calendar_today_rounded, size: 13, color: Color(0xFF7A9A86)),
              const SizedBox(width: 6),
              Text(
                'Placed on ${_formatDateTime(order.createdAt)}',
                style: const TextStyle(fontSize: 12, color: Color(0xFF5A7265)),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ==========================================
  // 2. ESTIMATED DELIVERY CARD
  // ==========================================
  Widget _buildEstimatedDeliveryCard(OrderModel order) {
    final isDelivered = order.status.toUpperCase() == 'DELIVERED';
    final isCancelled = order.status.toUpperCase() == 'CANCELLED';

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isCancelled
              ? [const Color(0xFFFEF2F2), const Color(0xFFFEE2E2)]
              : (isDelivered
                  ? [const Color(0xFFECFDF5), const Color(0xFFD1FAE5)]
                  : [const Color(0xFFF0FDF4), const Color(0xFFE6F7ED)]),
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isCancelled
              ? const Color(0xFFFECACA)
              : (isDelivered ? const Color(0xFFA7F3D0) : const Color(0xFFBBE5D0)),
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: isCancelled
                  ? AppColors.brandRed.withValues(alpha: 0.15)
                  : AppColors.primaryGreen.withValues(alpha: 0.15),
              shape: BoxShape.circle,
            ),
            child: Icon(
              isCancelled
                  ? Icons.cancel_rounded
                  : (isDelivered ? Icons.check_circle_rounded : Icons.local_shipping_rounded),
              color: isCancelled ? AppColors.brandRed : AppColors.primaryGreen,
              size: 24,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  isCancelled
                      ? 'Order Status'
                      : (isDelivered ? 'Delivery Completed' : 'Estimated Delivery'),
                  style: TextStyle(
                    fontSize: 11.5,
                    fontWeight: FontWeight.w600,
                    color: isCancelled ? const Color(0xFF991B1B) : AppColors.darkGreen,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  isCancelled
                      ? 'Order was Cancelled'
                      : (isDelivered
                          ? 'Delivered on ${_formatDateTime(order.updatedAt)}'
                          : _formatEstimatedDelivery(order.createdAt)),
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: isCancelled ? AppColors.brandRed : const Color(0xFF11261B),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ==========================================
  // 3. VERTICAL TIMELINE ORDER STATUS
  // ==========================================
  Widget _buildTimelineCard(OrderModel order) {
    return Container(
      padding: const EdgeInsets.all(18),
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.alt_route_rounded, color: AppColors.primaryGreen, size: 20),
              SizedBox(width: 8),
              Text(
                'Live Order Journey',
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Color(0xFF11261B)),
              ),
            ],
          ),
          const Divider(height: 20, color: Color(0xFFEEF3F0)),
          OrderTimelineStepper(
            currentStatus: order.status,
            orderDate: order.createdAt,
            isDetailed: true,
          ),
        ],
      ),
    );
  }

  // ==========================================
  // 4. DELIVERY ADDRESS
  // ==========================================
  Widget _buildAddressCard(OrderModel order) {
    final addr = order.shippingAddressSnapshot ?? {};
    final addressModel = order.address;

    final fullName = addr['fullName'] ?? addressModel?.fullName ?? 'Recipient';
    final mobileNumber = addr['mobileNumber'] ?? addressModel?.mobileNumber ?? '';
    final line1 = addr['addressLine1'] ?? addressModel?.addressLine1 ?? '';
    final line2 = addr['addressLine2'] ?? addressModel?.addressLine2 ?? '';
    final landmark = addr['landmark'] ?? addressModel?.landmark ?? '';
    final city = addr['city'] ?? addressModel?.city ?? '';
    final state = addr['state'] ?? addressModel?.state ?? '';
    final postalCode = addr['postalCode'] ?? addressModel?.postalCode ?? '';
    final country = addr['country'] ?? addressModel?.country ?? 'India';
    final addressType = addr['addressType'] ?? addressModel?.addressType ?? 'HOME';

    final fullAddressText = [
      line1,
      if (line2.isNotEmpty) line2,
      if (landmark.isNotEmpty) 'Near $landmark',
      '$city, $state - $postalCode',
      country,
    ].where((e) => e.isNotEmpty).join(', ');

    return Container(
      padding: const EdgeInsets.all(16),
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.location_on_outlined, color: AppColors.primaryGreen, size: 20),
              const SizedBox(width: 8),
              const Text(
                'Delivery Address',
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Color(0xFF11261B)),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: const Color(0xFFEBF3EE),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  addressType,
                  style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: AppColors.darkGreen),
                ),
              ),
            ],
          ),
          const Divider(height: 16, color: Color(0xFFEEF3F0)),
          Text(
            fullName,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Color(0xFF11261B)),
          ),
          const SizedBox(height: 4),
          Text(
            fullAddressText,
            style: const TextStyle(fontSize: 12.5, color: Color(0xFF4C6656), height: 1.35),
          ),
          if (mobileNumber.isNotEmpty) ...[
            const SizedBox(height: 6),
            Row(
              children: [
                const Icon(Icons.phone_outlined, size: 14, color: AppColors.primaryGreen),
                const SizedBox(width: 6),
                Text(
                  'Phone: $mobileNumber',
                  style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Color(0xFF11261B)),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  // ==========================================
  // 5. ORDER ITEMS
  // ==========================================
  Widget _buildOrderItemsCard(OrderModel order, bool isDelivered) {
    return Container(
      padding: const EdgeInsets.all(16),
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Row(
                children: [
                  Icon(Icons.inventory_2_outlined, color: AppColors.primaryGreen, size: 20),
                  SizedBox(width: 8),
                  Text(
                    'Order Items',
                    style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Color(0xFF11261B)),
                  ),
                ],
              ),
              Text(
                '${order.orderItems.length} ${order.orderItems.length == 1 ? "item" : "items"}',
                style: const TextStyle(fontSize: 12, color: Colors.grey, fontWeight: FontWeight.w500),
              ),
            ],
          ),
          const Divider(height: 20, color: Color(0xFFEEF3F0)),
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: order.orderItems.length,
            separatorBuilder: (context, index) => const Divider(height: 24, color: Color(0xFFEEF3F0)),
            itemBuilder: (context, idx) {
              final item = order.orderItems[idx];
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Product Image
                      Container(
                        width: 68,
                        height: 68,
                        decoration: BoxDecoration(
                          color: const Color(0xFFF7FAF8),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: const Color(0xFFE6EFEA)),
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: CustomImageView(
                            imageUrl: item.imageUrl ?? '',
                            fit: BoxFit.cover,
                            placeholderIcon: Icons.shopping_bag_outlined,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),

                      // Item Details: Name, Variant, SKU, Qty, Price
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              item.productNameSnapshot,
                              style: const TextStyle(
                                fontSize: 13.5,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF11261B),
                                height: 1.25,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 3),
                            if (item.variantNameSnapshot != null &&
                                item.variantNameSnapshot!.isNotEmpty &&
                                item.variantNameSnapshot != 'Default Variant') ...[
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1.5),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFF1F5F3),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Text(
                                  'Variant: ${item.variantNameSnapshot}',
                                  style: const TextStyle(fontSize: 10.5, fontWeight: FontWeight.w600, color: Color(0xFF4C6656)),
                                ),
                              ),
                              const SizedBox(height: 3),
                            ],
                            if (item.sku.isNotEmpty) ...[
                              Text('SKU: ${item.sku}', style: const TextStyle(fontSize: 10.5, color: Colors.grey)),
                              const SizedBox(height: 3),
                            ],
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'Qty: ${item.quantity} • ₹${item.unitPrice.toStringAsFixed(0)} each',
                                  style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: Color(0xFF5A7265)),
                                ),
                                Text(
                                  '₹${item.totalPrice.toStringAsFixed(0)}',
                                  style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.primaryGreen),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),

                  // Actions for Delivered items: Buy Again & Review Product
                  if (isDelivered) ...[
                    const SizedBox(height: 10),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        OutlinedButton.icon(
                          onPressed: () => _handleReviewProduct(item),
                          icon: const Icon(Icons.star_outline_rounded, size: 15, color: Color(0xFFD97706)),
                          label: const Text('Review', style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.bold, color: Color(0xFFD97706))),
                          style: OutlinedButton.styleFrom(
                            side: const BorderSide(color: Color(0xFFFDE68A)),
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            visualDensity: VisualDensity.compact,
                          ),
                        ),
                        const SizedBox(width: 8),
                        ElevatedButton.icon(
                          onPressed: () => _handleBuyAgain(item),
                          icon: const Icon(Icons.repeat_rounded, size: 15),
                          label: const Text('Buy Again', style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.bold)),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF1A3827),
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                            visualDensity: VisualDensity.compact,
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
              );
            },
          ),
        ],
      ),
    );
  }

  // ==========================================
  // 6. PRICE DETAILS
  // ==========================================
  Widget _buildPriceDetailsCard(OrderModel order) {
    final isFreeShipping = order.shippingCharge <= 0;

    return Container(
      padding: const EdgeInsets.all(16),
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.receipt_long_outlined, color: AppColors.primaryGreen, size: 20),
              SizedBox(width: 8),
              Text(
                'Price Summary',
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Color(0xFF11261B)),
              ),
            ],
          ),
          const Divider(height: 16, color: Color(0xFFEEF3F0)),
          _buildRow('Subtotal', '₹${order.subtotal.toStringAsFixed(0)}'),
          const SizedBox(height: 8),
          _buildRow(
            'Shipping Charges',
            isFreeShipping ? 'FREE' : '₹${order.shippingCharge.toStringAsFixed(0)}',
            valueColor: isFreeShipping ? AppColors.primaryGreen : null,
          ),
          const Divider(height: 20, color: Color(0xFFEEF3F0)),
          _buildRow(
            'Grand Total',
            '₹${order.totalAmount.toStringAsFixed(0)}',
            isBold: true,
            valueColor: AppColors.primaryGreen,
            fontSize: 16,
          ),
        ],
      ),
    );
  }

  // ==========================================
  // 7. PAYMENT DETAILS
  // ==========================================
  Widget _buildPaymentDetailsCard(OrderModel order) {
    final isCod = order.paymentMethod == 'COD';

    return Container(
      padding: const EdgeInsets.all(16),
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.payments_outlined, color: AppColors.primaryGreen, size: 20),
              SizedBox(width: 8),
              Text(
                'Payment Details',
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Color(0xFF11261B)),
              ),
            ],
          ),
          const Divider(height: 16, color: Color(0xFFEEF3F0)),
          _buildRow('Payment Method', isCod ? 'Cash on Delivery (COD)' : order.paymentMethod),
          const SizedBox(height: 8),
          _buildRow(
            'Payment Status',
            order.paymentStatus,
            valueColor: order.paymentStatus.toUpperCase() == 'PAID'
                ? AppColors.primaryGreen
                : const Color(0xFFD97706),
          ),
        ],
      ),
    );
  }

  Widget _buildRow(
    String label,
    String value, {
    bool isBold = false,
    Color? valueColor,
    double fontSize = 13,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: fontSize,
            color: isBold ? const Color(0xFF11261B) : const Color(0xFF5A7265),
            fontWeight: isBold ? FontWeight.bold : FontWeight.w500,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: fontSize,
            color: valueColor ?? const Color(0xFF11261B),
            fontWeight: isBold ? FontWeight.bold : FontWeight.w600,
          ),
        ),
      ],
    );
  }
}
