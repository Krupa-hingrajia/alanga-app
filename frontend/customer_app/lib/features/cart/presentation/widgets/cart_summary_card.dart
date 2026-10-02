import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_colors.dart';
import '../../data/models/cart_summary_model.dart';

class CartSummaryCard extends StatefulWidget {
  final CartSummaryModel summary;

  const CartSummaryCard({super.key, required this.summary});

  @override
  State<CartSummaryCard> createState() => _CartSummaryCardState();
}

class _CartSummaryCardState extends State<CartSummaryCard> {
  final TextEditingController _couponController = TextEditingController();
  bool _isCouponApplied = false;
  String? _appliedCouponCode;
  double _couponDiscount = 0.0;

  @override
  void dispose() {
    _couponController.dispose();
    super.dispose();
  }

  void _applyCoupon() {
    final code = _couponController.text.trim().toUpperCase();
    if (code.isEmpty) return;

    if (code == 'ALANGA100' || code == 'WELCOME' || code == 'SAVE50') {
      final discount = code == 'ALANGA100' ? 100.0 : 50.0;
      setState(() {
        _isCouponApplied = true;
        _appliedCouponCode = code;
        _couponDiscount = discount;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.celebration_rounded, color: Colors.white, size: 20),
              const SizedBox(width: 8),
              Text('Coupon $code applied! You saved ₹${discount.toStringAsFixed(0)}'),
            ],
          ),
          backgroundColor: AppColors.primaryGreen,
          duration: const Duration(seconds: 3),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Invalid coupon code. Try ALANGA100 or SAVE50'),
          backgroundColor: AppColors.brandRed,
          duration: Duration(seconds: 3),
        ),
      );
    }
  }

  void _removeCoupon() {
    setState(() {
      _isCouponApplied = false;
      _appliedCouponCode = null;
      _couponDiscount = 0.0;
      _couponController.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    final summary = widget.summary;
    final isFreeShipping = summary.shippingCharge <= 0;
    final finalPayable = (summary.estimatedTotal - _couponDiscount).clamp(0.0, double.infinity);

    return Container(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 18,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Out of stock warning banner
            if (summary.hasOutOfStockItems) ...[
              Container(
                margin: const EdgeInsets.only(bottom: 14),
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: AppColors.brandRed.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: AppColors.brandRed.withValues(alpha: 0.3)),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.warning_amber_rounded, color: AppColors.brandRed, size: 18),
                    SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Please remove out-of-stock items before proceeding to checkout.',
                        style: TextStyle(
                          color: AppColors.brandRed,
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],

            // Coupon / Promo Code Section
            Container(
              margin: const EdgeInsets.only(bottom: 14),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: const Color(0xFFF7FAF8),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: _isCouponApplied ? AppColors.primaryGreen : const Color(0xFFD4E2D9),
                  width: _isCouponApplied ? 1.5 : 1.0,
                ),
              ),
              child: _isCouponApplied
                  ? Row(
                      children: [
                        const Icon(Icons.check_circle_rounded, color: AppColors.primaryGreen, size: 18),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            '$_appliedCouponCode applied (-₹${_couponDiscount.toStringAsFixed(0)})',
                            style: const TextStyle(
                              color: AppColors.primaryGreen,
                              fontSize: 12.5,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        TextButton(
                          onPressed: _removeCoupon,
                          style: TextButton.styleFrom(
                            padding: EdgeInsets.zero,
                            minimumSize: Size.zero,
                            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          ),
                          child: const Text(
                            'Remove',
                            style: TextStyle(color: AppColors.brandRed, fontSize: 11.5, fontWeight: FontWeight.bold),
                          ),
                        ),
                      ],
                    )
                  : Row(
                      children: [
                        const Icon(Icons.local_offer_outlined, color: AppColors.primaryGreen, size: 18),
                        const SizedBox(width: 8),
                        Expanded(
                          child: TextField(
                            controller: _couponController,
                            textCapitalization: TextCapitalization.characters,
                            style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.bold),
                            decoration: const InputDecoration(
                              hintText: 'Enter Coupon (e.g. ALANGA100)',
                              hintStyle: TextStyle(fontSize: 12, color: Colors.grey, fontWeight: FontWeight.normal),
                              border: InputBorder.none,
                              isDense: true,
                              contentPadding: EdgeInsets.symmetric(vertical: 6),
                            ),
                          ),
                        ),
                        TextButton(
                          onPressed: _applyCoupon,
                          style: TextButton.styleFrom(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            minimumSize: Size.zero,
                            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          ),
                          child: const Text(
                            'APPLY',
                            style: TextStyle(
                              color: AppColors.primaryGreen,
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                            ),
                          ),
                        ),
                      ],
                    ),
            ),

            // Order Summary Title & Items count
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Bill Summary',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF11261B),
                  ),
                ),
                Text(
                  '${summary.totalItems} items',
                  style: const TextStyle(fontSize: 12, color: Colors.grey, fontWeight: FontWeight.w600),
                ),
              ],
            ),
            const SizedBox(height: 10),

            // Subtotal
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Item Total',
                  style: TextStyle(fontSize: 13, color: Color(0xFF5A7265)),
                ),
                Text(
                  '₹${summary.subtotal.toStringAsFixed(0)}',
                  style: const TextStyle(fontSize: 13.5, fontWeight: FontWeight.w600, color: Color(0xFF11261B)),
                ),
              ],
            ),
            const SizedBox(height: 6),

            // Delivery Fee
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Delivery Fee',
                  style: TextStyle(fontSize: 13, color: Color(0xFF5A7265)),
                ),
                Text(
                  isFreeShipping ? 'FREE' : '₹${summary.shippingCharge.toStringAsFixed(0)}',
                  style: TextStyle(
                    fontSize: 13.5,
                    fontWeight: FontWeight.bold,
                    color: isFreeShipping ? AppColors.primaryGreen : const Color(0xFF11261B),
                  ),
                ),
              ],
            ),

            // Coupon discount if applied
            if (_isCouponApplied) ...[
              const SizedBox(height: 6),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Coupon Discount',
                    style: TextStyle(fontSize: 13, color: AppColors.primaryGreen, fontWeight: FontWeight.w600),
                  ),
                  Text(
                    '- ₹${_couponDiscount.toStringAsFixed(0)}',
                    style: const TextStyle(
                      fontSize: 13.5,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primaryGreen,
                    ),
                  ),
                ],
              ),
            ],

            const SizedBox(height: 10),
            const Divider(height: 1, color: Color(0xFFEEF3F0)),
            const SizedBox(height: 10),

            // Total Amount Row
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Total Payable',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF11261B),
                      ),
                    ),
                    Text(
                      'Inclusive of all taxes',
                      style: TextStyle(fontSize: 10, color: Colors.grey),
                    ),
                  ],
                ),
                Text(
                  '₹${finalPayable.toStringAsFixed(0)}',
                  style: const TextStyle(
                    fontSize: 21,
                    fontWeight: FontWeight.w800,
                    color: AppColors.primaryGreen,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),

            // Proceed to Checkout Button
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: summary.hasOutOfStockItems
                    ? null
                    : () {
                        context.push('/checkout');
                      },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF143021),
                  foregroundColor: Colors.white,
                  disabledBackgroundColor: Colors.grey.shade300,
                  disabledForegroundColor: Colors.grey.shade600,
                  elevation: 2,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                ),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'PROCEED TO CHECKOUT',
                      style: TextStyle(
                        fontSize: 13.5,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0.5,
                      ),
                    ),
                    SizedBox(width: 8),
                    Icon(Icons.arrow_forward_rounded, size: 18),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 10),

            // Trust guarantee footer
            const Center(
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.shield_outlined, size: 13, color: Colors.grey),
                  SizedBox(width: 4),
                  Text(
                    'Safe & Secure Checkout • 100% Genuine Guarantee',
                    style: TextStyle(fontSize: 10.5, color: Colors.grey, fontWeight: FontWeight.w500),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
