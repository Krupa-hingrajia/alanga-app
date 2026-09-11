import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/widgets/custom_image_view.dart';
import '../../../addresses/data/models/address_model.dart';
import '../../../addresses/presentation/bloc/address_cubit.dart';
import '../../../addresses/presentation/bloc/address_state.dart';
import '../../../addresses/presentation/widgets/add_edit_address_bottom_sheet.dart';
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
    if (selectedAddress == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select or add a shipping address before placing order.'),
          backgroundColor: AppColors.brandRed,
        ),
      );
      return;
    }

    if (summary.hasOutOfStockItems) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please remove out-of-stock items from cart before placing order.'),
          backgroundColor: AppColors.brandRed,
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
      // Cart refresh
      if (mounted) {
        context.read<CartCubit>().fetchCart();
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isPlacingOrder = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.toString().replaceAll('Exception: ', '')),
            backgroundColor: AppColors.brandRed,
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
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (modalContext) {
        return Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Select Delivery Address', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(modalContext),
                  ),
                ],
              ),
              const Divider(height: 20),
              if (addresses.isEmpty)
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 20),
                  child: Center(child: Text('No addresses saved yet.', style: TextStyle(color: Colors.grey))),
                )
              else
                Flexible(
                  child: ListView.builder(
                    shrinkWrap: true,
                    itemCount: addresses.length,
                    itemBuilder: (ctx, idx) {
                      final addr = addresses[idx];
                      final isSelected = currentSelected?.id == addr.id;
                      return Container(
                        margin: const EdgeInsets.only(bottom: 12),
                        decoration: BoxDecoration(
                          color: isSelected ? AppColors.primaryGreen.withValues(alpha: 0.05) : Colors.white,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(
                            color: isSelected ? AppColors.primaryGreen : const Color(0xFFE4ECE8),
                            width: isSelected ? 1.5 : 1,
                          ),
                        ),
                        child: ListTile(
                          onTap: () {
                            context.read<AddressCubit>().selectAddress(addr);
                            Navigator.pop(modalContext);
                          },
                          leading: Icon(
                            isSelected ? Icons.check_circle_rounded : Icons.radio_button_unchecked,
                            color: isSelected ? AppColors.primaryGreen : Colors.grey,
                          ),
                          title: Row(
                            children: [
                              Text(addr.fullName, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                              const SizedBox(width: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                decoration: BoxDecoration(
                                  color: Colors.grey.shade200,
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Text(addr.addressType, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold)),
                              ),
                              if (addr.isDefault) ...[
                                const SizedBox(width: 6),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: AppColors.primaryGreen.withValues(alpha: 0.15),
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: const Text('DEFAULT', style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: AppColors.primaryGreen)),
                                ),
                              ],
                            ],
                          ),
                          subtitle: Padding(
                            padding: const EdgeInsets.only(top: 4),
                            child: Text(
                              '${addr.addressLine1}, ${addr.city}, ${addr.state} - ${addr.postalCode}\nPhone: ${addr.mobileNumber}',
                              style: const TextStyle(fontSize: 12, height: 1.3),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: () {
                    Navigator.pop(modalContext);
                    showModalBottomSheet(
                      context: context,
                      isScrollControlled: true,
                      builder: (_) => const AddEditAddressBottomSheet(),
                    );
                  },
                  icon: const Icon(Icons.add_rounded),
                  label: const Text('ADD NEW ADDRESS'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.primaryGreen,
                    side: const BorderSide(color: AppColors.primaryGreen),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6F8F6),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded, color: Color(0xFF11261B)),
          onPressed: () => context.pop(),
        ),
        title: const Text(
          'Checkout',
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
              return const Center(child: CircularProgressIndicator(color: AppColors.primaryGreen));
            }

            if (checkoutState is CheckoutError) {
              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.error_outline_rounded, color: AppColors.brandRed, size: 48),
                      const SizedBox(height: 16),
                      Text(
                        checkoutState.message,
                        textAlign: TextAlign.center,
                        style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 20),
                      ElevatedButton(
                        onPressed: () => context.read<CheckoutCubit>().fetchCheckoutSummary(),
                        style: ElevatedButton.styleFrom(backgroundColor: AppColors.primaryGreen, foregroundColor: Colors.white),
                        child: const Text('Retry'),
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
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // STEP 1: Delivery Address Section
                            _buildAddressSection(context, selectedAddress, addressesList),
                            const SizedBox(height: 16),

                            // STEP 2: Order Items Section
                            _buildOrderItemsSection(summary!),
                            const SizedBox(height: 16),

                            // STEP 3: Delivery Timeline Banner
                            _buildDeliveryBanner(summary.estimatedDelivery),
                            const SizedBox(height: 16),

                            // STEP 4: Payment Method Section
                            _buildPaymentMethodSection(),
                            const SizedBox(height: 16),

                            // Optional Notes Input
                            _buildNotesSection(),
                            const SizedBox(height: 24),
                          ],
                        ),
                      ),
                    ),

                    // STEP 5: Sticky Bottom Price Summary & Place Order Button
                    _buildStickyBottomBar(context, selectedAddress, summary),
                  ],
                );
              },
            );
          },
        ),
      ),
    );
  }

  Widget _buildAddressSection(BuildContext context, AddressModel? selectedAddress, List<AddressModel> addresses) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
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
                    style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Color(0xFF11261B)),
                  ),
                ],
              ),
              if (selectedAddress != null)
                TextButton(
                  onPressed: () => _showAddressSelectionModal(context, addresses, selectedAddress),
                  child: const Text('CHANGE', style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.primaryGreen)),
                ),
            ],
          ),
          const Divider(height: 16),
          if (selectedAddress == null) ...[
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFFFFFBEB),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFFFDE68A)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.info_outline_rounded, color: Color(0xFFD97706), size: 24),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('No Address Found', style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFFB45309))),
                        Text('Please add a delivery address to complete checkout.', style: TextStyle(fontSize: 11, color: Color(0xFFB45309))),
                      ],
                    ),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      showModalBottomSheet(
                        context: context,
                        isScrollControlled: true,
                        builder: (_) => const AddEditAddressBottomSheet(),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFD97706),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    ),
                    child: const Text('ADD ADDRESS', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
                  ),
                ],
              ),
            ),
          ] else ...[
            Row(
              children: [
                Text(selectedAddress.fullName, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: AppColors.primaryGreen.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(selectedAddress.addressType, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: AppColors.primaryGreen)),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Text(
              selectedAddress.formattedAddress,
              style: const TextStyle(fontSize: 12, color: Color(0xFF5A7265), height: 1.3),
            ),
            const SizedBox(height: 4),
            Text(
              'Mobile: ${selectedAddress.mobileNumber}',
              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Color(0xFF11261B)),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildOrderItemsSection(CheckoutSummaryModel summary) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
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
              const Text('Order Items', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Color(0xFF11261B))),
              Text('${summary.itemCount} items', style: const TextStyle(fontSize: 12, color: Colors.grey)),
            ],
          ),
          const Divider(height: 16),
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: summary.items.length,
            separatorBuilder: (_, __) => const Divider(height: 20, color: Color(0xFFEEF3F0)),
            itemBuilder: (context, index) {
              final item = summary.items[index];
              return Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      color: const Color(0xFFF6FAF9),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: CustomImageView(
                        imageUrl: item.imageUrl,
                        fit: BoxFit.cover,
                        placeholderIcon: Icons.shopping_bag_outlined,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(item.productName, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold), maxLines: 1, overflow: TextOverflow.ellipsis),
                        const SizedBox(height: 2),
                        Text('Variant: ${item.variantName}', style: const TextStyle(fontSize: 11, color: Colors.grey)),
                        if (item.sku.isNotEmpty) Text('SKU: ${item.sku}', style: const TextStyle(fontSize: 10, color: Colors.grey)),
                        const SizedBox(height: 4),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('₹${item.unitPrice.toStringAsFixed(0)} × ${item.quantity}', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
                            Text('₹${item.itemSubtotal.toStringAsFixed(0)}', style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: AppColors.primaryGreen)),
                          ],
                        ),
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

  Widget _buildDeliveryBanner(EstimatedDeliveryModel delivery) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.primaryGreen.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.primaryGreen.withValues(alpha: 0.2)),
      ),
      child: Row(
        children: [
          const Icon(Icons.local_shipping_outlined, color: AppColors.primaryGreen, size: 22),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Estimated Delivery', style: TextStyle(fontSize: 11, color: Color(0xFF5A7265))),
                Text(
                  delivery.displayRange,
                  style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: AppColors.primaryGreen),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentMethodSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Payment Method', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Color(0xFF11261B))),
          const Divider(height: 16),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.primaryGreen.withValues(alpha: 0.05),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.primaryGreen, width: 1.5),
            ),
            child: const Row(
              children: [
                Icon(Icons.check_circle_rounded, color: AppColors.primaryGreen, size: 20),
                SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Cash on Delivery (COD)', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                      Text('Pay in cash when your order is delivered to your doorstep.', style: TextStyle(fontSize: 11, color: Colors.grey)),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNotesSection() {
    return TextField(
      controller: _notesController,
      decoration: InputDecoration(
        labelText: 'Delivery Instructions / Notes (Optional)',
        labelStyle: const TextStyle(fontSize: 12, color: Colors.grey),
        prefixIcon: const Icon(Icons.note_alt_outlined, color: AppColors.primaryGreen, size: 18),
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFFE4ECE8))),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFFE4ECE8))),
      ),
    );
  }

  Widget _buildStickyBottomBar(BuildContext context, AddressModel? selectedAddress, CheckoutSummaryModel summary) {
    final isFreeShipping = summary.shippingCharge <= 0;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 16,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Subtotal', style: TextStyle(fontSize: 13, color: Colors.grey)),
                Text('₹${summary.subtotal.toStringAsFixed(0)}', style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
              ],
            ),
            const SizedBox(height: 6),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Shipping Fee', style: TextStyle(fontSize: 13, color: Colors.grey)),
                Text(
                  isFreeShipping ? 'FREE' : '₹${summary.shippingCharge.toStringAsFixed(0)}',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: isFreeShipping ? AppColors.primaryGreen : Colors.black87,
                  ),
                ),
              ],
            ),
            const Divider(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Grand Total', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                Text(
                  '₹${summary.grandTotal.toStringAsFixed(0)}',
                  style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppColors.primaryGreen),
                ),
              ],
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: (_isPlacingOrder || selectedAddress == null || summary.hasOutOfStockItems)
                    ? null
                    : () => _handlePlaceOrder(selectedAddress, summary),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF1A3827),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                ),
                child: _isPlacingOrder
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                      )
                    : const Text(
                        'PLACE ORDER',
                        style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, letterSpacing: 0.5),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
