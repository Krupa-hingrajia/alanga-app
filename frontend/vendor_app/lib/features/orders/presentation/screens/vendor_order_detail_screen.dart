import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/widgets/custom_image_view.dart';
import '../../../../core/dependency_injection/injection.dart';
import '../../data/models/vendor_order_model.dart';
import '../bloc/vendor_order_bloc.dart';
import '../bloc/vendor_order_event.dart';
import '../bloc/vendor_order_state.dart';
import '../widgets/vendor_order_status_badge.dart';
import '../widgets/order_status_timeline.dart';
import '../widgets/ship_order_bottom_sheet.dart';
import '../widgets/cancel_order_dialog.dart';
import '../widgets/pack_order_bottom_sheet.dart';
import '../widgets/order_documents_bottom_sheet.dart';
import '../../utils/order_document_generator.dart';

class VendorOrderDetailScreen extends StatefulWidget {
  final VendorOrderModel order;

  const VendorOrderDetailScreen({
    super.key,
    required this.order,
  });

  @override
  State<VendorOrderDetailScreen> createState() => _VendorOrderDetailScreenState();
}

class _VendorOrderDetailScreenState extends State<VendorOrderDetailScreen> {
  late VendorOrderModel _currentOrder;
  bool _statusChanged = false;

  @override
  void initState() {
    super.initState();
    _currentOrder = widget.order;
  }

  String _formatDate(DateTime date) {
    final months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    final day = date.day.toString().padLeft(2, '0');
    final month = months[date.month - 1];
    final year = date.year;
    final hour = date.hour.toString().padLeft(2, '0');
    final minute = date.minute.toString().padLeft(2, '0');
    return '$day $month $year, $hour:$minute';
  }

