import 'dart:async';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/dependency_injection/injection.dart';
import '../../../../core/widgets/custom_image_view.dart';
import '../../../products/data/models/product_model.dart';
import '../../../products/domain/repositories/product_repository.dart';

enum InventoryFilter { all, lowStock, outOfStock, inStock }

class GlobalInventoryScreen extends StatefulWidget {
  const GlobalInventoryScreen({super.key});

  @override
  State<GlobalInventoryScreen> createState() => _GlobalInventoryScreenState();
}

class _GlobalInventoryScreenState extends State<GlobalInventoryScreen> {
  final ProductRepository _productRepo = sl<ProductRepository>();
  final TextEditingController _searchController = TextEditingController();

  List<ProductModel> _products = [];
  bool _isLoading = true;
  String? _errorMessage;
  InventoryFilter _selectedFilter = InventoryFilter.all;

  // Track updating product IDs for loading indicators
  final Set<String> _updatingProductIds = {};

  @override
  void initState() {
    super.initState();
    _loadProducts();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadProducts() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final list = await _productRepo.getProducts();
      if (mounted) {
        setState(() {
          _products = list;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _errorMessage = 'Failed to load inventory. Please try again.';
        });
      }
    }
  }

  Future<void> _updateStock(ProductModel product, int newStock) async {
    if (newStock < 0) return;

    // Optimistic update
    final oldStock = product.stock ?? 0;
    final index = _products.indexWhere((p) => p.id == product.id);
    if (index != -1) {
      setState(() {
        _products[index] = _products[index].copyWith(stock: newStock);
        _updatingProductIds.add(product.id);
      });
    }

    try {
      await _productRepo.updateProduct(product.id, {'stock': newStock});
      if (mounted) {
        ScaffoldMessenger.of(context).hideCurrentSnackBar();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${product.name} stock updated to $newStock'),
            backgroundColor: AppColors.primaryGreen,
            duration: const Duration(seconds: 2),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
      // Revert optimistic update on failure
      if (index != -1 && mounted) {
        setState(() {
          _products[index] = _products[index].copyWith(stock: oldStock);
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to update stock for ${product.name}'),
            backgroundColor: AppColors.brandRed,
            duration: const Duration(seconds: 3),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _updatingProductIds.remove(product.id);
        });
      }
    }
  }

  void _showCustomStockDialog(ProductModel product) {
    final currentStock = product.stock ?? 0;
    final ctrl = TextEditingController(text: currentStock.toString());

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.primaryGreen.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(Icons.inventory_2_outlined, color: AppColors.primaryGreen, size: 20),
            ),
            const SizedBox(width: 10),
            const Text(
              'Set Exact Stock',
              style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold, color: Color(0xFF11261B)),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              product.name,
              style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Color(0xFF11261B)),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 4),
            Text(
              'SKU: ${product.sku.isEmpty ? "N/A" : product.sku}',
              style: const TextStyle(fontSize: 11, color: AppColors.textSecondaryLight, fontFamily: 'monospace'),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: ctrl,
              autofocus: true,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: 'Available Units in Warehouse',
                labelStyle: const TextStyle(fontSize: 12),
                prefixIcon: const Icon(Icons.numbers, size: 18),
                filled: true,
                fillColor: const Color(0xFFF4F8F5),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: Color(0xFFE4ECE8)),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: Color(0xFFE4ECE8)),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: AppColors.primaryGreen, width: 1.5),
                ),
              ),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              children: [10, 25, 50, 100].map((units) {
                return ActionChip(
                  label: Text('+$units', style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600)),
                  backgroundColor: const Color(0xFFF0F5F2),
                  side: const BorderSide(color: Color(0xFFE4ECE8)),
                  onPressed: () {
                    final curr = int.tryParse(ctrl.text) ?? 0;
                    ctrl.text = (curr + units).toString();
                  },
                );
              }).toList(),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel', style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            onPressed: () {
              final parsed = int.tryParse(ctrl.text.trim());
              if (parsed != null && parsed >= 0) {
                Navigator.pop(ctx);
                _updateStock(product, parsed);
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryGreen,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
            ),
            child: const Text('Save Stock', style: TextStyle(fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  List<ProductModel> get _filteredProducts {
    final query = _searchController.text.trim().toLowerCase();

    return _products.where((p) {
      // 1. Text search
      final matchName = p.name.toLowerCase().contains(query);
      final matchSku = p.sku.toLowerCase().contains(query);
      if (query.isNotEmpty && !matchName && !matchSku) return false;

      // 2. Filter tabs
      final stock = p.stock ?? 0;
      switch (_selectedFilter) {
        case InventoryFilter.all:
          return true;
        case InventoryFilter.lowStock:
          return stock > 0 && stock <= 5;
        case InventoryFilter.outOfStock:
          return stock <= 0;
        case InventoryFilter.inStock:
          return stock > 5;
      }
    }).toList();
  }

  int get _outOfStockCount => _products.where((p) => (p.stock ?? 0) <= 0).length;
  int get _lowStockCount => _products.where((p) => (p.stock ?? 0) > 0 && (p.stock ?? 0) <= 5).length;
  int get _inStockCount => _products.where((p) => (p.stock ?? 0) > 5).length;

  @override
  Widget build(BuildContext context) {
    final filtered = _filteredProducts;

    return Scaffold(
      backgroundColor: const Color(0xFFF3F6F4),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 0,
        titleSpacing: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF11261B)),
          onPressed: () {
            if (context.canPop()) {
              context.pop();
            } else {
              context.go('/home');
            }
          },
        ),
        title: const Text(
          'Inventory & Stock Manager',
          style: TextStyle(
            color: Color(0xFF11261B),
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: AppColors.primaryGreen),
            tooltip: 'Refresh Inventory',
            onPressed: _loadProducts,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: AppColors.primaryGreen))
          : _errorMessage != null
              ? _buildErrorView()
              : RefreshIndicator(
                  onRefresh: _loadProducts,
                  color: AppColors.primaryGreen,
                  child: ListView(
                    padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
                    children: [
                      // 1. Summary Metric Hero Cards
                      _buildSummaryHeroRow(),
                      const SizedBox(height: 16),

                      // 2. Search Field
                      _buildSearchBar(),
                      const SizedBox(height: 14),

                      // 3. Filter Segment Tabs
                      _buildFilterChips(),
                      const SizedBox(height: 16),

                      // 4. Products Inventory List Header
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Products (${filtered.length})',
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF11261B),
                            ),
                          ),
                          const Text(
                            'Tap + / - for instant 1-tap update',
                            style: TextStyle(
                              fontSize: 11,
                              color: AppColors.textSecondaryLight,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),

                      // 5. Product Cards or Empty State
                      if (filtered.isEmpty)
                        _buildEmptyState()
                      else
                        ...filtered.map((product) => _buildInventoryProductCard(product)),
                    ],
                  ),
                ),
    );
  }

  Widget _buildSummaryHeroRow() {
    return Row(
      children: [
        Expanded(
          child: _buildMetricTile(
            title: 'Out of Stock',
            count: _outOfStockCount,
            icon: Icons.cancel_outlined,
            color: const Color(0xFFDC2626),
            bgColor: const Color(0xFFFEF2F2),
            borderColor: const Color(0xFFFECACA),
            filter: InventoryFilter.outOfStock,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _buildMetricTile(
            title: 'Low Stock (≤5)',
            count: _lowStockCount,
            icon: Icons.warning_amber_rounded,
            color: const Color(0xFFD97706),
            bgColor: const Color(0xFFFFFBEB),
            borderColor: const Color(0xFFFDE68A),
            filter: InventoryFilter.lowStock,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _buildMetricTile(
            title: 'Healthy Stock',
            count: _inStockCount,
            icon: Icons.check_circle_outline,
            color: const Color(0xFF16A34A),
            bgColor: const Color(0xFFF0FDF4),
            borderColor: const Color(0xFFBBF7D0),
            filter: InventoryFilter.inStock,
          ),
        ),
      ],
    );
  }

  Widget _buildMetricTile({
    required String title,
    required int count,
    required IconData icon,
    required Color color,
    required Color bgColor,
    required Color borderColor,
    required InventoryFilter filter,
  }) {
    final isSelected = _selectedFilter == filter;

    return InkWell(
      onTap: () {
        setState(() {
          _selectedFilter = isSelected ? InventoryFilter.all : filter;
        });
      },
      borderRadius: BorderRadius.circular(14),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 10),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isSelected ? color : borderColor,
            width: isSelected ? 2 : 1,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: color.withValues(alpha: 0.15),
                    blurRadius: 8,
                    offset: const Offset(0, 3),
                  ),
                ]
              : null,
        ),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(icon, size: 14, color: color),
                const SizedBox(width: 4),
                Text(
                  count.toString(),
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    color: color,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 3),
            Text(
              title,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 10.5,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                color: color.withValues(alpha: 0.9),
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchBar() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE4ECE8)),
      ),
      child: TextField(
        controller: _searchController,
        onChanged: (_) => setState(() {}),
        decoration: InputDecoration(
          hintText: 'Search product by name or SKU...',
          hintStyle: const TextStyle(fontSize: 13, color: AppColors.textSecondaryLight),
          prefixIcon: const Icon(Icons.search, color: AppColors.primaryGreen, size: 20),
          suffixIcon: _searchController.text.isNotEmpty
              ? IconButton(
                  icon: const Icon(Icons.clear, size: 18, color: Colors.grey),
                  onPressed: () {
                    _searchController.clear();
                    setState(() {});
                  },
                )
              : null,
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        ),
      ),
    );
  }

  Widget _buildFilterChips() {
    final filters = [
      {'label': 'All (${_products.length})', 'filter': InventoryFilter.all},
      {'label': 'Low Stock ($_lowStockCount)', 'filter': InventoryFilter.lowStock},
      {'label': 'Out of Stock ($_outOfStockCount)', 'filter': InventoryFilter.outOfStock},
      {'label': 'In Stock ($_inStockCount)', 'filter': InventoryFilter.inStock},
    ];

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      physics: const BouncingScrollPhysics(),
      child: Row(
        children: filters.map((f) {
          final filter = f['filter'] as InventoryFilter;
          final isSelected = _selectedFilter == filter;
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: ChoiceChip(
              label: Text(
                f['label'] as String,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                  color: isSelected ? Colors.white : const Color(0xFF11261B),
                ),
              ),
              selected: isSelected,
              onSelected: (_) {
                setState(() => _selectedFilter = filter);
              },
              selectedColor: AppColors.primaryGreen,
              backgroundColor: Colors.white,
              side: BorderSide(
                color: isSelected ? AppColors.primaryGreen : const Color(0xFFE4ECE8),
              ),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              showCheckmark: false,
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildInventoryProductCard(ProductModel product) {
    final stock = product.stock ?? 0;
    final isUpdating = _updatingProductIds.contains(product.id);

    Color badgeColor;
    Color badgeBg;
    String badgeText;

    if (stock <= 0) {
      badgeColor = const Color(0xFFDC2626);
      badgeBg = const Color(0xFFFEE2E2);
      badgeText = 'OUT OF STOCK';
    } else if (stock <= 5) {
      badgeColor = const Color(0xFFD97706);
      badgeBg = const Color(0xFFFEF3C7);
      badgeText = 'LOW STOCK ($stock)';
    } else {
      badgeColor = const Color(0xFF16A34A);
      badgeBg = const Color(0xFFDCFCE7);
      badgeText = 'IN STOCK ($stock)';
    }

    final imageUrl = product.primaryImageUrl ?? product.image;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: stock <= 0
              ? const Color(0xFFFCA5A5)
              : stock <= 5
                  ? const Color(0xFFFDE68A)
                  : const Color(0xFFE4ECE8),
          width: stock <= 5 ? 1.2 : 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          children: [
            // Top Row: Image, Name, SKU, Status Badge
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Thumbnail
                Container(
                  width: 58,
                  height: 58,
                  decoration: BoxDecoration(
                    color: const Color(0xFFF4F8F5),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: const Color(0xFFE4ECE8)),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: CustomImageView(
                      imageUrl: imageUrl,
                      fit: BoxFit.cover,
                      placeholderIcon: Icons.shopping_bag_outlined,
                    ),
                  ),
                ),
                const SizedBox(width: 12),

                // Details
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(
                              color: badgeBg,
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              badgeText,
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w800,
                                color: badgeColor,
                                letterSpacing: 0.3,
                              ),
                            ),
                          ),
                          const Spacer(),
                          Text(
                            '₹${product.sellingPrice.toStringAsFixed(0)}',
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: AppColors.primaryGreen,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 5),
                      Text(
                        product.name,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF11261B),
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'SKU: ${product.sku.isEmpty ? "N/A" : product.sku}',
                        style: const TextStyle(
                          fontSize: 11,
                          color: AppColors.textSecondaryLight,
                          fontFamily: 'monospace',
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),

            // Divider
            const Divider(height: 1, color: Color(0xFFF0F5F2)),
            const SizedBox(height: 12),

            // Bottom Action Row: Quick 1-Tap Buttons + Direct Edit
            Row(
              children: [
                // Quick Stock Modifier Button (-)
                _buildStockStepButton(
                  icon: Icons.remove,
                  enabled: stock > 0 && !isUpdating,
                  onTap: () => _updateStock(product, stock - 1),
                ),
                const SizedBox(width: 8),

                // Tap-to-Edit Current Units Badge
                Expanded(
                  child: InkWell(
                    onTap: isUpdating ? null : () => _showCustomStockDialog(product),
                    borderRadius: BorderRadius.circular(10),
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF8FAF9),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: const Color(0xFFE4ECE8)),
                      ),
                      child: isUpdating
                          ? const Center(
                              child: SizedBox(
                                width: 16,
                                height: 16,
                                child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.primaryGreen),
                              ),
                            )
                          : Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Text(
                                  'Units: ',
                                  style: TextStyle(fontSize: 12, color: AppColors.textSecondaryLight),
                                ),
                                Text(
                                  stock.toString(),
                                  style: TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.bold,
                                    color: badgeColor,
                                  ),
                                ),
                                const SizedBox(width: 4),
                                const Icon(Icons.edit_outlined, size: 14, color: AppColors.textSecondaryLight),
                              ],
                            ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),

                // Quick Stock Modifier Button (+)
                _buildStockStepButton(
                  icon: Icons.add,
                  enabled: !isUpdating,
                  onTap: () => _updateStock(product, stock + 1),
                ),
                const SizedBox(width: 8),

                // Quick +5 Button
                _buildQuickAddChip(
                  label: '+5',
                  enabled: !isUpdating,
                  onTap: () => _updateStock(product, stock + 5),
                ),
                const SizedBox(width: 6),

                // Quick +10 Button
                _buildQuickAddChip(
                  label: '+10',
                  enabled: !isUpdating,
                  onTap: () => _updateStock(product, stock + 10),
                ),
                const SizedBox(width: 6),

                // Variants Drawer button
                IconButton(
                  icon: const Icon(Icons.tune_outlined, color: AppColors.primaryGreen, size: 20),
                  tooltip: 'Variant Stock',
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                  onPressed: () {
                    context.push('/products/inventory', extra: product);
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStockStepButton({
    required IconData icon,
    required bool enabled,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: enabled ? onTap : null,
      borderRadius: BorderRadius.circular(10),
      child: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          color: enabled ? const Color(0xFFF4F8F5) : const Color(0xFFF9FAFB),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: const Color(0xFFE4ECE8)),
        ),
        child: Icon(
          icon,
          size: 18,
          color: enabled ? const Color(0xFF1A3827) : Colors.grey,
        ),
      ),
    );
  }

  Widget _buildQuickAddChip({
    required String label,
    required bool enabled,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: enabled ? onTap : null,
      borderRadius: BorderRadius.circular(10),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        decoration: BoxDecoration(
          color: enabled ? const Color(0xFFF4F8F5) : const Color(0xFFF9FAFB),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: const Color(0xFFE4ECE8)),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w700,
            color: enabled ? AppColors.primaryGreen : Colors.grey,
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Container(
      padding: const EdgeInsets.all(32),
      alignment: Alignment.center,
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.primaryGreen.withValues(alpha: 0.08),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.inventory_2_outlined, size: 40, color: AppColors.primaryGreen),
          ),
          const SizedBox(height: 16),
          const Text(
            'No matching products found',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF11261B)),
          ),
          const SizedBox(height: 6),
          const Text(
            'Try changing your filter or search query',
            style: TextStyle(fontSize: 12, color: AppColors.textSecondaryLight),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorView() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 48, color: AppColors.brandRed),
            const SizedBox(height: 12),
            Text(
              _errorMessage ?? 'An error occurred',
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 14, color: Color(0xFF11261B)),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _loadProducts,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryGreen,
                foregroundColor: Colors.white,
              ),
              child: const Text('Try Again'),
            ),
          ],
        ),
      ),
    );
  }
}
