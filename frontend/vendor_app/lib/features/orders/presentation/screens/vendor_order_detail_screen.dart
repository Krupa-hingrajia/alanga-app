import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/widgets/custom_image_view.dart';
import '../../../../core/dependency_injection/injection.dart';
import '../../data/models/vendor_order_model.dart';
import '../bloc/vendor_order_bloc.dart';
import '../bloc/vendor_order_event.dart';
import '../bloc/vendor_order_state.dart';
import '../widgets/vendor_order_status_badge.dart';
import '../widgets/order_status_timeline.dart';

class VendorOrderDetailScreen extends StatefulWidget {
  final VendorOrderModel order;

  const VendorOrderDetailScreen({
    super.key,
    required this.order,
  });

  @override
  State<VendorOrderDetailScreen> createState() => _VendorOrderDetailScreenState();
}

class _VendorOrderDetailScreenState extends State<VendorOrderDetailScreen> {
  late VendorOrderModel _currentOrder;
  bool _statusChanged = false;

  @override
  void initState() {
    super.initState();
    _currentOrder = widget.order;
  }

  String _formatDate(DateTime date) {
    final months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    final day = date.day.toString().padLeft(2, '0');
    final month = months[date.month - 1];
    final year = date.year;
    final hour = date.hour.toString().padLeft(2, '0');
    final minute = date.minute.toString().padLeft(2, '0');
    return '$day $month $year, $hour:$minute';
  }

