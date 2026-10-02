import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';

class CancelOrderDialog extends StatefulWidget {
  final String orderNumber;

  const CancelOrderDialog({
    super.key,
    required this.orderNumber,
  });

  static Future<String?> show(BuildContext context, String orderNumber) {
    return showDialog<String>(
      context: context,
      builder: (_) => CancelOrderDialog(orderNumber: orderNumber),
    );
  }

  @override
  State<CancelOrderDialog> createState() => _CancelOrderDialogState();
}

class _CancelOrderDialogState extends State<CancelOrderDialog> {
  final _customReasonCtrl = TextEditingController();
  String _selectedReason = 'Item is out of stock';

  final List<String> _predefinedReasons = const [
    'Item is out of stock',
    'Customer requested cancellation',
    'Delivery address is unserviceable',
    'Incorrect product price or details',
    'Other reason',
  ];

  @override
  void dispose() {
    _customReasonCtrl.dispose();
    super.dispose();
  }

  void _submit() {
    String finalReason = _selectedReason;
    if (_selectedReason == 'Other reason') {
      final text = _customReasonCtrl.text.trim();
      if (text.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please specify the cancellation reason')),
        );
        return;
      }
      finalReason = text;
    }
    Navigator.of(context).pop(finalReason);
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      title: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppColors.brandRed.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.cancel_outlined, color: AppColors.brandRed, size: 22),
          ),
          const SizedBox(width: 12),
          const Expanded(
            child: Text(
              'Cancel Order',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF11261B)),
            ),
          ),
        ],
      ),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Are you sure you want to cancel order #${widget.orderNumber}? Product inventory will be restored automatically.',
              style: const TextStyle(fontSize: 13, color: Color(0xFF4C6656), height: 1.4),
            ),
            const SizedBox(height: 14),
            const Text(
              'Select Reason for Cancellation:',
              style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF11261B)),
            ),
            const SizedBox(height: 8),
            ..._predefinedReasons.map((reason) {
              final isSelected = _selectedReason == reason;
              return InkWell(
                onTap: () {
                  setState(() {
                    _selectedReason = reason;
                  });
                },
                borderRadius: BorderRadius.circular(8),
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 7, horizontal: 4),
                  child: Row(
                    children: [
                      Icon(
                        isSelected ? Icons.radio_button_checked : Icons.radio_button_off,
                        color: isSelected ? AppColors.brandRed : Colors.grey,
                        size: 18,
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          reason,
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                            color: isSelected ? const Color(0xFF11261B) : const Color(0xFF4B5563),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }),
            if (_selectedReason == 'Other reason') ...[
              const SizedBox(height: 8),
              TextField(
                controller: _customReasonCtrl,
                maxLines: 2,
                decoration: InputDecoration(
                  hintText: 'Enter reason details...',
                  hintStyle: const TextStyle(fontSize: 12, color: Colors.grey),
                  filled: true,
                  fillColor: const Color(0xFFF9FAF9),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: const BorderSide(color: Color(0xFFE4ECE8)),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Keep Order', style: TextStyle(color: Colors.grey)),
        ),
        ElevatedButton(
          onPressed: _submit,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.brandRed,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
          child: const Text('Confirm Cancel', style: TextStyle(fontWeight: FontWeight.bold)),
        ),
      ],
    );
  }
}
