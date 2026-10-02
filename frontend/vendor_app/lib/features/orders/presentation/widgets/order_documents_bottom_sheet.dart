import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../data/models/vendor_order_model.dart';
import '../../utils/order_document_generator.dart';

class OrderDocumentsBottomSheet extends StatelessWidget {
  final VendorOrderModel order;

  const OrderDocumentsBottomSheet({
    super.key,
    required this.order,
  });

  static Future<void> show(BuildContext context, VendorOrderModel order) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => OrderDocumentsBottomSheet(order: order),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isCod = order.paymentMethod.toUpperCase() == 'COD';
    final totalAmount = order.vendorGrandTotal > 0 ? order.vendorGrandTotal : order.grandTotal;

    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Drag handle
          Center(
            child: Container(
              width: 44,
              height: 5,
              decoration: BoxDecoration(
                color: const Color(0xFFDCE5DF),
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: const Color(0xFF1A3827).withValues(alpha: 0.1),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.print_outlined, size: 18, color: Color(0xFF1A3827)),
                      ),
                      const SizedBox(width: 8),
                      const Text(
                        'Printable Documents',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF11261B),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Order #${order.orderNumber} • ₹${totalAmount.toStringAsFixed(2)} (${isCod ? "COD" : "Prepaid"})',
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppColors.textSecondaryLight,
                    ),
                  ),
                ],
              ),
              IconButton(
                onPressed: () => Navigator.of(context).pop(),
                icon: const Icon(Icons.close_rounded, size: 20, color: Color(0xFF6B7280)),
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // Document Card 1: 4x6" Shipping Label
          _buildDocumentCard(
            context: context,
            title: 'Shipping Label',
            badge: '4x6" Thermal / Standard',
            badgeColor: const Color(0xFF0F766E),
            description: 'Barcode-ready courier label with buyer address & package content summary.',
            icon: Icons.receipt_long_rounded,
            accentColor: const Color(0xFF1A3827),
            onPrint: () {
              Navigator.of(context).pop();
              OrderDocumentGenerator.printShippingLabel(context: context, order: order);
            },
            onShare: () {
              Navigator.of(context).pop();
              OrderDocumentGenerator.shareShippingLabel(context: context, order: order);
            },
          ),
          const SizedBox(height: 14),

          // Document Card 2: Official GST Tax Invoice
          _buildDocumentCard(
            context: context,
            title: 'Tax Invoice',
            badge: 'GST Compliant (A4)',
            badgeColor: const Color(0xFF1D4ED8),
            description: 'Itemized invoice with HSN codes, SGST/CGST breakdown, and authorized signature.',
            icon: Icons.description_outlined,
            accentColor: const Color(0xFF1565C0),
            onPrint: () {
              Navigator.of(context).pop();
              OrderDocumentGenerator.printTaxInvoice(context: context, order: order);
            },
            onShare: () {
              Navigator.of(context).pop();
              OrderDocumentGenerator.shareTaxInvoice(context: context, order: order);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildDocumentCard({
    required BuildContext context,
    required String title,
    required String badge,
    required Color badgeColor,
    required String description,
    required IconData icon,
    required Color accentColor,
    required VoidCallback onPrint,
    required VoidCallback onShare,
  }) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFF9FBF9),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE4ECE8)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: accentColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: accentColor, size: 20),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          title,
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF11261B),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: badgeColor.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            badge,
                            style: TextStyle(
                              fontSize: 9.5,
                              fontWeight: FontWeight.bold,
                              color: badgeColor,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 2),
                    Text(
                      description,
                      style: const TextStyle(
                        fontSize: 11,
                        color: AppColors.textSecondaryLight,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                flex: 3,
                child: ElevatedButton.icon(
                  onPressed: onPrint,
                  icon: const Icon(Icons.print_rounded, size: 15),
                  label: const Text('Print / Preview', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF1A3827),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 9),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                flex: 2,
                child: OutlinedButton.icon(
                  onPressed: onShare,
                  icon: const Icon(Icons.share_outlined, size: 15, color: Color(0xFF1A3827)),
                  label: const Text('Share PDF', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF1A3827))),
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: Color(0xFF1A3827)),
                    padding: const EdgeInsets.symmetric(vertical: 9),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
