import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/dependency_injection/injection.dart';
import '../../data/models/vendor_profile_model.dart';
import '../../domain/repositories/vendor_profile_repository.dart';
import '../../../../core/widgets/custom_app_bar.dart';

class StoreKycScreen extends StatefulWidget {
  const StoreKycScreen({super.key});

  @override
  State<StoreKycScreen> createState() => _StoreKycScreenState();
}

class _StoreKycScreenState extends State<StoreKycScreen> {
  final _repository = sl<VendorProfileRepository>();
  bool _isLoading = true;
  bool _isSaving = false;
  String? _errorMessage;
  VendorProfileModel? _profile;

  // Controllers
  // 1. Business Identity
  final _storeNameController = TextEditingController();
  final _legalNameController = TextEditingController();
  final _businessDescriptionController = TextEditingController();
  String _businessType = 'Individual Seller';

  // 2. Tax & Legal (KYC)
  final _panController = TextEditingController();
  final _gstController = TextEditingController();

  // 3. Pickup Warehouse Address
  final _pickup1Controller = TextEditingController();
  final _pickup2Controller = TextEditingController();
  final _cityController = TextEditingController();
  final _stateController = TextEditingController();
  final _pincodeController = TextEditingController();
  final _pickupPhoneController = TextEditingController();

  // 4. Bank Account Details
  final _bankHolderController = TextEditingController();
  final _bankAccountController = TextEditingController();
  final _bankIfscController = TextEditingController();
  final _bankNameController = TextEditingController();
  String _bankAccountType = 'CURRENT';



  final List<String> _businessTypes = [
    'Individual Seller',
    'Proprietorship',
    'Partnership Firm',
    'Private Limited (Pvt Ltd)',
    'Public Limited',
    'Retailer / Wholesaler',
    'Manufacturer'
  ];

  final List<String> _accountTypes = ['CURRENT', 'SAVINGS'];

  @override
  void initState() {
    super.initState();
    _fetchProfile();
  }

  @override
  void dispose() {
    _storeNameController.dispose();
    _legalNameController.dispose();
    _businessDescriptionController.dispose();
    _panController.dispose();
    _gstController.dispose();
    _pickup1Controller.dispose();
    _pickup2Controller.dispose();
    _cityController.dispose();
    _stateController.dispose();
    _pincodeController.dispose();
    _pickupPhoneController.dispose();
    _bankHolderController.dispose();
    _bankAccountController.dispose();
    _bankIfscController.dispose();
    _bankNameController.dispose();
    super.dispose();
  }

