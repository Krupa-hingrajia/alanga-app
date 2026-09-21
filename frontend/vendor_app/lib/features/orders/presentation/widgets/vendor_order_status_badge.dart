import 'package:flutter/material.dart';

class VendorOrderStatusBadge extends StatelessWidget {
  final String status;
  final bool isCompact;

  const VendorOrderStatusBadge({
    super.key,
    required this.status,
    this.isCompact = false,
  });

  @override
  Widget build(BuildContext context) {
    final meta = _getStatusMeta(status);

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: isCompact ? 8 : 12,
        vertical: isCompact ? 3 : 5,
      ),
      decoration: BoxDecoration(
        color: meta.bgColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: meta.borderColor, width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(meta.icon, size: isCompact ? 12 : 14, color: meta.textColor),
          const SizedBox(width: 4),
          Text(
            meta.label,
            style: TextStyle(
              color: meta.textColor,
              fontSize: isCompact ? 11 : 12,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.2,
            ),
          ),
        ],
      ),
    );
  }

  _StatusMeta _getStatusMeta(String status) {
    switch (status.toUpperCase()) {
      case 'PENDING':
        return const _StatusMeta(
          label: 'Pending',
          textColor: Color(0xFFB45309), // Amber 700
          bgColor: Color(0xFFFFFBEB), // Amber 50
          borderColor: Color(0xFFFDE68A),
          icon: Icons.hourglass_top_rounded,
        );
      case 'CONFIRMED':
        return const _StatusMeta(
          label: 'Confirmed',
          textColor: Color(0xFF0F766E), // Teal 700
          bgColor: Color(0xFFF0FDFA), // Teal 50
          borderColor: Color(0xFF99F6E4),
          icon: Icons.check_circle_outline_rounded,
        );
      case 'PROCESSING':
        return const _StatusMeta(
          label: 'Processing',
          textColor: Color(0xFF1D4ED8), // Blue 700
          bgColor: Color(0xFFEFF6FF), // Blue 50
          borderColor: Color(0xFFBFDBFE),
          icon: Icons.autorenew_rounded,
        );
      case 'PACKED':
        return const _StatusMeta(
          label: 'Packed',
          textColor: Color(0xFF7E22CE), // Purple 700
          bgColor: Color(0xFFFAF5FF), // Purple 50
          borderColor: Color(0xFFE9D5FF),
          icon: Icons.inventory_2_outlined,
        );
      case 'SHIPPED':
      case 'OUT_FOR_DELIVERY':
        return const _StatusMeta(
          label: 'Shipped',
          textColor: Color(0xFF4338CA), // Indigo 700
          bgColor: Color(0xFFEEF2FF), // Indigo 50
          borderColor: Color(0xFFC7D2FE),
          icon: Icons.local_shipping_outlined,
        );
      case 'DELIVERED':
        return const _StatusMeta(
          label: 'Delivered',
          textColor: Color(0xFF15803D), // Green 700
          bgColor: Color(0xFFF0FDF4), // Green 50
          borderColor: Color(0xFFBBF7D0),
          icon: Icons.task_alt_rounded,
        );
      case 'CANCELLED':
        return const _StatusMeta(
          label: 'Cancelled',
          textColor: Color(0xFFB91C1C), // Red 700
          bgColor: Color(0xFFFEF2F2), // Red 50
          borderColor: Color(0xFFFECACA),
          icon: Icons.cancel_outlined,
        );
      default:
        return _StatusMeta(
          label: status,
          textColor: const Color(0xFF4B5563),
          bgColor: const Color(0xFFF3F4F6),
          borderColor: const Color(0xFFE5E7EB),
          icon: Icons.info_outline,
        );
    }
  }
}

class _StatusMeta {
  final String label;
  final Color textColor;
  final Color bgColor;
  final Color borderColor;
  final IconData icon;

  const _StatusMeta({
    required this.label,
    required this.textColor,
    required this.bgColor,
    required this.borderColor,
    required this.icon,
  });
}
