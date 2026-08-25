import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';

class WeightSelector extends StatelessWidget {
  final TextEditingController weightController;
  final String selectedUnit;
  final ValueChanged<String> onUnitChanged;

  const WeightSelector({
    super.key,
    required this.weightController,
    required this.selectedUnit,
    required this.onUnitChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Product Weight',
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.bold,
            color: Color(0xFF11261B),
          ),
        ),
        const SizedBox(height: 8),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Weight Number Field
            Expanded(
              flex: 3,
              child: TextFormField(
                controller: weightController,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                decoration: InputDecoration(
                  hintText: 'e.g. 0.5',
                  prefixIcon: const Icon(Icons.scale_outlined, color: AppColors.primaryGreen, size: 20),
                  filled: true,
                  fillColor: const Color(0xFFF9FBF9),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
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
                    final num = double.tryParse(val.trim());
                    if (num == null) return 'Invalid weight';
                    if (num < 0) return 'Weight cannot be negative';
                  }
                  return null;
                },
              ),
            ),
            const SizedBox(width: 10),

            // Weight Unit Choice Chips (gm / kg)
            Expanded(
              flex: 2,
              child: Container(
                height: 48,
                decoration: BoxDecoration(
                  color: const Color(0xFFF4F8F5),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFFE4ECE8)),
                ),
                child: Row(
                  children: [
                    _buildUnitOption('gm', 'Gram (gm)'),
                    _buildUnitOption('kg', 'Kilogram (kg)'),
                  ],
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildUnitOption(String value, String label) {
    final isSelected = selectedUnit.toLowerCase() == value.toLowerCase();
    return Expanded(
      child: GestureDetector(
        onTap: () => onUnitChanged(value),
        child: Container(
          decoration: BoxDecoration(
            color: isSelected ? AppColors.primaryGreen : Colors.transparent,
            borderRadius: BorderRadius.circular(10),
          ),
          alignment: Alignment.center,
          child: Text(
            value.toUpperCase(),
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: isSelected ? Colors.white : const Color(0xFF5A7265),
            ),
          ),
        ),
      ),
    );
  }
}
