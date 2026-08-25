import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../data/models/inventory_model.dart';

class UpdateInventoryBottomSheet extends StatefulWidget {
  final InventoryModel inventory;
  final Function(int currentStock, int? minimumStock, String? remarks) onSave;

  const UpdateInventoryBottomSheet({
    super.key,
    required this.inventory,
    required this.onSave,
  });

  @override
  State<UpdateInventoryBottomSheet> createState() => _UpdateInventoryBottomSheetState();
}

class _UpdateInventoryBottomSheetState extends State<UpdateInventoryBottomSheet> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _currentStockController;
  late TextEditingController _minimumStockController;
  late TextEditingController _remarksController;
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    _currentStockController = TextEditingController(text: widget.inventory.currentStock.toString());
    _minimumStockController = TextEditingController(text: widget.inventory.minimumStock.toString());
    _remarksController = TextEditingController();
  }

  @override
  void dispose() {
    _currentStockController.dispose();
    _minimumStockController.dispose();
    _remarksController.dispose();
    super.dispose();
  }

  void _submit() {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isSubmitting = true;
      });

      final currentStock = int.parse(_currentStockController.text.trim());
      final minStockText = _minimumStockController.text.trim();
      final minimumStock = minStockText.isNotEmpty ? int.parse(minStockText) : null;
      final remarks = _remarksController.text.trim().isNotEmpty ? _remarksController.text.trim() : null;

      widget.onSave(currentStock, minimumStock, remarks);
    }
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;

    return Padding(
      padding: EdgeInsets.only(bottom: bottomInset),
      child: Container(
        padding: const EdgeInsets.all(24.0),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Handle Bar
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade300,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // Title Header
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: AppColors.primaryGreen.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(
                        Icons.inventory_2_outlined,
                        color: AppColors.primaryGreen,
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Update Stock',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF11261B),
                            ),
                          ),
                          Text(
                            widget.inventory.variant.variantName,
                            style: const TextStyle(
                              fontSize: 13,
                              color: AppColors.textSecondaryLight,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close_rounded, color: Colors.grey),
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  'SKU: ${widget.inventory.sku}',
                  style: const TextStyle(fontSize: 12, color: Colors.grey, fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 20),

                // Current Stock Field
                TextFormField(
                  controller: _currentStockController,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    labelText: 'Current Stock *',
                    hintText: 'Enter total physical stock',
                    prefixIcon: const Icon(Icons.numbers_outlined, color: AppColors.primaryGreen),
                    filled: true,
                    fillColor: const Color(0xFFF9FBF9),
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
                      borderSide: const BorderSide(color: AppColors.primaryGreen, width: 2),
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Current stock is required.';
                    }
                    final val = int.tryParse(value.trim());
                    if (val == null) {
                      return 'Please enter a valid integer number.';
                    }
                    if (val < 0) {
                      return 'Current stock cannot be negative.';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // Minimum Stock Field
                TextFormField(
                  controller: _minimumStockController,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    labelText: 'Minimum Stock (Alert Threshold)',
                    hintText: 'e.g. 5',
                    prefixIcon: const Icon(Icons.warning_amber_rounded, color: AppColors.brandOrange),
                    filled: true,
                    fillColor: const Color(0xFFF9FBF9),
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
                      borderSide: const BorderSide(color: AppColors.primaryGreen, width: 2),
                    ),
                  ),
                  validator: (value) {
                    if (value != null && value.trim().isNotEmpty) {
                      final val = int.tryParse(value.trim());
                      if (val == null) {
                        return 'Please enter a valid integer number.';
                      }
                      if (val < 0) {
                        return 'Minimum stock cannot be negative.';
                      }
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // Remarks Field
                TextFormField(
                  controller: _remarksController,
                  maxLines: 2,
                  decoration: InputDecoration(
                    labelText: 'Remarks / Reason',
                    hintText: 'e.g. Received new inventory shipment from supplier',
                    prefixIcon: const Icon(Icons.notes_rounded, color: Colors.grey),
                    filled: true,
                    fillColor: const Color(0xFFF9FBF9),
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
                      borderSide: const BorderSide(color: AppColors.primaryGreen, width: 2),
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                // Save Action Button
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: _isSubmitting ? null : _submit,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryGreen,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    child: _isSubmitting
                        ? const SizedBox(
                            width: 22,
                            height: 22,
                            child: CircularProgressIndicator(
                              strokeWidth: 2.5,
                              color: Colors.white,
                            ),
                          )
                        : const Text(
                            'SAVE INVENTORY',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 0.5,
                            ),
                          ),
                  ),
                ),
                const SizedBox(height: 10),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