  void _confirmStatusAdvance(BuildContext context, String nextStatus, String actionLabel) {
    final bloc = context.read<VendorOrderBloc>();
    showDialog(
      context: context,
      builder: (dialogCtx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.primaryGreen.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.sync_alt_rounded, color: AppColors.primaryGreen, size: 22),
            ),
            const SizedBox(width: 12),
            const Expanded(
              child: Text(
                'Advance Order Status',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Advance order #${_currentOrder.orderNumber} to:',
              style: const TextStyle(fontSize: 14, color: Color(0xFF4B5563)),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: const Color(0xFFF3F4F6),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    _currentOrder.status,
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                  ),
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 10),
                    child: Icon(Icons.arrow_forward_rounded, size: 16, color: Colors.grey),
                  ),
                  Text(
                    nextStatus,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                      color: AppColors.primaryGreen,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),
            const Text(
              'Once updated, the order moves to the next fulfillment stage. Are you sure you want to proceed?',
              style: TextStyle(fontSize: 13, color: Color(0xFF6B7280), height: 1.4),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogCtx).pop(),
            child: const Text('Cancel', style: TextStyle(color: Color(0xFF6B7280))),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(dialogCtx).pop();
              bloc.add(UpdateOrderStatusEvent(
                orderId: _currentOrder.id,
                newStatus: nextStatus,
              ));
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF1A3827),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            child: Text(actionLabel),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<VendorOrderBloc>()..add(InitOrderDetailEvent(order: widget.order)),
      child: PopScope(
        canPop: false,
        onPopInvokedWithResult: (didPop, _) {
          if (didPop) return;
          context.pop(_statusChanged);
        },
        child: Scaffold(
          backgroundColor: const Color(0xFFF6F8F6),
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            scrolledUnderElevation: 0,
            automaticallyImplyLeading: false,
            leadingWidth: 56,
            leading: Center(
              child: Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                  border: Border.all(color: const Color(0xFFE4ECE8)),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.04),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: IconButton(
                  padding: EdgeInsets.zero,
                  icon: const Icon(
                    Icons.arrow_back,
                    size: 18,
                    color: Color(0xFF1A3827),
                  ),
                  onPressed: () => context.pop(_statusChanged),
                ),
              ),
            ),
            title: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Order #${_currentOrder.orderNumber}',
                  style: const TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF11261B),
                  ),
                ),
                Text(
                  _formatDate(_currentOrder.createdAt),
                  style: const TextStyle(
                    fontSize: 11,
                    color: Color(0xFF8B9E94),
                  ),
                ),
              ],
            ),
            actions: [
              Padding(
                padding: const EdgeInsets.only(right: 16),
                child: Center(
                  child: VendorOrderStatusBadge(status: _currentOrder.status),
                ),
              ),
            ],
          ),
          body: BlocConsumer<VendorOrderBloc, VendorOrderState>(
            listener: (context, state) {
              if (state is VendorOrderLoaded) {
                if (state.actionMessage != null) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(state.actionMessage!),
                      backgroundColor: AppColors.primaryGreen,
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                  // Update local model
                  final updated = state.allOrders.firstWhere(
                    (o) => o.id == _currentOrder.id,
                    orElse: () => _currentOrder,
                  );
                  setState(() {
                    _currentOrder = updated;
                    _statusChanged = true;
                  });
                } else if (state.errorMessage != null) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(state.errorMessage!),
                      backgroundColor: AppColors.brandRed,
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                }
              }
            },
            builder: (context, state) {
              return SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 100),
                physics: const BouncingScrollPhysics(),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // ── Status Banner (if delivered or cancelled) ────────
                    if (_currentOrder.status == 'DELIVERED')
                      _buildDeliveredBanner()
                    else if (_currentOrder.status == 'CANCELLED')
                      _buildCancelledBanner(),

                    const SizedBox(height: 12),

                    // ── Section 1: Customer Details ──────────────────────
                    _buildCustomerSection(),

                    const SizedBox(height: 16),

                    // ── Section 2: Delivery Address ─────────────────────
                    _buildAddressSection(),

                    const SizedBox(height: 16),

                    // ── Section 3: Ordered Products ─────────────────────
                    _buildOrderedProductsSection(),

                    const SizedBox(height: 16),

                    // ── Section 4: Price Breakdown ──────────────────────
                    _buildPriceSummarySection(),

                    const SizedBox(height: 16),

                    // ── Section 5: Order Timeline ───────────────────────
                    OrderStatusTimeline(
                      currentStatus: _currentOrder.status,
                      orderDate: _currentOrder.createdAt,
                      updatedAt: _currentOrder.updatedAt,
                      cancelReason: _currentOrder.cancelReason,
                    ),
                  ],
                ),
              );
            },
          ),
          bottomNavigationBar: _buildBottomActionBar(context),
        ),
      ),
    );
  }

  Widget _buildDeliveredBanner() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFF0FDF4),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFBBF7D0)),
      ),
      child: const Row(
        children: [
          Icon(Icons.check_circle_rounded, color: Color(0xFF16A34A), size: 24),
          SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Order Completed & Delivered',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF166534),
                  ),
                ),
                SizedBox(height: 2),
                Text(
                  'This order has been fulfilled. No further status changes can be made.',
                  style: TextStyle(fontSize: 12, color: Color(0xFF15803D)),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCancelledBanner() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFFEF2F2),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFFECACA)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.cancel_rounded, color: Color(0xFFDC2626), size: 24),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Order Cancelled',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF991B1B),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  _currentOrder.cancelReason != null && _currentOrder.cancelReason!.isNotEmpty
                      ? 'Reason: ${_currentOrder.cancelReason}'
                      : 'This order was cancelled and cannot be fulfilled.',
                  style: const TextStyle(fontSize: 12, color: Color(0xFFB91C1C)),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCustomerSection() {
    final customer = _currentOrder.customer;

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFE4ECE8)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFF1A3827).withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.person_rounded, size: 20, color: Color(0xFF1A3827)),
              ),
              const SizedBox(width: 12),
              const Text(
                'Customer Details',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF11261B),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          _buildInfoRow(
            icon: Icons.account_circle_outlined,
            label: 'Name',
            value: customer?.fullName ?? 'Customer',
          ),
          const SizedBox(height: 10),
          if (customer?.phoneNumber != null && customer!.phoneNumber.isNotEmpty) ...[
            _buildInfoRow(
              icon: Icons.phone_outlined,
              label: 'Phone',
              value: customer.phoneNumber,
            ),
            const SizedBox(height: 10),
          ],
          if (customer?.email != null && customer!.email.isNotEmpty)
            _buildInfoRow(
              icon: Icons.mail_outline_rounded,
              label: 'Email',
              value: customer.email,
            ),
        ],
      ),
    );
  }

  Widget _buildAddressSection() {
    final address = _currentOrder.address;

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFE4ECE8)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: const Color(0xFF1A3827).withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(Icons.location_on_outlined, size: 20, color: Color(0xFF1A3827)),
                  ),
                  const SizedBox(width: 12),
                  const Text(
                    'Delivery Address',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF11261B),
                    ),
                  ),
                ],
              ),
              if (address != null)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF1F5F9),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    address.addressType.toUpperCase(),
                    style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF475569),
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 14),
          if (address == null)
            const Text(
              'No delivery address specified.',
              style: TextStyle(color: Color(0xFF9CA3AF), fontSize: 13),
            )
          else ...[
            Text(
              address.fullName,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1F2937),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              address.formattedAddress,
              style: const TextStyle(
                fontSize: 13,
                color: Color(0xFF4B5563),
                height: 1.4,
              ),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                const Icon(Icons.phone_outlined, size: 14, color: Color(0xFF6B7280)),
                const SizedBox(width: 6),
                Text(
                  'Contact: ${address.mobileNumber}',
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF374151),
                  ),
                ),
                if (address.alternateMobile != null && address.alternateMobile!.isNotEmpty) ...[
                  const SizedBox(width: 8),
                  Text(
                    'Alt: ${address.alternateMobile}',
                    style: const TextStyle(fontSize: 12, color: Color(0xFF6B7280)),
                  ),
                ],
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildOrderedProductsSection() {
    final items = _currentOrder.orderItems;

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFE4ECE8)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: const Color(0xFF1A3827).withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(Icons.inventory_2_outlined, size: 20, color: Color(0xFF1A3827)),
                  ),
                  const SizedBox(width: 12),
                  const Text(
                    'Ordered Products',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF11261B),
                    ),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: AppColors.primaryGreen.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  '${items.length} item${items.length > 1 ? 's' : ''}',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primaryGreen,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: items.length,
            separatorBuilder: (context, index) => const Padding(
              padding: EdgeInsets.symmetric(vertical: 12),
              child: Divider(height: 1, color: Color(0xFFF1F5F9)),
            ),
            itemBuilder: (context, index) {
              final item = items[index];

              return Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Product Thumbnail
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Container(
                      width: 68,
                      height: 68,
                      color: const Color(0xFFF3F4F6),
                      child: CustomImageView(
                        imageUrl: item.productImage,
                        width: 68,
                        height: 68,
                        placeholderIcon: Icons.shopping_bag_outlined,
                      ),
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          item.productName,
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF11261B),
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        if (item.variantName != null && item.variantName!.isNotEmpty)
                          Text(
                            'Variant: ${item.variantName}',
                            style: const TextStyle(fontSize: 12, color: Color(0xFF6B7280)),
                          ),
                        if (item.sku != null && item.sku!.isNotEmpty)
                          Text(
                            'SKU: ${item.sku}',
                            style: const TextStyle(
                              fontSize: 11,
                              fontFamily: 'monospace',
                              color: Color(0xFF9CA3AF),
                            ),
                          ),
                        const SizedBox(height: 6),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              '₹${item.unitPrice.toStringAsFixed(2)} × ${item.quantity}',
                              style: const TextStyle(
                                fontSize: 13,
                                color: Color(0xFF4B5563),
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            Text(
                              '₹${item.totalPrice.toStringAsFixed(2)}',
                              style: const TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF1A3827),
                              ),
                            ),
                          ],
                        ),
                        if (item.shippingCharge > 0) ...[
                          const SizedBox(height: 2),
                          Text(
                            'Shipping: ₹${item.shippingCharge.toStringAsFixed(2)}',
                            style: const TextStyle(fontSize: 11, color: Color(0xFF8B9E94)),
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildPriceSummarySection() {
    final itemsTotal = _currentOrder.vendorItemsTotal > 0
        ? _currentOrder.vendorItemsTotal
        : _currentOrder.subtotal;
    final shipping = _currentOrder.vendorShippingTotal > 0
        ? _currentOrder.vendorShippingTotal
        : _currentOrder.shippingTotal;
    final grandTotal = _currentOrder.vendorGrandTotal > 0
        ? _currentOrder.vendorGrandTotal
        : _currentOrder.grandTotal;

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFE4ECE8)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFF1A3827).withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.receipt_outlined, size: 20, color: Color(0xFF1A3827)),
              ),
              const SizedBox(width: 12),
              const Text(
                'Price Summary',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF11261B),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          _buildPriceRow('Items Subtotal', '₹${itemsTotal.toStringAsFixed(2)}'),
          const SizedBox(height: 8),
          _buildPriceRow('Shipping Charges', shipping > 0 ? '₹${shipping.toStringAsFixed(2)}' : 'Free'),
          const SizedBox(height: 8),
          _buildPriceRow('Payment Method', _currentOrder.paymentMethod.toUpperCase()),
          const SizedBox(height: 8),
          _buildPriceRow('Payment Status', _currentOrder.paymentStatus.toUpperCase(), isHighlighted: true),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 12),
            child: Divider(height: 1, color: Color(0xFFE2E8F0)),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Grand Total',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF11261B),
                ),
              ),
              Text(
                '₹${grandTotal.toStringAsFixed(2)}',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1A3827),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 16, color: const Color(0xFF9CA3AF)),
        const SizedBox(width: 10),
        SizedBox(
          width: 70,
          child: Text(
            label,
            style: const TextStyle(
              fontSize: 13,
              color: Color(0xFF6B7280),
            ),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: Color(0xFF1F2937),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPriceRow(String label, String value, {bool isHighlighted = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 13,
            color: Color(0xFF64748B),
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: 13,
            fontWeight: isHighlighted ? FontWeight.bold : FontWeight.w500,
            color: isHighlighted ? AppColors.primaryGreen : const Color(0xFF1E293B),
          ),
        ),
      ],
    );
  }

  Widget _buildBottomActionBar(BuildContext context) {
    final nextStatus = _currentOrder.nextValidStatus;
    final actionLabel = _currentOrder.nextStatusActionLabel;
    final canAdvance = _currentOrder.canAdvanceStatus;

    return BlocBuilder<VendorOrderBloc, VendorOrderState>(
      builder: (context, state) {
        final isUpdating = state is VendorOrderLoaded && state.isUpdating;

        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          decoration: BoxDecoration(
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.05),
                blurRadius: 16,
                offset: const Offset(0, -4),
              ),
            ],
          ),
          child: SafeArea(
            top: false,
            child: Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: canAdvance && !isUpdating
                        ? () => _confirmStatusAdvance(context, nextStatus!, actionLabel!)
                        : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: canAdvance ? const Color(0xFF1A3827) : const Color(0xFFCBD5E1),
                      foregroundColor: Colors.white,
                      disabledBackgroundColor: const Color(0xFFE2E8F0),
                      disabledForegroundColor: const Color(0xFF94A3B8),
                      elevation: canAdvance ? 2 : 0,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    child: isUpdating
                        ? const SizedBox(
                            width: 22,
                            height: 22,
                            child: CircularProgressIndicator(strokeWidth: 2.5, color: Colors.white),
                          )
                        : Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                canAdvance ? Icons.check_circle_outline_rounded : Icons.lock_outline_rounded,
                                size: 20,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                canAdvance
                                    ? actionLabel!
                                    : _currentOrder.status == 'DELIVERED'
                                        ? 'Order Fulfilled'
                                        : _currentOrder.status == 'CANCELLED'
                                            ? 'Order Cancelled'
                                            : 'No Actions Available',
                                style: const TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
