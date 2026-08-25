import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/dependency_injection/injection.dart';
import '../../../../core/storage/secure_storage_service.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  Map<String, dynamic>? _userData;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    final data = await sl<SecureStorageService>().getUserData();
    setState(() {
      _userData = data;
      _loading = false;
    });
  }

  void _onConfirmLogout() {
    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        backgroundColor: Colors.white,
        title: const Row(
          children: [
            Icon(Icons.logout_rounded, color: AppColors.brandRed, size: 22),
            SizedBox(width: 8),
            Text(
              'Confirm Logout',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFF11261B),
              ),
            ),
          ],
        ),
        content: const Text(
          'Are you sure you want to log out of your ALANGA account?',
          style: TextStyle(
            fontSize: 14,
            color: Color(0xFF4C6656),
          ),
        ),
        actionsPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text(
              'Cancel',
              style: TextStyle(
                color: Color(0xFF4C6656),
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.of(ctx).pop();
              await sl<SecureStorageService>().clearAll();
              if (mounted) {
                context.go('/login');
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.brandRed,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              elevation: 0,
            ),
            child: const Text(
              'Logout',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(
        backgroundColor: Color(0xFFF3F6F4),
        body: Center(child: CircularProgressIndicator(color: AppColors.primaryGreen)),
      );
    }

    final topPadding = MediaQuery.of(context).padding.top;
    final name = _userData?['fullName'] ?? 'Customer';
    final email = _userData?['email'] ?? 'customer@alanga.com';
    final phone = _userData?['mobileNumber'] != null
        ? '${_userData?['countryCode'] ?? "+91"} ${_userData?['mobileNumber']}'
        : '+91 9876543210';

    final initial = name.isNotEmpty ? name[0].toUpperCase() : 'C';

    return Scaffold(
      backgroundColor: const Color(0xFFF3F6F4),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // 1. Account Hero Header Banner
            Container(
              width: double.infinity,
              padding: EdgeInsets.fromLTRB(20, topPadding + 14, 20, 24),
              decoration: const BoxDecoration(
                color: AppColors.darkGreen,
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(28),
                  bottomRight: Radius.circular(28),
                ),
              ),
              child: Column(
                children: [
                  // Title Bar
                  const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'My Profile',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // Avatar & Details
                  Row(
                    children: [
                      Stack(
                        children: [
                          Container(
                            width: 72,
                            height: 72,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              gradient: const LinearGradient(
                                colors: [AppColors.brandOrange, AppColors.brandYellow],
                              ),
                              border: Border.all(color: Colors.white, width: 2.5),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.15),
                                  blurRadius: 10,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: Center(
                              child: Text(
                                initial,
                                style: const TextStyle(
                                  fontSize: 28,
                                  fontWeight: FontWeight.w900,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),
                          Positioned(
                            bottom: 0,
                            right: 0,
                            child: Container(
                              padding: const EdgeInsets.all(4),
                              decoration: const BoxDecoration(
                                color: AppColors.primaryGreen,
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.edit_rounded,
                                size: 12,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Flexible(
                                  child: Text(
                                    name,
                                    style: const TextStyle(
                                      fontSize: 19,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                      letterSpacing: -0.2,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                const SizedBox(width: 6),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: AppColors.brandYellow.withValues(alpha: 0.2),
                                    borderRadius: BorderRadius.circular(6),
                                    border: Border.all(
                                      color: AppColors.brandYellow.withValues(alpha: 0.5),
                                      width: 0.8,
                                    ),
                                  ),
                                  child: const Text(
                                    'VIP',
                                    style: TextStyle(
                                      color: AppColors.brandYellow,
                                      fontSize: 9,
                                      fontWeight: FontWeight.w900,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 4),
                            Text(
                              email,
                              style: const TextStyle(
                                fontSize: 12,
                                color: Color(0xFFB0CDC0),
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 2),
                            Text(
                              phone,
                              style: const TextStyle(
                                fontSize: 12,
                                color: Color(0xFFB0CDC0),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // 2. Account Quick Metrics Row
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.darkGreen.withValues(alpha: 0.06),
                      blurRadius: 14,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildMetricTile(
                      icon: Icons.local_shipping_outlined,
                      label: 'Orders',
                      count: '3 Active',
                      color: AppColors.primaryGreen,
                    ),
                    Container(height: 30, width: 1, color: const Color(0xFFE4ECE8)),
                    _buildMetricTile(
                      icon: Icons.favorite_border_rounded,
                      label: 'Wishlist',
                      count: '5 Items',
                      color: AppColors.brandRed,
                    ),
                    Container(height: 30, width: 1, color: const Color(0xFFE4ECE8)),
                    _buildMetricTile(
                      icon: Icons.confirmation_number_outlined,
                      label: 'Coupons',
                      count: '2 Off',
                      color: AppColors.brandOrange,
                    ),
                    Container(height: 30, width: 1, color: const Color(0xFFE4ECE8)),
                    _buildMetricTile(
                      icon: Icons.account_balance_wallet_outlined,
                      label: 'Wallet',
                      count: '₹500',
                      color: const Color(0xFF0284C7),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),

            // 3. Section: Orders & Activity
            _buildMenuSection(
              title: 'ORDERS & ACTIVITY',
              items: [
                _MenuItem(
                  icon: Icons.shopping_bag_outlined,
                  iconBgColor: const Color(0xFFECFDF5),
                  iconColor: AppColors.primaryGreen,
                  title: 'My Orders',
                  subtitle: 'Track, view, or return past orders',
                  onTap: () {},
                ),
                _MenuItem(
                  icon: Icons.location_on_outlined,
                  iconBgColor: const Color(0xFFFFFBEB),
                  iconColor: AppColors.brandOrange,
                  title: 'Saved Delivery Addresses',
                  subtitle: 'Home, Office, and other addresses',
                  onTap: () {},
                ),
                _MenuItem(
                  icon: Icons.favorite_outline_rounded,
                  iconBgColor: const Color(0xFFFEF2F2),
                  iconColor: AppColors.brandRed,
                  title: 'My Wishlist',
                  subtitle: 'View saved products & items',
                  onTap: () {},
                ),
              ],
            ),
            const SizedBox(height: 16),

            // 4. Section: Payments & Offers
            _buildMenuSection(
              title: 'PAYMENTS & OFFERS',
              items: [
                _MenuItem(
                  icon: Icons.payment_rounded,
                  iconBgColor: const Color(0xFFE0F2FE),
                  iconColor: const Color(0xFF0284C7),
                  title: 'Payment Methods & Cards',
                  subtitle: 'Manage UPI, Debit & Credit cards',
                  onTap: () {},
                ),
                _MenuItem(
                  icon: Icons.card_giftcard_rounded,
                  iconBgColor: const Color(0xFFF3E8FF),
                  iconColor: const Color(0xFF7E22CE),
                  title: 'My Coupons & Voucher Rewards',
                  subtitle: 'Check available discount vouchers',
                  onTap: () {},
                ),
              ],
            ),
            const SizedBox(height: 16),

            // 5. Section: Account Settings & Support
            _buildMenuSection(
              title: 'ACCOUNT & SUPPORT',
              items: [
                _MenuItem(
                  icon: Icons.person_outline_rounded,
                  iconBgColor: const Color(0xFFF3F6F4),
                  iconColor: AppColors.darkGreen,
                  title: 'Edit Profile Details',
                  subtitle: 'Name, email, mobile number',
                  onTap: () {},
                ),
                _MenuItem(
                  icon: Icons.help_outline_rounded,
                  iconBgColor: const Color(0xFFF3F6F4),
                  iconColor: AppColors.darkGreen,
                  title: 'Help Center & Support',
                  subtitle: 'FAQs, live chat & assistance',
                  onTap: () {},
                ),
                _MenuItem(
                  icon: Icons.shield_outlined,
                  iconBgColor: const Color(0xFFF3F6F4),
                  iconColor: AppColors.darkGreen,
                  title: 'Privacy Policy & Terms',
                  subtitle: 'ALANGA marketplace policies',
                  onTap: () {},
                ),
              ],
            ),
            const SizedBox(height: 24),

            // 6. Logout Button
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: ElevatedButton(
                onPressed: _onConfirmLogout,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: AppColors.brandRed,
                  side: const BorderSide(color: Color(0xFFFECACA), width: 1.2),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                  elevation: 0,
                ),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.logout_rounded, size: 20, color: AppColors.brandRed),
                    SizedBox(width: 8),
                    Text(
                      'LOGOUT',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 0.8,
                        color: AppColors.brandRed,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 36),
          ],
        ),
      ),
    );
  }

  Widget _buildMetricTile({
    required IconData icon,
    required String label,
    required String count,
    required Color color,
  }) {
    return Column(
      children: [
        Icon(icon, size: 22, color: color),
        const SizedBox(height: 4),
        Text(
          label,
          style: const TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.bold,
            color: Color(0xFF11261B),
          ),
        ),
        Text(
          count,
          style: TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.w600,
            color: color,
          ),
        ),
      ],
    );
  }

  Widget _buildMenuSection({
    required String title,
    required List<_MenuItem> items,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 4, bottom: 8),
            child: Text(
              title,
              style: const TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w800,
                color: Color(0xFF8BA697),
                letterSpacing: 0.8,
              ),
            ),
          ),
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: const Color(0xFFE4ECE8), width: 1),
              boxShadow: [
                BoxShadow(
                  color: AppColors.darkGreen.withValues(alpha: 0.04),
                  blurRadius: 10,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: Column(
              children: List.generate(items.length, (index) {
                final item = items[index];
                final isLast = index == items.length - 1;

                return Column(
                  children: [
                    InkWell(
                      onTap: item.onTap,
                      borderRadius: index == 0
                          ? const BorderRadius.vertical(top: Radius.circular(20))
                          : isLast
                              ? const BorderRadius.vertical(bottom: Radius.circular(20))
                              : BorderRadius.zero,
                      child: Padding(
                        padding: const EdgeInsets.all(14),
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: item.iconBgColor,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Icon(
                                item.icon,
                                color: item.iconColor,
                                size: 20,
                              ),
                            ),
                            const SizedBox(width: 14),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    item.title,
                                    style: const TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold,
                                      color: Color(0xFF11261B),
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    item.subtitle,
                                    style: const TextStyle(
                                      fontSize: 11,
                                      color: Color(0xFF7A9A86),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const Icon(
                              Icons.chevron_right_rounded,
                              color: Color(0xFF9CA3AF),
                              size: 20,
                            ),
                          ],
                        ),
                      ),
                    ),
                    if (!isLast)
                      const Divider(
                        height: 1,
                        indent: 58,
                        color: Color(0xFFF3F6F4),
                      ),
                  ],
                );
              }),
            ),
          ),
        ],
      ),
    );
  }
}

class _MenuItem {
  final IconData icon;
  final Color iconBgColor;
  final Color iconColor;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  _MenuItem({
    required this.icon,
    required this.iconBgColor,
    required this.iconColor,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });
}
