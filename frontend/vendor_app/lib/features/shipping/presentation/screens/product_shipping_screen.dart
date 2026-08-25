import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/dependency_injection/injection.dart';
import '../bloc/shipping_bloc.dart';
import '../bloc/shipping_event.dart';
import '../bloc/shipping_state.dart';
import '../../data/models/product_shipping_model.dart';
import '../widgets/shipping_card.dart';
import '../widgets/shipping_summary_card.dart';
import '../widgets/customer_shipping_preview.dart';
import '../widgets/shipping_empty_state.dart';

class ProductShippingScreen extends StatefulWidget {
  final String productId;
  final String? productName;

  const ProductShippingScreen({
    super.key,
    required this.productId,
    this.productName,
  });

  @override
  State<ProductShippingScreen> createState() => _ProductShippingScreenState();
}

class _ProductShippingScreenState extends State<ProductShippingScreen> {
  late ShippingBloc _shippingBloc;
  ProductShippingModel? _liveShippingModel;
  bool _isFormOpen = false;

  @override
  void initState() {
    super.initState();
    _shippingBloc = sl<ShippingBloc>();
    _shippingBloc.add(FetchShippingEvent(productId: widget.productId));
  }

  @override
  void dispose() {
    _shippingBloc.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: _shippingBloc,
      child: Scaffold(
        backgroundColor: const Color(0xFFF6F8F6),
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          title: const Text(
            'Shipping Management',
            style: TextStyle(
              color: Color(0xFF11261B),
              fontWeight: FontWeight.bold,
              fontSize: 18,
            ),
          ),
          centerTitle: true,
          iconTheme: const IconThemeData(color: Color(0xFF11261B)),
        ),
        body: BlocConsumer<ShippingBloc, ShippingState>(
          listener: (context, state) {
            if (state is ShippingLoaded) {
              if (state.shipping != null) {
                setState(() {
                  _liveShippingModel = state.shipping;
                  _isFormOpen = true;
                });
              }
            } else if (state is ShippingSaved) {
              setState(() {
                _liveShippingModel = state.shipping;
                _isFormOpen = true;
              });
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(state.message),
                  backgroundColor: AppColors.primaryGreen,
                  behavior: SnackBarBehavior.floating,
                ),
              );
            } else if (state is ShippingError) {
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
            if (state is ShippingLoading) {
              return const Center(
                child: CircularProgressIndicator(color: AppColors.primaryGreen),
              );
            }

            final isSaving = state is ShippingSaving;
            final ProductShippingModel? fetchedModel = state is ShippingLoaded
                ? state.shipping
                : state is ShippingSaved
                    ? state.shipping
                    : null;

            final activeModel = _liveShippingModel ?? fetchedModel;

            // Empty state check if shipping has never been configured
            if (activeModel == null && !_isFormOpen) {
              return Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    if (widget.productName != null && widget.productName!.isNotEmpty) ...[
                      _buildProductNameBanner(),
                      const SizedBox(height: 20),
                    ],
                    Expanded(
                      child: Center(
                        child: ShippingEmptyState(
                          onConfigure: () {
                            setState(() {
                              _isFormOpen = true;
                              _liveShippingModel = ProductShippingModel(productId: widget.productId);
                            });
                          },
                        ),
                      ),
                    ),
                  ],
                ),
              );
            }

            final displayShipping = activeModel ?? ProductShippingModel(productId: widget.productId);

            return SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (widget.productName != null && widget.productName!.isNotEmpty) ...[
                    _buildProductNameBanner(),
                    const SizedBox(height: 16),
                  ],

                  // 1. Shipping Summary Card (Top Overview)
                  ShippingSummaryCard(shipping: displayShipping),
                  const SizedBox(height: 16),

                  // 2. Customer Shipping Live Preview Card
                  CustomerShippingPreview(shipping: displayShipping),
                  const SizedBox(height: 20),

                  // 3. Shipping Configuration Form Card (Live updates)
                  ShippingCard(
                    initialShipping: fetchedModel ?? displayShipping,
                    productId: widget.productId,
                    isSaving: isSaving,
                    onChanged: (liveModel) {
                      setState(() {
                        _liveShippingModel = liveModel;
                      });
                    },
                    onSave: (shipping) {
                      _shippingBloc.add(SaveShippingEvent(productId: widget.productId, shipping: shipping));
                    },
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildProductNameBanner() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE4ECE8)),
      ),
      child: Row(
        children: [
          const Icon(Icons.shopping_bag_outlined, color: AppColors.primaryGreen, size: 20),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Configuring Shipping For:',
                  style: TextStyle(fontSize: 11, color: Colors.grey, fontWeight: FontWeight.w500),
                ),
                const SizedBox(height: 2),
                Text(
                  widget.productName!,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF11261B),
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
