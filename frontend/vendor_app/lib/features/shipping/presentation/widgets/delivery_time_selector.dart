import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';

class DeliveryTimeSelector extends StatelessWidget {
  final TextEditingController minDaysController;
  final TextEditingController maxDaysController;

  const DeliveryTimeSelector({
    super.key,
    required this.minDaysController,
    required this.maxDaysController,
  });

  @override
  Widget build(BuildContext context) {
    final minVal = int.tryParse(minDaysController.text.trim()) ?? 3;
    final maxVal = int.tryParse(maxDaysController.text.trim()) ?? 7;
    final previewLabel = minVal == maxVal ? '$minVal Days' : '$minVal - $maxVal Days';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Estimated Delivery Time',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.bold,
                color: Color(0xFF11261B),
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: AppColors.primaryGreen.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: AppColors.primaryGreen.withValues(alpha: 0.3)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.local_shipping_outlined, size: 13, color: AppColors.primaryGreen),
                  const SizedBox(width: 4),
                  Text(
                    previewLabel,
                    style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primaryGreen,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            Expanded(
              child: TextFormField(
                controller: minDaysController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: 'Min Days',
                  hintText: 'e.g. 2',
                  prefixIcon: const Icon(Icons.today_outlined, color: AppColors.primaryGreen, size: 18),
                  filled: true,
                  fillColor: const Color(0xFFF9FBF9),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: Color(0xFFE4ECE8)),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: Color(0xFFE4ECE8)),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: AppColors.primaryGreen, width: 1.5),
                  ),
                ),
                validator: (val) {
                  if (val != null && val.trim().isNotEmpty) {
                    final num = int.tryParse(val.trim());
                    if (num == null || num < 1) return 'Min 1 day';
                  }
                  return null;
                },
              ),
            ),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 8.0),
              child: Text('to', style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold)),
            ),
            Expanded(
              child: TextFormField(
                controller: maxDaysController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: 'Max Days',
                  hintText: 'e.g. 5',
                  prefixIcon: const Icon(Icons.event_available_outlined, color: AppColors.primaryGreen, size: 18),
                  filled: true,
                  fillColor: const Color(0xFFF9FBF9),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: Color(0xFFE4ECE8)),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: Color(0xFFE4ECE8)),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: AppColors.primaryGreen, width: 1.5),
                  ),
                ),
                validator: (val) {
                  if (val != null && val.trim().isNotEmpty) {
                    final max = int.tryParse(val.trim());
                    final min = int.tryParse(minDaysController.text.trim()) ?? 1;
                    if (max == null || max < 1) return 'Min 1 day';
                    if (max < min) return 'Must be >= Min Days';
                  }
                  return null;
                },
              ),
            ),
          ],
        ),
      ],
    );
  }
}
