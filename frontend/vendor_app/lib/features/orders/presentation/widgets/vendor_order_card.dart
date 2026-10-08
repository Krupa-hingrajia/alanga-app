import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/widgets/custom_image_view.dart';
import '../../../../core/localization/app_localizations.dart';
import '../../data/models/vendor_order_model.dart';
import 'vendor_order_status_badge.dart';
import 'order_documents_bottom_sheet.dart';

class VendorOrderCard extends StatelessWidget {
  final VendorOrderModel order;
  final VoidCallback onTap;
  final VoidCallback? onQuickAdvanceStatus;
  final bool isUpdating;

  const VendorOrderCard({
    super.key,
    required this.order,
    required this.onTap,
    this.onQuickAdvanceStatus,
    this.isUpdating = false,
  });

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

  @override
  Widget build(BuildContext context) {
    final firstItem = order.orderItems.isNotEmpty ? order.orderItems.first : null;
    final totalQty = order.vendorTotalQuantity;
    final totalAmount = order.vendorGrandTotal > 0 ? order.vendorGrandTotal : order.grandTotal;

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFE4ECE8)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(20),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(20),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ── Header: Order Number + Status Badge ─────────────────
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: const Color(0xFF1A3827).withValues(alpha: 0.08),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        '#${order.orderNumber}',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                          color: Color(0xFF1A3827),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    VendorOrderStatusBadge(status: order.status, isCompact: true),
                  ],
                ),
                const SizedBox(height: 8),
                // ── Customer Name & Date Row ────────────────────────────
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Row(
                        children: [
                          const Icon(Icons.person_outline_rounded, size: 14, color: Color(0xFF6B7280)),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              order.customer?.fullName ?? context.tr('valued_customer'),
                              style: const TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: Color(0xFF1F2937),
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.access_time_rounded, size: 12, color: Color(0xFF8B9E94)),
                        const SizedBox(width: 4),
                        Text(
                          _formatDate(order.createdAt),
                          style: const TextStyle(
                            fontSize: 11,
                            color: Color(0xFF8B9E94),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),

                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 12),
                  child: Divider(height: 1, color: Color(0xFFF1F5F9)),
                ),

                // ── Product Summary Row ─────────────────────────────────
                if (firstItem != null)
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Product Thumbnail
                      ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Container(
                          width: 64,
                          height: 64,
                          color: const Color(0xFFF3F4F6),
                          child: CustomImageView(
                            imageUrl: firstItem.productImage,
                            width: 64,
                            height: 64,
                            placeholderIcon: Icons.shopping_bag_outlined,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              firstItem.productName,
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: Color(0xFF11261B),
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 3),
                            if (firstItem.variantName != null && firstItem.variantName!.isNotEmpty)
                              Text(
                                '${context.tr('variant')}: ${firstItem.variantName}',
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: Color(0xFF6B7280),
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            if (firstItem.sku != null && firstItem.sku!.isNotEmpty)
                              Text(
                                '${context.tr('sku')}: ${firstItem.sku}',
                                style: const TextStyle(
                                  fontSize: 11,
                                  fontFamily: 'monospace',
                                  color: Color(0xFF9CA3AF),
                                ),
                              ),
                            const SizedBox(height: 4),
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFF3F4F6),
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: Text(
                                    '${context.tr('qty')}: ${firstItem.quantity}',
                                    style: const TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.w600,
                                      color: Color(0xFF4B5563),
                                    ),
                                  ),
                                ),
                                if (order.orderItems.length > 1) ...[
                                  const SizedBox(width: 6),
                                  Text(
                                    '+${order.orderItems.length - 1} ${context.tr('more_items')}',
                                    style: const TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.w500,
                                      color: AppColors.primaryGreen,
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),

                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 12),
                  child: Divider(height: 1, color: Color(0xFFF1F5F9)),
                ),

                // ── Footer: Total Amount + Action Button ─────────────────
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Flexible(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '${context.tr('total')} ($totalQty ${context.tr(totalQty > 1 ? 'items' : 'item')})',
                            style: const TextStyle(
                              fontSize: 11,
                              color: Color(0xFF8B9E94),
                            ),
                          ),
                          Text(
                            '₹${totalAmount.toStringAsFixed(2)}',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF1A3827),
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    Row(
                      children: [
                        if (['CONFIRMED', 'PROCESSING', 'PACKED', 'SHIPPED', 'DELIVERED'].contains(order.status.toUpperCase()))
                          Padding(
                            padding: const EdgeInsets.only(right: 8),
                            child: Tooltip(
                              message: context.tr('print_shipping_label_invoice'),
                              child: InkWell(
                                onTap: () => OrderDocumentsBottomSheet.show(context, order),
                                borderRadius: BorderRadius.circular(10),
                                child: Container(
                                  width: 36,
                                  height: 36,
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFF3F7F4),
                                    borderRadius: BorderRadius.circular(10),
                                    border: Border.all(color: const Color(0xFFE2EBE5)),
                                  ),
                                  child: const Icon(
                                    Icons.print_outlined,
                                    size: 18,
                                    color: Color(0xFF1A3827),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        if (order.canAdvanceStatus && onQuickAdvanceStatus != null)
                          ElevatedButton.icon(
                            onPressed: isUpdating ? null : onQuickAdvanceStatus,
                            icon: isUpdating
                                ? const SizedBox(
                                    width: 14,
                                    height: 14,
                                    child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                                  )
                                : const Icon(Icons.arrow_forward_rounded, size: 14),
                            label: Text(
                              context.tr(order.nextStatusActionLabel ?? 'Update'),
                              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF1A3827),
                              foregroundColor: Colors.white,
                              elevation: 0,
                              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                          ),
                        const SizedBox(width: 8),
                        Container(
                          width: 34,
                          height: 34,
                          decoration: BoxDecoration(
                            color: const Color(0xFFF6F8F6),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: const Color(0xFFE4ECE8)),
                          ),
                          child: const Icon(
                            Icons.chevron_right_rounded,
                            size: 20,
                            color: Color(0xFF1A3827),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
