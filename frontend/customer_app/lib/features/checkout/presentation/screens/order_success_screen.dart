import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_colors.dart';
import '../../data/models/order_model.dart';

class OrderSuccessScreen extends StatefulWidget {
  final OrderModel order;

  const OrderSuccessScreen({super.key, required this.order});

  @override
  State<OrderSuccessScreen> createState() => _OrderSuccessScreenState();
}

class _OrderSuccessScreenState extends State<OrderSuccessScreen> with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );

    _scaleAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.elasticOut,
    );

    _fadeAnimation = CurvedAnimation(
      parent: _animationController,
      curve: const Interval(0.2, 1.0, curve: Curves.easeIn),
    );

    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
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

  @override
  Widget build(BuildContext context) {
    final order = widget.order;

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop) context.go('/home');
      },
      child: Scaffold(
        backgroundColor: const Color(0xFFF5F8F6),
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 22.0, vertical: 16.0),
            child: Column(
              children: [
                const Spacer(),

                // Animated Success Checkmark
                ScaleTransition(
                  scale: _scaleAnimation,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      Container(
                        width: 104,
                        height: 104,
                        decoration: BoxDecoration(
                          color: AppColors.primaryGreen.withValues(alpha: 0.12),
                          shape: BoxShape.circle,
                        ),
                      ),
                      Container(
                        width: 80,
                        height: 80,
                        decoration: const BoxDecoration(
                          color: AppColors.primaryGreen,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: Color(0x33059669),
                              blurRadius: 18,
                              offset: Offset(0, 6),
                            ),
                          ],
                        ),
                        child: const Icon(
                          Icons.check_rounded,
                          color: Colors.white,
                          size: 48,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // Success Titles with Fade Transition
                FadeTransition(
                  opacity: _fadeAnimation,
                  child: Column(
                    children: [
                      const Text(
                        'Order Placed Successfully!',
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF11261B),
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 6),
                      const Text(
                        'Thank you for your order. We are getting it ready to be shipped to your address.',
                        style: TextStyle(
                          fontSize: 13,
                          color: Color(0xFF5A7265),
                          height: 1.35,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 28),

                // Order Summary Card
                FadeTransition(
                  opacity: _fadeAnimation,
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(18),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(color: const Color(0xFFE2EBE6)),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.04),
                          blurRadius: 12,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        _buildDetailRow(
                          label: 'Order Number',
                          value: order.orderNumber,
                          isHighlight: true,
                        ),
                        const Divider(height: 20, color: Color(0xFFEFF4F1)),
                        _buildDetailRow(
                          label: 'Order Date',
                          value: _formatDateTime(order.createdAt),
                        ),
                        const Divider(height: 20, color: Color(0xFFEFF4F1)),
                        _buildDetailRow(
                          label: 'Payment Method',
                          value: order.paymentMethod == 'COD'
                              ? 'Cash on Delivery (COD)'
                              : order.paymentMethod,
                        ),
                        const Divider(height: 20, color: Color(0xFFEFF4F1)),
                        _buildDetailRow(
                          label: 'Grand Total',
                          value: '₹${order.totalAmount.toStringAsFixed(0)}',
                          isBold: true,
                        ),
                        const Divider(height: 20, color: Color(0xFFEFF4F1)),
                        _buildDetailRow(
                          label: 'Estimated Delivery Date',
                          value: _formatEstimatedDelivery(order.createdAt),
                          icon: Icons.local_shipping_outlined,
                        ),
                      ],
                    ),
                  ),
                ),

                const Spacer(),

                // Action Buttons
                FadeTransition(
                  opacity: _fadeAnimation,
                  child: Column(
                    children: [
                      // View My Orders button
                      SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: ElevatedButton(
                          onPressed: () => context.go('/orders'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF1A3827),
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                            elevation: 0,
                          ),
                          child: const Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.receipt_long_rounded, size: 18),
                              SizedBox(width: 8),
                              Text(
                                'VIEW MY ORDERS',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                  letterSpacing: 0.5,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      // Continue Shopping button
                      SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: OutlinedButton(
                          onPressed: () => context.go('/home'),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: AppColors.primaryGreen,
                            side: const BorderSide(color: AppColors.primaryGreen, width: 1.5),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                          ),
                          child: const Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.shopping_bag_outlined, size: 18),
                              SizedBox(width: 8),
                              Text(
                                'CONTINUE SHOPPING',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                  letterSpacing: 0.5,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDetailRow({
    required String label,
    required String value,
    bool isHighlight = false,
    bool isBold = false,
    IconData? icon,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 12.5, color: Color(0xFF6B8074), fontWeight: FontWeight.w500),
        ),
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null) ...[
              Icon(icon, size: 14, color: AppColors.primaryGreen),
              const SizedBox(width: 4),
            ],
            Text(
              value,
              style: TextStyle(
                fontSize: 13,
                fontWeight: (isHighlight || isBold) ? FontWeight.bold : FontWeight.w600,
                color: isHighlight
                    ? AppColors.primaryGreen
                    : (isBold ? const Color(0xFF11261B) : const Color(0xFF11261B)),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
