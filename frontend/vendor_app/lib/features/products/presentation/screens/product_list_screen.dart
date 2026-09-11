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
import '../../../../core/widgets/delete_confirmation_dialog.dart';

class ProductListScreen extends StatefulWidget {
  const ProductListScreen({super.key});

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
    _tabController = TabController(length: _tabs.length, vsync: this, initialIndex: 0);
    _searchCtrl.addListener(() {
      setState(() => _searchQuery = _searchCtrl.text.trim().toLowerCase());
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<ProductBloc>()..add(const FetchProductsEvent()),
      child: Scaffold(
        backgroundColor: const Color(0xFFF3F6F4),
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
                      // ── Fixed header (AppBar + search + stats) ────────────
                      // This block does NOT scroll. It stays pinned at the top.
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
                          indicatorWeight: 3.0,
                          indicatorSize: TabBarIndicatorSize.label,
                          dividerColor: const Color(0xFFE8EFE9),
                          labelStyle: const TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 13.5),
                          unselectedLabelStyle: const TextStyle(
                              fontWeight: FontWeight.w600, fontSize: 13),
                          tabs: _tabs
                              .map((t) => Tab(
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Icon(t.icon, size: 16),
                                        const SizedBox(width: 6),
                                        Text(t.label),
                                        if (countMap[t.status] != null &&
                                            countMap[t.status]! > 0) ...[
                                          const SizedBox(width: 6),
                                          Container(
                                            padding: const EdgeInsets.symmetric(
                                                horizontal: 7, vertical: 2),
                                            decoration: BoxDecoration(
                                              color: t.color
                                                  .withValues(alpha: 0.12),
                                              borderRadius:
                                                  BorderRadius.circular(12),
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
            await context.push('/products/add');
            if (context.mounted) {
              context.read<ProductBloc>().add(const FetchProductsEvent(isRefresh: true));
            }
          },
          backgroundColor: const Color(0xFF1A3827),
          elevation: 4,
          icon: const Icon(Icons.add_rounded, color: Colors.white),
          label: const Text(
            'Add Product',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              letterSpacing: 0.3,
            ),
          ),
        ),
      ),
    );
  }


  Widget _buildHeader(
      BuildContext context, ProductState state, Map<String, int> countMap) {

    return Container(
      color: const Color(0xFFF6F8F6),
      child: SafeArea(
        bottom: false,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top bar — same style as Add Product AppBar
            Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(
                children: [
                  // Back button — circular, same as Add Product AppBar
                  GestureDetector(
                    onTap: () => context.pop(),
                    child: Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white,
                        border: Border.all(
                            color: const Color(0xFFE4ECE8), width: 1.2),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.04),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: const Icon(Icons.arrow_back,
                          size: 18, color: Color(0xFF1A3827)),
                    ),
                  ),
                  const SizedBox(width: 14),
                  // Title — centered same as Add Product AppBar
                  Expanded(
                    child: Text(
                      'My Products',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF11261B),
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  // Refresh button — circular, same style as back button
                  GestureDetector(
                    onTap: () => context
                        .read<ProductBloc>()
                        .add(const FetchProductsEvent(isRefresh: true)),
                    child: Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white,
                        border: Border.all(
                            color: const Color(0xFFE4ECE8), width: 1.2),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.04),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: const Icon(Icons.refresh_rounded,
                          size: 18, color: Color(0xFF1A3827)),
                    ),
                  ),
                ],
              ),
            ),

            // Search bar
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Container(
                decoration: BoxDecoration(
                  color: const Color(0xFFF3F6F4),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: const Color(0xFFDDE8E1), width: 1),
                ),
                child: TextField(
                  controller: _searchCtrl,
                  style: const TextStyle(
                      fontSize: 14, color: Color(0xFF11261B)),
                  decoration: InputDecoration(
                    hintText: 'Search products by name or SKU...',
                    hintStyle: const TextStyle(
                        fontSize: 14, color: Color(0xFF7A9A86)),
                    prefixIcon: const Icon(Icons.search_rounded,
                        color: Color(0xFF7A9A86), size: 20),
                    suffixIcon: _searchQuery.isNotEmpty
                        ? GestureDetector(
                            onTap: () {
                              _searchCtrl.clear();
                              setState(() => _searchQuery = '');
                            },
                            child: const Icon(Icons.close_rounded,
                                color: Color(0xFF7A9A86), size: 18),
                          )
                        : null,
                    border: InputBorder.none,
                    contentPadding:
                        const EdgeInsets.symmetric(vertical: 12, horizontal: 4),
                  ),
                ),
              ),
            ),

            // Stats strip
            if (state is ProductListLoaded) ...[
              const SizedBox(height: 16),
              SizedBox(
                height: 72,
                child: ListView.separated(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  scrollDirection: Axis.horizontal,
                  itemCount: _tabs.length,
                  separatorBuilder: (_, _) => const SizedBox(width: 10),
                  itemBuilder: (_, i) {
                    final t = _tabs[i];
                    final count = countMap[t.status] ?? 0;
                    return Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 10),
                      decoration: BoxDecoration(
                        color: t.color.withValues(alpha: 0.08),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                            color: t.color.withValues(alpha: 0.2), width: 1),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(t.icon, size: 12, color: t.color),
                              const SizedBox(width: 4),
                              Text(
                                t.label,
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                  color: t.color,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '$count',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: t.color,
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ],

            const SizedBox(height: 10),
          ],
        ),
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
                  onTap: () => context.push('/products/details', extra: product),
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
      title: 'Delete Product',
      message: 'Are you sure you want to delete this product?',
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
        title: const Row(
          children: [
            Icon(Icons.rocket_launch_rounded,
                color: Color(0xFF1A8C4E), size: 22),
            SizedBox(width: 8),
            Text(
              'Submit for Approval',
              style: TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF11261B)),
            ),
          ],
        ),
        content: const Text(
          'Submit this product to administrative review? It will enter PENDING status and become read-only until reviewed.',
          style: TextStyle(color: Color(0xFF4C6656), fontSize: 14),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogCtx),
            child: const Text('Cancel',
                style: TextStyle(color: Color(0xFF4C6656))),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(dialogCtx);
              context
                  .read<ProductBloc>()
                  .add(SubmitProductForApprovalEvent(id: id));
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF1A8C4E),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
              elevation: 0,
            ),
            child: const Text('Submit',
                style: TextStyle(fontWeight: FontWeight.bold)),
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
                    ? 'No results found'
                    : 'No ${tab.label} Products',
                style: const TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF11261B),
                ),
              ),
              const SizedBox(height: 6),
              Text(
                _searchQuery.isNotEmpty
                    ? 'Try a different search term'
                    : 'Pull down to refresh or add a new product',
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
            const Text(
              'Something went wrong',
              style: TextStyle(
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
              label: const Text('Retry',
                  style: TextStyle(fontWeight: FontWeight.bold)),
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
