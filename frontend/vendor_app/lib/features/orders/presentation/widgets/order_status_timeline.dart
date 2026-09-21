import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';

class OrderStatusTimeline extends StatelessWidget {
  final String currentStatus;
  final DateTime orderDate;
  final DateTime? updatedAt;
  final String? cancelReason;

  const OrderStatusTimeline({
    super.key,
    required this.currentStatus,
    required this.orderDate,
    this.updatedAt,
    this.cancelReason,
  });

  static const List<_TimelineStepDef> _steps = [
    _TimelineStepDef(
      statusKey: 'PENDING',
      title: 'Order Placed',
      description: 'Customer placed order and awaits vendor confirmation',
      icon: Icons.receipt_long_rounded,
    ),
    _TimelineStepDef(
      statusKey: 'CONFIRMED',
      title: 'Confirmed',
      description: 'Order confirmed and accepted for fulfillment',
      icon: Icons.check_circle_outline_rounded,
    ),
    _TimelineStepDef(
      statusKey: 'PROCESSING',
      title: 'Processing',
      description: 'Items are being prepared and quality checked',
      icon: Icons.inventory_2_outlined,
    ),
    _TimelineStepDef(
      statusKey: 'PACKED',
      title: 'Packed',
      description: 'Parcel packed, labeled, and ready for dispatch',
      icon: Icons.archive_outlined,
    ),
    _TimelineStepDef(
      statusKey: 'SHIPPED',
      title: 'Shipped',
      description: 'Handed over to courier partner for delivery',
      icon: Icons.local_shipping_outlined,
    ),
    _TimelineStepDef(
      statusKey: 'OUT_FOR_DELIVERY',
      title: 'Out for Delivery',
      description: 'Delivery agent is on the way to the customer',
      icon: Icons.delivery_dining_outlined,
    ),
    _TimelineStepDef(
      statusKey: 'DELIVERED',
      title: 'Delivered',
      description: 'Package successfully delivered to customer',
      icon: Icons.task_alt_rounded,
    ),
  ];

  int _getStatusRank(String status) {
    switch (status.toUpperCase()) {
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
      case 'CANCELLED':
        return -1;
      default:
        return 0;
    }
  }

