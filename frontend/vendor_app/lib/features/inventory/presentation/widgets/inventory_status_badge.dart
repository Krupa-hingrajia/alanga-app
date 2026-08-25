import 'package:flutter/material.dart';

class InventoryStatusBadge extends StatelessWidget {
  final String status;
  final double fontSize;

  const InventoryStatusBadge({
    super.key,
    required this.status,
    this.fontSize = 11.0,
  });

  @override
  Widget build(BuildContext context) {
    Color bgColor;
    Color textColor;
    Color borderColor;
    String label;
    IconData icon;

    switch (status.toUpperCase()) {
      case 'IN_STOCK':
        bgColor = const Color(0xFFE8F5E9);
        textColor = const Color(0xFF2E7D32);
        borderColor = const Color(0xFFA5D6A7);
        label = 'In Stock';
        icon = Icons.check_circle_outline_rounded;
        break;
      case 'LOW_STOCK':
        bgColor = const Color(0xFFFFF3E0);
        textColor = const Color(0xFFE65100);
        borderColor = const Color(0xFFFFCC80);
        label = 'Low Stock';
        icon = Icons.warning_amber_rounded;
        break;
      case 'OUT_OF_STOCK':
      default:
        bgColor = const Color(0xFFFFEBEE);
        textColor = const Color(0xFFC62828);
        borderColor = const Color(0xFFEF9A9A);
        label = 'Out of Stock';
        icon = Icons.error_outline_rounded;
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: borderColor, width: 1.0),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: fontSize + 3, color: textColor),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              color: textColor,
              fontSize: fontSize,
              fontWeight: FontWeight.bold,
              letterSpacing: 0.2,
            ),
          ),
        ],
      ),
    );
  }
}
