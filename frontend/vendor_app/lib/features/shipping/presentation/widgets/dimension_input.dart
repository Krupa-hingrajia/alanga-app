import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';

class DimensionInput extends StatelessWidget {
  final TextEditingController lengthController;
  final TextEditingController widthController;
  final TextEditingController heightController;
  final String selectedUnit;
  final ValueChanged<String> onUnitChanged;

  const DimensionInput({
    super.key,
    required this.lengthController,
    required this.widthController,
    required this.heightController,
    required this.selectedUnit,
    required this.onUnitChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Product Dimensions',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.bold,
                color: Color(0xFF11261B),
              ),
            ),
            // Unit Toggle (cm / inch)
            Container(
              height: 32,
              padding: const EdgeInsets.all(2),
              decoration: BoxDecoration(
                color: const Color(0xFFF4F8F5),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: const Color(0xFFE4ECE8)),
              ),
              child: Row(
                children: [
                  _buildUnitChip('cm', 'cm'),
                  _buildUnitChip('inch', 'inch'),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            Expanded(child: _buildDimensionField('Length', lengthController)),
            const SizedBox(width: 8),
            Expanded(child: _buildDimensionField('Width', widthController)),
            const SizedBox(width: 8),
            Expanded(child: _buildDimensionField('Height', heightController)),
          ],
        ),
      ],
    );
  }

  Widget _buildDimensionField(String label, TextEditingController controller) {
    return TextFormField(
      controller: controller,
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      decoration: InputDecoration(
        labelText: '$label (${selectedUnit.toLowerCase()})',
        labelStyle: const TextStyle(fontSize: 11, color: Colors.grey),
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
          final num = double.tryParse(val.trim());
          if (num == null) return 'Invalid';
          if (num < 0) return 'Cannot be < 0';
        }
        return null;
      },
    );
  }

  Widget _buildUnitChip(String value, String label) {
    final isSelected = selectedUnit.toLowerCase() == value.toLowerCase();
    return GestureDetector(
      onTap: () => onUnitChanged(value),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primaryGreen : Colors.transparent,
          borderRadius: BorderRadius.circular(6),
        ),
        alignment: Alignment.center,
        child: Text(
          label,
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.bold,
            color: isSelected ? Colors.white : const Color(0xFF5A7265),
          ),
        ),
      ),
    );
  }
}
