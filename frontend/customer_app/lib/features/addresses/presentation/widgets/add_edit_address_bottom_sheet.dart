import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:dio/dio.dart';
import '../../../../core/constants/app_colors.dart';
import '../../data/models/address_model.dart';
import '../bloc/address_cubit.dart';

class AddEditAddressBottomSheet extends StatefulWidget {
  final AddressModel? address;

  const AddEditAddressBottomSheet({super.key, this.address});

  @override
  State<AddEditAddressBottomSheet> createState() => _AddEditAddressBottomSheetState();
}

class _AddEditAddressBottomSheetState extends State<AddEditAddressBottomSheet> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _fullNameController;
  late TextEditingController _mobileController;
  late TextEditingController _altMobileController;
  late TextEditingController _line1Controller;
  late TextEditingController _line2Controller;
  late TextEditingController _landmarkController;
  late TextEditingController _cityController;
  late TextEditingController _stateController;
  late TextEditingController _postalCodeController;

  String _addressType = 'HOME';
  bool _isDefault = false;
  bool _isSubmitting = false;
  bool _isFetchingLocation = false;

  @override
  void initState() {
    super.initState();
    final a = widget.address;
    _fullNameController = TextEditingController(text: a?.fullName ?? '');
    _mobileController = TextEditingController(text: a?.mobileNumber ?? '');
    _altMobileController = TextEditingController(text: a?.alternateMobile ?? '');
    _line1Controller = TextEditingController(text: a?.addressLine1 ?? '');
    _line2Controller = TextEditingController(text: a?.addressLine2 ?? '');
    _landmarkController = TextEditingController(text: a?.landmark ?? '');
    _cityController = TextEditingController(text: a?.city ?? '');
    _stateController = TextEditingController(text: a?.state ?? '');
    _postalCodeController = TextEditingController(text: a?.postalCode ?? '');
    _addressType = a?.addressType ?? 'HOME';
    _isDefault = a?.isDefault ?? false;
  }

  @override
  void dispose() {
    _fullNameController.dispose();
    _mobileController.dispose();
    _altMobileController.dispose();
    _line1Controller.dispose();
    _line2Controller.dispose();
    _landmarkController.dispose();
    _cityController.dispose();
    _stateController.dispose();
    _postalCodeController.dispose();
    super.dispose();
  }

  Future<void> _fetchLiveLocation() async {
    setState(() => _isFetchingLocation = true);

    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        throw Exception('Location services are disabled on your device. Please turn on GPS.');
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          throw Exception('Location permissions were denied.');
        }
      }

      if (permission == LocationPermission.deniedForever) {
        throw Exception('Location permissions are permanently denied. Please enable location in App Settings.');
      }

      final position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(accuracy: LocationAccuracy.high),
      );

      bool geocoded = false;

      // Reverse geocode via geocoding package
      try {
        final placemarks = await placemarkFromCoordinates(position.latitude, position.longitude);
        if (placemarks.isNotEmpty) {
          final place = placemarks.first;
          setState(() {
            final line1Parts = [place.name, place.street, place.subLocality]
                .where((e) => e != null && e.isNotEmpty && e != place.locality)
                .toSet()
                .join(', ');
            _line1Controller.text = line1Parts.isNotEmpty ? line1Parts : (place.subLocality ?? place.locality ?? '');
            _line2Controller.text = place.subLocality ?? '';
            _cityController.text = place.locality ?? place.subAdministrativeArea ?? '';
            _stateController.text = place.administrativeArea ?? '';
            _postalCodeController.text = place.postalCode ?? '';
          });
          geocoded = true;
        }
      } catch (_) {}

      // Fallback via OpenStreetMap Nominatim API if native geocoding failed
      if (!geocoded) {
        final dio = Dio();
        final res = await dio.get(
          'https://nominatim.openstreetmap.org/reverse',
          queryParameters: {
            'lat': position.latitude,
            'lon': position.longitude,
            'format': 'json',
          },
          options: Options(headers: {'User-Agent': 'AlangaCustomerApp/1.0'}),
        );
        if (res.data != null && res.data['address'] != null) {
          final addr = res.data['address'] as Map;
          setState(() {
            _line1Controller.text = addr['road'] ?? addr['suburb'] ?? addr['neighbourhood'] ?? '';
            _cityController.text = addr['city'] ?? addr['town'] ?? addr['village'] ?? addr['state_district'] ?? '';
            _stateController.text = addr['state'] ?? '';
            _postalCodeController.text = addr['postcode'] ?? '';
          });
        }
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Live location fetched successfully! Address fields filled.'),
            backgroundColor: AppColors.primaryGreen,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.toString().replaceAll('Exception: ', '')),
            backgroundColor: AppColors.brandRed,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isFetchingLocation = false);
      }
    }
  }

  Future<void> _saveAddress() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSubmitting = true);

    final payload = {
      'fullName': _fullNameController.text.trim(),
      'mobileNumber': _mobileController.text.trim(),
      if (_altMobileController.text.trim().isNotEmpty)
        'alternateMobile': _altMobileController.text.trim(),
      'addressLine1': _line1Controller.text.trim(),
      if (_line2Controller.text.trim().isNotEmpty)
        'addressLine2': _line2Controller.text.trim(),
      if (_landmarkController.text.trim().isNotEmpty)
        'landmark': _landmarkController.text.trim(),
      'city': _cityController.text.trim(),
      'state': _stateController.text.trim(),
      'country': 'India',
      'postalCode': _postalCodeController.text.trim(),
      'addressType': _addressType,
      'isDefault': _isDefault,
    };

    try {
      if (widget.address == null) {
        await context.read<AddressCubit>().createAddress(payload);
      } else {
        await context.read<AddressCubit>().updateAddress(widget.address!.id, payload);
      }
      if (mounted) Navigator.pop(context);
    } catch (e) {
      if (mounted) {
        setState(() => _isSubmitting = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.toString().replaceAll('Exception: ', '')),
            backgroundColor: AppColors.brandRed,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.address != null;

    return Container(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom + 16,
        top: 20,
        left: 20,
        right: 20,
      ),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    isEdit ? 'Edit Address' : 'Add New Address',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF11261B),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close_rounded),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
              const Divider(height: 16),

              // USE LIVE LOCATION BUTTON
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: _isFetchingLocation ? null : _fetchLiveLocation,
                  icon: _isFetchingLocation
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.primaryGreen),
                        )
                      : const Icon(Icons.my_location_rounded, color: AppColors.primaryGreen, size: 18),
                  label: Text(
                    _isFetchingLocation ? 'FETCHING LOCATION...' : 'USE MY LIVE LOCATION',
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, letterSpacing: 0.3),
                  ),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.primaryGreen,
                    side: const BorderSide(color: AppColors.primaryGreen, width: 1.5),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Full Name & Mobile
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _fullNameController,
                      decoration: _inputDecoration('Full Name *', Icons.person_outline),
                      validator: (v) => v == null || v.trim().isEmpty ? 'Required' : null,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextFormField(
                      controller: _mobileController,
                      keyboardType: TextInputType.phone,
                      decoration: _inputDecoration('Mobile Number *', Icons.phone_outlined),
                      validator: (v) => v == null || v.trim().length < 10 ? 'Enter valid mobile' : null,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // Alternate Mobile
              TextFormField(
                controller: _altMobileController,
                keyboardType: TextInputType.phone,
                decoration: _inputDecoration('Alternate Mobile (Optional)', Icons.phone_android_outlined),
              ),
              const SizedBox(height: 12),

              // Address Line 1
              TextFormField(
                controller: _line1Controller,
                decoration: _inputDecoration('House / Flat / Building No., Street *', Icons.home_outlined),
                validator: (v) => v == null || v.trim().isEmpty ? 'Required' : null,
              ),
              const SizedBox(height: 12),

              // Address Line 2 & Landmark
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _line2Controller,
                      decoration: _inputDecoration('Area / Sector (Optional)', Icons.map_outlined),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextFormField(
                      controller: _landmarkController,
                      decoration: _inputDecoration('Landmark (Optional)', Icons.near_me_outlined),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // City, State, Postal Code
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _cityController,
                      decoration: _inputDecoration('City *', Icons.location_city_outlined),
                      validator: (v) => v == null || v.trim().isEmpty ? 'Required' : null,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: TextFormField(
                      controller: _stateController,
                      decoration: _inputDecoration('State *', Icons.domain_outlined),
                      validator: (v) => v == null || v.trim().isEmpty ? 'Required' : null,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: TextFormField(
                      controller: _postalCodeController,
                      keyboardType: TextInputType.number,
                      decoration: _inputDecoration('Pincode *', Icons.pin_drop_outlined),
                      validator: (v) => v == null || v.trim().length < 6 ? 'Invalid' : null,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Address Type Chips
              const Text('Save Address As', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
              const SizedBox(height: 8),
              Row(
                children: ['HOME', 'OFFICE', 'OTHER'].map((type) {
                  final isSelected = _addressType == type;
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: ChoiceChip(
                      label: Text(type),
                      selected: isSelected,
                      selectedColor: AppColors.primaryGreen,
                      labelStyle: TextStyle(
                        color: isSelected ? Colors.white : Colors.black87,
                        fontWeight: FontWeight.bold,
                        fontSize: 11,
                      ),
                      onSelected: (_) => setState(() => _addressType = type),
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 12),

              // Set as default checkbox
              CheckboxListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text('Set as default address', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
                value: _isDefault,
                activeColor: AppColors.primaryGreen,
                onChanged: (val) => setState(() => _isDefault = val ?? false),
              ),
              const SizedBox(height: 16),

              // Submit Button
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  onPressed: _isSubmitting ? null : _saveAddress,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF1A3827),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: _isSubmitting
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                        )
                      : Text(
                          isEdit ? 'UPDATE ADDRESS' : 'SAVE ADDRESS',
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  InputDecoration _inputDecoration(String label, IconData icon) {
    return InputDecoration(
      labelText: label,
      labelStyle: const TextStyle(fontSize: 12, color: Color(0xFF7A9A86)),
      prefixIcon: Icon(icon, size: 18, color: AppColors.primaryGreen),
      isDense: true,
      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: Color(0xFFE4ECE8)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: AppColors.primaryGreen, width: 1.5),
      ),
    );
  }
}
