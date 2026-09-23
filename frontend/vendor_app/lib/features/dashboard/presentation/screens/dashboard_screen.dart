import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shimmer/shimmer.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/dependency_injection/injection.dart';
import '../../../../core/storage/secure_storage_service.dart';

// Category imports
import '../../../categories/data/models/category_model.dart';
import '../../../categories/domain/repositories/category_repository.dart';

// SubCategory imports
import '../../../sub_categories/data/models/sub_category_model.dart';
import '../../../sub_categories/domain/repositories/sub_category_repository.dart';

// Brand imports
import '../../../brands/data/models/brand_model.dart';
import '../../../brands/domain/repositories/brand_repository.dart';
import '../../../brands/presentation/widgets/request_brand_bottom_sheet.dart';

// Product imports
import '../../../products/data/models/product_model.dart';
import '../../../products/domain/repositories/product_repository.dart';
import '../../../products/presentation/screens/product_list_screen.dart';
import '../../../../core/widgets/shimmer_widgets.dart';

// Orders imports
import '../../../orders/presentation/screens/vendor_order_list_screen.dart';

// Settings & Auth imports
import '../../../settings/presentation/widgets/delete_account_dialog.dart';
import '../../../auth/domain/repositories/auth_repository.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  Map<String, dynamic>? _userData;
  bool _userLoading = false;
  bool _dataLoading = true;

  List<ProductModel> _products = [];
  List<CategoryModel> _categories = [];
  List<SubCategoryModel> _subCategories = [];
  List<BrandModel> _brands = [];

  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    _loadUser();
    _loadDashboardData();
  }

  Future<void> _loadUser() async {
    try {
      final data = await sl<SecureStorageService>().getUserData();
      if (mounted) {
        setState(() {
          _userData = data;
          _userLoading = false;
        });
      }
    } catch (_) {
      if (mounted) {
        setState(() {
          _userLoading = false;
        });
      }
    }
  }

  Future<void> _loadDashboardData() async {
    // Only show shimmer skeleton if we have zero cached data
    if (_categories.isEmpty && _products.isEmpty && _brands.isEmpty) {
      setState(() {
        _dataLoading = true;
      });
    }

    try {
      final catFuture = sl<CategoryRepository>().getCategories().then((res) {
        if (mounted) setState(() => _categories = res);
      }).catchError((_) => <CategoryModel>[]);

      final subCatFuture = sl<SubCategoryRepository>().getSubCategories().then((res) {
        if (mounted) setState(() => _subCategories = res);
      }).catchError((_) => <SubCategoryModel>[]);

      final brandFuture = sl<BrandRepository>().getBrands().then((res) {
        if (mounted) setState(() => _brands = res);
      }).catchError((_) => <BrandModel>[]);

      final prodFuture = sl<ProductRepository>().getProducts().then((res) {
        if (mounted) setState(() => _products = res);
      }).catchError((_) => <ProductModel>[]);

      await Future.wait([catFuture, subCatFuture, brandFuture, prodFuture]);
    } catch (_) {
      // ignore
    } finally {
      if (mounted) {
        setState(() {
          _dataLoading = false;
        });
      }
    }
  }

  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Good Morning';
    if (hour < 17) return 'Good Afternoon';
    return 'Good Evening';
  }

  String _formatTime(DateTime dateTime) {
    final diff = DateTime.now().difference(dateTime);
    if (diff.inMinutes < 1) return 'Just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    if (diff.inDays < 7) return '${diff.inDays}d ago';
    return '${dateTime.day}/${dateTime.month}/${dateTime.year}';
  }

  List<_ActivityItem> _getRecentActivities() {
    final List<_ActivityItem> items = [];

    for (final c in _categories) {
      items.add(_ActivityItem(
        title: 'Category ${c.status == 'PENDING' ? 'Submitted' : c.status == 'REJECTED' ? 'Rejected' : 'Approved'}',
        subtitle: c.name,
        time: c.updatedAt,
        icon: c.status == 'PENDING'
            ? Icons.hourglass_empty_rounded
            : c.status == 'REJECTED'
                ? Icons.cancel_outlined
                : Icons.check_circle_outline_rounded,
        iconColor: c.status == 'PENDING'
            ? AppColors.brandOrange
            : c.status == 'REJECTED'
                ? AppColors.brandRed
                : AppColors.primaryGreen,
      ));
    }

    for (final sc in _subCategories) {
      items.add(_ActivityItem(
        title: 'Sub Category ${sc.status == 'PENDING' ? 'Submitted' : sc.status == 'REJECTED' ? 'Rejected' : 'Approved'}',
        subtitle: sc.name,
        time: sc.updatedAt,
        icon: sc.status == 'PENDING'
            ? Icons.hourglass_empty_rounded
            : sc.status == 'REJECTED'
                ? Icons.cancel_outlined
                : Icons.check_circle_outline_rounded,
        iconColor: sc.status == 'PENDING'
            ? AppColors.brandOrange
            : sc.status == 'REJECTED'
                ? AppColors.brandRed
                : AppColors.primaryGreen,
      ));
    }

    for (final b in _brands) {
      items.add(_ActivityItem(
        title: 'Brand ${b.status == 'PENDING' ? 'Submitted' : b.status == 'REJECTED' ? 'Rejected' : 'Approved'}',
        subtitle: b.name,
        time: b.updatedAt,
        icon: b.status == 'PENDING'
            ? Icons.hourglass_empty_rounded
            : b.status == 'REJECTED'
                ? Icons.cancel_outlined
                : Icons.check_circle_outline_rounded,
        iconColor: b.status == 'PENDING'
            ? AppColors.brandOrange
            : b.status == 'REJECTED'
                ? AppColors.brandRed
                : AppColors.primaryGreen,
      ));
    }

    for (final p in _products) {
      items.add(_ActivityItem(
        title: 'Product ${p.status == 'PENDING' ? 'Submitted' : p.status == 'REJECTED' ? 'Rejected' : p.status == 'DRAFT' ? 'Created' : 'Approved'}',
        subtitle: p.name,
        time: p.updatedAt,
        icon: p.status == 'PENDING'
            ? Icons.hourglass_empty_rounded
            : p.status == 'REJECTED'
                ? Icons.cancel_outlined
                : p.status == 'DRAFT'
                    ? Icons.edit_note_rounded
                    : Icons.check_circle_outline_rounded,
        iconColor: p.status == 'PENDING'
            ? AppColors.brandOrange
            : p.status == 'REJECTED'
                ? AppColors.brandRed
                : p.status == 'DRAFT'
                    ? Colors.blue
                    : AppColors.primaryGreen,
      ));
    }

    items.sort((a, b) => b.time.compareTo(a.time));
    return items.take(5).toList();
  }

  Widget _buildQuickAddCard({
    required BuildContext context,
    required String title,
    required IconData icon,
    required Color color,
    required String route,
  }) {
    return InkWell(
      onTap: () {
        context.pop();
        context.push(route);
      },
      borderRadius: BorderRadius.circular(16),
      child: Container(
        width: 96,
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
        decoration: BoxDecoration(
          color: const Color(0xFFF8FAF8),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFFE4ECE8)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Stack(
              alignment: Alignment.center,
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(
                      colors: [color.withOpacity(0.18), color.withOpacity(0.04)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                  ),
                ),
                Container(
                  width: 30,
                  height: 30,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white,
                  ),
                  child: Icon(icon, color: color, size: 16),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Text(
              title,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: Color(0xFF11261B),
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  void _showQuickAddBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Center(
                  child: Container(
                    width: 38,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade300,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: 18),
                const Text(
                  'Quick Add Options',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF11261B),
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _buildQuickAddCard(
                      context: context,
                      title: 'Product',
                      icon: Icons.shopping_bag_outlined,
                      color: Colors.blue,
                      route: '/products/add',
                    ),
                  ],
                ),
                const SizedBox(height: 8),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      // On tab 0 (Dashboard) → exit the app. On tabs 2/3 → go back to tab 0.
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (didPop) return;
        if (_currentIndex != 0) {
          setState(() => _currentIndex = 0);
        } else {
          // Exit the app
          // ignore: deprecated_member_use
          SystemNavigator.pop();
        }
      },
      child: Scaffold(
        backgroundColor: const Color(0xFFF6F8F6),
        appBar: (_currentIndex == 0 || _currentIndex == 1 || _currentIndex == 2)
            ? null
            : _currentIndex == 3
                ? _buildNotificationsAppBar()
                : _currentIndex == 4
                    ? _buildProfileAppBar()
                    : null,
        body: AnimatedSwitcher(
          duration: const Duration(milliseconds: 250),
          child: _getBody(),
        ),
        floatingActionButton: _currentIndex == 0
            ? FloatingActionButton(
                onPressed: () => _showQuickAddBottomSheet(context),
                backgroundColor: const Color(0xFF1A3827),
                foregroundColor: Colors.white,
                elevation: 4,
                child: const Icon(Icons.add, size: 28),
              )
            : null,
        bottomNavigationBar: Container(
          decoration: BoxDecoration(
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.04),
                blurRadius: 16,
                offset: const Offset(0, -2),
              ),
            ],
          ),
          child: BottomNavigationBar(
            currentIndex: _currentIndex,
            onTap: (index) {
              setState(() {
                _currentIndex = index;
              });
              if (index == 0) {
                _loadDashboardData();
              } else if (index == 4) {
                _loadUser();
              }
            },
            type: BottomNavigationBarType.fixed,
            backgroundColor: Colors.white,
            selectedItemColor: const Color(0xFF1A3827),
            unselectedItemColor: const Color(0xFF8B9E94),
            selectedLabelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 11),
            unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.normal, fontSize: 11),
            items: const [
              BottomNavigationBarItem(
                icon: Icon(Icons.dashboard_outlined),
                activeIcon: Icon(Icons.dashboard),
                label: 'Dashboard',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.receipt_long_outlined),
                activeIcon: Icon(Icons.receipt_long),
                label: 'Orders',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.shopping_bag_outlined),
                activeIcon: Icon(Icons.shopping_bag),
                label: 'Products',
              ),
              BottomNavigationBarItem(
                icon: Badge(
                  label: Text('3'),
                  child: Icon(Icons.notifications_outlined),
                ),
                activeIcon: Badge(
                  label: Text('3'),
                  child: Icon(Icons.notifications),
                ),
                label: 'Alerts',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.person_outline),
                activeIcon: Icon(Icons.person),
                label: 'Profile',
              ),
            ],
          ),
        ),
      ),
    );
  }

  PreferredSizeWidget _buildDashboardAppBar() {
    final businessName = _userData?['businessName'] ?? 'Alanga Vendor';
    final initials = businessName.isNotEmpty ? businessName.substring(0, 1).toUpperCase() : 'V';

    return AppBar(
      backgroundColor: Colors.transparent,
      elevation: 0,
      scrolledUnderElevation: 0,
      title: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    Text(
                      _getGreeting(),
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.white.withOpacity(0.75),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.12),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.verified, color: Colors.greenAccent, size: 10),
                          SizedBox(width: 2),
                          Text(
                            'Verified',
                            style: TextStyle(
                              color: Colors.greenAccent,
                              fontSize: 9,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                Text(
                  businessName,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
      actions: [
        IconButton(
          icon: const Badge(
            label: Text('3'),
            child: Icon(Icons.notifications_outlined, color: Colors.white),
          ),
          onPressed: () {
            setState(() {
              _currentIndex = 3;
            });
          },
        ),
        const SizedBox(width: 4),
        GestureDetector(
          onTap: () {
            setState(() {
              _currentIndex = 4;
            });
          },
          child: Container(
            margin: const EdgeInsets.only(right: 16),
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.15),
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white.withOpacity(0.25), width: 1.5),
            ),
            child: Center(
              child: Text(
                initials,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCustomAppBar() {
    final businessName = _userData?['businessName'] ?? 'Alanga Vendor';
    final initials = businessName.isNotEmpty ? businessName.substring(0, 1).toUpperCase() : 'V';
    final profileImage = _userData?['profileImage'] as String?;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    Text(
                      _getGreeting(),
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.white.withOpacity(0.75),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.12),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.verified, color: Colors.greenAccent, size: 10),
                          SizedBox(width: 2),
                          Text(
                            'Verified',
                            style: TextStyle(
                              color: Colors.greenAccent,
                              fontSize: 9,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 2),
                Text(
                  businessName,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          IconButton(
            icon: const Badge(
              label: Text('3'),
              child: Icon(Icons.notifications_outlined, color: Colors.white),
            ),
            onPressed: () {
              setState(() {
                _currentIndex = 3;
              });
            },
          ),
          const SizedBox(width: 4),
          GestureDetector(
            onTap: () {
              setState(() {
                _currentIndex = 4;
              });
              _loadUser();
            },
            child: _buildAvatarWidget(size: 36, imagePath: profileImage, initials: initials),
          ),
        ],
      ),
    );
  }

  Widget _buildAvatarWidget({
    required double size,
    required String? imagePath,
    required String initials,
    Color backgroundColor = const Color(0xFF1A3827),
    double fontSize = 14,
  }) {
    if (imagePath != null && imagePath.trim().isNotEmpty) {
      final trimmed = imagePath.trim();
      if (trimmed.startsWith('http://') || trimmed.startsWith('https://')) {
        return Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: Colors.white.withValues(alpha: 0.35), width: 1.5),
          ),
          child: ClipOval(
            child: Image.network(
              trimmed,
              width: size,
              height: size,
              fit: BoxFit.cover,
              errorBuilder: (_, _, _) => _buildInitialsCircle(size, backgroundColor, initials, fontSize),
            ),
          ),
        );
      }
      final file = File(trimmed);
      if (file.existsSync()) {
        return Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: Colors.white.withValues(alpha: 0.35), width: 1.5),
          ),
          child: ClipOval(
            child: Image.file(
              file,
              width: size,
              height: size,
              fit: BoxFit.cover,
              errorBuilder: (_, _, _) => _buildInitialsCircle(size, backgroundColor, initials, fontSize),
            ),
          ),
        );
      }
    }
    return _buildInitialsCircle(size, backgroundColor, initials, fontSize);
  }

  Widget _buildInitialsCircle(double size, Color backgroundColor, String initials, double fontSize) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: backgroundColor,
        shape: BoxShape.circle,
        border: Border.all(color: Colors.white.withValues(alpha: 0.35), width: 1.5),
      ),
      child: Center(
        child: Text(
          initials,
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: fontSize,
          ),
        ),
      ),
    );
  }

  PreferredSizeWidget _buildNotificationsAppBar() {
    return AppBar(
      backgroundColor: const Color(0xFFF6F8F6),
      elevation: 0,
      scrolledUnderElevation: 0,
      centerTitle: true,
      automaticallyImplyLeading: false,
      leading: Padding(
        padding: const EdgeInsets.only(left: 12),
        child: GestureDetector(
          onTap: () => setState(() => _currentIndex = 0),
          child: Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white,
              border: Border.all(color: const Color(0xFFE4ECE8), width: 1.2),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.04),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: const Icon(
              Icons.arrow_back,
              size: 18,
              color: Color(0xFF1A3827),
            ),
          ),
        ),
      ),
      title: const Text(
        'Business Alerts',
        style: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: Color(0xFF11261B),
        ),
      ),
    );
  }

  PreferredSizeWidget _buildProfileAppBar() {
    return AppBar(
      backgroundColor: const Color(0xFFF6F8F6),
      elevation: 0,
      scrolledUnderElevation: 0,
      centerTitle: true,
      automaticallyImplyLeading: false,
      leading: Padding(
        padding: const EdgeInsets.only(left: 12),
        child: GestureDetector(
          onTap: () => setState(() => _currentIndex = 0),
          child: Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white,
              border: Border.all(color: const Color(0xFFE4ECE8), width: 1.2),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.04),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: const Icon(
              Icons.arrow_back,
              size: 18,
              color: Color(0xFF1A3827),
            ),
          ),
        ),
      ),
      title: const Text(
        'Seller Profile',
        style: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: Color(0xFF11261B),
        ),
      ),
    );
  }

  Widget _getBody() {
    switch (_currentIndex) {
      case 0:
        return RefreshIndicator(
          onRefresh: _loadDashboardData,
          color: const Color(0xFF1A3827),
          child: Stack(
            children: [
              // Forest Green Curved Background Panel covering header and Hero card
              Container(
                height: 205,
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Color(0xFF1A3827), Color(0xFF0C1B12)],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                  borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(32),
                    bottomRight: Radius.circular(32),
                  ),
                ),
              ),
              // Main Dashboard content wrapped in SafeArea
              SafeArea(
                bottom: false,
                child: Column(
                  children: [
                    _buildCustomAppBar(),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0),
                      child: _buildHeroCard(),
                    ),
                    const SizedBox(height: 12),
                    Expanded(
                      child: _buildDashboardContent(),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      case 1:
        return VendorOrderListScreen(
          onBackToDashboard: () {
            setState(() {
              _currentIndex = 0;
            });
          },
        );
      case 2:
        return ProductListScreen(
          onBackToDashboard: () {
            setState(() {
              _currentIndex = 0;
            });
          },
        );
      case 3:
        return _buildNotificationsTab();
      case 4:
        return _buildProfileTab();
      default:
        return _buildDashboardContent();
    }
  }

  Widget _buildHeroCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Welcome Back',
                  style: TextStyle(
                    color: Color(0xFF11261B),
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 6),
                const Text(
                  'Manage your business catalogue and track pending marketplace approvals.',
                  style: TextStyle(
                    color: AppColors.textSecondaryLight,
                    fontSize: 12,
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 16),
                ElevatedButton.icon(
                  onPressed: () => context.push('/products/add'),
                  icon: const Icon(Icons.add, size: 16, color: Colors.white),
                  label: const Text(
                    'Add Product',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF1A3827),
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Container(
            width: 82,
            height: 82,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: const Color(0xFF1A3827).withValues(alpha: 0.18),
                width: 1.5,
              ),
            ),
            child: ClipOval(
              child: Image.asset(
                'assets/images/app_icon.jpg',
                fit: BoxFit.cover,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDashboardContent() {
    if (_dataLoading) {
      return const SingleChildScrollView(
        physics: NeverScrollableScrollPhysics(),
        padding: EdgeInsets.fromLTRB(16, 16, 16, 120),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            DashboardStatsSkeleton(),
            SizedBox(height: 24),
            ShimmerBox(width: 160, height: 18, radius: 8),
            SizedBox(height: 12),
            DashboardListSkeleton(itemCount: 3),
            SizedBox(height: 24),
            ShimmerBox(width: 140, height: 18, radius: 8),
            SizedBox(height: 12),
            DashboardListSkeleton(itemCount: 4),
          ],
        ),
      );
    }

    final pendingCategoriesCount = _categories.where((c) => c.status == 'PENDING').length;
    final pendingSubCategoriesCount = _subCategories.where((sc) => sc.status == 'PENDING').length;
    final pendingBrandsCount = _brands.where((b) => b.status == 'PENDING').length;
    final pendingProductsCount = _products.where((p) => p.status == 'PENDING').length;

    final totalProducts = _products.length;
    final pendingProducts = pendingProductsCount;
    final approvedProducts = _products.where((p) => p.status == 'ACTIVE').length;
    final rejectedProducts = _products.where((p) => p.status == 'REJECTED').length;

    return SingleChildScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [

          // Business Overview Section
          const Text(
            'Business Overview',
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.bold,
              color: Color(0xFF11261B),
            ),
          ),
          const SizedBox(height: 12),
          GridView.count(
            crossAxisCount: 2,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: 2.45,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            children: [
              _buildOverviewCard(
                title: 'Total Products',
                value: '$totalProducts',
                icon: Icons.shopping_bag_outlined,
                color: Colors.blue,
              ),
              _buildOverviewCard(
                title: 'Pending Products',
                value: '$pendingProducts',
                icon: Icons.pending_actions_outlined,
                color: AppColors.brandOrange,
              ),
              _buildOverviewCard(
                title: 'Approved Products',
                value: '$approvedProducts',
                icon: Icons.check_circle_outline_rounded,
                color: AppColors.primaryGreen,
              ),
              _buildOverviewCard(
                title: 'Rejected Products',
                value: '$rejectedProducts',
                icon: Icons.cancel_outlined,
                color: AppColors.brandRed,
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Quick Actions Reels Section
          const Text(
            'Quick Actions',
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.bold,
              color: Color(0xFF11261B),
            ),
          ),
          const SizedBox(height: 14),
          _buildQuickActionsReel(),
          const SizedBox(height: 24),

          // Marketplace Master Data & Taxonomy Showcase
          _buildMasterDataShowcase(),
          const SizedBox(height: 26),

          // Pending Approvals Section
          const Text(
            'Pending Approvals',
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.bold,
              color: Color(0xFF11261B),
            ),
          ),
          const SizedBox(height: 12),
          Column(
            children: [
              _buildPendingApprovalItem(
                title: 'Pending Products',
                count: pendingProductsCount,
                icon: Icons.shopping_bag_outlined,
                route: '/products',
                indicatorColor: Colors.blue,
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Recent Activities Section
          const Text(
            'Recent Activities',
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.bold,
              color: Color(0xFF11261B),
            ),
          ),
          const SizedBox(height: 12),
          _buildRecentActivitiesList(),
          const SizedBox(height: 24),

          // Business Tips Section
          const Text(
            'Business Tips',
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.bold,
              color: Color(0xFF11261B),
            ),
          ),
          const SizedBox(height: 12),
          _buildBusinessTipsList(),
          const SizedBox(height: 36),
        ],
      ),
    );
  }

  Widget _buildOverviewCard({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.04),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Container(
          decoration: BoxDecoration(
            border: Border(
              left: BorderSide(color: color, width: 4),
            ),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Stack(
                    alignment: Alignment.center,
                    children: [
                      Container(
                        width: 32,
                        height: 32,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: LinearGradient(
                            colors: [color.withOpacity(0.18), color.withOpacity(0.04)],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                        ),
                      ),
                      Container(
                        width: 22,
                        height: 22,
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.white,
                        ),
                        child: Icon(icon, color: color, size: 13),
                      ),
                    ],
                  ),
                  Text(
                    value,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: color,
                    ),
                  ),
                ],
              ),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 11,
                  color: AppColors.textSecondaryLight,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildQuickActionsReel() {
    final items = [
      // _ReelItem(
      //   title: 'Add Product',
      //   icon: Icons.add_circle_outline_rounded,
      //   color: AppColors.primaryGreen,
      //   route: '/products/add',
      //   emoji: '➕',
      // ),
      _ReelItem(
        title: 'Orders',
        icon: Icons.receipt_long_rounded,
        color: const Color(0xFF10B981),
        route: '/orders',
        emoji: '📦',
      ),
      _ReelItem(
        title: 'Products',
        icon: Icons.shopping_bag_rounded,
        color: const Color(0xFF4A7BC4),
        route: '/products',
        emoji: '🛍️',
      ),
      _ReelItem(
        title: 'Categories',
        icon: Icons.grid_view_rounded,
        color: Colors.purple,
        route: '',
        emoji: '📁',
        onTap: () => _showCategoriesBottomSheet(context),
      ),
      _ReelItem(
        title: 'Sub Categories',
        icon: Icons.folder_copy_outlined,
        color: Colors.teal,
        route: '',
        emoji: '📂',
        onTap: () => _showSubCategoriesBottomSheet(context),
      ),
      _ReelItem(
        title: 'Brands',
        icon: Icons.label_outline_rounded,
        color: AppColors.brandOrange,
        route: '',
        emoji: '🏷️',
        onTap: () => _showBrandsBottomSheet(context),
      ),
      // _ReelItem(
      //   title: 'Inventory',
      //   icon: Icons.inventory_2_outlined,
      //   color: Colors.indigo,
      //   route: '/inventory',
      //   emoji: '📦',
      // ),
    ];

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        child: Row(
          children: items.map((item) {
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              child: InkWell(
                onTap: () {
                  if (item.onTap != null) {
                    item.onTap!();
                  } else if (item.route.isNotEmpty) {
                    context.push(item.route);
                  }
                },
                borderRadius: BorderRadius.circular(16),
                child: Column(
                  children: [
                    Container(
                      width: 56,
                      height: 56,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: item.color.withValues(alpha: 0.08),
                        border: Border.all(color: item.color.withValues(alpha: 0.25), width: 1.5),
                      ),
                      child: Center(
                        child: Text(
                          item.emoji,
                          style: const TextStyle(fontSize: 24),
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      item.title,
                      style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF11261B),
                      ),
                    ),
                  ],
                ),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildMasterDataShowcase() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: const Color(0xFFE6EFEA)),
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryGreen.withValues(alpha: 0.04),
            blurRadius: 18,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Expanded(
                child: Row(
                  children: [
                    Icon(Icons.storefront_outlined, color: AppColors.primaryGreen, size: 20),
                    SizedBox(width: 8),
                    Flexible(
                      child: Text(
                        'Marketplace Master Data',
                        style: TextStyle(
                          fontSize: 14.5,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF11261B),
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.primaryGreen.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Text(
                  'Admin Managed',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primaryGreen,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: InkWell(
                  onTap: () => _showCategoriesBottomSheet(context),
                  borderRadius: BorderRadius.circular(16),
                  child: Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF7FAF8),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: const Color(0xFFE4ECE8)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Icon(Icons.grid_view_rounded, color: Colors.purple, size: 20),
                            Text(
                              '${_categories.length}',
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.purple,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          'Categories',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF11261B),
                          ),
                        ),
                        const SizedBox(height: 2),
                        const Text(
                          'Tap to explore',
                          style: TextStyle(fontSize: 11, color: AppColors.textSecondaryLight),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: InkWell(
                  onTap: () => _showSubCategoriesBottomSheet(context),
                  borderRadius: BorderRadius.circular(16),
                  child: Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF7FAF8),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: const Color(0xFFE4ECE8)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Icon(Icons.folder_copy_outlined, color: Colors.teal, size: 20),
                            Text(
                              '${_subCategories.length}',
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.teal,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          'Sub Categories',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF11261B),
                          ),
                        ),
                        const SizedBox(height: 2),
                        const Text(
                          'Tap to explore',
                          style: TextStyle(fontSize: 11, color: AppColors.textSecondaryLight),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFFF7FAF8),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFFE4ECE8)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Row(
                        children: [
                          const Icon(Icons.label_outline_rounded, color: AppColors.brandOrange, size: 20),
                          const SizedBox(width: 8),
                          Flexible(
                            child: Text(
                              'Marketplace Brands (${_brands.length})',
                              style: const TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF11261B),
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    InkWell(
                      onTap: () => _showBrandsBottomSheet(context),
                      child: const Text(
                        'View All',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: AppColors.primaryGreen,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                if (_brands.isEmpty)
                  const Text(
                    'No Brands Loaded',
                    style: TextStyle(fontSize: 12, color: AppColors.textSecondaryLight),
                  )
                else
                  SizedBox(
                    height: 38,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      itemCount: _brands.length,
                      separatorBuilder: (_, __) => const SizedBox(width: 8),
                      itemBuilder: (ctx, index) {
                        final brand = _brands[index];
                        return Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: const Color(0xFFD1DCD6)),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              if (brand.image != null && brand.image!.isNotEmpty)
                                Padding(
                                  padding: const EdgeInsets.only(right: 6),
                                  child: Image.network(
                                    brand.image!,
                                    width: 16,
                                    height: 16,
                                    errorBuilder: (ctx, err, stack) => const Icon(Icons.label, size: 14, color: AppColors.brandOrange),
                                  ),
                                )
                              else
                                const Icon(Icons.label_outline, size: 14, color: AppColors.brandOrange),
                              const SizedBox(width: 4),
                              Text(
                                brand.name,
                                style: const TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: Color(0xFF11261B),
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
                const SizedBox(height: 14),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: () {
                      RequestBrandBottomSheet.show(context, onRequestSubmitted: () {
                        _loadDashboardData();
                      });
                    },
                    icon: const Icon(Icons.add_circle_outline_rounded, size: 18),
                    label: const Text('Request New Brand'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.primaryGreen,
                      side: const BorderSide(color: AppColors.primaryGreen, width: 1.2),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      padding: const EdgeInsets.symmetric(vertical: 12),
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

  void _showCategoriesBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        final searchCtrl = TextEditingController();

        return StatefulBuilder(
          builder: (ctx, setModalState) {
            final query = searchCtrl.text.trim().toLowerCase();
            final filteredCategories = _categories.where((cat) {
              final matchesCat = cat.name.toLowerCase().contains(query);
              final matchesSubCat = _subCategories
                  .where((sc) => sc.categoryId == cat.id)
                  .any((sc) => sc.name.toLowerCase().contains(query));
              return matchesCat || matchesSubCat;
            }).toList();

            return Container(
              constraints: BoxConstraints(
                maxHeight: MediaQuery.of(context).size.height * 0.8,
              ),
              padding: EdgeInsets.only(
                left: 20,
                right: 20,
                top: 16,
                bottom: MediaQuery.of(ctx).viewInsets.bottom + 16,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      width: 38,
                      height: 4,
                      decoration: BoxDecoration(
                        color: Colors.grey.shade300,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Row(
                          children: [
                            const Icon(Icons.grid_view_rounded, color: Colors.purple),
                            const SizedBox(width: 8),
                            Flexible(
                              child: Text(
                                'Marketplace Categories (${_categories.length})',
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF11261B),
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        onPressed: () => Navigator.pop(ctx),
                        icon: const Icon(Icons.close, color: Colors.grey),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'Master categories managed by Admin for marketplace product placement.',
                    style: TextStyle(fontSize: 12, color: AppColors.textSecondaryLight),
                  ),
                  const SizedBox(height: 14),

                  // Search Bar
                  Container(
                    decoration: BoxDecoration(
                      color: const Color(0xFFF3F6F4),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: const Color(0xFFDDE8E1)),
                    ),
                    child: TextField(
                      controller: searchCtrl,
                      onChanged: (_) => setModalState(() {}),
                      style: const TextStyle(fontSize: 13.5, color: Color(0xFF11261B)),
                      decoration: InputDecoration(
                        hintText: 'Search categories or sub-categories...',
                        hintStyle: const TextStyle(fontSize: 13, color: Color(0xFF7A9A86)),
                        prefixIcon: const Icon(Icons.search_rounded, size: 18, color: Color(0xFF7A9A86)),
                        suffixIcon: searchCtrl.text.isNotEmpty
                            ? GestureDetector(
                                onTap: () {
                                  searchCtrl.clear();
                                  setModalState(() {});
                                },
                                child: const Icon(Icons.close_rounded, size: 18, color: Color(0xFF7A9A86)),
                              )
                            : null,
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
                      ),
                    ),
                  ),
                  const SizedBox(height: 14),

                  Expanded(
                    child: filteredCategories.isEmpty
                        ? const Center(
                            child: Text(
                              'No matching categories found',
                              style: TextStyle(color: Colors.grey, fontSize: 13),
                            ),
                          )
                        : ListView.separated(
                            itemCount: filteredCategories.length,
                            separatorBuilder: (_, __) => const Divider(height: 1, color: Color(0xFFEFEFEF)),
                            itemBuilder: (ctx, index) {
                              final cat = filteredCategories[index];
                              final subCatsForCat = _subCategories.where((sc) => sc.categoryId == cat.id).toList();

                              return ExpansionTile(
                                leading: Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: Colors.purple.withValues(alpha: 0.1),
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: const Icon(Icons.category_outlined, color: Colors.purple, size: 20),
                                ),
                                title: Text(
                                  cat.name,
                                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Color(0xFF11261B)),
                                ),
                                subtitle: Text(
                                  '${subCatsForCat.length} Sub Categories',
                                  style: const TextStyle(fontSize: 12, color: AppColors.textSecondaryLight),
                                ),
                                children: subCatsForCat.isEmpty
                                    ? [
                                        const Padding(
                                          padding: EdgeInsets.all(12.0),
                                          child: Text('No Sub Categories under this category.', style: TextStyle(fontSize: 12, color: Colors.grey)),
                                        )
                                      ]
                                    : subCatsForCat.map((sc) {
                                        return ListTile(
                                          contentPadding: const EdgeInsets.only(left: 48, right: 16),
                                          dense: true,
                                          leading: const Icon(Icons.subdirectory_arrow_right_rounded, size: 16, color: Colors.teal),
                                          title: Text(sc.name, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500)),
                                        );
                                      }).toList(),
                              );
                            },
                          ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  void _showSubCategoriesBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        final searchCtrl = TextEditingController();

        return StatefulBuilder(
          builder: (ctx, setModalState) {
            final query = searchCtrl.text.trim().toLowerCase();
            final filteredSubCategories = _subCategories.where((sc) {
              final matchesSubCat = sc.name.toLowerCase().contains(query);
              final parentCat = _categories.firstWhere(
                (c) => c.id == sc.categoryId,
                orElse: () => CategoryModel(id: '', name: '', status: 'APPROVED', createdAt: DateTime.now(), updatedAt: DateTime.now()),
              );
              final matchesParentCat = parentCat.name.toLowerCase().contains(query);
              return matchesSubCat || matchesParentCat;
            }).toList();

            return Container(
              constraints: BoxConstraints(
                maxHeight: MediaQuery.of(context).size.height * 0.8,
              ),
              padding: EdgeInsets.only(
                left: 20,
                right: 20,
                top: 16,
                bottom: MediaQuery.of(ctx).viewInsets.bottom + 16,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      width: 38,
                      height: 4,
                      decoration: BoxDecoration(
                        color: Colors.grey.shade300,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Row(
                          children: [
                            const Icon(Icons.folder_copy_outlined, color: Colors.teal),
                            const SizedBox(width: 8),
                            Flexible(
                              child: Text(
                                'Sub Categories (${_subCategories.length})',
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF11261B),
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        onPressed: () => Navigator.pop(ctx),
                        icon: const Icon(Icons.close, color: Colors.grey),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'Active Sub Categories available for product assignment.',
                    style: TextStyle(fontSize: 12, color: AppColors.textSecondaryLight),
                  ),
                  const SizedBox(height: 14),

                  // Search Bar
                  Container(
                    decoration: BoxDecoration(
                      color: const Color(0xFFF3F6F4),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: const Color(0xFFDDE8E1)),
                    ),
                    child: TextField(
                      controller: searchCtrl,
                      onChanged: (_) => setModalState(() {}),
                      style: const TextStyle(fontSize: 13.5, color: Color(0xFF11261B)),
                      decoration: InputDecoration(
                        hintText: 'Search sub-categories...',
                        hintStyle: const TextStyle(fontSize: 13, color: Color(0xFF7A9A86)),
                        prefixIcon: const Icon(Icons.search_rounded, size: 18, color: Color(0xFF7A9A86)),
                        suffixIcon: searchCtrl.text.isNotEmpty
                            ? GestureDetector(
                                onTap: () {
                                  searchCtrl.clear();
                                  setModalState(() {});
                                },
                                child: const Icon(Icons.close_rounded, size: 18, color: Color(0xFF7A9A86)),
                              )
                            : null,
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
                      ),
                    ),
                  ),
                  const SizedBox(height: 14),

                  Expanded(
                    child: filteredSubCategories.isEmpty
                        ? const Center(
                            child: Text(
                              'No matching sub-categories found',
                              style: TextStyle(color: Colors.grey, fontSize: 13),
                            ),
                          )
                        : ListView.separated(
                            itemCount: filteredSubCategories.length,
                            separatorBuilder: (_, __) => const Divider(height: 1, color: Color(0xFFEFEFEF)),
                            itemBuilder: (ctx, index) {
                              final sc = filteredSubCategories[index];
                              final parentCat = _categories.firstWhere(
                                (c) => c.id == sc.categoryId,
                                orElse: () => CategoryModel(id: '', name: 'Master Category', status: 'APPROVED', createdAt: DateTime.now(), updatedAt: DateTime.now()),
                              );

                              return ListTile(
                                leading: Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: Colors.teal.withValues(alpha: 0.1),
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: const Icon(Icons.folder_outlined, color: Colors.teal, size: 20),
                                ),
                                title: Text(
                                  sc.name,
                                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Color(0xFF11261B)),
                                ),
                                subtitle: Text(
                                  'Parent Category: ${parentCat.name}',
                                  style: const TextStyle(fontSize: 12, color: AppColors.textSecondaryLight),
                                ),
                              );
                            },
                          ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  void _showBrandsBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        final searchCtrl = TextEditingController();

        return StatefulBuilder(
          builder: (ctx, setModalState) {
            final query = searchCtrl.text.trim().toLowerCase();
            final filteredBrands = _brands.where((b) {
              final matchesName = b.name.toLowerCase().contains(query);
              final matchesDesc = b.description?.toLowerCase().contains(query) ?? false;
              return matchesName || matchesDesc;
            }).toList();

            return Container(
              constraints: BoxConstraints(
                maxHeight: MediaQuery.of(context).size.height * 0.85,
              ),
              padding: EdgeInsets.only(
                left: 20,
                right: 20,
                top: 16,
                bottom: MediaQuery.of(ctx).viewInsets.bottom + 16,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      width: 38,
                      height: 4,
                      decoration: BoxDecoration(
                        color: Colors.grey.shade300,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Row(
                          children: [
                            const Icon(Icons.label_outline_rounded, color: AppColors.brandOrange),
                            const SizedBox(width: 8),
                            Flexible(
                              child: Text(
                                'Marketplace Brands (${_brands.length})',
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF11261B),
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        onPressed: () => Navigator.pop(ctx),
                        icon: const Icon(Icons.close, color: Colors.grey),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'Active marketplace brands. If your brand is not listed, submit a request below.',
                    style: TextStyle(fontSize: 12, color: AppColors.textSecondaryLight),
                  ),
                  const SizedBox(height: 14),

                  // Search Bar
                  Container(
                    decoration: BoxDecoration(
                      color: const Color(0xFFF3F6F4),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: const Color(0xFFDDE8E1)),
                    ),
                    child: TextField(
                      controller: searchCtrl,
                      onChanged: (_) => setModalState(() {}),
                      style: const TextStyle(fontSize: 13.5, color: Color(0xFF11261B)),
                      decoration: InputDecoration(
                        hintText: 'Search marketplace brands...',
                        hintStyle: const TextStyle(fontSize: 13, color: Color(0xFF7A9A86)),
                        prefixIcon: const Icon(Icons.search_rounded, size: 18, color: Color(0xFF7A9A86)),
                        suffixIcon: searchCtrl.text.isNotEmpty
                            ? GestureDetector(
                                onTap: () {
                                  searchCtrl.clear();
                                  setModalState(() {});
                                },
                                child: const Icon(Icons.close_rounded, size: 18, color: Color(0xFF7A9A86)),
                              )
                            : null,
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
                      ),
                    ),
                  ),
                  const SizedBox(height: 14),

                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      onPressed: () {
                        Navigator.pop(ctx);
                        RequestBrandBottomSheet.show(context, onRequestSubmitted: () {
                          _loadDashboardData();
                        });
                      },
                      icon: const Icon(Icons.add_circle_outline_rounded, size: 18),
                      label: const Text('Request New Brand'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.primaryGreen,
                        side: const BorderSide(color: AppColors.primaryGreen, width: 1.2),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                    ),
                  ),
                  const SizedBox(height: 14),
                  Expanded(
                    child: filteredBrands.isEmpty
                        ? const Center(
                            child: Text(
                              'No matching brands found',
                              style: TextStyle(color: Colors.grey, fontSize: 13),
                            ),
                          )
                        : ListView.separated(
                            itemCount: filteredBrands.length,
                            separatorBuilder: (_, __) => const Divider(height: 1, color: Color(0xFFEFEFEF)),
                            itemBuilder: (ctx, index) {
                              final brand = filteredBrands[index];
                              return ListTile(
                                leading: brand.image != null && brand.image!.isNotEmpty
                                    ? ClipRRect(
                                        borderRadius: BorderRadius.circular(8),
                                        child: Image.network(
                                          brand.image!,
                                          width: 36,
                                          height: 36,
                                          fit: BoxFit.cover,
                                          errorBuilder: (ctx, err, stack) => Container(
                                            width: 36,
                                            height: 36,
                                            color: AppColors.brandOrange.withValues(alpha: 0.1),
                                            child: const Icon(Icons.label, color: AppColors.brandOrange, size: 20),
                                          ),
                                        ),
                                      )
                                    : Container(
                                        width: 36,
                                        height: 36,
                                        decoration: BoxDecoration(
                                          color: AppColors.brandOrange.withValues(alpha: 0.1),
                                          borderRadius: BorderRadius.circular(8),
                                        ),
                                        child: const Icon(Icons.label_outline, color: AppColors.brandOrange, size: 20),
                                      ),
                                title: Text(
                                  brand.name,
                                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Color(0xFF11261B)),
                                ),
                                subtitle: brand.description != null && brand.description!.isNotEmpty
                                    ? Text(
                                        brand.description!,
                                        style: const TextStyle(fontSize: 12, color: AppColors.textSecondaryLight),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      )
                                    : null,
                              );
                            },
                          ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildPendingApprovalItem({
    required String title,
    required int count,
    required IconData icon,
    required String route,
    required Color indicatorColor,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Container(
          decoration: BoxDecoration(
            border: Border(
              left: BorderSide(color: indicatorColor, width: 3.5),
            ),
          ),
          child: ListTile(
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            onTap: () => context.push(route),
            leading: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: const Color(0xFFFFF9F2),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, color: AppColors.brandOrange, size: 20),
            ),
            title: Text(
              title,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: Color(0xFF11261B),
              ),
            ),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: count > 0 ? const Color(0xFFFEEFDD) : const Color(0xFFF1F5F2),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    '$count pending',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: count > 0 ? AppColors.brandOrange : AppColors.textSecondaryLight,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                const Icon(Icons.arrow_forward_ios, size: 12, color: Color(0xFFD1DDD6)),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildRecentActivitiesList() {
    final list = _getRecentActivities();

    if (list.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.02),
              blurRadius: 16,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: const Center(
          child: Text(
            'No recent activities recorded.',
            style: TextStyle(color: AppColors.textSecondaryLight, fontSize: 13),
          ),
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: ListView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: list.length,
        itemBuilder: (context, index) {
          final item = list[index];
          final isLast = index == list.length - 1;

          return IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: item.iconColor.withOpacity(0.08),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(item.icon, color: item.iconColor, size: 14),
                    ),
                    if (!isLast)
                      Expanded(
                        child: Container(
                          width: 2,
                          color: const Color(0xFFE4ECE8),
                        ),
                      ),
                  ],
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(bottom: 16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              item.title,
                              style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF11261B),
                              ),
                            ),
                            Text(
                              _formatTime(item.time),
                              style: const TextStyle(
                                fontSize: 10,
                                color: AppColors.textSecondaryDark,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 2),
                        Text(
                          item.subtitle,
                          style: const TextStyle(
                            fontSize: 11,
                            color: AppColors.textSecondaryLight,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildBusinessTipsList() {
    final tips = [
      _TipItem(
        title: 'Complete your profile',
        description: 'Provide verified tax and bank information to accelerate store approval times.',
        icon: Icons.assignment_ind_outlined,
        color: AppColors.primaryGreen,
      ),
      _TipItem(
        title: 'Add high-quality photos',
        description: 'Uploading multiple detailed images increases seller sales conversion rates.',
        icon: Icons.photo_library_outlined,
        color: AppColors.brandOrange,
      ),
      _TipItem(
        title: 'Detailed specifications',
        description: 'Write transparent descriptions to minimize customer return requests.',
        icon: Icons.description_outlined,
        color: Colors.blue,
      ),
    ];

    return SizedBox(
      height: 120,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: tips.length,
        itemBuilder: (context, index) {
          final tip = tips[index];
          return Container(
            width: 250,
            margin: const EdgeInsets.only(right: 12),
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.02),
                  blurRadius: 16,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: tip.color.withOpacity(0.08),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(tip.icon, color: tip.color, size: 20),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        tip.title,
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF11261B),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Expanded(
                        child: Text(
                          tip.description,
                          style: const TextStyle(
                            fontSize: 10,
                            color: AppColors.textSecondaryLight,
                            height: 1.3,
                          ),
                          maxLines: 4,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildNotificationsTab() {
    final alertItems = [
      _AlertItem(
        title: 'Category Approval Successful',
        message: 'Your category submission "Fashion Wear" has been reviewed and approved by administrator.',
        time: DateTime.now().subtract(const Duration(hours: 1)),
        icon: Icons.check_circle_outline,
        color: AppColors.primaryGreen,
      ),
      _AlertItem(
        title: 'New Brand Request Reviewing',
        message: 'Your registration request for brand "Alanga Apparel" is under priority verification.',
        time: DateTime.now().subtract(const Duration(hours: 4)),
        icon: Icons.hourglass_top,
        color: AppColors.brandOrange,
      ),
      _AlertItem(
        title: 'Seller Panel Welcome',
        message: 'Welcome to Alanga Seller Central Panel! Let\'s catalog products to drive shop orders.',
        time: DateTime.now().subtract(const Duration(days: 1)),
        icon: Icons.verified_user_outlined,
        color: Colors.blue,
      ),
    ];

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: alertItems.length,
      itemBuilder: (context, index) {
        final alert = alertItems[index];
        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.02),
                blurRadius: 16,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: alert.color.withOpacity(0.08),
                  shape: BoxShape.circle,
                ),
                child: Icon(alert.icon, color: alert.color, size: 20),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            alert.title,
                            style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF11261B),
                            ),
                          ),
                        ),
                        Text(
                          _formatTime(alert.time),
                          style: const TextStyle(fontSize: 10, color: AppColors.textSecondaryDark),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(
                      alert.message,
                      style: const TextStyle(
                        fontSize: 11,
                        color: AppColors.textSecondaryLight,
                        height: 1.4,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildProfileTab() {
    final businessName = _userData?['businessName'] ?? 'Alanga Store';
    final fullName = _userData?['fullName'] ?? 'Vendor User';
    final email = _userData?['email'] ?? 'vendor@alanga.com';
    final mobileNumber = _userData?['mobileNumber'] ?? '';
    final countryCode = _userData?['countryCode'] ?? '+91';
    final formattedMobile = mobileNumber.isNotEmpty ? '$countryCode $mobileNumber' : 'Not Provided';
    final initials = businessName.isNotEmpty ? businessName.substring(0, 1).toUpperCase() : 'V';
    final profileImage = _userData?['profileImage'] as String?;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Profile Card Banner
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.02),
                  blurRadius: 16,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Row(
              children: [
                _buildAvatarWidget(
                  size: 60,
                  imagePath: profileImage,
                  initials: initials,
                  fontSize: 22,
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              businessName,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF11261B),
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          const SizedBox(width: 4),
                          const Icon(Icons.verified, color: AppColors.primaryGreen, size: 16),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Owner: $fullName',
                        style: const TextStyle(
                          fontSize: 12,
                          color: AppColors.textSecondaryLight,
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  onPressed: () async {
                    await context.push('/profile/edit');
                    await _loadUser();
                    if (mounted) setState(() {});
                  },
                  icon: const Icon(Icons.edit_outlined, color: Color(0xFF1A3827), size: 20),
                  tooltip: 'Edit Profile',
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Business Details
          const Text(
            'Business Profile Details',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: Color(0xFF11261B),
            ),
          ),
          const SizedBox(height: 12),
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.02),
                  blurRadius: 16,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Column(
              children: [
                _buildProfileDetailRow(Icons.email_outlined, 'Registered Email', email),
                const Divider(height: 1, color: Color(0xFFF1F5F2)),
                _buildProfileDetailRow(Icons.phone_outlined, 'Contact Mobile', formattedMobile),
                const Divider(height: 1, color: Color(0xFFF1F5F2)),
                _buildProfileDetailRow(Icons.badge_outlined, 'Seller Status', 'Verified Marketplace Partner'),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Action Items
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.02),
                  blurRadius: 16,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Column(
              children: [
                ListTile(
                  leading: const Icon(Icons.settings_outlined, color: Color(0xFF4C6656)),
                  title: const Text('Store Settings', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
                  trailing: const Icon(Icons.arrow_forward_ios, size: 12, color: Color(0xFFD1DDD6)),
                  onTap: () async {
                    await context.push('/settings');
                    _loadUser();
                  },
                ),
                const Divider(height: 1, color: Color(0xFFF1F5F2)),
                ListTile(
                  leading: const Icon(Icons.headset_mic_outlined, color: Color(0xFF4C6656)),
                  title: const Text('Alanga Seller Support', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
                  trailing: const Icon(Icons.arrow_forward_ios, size: 12, color: Color(0xFFD1DDD6)),
                  onTap: () => context.push('/settings/support'),
                ),
                const Divider(height: 1, color: Color(0xFFF1F5F2)),
                ListTile(
                  leading: const Icon(Icons.privacy_tip_outlined, color: Color(0xFF4C6656)),
                  title: const Text('Privacy Policy & Legal', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
                  trailing: const Icon(Icons.arrow_forward_ios, size: 12, color: Color(0xFFD1DDD6)),
                  onTap: () => context.push('/settings/privacy-policy'),
                ),
                const Divider(height: 1, color: Color(0xFFF1F5F2)),
                ListTile(
                  leading: const Icon(Icons.delete_outline, color: AppColors.brandRed),
                  title: const Text('Delete Account', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.brandRed)),
                  trailing: const Icon(Icons.arrow_forward_ios, size: 12, color: Color(0xFFD1DDD6)),
                  onTap: () => DeleteAccountDialog.show(context),
                ),
              ],
            ),
          ),
          const SizedBox(height: 36),

          // Logout Action
          ElevatedButton.icon(
            onPressed: () => _showDashboardLogoutDialog(),
            icon: const Icon(Icons.logout_outlined, size: 16),
            label: const Text(
              'LOGOUT FROM CENTRAL',
              style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 0.5),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.brandRed,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: 0,
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _performDashboardLogout() async {
    showDialog<void>(
      context: context,
      barrierDismissible: false,
      barrierColor: Colors.black.withValues(alpha: 0.35),
      builder: (_) => PopScope(
        canPop: false,
        child: Center(
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 40),
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.12),
                  blurRadius: 20,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(
                  width: 22,
                  height: 22,
                  child: CircularProgressIndicator(
                    strokeWidth: 2.5,
                    valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF1A3827)),
                  ),
                ),
                SizedBox(width: 16),
                Text(
                  'Logging out...',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF11261B),
                    decoration: TextDecoration.none,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );

    try {
      await sl<AuthRepository>().logout().timeout(
        const Duration(seconds: 3),
        onTimeout: () async {
          await sl<SecureStorageService>().clearAll();
        },
      );
    } catch (_) {
      try {
        await sl<SecureStorageService>().clearAll();
      } catch (_) {}
    }

    if (mounted) {
      context.go('/login');
    }
  }

  void _showDashboardLogoutDialog() {
    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
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
          style: TextStyle(fontSize: 14, color: Color(0xFF4C6656)),
        ),
        actionsPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text(
              'Cancel',
              style: TextStyle(color: Color(0xFF4C6656), fontWeight: FontWeight.w600),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(ctx).pop();
              _performDashboardLogout();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.brandRed,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              elevation: 0,
            ),
            child: const Text('Logout', style: TextStyle(fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileDetailRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: const Color(0xFF4C6656), size: 20),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    fontSize: 11,
                    color: AppColors.textSecondaryLight,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF11261B),
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

class _ActivityItem {
  final String title;
  final String subtitle;
  final DateTime time;
  final IconData icon;
  final Color iconColor;

  _ActivityItem({
    required this.title,
    required this.subtitle,
    required this.time,
    required this.icon,
    required this.iconColor,
  });
}

class _TipItem {
  final String title;
  final String description;
  final IconData icon;
  final Color color;

  _TipItem({
    required this.title,
    required this.description,
    required this.icon,
    required this.color,
  });
}

class _AlertItem {
  final String title;
  final String message;
  final DateTime time;
  final IconData icon;
  final Color color;

  _AlertItem({
    required this.title,
    required this.message,
    required this.time,
    required this.icon,
    required this.color,
  });
}

class _ReelItem {
  final String title;
  final IconData icon;
  final Color color;
  final String route;
  final String emoji;
  final VoidCallback? onTap;

  _ReelItem({
    required this.title,
    required this.icon,
    required this.color,
    required this.route,
    required this.emoji,
    this.onTap,
  });
}
