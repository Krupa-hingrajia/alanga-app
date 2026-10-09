import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/dependency_injection/injection.dart';
import '../../../../core/storage/secure_storage_service.dart';
import '../../../../core/localization/app_localizations.dart';

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

// Modular Dashboard Widgets
import '../widgets/dashboard_quick_add_modal.dart';
import '../widgets/dashboard_master_data_sheets.dart';
import '../widgets/dashboard_alerts_tab.dart';
import '../widgets/dashboard_profile_tab.dart';
import '../../../profile/presentation/widgets/first_time_store_setup_sheet.dart';

// Product imports
import '../../../products/data/models/product_model.dart';
import '../../../products/domain/repositories/product_repository.dart';
import '../../../products/presentation/screens/product_list_screen.dart';
import '../../../../core/widgets/shimmer_widgets.dart';

// Orders imports
import '../../../orders/presentation/screens/vendor_order_list_screen.dart';

// Dashboard Summary imports
import '../../domain/repositories/vendor_dashboard_repository.dart';
import '../../data/models/vendor_dashboard_summary_model.dart';

// Settings & Auth imports
import '../../../auth/domain/repositories/auth_repository.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  Map<String, dynamic>? _userData;
  bool _dataLoading = true;
  bool _hasPromptedProfileSetup = false;

  List<ProductModel> _products = [];
  List<CategoryModel> _categories = [];
  List<SubCategoryModel> _subCategories = [];
  List<BrandModel> _brands = [];
  VendorDashboardSummaryModel? _summary;

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
        });

        final rawEmail = data?['email'] as String? ?? '';
        final isPlaceholder = rawEmail.contains('@alanga.com') && rawEmail.startsWith('vendor_');
        if (isPlaceholder && !_hasPromptedProfileSetup) {
          _hasPromptedProfileSetup = true;
          WidgetsBinding.instance.addPostFrameCallback((_) {
            FirstTimeStoreSetupSheet.show(
              context,
              initialFullName: data?['fullName'] as String?,
              initialBusinessName: data?['businessName'] as String?,
              initialEmail: null,
              onUpdated: () async {
                await _loadUser();
                await _loadDashboardData();
              },
            );
          });
        }
      }
    } catch (_) {
      // ignore
    }
  }

  Future<void> _loadDashboardData() async {
    // Only show shimmer skeleton if we have zero cached data
    if (_categories.isEmpty && _products.isEmpty && _brands.isEmpty && _summary == null) {
      setState(() {
        _dataLoading = true;
      });
    }

    try {
      final catFuture = sl<CategoryRepository>().getCategories().then((res) {
        if (mounted) setState(() => _categories = res);
      }).catchError((_) => null);

      final subCatFuture = sl<SubCategoryRepository>().getSubCategories().then((res) {
        if (mounted) setState(() => _subCategories = res);
      }).catchError((_) => null);

      final brandFuture = sl<BrandRepository>().getBrands().then((res) {
        if (mounted) setState(() => _brands = res);
      }).catchError((_) => null);

      final prodFuture = sl<ProductRepository>().getProducts().then((res) {
        if (mounted) setState(() => _products = res);
      }).catchError((_) => null);

      final summaryFuture = sl<VendorDashboardRepository>().getSummary().then((res) {
        if (mounted) setState(() => _summary = res);
      }).catchError((_) => null);

      await Future.wait([catFuture, subCatFuture, brandFuture, prodFuture, summaryFuture]);
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

  String _getGreeting(BuildContext context) {
    final hour = DateTime.now().hour;
    if (hour < 12) return context.tr('good_morning');
    if (hour < 17) return context.tr('good_afternoon');
    return context.tr('good_evening');
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

  void _showQuickAddBottomSheet(BuildContext context) {
    DashboardQuickAddModal.show(context);
  }

  @override
  Widget build(BuildContext context) {
    final isDarkHeaderTab = _currentIndex == 0;
    final overlayStyle = isDarkHeaderTab
        ? const SystemUiOverlayStyle(
            statusBarColor: Colors.transparent,
            statusBarIconBrightness: Brightness.light,
            statusBarBrightness: Brightness.dark,
          )
        : const SystemUiOverlayStyle(
            statusBarColor: Colors.transparent,
            statusBarIconBrightness: Brightness.dark,
            statusBarBrightness: Brightness.light,
          );

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: overlayStyle,
      child: PopScope(
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
            items: [
              BottomNavigationBarItem(
                icon: const Icon(Icons.dashboard_outlined),
                activeIcon: const Icon(Icons.dashboard),
                label: context.tr('dashboard'),
              ),
              BottomNavigationBarItem(
                icon: const Icon(Icons.receipt_long_outlined),
                activeIcon: const Icon(Icons.receipt_long),
                label: context.tr('orders'),
              ),
              BottomNavigationBarItem(
                icon: const Icon(Icons.shopping_bag_outlined),
                activeIcon: const Icon(Icons.shopping_bag),
                label: context.tr('products'),
              ),
              BottomNavigationBarItem(
                icon: const Badge(
                  label: Text('3'),
                  child: Icon(Icons.notifications_outlined),
                ),
                activeIcon: const Badge(
                  label: Text('3'),
                  child: Icon(Icons.notifications),
                ),
                label: context.tr('alerts'),
              ),
              BottomNavigationBarItem(
                icon: const Icon(Icons.person_outline),
                activeIcon: const Icon(Icons.person),
                label: context.tr('profile'),
              ),
            ],
          ),
        ),
      ),
    ),
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
                      _getGreeting(context),
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
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.verified, color: Colors.greenAccent, size: 10),
                          const SizedBox(width: 2),
                          Text(
                            context.tr('verified'),
                            style: const TextStyle(
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
      title: Text(
        context.tr('business_alerts'),
        style: const TextStyle(
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
      title: Text(
        context.tr('seller_profile'),
        style: const TextStyle(
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
                    const SizedBox(height: 4),
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
                Text(
                  context.tr('welcome_back'),
                  style: const TextStyle(
                    color: Color(0xFF11261B),
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  context.tr('hero_description'),
                  style: const TextStyle(
                    color: AppColors.textSecondaryLight,
                    fontSize: 12,
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 16),
                ElevatedButton.icon(
                  onPressed: () async {
                    final user = (context.read<AuthBloc>().state is AuthenticatedState)
                        ? (context.read<AuthBloc>().state as AuthenticatedState).user
                        : null;
                    final canProceed = await FirstTimeStoreSetupSheet.guardProductCreation(
                      context,
                      user: user,
                      onProfileUpdated: () {
                        context.read<AuthBloc>().add(const CheckAuthStatusEvent());
                      },
                    );
                    if (canProceed && context.mounted) {
                      context.push('/products/add');
                    }
                  },
                  icon: const Icon(Icons.add, size: 16, color: Colors.white),
                  label: Text(
                    context.tr('add_new_product'),
                    style: const TextStyle(
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
    final outOfStockCount = _products.where((p) => (p.stock ?? 0) <= 0).length;
    final lowStockCount = _products.where((p) => (p.stock ?? 0) > 0 && (p.stock ?? 0) <= 5).length;

    return SingleChildScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(16.0, 2.0, 16.0, 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // 0. First-Time Store Profile Setup Action Banner
          _buildStoreSetupActionBanner(),

          // 1. KYC Verification Action Banner
          _buildKycBannerSection(),
          const SizedBox(height: 12),

          if (outOfStockCount > 0 || lowStockCount > 0) ...[
            _buildLowStockAlertBanner(outOfStockCount, lowStockCount),
            const SizedBox(height: 12),
          ],

          // 2. Real-time Orders & Sales Performance Section
          _buildSalesPerformanceSection(),
          const SizedBox(height: 16),

          // Business Overview Section
          Text(
            context.tr('business_overview'),
            style: const TextStyle(
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
                title: context.tr('total_products'),
                value: '$totalProducts',
                icon: Icons.shopping_bag_outlined,
                color: Colors.blue,
                onTap: () => context.push('/products', extra: {'initialStatus': 'ACTIVE'}),
              ),
              _buildOverviewCard(
                title: context.tr('pending_products'),
                value: '$pendingProducts',
                icon: Icons.pending_actions_outlined,
                color: AppColors.brandOrange,
                onTap: () => context.push('/products', extra: {'initialStatus': 'PENDING'}),
              ),
              _buildOverviewCard(
                title: context.tr('approved_products'),
                value: '$approvedProducts',
                icon: Icons.check_circle_outline_rounded,
                color: AppColors.primaryGreen,
                onTap: () => context.push('/products', extra: {'initialStatus': 'ACTIVE'}),
              ),
              _buildOverviewCard(
                title: context.tr('rejected_products'),
                value: '$rejectedProducts',
                icon: Icons.cancel_outlined,
                color: AppColors.brandRed,
                onTap: () => context.push('/products', extra: {'initialStatus': 'REJECTED'}),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Quick Actions Reels Section
          Text(
            context.tr('quick_actions'),
            style: const TextStyle(
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
          Text(
            context.tr('pending_approvals'),
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.bold,
              color: Color(0xFF11261B),
            ),
          ),
          const SizedBox(height: 12),
          Column(
            children: [
              _buildPendingApprovalItem(
                title: context.tr('pending_products'),
                count: pendingProductsCount,
                icon: Icons.shopping_bag_outlined,
                route: '/products',
                extra: const {'initialStatus': 'PENDING'},
                indicatorColor: Colors.blue,
              ),
              const SizedBox(height: 10),
              _buildPendingApprovalItem(
                title: context.tr('pending_categories'),
                count: pendingCategoriesCount,
                icon: Icons.category_outlined,
                route: '/categories',
                extra: const {'initialStatus': 'PENDING'},
                indicatorColor: Colors.orange,
              ),
              const SizedBox(height: 10),
              _buildPendingApprovalItem(
                title: context.tr('pending_sub_categories'),
                count: pendingSubCategoriesCount,
                icon: Icons.account_tree_outlined,
                route: '/sub-categories',
                extra: const {'initialStatus': 'PENDING'},
                indicatorColor: Colors.purple,
              ),
              const SizedBox(height: 10),
              _buildPendingApprovalItem(
                title: context.tr('pending_brands'),
                count: pendingBrandsCount,
                icon: Icons.branding_watermark_outlined,
                route: '/brands',
                extra: const {'initialStatus': 'PENDING'},
                indicatorColor: Colors.teal,
              ),
            ],
          ),
          const SizedBox(height: 10),

          // Recent Activities Section
          Text(
            context.tr('recent_activities'),
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.bold,
              color: Color(0xFF11261B),
            ),
          ),
          const SizedBox(height: 12),
          _buildRecentActivitiesList(),
          const SizedBox(height: 24),

          // Business Tips Section
          Text(
            context.tr('business_tips'),
            style: const TextStyle(
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
    VoidCallback? onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
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
    ),
  );
}

  Widget _buildLowStockAlertBanner(int outOfStock, int lowStock) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFFFFBEB),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFFDE68A), width: 1.2),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: const BoxDecoration(
              color: Color(0xFFFEF3C7),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.warning_amber_rounded, color: Color(0xFFD97706), size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Stock Action Required',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF92400E),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  '$outOfStock out of stock, $lowStock running low',
                  style: const TextStyle(
                    fontSize: 11.5,
                    color: Color(0xFFB45309),
                  ),
                ),
              ],
            ),
          ),
          ElevatedButton(
            onPressed: () => context.push('/inventory'),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFD97706),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              elevation: 0,
            ),
            child: const Text('Manage', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  Widget _buildStoreSetupActionBanner() {
    final rawEmail = _userData?['email'] as String? ?? '';
    final isPlaceholder = rawEmail.contains('@alanga.com') && rawEmail.startsWith('vendor_');
    if (!isPlaceholder) return const SizedBox.shrink();

    final fullName = _userData?['fullName'] as String? ?? '';
    final businessName = _userData?['businessName'] as String? ?? '';

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF7ED),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFFED7AA), width: 1.2),
      ),
      child: InkWell(
        onTap: () {
          FirstTimeStoreSetupSheet.show(
            context,
            initialFullName: fullName,
            initialBusinessName: businessName,
            initialEmail: null,
            onUpdated: () async {
              await _loadUser();
              await _loadDashboardData();
            },
          );
        },
        borderRadius: BorderRadius.circular(14),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: const BoxDecoration(
                  color: Color(0xFFFFEDD5),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.storefront_rounded, color: Color(0xFFC2410C), size: 20),
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Complete Your Store Profile',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF9A3412),
                      ),
                    ),
                    SizedBox(height: 2),
                    Text(
                      'Add your store name & email for order alerts',
                      style: TextStyle(
                        fontSize: 11.5,
                        color: Color(0xFFC2410C),
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: const Color(0xFFC2410C),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Text(
                  'SETUP',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 11,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildKycBannerSection() {
    final kycStatus = _summary?.kycStatus ?? 'NOT_SUBMITTED';

    if (kycStatus == 'VERIFIED') {
      return InkWell(
        onTap: () async {
          await context.push('/kyc');
          _loadDashboardData();
        },
        borderRadius: BorderRadius.circular(10),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: const Color(0xFFE8F5E9),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: const Color(0xFFA5D6A7), width: 1),
          ),
          child: const Row(
            children: [
              Icon(Icons.check_circle_rounded, color: Color(0xFF2E7D32), size: 18),
              SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Seller KYC & Payouts Active',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF1B5E20),
                  ),
                ),
              ),
              Icon(Icons.arrow_forward_ios_rounded, size: 11, color: Color(0xFF2E7D32)),
            ],
          ),
        ),
      );
    }

    final isPending = kycStatus == 'PENDING';
    final bgColor = isPending ? const Color(0xFFFFF9E6) : const Color(0xFFF0FDF4);
    final borderColor = isPending ? const Color(0xFFFFD54F) : const Color(0xFF86EFAC);
    final primaryColor = isPending ? const Color(0xFFD97706) : const Color(0xFF15803D);

    return InkWell(
      onTap: () async {
        await context.push('/kyc');
        _loadDashboardData();
      },
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: borderColor, width: 1),
          boxShadow: [
            BoxShadow(
              color: primaryColor.withOpacity(0.04),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: primaryColor.withOpacity(0.12),
                shape: BoxShape.circle,
              ),
              child: Icon(
                isPending ? Icons.hourglass_top_rounded : Icons.shield_outlined,
                color: primaryColor,
                size: 16,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    isPending
                        ? 'KYC Verification Under Review'
                        : 'Action: Complete KYC & Bank',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: primaryColor,
                    ),
                  ),
                  const SizedBox(height: 1),
                  Text(
                    isPending
                        ? 'Documents submitted • Verification in progress'
                        : 'Submit PAN & Bank details for payouts',
                    style: TextStyle(
                      fontSize: 10,
                      color: primaryColor.withOpacity(0.85),
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
              decoration: BoxDecoration(
                color: primaryColor,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    isPending ? 'STATUS' : 'START',
                    style: const TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      letterSpacing: 0.3,
                    ),
                  ),
                  const SizedBox(width: 3),
                  const Icon(Icons.arrow_forward_ios_rounded, size: 9, color: Colors.white),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSalesPerformanceSection() {
    final todayRevenue = _summary?.todayRevenue ?? 0.0;
    final ordersToDispatch = _summary?.ordersToDispatch ?? 0;
    final todayOrders = _summary?.todayOrders ?? 0;
    final lowStock = _summary?.lowStockProducts ?? 0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                const Icon(Icons.bolt, color: AppColors.primaryGreen, size: 15),
                const SizedBox(width: 4),
                Text(
                  context.tr('orders_sales_performance'),
                  style: const TextStyle(
                    fontSize: 13.5,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF11261B),
                  ),
                ),
              ],
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
              decoration: BoxDecoration(
                color: const Color(0xFFE8F4EC),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  const CircleAvatar(radius: 2.5, backgroundColor: AppColors.primaryGreen),
                  const SizedBox(width: 4),
                  Text(
                    context.tr('live'),
                    style: const TextStyle(fontSize: 9.5, fontWeight: FontWeight.bold, color: Color(0xFF1A3827)),
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 6),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: const Color(0xFFE5EDE8)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.02),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            children: [
              // 1. Today Sales
              Expanded(
                child: _buildCompactMetric(
                  title: context.tr('todays_sales'),
                  value: '₹${todayRevenue.toStringAsFixed(todayRevenue.truncateToDouble() == todayRevenue ? 0 : 2)}',
                  icon: Icons.currency_rupee_rounded,
                  color: const Color(0xFF1A3827),
                  bgTint: const Color(0xFFEBF5EE),
                ),
              ),
              Container(width: 1, height: 32, color: const Color(0xFFEFEFEF)),
              // 2. Orders to Dispatch
              Expanded(
                child: _buildCompactMetric(
                  title: context.tr('orders_to_dispatch'),
                  value: '$ordersToDispatch',
                  icon: Icons.local_shipping_outlined,
                  color: const Color(0xFFE65100),
                  bgTint: const Color(0xFFFFF3E0),
                  badge: ordersToDispatch > 0 ? 'URGENT' : null,
                  onTap: () {
                    setState(() => _currentIndex = 1);
                  },
                ),
              ),
              Container(width: 1, height: 32, color: const Color(0xFFEFEFEF)),
              // 3. Today's Orders
              Expanded(
                child: _buildCompactMetric(
                  title: context.tr('orders'),
                  value: '$todayOrders',
                  icon: Icons.shopping_cart_outlined,
                  color: const Color(0xFF1565C0),
                  bgTint: const Color(0xFFE3F2FD),
                  onTap: () {
                    setState(() => _currentIndex = 1);
                  },
                ),
              ),
              Container(width: 1, height: 32, color: const Color(0xFFEFEFEF)),
              // 4. Low Stock
              Expanded(
                child: _buildCompactMetric(
                  title: 'Low Stock',
                  value: '$lowStock',
                  icon: Icons.warning_amber_rounded,
                  color: const Color(0xFFC62828),
                  bgTint: const Color(0xFFFFEBEE),
                  badge: lowStock > 0 ? 'ALERT' : null,
                  onTap: () {
                    context.push('/inventory');
                  },
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildCompactMetric({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
    required Color bgTint,
    String? badge,
    VoidCallback? onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 2, vertical: 4),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 18,
                  height: 18,
                  decoration: BoxDecoration(
                    color: bgTint,
                    borderRadius: BorderRadius.circular(5),
                  ),
                  child: Icon(icon, color: color, size: 11),
                ),
                const SizedBox(width: 4),
                Flexible(
                  child: Text(
                    value,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      color: color,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 3),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                Flexible(
                  child: Text(
                    title,
                    style: const TextStyle(
                      fontSize: 9.5,
                      color: AppColors.textSecondaryLight,
                      fontWeight: FontWeight.w500,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                if (badge != null) ...[
                  const SizedBox(width: 2),
                  Container(
                    width: 5,
                    height: 5,
                    decoration: BoxDecoration(
                      color: color,
                      shape: BoxShape.circle,
                    ),
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickActionsReel() {
    final items = [
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
      _ReelItem(
        title: 'Inventory',
        icon: Icons.inventory_2_outlined,
        color: Colors.indigo,
        route: '/inventory',
        emoji: '📦',
      ),
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
                      foregroundColor: const Color(0xFF1A3827),
                      side: const BorderSide(color: Color(0xFF1A3827), width: 1.2),
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
    DashboardMasterDataSheets.showCategoriesBottomSheet(
      context,
      categories: _categories,
      subCategories: _subCategories,
    );
  }

  void _showSubCategoriesBottomSheet(BuildContext context) {
    DashboardMasterDataSheets.showSubCategoriesBottomSheet(
      context,
      categories: _categories,
      subCategories: _subCategories,
    );
  }

  void _showBrandsBottomSheet(BuildContext context) {
    DashboardMasterDataSheets.showBrandsBottomSheet(
      context,
      brands: _brands,
      onRefresh: () => _loadDashboardData(),
    );
  }

  Widget _buildPendingApprovalItem({
    required String title,
    required int count,
    required IconData icon,
    required String route,
    required Color indicatorColor,
    Object? extra,
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
            onTap: () => context.push(route, extra: extra),
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
    return const DashboardAlertsTab();
  }

  Widget _buildProfileTab() {
    return DashboardProfileTab(
      userData: _userData,
      kycStatus: _summary?.kycStatus,
      onRefreshUser: _loadUser,
      onRefreshDashboard: _loadDashboardData,
      onLogout: _showDashboardLogoutDialog,
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
