import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../bloc/register/register_bloc.dart';
import '../bloc/register/register_event.dart';
import '../bloc/register/register_state.dart';
import '../../domain/entities/user_entity.dart';
import '../../../../core/dependency_injection/injection.dart';
import '../../../../core/constants/app_colors.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey0 = GlobalKey<FormState>();
  final _formKey1 = GlobalKey<FormState>();
  final _formKey2 = GlobalKey<FormState>();
  final _formKey3 = GlobalKey<FormState>();
  final _formKey4 = GlobalKey<FormState>();

  int _currentStep = 0;

  // Step 1: Personal & Login Info
  final _fullNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _countryCodeController = TextEditingController(text: '+91');
  final _mobileNumberController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  // Step 2: Business Identity
  final _businessNameController = TextEditingController();
  final _legalNameController = TextEditingController();
  String _businessType = 'Individual Seller';

  // Step 3: Tax & Legal (KYC)
  final _panNumberController = TextEditingController();
  final _gstNumberController = TextEditingController();

  // Step 4: Pickup & Warehouse Address
  final _pickupAddress1Controller = TextEditingController();
  final _pickupAddress2Controller = TextEditingController();
  final _cityController = TextEditingController();
  final _stateController = TextEditingController();
  final _pincodeController = TextEditingController();
  final _pickupPhoneController = TextEditingController();

  // Step 5: Bank Details (Payouts)
  final _bankHolderController = TextEditingController();
  final _bankAccountController = TextEditingController();
  final _confirmBankAccountController = TextEditingController();
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

  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

  late final RegisterBloc _registerBloc;

  @override
  void initState() {
    super.initState();
    _registerBloc = sl<RegisterBloc>();
  }

  @override
  void dispose() {
    _registerBloc.close();
    _fullNameController.dispose();
    _emailController.dispose();
    _countryCodeController.dispose();
    _mobileNumberController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();

    _businessNameController.dispose();
    _legalNameController.dispose();

    _panNumberController.dispose();
    _gstNumberController.dispose();

    _pickupAddress1Controller.dispose();
    _pickupAddress2Controller.dispose();
    _cityController.dispose();
    _stateController.dispose();
    _pincodeController.dispose();
    _pickupPhoneController.dispose();

    _bankHolderController.dispose();
    _bankAccountController.dispose();
    _confirmBankAccountController.dispose();
    _bankIfscController.dispose();
    _bankNameController.dispose();

    super.dispose();
  }

  void _nextStep() {
    if (_currentStep == 0) {
      if (_formKey0.currentState!.validate()) {
        setState(() => _currentStep = 1);
      }
    } else if (_currentStep == 1) {
      if (_formKey1.currentState!.validate()) {
        setState(() => _currentStep = 2);
      }
    } else if (_currentStep == 2) {
      if (_formKey2.currentState!.validate()) {
        setState(() => _currentStep = 3);
      }
    } else if (_currentStep == 3) {
      if (_formKey3.currentState!.validate()) {
        setState(() => _currentStep = 4);
      }
    }
  }

  void _previousStep() {
    if (_currentStep > 0) {
      setState(() => _currentStep--);
    }
  }

  void _submitRegistration() {
    if (!_formKey4.currentState!.validate()) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please check highlighted fields before submitting.'),
          backgroundColor: Colors.redAccent,
        ),
      );
      return;
    }

    final phone = _mobileNumberController.text.trim();
    final pickupPhone = _pickupPhoneController.text.trim().isEmpty
        ? phone
        : _pickupPhoneController.text.trim();

    _registerBloc.add(
      RegisterSubmittedEvent(
        fullName: _fullNameController.text.trim(),
        email: _emailController.text.trim().toLowerCase(),
        countryCode: _countryCodeController.text.trim(),
        mobileNumber: phone,
        password: _passwordController.text,
        confirmPassword: _confirmPasswordController.text,
        role: UserRole.vendor,
        // 1. Business Identity
        businessName: _businessNameController.text.trim().isEmpty
            ? _fullNameController.text.trim()
            : _businessNameController.text.trim(),
        legalName: _legalNameController.text.trim().isEmpty
            ? null
            : _legalNameController.text.trim(),
        businessType: _businessType,
        // 2. Tax & Legal (KYC)
        panNumber: _panNumberController.text.trim().isEmpty
            ? null
            : _panNumberController.text.trim().toUpperCase(),
        gstNumber: _gstNumberController.text.trim().isEmpty
            ? null
            : _gstNumberController.text.trim().toUpperCase(),
        // 3. Pickup & Warehouse Address
        pickupAddressLine1: _pickupAddress1Controller.text.trim().isEmpty
            ? null
            : _pickupAddress1Controller.text.trim(),
        pickupAddressLine2: _pickupAddress2Controller.text.trim().isEmpty
            ? null
            : _pickupAddress2Controller.text.trim(),
        city: _cityController.text.trim(),
        state: _stateController.text.trim(),
        pincode: _pincodeController.text.trim(),
        pickupContactPhone: pickupPhone,
        // 4. Bank Account Details (Payouts)
        bankAccountHolderName: _bankHolderController.text.trim().isEmpty
            ? null
            : _bankHolderController.text.trim(),
        bankAccountNumber: _bankAccountController.text.trim().isEmpty
            ? null
            : _bankAccountController.text.trim(),
        bankIfscCode: _bankIfscController.text.trim().isEmpty
            ? null
            : _bankIfscController.text.trim().toUpperCase(),
        bankName: _bankNameController.text.trim().isEmpty
            ? null
            : _bankNameController.text.trim(),
        bankAccountType: _bankAccountType,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isTablet = size.width > 600;

    return BlocProvider.value(
      value: _registerBloc,
      child: Scaffold(
        backgroundColor: const Color(0xFFE6EFEA),
        appBar: AppBar(
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Color(0xFF0F2016)),
            onPressed: () => context.go('/login'),
          ),
          elevation: 0,
          backgroundColor: Colors.transparent,
        ),
        extendBodyBehindAppBar: true,
        body: Center(
          child: SingleChildScrollView(
            keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
            padding: const EdgeInsets.only(
              left: 20.0,
              right: 20.0,
              top: kToolbarHeight + 10.0,
              bottom: 24.0,
            ),
            child: ConstrainedBox(
              constraints: BoxConstraints(
                maxWidth: isTablet ? 480 : double.infinity,
              ),
              child: BlocConsumer<RegisterBloc, RegisterState>(
                listener: (context, state) {
                  if (state is RegisterSuccess) {
                    context.go('/success');
                  } else if (state is RegisterFailure) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(state.errorMessage),
                        backgroundColor: AppColors.brandRed,
                      ),
                    );
                  }
                },
                builder: (context, state) {
                  return Container(
                    padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 28),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.06),
                          blurRadius: 20,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // Small Brand Logo Asset
                        Center(
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: Image.asset(
                              'assets/images/app_icon.jpg',
                              height: 56,
                              width: 56,
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                        const SizedBox(height: 10),
                        // Title
                        const Text(
                          'Seller Onboarding',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF0F2016),
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          _getStepSubTitle(),
                          style: const TextStyle(
                            fontSize: 12,
                            color: AppColors.textSecondaryLight,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 20),

                        // Progress Indicator Row (5 Steps)
                        SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              _buildStepIndicator(0, 'Login'),
                              _buildStepLine(),
                              _buildStepIndicator(1, 'Business'),
                              _buildStepLine(),
                              _buildStepIndicator(2, 'Tax & KYC'),
                              _buildStepLine(),
                              _buildStepIndicator(3, 'Pickup'),
                              _buildStepLine(),
                              _buildStepIndicator(4, 'Bank'),
                            ],
                          ),
                        ),
                        const SizedBox(height: 24),

                        // Step Forms
                        if (_currentStep == 0) _buildPersonalInfoForm(),
                        if (_currentStep == 1) _buildBusinessInfoForm(),
                        if (_currentStep == 2) _buildTaxInfoForm(),
                        if (_currentStep == 3) _buildPickupAddressForm(),
                        if (_currentStep == 4) _buildBankDetailsForm(state),

                        const SizedBox(height: 28),

                        // Navigation Buttons
                        Row(
                          children: [
                            if (_currentStep > 0)
                              SizedBox(
                                width: 95,
                                child: OutlinedButton(
                                  onPressed: state is RegisterLoading ? null : _previousStep,
                                  style: OutlinedButton.styleFrom(
                                    padding: const EdgeInsets.symmetric(vertical: 14),
                                    side: const BorderSide(color: Color(0xFF1A3827)),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                  ),
                                  child: const Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(Icons.arrow_back_rounded, size: 16, color: Color(0xFF1A3827)),
                                      SizedBox(width: 4),
                                      Text(
                                        'BACK',
                                        style: TextStyle(
                                          color: Color(0xFF1A3827),
                                          fontWeight: FontWeight.bold,
                                          fontSize: 12,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            if (_currentStep > 0) const SizedBox(width: 12),
                            Expanded(
                              child: ElevatedButton(
                                onPressed: state is RegisterLoading
                                    ? null
                                    : () {
                                        if (_currentStep < 4) {
                                          _nextStep();
                                        } else {
                                          _submitRegistration();
                                        }
                                      },
                                style: ElevatedButton.styleFrom(
                                  padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
                                  backgroundColor: const Color(0xFF1A3827),
                                  foregroundColor: Colors.white,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  elevation: 1,
                                ),
                                child: state is RegisterLoading
                                    ? const SizedBox(
                                        height: 18,
                                        width: 18,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                          color: Colors.white,
                                        ),
                                      )
                                    : FittedBox(
                                        fit: BoxFit.scaleDown,
                                        child: Row(
                                          mainAxisAlignment: MainAxisAlignment.center,
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Text(
                                              _currentStep == 4 ? 'COMPLETE REGISTRATION' : 'NEXT',
                                              style: const TextStyle(
                                                fontSize: 14,
                                                fontWeight: FontWeight.bold,
                                                letterSpacing: 0.5,
                                              ),
                                            ),
                                            const SizedBox(width: 8),
                                            Icon(
                                              _currentStep == 4
                                                  ? Icons.check_circle_outline_rounded
                                                  : Icons.arrow_forward_rounded,
                                              size: 18,
                                            ),
                                          ],
                                        ),
                                      ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),

                        // Link to Login
                        if (state is! RegisterLoading)
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Text(
                                "Already registered? ",
                                style: TextStyle(color: AppColors.textSecondaryLight, fontSize: 13),
                              ),
                              TextButton(
                                onPressed: () => context.go('/login'),
                                style: TextButton.styleFrom(padding: EdgeInsets.zero),
                                child: const Text(
                                  'Login Here',
                                  style: TextStyle(color: Color(0xFF1A3827), fontWeight: FontWeight.bold),
                                ),
                              ),
                            ],
                          ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ),
        ),
      ),
    );
  }

  String _getStepSubTitle() {
    switch (_currentStep) {
      case 0:
        return 'Step 1 of 5: Account & Login Credentials';
      case 1:
        return 'Step 2 of 5: Business Identity';
      case 2:
        return 'Step 3 of 5: Tax & Legal (KYC)';
      case 3:
        return 'Step 4 of 5: Pickup & Warehouse Address';
      case 4:
        return 'Step 5 of 5: Bank Account Details (Payouts)';
      default:
        return '';
    }
  }

  Widget _buildStepIndicator(int stepIndex, String title) {
    final isActive = _currentStep == stepIndex;
    final isCompleted = _currentStep > stepIndex;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4.0),
      child: Column(
        children: [
          Container(
            width: 28,
            height: 28,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: isCompleted
                  ? AppColors.primaryGreen
                  : isActive
                      ? AppColors.primaryGreen
                      : const Color(0xFFD1DDD6),
              border: isActive
                  ? Border.all(color: AppColors.primaryGreen, width: 2)
                  : null,
            ),
            child: Center(
              child: isCompleted
                  ? const Icon(Icons.check, size: 14, color: Colors.white)
                  : Text(
                      '${stepIndex + 1}',
                      style: TextStyle(
                        color: isActive || isCompleted ? Colors.white : AppColors.textSecondaryLight,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
            ),
          ),
          const SizedBox(height: 3),
          Text(
            title,
            style: TextStyle(
              fontSize: 9,
              color: isActive ? AppColors.primaryGreen : AppColors.textSecondaryLight,
              fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
            ),
          )
        ],
      ),
    );
  }

  Widget _buildStepLine() {
    return Container(
      width: 18,
      height: 2,
      margin: const EdgeInsets.only(bottom: 12),
      color: const Color(0xFFD1DDD6),
    );
  }

  // Step 0: Personal & Login Form
  Widget _buildPersonalInfoForm() {
    return Form(
      key: _formKey0,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          TextFormField(
            controller: _fullNameController,
            style: const TextStyle(color: Color(0xFF0F2016), fontSize: 14),
            decoration: _buildInputDecoration('Full Name / Owner Name', Icons.person_outline),
            validator: (value) {
              if (value == null || value.trim().isEmpty) return 'Please enter your full name';
              if (value.trim().length < 2) return 'Name must be at least 2 characters';
              return null;
            },
          ),
          const SizedBox(height: 14),
          TextFormField(
            controller: _emailController,
            style: const TextStyle(color: Color(0xFF0F2016), fontSize: 14),
            decoration: _buildInputDecoration('Email Address', Icons.email_outlined),
            keyboardType: TextInputType.emailAddress,
            validator: (value) {
              if (value == null || value.trim().isEmpty) return 'Please enter your email';
              final emailRegex = RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$', caseSensitive: false);
              if (!emailRegex.hasMatch(value.trim())) return 'Please enter a valid email';
              return null;
            },
          ),
          const SizedBox(height: 14),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                width: 70,
                child: TextFormField(
                  controller: _countryCodeController,
                  style: const TextStyle(color: Color(0xFF0F2016), fontSize: 14),
                  decoration: _buildInputDecoration('Code', null),
                  keyboardType: TextInputType.phone,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) return 'Required';
                    return null;
                  },
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: TextFormField(
                  controller: _mobileNumberController,
                  style: const TextStyle(color: Color(0xFF0F2016), fontSize: 14),
                  decoration: _buildInputDecoration('Mobile Number', Icons.phone_outlined),
                  keyboardType: TextInputType.phone,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) return 'Please enter mobile number';
                    if (!RegExp(r'^\d{7,15}$').hasMatch(value.trim())) {
                      return 'Must be 7 to 15 digits';
                    }
                    return null;
                  },
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          TextFormField(
            controller: _passwordController,
            obscureText: _obscurePassword,
            style: const TextStyle(color: Color(0xFF0F2016), fontSize: 14),
            decoration: _buildInputDecoration('Password', Icons.lock_outline).copyWith(
              suffixIcon: IconButton(
                icon: Icon(
                  _obscurePassword ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                  color: AppColors.textSecondaryLight,
                  size: 20,
                ),
                onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
              ),
            ),
            validator: (value) {
              if (value == null || value.isEmpty) return 'Please enter a password';
              if (value.length < 8) return 'Password must be at least 8 characters';
              if (!RegExp(r'(?=.*[a-z])').hasMatch(value)) return 'Must contain a lowercase letter';
              if (!RegExp(r'(?=.*[A-Z])').hasMatch(value)) return 'Must contain an uppercase letter';
              if (!RegExp(r'(?=.*\d)').hasMatch(value)) return 'Must contain a digit';
              if (!RegExp(r'(?=.*[@$!%*?&])').hasMatch(value)) return r'Must contain a special char (@$!%*?&)';
              return null;
            },
          ),
          const SizedBox(height: 14),
          TextFormField(
            controller: _confirmPasswordController,
            obscureText: _obscureConfirmPassword,
            style: const TextStyle(color: Color(0xFF0F2016), fontSize: 14),
            decoration: _buildInputDecoration('Confirm Password', Icons.lock_outline).copyWith(
              suffixIcon: IconButton(
                icon: Icon(
                  _obscureConfirmPassword ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                  color: AppColors.textSecondaryLight,
                  size: 20,
                ),
                onPressed: () => setState(() => _obscureConfirmPassword = !_obscureConfirmPassword),
              ),
            ),
            validator: (value) {
              if (value == null || value.isEmpty) return 'Please confirm your password';
              if (value != _passwordController.text) return 'Passwords do not match';
              return null;
            },
          ),
        ],
      ),
    );
  }

  // Step 1: Business Identity Form
  Widget _buildBusinessInfoForm() {
    return Form(
      key: _formKey1,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          TextFormField(
            controller: _businessNameController,
            style: const TextStyle(color: Color(0xFF0F2016), fontSize: 14),
            decoration: _buildInputDecoration('Store / Display Name *', Icons.storefront_outlined),
            validator: (value) {
              if (value == null || value.trim().isEmpty) return 'Please enter your Store Name';
              return null;
            },
          ),
          const SizedBox(height: 14),
          TextFormField(
            controller: _legalNameController,
            style: const TextStyle(color: Color(0xFF0F2016), fontSize: 14),
            decoration: _buildInputDecoration('Legal Entity Name (As on PAN/GST)', Icons.badge_outlined),
          ),
          const SizedBox(height: 14),
          DropdownButtonFormField<String>(
            value: _businessType,
            style: const TextStyle(color: Color(0xFF0F2016), fontSize: 14),
            decoration: _buildInputDecoration('Business Type', Icons.category_outlined),
            items: _businessTypes.map((type) {
              return DropdownMenuItem(value: type, child: Text(type));
            }).toList(),
            onChanged: (val) {
              if (val != null) setState(() => _businessType = val);
            },
          ),
        ],
      ),
    );
  }

  // Step 2: Tax & Legal (KYC) Form
  Widget _buildTaxInfoForm() {
    return Form(
      key: _formKey2,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFFE8F4EC),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Row(
              children: [
                Icon(Icons.info_outline, color: Color(0xFF1A3827), size: 20),
                SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'PAN and GST are required for legal payouts and tax compliance. You can also update them later in KYC Settings.',
                    style: TextStyle(fontSize: 11, color: Color(0xFF1A3827)),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _panNumberController,
            textCapitalization: TextCapitalization.characters,
            style: const TextStyle(color: Color(0xFF0F2016), fontSize: 14),
            decoration: _buildInputDecoration('PAN Number (e.g. ABCDE1234F)', Icons.credit_card_outlined),
            validator: (value) {
              if (value != null && value.trim().isNotEmpty) {
                final panRegex = RegExp(r'^[A-Z]{5}[0-9]{4}[A-Z]{1}$');
                if (!panRegex.hasMatch(value.trim().toUpperCase())) {
                  return 'Invalid PAN format (e.g. ABCDE1234F)';
                }
              }
              return null;
            },
          ),
          const SizedBox(height: 14),
          TextFormField(
            controller: _gstNumberController,
            textCapitalization: TextCapitalization.characters,
            style: const TextStyle(color: Color(0xFF0F2016), fontSize: 14),
            decoration: _buildInputDecoration('GSTIN Number (Optional for exempt)', Icons.receipt_long_outlined),
            validator: (value) {
              if (value != null && value.trim().isNotEmpty) {
                final gstRegex = RegExp(r'^[0-9]{2}[A-Z]{5}[0-9]{4}[A-Z]{1}[1-9A-Z]{1}Z[0-9A-Z]{1}$');
                if (!gstRegex.hasMatch(value.trim().toUpperCase())) {
                  return 'Invalid GSTIN format (15 digits)';
                }
              }
              return null;
            },
          ),
        ],
      ),
    );
  }

  // Step 3: Pickup & Warehouse Address Form
  Widget _buildPickupAddressForm() {
    return Form(
      key: _formKey3,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          TextFormField(
            controller: _pickupAddress1Controller,
            style: const TextStyle(color: Color(0xFF0F2016), fontSize: 14),
            decoration: _buildInputDecoration('Pickup Address Line 1 / Street *', Icons.location_on_outlined),
            validator: (value) {
              if (value == null || value.trim().isEmpty) return 'Please enter pickup address';
              return null;
            },
          ),
          const SizedBox(height: 14),
          TextFormField(
            controller: _pickupAddress2Controller,
            style: const TextStyle(color: Color(0xFF0F2016), fontSize: 14),
            decoration: _buildInputDecoration('Address Line 2 / Landmark (Optional)', Icons.navigation_outlined),
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: TextFormField(
                  controller: _cityController,
                  style: const TextStyle(color: Color(0xFF0F2016), fontSize: 14),
                  decoration: _buildInputDecoration('City *', Icons.location_city_outlined),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) return 'City is required';
                    return null;
                  },
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: TextFormField(
                  controller: _stateController,
                  style: const TextStyle(color: Color(0xFF0F2016), fontSize: 14),
                  decoration: _buildInputDecoration('State *', Icons.map_outlined),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) return 'State is required';
                    return null;
                  },
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: TextFormField(
                  controller: _pincodeController,
                  style: const TextStyle(color: Color(0xFF0F2016), fontSize: 14),
                  decoration: _buildInputDecoration('Pincode *', Icons.pin_drop_outlined),
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) return 'Pincode required';
                    if (value.trim().length != 6) return 'Must be 6 digits';
                    return null;
                  },
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: TextFormField(
                  controller: _pickupPhoneController,
                  style: const TextStyle(color: Color(0xFF0F2016), fontSize: 14),
                  decoration: _buildInputDecoration('Pickup Phone', Icons.phone_callback_outlined),
                  keyboardType: TextInputType.phone,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // Step 4: Bank Details Form
  Widget _buildBankDetailsForm(RegisterState state) {
    return Form(
      key: _formKey4,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFFE8F4EC),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Row(
              children: [
                Icon(Icons.account_balance_outlined, color: Color(0xFF1A3827), size: 20),
                SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Bank details are used for weekly seller payouts. You can also review or update them anytime from your KYC Dashboard.',
                    style: TextStyle(fontSize: 11, color: Color(0xFF1A3827)),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _bankHolderController,
            style: const TextStyle(color: Color(0xFF0F2016), fontSize: 14),
            decoration: _buildInputDecoration('Account Holder Name', Icons.person_pin_outlined),
          ),
          const SizedBox(height: 14),
          TextFormField(
            controller: _bankAccountController,
            style: const TextStyle(color: Color(0xFF0F2016), fontSize: 14),
            decoration: _buildInputDecoration('Bank Account Number', Icons.numbers_outlined),
            keyboardType: TextInputType.number,
          ),
          const SizedBox(height: 14),
          TextFormField(
            controller: _confirmBankAccountController,
            style: const TextStyle(color: Color(0xFF0F2016), fontSize: 14),
            decoration: _buildInputDecoration('Confirm Account Number', Icons.numbers_outlined),
            keyboardType: TextInputType.number,
            validator: (value) {
              if (_bankAccountController.text.trim().isNotEmpty &&
                  value != _bankAccountController.text) {
                return 'Account numbers do not match';
              }
              return null;
            },
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: TextFormField(
                  controller: _bankIfscController,
                  textCapitalization: TextCapitalization.characters,
                  style: const TextStyle(color: Color(0xFF0F2016), fontSize: 14),
                  decoration: _buildInputDecoration('IFSC Code', Icons.qr_code_outlined),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: DropdownButtonFormField<String>(
                  value: _bankAccountType,
                  style: const TextStyle(color: Color(0xFF0F2016), fontSize: 14),
                  decoration: _buildInputDecoration('Type', null),
                  items: _accountTypes.map((t) {
                    return DropdownMenuItem(value: t, child: Text(t));
                  }).toList(),
                  onChanged: (val) {
                    if (val != null) setState(() => _bankAccountType = val);
                  },
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          TextFormField(
            controller: _bankNameController,
            style: const TextStyle(color: Color(0xFF0F2016), fontSize: 14),
            decoration: _buildInputDecoration('Bank Name (e.g. HDFC Bank, SBI)', Icons.account_balance_outlined),
          ),
        ],
      ),
    );
  }

  InputDecoration _buildInputDecoration(String label, IconData? icon) {
    return InputDecoration(
      labelText: label,
      labelStyle: const TextStyle(color: AppColors.textSecondaryLight, fontSize: 13),
      prefixIcon: icon != null
          ? Icon(icon, color: const Color(0xFF1A3827), size: 20)
          : null,
      filled: true,
      fillColor: const Color(0xFFF7FAF8),
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: Color(0xFFDCE6E1)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: Color(0xFFDCE6E1)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: Color(0xFF1A3827), width: 1.5),
      ),
    );
  }
}
