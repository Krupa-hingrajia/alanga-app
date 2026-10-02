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
  final TextEditingController? searchController;
  final ValueChanged<String>? onSearchSubmitted;

  const HomeHeader({
    super.key,
    required this.customerName,
    this.deliveryAddress = 'Navi Mumbai, 400706',
    this.notificationCount = 3,
    this.cartCount = 2,
    this.onNotificationTap,
    this.onCartTap,
    this.onAddressTap,
    this.searchController,
    this.onSearchSubmitted,
  });

  @override
  Widget build(BuildContext context) {
    final topPadding = MediaQuery.of(context).padding.top;

    return Container(
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [
            Color(0xFF072717),
            Color(0xFF0D4726),
            Color(0xFF15803D),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(26),
          bottomRight: Radius.circular(26),
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF072717).withValues(alpha: 0.25),
            blurRadius: 18,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Stack(
        children: [
          // Ambient decorative glow circles
          Positioned(
            right: -30,
            top: -20,
            child: Container(
              width: 140,
              height: 140,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withValues(alpha: 0.05),
              ),
            ),
          ),
          Positioned(
            left: -20,
            bottom: -20,
            child: Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color(0xFF10B981).withValues(alpha: 0.08),
              ),
            ),
          ),

          // Main Header Content
          Padding(
            padding: EdgeInsets.fromLTRB(16, topPadding + 6, 16, 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Top Row: Brand & Delivery Pill + Actions
                Row(
                  children: [
                    // Brand & Delivery Pill Column
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              const Text(
                                'ALANGA',
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.w900,
                                  color: Colors.white,
                                  letterSpacing: 1.2,
                                ),
                              ),
                              const SizedBox(width: 6),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFFBBF24),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: const Text(
                                  'STORE',
                                  style: TextStyle(
                                    fontSize: 9,
                                    fontWeight: FontWeight.w900,
                                    color: Color(0xFF1F2937),
                                    letterSpacing: 0.5,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 3),

                          // Delivery Location Pill
                          GestureDetector(
                            onTap: onAddressTap ?? () {},
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(
                                  Icons.flash_on_rounded,
                                  size: 14,
                                  color: Color(0xFFFBBF24),
                                ),
                                const SizedBox(width: 2),
                                Flexible(
                                  child: Text(
                                    'Deliver to $deliveryAddress',
                                    style: const TextStyle(
                                      fontSize: 11.5,
                                      fontWeight: FontWeight.w600,
                                      color: Color(0xFFD1FAE5),
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                const SizedBox(width: 2),
                                const Icon(
                                  Icons.keyboard_arrow_down_rounded,
                                  size: 16,
                                  color: Color(0xFFD1FAE5),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Actions: Notification & Cart Buttons
                    BadgeIconButton(
                      icon: Icons.notifications_none_rounded,
                      count: notificationCount,
                      onTap: onNotificationTap ?? () {},
                    ),
                    const SizedBox(width: 8),
                    BadgeIconButton(
                      icon: Icons.shopping_bag_outlined,
                      count: cartCount,
                      onTap: onCartTap ?? () {},
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                // Integrated Search Bar
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(14),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.12),
                        blurRadius: 10,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: TextField(
                    controller: searchController,
                    textInputAction: TextInputAction.search,
                    onSubmitted: onSearchSubmitted,
                    style: const TextStyle(fontSize: 13.5, color: Color(0xFF11261B)),
                    decoration: InputDecoration(
                      hintText: 'Search for clothes, gadgets, essentials...',
                      hintStyle: const TextStyle(
                        fontSize: 12.5,
                        color: Color(0xFF8BA697),
                        fontWeight: FontWeight.normal,
                      ),
                      prefixIcon: const Icon(
                        Icons.search_rounded,
                        color: AppColors.primaryGreen,
                        size: 22,
                      ),
                      suffixIcon: IconButton(
                        icon: const Icon(
                          Icons.mic_none_rounded,
                          color: AppColors.brandOrange,
                          size: 20,
                        ),
                        onPressed: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Voice Search coming soon!'),
                              duration: Duration(seconds: 2),
                            ),
                          );
                        },
                      ),
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
