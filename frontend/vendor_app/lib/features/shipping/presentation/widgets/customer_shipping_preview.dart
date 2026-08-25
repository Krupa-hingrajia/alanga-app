import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../data/models/product_shipping_model.dart';

class CustomerShippingPreview extends StatelessWidget {
  final ProductShippingModel shipping;

  const CustomerShippingPreview({super.key, required this.shipping});

  String _formatDateRange(int minDays, int maxDays) {
    final now = DateTime.now();
    final minDate = now.add(Duration(days: minDays));
    final maxDate = now.add(Duration(days: maxDays));

    const months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];

    if (minDays == maxDays) {
      return '${minDate.day} ${months[minDate.month - 1]}';
    }

    if (minDate.month == maxDate.month) {
      return '${minDate.day} ${months[minDate.month - 1]} - ${maxDate.day} ${months[maxDate.month - 1]}';
    }

    return '${minDate.day} ${months[minDate.month - 1]} - ${maxDate.day} ${months[maxDate.month - 1]}';
  }

  @override
  Widget build(BuildContext context) {
    final isFree = shipping.isFreeShipping || shipping.shippingCharge == 0;
    final dateRangeStr = _formatDateRange(
      shipping.estimatedDeliveryMinDays,
      shipping.estimatedDeliveryMaxDays,
    );

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFF2563EB).withValues(alpha: 0.25), width: 1.2),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF2563EB).withValues(alpha: 0.06),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Badge for Customer Preview
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            decoration: const BoxDecoration(
              color: Color(0xFFEFF6FF),
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(19),
                topRight: Radius.circular(19),
              ),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(5),
                  decoration: BoxDecoration(
                    color: const Color(0xFF2563EB).withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: const Icon(Icons.preview_rounded, color: Color(0xFF2563EB), size: 16),
                ),
                const SizedBox(width: 8),
                const Text(
                  'CUSTOMER APP LIVE PREVIEW',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF2563EB),
                    letterSpacing: 0.5,
                  ),
                ),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: const Color(0xFF93C5FD)),
                  ),
                  child: const Text(
                    'Live Dynamic View',
                    style: TextStyle(fontSize: 10, color: Color(0xFF1E40AF), fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
          ),

          // Amazon / Flipkart Style Product Page Shipping Card Component
          Padding(
            padding: const EdgeInsets.all(16),
            child: Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: const Color(0xFFFAFAFA),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: const Color(0xFFE5E7EB)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Free Shipping or Standard Shipping Row
                  Row(
                    children: [
                      Icon(
                        isFree ? Icons.local_shipping_rounded : Icons.local_shipping_outlined,
                        color: isFree ? AppColors.primaryGreen : const Color(0xFF1F2937),
                        size: 22,
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            RichText(
                              text: TextSpan(
                                children: [
                                  TextSpan(
                                    text: isFree ? 'FREE Delivery ' : 'Shipping Charge: ',
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold,
                                      color: isFree ? AppColors.primaryGreen : const Color(0xFF111827),
                                    ),
                                  ),
                                  if (!isFree)
                                    TextSpan(
                                      text: '₹${shipping.shippingCharge.toStringAsFixed(0)}',
                                      style: const TextStyle(
                                        fontSize: 15,
                                        fontWeight: FontWeight.bold,
                                        color: AppColors.primaryGreen,
                                      ),
                                    ),
                                ],
                              ),
                            ),
                            if (shipping.isFreeShipping &&
                                shipping.freeShippingAboveAmount != null &&
                                shipping.freeShippingAboveAmount! > 0)
                              Text(
                                'Free delivery on orders above ₹${shipping.freeShippingAboveAmount!.toStringAsFixed(0)}',
                                style: const TextStyle(fontSize: 11, color: Color(0xFF6B7280)),
                              ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  const Divider(height: 1, color: Color(0xFFE5E7EB)),
                  const SizedBox(height: 10),

                  // Delivery Date Range Row
                  Row(
                    children: [
                      const Icon(Icons.event_available_rounded, color: Color(0xFF2563EB), size: 18),
                      const SizedBox(width: 8),
                      Text(
                        'Delivery between ',
                        style: TextStyle(fontSize: 12.5, color: Colors.grey.shade700),
                      ),
                      Text(
                        dateRangeStr,
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF111827),
                        ),
                      ),
                      Text(
                        ' (${shipping.estimatedDeliveryLabel ?? "${shipping.estimatedDeliveryMinDays}-${shipping.estimatedDeliveryMaxDays} Days"})',
                        style: const TextStyle(fontSize: 11, color: Colors.grey),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),

                  // Cash on Delivery Tag
                  Row(
                    children: [
                      Icon(
                        shipping.codAvailable ? Icons.check_circle_rounded : Icons.cancel_rounded,
                        color: shipping.codAvailable ? AppColors.primaryGreen : AppColors.brandRed,
                        size: 16,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        shipping.codAvailable ? 'Cash on Delivery Available' : 'Cash on Delivery Not Available',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: shipping.codAvailable ? AppColors.primaryGreen : AppColors.brandRed,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
