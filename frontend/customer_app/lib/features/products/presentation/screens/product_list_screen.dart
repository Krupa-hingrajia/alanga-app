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
import '../../../../core/network/api_service.dart';

class ProductListScreen extends StatefulWidget {
  final String? initialQuery;

  const ProductListScreen({super.key, this.initialQuery});

  @override
  State<ProductListScreen> createState() => _ProductListScreenState();
}

class _ProductListScreenState extends State<ProductListScreen> {
  final _searchController = TextEditingController();
  String _searchQuery = '';

  String _sortBy = 'Newest'; // 'Newest', 'Price: Low to High', 'Price: High to Low'
  
  List<dynamic> _categories = [];
  List<dynamic> _brands = [];
  bool _loadingFilters = true;

  // Selected filters
  final Set<String> _selectedCategoryIds = {};
  final Set<String> _selectedBrandIds = {};
  double _maxPriceLimit = 200000;
  double _currentPriceRange = 200000;

  @override
  void initState() {
    super.initState();
    _searchQuery = widget.initialQuery ?? '';
    _searchController.text = _searchQuery;
    _loadFilters();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadFilters() async {
    try {
      final responses = await Future.wait([
        sl<ApiService>().get('/customer/categories'),
        sl<ApiService>().get('/customer/brands'),
      ]);
      setState(() {
        _categories = responses[0].data['data'] as List<dynamic>;
        _brands = responses[1].data['data'] as List<dynamic>;
        _loadingFilters = false;
      });
    } catch (_) {
      setState(() {
        _loadingFilters = false;
      });
    }
  }

  void _openFilterBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (bottomSheetCtx) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return DraggableScrollableSheet(
              initialChildSize: 0.75,
              minChildSize: 0.5,
              maxChildSize: 0.9,
              expand: false,
              builder: (_, scrollController) {
                return Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Filters',
                            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF11261B)),
                          ),
                          TextButton(
                            onPressed: () {
                              setModalState(() {
                                _selectedCategoryIds.clear();
                                _selectedBrandIds.clear();
                                _currentPriceRange = _maxPriceLimit;
                              });
                            },
                            child: const Text('Reset All', style: TextStyle(color: AppColors.brandOrange)),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Expanded(
                        child: ListView(
                          controller: scrollController,
                          children: [
                            // Price Range Slider
                            const Text(
                              'Price Range',
                              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Color(0xFF11261B)),
                            ),
                            const SizedBox(height: 8),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text('₹0', style: TextStyle(fontSize: 12, color: Colors.grey)),
                                Text('Up to ₹${_currentPriceRange.toStringAsFixed(0)}',
                                    style: const TextStyle(
                                        fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.primaryGreen)),
                              ],
                            ),
                            Slider(
                              value: _currentPriceRange,
                              min: 0,
                              max: _maxPriceLimit,
                              activeColor: AppColors.brandOrange,
                              inactiveColor: const Color(0xFFE4ECE8),
                              onChanged: (val) {
                                setModalState(() {
                                  _currentPriceRange = val;
                                });
                              },
                            ),
                            const SizedBox(height: 24),

                            // Categories Filter
                            const Text(
                              'Categories',
                              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Color(0xFF11261B)),
                            ),
                            const SizedBox(height: 12),
                            Wrap(
                              spacing: 8,
                              runSpacing: 8,
                              children: _categories.map((c) {
                                final catId = c['id'] as String;
                                final isSelected = _selectedCategoryIds.contains(catId);
                                return FilterChip(
                                  label: Text(c['name'] as String),
                                  selected: isSelected,
                                  selectedColor: AppColors.brandOrange.withOpacity(0.15),
                                  checkmarkColor: AppColors.brandOrange,
                                  onSelected: (val) {
                                    setModalState(() {
                                      if (val) {
                                        _selectedCategoryIds.add(catId);
                                      } else {
                                        _selectedCategoryIds.remove(catId);
                                      }
                                    });
                                  },
                                );
                              }).toList(),
                            ),
                            const SizedBox(height: 24),

