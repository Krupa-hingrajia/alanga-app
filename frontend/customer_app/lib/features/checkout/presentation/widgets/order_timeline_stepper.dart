import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';

class OrderTimelineStepper extends StatelessWidget {
  final String currentStatus;
  final DateTime orderDate;
  final bool isDetailed;

  const OrderTimelineStepper({
    super.key,
    required this.currentStatus,
    required this.orderDate,
    this.isDetailed = false,
  });

  int _getStatusStepIndex(String status) {
    switch (status.toUpperCase().replaceAll(' ', '_')) {
      case 'CANCELLED':
      case 'RETURNED':
        return -1;
      case 'PENDING':
        return 0;
      case 'CONFIRMED':
        return 1;
      case 'PROCESSING':
        return 2;
      case 'PACKED':
        return 3;
      case 'SHIPPED':
        return 4;
      case 'OUT_FOR_DELIVERY':
        return 5;
      case 'DELIVERED':
        return 6;
      default:
        return 0;
    }
  }

  String _formatDate(DateTime dt) {
    final months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    final hour = dt.hour > 12 ? dt.hour - 12 : (dt.hour == 0 ? 12 : dt.hour);
    final period = dt.hour >= 12 ? 'PM' : 'AM';
    final minute = dt.minute.toString().padLeft(2, '0');
    return '${dt.day} ${months[dt.month - 1]} ${dt.year}, $hour:$minute $period';
  }

  @override
  Widget build(BuildContext context) {
    final isCancelled = currentStatus.toUpperCase() == 'CANCELLED' || currentStatus.toUpperCase() == 'RETURNED';
    final currentStep = _getStatusStepIndex(currentStatus);

    if (isCancelled) {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFFFEF2F2),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: const Color(0xFFFECACA)),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: const BoxDecoration(
                color: AppColors.brandRed,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.cancel_rounded, color: Colors.white, size: 24),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Order Cancelled',
                    style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: AppColors.brandRed),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'This order was placed on ${_formatDate(orderDate)} and has been cancelled.',
                    style: const TextStyle(fontSize: 12, color: Color(0xFF7F1D1D), height: 1.35),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    }

    final steps = [
      {
        'title': 'Order Placed',
        'desc': _formatDate(orderDate),
        'detail': 'Your order has been placed and received by the seller.',
        'icon': Icons.receipt_long_rounded,
      },
      {
        'title': 'Confirmed',
        'desc': 'Order verified',
        'detail': 'Order details and inventory have been confirmed.',
        'icon': Icons.check_circle_outline_rounded,
      },
      {
        'title': 'Processing',
        'desc': 'Preparing items',
        'detail': 'Items are being gathered and inspected at warehouse.',
        'icon': Icons.sync_rounded,
      },
      {
        'title': 'Packed',
        'desc': 'Ready for dispatch',
        'detail': 'Package is packed securely and ready for courier pickup.',
        'icon': Icons.inventory_2_outlined,
      },
      {
        'title': 'Shipped',
        'desc': 'In transit',
        'detail': 'Handed over to delivery partner and in transit.',
        'icon': Icons.local_shipping_outlined,
      },
      {
        'title': 'Out for Delivery',
        'desc': 'Nearby courier',
        'detail': 'Delivery agent is out to deliver your package today.',
        'icon': Icons.delivery_dining_outlined,
      },
      {
        'title': 'Delivered',
        'desc': 'Package delivered',
        'detail': 'Package has been delivered to your delivery address.',
        'icon': Icons.home_outlined,
      },
    ];

    return Column(
      children: List.generate(steps.length, (index) {
        final step = steps[index];
        final isCompleted = index <= currentStep;
        final isCurrent = index == currentStep;
        final isLast = index == steps.length - 1;

        return IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Indicator column with icon/checkmark and connecting line
              Column(
                children: [
                  Container(
                    width: isDetailed ? 26 : 22,
                    height: isDetailed ? 26 : 22,
                    decoration: BoxDecoration(
                      color: isCompleted ? AppColors.primaryGreen : Colors.white,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: isCompleted ? AppColors.primaryGreen : const Color(0xFFD1D5DB),
                        width: isCurrent ? 2.5 : 2,
                      ),
                      boxShadow: isCurrent
                          ? [
                              BoxShadow(
                                color: AppColors.primaryGreen.withValues(alpha: 0.35),
                                blurRadius: 8,
                                spreadRadius: 2,
                              ),
                            ]
                          : null,
                    ),
                    child: Center(
                      child: isCompleted
                          ? Icon(
                              Icons.check_rounded,
                              size: isDetailed ? 15 : 13,
                              color: Colors.white,
                            )
                          : Container(
                              width: 6,
                              height: 6,
                              decoration: const BoxDecoration(
                                color: Color(0xFFD1D5DB),
                                shape: BoxShape.circle,
                              ),
                            ),
                    ),
                  ),
                  if (!isLast)
                    Expanded(
                      child: Container(
                        width: 2,
                        color: index < currentStep ? AppColors.primaryGreen : const Color(0xFFE5E7EB),
                      ),
                    ),
                ],
              ),
              const SizedBox(width: 14),

              // Content column
              Expanded(
                child: Padding(
                  padding: EdgeInsets.only(bottom: isLast ? 0 : (isDetailed ? 22 : 18)),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            step['title'] as String,
                            style: TextStyle(
                              fontSize: isDetailed ? 14.5 : 13.5,
                              fontWeight: isCompleted ? FontWeight.bold : FontWeight.w500,
                              color: isCompleted ? const Color(0xFF11261B) : Colors.grey.shade400,
                            ),
                          ),
                          if (isCurrent) ...[
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1.5),
                              decoration: BoxDecoration(
                                color: AppColors.primaryGreen.withValues(alpha: 0.12),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: const Text(
                                'CURRENT',
                                style: TextStyle(
                                  fontSize: 9,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.primaryGreen,
                                  letterSpacing: 0.5,
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                      const SizedBox(height: 2),
                      Text(
                        step['desc'] as String,
                        style: TextStyle(
                          fontSize: 11.5,
                          color: isCurrent
                              ? AppColors.primaryGreen
                              : (isCompleted ? const Color(0xFF5A7265) : Colors.grey.shade400),
                          fontWeight: isCurrent ? FontWeight.w600 : FontWeight.normal,
                        ),
                      ),
                      if (isDetailed && (isCompleted || isCurrent)) ...[
                        const SizedBox(height: 3),
                        Text(
                          step['detail'] as String,
                          style: TextStyle(
                            fontSize: 11,
                            color: Colors.grey.shade600,
                            height: 1.3,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      }),
    );
  }
}
