import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/dependency_injection/injection.dart';
import '../bloc/inventory_bloc.dart';
import '../bloc/inventory_event.dart';
import '../bloc/inventory_state.dart';
import '../../data/models/inventory_model.dart';
import '../widgets/inventory_card.dart';
import '../widgets/update_inventory_bottom_sheet.dart';
import '../widgets/inventory_history_bottom_sheet.dart';

class ProductInventoryScreen extends StatefulWidget {
  final String productId;
  final String? productName;

  const ProductInventoryScreen({
    super.key,
    required this.productId,
    this.productName,
  });

  @override
  State<ProductInventoryScreen> createState() => _ProductInventoryScreenState();
}

class _ProductInventoryScreenState extends State<ProductInventoryScreen> {
  late InventoryBloc _inventoryBloc;
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _inventoryBloc = sl<InventoryBloc>();
    _inventoryBloc.add(FetchProductInventoryEvent(productId: widget.productId));
  }

  @override
  void dispose() {
    _searchController.dispose();
    _inventoryBloc.close();
    super.dispose();
  }

  void _onUpdateStockTap(InventoryModel inventory) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return UpdateInventoryBottomSheet(
          inventory: inventory,
          onSave: (currentStock, minimumStock, remarks) {
            Navigator.of(ctx).pop();
            _inventoryBloc.add(
              UpdateVariantInventoryEvent(
                productId: widget.productId,
                variantId: inventory.variant.id,
                currentStock: currentStock,
                minimumStock: minimumStock,
                remarks: remarks,
              ),
            );
          },
        );
      },
    );
  }

  void _onHistoryTap(InventoryModel inventory) {
    _inventoryBloc.add(
      FetchVariantHistoryEvent(
        productId: widget.productId,
        variantId: inventory.variant.id,
      ),
    );

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return BlocProvider.value(
          value: _inventoryBloc,
          child: BlocBuilder<InventoryBloc, InventoryState>(
            builder: (context, state) {
              if (state is InventoryHistoryLoading) {
                return Container(
                  height: 300,
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
                  ),
                  child: const Center(
                    child: CircularProgressIndicator(color: AppColors.primaryGreen),
                  ),
                );
              }

              if (state is InventoryHistoryLoaded) {
                return InventoryHistoryBottomSheet(
                  variantName: inventory.variant.variantName,
                  sku: inventory.sku,
                  history: state.history,
                );
              }

              return Container(
                height: 250,
                padding: const EdgeInsets.all(20),
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
                ),
                child: Center(
                  child: Text(
                    state is InventoryError ? state.message : 'Loading history...',
                    style: const TextStyle(color: Colors.red),
                  ),
                ),
              );
            },
          ),
        );
      },
    ).then((_) {
      // Re-fetch inventory list after closing history bottom sheet
      _inventoryBloc.add(FetchProductInventoryEvent(productId: widget.productId, isRefresh: true));
    });
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: _inventoryBloc,
      child: Scaffold(
        backgroundColor: const Color(0xFFF6F8F6),
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          title: const Text(
            'Inventory Management',
            style: TextStyle(
              color: Color(0xFF11261B),
              fontWeight: FontWeight.bold,
              fontSize: 18,
            ),
          ),
          centerTitle: true,
          iconTheme: const IconThemeData(color: Color(0xFF11261B)),
        ),
        body: BlocConsumer<InventoryBloc, InventoryState>(
          listener: (context, state) {
            if (state is InventoryUpdated) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(state.message),
                  backgroundColor: AppColors.primaryGreen,
                  behavior: SnackBarBehavior.floating,
                ),
              );
            } else if (state is InventoryError) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(state.message),
                  backgroundColor: AppColors.brandRed,
                  behavior: SnackBarBehavior.floating,
                ),
              );
            }
          },
          builder: (context, state) {
            return Column(
              children: [
                // Product Header Banner & Search Box Container
                Container(
                  color: Colors.white,
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (widget.productName != null && widget.productName!.isNotEmpty) ...[
                        Row(
                          children: [
                            const Icon(Icons.shopping_bag_outlined, size: 18, color: AppColors.primaryGreen),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                widget.productName!,
                                style: const TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF11261B),
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                      ],

                      // Search TextField
                      TextField(
                        controller: _searchController,
                        onChanged: (val) {
                          _inventoryBloc.add(SearchInventoryEvent(query: val));
                        },
                        decoration: InputDecoration(
                          hintText: 'Search by SKU or Variant Name...',
                          hintStyle: const TextStyle(fontSize: 13, color: Colors.grey),
                          prefixIcon: const Icon(Icons.search_rounded, color: AppColors.primaryGreen, size: 20),
                          suffixIcon: _searchController.text.isNotEmpty
                              ? IconButton(
                                  icon: const Icon(Icons.clear_rounded, size: 18, color: Colors.grey),
                                  onPressed: () {
                                    _searchController.clear();
                                    _inventoryBloc.add(const SearchInventoryEvent(query: ''));
                                  },
                                )
                              : null,
                          filled: true,
                          fillColor: const Color(0xFFF6F8F6),
                          contentPadding: const EdgeInsets.symmetric(vertical: 10),
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
                    ],
                  ),
                ),

                // Main Content List
                Expanded(
                  child: RefreshIndicator(
                    color: AppColors.primaryGreen,
                    onRefresh: () async {
                      _inventoryBloc.add(FetchProductInventoryEvent(productId: widget.productId, isRefresh: true));
                    },
                    child: _buildBody(state),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildBody(InventoryState state) {
    if (state is InventoryLoading) {
      return const Center(
        child: CircularProgressIndicator(color: AppColors.primaryGreen),
      );
    }

    if (state is InventoryLoaded) {
      final items = state.filteredInventories;

      if (items.isEmpty) {
        return ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          children: [
            SizedBox(height: MediaQuery.of(context).size.height * 0.2),
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF4F8F5),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.inventory_2_outlined, size: 48, color: AppColors.primaryGreen),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    state.searchQuery.isNotEmpty
                        ? 'No variants found matching "${state.searchQuery}"'
                        : 'No variants or inventory found for this product.',
                    style: const TextStyle(
                      fontSize: 14,
                      color: Color(0xFF4C6656),
                      fontWeight: FontWeight.w500,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ],
        );
      }

      return ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: items.length,
        separatorBuilder: (_, __) => const SizedBox(height: 14),
        itemBuilder: (context, index) {
          final inventory = items[index];
          return InventoryCard(
            inventory: inventory,
            onUpdateTap: () => _onUpdateStockTap(inventory),
            onHistoryTap: () => _onHistoryTap(inventory),
          );
        },
      );
    }

    if (state is InventoryError) {
      return ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        children: [
          SizedBox(height: MediaQuery.of(context).size.height * 0.25),
          Center(
            child: Column(
              children: [
                const Icon(Icons.error_outline_rounded, size: 48, color: AppColors.brandRed),
                const SizedBox(height: 12),
                Text(
                  state.message,
                  style: const TextStyle(color: AppColors.brandRed, fontSize: 14),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                ElevatedButton.icon(
                  onPressed: () {
                    _inventoryBloc.add(FetchProductInventoryEvent(productId: widget.productId));
                  },
                  icon: const Icon(Icons.refresh_rounded, size: 18),
                  label: const Text('Try Again'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryGreen,
                    foregroundColor: Colors.white,
                  ),
                ),
              ],
            ),
          ),
        ],
      );
    }

    return const SizedBox.shrink();
  }
}
