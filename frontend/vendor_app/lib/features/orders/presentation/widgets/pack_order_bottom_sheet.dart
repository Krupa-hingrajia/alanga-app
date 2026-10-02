import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/widgets/custom_image_view.dart';
import '../../data/models/vendor_order_model.dart';
import '../../utils/order_document_generator.dart';

class PackOrderBottomSheet extends StatefulWidget {
  final VendorOrderModel order;

  const PackOrderBottomSheet({
    super.key,
    required this.order,
  });

  /// Shows the packing checklist sheet. Returns true if user confirmed packing.
  static Future<bool?> show(BuildContext context, VendorOrderModel order) {
    return showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => PackOrderBottomSheet(order: order),
    );
  }

  @override
  State<PackOrderBottomSheet> createState() => _PackOrderBottomSheetState();
}

class _PackOrderBottomSheetState extends State<PackOrderBottomSheet> {
  late final Set<String> _checkedItems;
  bool _autoPrintLabel = true;

  @override
  void initState() {
    super.initState();
    // Default all items checked
    _checkedItems = widget.order.orderItems.map((item) => item.id).toSet();
  }

  @override
  Widget build(BuildContext context) {
    final allChecked = _checkedItems.length == widget.order.orderItems.length;

    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.85,
      ),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
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
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: const Color(0xFF7E22CE).withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(Icons.inventory_2_outlined, color: Color(0xFF7E22CE), size: 20),
                  ),
                  const SizedBox(width: 10),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Pack Order Checklist',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF11261B),
                        ),
                      ),
                      Text(
                        'Order #${widget.order.orderNumber} (${widget.order.orderItems.length} items)',
                        style: const TextStyle(
                          fontSize: 12,
                          color: AppColors.textSecondaryLight,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              IconButton(
                onPressed: () => Navigator.of(context).pop(false),
                icon: const Icon(Icons.close_rounded, size: 20, color: Color(0xFF6B7280)),
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
              ),
            ],
          ),
          const SizedBox(height: 14),

          // Instructions callout
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFFF3F4F6),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Row(
              children: [
                Icon(Icons.info_outline_rounded, size: 16, color: Color(0xFF4B5563)),
                SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Verify that all items, variants, and quantities are placed correctly inside the packaging box.',
                    style: TextStyle(fontSize: 11.5, color: Color(0xFF4B5563), height: 1.3),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),

          // Items Checklist
          Flexible(
            child: ListView.separated(
              shrinkWrap: true,
              itemCount: widget.order.orderItems.length,
              separatorBuilder: (context, index) => const SizedBox(height: 8),
              itemBuilder: (context, index) {
                final item = widget.order.orderItems[index];
                final isChecked = _checkedItems.contains(item.id);

                return InkWell(
                  onTap: () {
                    setState(() {
                      if (isChecked) {
                        _checkedItems.remove(item.id);
                      } else {
                        _checkedItems.add(item.id);
                      }
                    });
                  },
                  borderRadius: BorderRadius.circular(12),
                  child: Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: isChecked ? const Color(0xFFF8FAF8) : Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: isChecked ? AppColors.primaryGreen.withValues(alpha: 0.4) : const Color(0xFFE5E7EB),
                      ),
                    ),
                    child: Row(
                      children: [
                        Checkbox(
                          value: isChecked,
                          activeColor: AppColors.primaryGreen,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                          onChanged: (val) {
                            setState(() {
                              if (val == true) {
                                _checkedItems.add(item.id);
                              } else {
                                _checkedItems.remove(item.id);
                              }
                            });
                          },
                        ),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: CustomImageView(
                            imageUrl: item.productImage,
                            width: 44,
                            height: 44,
                            fit: BoxFit.cover,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                item.productName,
                                style: const TextStyle(
                                  fontSize: 12.5,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF11261B),
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              if (item.variantName != null && item.variantName!.isNotEmpty) ...[
                                const SizedBox(height: 2),
                                Text(
                                  'Variant: ${item.variantName}',
                                  style: const TextStyle(
                                    fontSize: 11,
                                    color: Color(0xFF6B7280),
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                              const SizedBox(height: 2),
                              Text(
                                'SKU: ${item.sku ?? "N/A"} • Qty: ${item.quantity}',
                                style: const TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.primaryGreen,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 14),

          // Auto-print switch
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: const Color(0xFFF9FBF9),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFFE4ECE8)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Row(
                  children: [
                    Icon(Icons.print_outlined, size: 18, color: AppColors.primaryGreen),
                    SizedBox(width: 8),
                    Text(
                      'Print Shipping Label now',
                      style: TextStyle(
                        fontSize: 12.5,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF11261B),
                      ),
                    ),
                  ],
                ),
                Switch.adaptive(
                  value: _autoPrintLabel,
                  activeTrackColor: AppColors.primaryGreen,
                  onChanged: (val) => setState(() => _autoPrintLabel = val),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Confirm button
          ElevatedButton.icon(
            onPressed: allChecked
                ? () {
                    Navigator.of(context).pop(true);
                    if (_autoPrintLabel) {
                      OrderDocumentGenerator.printShippingLabel(
                        context: context,
                        order: widget.order,
                      );
                    }
                  }
                : null,
            icon: const Icon(Icons.check_circle_outline_rounded, size: 18),
            label: Text(
              _autoPrintLabel ? 'Confirm Packed & Print Label' : 'Confirm Packed',
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF1A3827),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
          ),
        ],
      ),
    );
  }
}
