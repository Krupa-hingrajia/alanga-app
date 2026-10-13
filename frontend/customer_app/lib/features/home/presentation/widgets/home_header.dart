import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/widgets/badge_icon_button.dart';

class HomeHeader extends StatefulWidget {
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
  State<HomeHeader> createState() => _HomeHeaderState();
}

class _HomeHeaderState extends State<HomeHeader> with SingleTickerProviderStateMixin {
  final List<String> _searchHints = const [
    'Search "Fresh Fruits & Veggies"...',
    'Search "Dairy, Milk & Paneer"...',
    'Search "Snacks, Biscuits & Cold Drinks"...',
    'Search "Atta, Rice & Organic Staples"...',
    'Search "Personal Care & Home Needs"...',
  ];

  int _currentHintIndex = 0;
  Timer? _hintTimer;
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    )..repeat(reverse: true);

    _pulseAnimation = Tween<double>(begin: 0.96, end: 1.04).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    _hintTimer = Timer.periodic(const Duration(milliseconds: 2800), (timer) {
      if (mounted) {
        setState(() {
          _currentHintIndex = (_currentHintIndex + 1) % _searchHints.length;
        });
      }
    });
  }

  @override
  void dispose() {
    _hintTimer?.cancel();
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final topPadding = MediaQuery.of(context).padding.top;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark, // Clean dark status bar icons (Time, Battery, Wifi) on light header
        statusBarBrightness: Brightness.light,    // Clean dark iOS status bar text/icons
        systemNavigationBarColor: Colors.white,
        systemNavigationBarIconBrightness: Brightness.dark,
      ),
      child: Container(
        decoration: BoxDecoration(
          gradient: AppColors.lightGreenHeaderGradient,
          borderRadius: const BorderRadius.only(
            bottomLeft: Radius.circular(26),
            bottomRight: Radius.circular(26),
          ),
          border: const Border(
            bottom: BorderSide(color: Color(0xFFC0E4CF), width: 1.2),
          ),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF0C9A56).withValues(alpha: 0.08),
              blurRadius: 16,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Padding(
          padding: EdgeInsets.fromLTRB(16, topPadding + 6, 16, 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Top Row: Brand Emblem, Delivery Pill + Action Buttons
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // Alanga Logo Emblem with Animated Gradient Glow
                  ScaleTransition(
                    scale: _pulseAnimation,
                    child: Container(
                      width: 44,
                      height: 44,
                      padding: const EdgeInsets.all(2.2),
                      decoration: BoxDecoration(
                        gradient: AppColors.logoRibbonGradient,
                        borderRadius: BorderRadius.circular(14),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.ribbonAmber.withValues(alpha: 0.25),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: Image.asset(
                            'assets/images/app_icon.jpg',
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) => const Icon(
                              Icons.storefront_rounded,
                              color: AppColors.ribbonGold,
                              size: 24,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),

                  // Brand Title & Delivery Address
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Text(
                              'ALANGA',
                              style: TextStyle(
                                fontSize: 19.5,
                                fontWeight: FontWeight.w900,
                                color: Color(0xFF0C2417),
                                letterSpacing: 1.4,
                              ),
                            ),
                            const SizedBox(width: 6),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                gradient: AppColors.brandGoldGradient,
                                borderRadius: BorderRadius.circular(6),
                                boxShadow: [
                                  BoxShadow(
                                    color: AppColors.brandOrange.withValues(alpha: 0.25),
                                    blurRadius: 5,
                                    offset: const Offset(0, 1.5),
                                  ),
                                ],
                              ),
                              child: const Text(
                                'STORE',
                                style: TextStyle(
                                  fontSize: 9,
                                  fontWeight: FontWeight.w900,
                                  color: Color(0xFF1E281F),
                                  letterSpacing: 0.6,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 3),

                        // Delivery Location Pill
                        GestureDetector(
                          onTap: widget.onAddressTap ?? () {},
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(
                                Icons.location_on_rounded,
                                size: 14,
                                color: AppColors.brandOrange,
                              ),
                              const SizedBox(width: 2),
                              Flexible(
                                child: Text(
                                  'Deliver to ${widget.deliveryAddress}',
                                  style: const TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                    color: Color(0xFF1B4D31),
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              const SizedBox(width: 2),
                              const Icon(
                                Icons.keyboard_arrow_down_rounded,
                                size: 16,
                                color: Color(0xFF38684D),
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
                    count: widget.notificationCount,
                    backgroundColor: Colors.white,
                    borderColor: const Color(0xFFC0E4CF),
                    iconColor: const Color(0xFF0C2417),
                    onTap: widget.onNotificationTap ?? () {},
                  ),
                  const SizedBox(width: 8),
                  BadgeIconButton(
                    icon: Icons.shopping_bag_outlined,
                    count: widget.cartCount,
                    backgroundColor: Colors.white,
                    borderColor: const Color(0xFFC0E4CF),
                    iconColor: const Color(0xFF0C2417),
                    onTap: widget.onCartTap ?? () {},
                  ),
                ],
              ),
              const SizedBox(height: 14),

              // Premium Search Bar with Animated Hint Transition (Crisp White on Light Green)
              Container(
                height: 48,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: const Color(0xFFBCE0CB),
                    width: 1.2,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.04),
                      blurRadius: 10,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: Stack(
                  alignment: Alignment.centerLeft,
                  children: [
                    // Animated Rotating Hint Text (visible when search input is empty)
                    if (widget.searchController == null || widget.searchController!.text.isEmpty)
                      Positioned(
                        left: 44,
                        right: 48,
                        child: IgnorePointer(
                          child: AnimatedSwitcher(
                            duration: const Duration(milliseconds: 350),
                            transitionBuilder: (child, animation) {
                              return FadeTransition(
                                opacity: animation,
                                child: SlideTransition(
                                  position: Tween<Offset>(
                                    begin: const Offset(0, 0.4),
                                    end: Offset.zero,
                                  ).animate(animation),
                                  child: child,
                                ),
                              );
                            },
                            child: Text(
                              _searchHints[_currentHintIndex],
                              key: ValueKey<int>(_currentHintIndex),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontSize: 13,
                                color: Color(0xFF6B8A78),
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ),
                      ),

                    // Text Field
                    TextField(
                      controller: widget.searchController,
                      textInputAction: TextInputAction.search,
                      onSubmitted: widget.onSearchSubmitted,
                      onChanged: (_) {
                        if (mounted) setState(() {});
                      },
                      style: const TextStyle(
                        fontSize: 13.5,
                        color: Color(0xFF0F261A),
                        fontWeight: FontWeight.w600,
                      ),
                      decoration: InputDecoration(
                        hintText: '',
                        border: InputBorder.none,
                        enabledBorder: InputBorder.none,
                        focusedBorder: InputBorder.none,
                        prefixIcon: const Icon(
                          Icons.search_rounded,
                          color: AppColors.primaryGreen,
                          size: 22,
                        ),
                        suffixIcon: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              width: 1,
                              height: 18,
                              color: const Color(0xFFD4E2D9),
                            ),
                            IconButton(
                              icon: const Icon(
                                Icons.mic_none_rounded,
                                color: AppColors.brandOrange,
                                size: 21,
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
                          ],
                        ),
                        contentPadding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
