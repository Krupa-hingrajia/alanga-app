import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../data/models/product_shipping_model.dart';

class ShippingSummaryCard extends StatelessWidget {
  final ProductShippingModel shipping;

  const ShippingSummaryCard({super.key, required this.shipping});

  @override
  Widget build(BuildContext context) {
    final weightStr = shipping.weight > 0 ? '${shipping.weight} ${shipping.weightUnit}' : 'Not specified';
    
    final hasDimensions = shipping.length > 0 || shipping.width > 0 || shipping.height > 0;
    final dimStr = hasDimensions
        ? '${shipping.length} × ${shipping.width} × ${shipping.height} ${shipping.dimensionUnit}'
        : 'Not specified';

    final isFree = shipping.isFreeShipping || shipping.shippingCharge == 0;
    final chargeStr = isFree ? 'Free Shipping' : '₹${shipping.shippingCharge.toStringAsFixed(0)}';

    final minDays = shipping.estimatedDeliveryMinDays;
    final maxDays = shipping.estimatedDeliveryMaxDays;
    final deliveryStr = minDays == maxDays ? '$minDays Days' : '$minDays - $maxDays Days';

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFE4ECE8)),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF1A3827).withValues(alpha: 0.06),
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
                  color: AppColors.primaryGreen.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.assessment_outlined, color: AppColors.primaryGreen, size: 20),
              ),
              const SizedBox(width: 10),
              const Text(
                'Shipping Summary Overview',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF11261B),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          const Divider(height: 1, color: Color(0xFFF0F4F1)),
          const SizedBox(height: 14),

          // 2-Column Grid of Overview Metrics
          Row(
            children: [
              Expanded(
                child: _buildMetricTile(
                  icon: Icons.scale_outlined,
                  label: 'Weight',
                  value: weightStr,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildMetricTile(
                  icon: Icons.aspect_ratio_outlined,
                  label: 'Dimensions',
                  value: dimStr,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildMetricTile(
                  icon: Icons.local_shipping_outlined,
                  label: 'Shipping Charge',
                  value: chargeStr,
                  valueColor: isFree ? AppColors.primaryGreen : const Color(0xFF11261B),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildMetricTile(
                  icon: Icons.event_available_outlined,
                  label: 'Estimated Delivery',
                  value: deliveryStr,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildMetricTile(
                  icon: Icons.card_giftcard_outlined,
                  label: 'Free Shipping',
                  value: shipping.isFreeShipping
                      ? (shipping.freeShippingAboveAmount != null && shipping.freeShippingAboveAmount! > 0
                          ? 'Above ₹${shipping.freeShippingAboveAmount!.toStringAsFixed(0)}'
                          : 'Enabled')
                      : 'Disabled',
                  valueColor: shipping.isFreeShipping ? AppColors.primaryGreen : Colors.grey,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildMetricTile(
                  icon: Icons.monetization_on_outlined,
                  label: 'Cash on Delivery',
                  value: shipping.codAvailable ? 'Available' : 'Not Available',
                  valueColor: shipping.codAvailable ? AppColors.primaryGreen : AppColors.brandRed,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMetricTile({
    required IconData icon,
    required String label,
    required String value,
    Color? valueColor,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFF9FBF9),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE4ECE8), width: 0.8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 15, color: const Color(0xFF5A7265)),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  label,
                  style: const TextStyle(
                    fontSize: 11,
                    color: Color(0xFF5A7265),
                    fontWeight: FontWeight.w500,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            value,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.bold,
              color: valueColor ?? const Color(0xFF11261B),
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}
