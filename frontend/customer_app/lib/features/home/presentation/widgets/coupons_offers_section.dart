import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../../core/constants/app_colors.dart';

class CouponsOffersSection extends StatelessWidget {
  const CouponsOffersSection({super.key});

  void _onCouponTapped(BuildContext context, String code, String discount) {
    Clipboard.setData(ClipboardData(text: code));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check_circle_rounded, color: Colors.white, size: 20),
            const SizedBox(width: 8),
            Text(
              'Coupon "$code" copied! ($discount)',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ],
        ),
        backgroundColor: AppColors.primaryGreen,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 2),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final coupons = [
      {
        'discount': 'FLAT ₹50 OFF',
        'minOrder': 'above ₹799',
        'code': 'FLAT50',
      },
      {
        'discount': 'FLAT ₹100 OFF',
        'minOrder': 'above ₹1399',
        'code': 'FLAT100',
      },
      {
        'discount': 'FLAT ₹150 OFF',
        'minOrder': 'above ₹2099',
        'code': 'FLAT150',
      },
      {
        'discount': 'FLAT ₹200 OFF',
        'minOrder': 'above ₹2699',
        'code': 'FLAT200',
      },
    ];

    final cashbackOffers = [
      {
        'title': 'Get instant ₹75 cashback with BHIM app',
        'subtitle': 'Valid on orders above ₹99',
        'code': 'BHIM75',
        'icon': Icons.account_balance_wallet_rounded,
        'iconColor': const Color(0xFF0D5C3A),
        'bgColor': const Color(0xFFF0FDF4),
      },
      {
        'title': 'Get Up to ₹50 cashback using Amazon Pay',
        'subtitle': 'Valid on orders above ₹199',
        'code': 'AMAZON50',
        'icon': Icons.payments_rounded,
        'iconColor': const Color(0xFFC2410C),
        'bgColor': const Color(0xFFFFF7ED),
      },
      {
        'title': 'Flat ₹100 Cashback with Paytm UPI',
        'subtitle': 'Valid for 1st order of the month',
        'code': 'PAYTM100',
        'icon': Icons.bolt_rounded,
        'iconColor': const Color(0xFF0369A1),
        'bgColor': const Color(0xFFF0F9FF),
      },
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Section Title (Zepto Style)
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Coupons & Offers',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF11261B),
                  letterSpacing: -0.3,
                ),
              ),
              InkWell(
                onTap: () {
                  _onCouponTapped(context, 'FLAT100', 'Flat ₹100 OFF');
                },
                child: const Text(
                  'View All',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: AppColors.primaryGreen,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),

        // 1. Horizontal Flat Discount Cards (Zepto Style)
        SizedBox(
          height: 104,
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            scrollDirection: Axis.horizontal,
            itemCount: coupons.length,
            itemBuilder: (context, index) {
              final c = coupons[index];
              return InkWell(
                onTap: () => _onCouponTapped(context, c['code']!, c['discount']!),
                borderRadius: BorderRadius.circular(16),
                child: Container(
                  width: 136,
                  margin: const EdgeInsets.only(right: 12),
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                  decoration: BoxDecoration(
                    color: const Color(0xFFE8F7EE),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: const Color(0xFFBBE5CD),
                      width: 1.2,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primaryGreen.withValues(alpha: 0.05),
                        blurRadius: 8,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Badge icon
                      Container(
                        padding: const EdgeInsets.all(5),
                        decoration: BoxDecoration(
                          color: AppColors.primaryGreen.withValues(alpha: 0.15),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.percent_rounded,
                          size: 15,
                          color: AppColors.primaryGreen,
                        ),
                      ),
                      const SizedBox(height: 6),
                      // Flat discount
                      Text(
                        c['discount']!,
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w900,
                          color: Color(0xFF0F3B20),
                          letterSpacing: -0.2,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 3),
                      // Min order pill
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(
                            color: const Color(0xFFBBE5CD),
                            width: 0.8,
                          ),
                        ),
                        child: Text(
                          c['minOrder']!,
                          style: const TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF235334),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 12),

        // 2. Bank / Wallet Cashback Banner Pills (Zepto Style)
        SizedBox(
          height: 62,
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            scrollDirection: Axis.horizontal,
            itemCount: cashbackOffers.length,
            itemBuilder: (context, index) {
              final offer = cashbackOffers[index];
              return InkWell(
                onTap: () => _onCouponTapped(context, offer['code'] as String, offer['title'] as String),
                borderRadius: BorderRadius.circular(14),
                child: Container(
                  width: 300,
                  margin: const EdgeInsets.only(right: 12),
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: const Color(0xFFE2ECE5), width: 1.2),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.03),
                        blurRadius: 6,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      // Cashback Icon Box
                      Container(
                        width: 38,
                        height: 38,
                        decoration: BoxDecoration(
                          color: offer['bgColor'] as Color,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                            color: (offer['iconColor'] as Color).withValues(alpha: 0.2),
                          ),
                        ),
                        child: Icon(
                          offer['icon'] as IconData,
                          size: 20,
                          color: offer['iconColor'] as Color,
                        ),
                      ),
                      const SizedBox(width: 10),
                      // Texts
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              offer['title'] as String,
                              style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w800,
                                color: Color(0xFF11261B),
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 2),
                            Text(
                              offer['subtitle'] as String,
                              style: TextStyle(
                                fontSize: 10.5,
                                fontWeight: FontWeight.w500,
                                color: Colors.grey.shade600,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                      const Icon(
                        Icons.chevron_right_rounded,
                        color: Color(0xFF9CA3AF),
                        size: 18,
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
