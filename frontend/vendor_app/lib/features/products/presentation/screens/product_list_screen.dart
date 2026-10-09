import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../bloc/product_bloc.dart';
import '../bloc/product_event.dart';
import '../bloc/product_state.dart';
import '../widgets/product_card.dart';
import '../../data/models/product_model.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/dependency_injection/injection.dart';
import '../../../../core/localization/app_localizations.dart';
import '../../../../core/widgets/delete_confirmation_dialog.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../auth/presentation/bloc/auth_event.dart';
import '../../../auth/presentation/bloc/auth_state.dart';
import '../../../profile/presentation/widgets/first_time_store_setup_sheet.dart';

class ProductListScreen extends StatefulWidget {
  final VoidCallback? onBackToDashboard;
  final String? initialStatus;

  const ProductListScreen({super.key, this.onBackToDashboard, this.initialStatus});

  @override
  State<ProductListScreen> createState() => _ProductListScreenState();
}

class _ProductListScreenState extends State<ProductListScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final TextEditingController _searchCtrl = TextEditingController();
  String _searchQuery = '';

  final List<_TabMeta> _tabs = const [
    _TabMeta(label: 'Approved',  status: 'ACTIVE',    color: Color(0xFF1A8C4E), icon: Icons.check_circle_rounded),
    _TabMeta(label: 'Pending',   status: 'PENDING',   color: Color(0xFFF99F1B), icon: Icons.hourglass_top_rounded),
    _TabMeta(label: 'Draft',     status: 'DRAFT',     color: Color(0xFF4A7BC4), icon: Icons.edit_note_rounded),
    _TabMeta(label: 'Rejected',  status: 'REJECTED',  color: Color(0xFFE6222B), icon: Icons.cancel_rounded),
    _TabMeta(label: 'Suspended', status: 'SUSPENDED', color: Color(0xFF8B6F47), icon: Icons.pause_circle_rounded),
  ];

  List<ProductModel> _cachedProducts = [];

  @override
  void initState() {
    super.initState();
    int initialIdx = 0;
    if (widget.initialStatus != null) {
      final found = _tabs.indexWhere(
        (t) => t.status.toUpperCase() == widget.initialStatus!.toUpperCase(),
      );
      if (found != -1) initialIdx = found;
    }
    _tabController = TabController(length: _tabs.length, vsync: this, initialIndex: initialIdx);
    _tabController.addListener(() {
      if (mounted) setState(() {});
    });
    _searchCtrl.addListener(() {
      setState(() => _searchQuery = _searchCtrl.text.trim().toLowerCase());
    });
  }

  @override
  void didUpdateWidget(covariant ProductListScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.initialStatus != null && widget.initialStatus != oldWidget.initialStatus) {
      final found = _tabs.indexWhere(
        (t) => t.status.toUpperCase() == widget.initialStatus!.toUpperCase(),
      );
      if (found != -1 && _tabController.index != found) {
        _tabController.animateTo(found);
      }
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchCtrl.dispose();
    super.dispose();
  }

  void _handleBack(BuildContext context) {
    if (widget.onBackToDashboard != null) {
      widget.onBackToDashboard!();
    } else if (Navigator.of(context).canPop()) {
      Navigator.of(context).pop();
    }
  }

  PreferredSizeWidget _buildAppBar(BuildContext context) {
    return AppBar(
      backgroundColor: const Color(0xFFF6F8F6),
      elevation: 0,
      scrolledUnderElevation: 0,
      centerTitle: true,
      toolbarHeight: 46,
      automaticallyImplyLeading: false,
      leading: Padding(
        padding: const EdgeInsets.only(left: 12),
        child: Center(
          child: GestureDetector(
            onTap: () => _handleBack(context),
            child: Container(
              width: 34,
              height: 34,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white,
                border: Border.all(color: const Color(0xFFE4ECE8), width: 1.2),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.04),
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: const Icon(
                Icons.arrow_back,
                size: 17,
                color: Color(0xFF1A3827),
              ),
            ),
          ),
        ),
      ),
      title: Text(
        context.tr('my_products'),
        style: const TextStyle(
          fontSize: 17,
          fontWeight: FontWeight.bold,
          color: Color(0xFF11261B),
        ),
      ),
      actions: [
        Padding(
          padding: const EdgeInsets.only(right: 12),
          child: Center(
            child: Builder(
              builder: (btnCtx) => GestureDetector(
                onTap: () {
                  btnCtx.read<ProductBloc>().add(const FetchProductsEvent(isRefresh: true));
                },
                child: Container(
                  width: 34,
                  height: 34,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white,
                    border: Border.all(color: const Color(0xFFE4ECE8), width: 1.2),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.04),
                        blurRadius: 6,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.refresh_rounded,
                    size: 17,
                    color: Color(0xFF1A3827),
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<ProductBloc>()..add(const FetchProductsEvent()),
      child: Builder(
        builder: (context) {
          return PopScope(
            canPop: false,
            onPopInvokedWithResult: (didPop, _) {
              if (didPop) return;
              _handleBack(context);
            },
            child: Scaffold(
              backgroundColor: const Color(0xFFF6F8F6),
              appBar: _buildAppBar(context),
              body: BlocConsumer<ProductBloc, ProductState>(
          listener: (context, state) {
            if (state is ProductActionSuccess) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(state.message),
                  backgroundColor: AppColors.primaryGreen,
                  behavior: SnackBarBehavior.floating,
                ),
              );
              context
                  .read<ProductBloc>()
                  .add(const FetchProductsEvent(isRefresh: true));
            } else if (state is ProductActionError) {
              showValidationErrorDialog(
                context: context,
                title: 'Delete Product',
                message: state.message,
              );
            }
          },
          builder: (context, state) {
            if (state is ProductListLoaded) {
              _cachedProducts = state.products;
            }
            final isActionLoading = state is ProductActionLoading;
            final allProducts = _cachedProducts;

            // Build count map for stat strip
            final countMap = <String, int>{};
            for (final t in _tabs) {
              countMap[t.status] = allProducts
                  .where((p) => p.status.toUpperCase() == t.status)
                  .length;
            }

            return Stack(
              children: [
                AbsorbPointer(
                  absorbing: isActionLoading,
                  child: Column(
                    children: [
                      // ── Fixed header (Search Bar + Counter) ───────────────
                      if (isActionLoading)
                        const LinearProgressIndicator(
                          color: AppColors.brandOrange,
                          backgroundColor: Color(0xFFFFF3E0),
                        ),
                      _buildHeader(context, state, countMap),

                      // ── Fixed TabBar ───────────────────────────────────────
                      Container(
                        color: Colors.white,
                        child: TabBar(
                          controller: _tabController,
                          isScrollable: true,
                          tabAlignment: TabAlignment.start,
                          labelColor: AppColors.primaryGreen,
                          unselectedLabelColor: const Color(0xFF5A7265),
                          indicatorColor: AppColors.primaryGreen,
                          indicatorWeight: 2.5,
                          indicatorSize: TabBarIndicatorSize.label,
                          dividerColor: const Color(0xFFE8EFE9),
                          labelPadding: const EdgeInsets.symmetric(horizontal: 14),
                          labelStyle: const TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 13),
                          unselectedLabelStyle: const TextStyle(
                              fontWeight: FontWeight.w600, fontSize: 13),
                          tabs: _tabs
                              .map((t) => Tab(
                                    height: 42,
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Icon(t.icon, size: 15),
                                        const SizedBox(width: 5),
                                        Text(context.tr(t.label)),
                                        if (countMap[t.status] != null &&
                                            countMap[t.status]! > 0) ...[
                                          const SizedBox(width: 5),
                                          Container(
                                            padding: const EdgeInsets.symmetric(
                                                horizontal: 6, vertical: 1.5),
                                            decoration: BoxDecoration(
                                              color: t.color
                                                  .withValues(alpha: 0.12),
                                              borderRadius:
                                                  BorderRadius.circular(10),
                                            ),
                                            child: Text(
                                              '${countMap[t.status]}',
                                              style: TextStyle(
                                                fontSize: 10.5,
                                                fontWeight: FontWeight.w800,
                                                color: t.color,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ],
                                    ),
                                  ))
                              .toList(),
                        ),
                      ),

                      // ── Scrollable content ─────────────────────────────────
                      Expanded(
                        child: (state is ProductListLoading &&
                                allProducts.isEmpty)
                            ? _buildSkeletonLoader()
                            : state is ProductListError
                                ? _buildError(context, state.message)
                                : TabBarView(
                                    controller: _tabController,
                                    children: _tabs
                                        .map((t) => _buildProductTab(
                                            context, allProducts, t))
                                        .toList(),
                                  ),
                      ),
                    ],
                  ),
                ),
              ],
            );
          },
        ),
        floatingActionButton: FloatingActionButton.extended(
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
              await context.push('/products/add');
              if (context.mounted) {
                context.read<ProductBloc>().add(const FetchProductsEvent(isRefresh: true));
              }
            }
          },
          backgroundColor: const Color(0xFF1A3827),
          elevation: 4,
          icon: const Icon(Icons.add_rounded, color: Colors.white),
          label: Text(
            context.tr('add_product'),
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              letterSpacing: 0.3,
            ),
          ),
        ),
      ),
    );
  },
),
);
  }

  Widget _buildHeader(
      BuildContext context, ProductState state, Map<String, int> countMap) {
    final totalCount = countMap.values.fold<int>(0, (sum, count) => sum + count);

    return Container(
      color: const Color(0xFFF6F8F6),
      padding: const EdgeInsets.fromLTRB(16, 2, 16, 10),
      child: Row(
        children: [
          Expanded(
            child: Container(
              height: 42,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: const Color(0xFFE2ECE5), width: 1.0),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF1A3827).withValues(alpha: 0.03),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: TextField(
                controller: _searchCtrl,
                style: const TextStyle(
                  fontSize: 13.5,
                  fontWeight: FontWeight.w500,
                  color: Color(0xFF11261B),
                ),
                decoration: InputDecoration(
                  hintText: context.tr('search_products_hint'),
                  hintStyle: const TextStyle(
                    fontSize: 13,
                    color: Color(0xFF9CA3AF),
                  ),
                  prefixIcon: const Icon(
                    Icons.search_rounded,
                    color: Color(0xFF1A3827),
                    size: 20,
                  ),
                  suffixIcon: _searchQuery.isNotEmpty
                      ? GestureDetector(
                          onTap: () {
                            _searchCtrl.clear();
                            setState(() => _searchQuery = '');
                          },
                          child: const Icon(
                            Icons.close_rounded,
                            color: Color(0xFF6B7280),
                            size: 18,
                          ),
                        )
                      : null,
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 11,
                  ),
                ),
              ),
            ),
          ),
          if (state is ProductListLoaded) ...[
            const SizedBox(width: 8),
            Container(
              height: 42,
              padding: const EdgeInsets.symmetric(horizontal: 12),
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: const Color(0xFF1A3827),
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF1A3827).withValues(alpha: 0.15),
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    'ALL: ',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 0.5,
                      color: Color(0xFF85D6A4),
                    ),
                  ),
                  Text(
                    '$totalCount',
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w900,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildProductTab(
      BuildContext context, List<dynamic> allProducts, _TabMeta tab) {
    var list = allProducts
        .where((p) => p.status.toUpperCase() == tab.status)
        .toList();

    if (_searchQuery.isNotEmpty) {
      list = list
          .where((p) =>
              p.name.toLowerCase().contains(_searchQuery) ||
              p.sku.toLowerCase().contains(_searchQuery))
          .toList();
    }

    return RefreshIndicator(
      color: AppColors.brandOrange,
      backgroundColor: Colors.white,
      onRefresh: () async {
        context
            .read<ProductBloc>()
            .add(const FetchProductsEvent(isRefresh: true));
      },
      child: list.isEmpty
          ? _buildEmptyState(tab)
          : ListView.builder(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
              itemCount: list.length,
              itemBuilder: (context, index) {
                final product = list[index];
                return ProductCard(
                  product: product,
                  onTap: () async {
                    await context.push('/products/details', extra: product);
                    if (context.mounted) {
                      context.read<ProductBloc>().add(const FetchProductsEvent(isRefresh: true));
                    }
                  },
                  onManageInventory: () => context.push('/products/inventory', extra: product),
                  onManageShipping: () => context.push('/products/shipping', extra: product),
                  onEdit: () async {
                    await context.push('/products/edit', extra: product);
                    if (context.mounted) {
                      context.read<ProductBloc>().add(const FetchProductsEvent(isRefresh: true));
                    }
                  },
                  onSubmit: () => _confirmSubmit(context, product.id),
                  onDelete: () => _confirmDelete(context, product.id),
                );
              },
            ),
    );
  }

  void _confirmDelete(BuildContext context, String id) async {
    final confirmed = await showDeleteConfirmationDialog(
      context: context,
      title: context.tr('delete_product'),
      message: context.tr('delete_product_confirm'),
    );
    if (confirmed == true && context.mounted) {
      context.read<ProductBloc>().add(DeleteProductSubmittedEvent(id: id));
    }
  }

  void _confirmSubmit(BuildContext context, String id) {
    showDialog(
      context: context,
      builder: (dialogCtx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            const Icon(Icons.rocket_launch_rounded,
                color: Color(0xFF1A8C4E), size: 22),
            const SizedBox(width: 8),
            Text(
              context.tr('submit_for_approval'),
              style: const TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF11261B)),
            ),
          ],
        ),
        content: Text(
          context.tr('submit_approval_confirm_desc'),
          style: const TextStyle(color: Color(0xFF4C6656), fontSize: 14),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogCtx),
            child: Text(context.tr('cancel'),
                style: const TextStyle(color: Color(0xFF4C6656))),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(dialogCtx);
              context
                  .read<ProductBloc>()
                  .add(SubmitProductForApprovalEvent(id: id));
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF1A3827),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
              elevation: 0,
            ),
            child: Text(context.tr('submit'),
                style: const TextStyle(fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(_TabMeta tab) {
    return LayoutBuilder(
      builder: (context, constraints) => SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: Container(
          height: constraints.maxHeight,
          alignment: Alignment.center,
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: tab.color.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(24),
                ),
                child: Icon(
                  Icons.shopping_bag_outlined,
                  size: 38,
                  color: tab.color.withValues(alpha: 0.6),
                ),
              ),
              const SizedBox(height: 18),
              Text(
                _searchQuery.isNotEmpty
                    ? context.tr('no_results_found')
                    : '${context.tr('no_products_found')} (${context.tr(tab.label)})',
                style: const TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF11261B),
                ),
              ),
              const SizedBox(height: 6),
              Text(
                _searchQuery.isNotEmpty
                    ? context.tr('try_diff_search_term')
                    : context.tr('pull_to_refresh_add_product'),
                style: const TextStyle(
                  fontSize: 13,
                  color: Color(0xFF7A9A86),
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildError(BuildContext context, String message) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                color: const Color(0xFFE6222B).withValues(alpha: 0.07),
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Icon(Icons.error_outline_rounded,
                  color: Color(0xFFE6222B), size: 36),
            ),
            const SizedBox(height: 16),
            Text(
              context.tr('something_went_wrong'),
              style: const TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF11261B)),
            ),
            const SizedBox(height: 6),
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(color: Color(0xFF7A9A86), fontSize: 13),
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: () {
                context.read<ProductBloc>().add(const FetchProductsEvent());
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF1A3827),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
                elevation: 0,
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              ),
              icon: const Icon(Icons.refresh_rounded, size: 18),
              label: Text(context.tr('retry'),
                  style: const TextStyle(fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSkeletonLoader() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: 4,
      itemBuilder: (context, index) {
        return Container(
          margin: const EdgeInsets.only(bottom: 14),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(18),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF1A3827).withValues(alpha: 0.05),
                blurRadius: 12,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    _shimmer(width: 76, height: 76, radius: 14),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _shimmer(width: 70, height: 18, radius: 8),
                          const SizedBox(height: 8),
                          _shimmer(width: double.infinity, height: 14, radius: 6),
                          const SizedBox(height: 6),
                          _shimmer(width: 100, height: 12, radius: 5),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                _shimmer(width: double.infinity, height: 48, radius: 12),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _shimmer({required double width, required double height, required double radius}) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(radius),
      ),
    );
  }
}

class _TabMeta {
  final String label;
  final String status;
  final Color color;
  final IconData icon;

  const _TabMeta({
    required this.label,
    required this.status,
    required this.color,
    required this.icon,
  });
}
