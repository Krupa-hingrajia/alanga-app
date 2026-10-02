import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';

class ShipOrderBottomSheet extends StatefulWidget {
  final String orderNumber;

  const ShipOrderBottomSheet({
    super.key,
    required this.orderNumber,
  });

  static Future<Map<String, String>?> show(BuildContext context, String orderNumber) {
    return showModalBottomSheet<Map<String, String>>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => ShipOrderBottomSheet(orderNumber: orderNumber),
    );
  }

  @override
  State<ShipOrderBottomSheet> createState() => _ShipOrderBottomSheetState();
}

class _ShipOrderBottomSheetState extends State<ShipOrderBottomSheet> {
  final _formKey = GlobalKey<FormState>();
  final _courierCtrl = TextEditingController();
  final _trackingCtrl = TextEditingController();
  final _urlCtrl = TextEditingController();

  final List<String> _popularCouriers = const [
    'Delhivery',
    'Shiprocket',
    'Blue Dart',
    'DTDC',
    'Ekart',
    'Ecom Express',
    'Self / Local Delivery',
  ];

  @override
  void dispose() {
    _courierCtrl.dispose();
    _trackingCtrl.dispose();
    _urlCtrl.dispose();
    super.dispose();
  }

  void _onSelectCourier(String name) {
    setState(() {
      _courierCtrl.text = name;
      _updateTrackingUrl();
    });
  }

  void _updateTrackingUrl() {
    final courier = _courierCtrl.text.trim().toLowerCase();
    final tracking = _trackingCtrl.text.trim();
    if (tracking.isEmpty) return;

    if (courier.contains('delhivery')) {
      _urlCtrl.text = 'https://www.delhivery.com/track/package/$tracking';
    } else if (courier.contains('blue dart') || courier.contains('bluedart')) {
      _urlCtrl.text = 'https://www.bluedart.com/tracking?trackNumber=$tracking';
    } else if (courier.contains('dtdc')) {
      _urlCtrl.text = 'https://www.dtdc.in/tracking/shipment-tracking.asp?trackingNo=$tracking';
    } else if (courier.contains('shiprocket')) {
      _urlCtrl.text = 'https://shiprocket.co/tracking/$tracking';
    } else if (courier.contains('ekart')) {
      _urlCtrl.text = 'https://ekartlogistics.com/shipmenttrack/$tracking';
    } else if (courier.contains('ecom')) {
      _urlCtrl.text = 'https://ecomexpress.in/tracking/?awb=$tracking';
    } else if (courier.contains('post')) {
      _urlCtrl.text = 'https://www.indiapost.gov.in/_layouts/15/dpt.cept.tracking/trackconsignment.aspx';
    }
  }

  void _submit() {
    if (_formKey.currentState?.validate() ?? false) {
      Navigator.of(context).pop({
        'courierName': _courierCtrl.text.trim(),
        'trackingNumber': _trackingCtrl.text.trim(),
        if (_urlCtrl.text.trim().isNotEmpty) 'trackingUrl': _urlCtrl.text.trim(),
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;

    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: EdgeInsets.fromLTRB(20, 16, 20, 20 + bottomInset),
      child: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Top drag indicator
              Center(
                child: Container(
                  width: 44,
                  height: 5,
                  decoration: BoxDecoration(
                    color: const Color(0xFFDCE5DF),
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Title and Header
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: const Color(0xFF2563EB).withValues(alpha: 0.1),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.local_shipping_rounded, color: Color(0xFF2563EB), size: 24),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Ship Order',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF11261B),
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'Order #${widget.orderNumber}',
                          style: const TextStyle(
                            fontSize: 12,
                            color: Color(0xFF6B8A78),
                            fontFamily: 'monospace',
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(Icons.close_rounded, color: Color(0xFF556960)),
                    visualDensity: VisualDensity.compact,
                  ),
                ],
              ),
              const Divider(height: 24, color: Color(0xFFE8EFEA)),

              // Instructions
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFFF0FDF4),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: const Color(0xFFBBF7D0)),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.info_outline, size: 18, color: Color(0xFF15803D)),
                    SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        'Enter courier and tracking details so customer can track their parcel in real-time.',
                        style: TextStyle(fontSize: 11.5, color: Color(0xFF15803D), height: 1.3),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // Quick Courier Selection Chips
              const Text(
                'Select Courier Partner',
                style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.bold, color: Color(0xFF11261B)),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: _popularCouriers.map((courier) {
                  final isSelected = _courierCtrl.text.trim() == courier;
                  return InkWell(
                    onTap: () => _onSelectCourier(courier),
                    borderRadius: BorderRadius.circular(8),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(
                        color: isSelected ? AppColors.primaryGreen : const Color(0xFFF4F7F5),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: isSelected ? AppColors.primaryGreen : const Color(0xFFE2ECE5),
                        ),
                      ),
                      child: Text(
                        courier,
                        style: TextStyle(
                          fontSize: 11.5,
                          fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                          color: isSelected ? Colors.white : const Color(0xFF26382E),
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 14),

              // Custom Courier Name Input
              TextFormField(
                controller: _courierCtrl,
                decoration: InputDecoration(
                  labelText: 'Courier Name *',
                  hintText: 'e.g. Delhivery, Blue Dart, Self Delivery',
                  prefixIcon: const Icon(Icons.business_outlined, size: 18),
                  filled: true,
                  fillColor: const Color(0xFFF9FAF9),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: const BorderSide(color: Color(0xFFE4ECE8)),
                  ),
                ),
                validator: (val) {
                  if (val == null || val.trim().isEmpty) {
                    return 'Please enter or select a courier partner';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 14),

              // Tracking / AWB Number Input
              TextFormField(
                controller: _trackingCtrl,
                onChanged: (_) => _updateTrackingUrl(),
                decoration: InputDecoration(
                  labelText: 'AWB / Tracking Number *',
                  hintText: 'e.g. AWB123456789 or Delivery Boy Mobile',
                  prefixIcon: const Icon(Icons.qr_code_rounded, size: 18),
                  filled: true,
                  fillColor: const Color(0xFFF9FAF9),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: const BorderSide(color: Color(0xFFE4ECE8)),
                  ),
                ),
                validator: (val) {
                  if (val == null || val.trim().isEmpty) {
                    return 'Please enter the AWB / Tracking number';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 14),

              // Optional Tracking URL Input
              TextFormField(
                controller: _urlCtrl,
                decoration: InputDecoration(
                  labelText: 'Tracking Website URL (Optional)',
                  hintText: 'https://track.courier.com/...',
                  prefixIcon: const Icon(Icons.link_rounded, size: 18),
                  filled: true,
                  fillColor: const Color(0xFFF9FAF9),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: const BorderSide(color: Color(0xFFE4ECE8)),
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // Submit Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: _submit,
                  icon: const Icon(Icons.local_shipping_rounded, size: 18),
                  label: const Text(
                    'DISPATCH & SHIP ORDER',
                    style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 0.5),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF1A3827),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
