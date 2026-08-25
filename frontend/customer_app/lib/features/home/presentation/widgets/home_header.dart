import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/widgets/badge_icon_button.dart';

class HomeHeader extends StatelessWidget {
  final String customerName;
  final String deliveryAddress;
  final int notificationCount;
  final int cartCount;
  final VoidCallback? onNotificationTap;
  final VoidCallback? onCartTap;
  final VoidCallback? onAddressTap;

  const HomeHeader({
    super.key,
    required this.customerName,
    this.deliveryAddress = 'Navi Mumbai, 400706',
    this.notificationCount = 3,
    this.cartCount = 2,
    this.onNotificationTap,
    this.onCartTap,
    this.onAddressTap,
  });

  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour >= 5 && hour < 12) {
      return 'Good Morning ☀️';
    } else if (hour >= 12 && hour < 17) {
      return 'Good Afternoon 🌤️';
    } else {
      return 'Good Evening 🌙';
    }
  }

  @override
  Widget build(BuildContext context) {
    final topPadding = MediaQuery.of(context).padding.top;

    return Container(
      padding: EdgeInsets.fromLTRB(16, topPadding + 8, 16, 14),
      decoration: const BoxDecoration(
        color: AppColors.darkGreen,
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(24),
          bottomRight: Radius.circular(24),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _getGreeting(),
                      style: const TextStyle(
                        fontSize: 12,
                        color: Color(0xFFA3C2B0),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      customerName,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        letterSpacing: -0.2,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              BadgeIconButton(
                icon: Icons.notifications_none_rounded,
                count: notificationCount,
                onTap: onNotificationTap ?? () {},
              ),
              const SizedBox(width: 10),
              BadgeIconButton(
                icon: Icons.shopping_bag_outlined,
                count: cartCount,
                onTap: onCartTap ?? () {},
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Delivery Location Selector Pill
          GestureDetector(
            onTap: onAddressTap ?? () {},
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: Colors.white.withValues(alpha: 0.2),
                  width: 0.8,
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.location_on_rounded,
                    size: 14,
                    color: AppColors.brandYellow,
                  ),
                  const SizedBox(width: 5),
                  const Text(
                    'Deliver to ',
                    style: TextStyle(
                      fontSize: 11,
                      color: Color(0xFFD0E0D7),
                    ),
                  ),
                  Flexible(
                    child: Text(
                      deliveryAddress,
                      style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(width: 4),
                  const Icon(
                    Icons.keyboard_arrow_down_rounded,
                    size: 16,
                    color: Colors.white,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