  @override
  Widget build(BuildContext context) {
    final isCancelled = currentStatus.toUpperCase() == 'CANCELLED';
    final currentRank = _getStatusRank(currentStatus);

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFFE6EDE9)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 18,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(9),
                    decoration: BoxDecoration(
                      color: AppColors.primaryGreen.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      Icons.alt_route_rounded,
                      size: 20,
                      color: AppColors.primaryGreen,
                    ),
                  ),
                  const SizedBox(width: 12),
                  const Text(
                    'Fulfillment Timeline',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF11261B),
                      letterSpacing: -0.2,
                    ),
                  ),
                ],
              ),
              // Status Badge Pill
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: isCancelled
                      ? const Color(0xFFFEE2E2)
                      : currentRank == 6
                          ? const Color(0xFFE8F5E9)
                          : AppColors.primaryGreen.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      isCancelled
                          ? Icons.cancel_rounded
                          : currentRank == 6
                              ? Icons.check_circle_rounded
                              : Icons.schedule_rounded,
                      size: 13,
                      color: isCancelled
                          ? const Color(0xFFDC2626)
                          : currentRank == 6
                              ? AppColors.primaryGreen
                              : AppColors.primaryGreen,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      currentStatus,
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: isCancelled
                            ? const Color(0xFFDC2626)
                            : AppColors.primaryGreen,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 20),

          // Cancelled Banner if applicable
          if (isCancelled) ...[
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: const Color(0xFFFEF2F2),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: const Color(0xFFFECACA)),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(Icons.cancel_rounded, color: Color(0xFFDC2626), size: 22),
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
                        const SizedBox(height: 3),
                        Text(
                          cancelReason != null && cancelReason!.isNotEmpty
                              ? 'Reason: $cancelReason'
                              : 'This order was cancelled and cannot be fulfilled further.',
                          style: const TextStyle(
                            fontSize: 12,
                            color: Color(0xFFB91C1C),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 18),
          ],

          // Clean Timeline Steps List (no cross-axis expansion bug)
          Column(
            children: List.generate(_steps.length, (index) {
              final step = _steps[index];
              final isCompleted = !isCancelled && currentRank >= index;
              final isPassed = !isCancelled && currentRank > index;
              final isCurrent = !isCancelled && currentRank == index;
              final isLast = index == _steps.length - 1;

              return IntrinsicHeight(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Column 1: Node Icon + Perfectly Centered Vertical Connector
                    SizedBox(
                      width: 32,
                      child: Column(
                        children: [
                          // Circular Node
                          Container(
                            width: 28,
                            height: 28,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: isCancelled
                                  ? const Color(0xFFF3F4F6)
                                  : isCurrent
                                      ? AppColors.primaryGreen
                                      : isCompleted
                                          ? const Color(0xFFE8F5E9)
                                          : const Color(0xFFF8FAFC),
                              border: Border.all(
                                color: isCancelled
                                    ? const Color(0xFFD1D5DB)
                                    : isCurrent
                                        ? AppColors.primaryGreen
                                        : isCompleted
                                            ? AppColors.primaryGreen
                                            : const Color(0xFFCBD5E1),
                                width: isCurrent ? 2.5 : 1.5,
                              ),
                              boxShadow: isCurrent
                                  ? [
                                      BoxShadow(
                                        color: AppColors.primaryGreen.withValues(alpha: 0.35),
                                        blurRadius: 8,
                                        offset: const Offset(0, 2),
                                      ),
                                    ]
                                  : null,
                            ),
                            child: Center(
                              child: isCancelled
                                  ? const Icon(Icons.circle, size: 6, color: Color(0xFF9CA3AF))
                                  : isCompleted
                                      ? Icon(
                                          Icons.check_rounded,
                                          size: 16,
                                          color: isCurrent ? Colors.white : AppColors.primaryGreen,
                                        )
                                      : Container(
                                          width: 8,
                                          height: 8,
                                          decoration: const BoxDecoration(
                                            shape: BoxShape.circle,
                                            color: Color(0xFFCBD5E1),
                                          ),
                                        ),
                            ),
                          ),

                          // Vertical Line Connector (Only between steps)
                          if (!isLast)
                            Expanded(
                              child: Center(
                                child: Container(
                                  width: 2.5,
                                  decoration: BoxDecoration(
                                    color: isPassed
                                        ? AppColors.primaryGreen
                                        : const Color(0xFFE2E8F0),
                                    borderRadius: BorderRadius.circular(2),
                                  ),
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),

                    const SizedBox(width: 14),

                    // Column 2: Step Content
                    Expanded(
                      child: Padding(
                        padding: EdgeInsets.only(
                          top: 3.0,
                          bottom: isLast ? 0.0 : 20.0,
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Text(
                                  step.title,
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: isCurrent ? FontWeight.bold : FontWeight.w600,
                                    color: isCancelled
                                        ? const Color(0xFF6B7280)
                                        : isCurrent
                                            ? AppColors.primaryGreen
                                            : isCompleted
                                                ? const Color(0xFF1E293B)
                                                : const Color(0xFF94A3B8),
                                  ),
                                ),
                                if (isCurrent) ...[
                                  const SizedBox(width: 8),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                                    decoration: BoxDecoration(
                                      color: AppColors.primaryGreen.withValues(alpha: 0.12),
                                      borderRadius: BorderRadius.circular(6),
                                    ),
                                    child: Text(
                                      'Current',
                                      style: TextStyle(
                                        fontSize: 10,
                                        fontWeight: FontWeight.bold,
                                        color: AppColors.primaryGreen,
                                      ),
                                    ),
                                  ),
                                ],
                              ],
                            ),
                            const SizedBox(height: 3),
                            Text(
                              step.description,
                              style: TextStyle(
                                fontSize: 12,
                                height: 1.35,
                                color: isCancelled
                                    ? const Color(0xFF9CA3AF)
                                    : isCompleted
                                        ? const Color(0xFF64748B)
                                        : const Color(0xFF94A3B8),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              );
            }),
          ),
        ],
      ),
    );
  }
}

class _TimelineStepDef {
  final String statusKey;
  final String title;
  final String description;
  final IconData icon;

  const _TimelineStepDef({
    required this.statusKey,
    required this.title,
    required this.description,
    required this.icon,
  });
}
