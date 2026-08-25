import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../data/models/product_shipping_model.dart';
import 'weight_selector.dart';
import 'dimension_input.dart';
import 'delivery_time_selector.dart';
import 'shipping_switch_tile.dart';

class ShippingCard extends StatefulWidget {
  final ProductShippingModel? initialShipping;
  final String productId;
  final Function(ProductShippingModel shipping) onSave;
  final ValueChanged<ProductShippingModel>? onChanged;
  final bool isSaving;

  const ShippingCard({
    super.key,
    this.initialShipping,
    required this.productId,
    required this.onSave,
    this.onChanged,
    this.isSaving = false,
  });

  @override
  State<ShippingCard> createState() => _ShippingCardState();
}

class _ShippingCardState extends State<ShippingCard> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _weightController;
  String _weightUnit = 'kg';

  late TextEditingController _lengthController;
  late TextEditingController _widthController;
  late TextEditingController _heightController;
  String _dimensionUnit = 'cm';

  late TextEditingController _shippingChargeController;
  bool _isFreeShipping = false;
  late TextEditingController _freeShippingAboveController;

  late TextEditingController _minDaysController;
  late TextEditingController _maxDaysController;

  bool _codAvailable = true;

  @override
  void initState() {
    super.initState();
    _populateFields(widget.initialShipping);
  }

  @override
  void didUpdateWidget(covariant ShippingCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.initialShipping != oldWidget.initialShipping && widget.initialShipping != null) {
      _populateFields(widget.initialShipping);
    }
  }

  void _populateFields(ProductShippingModel? shipping) {
    _weightController = TextEditingController(
      text: shipping != null && shipping.weight > 0 ? shipping.weight.toString() : '',
    );
    _weightUnit = shipping?.weightUnit ?? 'kg';

    _lengthController = TextEditingController(
      text: shipping != null && shipping.length > 0 ? shipping.length.toString() : '',
    );
    _widthController = TextEditingController(
      text: shipping != null && shipping.width > 0 ? shipping.width.toString() : '',
    );
    _heightController = TextEditingController(
      text: shipping != null && shipping.height > 0 ? shipping.height.toString() : '',
    );
    _dimensionUnit = shipping?.dimensionUnit ?? 'cm';

    _shippingChargeController = TextEditingController(
      text: shipping != null ? shipping.shippingCharge.toStringAsFixed(0) : '0',
    );

    _isFreeShipping = shipping?.isFreeShipping ?? false;
    _freeShippingAboveController = TextEditingController(
      text: shipping?.freeShippingAboveAmount != null
          ? shipping!.freeShippingAboveAmount!.toStringAsFixed(0)
          : '',
    );

    _minDaysController = TextEditingController(
      text: shipping != null ? shipping.estimatedDeliveryMinDays.toString() : '3',
    );
    _maxDaysController = TextEditingController(
      text: shipping != null ? shipping.estimatedDeliveryMaxDays.toString() : '7',
    );

    _codAvailable = shipping?.codAvailable ?? true;

    _addListeners();
  }

  void _addListeners() {
    _weightController.addListener(_notifyChange);
    _lengthController.addListener(_notifyChange);
    _widthController.addListener(_notifyChange);
    _heightController.addListener(_notifyChange);
    _shippingChargeController.addListener(_notifyChange);
    _freeShippingAboveController.addListener(_notifyChange);
    _minDaysController.addListener(_notifyChange);
    _maxDaysController.addListener(_notifyChange);
  }

  void _notifyChange() {
    if (widget.onChanged == null) return;
    final weight = double.tryParse(_weightController.text.trim()) ?? 0.0;
    final length = double.tryParse(_lengthController.text.trim()) ?? 0.0;
    final width = double.tryParse(_widthController.text.trim()) ?? 0.0;
    final height = double.tryParse(_heightController.text.trim()) ?? 0.0;
    final shippingCharge = double.tryParse(_shippingChargeController.text.trim()) ?? 0.0;

    final freeAboveText = _freeShippingAboveController.text.trim();
    final freeShippingAbove = freeAboveText.isNotEmpty ? double.tryParse(freeAboveText) : null;

    final minDays = int.tryParse(_minDaysController.text.trim()) ?? 3;
    final maxDays = int.tryParse(_maxDaysController.text.trim()) ?? 7;

    final liveModel = ProductShippingModel(
      id: widget.initialShipping?.id,
      productId: widget.productId,
      weight: weight,
      weightUnit: _weightUnit,
      length: length,
      width: width,
      height: height,
      dimensionUnit: _dimensionUnit,
      shippingCharge: shippingCharge,
      isFreeShipping: _isFreeShipping,
      freeShippingAboveAmount: freeShippingAbove,
      estimatedDeliveryMinDays: minDays,
      estimatedDeliveryMaxDays: maxDays,
      codAvailable: _codAvailable,
      estimatedDeliveryLabel: minDays == maxDays ? '$minDays Days' : '$minDays-$maxDays Days',
    );
    widget.onChanged!(liveModel);
  }

  @override
  void dispose() {
    _weightController.dispose();
    _lengthController.dispose();
    _widthController.dispose();
    _heightController.dispose();
    _shippingChargeController.dispose();
    _freeShippingAboveController.dispose();
    _minDaysController.dispose();
    _maxDaysController.dispose();
    super.dispose();
  }

  void _submit() {
    if (_formKey.currentState!.validate()) {
      final weight = double.tryParse(_weightController.text.trim()) ?? 0.0;
      final length = double.tryParse(_lengthController.text.trim()) ?? 0.0;
      final width = double.tryParse(_widthController.text.trim()) ?? 0.0;
      final height = double.tryParse(_heightController.text.trim()) ?? 0.0;
      final shippingCharge = double.tryParse(_shippingChargeController.text.trim()) ?? 0.0;

      final freeAboveText = _freeShippingAboveController.text.trim();
      final freeShippingAbove = freeAboveText.isNotEmpty ? double.tryParse(freeAboveText) : null;

      final minDays = int.tryParse(_minDaysController.text.trim()) ?? 3;
      final maxDays = int.tryParse(_maxDaysController.text.trim()) ?? 7;

      final model = ProductShippingModel(
        id: widget.initialShipping?.id,
        productId: widget.productId,
        weight: weight,
        weightUnit: _weightUnit,
        length: length,
        width: width,
        height: height,
        dimensionUnit: _dimensionUnit,
        shippingCharge: shippingCharge,
        isFreeShipping: _isFreeShipping,
        freeShippingAboveAmount: freeShippingAbove,
        estimatedDeliveryMinDays: minDays,
        estimatedDeliveryMaxDays: maxDays,
        codAvailable: _codAvailable,
      );

      widget.onSave(model);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFE4ECE8)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Card Title Header
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: AppColors.primaryGreen.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.local_shipping_outlined,
                    color: AppColors.primaryGreen,
                    size: 22,
                  ),
                ),
                const SizedBox(width: 12),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Shipping Configuration',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF11261B),
                        ),
                      ),
                      Text(
                        'Configure weight, dimensions, delivery rates & COD',
                        style: TextStyle(fontSize: 11.5, color: Colors.grey),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 18),
            const Divider(height: 1, color: Color(0xFFF0F4F1)),
            const SizedBox(height: 18),

            // 1. Weight Section
            WeightSelector(
              weightController: _weightController,
              selectedUnit: _weightUnit,
              onUnitChanged: (unit) {
                setState(() {
                  _weightUnit = unit;
                });
                _notifyChange();
              },
            ),
            const SizedBox(height: 18),

            // 2. Dimensions Section
            DimensionInput(
              lengthController: _lengthController,
              widthController: _widthController,
              heightController: _heightController,
              selectedUnit: _dimensionUnit,
              onUnitChanged: (unit) {
                setState(() {
                  _dimensionUnit = unit;
                });
                _notifyChange();
              },
            ),
            const SizedBox(height: 18),

            // 3. Shipping Charge Field
            TextFormField(
              controller: _shippingChargeController,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              decoration: InputDecoration(
                labelText: 'Standard Shipping Charge (₹) *',
                hintText: 'e.g. 50 (Enter 0 for free delivery)',
                prefixIcon: const Icon(Icons.payments_outlined, color: AppColors.primaryGreen, size: 20),
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
                  if (num == null) return 'Please enter a valid amount';
                  if (num < 0) return 'Shipping charge cannot be negative';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),

            // 4. Free Shipping Toggle & Threshold
            ShippingSwitchTile(
              title: 'Free Shipping Offer',
              subtitle: 'Offer zero delivery charge on this product',
              icon: Icons.card_giftcard_outlined,
              value: _isFreeShipping,
              onChanged: (val) {
                setState(() {
                  _isFreeShipping = val;
                });
                _notifyChange();
              },
            ),

            if (_isFreeShipping) ...[
              const SizedBox(height: 12),
              TextFormField(
                controller: _freeShippingAboveController,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                decoration: InputDecoration(
                  labelText: 'Free Shipping Above Order Amount (₹)',
                  hintText: 'e.g. 499 (Leave empty for unconditionally free)',
                  prefixIcon: const Icon(Icons.sell_outlined, color: AppColors.brandOrange, size: 20),
                  filled: true,
                  fillColor: const Color(0xFFFFFBF7),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: Color(0xFFFFE0B2)),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: Color(0xFFFFE0B2)),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: AppColors.brandOrange, width: 1.5),
                  ),
                ),
                validator: (val) {
                  if (val != null && val.trim().isNotEmpty) {
                    final num = double.tryParse(val.trim());
                    if (num == null) return 'Please enter a valid amount';
                    if (num < 0) return 'Minimum amount cannot be negative';
                  }
                  return null;
                },
              ),
            ],
            const SizedBox(height: 18),

            // 5. Estimated Delivery Selector
            DeliveryTimeSelector(
              minDaysController: _minDaysController,
              maxDaysController: _maxDaysController,
            ),
            const SizedBox(height: 18),

            // 6. Cash On Delivery Toggle
            ShippingSwitchTile(
              title: 'Cash on Delivery (COD)',
              subtitle: 'Allow customer to pay cash upon product delivery',
              icon: Icons.monetization_on_outlined,
              value: _codAvailable,
              onChanged: (val) {
                setState(() {
                  _codAvailable = val;
                });
                _notifyChange();
              },
            ),
            const SizedBox(height: 24),

            // 7. Save Action Button
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton.icon(
                onPressed: widget.isSaving ? null : _submit,
                icon: widget.isSaving
                    ? const SizedBox.shrink()
                    : const Icon(Icons.save_rounded, size: 18),
                label: widget.isSaving
                    ? const SizedBox(
                        width: 22,
                        height: 22,
                        child: CircularProgressIndicator(
                          strokeWidth: 2.5,
                          color: Colors.white,
                        ),
                      )
                    : const Text(
                        'SAVE SHIPPING INFORMATION',
                        style: TextStyle(
                          fontSize: 13.5,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 0.5,
                        ),
                      ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryGreen,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