  Future<void> _fetchProfile() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final profile = await _repository.getProfile();
      if (!mounted) return;
      setState(() {
        _profile = profile;
        _isLoading = false;

        // Populate controllers
        _storeNameController.text = profile.storeName;
        _legalNameController.text = profile.legalName ?? '';
        _businessDescriptionController.text = profile.businessDescription ?? '';
        if (_businessTypes.contains(profile.businessType)) {
          _businessType = profile.businessType;
        }

        _panController.text = profile.panNumber ?? '';
        _gstController.text = profile.gstNumber ?? '';

        _pickup1Controller.text = profile.pickupAddressLine1 ?? '';
        _pickup2Controller.text = profile.pickupAddressLine2 ?? '';
        _cityController.text = profile.pickupCity ?? '';
        _stateController.text = profile.pickupState ?? '';
        _pincodeController.text = profile.pickupPincode ?? '';
        _pickupPhoneController.text = profile.pickupContactPhone ?? '';

        _bankHolderController.text = profile.bankAccountHolderName ?? '';
        _bankAccountController.text = profile.bankAccountNumber ?? '';
        _bankIfscController.text = profile.bankIfscCode ?? '';
        _bankNameController.text = profile.bankName ?? '';
        if (_accountTypes.contains(profile.bankAccountType)) {
          _bankAccountType = profile.bankAccountType;
        }
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
        _errorMessage = 'Failed to load KYC and store profile: $e';
      });
    }
  }

  Future<void> _saveProfile() async {
    setState(() => _isSaving = true);

    try {
      final updateData = {
        'storeName': _storeNameController.text.trim(),
        'legalName': _legalNameController.text.trim().isEmpty ? null : _legalNameController.text.trim(),
        'businessType': _businessType,
        'businessDescription': _businessDescriptionController.text.trim().isEmpty ? null : _businessDescriptionController.text.trim(),
        'panNumber': _panController.text.trim().isEmpty ? null : _panController.text.trim().toUpperCase(),
        'gstNumber': _gstController.text.trim().isEmpty ? null : _gstController.text.trim().toUpperCase(),
        'pickupAddressLine1': _pickup1Controller.text.trim().isEmpty ? null : _pickup1Controller.text.trim(),
        'pickupAddressLine2': _pickup2Controller.text.trim().isEmpty ? null : _pickup2Controller.text.trim(),
        'pickupCity': _cityController.text.trim().isEmpty ? null : _cityController.text.trim(),
        'pickupState': _stateController.text.trim().isEmpty ? null : _stateController.text.trim(),
        'pickupPincode': _pincodeController.text.trim().isEmpty ? null : _pincodeController.text.trim(),
        'pickupContactPhone': _pickupPhoneController.text.trim().isEmpty ? null : _pickupPhoneController.text.trim(),
        'bankAccountHolderName': _bankHolderController.text.trim().isEmpty ? null : _bankHolderController.text.trim(),
        'bankAccountNumber': _bankAccountController.text.trim().isEmpty ? null : _bankAccountController.text.trim(),
        'bankIfscCode': _bankIfscController.text.trim().isEmpty ? null : _bankIfscController.text.trim().toUpperCase(),
        'bankName': _bankNameController.text.trim().isEmpty ? null : _bankNameController.text.trim(),
        'bankAccountType': _bankAccountType,
      };

      final updated = await _repository.updateProfile(updateData);
      if (!mounted) return;
      setState(() {
        _profile = updated;
        _isSaving = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Store KYC & Bank Details updated successfully!'),
          backgroundColor: AppColors.primaryGreen,
        ),
      );
    } catch (e) {
      if (!mounted) return;
      setState(() => _isSaving = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to update details: $e'),
          backgroundColor: AppColors.brandRed,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6F8F6),
      appBar: const CustomAppBar(
        titleText: 'Store KYC & Bank Details',
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: AppColors.primaryGreen))
          : _errorMessage != null
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(_errorMessage!, style: const TextStyle(color: AppColors.brandRed)),
                      const SizedBox(height: 12),
                      ElevatedButton(
                        onPressed: _fetchProfile,
                        style: ElevatedButton.styleFrom(backgroundColor: AppColors.primaryGreen),
                        child: const Text('RETRY'),
                      ),
                    ],
                  ),
                )
              : SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // KYC Status Banner Card
                      _buildKycStatusBanner(),
                      const SizedBox(height: 16),

                      // Section 1: Business Identity
                      _buildSectionCard(
                        title: '1. Business Identity',
                        icon: Icons.storefront_outlined,
                        children: [
                          _buildTextField(_storeNameController, 'Store / Brand Display Name *'),
                          const SizedBox(height: 12),
                          _buildTextField(_legalNameController, 'Legal Business Name (On PAN/GST)'),
                          const SizedBox(height: 12),
                          DropdownButtonFormField<String>(
                            value: _businessType,
                            decoration: _buildInputDecoration('Business Entity Type'),
                            items: _businessTypes.map((t) => DropdownMenuItem(value: t, child: Text(t))).toList(),
                            onChanged: (val) {
                              if (val != null) setState(() => _businessType = val);
                            },
                          ),
                          const SizedBox(height: 12),
                          _buildTextField(_businessDescriptionController, 'Business Description / Tagline', maxLines: 2),
                        ],
                      ),
                      const SizedBox(height: 16),

                      // Section 2: Tax & Legal (KYC)
                      _buildSectionCard(
                        title: '2. Tax & Legal (KYC)',
                        icon: Icons.badge_outlined,
                        children: [
                          _buildTextField(
                            _panController,
                            'Permanent Account Number (PAN) *',
                            textCapitalization: TextCapitalization.characters,
                          ),
                          const SizedBox(height: 12),
                          _buildTextField(
                            _gstController,
                            'GSTIN Number (Goods & Services Tax)',
                            textCapitalization: TextCapitalization.characters,
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),

                      // Section 3: Pickup & Warehouse Address
                      _buildSectionCard(
                        title: '3. Pickup & Warehouse Address',
                        icon: Icons.local_shipping_outlined,
                        children: [
                          _buildTextField(_pickup1Controller, 'Address Line 1 / Street / Warehouse *'),
                          const SizedBox(height: 12),
                          _buildTextField(_pickup2Controller, 'Address Line 2 / Area / Landmark'),
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              Expanded(child: _buildTextField(_cityController, 'City *')),
                              const SizedBox(width: 10),
                              Expanded(child: _buildTextField(_stateController, 'State *')),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              Expanded(
                                child: _buildTextField(
                                  _pincodeController,
                                  'Pincode *',
                                  keyboardType: TextInputType.number,
                                ),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: _buildTextField(
                                  _pickupPhoneController,
                                  'Warehouse Contact Phone',
                                  keyboardType: TextInputType.phone,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),

                      // Section 4: Bank Account Details (Payouts)
                      _buildSectionCard(
                        title: '4. Bank Account Details (Payouts)',
                        icon: Icons.account_balance_outlined,
                        children: [
                          _buildTextField(_bankHolderController, 'Account Beneficiary Name *'),
                          const SizedBox(height: 12),
                          _buildTextField(
                            _bankAccountController,
                            'Bank Account Number *',
                            keyboardType: TextInputType.number,
                          ),
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              Expanded(
                                child: _buildTextField(
                                  _bankIfscController,
                                  'IFSC Code *',
                                  textCapitalization: TextCapitalization.characters,
                                ),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: DropdownButtonFormField<String>(
                                  value: _bankAccountType,
                                  decoration: _buildInputDecoration('Account Type'),
                                  items: _accountTypes.map((t) => DropdownMenuItem(value: t, child: Text(t))).toList(),
                                  onChanged: (val) {
                                    if (val != null) setState(() => _bankAccountType = val);
                                  },
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          _buildTextField(_bankNameController, 'Bank Name (e.g. HDFC, ICICI, SBI)'),
                        ],
                      ),

                    ],
                  ),
                ),
      bottomSheet: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, -3),
            ),
          ],
        ),
        child: SafeArea(
          child: SizedBox(
            width: double.infinity,
            height: 48,
            child: ElevatedButton(
              onPressed: _isSaving ? null : _saveProfile,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryGreen,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                elevation: 0,
              ),
              child: _isSaving
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                    )
                  : const Text(
                      'SAVE KYC & BANK DETAILS',
                      style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, letterSpacing: 0.5),
                    ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildKycStatusBanner() {
    final status = _profile?.kycStatus ?? 'NOT_SUBMITTED';
    Color bgColor;
    Color textColor;
    IconData icon;
    String statusTitle;
    String statusDesc;

    if (status == 'VERIFIED') {
      bgColor = const Color(0xFFE8F5E9);
      textColor = const Color(0xFF2E7D32);
      icon = Icons.check_circle_rounded;
      statusTitle = 'KYC Verified ✓';
      statusDesc = 'Your store identity and bank account are approved for instant payouts.';
    } else if (status == 'PENDING') {
      bgColor = const Color(0xFFFFF3E0);
      textColor = const Color(0xFFE65100);
      icon = Icons.hourglass_top_rounded;
      statusTitle = 'Verification Under Review';
      statusDesc = 'Your KYC & bank details have been submitted and are being reviewed.';
    } else {
      bgColor = const Color(0xFFE3F2FD);
      textColor = const Color(0xFF1565C0);
      icon = Icons.info_rounded;
      statusTitle = 'KYC Incomplete';
      statusDesc = 'Please complete Tax, Warehouse & Bank Details to activate seller payouts.';
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: textColor.withOpacity(0.3)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: textColor, size: 28),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  statusTitle,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: textColor,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  statusDesc,
                  style: TextStyle(
                    fontSize: 12,
                    color: textColor.withOpacity(0.85),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionCard({
    required String title,
    required IconData icon,
    required List<Widget> children,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: AppColors.primaryGreen, size: 20),
              const SizedBox(width: 8),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF0F2016),
                ),
              ),
            ],
          ),
          const Divider(height: 20, color: Color(0xFFEAEAEA)),
          ...children,
        ],
      ),
    );
  }

  Widget _buildTextField(
    TextEditingController controller,
    String label, {
    int maxLines = 1,
    TextInputType keyboardType = TextInputType.text,
    TextCapitalization textCapitalization = TextCapitalization.none,
  }) {
    return TextFormField(
      controller: controller,
      maxLines: maxLines,
      keyboardType: keyboardType,
      textCapitalization: textCapitalization,
      style: const TextStyle(fontSize: 14, color: Color(0xFF0F2016)),
      decoration: _buildInputDecoration(label),
    );
  }

  InputDecoration _buildInputDecoration(String label) {
    return InputDecoration(
      labelText: label,
      labelStyle: const TextStyle(color: AppColors.textSecondaryLight, fontSize: 13),
      filled: true,
      fillColor: const Color(0xFFF9FBFA),
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: Color(0xFFDCE6E1)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: Color(0xFFDCE6E1)),
      ),
      focusedBorder: const OutlineInputBorder(
        borderRadius: BorderRadius.all(Radius.circular(8)),
        borderSide: BorderSide(color: AppColors.primaryGreen, width: 1.5),
      ),
    );
  }
}