                            // Brands Filter
                            const Text(
                              'Brands',
                              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Color(0xFF11261B)),
                            ),
                            const SizedBox(height: 12),
                            Wrap(
                              spacing: 8,
                              runSpacing: 8,
                              children: _brands.map((b) {
                                final brandId = b['id'] as String;
                                final isSelected = _selectedBrandIds.contains(brandId);
                                return FilterChip(
                                  label: Text(b['name'] as String),
                                  selected: isSelected,
                                  selectedColor: AppColors.brandOrange.withOpacity(0.15),
                                  checkmarkColor: AppColors.brandOrange,
                                  onSelected: (val) {
                                    setModalState(() {
                                      if (val) {
                                        _selectedBrandIds.add(brandId);
                                      } else {
                                        _selectedBrandIds.remove(brandId);
                                      }
                                    });
                                  },
                                );
                              }).toList(),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: () {
                          setState(() {}); // Trigger rebuild of ProductListScreen
                          Navigator.pop(bottomSheetCtx);
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.brandOrange,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          elevation: 0,
                        ),
                        child: const Text('APPLY FILTERS', style: TextStyle(fontWeight: FontWeight.bold)),
                      ),
                    ],
                  ),
                );
              },
            );
          },
        );
      },
    );
  }

  List<ProductModel> _processProducts(List<ProductModel> rawList) {
    // 1. Set max price limit dynamically from catalogue
    if (rawList.isNotEmpty && _maxPriceLimit == 200000) {
      final maxMrp = rawList.map((p) => p.sellingPrice).reduce((a, b) => a > b ? a : b);
      if (maxMrp > 0) {
        _maxPriceLimit = maxMrp;
        _currentPriceRange = maxMrp;
      }
    }

    // 2. Filter list
    var list = rawList.where((p) {
      final matchesSearch = p.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          (p.shortDescription ?? '').toLowerCase().contains(_searchQuery.toLowerCase());
      final matchesCategory = _selectedCategoryIds.isEmpty || _selectedCategoryIds.contains(p.categoryId);
      final matchesBrand = _selectedBrandIds.isEmpty || _selectedBrandIds.contains(p.brandId);
      final matchesPrice = p.sellingPrice <= _currentPriceRange;
      final isActive = p.status.toUpperCase() == 'ACTIVE';

      return matchesSearch && matchesCategory && matchesBrand && matchesPrice && isActive;
    }).toList();

    // 3. Sort list
    if (_sortBy == 'Price: Low to High') {
      list.sort((a, b) => a.sellingPrice.compareTo(b.sellingPrice));
    } else if (_sortBy == 'Price: High to Low') {
      list.sort((a, b) => b.sellingPrice.compareTo(a.sellingPrice));
    } else if (_sortBy == 'Newest') {
      list.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    }

    return list;
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<ProductBloc>()..add(const FetchProductsEvent()),
      child: Scaffold(
        backgroundColor: const Color(0xFFF3F6F4),
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          title: const Text(
            'Explore Products',
            style: TextStyle(
              color: Color(0xFF11261B),
              fontWeight: FontWeight.bold,
              fontSize: 18,
            ),
          ),
          centerTitle: true,
          iconTheme: const IconThemeData(color: Color(0xFF11261B)),
        ),
        body: Column(
          children: [
            // Search field Row
            _buildSearchBar(context),
            // Sorter and Filter triggers
            _buildSorterAndFilterBar(context),
            Expanded(
              child: BlocBuilder<ProductBloc, ProductState>(
                builder: (context, state) {
                  if (state is ProductLoading) {
                    return const Center(child: CircularProgressIndicator(color: AppColors.brandOrange));
                  } else if (state is ProductLoaded) {
                    final processedList = _processProducts(state.products);

                    if (processedList.isEmpty) {
                      return _buildEmptyState();
                    }

                    return RefreshIndicator(
                      color: AppColors.brandOrange,
                      backgroundColor: Colors.white,
                      onRefresh: () async {
                        context.read<ProductBloc>().add(const FetchProductsEvent(isRefresh: true));
                      },
                      child: GridView.builder(
                        padding: const EdgeInsets.all(16),
                        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          mainAxisSpacing: 16,
                          crossAxisSpacing: 16,
                          childAspectRatio: 0.75,
                        ),
                        itemCount: processedList.length,
                        itemBuilder: (context, index) {
                          final product = processedList[index];
                          return ProductCard(
                            product: product,
                            onTap: () => context.push('/products/details', extra: product),
                          );
                        },
                      ),
                    );
                  } else if (state is ProductError) {
                    return Center(
                      child: Padding(
                        padding: const EdgeInsets.all(24.0),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.error_outline, color: AppColors.brandRed, size: 48),
                            const SizedBox(height: 12),
                            Text(state.message, style: const TextStyle(color: Color(0xFF11261B))),
                            const SizedBox(height: 16),
                            ElevatedButton(
                              onPressed: () {
                                context.read<ProductBloc>().add(const FetchProductsEvent());
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.brandOrange,
                                foregroundColor: Colors.white,
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                              ),
                              child: const Text('Retry'),
                            ),
                          ],
                        ),
                      ),
                    );
                  }
                  return const SizedBox();
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchBar(BuildContext context) {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      child: TextField(
        controller: _searchController,
        onChanged: (val) {
          setState(() {
            _searchQuery = val.trim();
          });
        },
        decoration: InputDecoration(
          hintText: 'Search products...',
          hintStyle: const TextStyle(color: Colors.grey, fontSize: 13),
          prefixIcon: const Icon(Icons.search, color: Colors.grey, size: 20),
          suffixIcon: _searchQuery.isNotEmpty
              ? IconButton(
                  icon: const Icon(Icons.clear, size: 18),
                  onPressed: () {
                    _searchController.clear();
                    setState(() {
                      _searchQuery = '';
                    });
                  },
                )
              : null,
          filled: true,
          fillColor: const Color(0xFFF3F6F4),
          contentPadding: const EdgeInsets.symmetric(vertical: 0, horizontal: 16),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
        ),
      ),
    );
  }

  Widget _buildSorterAndFilterBar(BuildContext context) {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.only(left: 20, right: 20, bottom: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Sorter Dropdown
          DropdownButton<String>(
            value: _sortBy,
            underline: const SizedBox(),
            icon: const Icon(Icons.arrow_drop_down, color: AppColors.brandOrange, size: 20),
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: Color(0xFF11261B),
            ),
            items: <String>['Newest', 'Price: Low to High', 'Price: High to Low']
                .map<DropdownMenuItem<String>>((String value) {
              return DropdownMenuItem<String>(
                value: value,
                child: Text(value),
              );
            }).toList(),
            onChanged: (String? val) {
              if (val != null) {
                setState(() {
                  _sortBy = val;
                });
              }
            },
          ),
          // Filter Trigger Button
          OutlinedButton.icon(
            onPressed: _loadingFilters ? null : () => _openFilterBottomSheet(context),
            style: OutlinedButton.styleFrom(
              side: const BorderSide(color: Color(0xFFE4ECE8)),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 0),
            ),
            icon: const Icon(Icons.filter_list, size: 14, color: AppColors.brandOrange),
            label: const Text(
              'Filters',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.bold,
                color: Color(0xFF4C6656),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.shopping_bag_outlined, size: 64, color: Color(0xFFD1DDD6)),
          SizedBox(height: 16),
          Text(
            'No Match Found',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Color(0xFF11261B),
            ),
          ),
          SizedBox(height: 6),
          Text(
            'Try widening your filter configuration.',
            style: TextStyle(
              fontSize: 12,
              color: Color(0xFF4C6656),
            ),
          ),
        ],
      ),
    );
  }
}