  Future<void> _makePhoneCall(String phoneNumber) async {
    final cleanNumber = phoneNumber.replaceAll(RegExp(r'[^\d+]'), '');
    if (cleanNumber.isEmpty) return;
    final uri = Uri.parse('tel:$cleanNumber');
    try {
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri);
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Could not launch phone dialer')),
          );
        }
      }
    } catch (_) {}
  }

  Future<void> _openWhatsApp(String phoneNumber, String customerName) async {
    final cleanNumber = phoneNumber.replaceAll(RegExp(r'[^\d]'), '');
    if (cleanNumber.isEmpty) return;
    final formattedNumber = cleanNumber.length == 10 ? '91$cleanNumber' : cleanNumber;
    final message = Uri.encodeComponent(
      'Hello $customerName, this is from Alanga Marketplace regarding your Order #${_currentOrder.orderNumber} for ${_currentOrder.firstProductName}. We are processing your order. Thank you!',
    );
    final uri = Uri.parse('https://wa.me/$formattedNumber?text=$message');
    try {
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Could not open WhatsApp')),
          );
        }
      }
    } catch (_) {}
  }

  void _confirmCancelOrder(BuildContext context) async {
    final bloc = context.read<VendorOrderBloc>();
    final reason = await CancelOrderDialog.show(context, _currentOrder.orderNumber);
    if (reason != null && context.mounted) {
      bloc.add(UpdateOrderStatusEvent(
        orderId: _currentOrder.id,
        newStatus: 'CANCELLED',
        cancelReason: reason,
      ));
    }
  }

  void _confirmStatusAdvance(BuildContext context, String nextStatus, String actionLabel) async {
    final bloc = context.read<VendorOrderBloc>();

    // If advancing to PACKED, show packaging verification checklist
    if (nextStatus == 'PACKED') {
      final confirmed = await PackOrderBottomSheet.show(context, _currentOrder);
      if (confirmed == true && context.mounted) {
        bloc.add(UpdateOrderStatusEvent(
          orderId: _currentOrder.id,
          newStatus: 'PACKED',
        ));
      }
      return;
    }

    // If advancing to SHIPPED, show courier & tracking bottom sheet
    if (nextStatus == 'SHIPPED') {
      final shippingData = await ShipOrderBottomSheet.show(context, _currentOrder.orderNumber);
      if (shippingData != null && context.mounted) {
        bloc.add(UpdateOrderStatusEvent(
          orderId: _currentOrder.id,
          newStatus: 'SHIPPED',
          courierName: shippingData['courierName'],
          trackingNumber: shippingData['trackingNumber'],
          trackingUrl: shippingData['trackingUrl'],
        ));
      }
      return;
    }

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
              child: const Icon(Icons.sync_alt_rounded, color: AppColors.primaryGreen, size: 22),
            ),
            const SizedBox(width: 12),
            const Expanded(
              child: Text(
                'Advance Order Status',
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
              'Advance order #${_currentOrder.orderNumber} to:',
              style: const TextStyle(fontSize: 14, color: Color(0xFF4B5563)),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: const Color(0xFFF3F4F6),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    _currentOrder.status,
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                  ),
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 10),
                    child: Icon(Icons.arrow_forward_rounded, size: 16, color: Colors.grey),
                  ),
                  Text(
                    nextStatus,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                      color: AppColors.primaryGreen,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),
            const Text(
              'Once updated, the order moves to the next fulfillment stage. Are you sure you want to proceed?',
              style: TextStyle(fontSize: 13, color: Color(0xFF6B7280), height: 1.4),
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
                orderId: _currentOrder.id,
                newStatus: nextStatus,
              ));
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF1A3827),
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
      create: (_) => sl<VendorOrderBloc>()..add(InitOrderDetailEvent(order: widget.order)),
      child: PopScope(
        canPop: false,
        onPopInvokedWithResult: (didPop, _) {
          if (didPop) return;
          context.pop(_statusChanged);
        },
        child: Scaffold(
          backgroundColor: const Color(0xFFF6F8F6),
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            scrolledUnderElevation: 0,
            automaticallyImplyLeading: false,
            leadingWidth: 56,
            leading: Center(
              child: Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                  border: Border.all(color: const Color(0xFFE4ECE8)),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.04),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: IconButton(
                  padding: EdgeInsets.zero,
                  icon: const Icon(
                    Icons.arrow_back,
                    size: 18,
                    color: Color(0xFF1A3827),
                  ),
                  onPressed: () => context.pop(_statusChanged),
                ),
              ),
            ),
            title: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Order #${_currentOrder.orderNumber}',
                  style: const TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF11261B),
                  ),
                ),
                Text(
                  _formatDate(_currentOrder.createdAt),
                  style: const TextStyle(
                    fontSize: 11,
                    color: Color(0xFF8B9E94),
                  ),
                ),
              ],
            ),
            actions: [
              Padding(
                padding: const EdgeInsets.only(right: 16),
                child: Center(
                  child: VendorOrderStatusBadge(status: _currentOrder.status),
                ),
              ),
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
                  final updated = state.allOrders.firstWhere(
                    (o) => o.id == _currentOrder.id,
                    orElse: () => _currentOrder,
                  );
                  setState(() {
                    _currentOrder = updated;
                    _statusChanged = true;
                  });
                } else if (state.errorMessage != null) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(state.errorMessage!),
                      backgroundColor: AppColors.brandRed,
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                }
              }
            },
            builder: (context, state) {
              return SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 110),
                physics: const BouncingScrollPhysics(),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Status Banner (if delivered or cancelled)
                    if (_currentOrder.status == 'DELIVERED')
                      _buildDeliveredBanner()
                    else if (_currentOrder.status == 'CANCELLED')
                      _buildCancelledBanner(),

                    const SizedBox(height: 12),

                    // Quick Action Documents: Label & Invoice
                    _buildDocumentActionsBar(),

                    // Shipment & Tracking Details (when shipped or tracking available)
                    _buildShipmentTrackingSection(),

                    // Section 1: Customer Details (with Call & WhatsApp)
                    _buildCustomerSection(),

                    const SizedBox(height: 16),

                    // Section 2: Delivery Address (with Call & WhatsApp)
                    _buildAddressSection(),

                    const SizedBox(height: 16),

                    // Section 3: Ordered Products
                    _buildOrderedProductsSection(),

                    const SizedBox(height: 16),

                    // Section 4: Price Breakdown
                    _buildPriceSummarySection(),

                    const SizedBox(height: 16),

                    // Section 5: Order Timeline
                    OrderStatusTimeline(
                      currentStatus: _currentOrder.status,
                      orderDate: _currentOrder.createdAt,
                      updatedAt: _currentOrder.updatedAt,
                      cancelReason: _currentOrder.cancelReason,
                    ),
                  ],
                ),
              );
            },
          ),
          bottomNavigationBar: _buildBottomActionBar(context),
        ),
      ),
    );
  }

  // --- WIDGETS ---

  Widget _buildDocumentActionsBar() {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE4ECE8)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.print_outlined, size: 16, color: Color(0xFF4C6656)),
              const SizedBox(width: 6),
              const Expanded(
                child: Text(
                  'Order Documents & Printables',
                  style: TextStyle(
                    fontSize: 12.5,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF11261B),
                  ),
                ),
              ),
              InkWell(
                onTap: () => OrderDocumentsBottomSheet.show(context, _currentOrder),
                child: const Text(
                  'All Documents',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primaryGreen,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          // 1. Shipping Label Row
          Row(
            children: [
              Expanded(
                flex: 3,
                child: ElevatedButton.icon(
                  onPressed: () => OrderDocumentGenerator.printShippingLabel(
                    context: context,
                    order: _currentOrder,
                  ),
                  icon: const Icon(Icons.receipt_long_rounded, size: 15),
                  label: const Text('Print Label', style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.bold)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF1A3827),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                flex: 2,
                child: OutlinedButton.icon(
                  onPressed: () => OrderDocumentGenerator.shareShippingLabel(
                    context: context,
                    order: _currentOrder,
                  ),
                  icon: const Icon(Icons.share_outlined, size: 14, color: Color(0xFF1A3827)),
                  label: const Text('Share', style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.bold, color: Color(0xFF1A3827))),
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: Color(0xFF1A3827)),
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          // 2. Tax Invoice Row
          Row(
            children: [
              Expanded(
                flex: 3,
                child: ElevatedButton.icon(
                  onPressed: () => OrderDocumentGenerator.printTaxInvoice(
                    context: context,
                    order: _currentOrder,
                  ),
                  icon: const Icon(Icons.description_outlined, size: 15),
                  label: const Text('Tax Invoice', style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.bold)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF1565C0),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                flex: 2,
                child: OutlinedButton.icon(
                  onPressed: () => OrderDocumentGenerator.shareTaxInvoice(
                    context: context,
                    order: _currentOrder,
                  ),
                  icon: const Icon(Icons.share_outlined, size: 14, color: Color(0xFF1565C0)),
                  label: const Text('Share', style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.bold, color: Color(0xFF1565C0))),
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: Color(0xFF1565C0)),
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildShipmentTrackingSection() {
    if (!_currentOrder.hasTracking && !_currentOrder.isShipped) {
      return const SizedBox.shrink();
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFE4ECE8)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFF2563EB).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.local_shipping_outlined, size: 20, color: Color(0xFF2563EB)),
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Text(
                  'Shipment & Tracking',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF11261B),
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: const Color(0xFFEFF6FF),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  _currentOrder.status,
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF2563EB),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          _buildInfoRow(
            icon: Icons.business_outlined,
            label: 'Courier',
            value: _currentOrder.courierName ?? 'Standard Delivery',
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              const Icon(Icons.qr_code_rounded, size: 16, color: Color(0xFF9CA3AF)),
              const SizedBox(width: 10),
              const SizedBox(
                width: 70,
                child: Text(
                  'AWB / No.',
                  style: TextStyle(fontSize: 13, color: Color(0xFF6B7280)),
                ),
              ),
              Expanded(
                child: Text(
                  _currentOrder.trackingNumber ?? 'Pending',
                  style: const TextStyle(
                    fontSize: 13,
                    fontFamily: 'monospace',
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1F2937),
                  ),
                ),
              ),
              if (_currentOrder.hasTracking)
                InkWell(
                  onTap: () {
                    Clipboard.setData(ClipboardData(text: _currentOrder.trackingNumber!));
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('AWB copied to clipboard'), duration: Duration(seconds: 1)),
                    );
                  },
                  borderRadius: BorderRadius.circular(6),
                  child: const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 6, vertical: 4),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.copy_rounded, size: 13, color: AppColors.primaryGreen),
                        SizedBox(width: 4),
                        Text(
                          'Copy',
                          style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.bold, color: AppColors.primaryGreen),
                        ),
                      ],
                    ),
                  ),
                ),
            ],
          ),
          if (_currentOrder.shippedAt != null) ...[
            const SizedBox(height: 10),
            _buildInfoRow(
              icon: Icons.access_time_rounded,
              label: 'Shipped',
              value: _formatDate(_currentOrder.shippedAt!),
            ),
          ],
          if (_currentOrder.trackingUrl != null && _currentOrder.trackingUrl!.isNotEmpty) ...[
            const SizedBox(height: 14),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () async {
                  final uri = Uri.parse(_currentOrder.trackingUrl!);
                  if (await canLaunchUrl(uri)) {
                    await launchUrl(uri, mode: LaunchMode.externalApplication);
                  }
                },
                icon: const Icon(Icons.open_in_new_rounded, size: 16),
                label: const Text('Track Package on Courier Website'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: const Color(0xFF2563EB),
                  side: const BorderSide(color: Color(0xFF93C5FD)),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  padding: const EdgeInsets.symmetric(vertical: 10),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildContactButtons(String phoneNumber, String contactName) {
    if (phoneNumber.trim().isEmpty) return const SizedBox.shrink();

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        InkWell(
          onTap: () => _makePhoneCall(phoneNumber),
          borderRadius: BorderRadius.circular(6),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: const Color(0xFFEFF6FF),
              borderRadius: BorderRadius.circular(6),
              border: Border.all(color: const Color(0xFFBFDBFE)),
            ),
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.call_rounded, size: 13, color: Color(0xFF2563EB)),
                SizedBox(width: 4),
                Text(
                  'Call',
                  style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF2563EB)),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(width: 8),
        InkWell(
          onTap: () => _openWhatsApp(phoneNumber, contactName),
          borderRadius: BorderRadius.circular(6),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: const Color(0xFFF0FDF4),
              borderRadius: BorderRadius.circular(6),
              border: Border.all(color: const Color(0xFFBBF7D0)),
            ),
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.chat_bubble_rounded, size: 12, color: Color(0xFF16A34A)),
                SizedBox(width: 4),
                Text(
                  'WhatsApp',
                  style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF16A34A)),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCustomerSection() {
    final customer = _currentOrder.customer;

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFE4ECE8)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFF1A3827).withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.person_rounded, size: 20, color: Color(0xFF1A3827)),
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Text(
                  'Customer Details',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF11261B),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          _buildInfoRow(
            icon: Icons.account_circle_outlined,
            label: 'Name',
            value: customer?.fullName ?? 'Customer',
          ),
          const SizedBox(height: 10),
          if (customer?.phoneNumber != null && customer!.phoneNumber.isNotEmpty) ...[
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const Icon(Icons.phone_outlined, size: 16, color: Color(0xFF9CA3AF)),
                const SizedBox(width: 10),
                const SizedBox(
                  width: 70,
                  child: Text(
                    'Phone',
                    style: TextStyle(fontSize: 13, color: Color(0xFF6B7280)),
                  ),
                ),
                Expanded(
                  child: Text(
                    customer.phoneNumber,
                    style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Color(0xFF1F2937)),
                  ),
                ),
                _buildContactButtons(customer.phoneNumber, customer.fullName),
              ],
            ),
            const SizedBox(height: 10),
          ],
          if (customer?.email != null && customer!.email.isNotEmpty)
            _buildInfoRow(
              icon: Icons.mail_outline_rounded,
              label: 'Email',
              value: customer.email,
            ),
        ],
      ),
    );
  }

  Widget _buildAddressSection() {
    final address = _currentOrder.address;

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFE4ECE8)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: const Color(0xFF1A3827).withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(Icons.location_on_outlined, size: 20, color: Color(0xFF1A3827)),
                  ),
                  const SizedBox(width: 12),
                  const Text(
                    'Delivery Address',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF11261B),
                    ),
                  ),
                ],
              ),
              if (address != null)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF1F5F9),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    address.addressType.toUpperCase(),
                    style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF475569),
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 14),
          if (address == null)
            const Text(
              'No delivery address specified.',
              style: TextStyle(color: Color(0xFF9CA3AF), fontSize: 13),
            )
          else ...[
            Text(
              address.fullName,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1F2937),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              address.formattedAddress,
              style: const TextStyle(
                fontSize: 13,
                color: Color(0xFF4B5563),
                height: 1.4,
              ),
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                const Icon(Icons.phone_outlined, size: 14, color: Color(0xFF9CA3AF)),
                const SizedBox(width: 6),
                Text(
                  address.mobileNumber,
                  style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Color(0xFF1F2937)),
                ),
                const Spacer(),
                _buildContactButtons(address.mobileNumber, address.fullName),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildOrderedProductsSection() {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFE4ECE8)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFF1A3827).withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.shopping_bag_outlined, size: 20, color: Color(0xFF1A3827)),
              ),
              const SizedBox(width: 12),
              Text(
                'Items (${_currentOrder.orderItems.length})',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF11261B),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          ..._currentOrder.orderItems.map((item) => _buildOrderItemTile(item)),
        ],
      ),
    );
  }

  Widget _buildOrderItemTile(VendorOrderItemModel item) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFF9FBF9),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE8EFEA)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: const Color(0xFFE4ECE8)),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(7),
              child: CustomImageView(
                imageUrl: item.productImage,
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
                Text(
                  item.productName,
                  style: const TextStyle(
                    fontSize: 13.5,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF11261B),
                  ),
                ),
                if (item.variantName != null && item.variantName!.isNotEmpty) ...[
                  const SizedBox(height: 2),
                  Text(
                    item.variantName!,
                    style: const TextStyle(fontSize: 11.5, color: Color(0xFF6B8A78), fontWeight: FontWeight.w500),
                  ),
                ],
                if (item.sku != null && item.sku!.isNotEmpty) ...[
                  const SizedBox(height: 2),
                  Text(
                    'SKU: ${item.sku}',
                    style: const TextStyle(fontSize: 10.5, fontFamily: 'monospace', color: Colors.grey),
                  ),
                ],
                const SizedBox(height: 6),
                Row(
                  children: [
                    Text(
                      '₹${item.unitPrice.toStringAsFixed(0)} × ${item.quantity}',
                      style: const TextStyle(fontSize: 12, color: Color(0xFF4B5563)),
                    ),
                    const Spacer(),
                    Text(
                      '₹${item.totalPrice.toStringAsFixed(0)}',
                      style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.primaryGreen),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPriceSummarySection() {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFE4ECE8)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFF1A3827).withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.receipt_outlined, size: 20, color: Color(0xFF1A3827)),
              ),
              const SizedBox(width: 12),
              const Text(
                'Price Summary',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF11261B),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          _buildPriceRow('Items Total', '₹${_currentOrder.vendorItemsTotal.toStringAsFixed(0)}'),
          const SizedBox(height: 8),
          _buildPriceRow('Shipping Charges', '₹${_currentOrder.vendorShippingTotal.toStringAsFixed(0)}'),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 10),
            child: Divider(height: 1, color: Color(0xFFE8EFEA)),
          ),
          _buildPriceRow('Grand Total', '₹${_currentOrder.vendorGrandTotal.toStringAsFixed(0)}', isHighlighted: true),
          const SizedBox(height: 10),
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: _currentOrder.paymentMethod.toUpperCase() == 'COD'
                      ? const Color(0xFFFEF3C7)
                      : const Color(0xFFE0E7FF),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  _currentOrder.paymentMethod.toUpperCase(),
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: _currentOrder.paymentMethod.toUpperCase() == 'COD'
                        ? const Color(0xFF92400E)
                        : const Color(0xFF3730A3),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Text(
                'Payment Status: ${_currentOrder.paymentStatus.toUpperCase()}',
                style: const TextStyle(fontSize: 12, color: Color(0xFF6B7280), fontWeight: FontWeight.w500),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDeliveredBanner() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFF0FDF4),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFBBF7D0)),
      ),
      child: const Row(
        children: [
          Icon(Icons.check_circle_rounded, color: Color(0xFF16A34A), size: 24),
          SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Order Completed & Delivered',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF166534),
                  ),
                ),
                SizedBox(height: 2),
                Text(
                  'This order has been fulfilled. No further status changes can be made.',
                  style: TextStyle(fontSize: 12, color: Color(0xFF15803D)),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCancelledBanner() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFFEF2F2),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFFECACA)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.cancel_rounded, color: Color(0xFFDC2626), size: 24),
          SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Order Cancelled',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF991B1B),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  _currentOrder.cancelReason != null && _currentOrder.cancelReason!.isNotEmpty
                      ? 'Reason: ${_currentOrder.cancelReason}'
                      : 'This order was cancelled and inventory was restored.',
                  style: const TextStyle(fontSize: 12, color: Color(0xFFB91C1C)),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 16, color: const Color(0xFF9CA3AF)),
        const SizedBox(width: 10),
        SizedBox(
          width: 70,
          child: Text(
            label,
            style: const TextStyle(fontSize: 13, color: Color(0xFF6B7280)),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Color(0xFF1F2937)),
          ),
        ),
      ],
    );
  }

  Widget _buildPriceRow(String label, String value, {bool isHighlighted = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 13, color: Color(0xFF64748B)),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: isHighlighted ? 15 : 13,
            fontWeight: isHighlighted ? FontWeight.bold : FontWeight.w500,
            color: isHighlighted ? AppColors.primaryGreen : const Color(0xFF1E293B),
          ),
        ),
      ],
    );
  }

  Widget _buildBottomActionBar(BuildContext context) {
    final nextStatus = _currentOrder.nextValidStatus;
    final actionLabel = _currentOrder.nextStatusActionLabel;
    final canAdvance = _currentOrder.canAdvanceStatus;
    final canCancel = _currentOrder.canCancelOrder;

    return BlocBuilder<VendorOrderBloc, VendorOrderState>(
      builder: (context, state) {
        final isUpdating = state is VendorOrderLoaded && state.isUpdating;

        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.05),
                blurRadius: 16,
                offset: const Offset(0, -4),
              ),
            ],
          ),
          child: SafeArea(
            top: false,
            child: Row(
              children: [
                if (canCancel) ...[
                  OutlinedButton.icon(
                    onPressed: !isUpdating ? () => _confirmCancelOrder(context) : null,
                    icon: const Icon(Icons.cancel_outlined, size: 16, color: AppColors.brandRed),
                    label: const Text('Cancel', style: TextStyle(color: AppColors.brandRed, fontWeight: FontWeight.bold)),
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: AppColors.brandRed),
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 16),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                    ),
                  ),
                  const SizedBox(width: 10),
                ],
                Expanded(
                  child: ElevatedButton(
                    onPressed: canAdvance && !isUpdating
                        ? () => _confirmStatusAdvance(context, nextStatus!, actionLabel!)
                        : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: canAdvance ? const Color(0xFF1A3827) : const Color(0xFFCBD5E1),
                      foregroundColor: Colors.white,
                      disabledBackgroundColor: const Color(0xFFE2E8F0),
                      disabledForegroundColor: const Color(0xFF94A3B8),
                      elevation: canAdvance ? 2 : 0,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    child: isUpdating
                        ? const SizedBox(
                            width: 22,
                            height: 22,
                            child: CircularProgressIndicator(strokeWidth: 2.5, color: Colors.white),
                          )
                        : Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                canAdvance
                                    ? (nextStatus == 'SHIPPED'
                                        ? Icons.local_shipping_rounded
                                        : Icons.check_circle_outline_rounded)
                                    : Icons.lock_outline_rounded,
                                size: 19,
                              ),
                              const SizedBox(width: 8),
                              Flexible(
                                child: Text(
                                  canAdvance
                                      ? actionLabel!
                                      : _currentOrder.status == 'DELIVERED'
                                          ? 'Order Fulfilled'
                                          : _currentOrder.status == 'CANCELLED'
                                              ? 'Order Cancelled'
                                              : 'No Actions Available',
                                  style: const TextStyle(
                                    fontSize: 14.5,
                                    fontWeight: FontWeight.bold,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
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
}
