import 'dart:async';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_colors.dart';

class BannerCarousel extends StatefulWidget {
  const BannerCarousel({super.key});

  @override
  State<BannerCarousel> createState() => _BannerCarouselState();
}

class _BannerCarouselState extends State<BannerCarousel> {
  final PageController _pageController = PageController();
  int _currentPage = 0;
  Timer? _timer;

  final List<Map<String, dynamic>> _banners = [
    {
      'title': 'FRESH FARM HARVEST',
      'subtitle': 'Up to 50% OFF on Organic Veggies & Fruits',
      'badge': '10-MIN DELIVERY',
      'gradient': const [Color(0xFF092215), Color(0xFF15442A), Color(0xFF1F5C3B)],
      'accentColor': AppColors.brandYellow,
      'badgeColor': AppColors.primaryGreen,
      'icon': Icons.eco_rounded,
      'query': 'Fresh',
    },
    {
      'title': 'FLASH CARNIVAL SALE',
      'subtitle': 'Flat 60% OFF on Bestselling Grocery Essentials',
      'badge': 'LIMITED HOURS',
      'gradient': const [Color(0xFF991B1B), Color(0xFFDC2626), Color(0xFFEA580C)],
      'accentColor': Colors.white,
      'badgeColor': AppColors.brandYellow,
      'icon': Icons.local_fire_department_rounded,
      'query': 'Deal',
    },
    {
      'title': 'DAILY DAIRY & BREAKFAST',
      'subtitle': 'Fresh Milk, Artisanal Bread & Country Eggs',
      'badge': 'MORNING SPECIAL',
      'gradient': const [Color(0xFF9A3412), Color(0xFFD97706), Color(0xFFF59E0B)],
      'accentColor': Colors.white,
      'badgeColor': Colors.white,
      'icon': Icons.egg_alt_rounded,
      'query': 'Dairy',
    },
    {
      'title': 'MEGA CASHBACK WEEKEND',
      'subtitle': 'Flat ₹150 Cashback on Orders Above ₹999',
      'badge': 'EXTRA REWARD',
      'gradient': const [Color(0xFF064E3B), Color(0xFF059669), Color(0xFF10B981)],
      'accentColor': AppColors.brandYellow,
      'badgeColor': AppColors.brandYellow,
      'icon': Icons.wallet_giftcard_rounded,
      'query': 'Offer',
    },
  ];

  @override
  void initState() {
    super.initState();
    _startAutoSlide();
  }

  void _startAutoSlide() {
    _timer = Timer.periodic(const Duration(seconds: 4), (timer) {
      if (_pageController.hasClients) {
        _currentPage = (_currentPage + 1) % _banners.length;
        _pageController.animateToPage(
          _currentPage,
          duration: const Duration(milliseconds: 600),
          curve: Curves.easeInOutCubic,
        );
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(
          height: 158,
          child: PageView.builder(
            controller: _pageController,
            onPageChanged: (index) {
              setState(() {
                _currentPage = index;
              });
            },
            itemCount: _banners.length,
            itemBuilder: (context, index) {
              final banner = _banners[index];
              return GestureDetector(
                onTap: () {
                  final q = banner['query'] as String?;
                  if (q != null && q.isNotEmpty) {
                    context.push('/products', extra: q);
                  }
                },
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 16),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(22),
                    gradient: LinearGradient(
                      colors: banner['gradient'] as List<Color>,
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: (banner['gradient'][0] as Color).withValues(alpha: 0.35),
                        blurRadius: 16,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(22),
                    child: Stack(
                      children: [
                        // Decorative glowing circles
                        Positioned(
                          right: -25,
                          bottom: -25,
                          child: Container(
                            width: 150,
                            height: 150,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colors.white.withValues(alpha: 0.08),
                            ),
                          ),
                        ),
                        Positioned(
                          right: 35,
                          top: -30,
                          child: Container(
                            width: 90,
                            height: 90,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colors.white.withValues(alpha: 0.06),
                            ),
                          ),
                        ),

                        // Content
                        Padding(
                          padding: const EdgeInsets.all(20),
                          child: Row(
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                      decoration: BoxDecoration(
                                        color: Colors.black.withValues(alpha: 0.25),
                                        borderRadius: BorderRadius.circular(20),
                                        border: Border.all(
                                          color: Colors.white.withValues(alpha: 0.2),
                                          width: 0.8,
                                        ),
                                      ),
                                      child: Text(
                                        banner['badge'] as String,
                                        style: TextStyle(
                                          color: banner['badgeColor'] as Color,
                                          fontSize: 9,
                                          fontWeight: FontWeight.w900,
                                          letterSpacing: 0.8,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      banner['title'] as String,
                                      style: TextStyle(
                                        color: banner['accentColor'] as Color,
                                        fontSize: 16.5,
                                        fontWeight: FontWeight.w900,
                                        letterSpacing: 0.2,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      banner['subtitle'] as String,
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 11,
                                        fontWeight: FontWeight.w500,
                                        height: 1.25,
                                      ),
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ],
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.all(14),
                                decoration: BoxDecoration(
                                  color: Colors.white.withValues(alpha: 0.18),
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: Colors.white.withValues(alpha: 0.25),
                                    width: 1.5,
                                  ),
                                ),
                                child: Icon(
                                  banner['icon'] as IconData,
                                  size: 34,
                                  color: Colors.white,
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
            },
          ),
        ),
        const SizedBox(height: 10),

        // Animated Expanding Indicator Dots
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(
            _banners.length,
            (index) => AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeOutCubic,
              margin: const EdgeInsets.symmetric(horizontal: 3),
              height: 5.5,
              width: _currentPage == index ? 22 : 6,
              decoration: BoxDecoration(
                color: _currentPage == index
                    ? AppColors.primaryGreen
                    : AppColors.darkGreen.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
