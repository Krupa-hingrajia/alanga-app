import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/dependency_injection/injection.dart';
import '../../data/models/vendor_order_model.dart';
import '../bloc/vendor_order_bloc.dart';
import '../bloc/vendor_order_event.dart';
import '../bloc/vendor_order_state.dart';
import '../widgets/vendor_order_card.dart';

class VendorOrderListScreen extends StatefulWidget {
  final VoidCallback? onBackToDashboard;

  const VendorOrderListScreen({super.key, this.onBackToDashboard});

  @override
  State<VendorOrderListScreen> createState() => _VendorOrderListScreenState();
}

class _VendorOrderListScreenState extends State<VendorOrderListScreen> {
  final TextEditingController _searchCtrl = TextEditingController();

  final List<_StatusFilterMeta> _filters = const [
    _StatusFilterMeta(label: 'All', statusKey: null),
    _StatusFilterMeta(label: 'Pending', statusKey: 'PENDING', color: Color(0xFFB45309)),
    _StatusFilterMeta(label: 'Confirmed', statusKey: 'CONFIRMED', color: Color(0xFF0F766E)),
    _StatusFilterMeta(label: 'Processing', statusKey: 'PROCESSING', color: Color(0xFF1D4ED8)),
    _StatusFilterMeta(label: 'Packed', statusKey: 'PACKED', color: Color(0xFF7E22CE)),
    _StatusFilterMeta(label: 'Shipped', statusKey: 'SHIPPED', color: Color(0xFF4338CA)),
    _StatusFilterMeta(label: 'Delivered', statusKey: 'DELIVERED', color: Color(0xFF15803D)),
    _StatusFilterMeta(label: 'Cancelled', statusKey: 'CANCELLED', color: Color(0xFFB91C1C)),
  ];

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  void _handleBack(BuildContext context) {
    if (widget.onBackToDashboard != null) {
      widget.onBackToDashboard!();
    } else if (context.canPop()) {
      context.pop();
    } else {
      context.go('/home');
    }
  }

