import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';

class OrderStatusBadge extends StatelessWidget {
  final String status;
  final bool isLarge;

  const OrderStatusBadge({
    super.key,
    required this.status,
    this.isLarge = false,
  });

  static Color getStatusColor(String status) {
    switch (status.toUpperCase().replaceAll(' ', '_')) {
      case 'DELIVERED':
        return AppColors.primaryGreen;
      case 'SHIPPED':
        return const Color(0xFF0284C7);
      case 'OUT_FOR_DELIVERY':
        return const Color(0xFFEA580C);
      case 'PACKED':
        return const Color(0xFF0891B2);
      case 'PROCESSING':
        return const Color(0xFF7C3AED);
      case 'CONFIRMED':
        return const Color(0xFF2563EB);
      case 'CANCELLED':
      case 'RETURNED':
        return AppColors.brandRed;
      case 'PENDING':
      default:
        return const Color(0xFFD97706);
    }
  }

  static IconData getStatusIcon(String status) {
    switch (status.toUpperCase().replaceAll(' ', '_')) {
      case 'DELIVERED':
        return Icons.check_circle_rounded;
      case 'SHIPPED':
        return Icons.local_shipping_rounded;
      case 'OUT_FOR_DELIVERY':
        return Icons.delivery_dining_rounded;
      case 'PACKED':
        return Icons.inventory_2_rounded;
      case 'PROCESSING':
        return Icons.sync_rounded;
      case 'CONFIRMED':
        return Icons.verified_rounded;
      case 'CANCELLED':
      case 'RETURNED':
        return Icons.cancel_rounded;
      case 'PENDING':
      default:
        return Icons.schedule_rounded;
    }
  }

  static String getDisplayStatus(String status) {
    switch (status.toUpperCase().replaceAll(' ', '_')) {
      case 'OUT_FOR_DELIVERY':
        return 'Out for Delivery';
      case 'DELIVERED':
        return 'Delivered';
      case 'SHIPPED':
        return 'Shipped';
      case 'PACKED':
        return 'Packed';
      case 'PROCESSING':
        return 'Processing';
      case 'CONFIRMED':
        return 'Confirmed';
      case 'CANCELLED':
        return 'Cancelled';
      case 'PENDING':
      default:
        return 'Pending';
    }
  }

  @override
  Widget build(BuildContext context) {
    final color = getStatusColor(status);
    final icon = getStatusIcon(status);
    final text = getDisplayStatus(status);

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: isLarge ? 10 : 8,
        vertical: isLarge ? 4 : 3,
      ),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(isLarge ? 8 : 6),
        border: Border.all(color: color.withValues(alpha: 0.3), width: 0.8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: isLarge ? 14 : 12, color: color),
          const SizedBox(width: 4),
          Text(
            text,
            style: TextStyle(
              fontSize: isLarge ? 12 : 10.5,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}
