import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/widgets/custom_image_view.dart';
import '../../../addresses/data/models/address_model.dart';
import '../../../addresses/presentation/bloc/address_cubit.dart';
import '../../../addresses/presentation/bloc/address_state.dart';
import '../../../addresses/presentation/widgets/add_edit_address_bottom_sheet.dart';
import '../../../addresses/presentation/widgets/default_badge.dart';
import '../../../cart/presentation/bloc/cart_cubit.dart';
import '../../data/models/checkout_summary_model.dart';
import '../bloc/checkout_cubit.dart';
import '../bloc/checkout_state.dart';

class CheckoutScreen extends StatefulWidget {
  const CheckoutScreen({super.key});

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  final TextEditingController _notesController = TextEditingController();
  bool _isPlacingOrder = false;

  @override
  void initState() {
    super.initState();
    context.read<CheckoutCubit>().fetchCheckoutSummary();
    context.read<AddressCubit>().fetchAddresses();
  }

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _handlePlaceOrder(AddressModel? selectedAddress, CheckoutSummaryModel summary) async {
    // 1. Validation: No Address Selected
    if (selectedAddress == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Row(
            children: [
              Icon(Icons.location_off_rounded, color: Colors.white, size: 20),
              SizedBox(width: 10),
              Expanded(
                child: Text(
                  'No Address Selected: Please add or select a delivery address.',
                  style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
                ),
              ),
            ],
          ),
          backgroundColor: AppColors.brandRed,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          duration: const Duration(seconds: 4),
        ),
      );
      return;
    }

    // 2. Validation: Out of Stock
    if (summary.hasOutOfStockItems) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Row(
            children: [
              Icon(Icons.inventory_2_outlined, color: Colors.white, size: 20),
              SizedBox(width: 10),
              Expanded(
                child: Text(
                  'Out of Stock: Some items in your cart are unavailable. Please remove them before checkout.',
                  style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
                ),
              ),
            ],
          ),
          backgroundColor: AppColors.brandRed,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          duration: const Duration(seconds: 4),
        ),
      );
      return;
    }

    setState(() => _isPlacingOrder = true);

    try {
      await context.read<CheckoutCubit>().placeOrder(
            addressId: selectedAddress.id,
            paymentMethod: 'COD',
            notes: _notesController.text.trim().isNotEmpty ? _notesController.text.trim() : null,
          );

      // Refresh cart count across the app
      if (mounted) {
        context.read<CartCubit>().fetchCart();
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isPlacingOrder = false);
        final errorMessage = e.toString().replaceAll('Exception: ', '');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.error_outline_rounded, color: Colors.white, size: 20),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    errorMessage,
                    style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 13),
                  ),
                ),
              ],
            ),
            backgroundColor: AppColors.brandRed,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            duration: const Duration(seconds: 4),
          ),
        );
      }
    }
  }

  void _showAddressSelectionModal(BuildContext context, List<AddressModel> addresses, AddressModel? currentSelected) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (modalContext) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Row(
                      children: [
                        Icon(Icons.location_on_outlined, color: AppColors.primaryGreen, size: 22),
                        SizedBox(width: 8),
                        Text(
                          'Select Delivery Address',
                          style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold, color: Color(0xFF11261B)),
                        ),
                      ],
                    ),
                    IconButton(
                      icon: const Icon(Icons.close_rounded, size: 20),
                      onPressed: () => Navigator.pop(modalContext),
                    ),
                  ],
                ),
                const Divider(height: 16),
                if (addresses.isEmpty)
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 24),
                    child: Center(
                      child: Text(
                        'No addresses saved yet. Add a new address below.',
                        style: TextStyle(color: Colors.grey, fontSize: 13),
                      ),
                    ),
                  )
                else
                  Flexible(
                    child: ListView.builder(
                      shrinkWrap: true,
                      itemCount: addresses.length,
                      itemBuilder: (ctx, idx) {
                        final addr = addresses[idx];
                        final isSelected = currentSelected?.id == addr.id;
                        return InkWell(
                          onTap: () {
                            context.read<AddressCubit>().selectAddress(addr);
                            Navigator.pop(modalContext);
                          },
                          borderRadius: BorderRadius.circular(14),
                          child: Container(
                            margin: const EdgeInsets.only(bottom: 12),
                            padding: const EdgeInsets.all(14),
                            decoration: BoxDecoration(
                              color: isSelected ? AppColors.primaryGreen.withValues(alpha: 0.04) : Colors.white,
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(
                                color: isSelected ? AppColors.primaryGreen : const Color(0xFFE4ECE8),
                                width: isSelected ? 1.8 : 1,
                              ),
                            ),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Padding(
                                  padding: const EdgeInsets.only(top: 2),
                                  child: Icon(
                                    isSelected ? Icons.radio_button_checked_rounded : Icons.radio_button_off_rounded,
                                    color: isSelected ? AppColors.primaryGreen : Colors.grey.shade400,
                                    size: 20,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          Text(
                                            addr.fullName,
                                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Color(0xFF11261B)),
                                          ),
                                          const SizedBox(width: 8),
                                          Container(
                                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                            decoration: BoxDecoration(
                                              color: const Color(0xFFEBF3EE),
                                              borderRadius: BorderRadius.circular(4),
                                            ),
                                            child: Text(
                                              addr.addressType,
                                              style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: AppColors.darkGreen),
                                            ),
                                          ),
                                          if (addr.isDefault) ...[
                                            const SizedBox(width: 6),
                                            const DefaultBadge(compact: true),
                                          ],
                                        ],
                                      ),
                                      const SizedBox(height: 6),
                                      Text(
                                        addr.formattedAddress,
                                        style: const TextStyle(fontSize: 12, color: Color(0xFF5A7265), height: 1.3),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        'Phone: ${addr.mobileNumber}',
                                        style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Color(0xFF11261B)),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  height: 46,
                  child: OutlinedButton.icon(
                    onPressed: () {
                      Navigator.pop(modalContext);
                      showModalBottomSheet(
                        context: context,
                        isScrollControlled: true,
                        backgroundColor: Colors.transparent,
                        builder: (_) => const AddEditAddressBottomSheet(),
                      );
                    },
                    icon: const Icon(Icons.add_rounded, size: 20),
                    label: const Text(
                      'ADD NEW ADDRESS',
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, letterSpacing: 0.5),
                    ),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.primaryGreen,
                      side: const BorderSide(color: AppColors.primaryGreen, width: 1.5),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F7F5),
      appBar: AppBar(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.transparent,
        elevation: 0.5,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 18, color: Color(0xFF11261B)),
          onPressed: () => context.pop(),
        ),
        title: const Text(
          'Order Checkout',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Color(0xFF11261B),
          ),
        ),
        centerTitle: true,
      ),
      body: BlocListener<CheckoutCubit, CheckoutState>(
        listener: (context, state) {
          if (state is PlaceOrderSuccess) {
            context.pushReplacement('/order-success', extra: state.order);
          }
        },
        child: BlocBuilder<CheckoutCubit, CheckoutState>(
          builder: (context, checkoutState) {
            if (checkoutState is CheckoutLoading) {
              return const Center(
                child: CircularProgressIndicator(color: AppColors.primaryGreen),
              );
            }

            if (checkoutState is CheckoutError) {
              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(28),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: AppColors.brandRed.withValues(alpha: 0.1),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.wifi_off_rounded, color: AppColors.brandRed, size: 40),
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        'Unable to Load Checkout',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF11261B)),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        checkoutState.message,
                        textAlign: TextAlign.center,
                        style: const TextStyle(fontSize: 13, color: Color(0xFF5A7265)),
                      ),
                      const SizedBox(height: 20),
                      ElevatedButton.icon(
                        onPressed: () => context.read<CheckoutCubit>().fetchCheckoutSummary(),
                        icon: const Icon(Icons.refresh_rounded, size: 18),
                        label: const Text('Try Again'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primaryGreen,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }

            CheckoutSummaryModel? summary;
            if (checkoutState is CheckoutLoaded) {
              summary = checkoutState.summary;
            } else if (checkoutState is PlaceOrderLoading) {
              summary = checkoutState.summary;
            }

            if (summary == null) return const SizedBox.shrink();

            return BlocBuilder<AddressCubit, AddressState>(
              builder: (context, addressState) {
                AddressModel? selectedAddress;
                List<AddressModel> addressesList = [];

                if (addressState is AddressLoaded) {
                  addressesList = addressState.addresses;
                  selectedAddress = addressState.selectedAddress ?? summary?.defaultAddress;
                } else {
                  selectedAddress = summary?.defaultAddress;
                }

                return Column(
                  children: [
                    Expanded(
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // SECTION 1: Delivery Address
                            _buildSection1DeliveryAddress(context, selectedAddress, addressesList),
                            const SizedBox(height: 16),

                            // SECTION 2: Order Items
                            _buildSection2OrderItems(summary!),
                            const SizedBox(height: 16),

                            // SECTION 3: Shipping Summary
                            _buildSection3ShippingSummary(summary),
                            const SizedBox(height: 16),

                            // SECTION 4: Price Details (Amazon / Flipkart style card)
                            _buildSection4PriceDetails(summary),
                            const SizedBox(height: 16),

                            // SECTION 5: Payment Method
                            _buildSection5PaymentMethod(),
                            const SizedBox(height: 16),

                            // SECTION 6: Order Notes (Optional)
                            _buildSection6OrderNotes(),
                            const SizedBox(height: 16),
                          ],
                        ),
                      ),
                    ),

                    // SECTION 7: Sticky Bottom Bar
                    _buildSection7StickyBottomBar(context, selectedAddress, summary),
                  ],
                );
              },
            );
          },
        ),
      ),
    );
  }

  // ==========================================
  // SECTION 1: DELIVERY ADDRESS
  // ==========================================
  Widget _buildSection1DeliveryAddress(BuildContext context, AddressModel? selectedAddress, List<AddressModel> addresses) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Row(
                children: [
                  Icon(Icons.location_on_rounded, color: AppColors.primaryGreen, size: 20),
                  SizedBox(width: 8),
                  Text(
                    'Delivery Address',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF11261B),
                    ),
                  ),
                ],
              ),
              if (selectedAddress != null)
                TextButton(
                  onPressed: () => _showAddressSelectionModal(context, addresses, selectedAddress),
                  style: TextButton.styleFrom(
                    foregroundColor: AppColors.primaryGreen,
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    visualDensity: VisualDensity.compact,
                  ),
                  child: const Text(
                    'CHANGE',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, letterSpacing: 0.5),
                  ),
                ),
            ],
          ),
          const Divider(height: 16, color: Color(0xFFEEF3F0)),
          if (selectedAddress == null) ...[
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: const Color(0xFFFFFBEB),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFFFDE68A)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.warning_amber_rounded, color: Color(0xFFD97706), size: 24),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'No Address Selected',
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Color(0xFFB45309)),
                        ),
                        SizedBox(height: 2),
                        Text(
                          'Please add a delivery address to complete checkout.',
                          style: TextStyle(fontSize: 11, color: Color(0xFF92400E)),
                        ),
                      ],
                    ),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      showModalBottomSheet(
                        context: context,
                        isScrollControlled: true,
                        backgroundColor: Colors.transparent,
                        builder: (_) => const AddEditAddressBottomSheet(),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFD97706),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      elevation: 0,
                    ),
                    child: const Text('ADD ADDRESS', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
                  ),
                ],
              ),
            ),
          ] else ...[
            Row(
              children: [
                Text(
                  selectedAddress.fullName,
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: Color(0xFF11261B)),
                ),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: const Color(0xFFEBF3EE),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    selectedAddress.addressType,
                    style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: AppColors.darkGreen),
                  ),
                ),
                if (selectedAddress.isDefault) ...[
                  const SizedBox(width: 6),
                  const DefaultBadge(compact: true),
                ],
              ],
            ),
            const SizedBox(height: 6),
            Text(
              selectedAddress.formattedAddress,
              style: const TextStyle(fontSize: 13, color: Color(0xFF4C6656), height: 1.35),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                const Icon(Icons.phone_outlined, size: 14, color: AppColors.primaryGreen),
                const SizedBox(width: 6),
                Text(
                  selectedAddress.mobileNumber,
                  style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Color(0xFF11261B)),
                ),
                if (selectedAddress.alternateMobile != null && selectedAddress.alternateMobile!.isNotEmpty) ...[
                  Text(
                    ' / ${selectedAddress.alternateMobile}',
                    style: const TextStyle(fontSize: 12, color: Color(0xFF5A7265)),
                  ),
                ],
              ],
            ),
          ],
        ],
      ),
    );
  }

  // ==========================================
  // SECTION 2: ORDER ITEMS
  // ==========================================
  Widget _buildSection2OrderItems(CheckoutSummaryModel summary) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Row(
                children: [
                  Icon(Icons.shopping_bag_outlined, color: AppColors.primaryGreen, size: 20),
                  SizedBox(width: 8),
                  Text(
                    'Order Items',
                    style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Color(0xFF11261B)),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: const Color(0xFFF1F5F3),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  '${summary.itemCount} ${summary.itemCount == 1 ? "item" : "items"}',
                  style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: Color(0xFF4C6656)),
                ),
              ),
            ],
          ),
          const Divider(height: 16, color: Color(0xFFEEF3F0)),
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: summary.items.length,
            separatorBuilder: (context, index) => const Divider(height: 20, color: Color(0xFFF0F4F2)),
            itemBuilder: (context, index) {
              final item = summary.items[index];
              return Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Product Image
                  Container(
                    width: 68,
                    height: 68,
                    decoration: BoxDecoration(
                      color: const Color(0xFFF7FAF8),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: const Color(0xFFE6EFEA)),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: CustomImageView(
                        imageUrl: item.imageUrl,
                        fit: BoxFit.cover,
                        placeholderIcon: Icons.shopping_bag_outlined,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  // Item details
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          item.productName,
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF11261B),
                            height: 1.25,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        // Selected Variant
                        if (item.variantName.isNotEmpty && item.variantName != 'Default Variant') ...[
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1.5),
                            decoration: BoxDecoration(
                              color: const Color(0xFFF1F5F3),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              'Variant: ${item.variantName}',
                              style: const TextStyle(fontSize: 10.5, fontWeight: FontWeight.w600, color: Color(0xFF4C6656)),
                            ),
                          ),
                          const SizedBox(height: 3),
                        ],
                        // SKU
                        if (item.sku.isNotEmpty)
                          Text(
                            'SKU: ${item.sku}',
                            style: const TextStyle(fontSize: 10.5, color: Colors.grey),
                          ),
                        const SizedBox(height: 6),
                        // Quantity & Price & Item Total
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              '₹${item.unitPrice.toStringAsFixed(0)} × ${item.quantity}',
                              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Color(0xFF5A7265)),
                            ),
                            Text(
                              '₹${item.itemSubtotal.toStringAsFixed(0)}',
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: AppColors.primaryGreen,
                              ),
                            ),
                          ],
                        ),
                        // Out of Stock warning badge
                        if (item.isOutOfStock) ...[
                          const SizedBox(height: 4),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: AppColors.brandRed.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: const Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.cancel_outlined, size: 12, color: AppColors.brandRed),
                                SizedBox(width: 4),
                                Text(
                                  'Out of Stock',
                                  style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: AppColors.brandRed),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }

  // ==========================================
  // SECTION 3: SHIPPING SUMMARY
  // ==========================================
  Widget _buildSection3ShippingSummary(CheckoutSummaryModel summary) {
    final isFree = summary.shippingCharge <= 0;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.local_shipping_outlined, color: AppColors.primaryGreen, size: 20),
              SizedBox(width: 8),
              Text(
                'Shipping Summary',
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Color(0xFF11261B)),
              ),
            ],
          ),
          const Divider(height: 16, color: Color(0xFFEEF3F0)),
          _buildSummaryRow(
            label: 'Shipping Method',
            valueWidget: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: AppColors.primaryGreen.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: const Text(
                    'Standard Delivery',
                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.primaryGreen),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),
          _buildSummaryRow(
            label: 'Delivery Days',
            valueWidget: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.schedule_rounded, size: 14, color: Color(0xFF4C6656)),
                const SizedBox(width: 4),
                Text(
                  summary.estimatedDelivery.displayRange,
                  style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Color(0xFF11261B)),
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),
          _buildSummaryRow(
            label: 'Shipping Charge',
            valueWidget: isFree
                ? const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        '₹40',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey,
                          decoration: TextDecoration.lineThrough,
                        ),
                      ),
                      SizedBox(width: 6),
                      Text(
                        'FREE',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                          color: AppColors.primaryGreen,
                        ),
                      ),
                    ],
                  )
                : Text(
                    '₹${summary.shippingCharge.toStringAsFixed(0)}',
                    style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Color(0xFF11261B)),
                  ),
          ),
        ],
      ),
    );
  }

  // ==========================================
  // SECTION 4: PRICE DETAILS
  // ==========================================
  Widget _buildSection4PriceDetails(CheckoutSummaryModel summary) {
    final isFree = summary.shippingCharge <= 0;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.receipt_long_outlined, color: AppColors.primaryGreen, size: 20),
              SizedBox(width: 8),
              Text(
                'Price Details',
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Color(0xFF11261B)),
              ),
            ],
          ),
          const Divider(height: 16, color: Color(0xFFEEF3F0)),
          _buildSummaryRow(
            label: 'Subtotal (${summary.itemCount} ${summary.itemCount == 1 ? "item" : "items"})',
            valueWidget: Text(
              '₹${summary.subtotal.toStringAsFixed(0)}',
              style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Color(0xFF11261B)),
            ),
          ),
          const SizedBox(height: 10),
          _buildSummaryRow(
            label: 'Shipping Charges',
            valueWidget: Text(
              isFree ? 'FREE' : '₹${summary.shippingCharge.toStringAsFixed(0)}',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.bold,
                color: isFree ? AppColors.primaryGreen : const Color(0xFF11261B),
              ),
            ),
          ),
          const Divider(height: 20, color: Color(0xFFEEF3F0)),
          _buildSummaryRow(
            label: 'Grand Total',
            labelStyle: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Color(0xFF11261B)),
            valueWidget: Text(
              '₹${summary.grandTotal.toStringAsFixed(0)}',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.primaryGreen),
            ),
          ),
          if (isFree) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
              decoration: BoxDecoration(
                color: const Color(0xFFECFDF5),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: const Color(0xFFA7F3D0)),
              ),
              child: const Row(
                children: [
                  Icon(Icons.verified_rounded, size: 16, color: AppColors.primaryGreen),
                  SizedBox(width: 6),
                  Text(
                    'You saved ₹40 delivery fee on this order!',
                    style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.bold, color: AppColors.darkGreen),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  // ==========================================
  // SECTION 5: PAYMENT METHOD
  // ==========================================
  Widget _buildSection5PaymentMethod() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.payments_outlined, color: AppColors.primaryGreen, size: 20),
              SizedBox(width: 8),
              Text(
                'Payment Method',
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Color(0xFF11261B)),
              ),
            ],
          ),
          const Divider(height: 16, color: Color(0xFFEEF3F0)),
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: AppColors.primaryGreen.withValues(alpha: 0.05),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.primaryGreen, width: 1.5),
            ),
            child: Row(
              children: [
                const Icon(Icons.radio_button_checked_rounded, color: AppColors.primaryGreen, size: 22),
                const SizedBox(width: 12),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            'Cash on Delivery (COD)',
                            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13.5, color: Color(0xFF11261B)),
                          ),
                          SizedBox(width: 6),
                          Icon(Icons.money_rounded, size: 16, color: AppColors.primaryGreen),
                        ],
                      ),
                      SizedBox(height: 3),
                      Text(
                        'Pay with cash at your doorstep upon receiving the package.',
                        style: TextStyle(fontSize: 11, color: Color(0xFF5A7265)),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: AppColors.primaryGreen,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: const Text(
                    'DEFAULT',
                    style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: Colors.white),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ==========================================
  // SECTION 6: ORDER NOTES (OPTIONAL)
  // ==========================================
  Widget _buildSection6OrderNotes() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.edit_note_rounded, color: AppColors.primaryGreen, size: 22),
              SizedBox(width: 8),
              Text(
                'Order Notes (Optional)',
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Color(0xFF11261B)),
              ),
            ],
          ),
          const SizedBox(height: 10),
          TextField(
            controller: _notesController,
            maxLines: 2,
            decoration: InputDecoration(
              hintText: 'e.g. Please ring doorbell, leave with security or call on arrival.',
              hintStyle: const TextStyle(fontSize: 12, color: Color(0xFF9EABA2)),
              filled: true,
              fillColor: const Color(0xFFF9FAF9),
              contentPadding: const EdgeInsets.all(12),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: const BorderSide(color: Color(0xFFE2EBE6)),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: const BorderSide(color: Color(0xFFE2EBE6)),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: const BorderSide(color: AppColors.primaryGreen, width: 1.5),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ==========================================
  // SECTION 7: STICKY BOTTOM BAR
  // ==========================================
  Widget _buildSection7StickyBottomBar(BuildContext context, AddressModel? selectedAddress, CheckoutSummaryModel summary) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 14, 20, 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(22)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 16,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Row(
          children: [
            // Left: Grand Total
            Expanded(
              flex: 4,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Grand Total',
                    style: TextStyle(fontSize: 11, color: Color(0xFF5A7265), fontWeight: FontWeight.w500),
                  ),
                  Text(
                    '₹${summary.grandTotal.toStringAsFixed(0)}',
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF11261B),
                    ),
                  ),
                  const Text(
                    'All taxes included',
                    style: TextStyle(fontSize: 9.5, color: Color(0xFF7A9A86)),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            // Right: Place Order Button
            Expanded(
              flex: 6,
              child: SizedBox(
                height: 48,
                child: ElevatedButton(
                  onPressed: _isPlacingOrder ? null : () => _handlePlaceOrder(selectedAddress, summary),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF1A3827),
                    foregroundColor: Colors.white,
                    disabledBackgroundColor: const Color(0xFF9EABA2),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    elevation: 0,
                  ),
                  child: _isPlacingOrder
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                        )
                      : const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              'PLACE ORDER',
                              style: TextStyle(
                                fontSize: 13.5,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 0.5,
                              ),
                            ),
                            SizedBox(width: 6),
                            Icon(Icons.arrow_forward_rounded, size: 16),
                          ],
                        ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryRow({
    required String label,
    required Widget valueWidget,
    TextStyle? labelStyle,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: labelStyle ?? const TextStyle(fontSize: 13, color: Color(0xFF5A7265)),
        ),
        valueWidget,
      ],
    );
  }
}