  void _showQuickStatusConfirmDialog(
    BuildContext context,
    VendorOrderBloc bloc,
    VendorOrderModel order,
  ) {
    final nextStatus = order.nextValidStatus;
    final actionLabel = order.nextStatusActionLabel;
    if (nextStatus == null || actionLabel == null) return;

    showDialog(
      context: context,
      builder: (dialogCtx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.primaryGreen.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.sync_alt_rounded, color: AppColors.primaryGreen, size: 22),
            ),
            const SizedBox(width: 12),
            const Expanded(
              child: Text(
                'Update Status',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Advance order #${order.orderNumber} to:',
              style: const TextStyle(fontSize: 14, color: Color(0xFF4B5563)),
            ),
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: const Color(0xFFF3F4F6),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                children: [
                  Text(
                    order.status,
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                  ),
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 8),
                    child: Icon(Icons.arrow_forward_rounded, size: 16, color: Colors.grey),
                  ),
                  Text(
                    nextStatus,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                      color: AppColors.primaryGreen,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            const Text(
              'Are you sure you want to proceed?',
              style: TextStyle(fontSize: 13, color: Color(0xFF6B7280)),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogCtx).pop(),
            child: const Text('Cancel', style: TextStyle(color: Color(0xFF6B7280))),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(dialogCtx).pop();
              bloc.add(UpdateOrderStatusEvent(
                orderId: order.id,
                newStatus: nextStatus,
              ));
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryGreen,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            child: Text(actionLabel),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<VendorOrderBloc>()..add(const FetchVendorOrdersEvent()),
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
              appBar: AppBar(
                backgroundColor: Colors.transparent,
                elevation: 0,
                scrolledUnderElevation: 0,
                leading: IconButton(
                  icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Color(0xFF11261B), size: 20),
                  tooltip: 'Back to Dashboard',
                  onPressed: () => _handleBack(context),
                ),
                title: const Text(
                  'Order Management',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF11261B),
                  ),
                ),
          actions: [
            BlocBuilder<VendorOrderBloc, VendorOrderState>(
              builder: (context, state) {
                return IconButton(
                  icon: const Icon(Icons.refresh_rounded, color: Color(0xFF1A3827)),
                  tooltip: 'Refresh Orders',
                  onPressed: () {
                    context.read<VendorOrderBloc>().add(const FetchVendorOrdersEvent(isRefresh: true));
                  },
                );
              },
            ),
            const SizedBox(width: 8),
          ],
        ),
        body: BlocConsumer<VendorOrderBloc, VendorOrderState>(
          listener: (context, state) {
            if (state is VendorOrderLoaded) {
              if (state.actionMessage != null) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(state.actionMessage!),
                    backgroundColor: AppColors.primaryGreen,
                    behavior: SnackBarBehavior.floating,
                  ),
                );
              } else if (state.errorMessage != null) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(state.errorMessage!),
                    backgroundColor: AppColors.brandRed,
                    behavior: SnackBarBehavior.floating,
                  ),
                );
              }
            } else if (state is VendorOrderError) {
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
            final bloc = context.read<VendorOrderBloc>();

            return Column(
              children: [
                // ── Search Bar ─────────────────────────────────────────
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: const Color(0xFFE4ECE8)),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.03),
                          blurRadius: 10,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: TextField(
                      controller: _searchCtrl,
                      onChanged: (val) {
                        bloc.add(SearchOrdersEvent(query: val));
                      },
                      decoration: InputDecoration(
                        hintText: 'Search order #, customer, product...',
                        hintStyle: const TextStyle(fontSize: 13, color: Color(0xFF9CA3AF)),
                        prefixIcon: const Icon(Icons.search_rounded, color: Color(0xFF1A3827), size: 22),
                        suffixIcon: _searchCtrl.text.isNotEmpty
                            ? IconButton(
                                icon: const Icon(Icons.clear, size: 18, color: Color(0xFF9CA3AF)),
                                onPressed: () {
                                  _searchCtrl.clear();
                                  bloc.add(const SearchOrdersEvent(query: ''));
                                },
                              )
                            : null,
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                      ),
                    ),
                  ),
                ),

                // ── Status Filter Chips Strip ─────────────────────────
                SizedBox(
                  height: 48,
                  child: ListView.separated(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                    scrollDirection: Axis.horizontal,
                    physics: const BouncingScrollPhysics(),
                    itemCount: _filters.length,
                    separatorBuilder: (context, index) => const SizedBox(width: 8),
                    itemBuilder: (context, index) {
                      final f = _filters[index];
                      final selectedStatus = (state is VendorOrderLoaded) ? state.selectedStatus : null;
                      final isSelected = selectedStatus == f.statusKey;

                      int count = 0;
                      if (state is VendorOrderLoaded) {
                        if (f.statusKey == null) {
                          count = state.statusCounts['ALL'] ?? 0;
                        } else {
                          count = state.statusCounts[f.statusKey!] ?? 0;
                        }
                      }

                      return FilterChip(
                        selected: isSelected,
                        showCheckmark: false,
                        label: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(f.label),
                            const SizedBox(width: 6),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: isSelected
                                    ? Colors.white.withValues(alpha: 0.25)
                                    : const Color(0xFFE2E8F0),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Text(
                                '$count',
                                style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                  color: isSelected ? Colors.white : const Color(0xFF475569),
                                ),
                              ),
                            ),
                          ],
                        ),
                        labelStyle: TextStyle(
                          fontSize: 12,
                          fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                          color: isSelected ? Colors.white : const Color(0xFF334155),
                        ),
                        backgroundColor: Colors.white,
                        selectedColor: AppColors.primaryGreen,
                        side: BorderSide(
                          color: isSelected ? AppColors.primaryGreen : const Color(0xFFE4ECE8),
                        ),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                        onSelected: (_) {
                          bloc.add(FilterOrdersByStatusEvent(status: f.statusKey));
                        },
                      );
                    },
                  ),
                ),
                const SizedBox(height: 6),

                // ── Order List / Shimmer / Empty ──────────────────────
                Expanded(
                  child: _buildOrderContent(context, state, bloc),
                ),
              ],
            );
          },
        ),
      ),
    );
  },
),
);
  }

  Widget _buildOrderContent(
    BuildContext context,
    VendorOrderState state,
    VendorOrderBloc bloc,
  ) {
    if (state is VendorOrderLoading) {
      return const Center(
        child: CircularProgressIndicator(color: Color(0xFF1A3827)),
      );
    }

    if (state is VendorOrderError) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.error_outline_rounded, size: 54, color: AppColors.brandRed),
              const SizedBox(height: 12),
              Text(
                state.message,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 14, color: Color(0xFF4B5563)),
              ),
              const SizedBox(height: 16),
              ElevatedButton.icon(
                onPressed: () => bloc.add(const FetchVendorOrdersEvent(isRefresh: true)),
                icon: const Icon(Icons.refresh, size: 18),
                label: const Text('Try Again'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryGreen,
                  foregroundColor: Colors.white,
                ),
              ),
            ],
          ),
        ),
      );
    }

    if (state is VendorOrderLoaded) {
      final orders = state.filteredOrders;

      if (orders.isEmpty) {
        return RefreshIndicator(
          onRefresh: () async {
            bloc.add(const FetchVendorOrdersEvent(isRefresh: true));
          },
          color: AppColors.primaryGreen,
          child: ListView(
            physics: const AlwaysScrollableScrollPhysics(),
            children: [
              SizedBox(height: MediaQuery.of(context).size.height * 0.15),
              Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        color: const Color(0xFF1A3827).withValues(alpha: 0.08),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.receipt_long_outlined,
                        size: 40,
                        color: Color(0xFF1A3827),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      state.searchQuery.isNotEmpty
                          ? 'No matching orders found'
                          : state.selectedStatus != null
                              ? 'No ${state.selectedStatus!.toLowerCase()} orders'
                              : 'No orders received yet',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1F2937),
                      ),
                    ),
                    const SizedBox(height: 6),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 40),
                      child: Text(
                        state.searchQuery.isNotEmpty
                            ? 'Try searching with a different order number or customer name.'
                            : 'Orders containing your products will appear here when placed by customers.',
                        textAlign: TextAlign.center,
                        style: const TextStyle(fontSize: 13, color: Color(0xFF6B7280)),
                      ),
                    ),
                    const SizedBox(height: 20),
                    if (state.searchQuery.isNotEmpty || state.selectedStatus != null)
                      TextButton.icon(
                        onPressed: () {
                          _searchCtrl.clear();
                          bloc.add(const SearchOrdersEvent(query: ''));
                          bloc.add(const FilterOrdersByStatusEvent(status: null));
                        },
                        icon: const Icon(Icons.filter_alt_off_rounded, size: 18),
                        label: const Text('Clear All Filters'),
                        style: TextButton.styleFrom(
                          foregroundColor: AppColors.primaryGreen,
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
        );
      }

      return RefreshIndicator(
        onRefresh: () async {
          bloc.add(const FetchVendorOrdersEvent(isRefresh: true));
        },
        color: AppColors.primaryGreen,
        child: ListView.builder(
          padding: const EdgeInsets.fromLTRB(16, 4, 16, 80),
          physics: const AlwaysScrollableScrollPhysics(),
          itemCount: orders.length,
          itemBuilder: (context, index) {
            final order = orders[index];
            final isUpdatingThis = state.isUpdating && state.updatingOrderId == order.id;

            return VendorOrderCard(
              order: order,
              isUpdating: isUpdatingThis,
              onTap: () async {
                await context.push('/orders/details', extra: order);
                if (mounted) {
                  bloc.add(const FetchVendorOrdersEvent(isRefresh: true));
                }
              },
              onQuickAdvanceStatus: () {
                _showQuickStatusConfirmDialog(context, bloc, order);
              },
            );
          },
        ),
      );
    }

    return const SizedBox.shrink();
  }
}

class _StatusFilterMeta {
  final String label;
  final String? statusKey;
  final Color? color;

  const _StatusFilterMeta({
    required this.label,
    required this.statusKey,
    this.color,
  });
}
