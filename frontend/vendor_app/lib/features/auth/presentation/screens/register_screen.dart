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

  int _currentStep = 0;

  // Step 1: Personal Info
  final _fullNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _countryCodeController = TextEditingController(text: '+91');
  final _mobileNumberController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  // Step 2: Business Info
  final _businessNameController = TextEditingController();
  String _businessType = 'Individual Seller';

  // Step 3: Address & Identification
  final _cityController = TextEditingController();
  final _stateController = TextEditingController();
  final _pincodeController = TextEditingController();
  final _gstNumberController = TextEditingController();
  final _panNumberController = TextEditingController();

  final List<String> _businessTypes = [
    'Individual Seller',
    'Retailer',
    'Wholesaler',
    'Distributor',
    'Manufacturer',
    'Online Seller'
  ];

  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

  @override
  void dispose() {
    _fullNameController.dispose();
    _emailController.dispose();
    _countryCodeController.dispose();
    _mobileNumberController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _businessNameController.dispose();
    _cityController.dispose();
    _stateController.dispose();
    _pincodeController.dispose();
    _gstNumberController.dispose();
    _panNumberController.dispose();
    super.dispose();
  }

  void _nextStep() {
    if (_currentStep == 0) {
      if (_formKey0.currentState!.validate()) {
        setState(() {
          _currentStep = 1;
        });
      }
    } else if (_currentStep == 1) {
      if (_formKey1.currentState!.validate()) {
        setState(() {
          _currentStep = 2;
        });
      }
    }
  }

  void _previousStep() {
    if (_currentStep > 0) {
      setState(() {
        _currentStep--;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isTablet = size.width > 600;

    return BlocProvider(
      create: (_) => sl<RegisterBloc>(),
      child: Scaffold(
        backgroundColor: const Color(0xFFFEEFDD),
        body: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: ConstrainedBox(
              constraints: BoxConstraints(
                maxWidth: isTablet ? 450 : double.infinity,
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
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
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
                        // Title
                        const Text(
                          'Register as Vendor',
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF1D1B18),
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 16),

                        // Progress Indicator Row
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            _buildStepIndicator(0, 'Personal'),
                            _buildStepLine(),
                            _buildStepIndicator(1, 'Business'),
                            _buildStepLine(),
                            _buildStepIndicator(2, 'Address'),
                          ],
                        ),
                        const SizedBox(height: 32),

                        // Step Forms
                        if (_currentStep == 0) _buildPersonalInfoForm(),
                        if (_currentStep == 1) _buildBusinessInfoForm(),
                        if (_currentStep == 2) _buildAddressInfoForm(state),

                        const SizedBox(height: 32),

                        // Navigation Buttons
                        Row(
                          children: [
                            if (_currentStep > 0)
                              Expanded(
                                child: OutlinedButton(
                                  onPressed: state is RegisterLoading ? null : _previousStep,
                                  style: OutlinedButton.styleFrom(
                                    padding: const EdgeInsets.symmetric(vertical: 14),
                                    side: const BorderSide(color: AppColors.brandOrange),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                  ),
                                  child: const Text(
                                    'BACK',
                                    style: TextStyle(
                                      color: AppColors.brandOrange,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 14,
                                    ),
                                  ),
                                ),
                              ),
                            if (_currentStep > 0) const SizedBox(width: 16),
                            Expanded(
                              child: ElevatedButton(
                                onPressed: state is RegisterLoading
                                    ? null
                                    : () {
                                        if (_currentStep < 2) {
                                          _nextStep();
                                        } else {
                                          if (_formKey2.currentState!.validate()) {
                                            BlocProvider.of<RegisterBloc>(context).add(
                                              RegisterSubmittedEvent(
                                                fullName: _fullNameController.text.trim(),
                                                email: _emailController.text.trim(),
                                                countryCode: _countryCodeController.text.trim(),
                                                mobileNumber: _mobileNumberController.text.trim(),
                                                password: _passwordController.text,
                                                confirmPassword: _confirmPasswordController.text,
                                                role: UserRole.vendor,
                                                businessName: _businessNameController.text.trim(),
                                                businessType: _businessType,
                                                city: _cityController.text.trim(),
                                                state: _stateController.text.trim(),
                                                pincode: _pincodeController.text.trim(),
                                                gstNumber: _gstNumberController.text.trim().isEmpty
                                                    ? null
                                                    : _gstNumberController.text.trim(),
                                                panNumber: _panNumberController.text.trim().isEmpty
                                                    ? null
                                                    : _panNumberController.text.trim(),
                                              ),
                                            );
                                          }
                                        }
                                      },
                                style: ElevatedButton.styleFrom(
                                  padding: const EdgeInsets.symmetric(vertical: 14),
                                  backgroundColor: AppColors.brandOrange,
                                  foregroundColor: Colors.white,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  elevation: 0,
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
                                    : Text(
                                        _currentStep == 2 ? 'SUBMIT' : 'NEXT',
                                        style: const TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.bold,
                                          letterSpacing: 1,
                                        ),
                                      ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 24),

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
                                  style: TextStyle(color: AppColors.brandOrange, fontWeight: FontWeight.bold),
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

  Widget _buildStepIndicator(int stepIndex, String title) {
    final isActive = _currentStep == stepIndex;
    final isCompleted = _currentStep > stepIndex;

    return Column(
      children: [
        Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: isCompleted
                ? AppColors.brandOrange
                : isActive
                    ? AppColors.brandOrange
                    : const Color(0xFFF0EBE1),
            border: isActive
                ? Border.all(color: AppColors.brandOrange, width: 2)
                : null,
          ),
          child: Center(
            child: isCompleted
                ? const Icon(Icons.check, size: 16, color: Colors.white)
                : Text(
                    '${stepIndex + 1}',
                    style: TextStyle(
                      color: isActive || isCompleted ? Colors.white : AppColors.textSecondaryLight,
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                    ),
                  ),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          title,
          style: TextStyle(
            fontSize: 10,
            color: isActive ? AppColors.brandOrange : AppColors.textSecondaryLight,
            fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
          ),
        )
      ],
    );
  }

  Widget _buildStepLine() {
    return Container(
      width: 40,
      height: 2,
      margin: const EdgeInsets.only(bottom: 12),
      color: const Color(0xFFF0EBE1),
    );
  }

  // Personal Info Form
  Widget _buildPersonalInfoForm() {
    return Form(
      key: _formKey0,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Full Name
          TextFormField(
            controller: _fullNameController,
            style: const TextStyle(color: Color(0xFF1D1B18), fontSize: 14),
            decoration: _buildInputDecoration('Full Name', Icons.person_outline),
            validator: (value) {
              if (value == null || value.trim().isEmpty) return 'Please enter your full name';
              if (value.trim().length < 2) return 'Name must be at least 2 characters';
              return null;
            },
          ),
          const SizedBox(height: 16),

          // Email
          TextFormField(
            controller: _emailController,
            style: const TextStyle(color: Color(0xFF1D1B18), fontSize: 14),
            decoration: _buildInputDecoration('Email Address', Icons.email_outlined),
            keyboardType: TextInputType.emailAddress,
            validator: (value) {
              if (value == null || value.trim().isEmpty) return 'Please enter your email';
              final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
              if (!emailRegex.hasMatch(value.trim())) return 'Please enter a valid email';
              return null;
            },
          ),
          const SizedBox(height: 16),

          // Mobile Row
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                width: 75,
                child: TextFormField(
                  controller: _countryCodeController,
                  style: const TextStyle(color: Color(0xFF1D1B18), fontSize: 14),
                  decoration: _buildInputDecoration('Code', null),
                  keyboardType: TextInputType.phone,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) return 'Required';
                    if (!value.startsWith('+')) return 'Use +';
                    return null;
                  },
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: TextFormField(
                  controller: _mobileNumberController,
                  style: const TextStyle(color: Color(0xFF1D1B18), fontSize: 14),
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
          const SizedBox(height: 16),

          // Password
          TextFormField(
            controller: _passwordController,
            obscureText: _obscurePassword,
            style: const TextStyle(color: Color(0xFF1D1B18), fontSize: 14),
            decoration: _buildPasswordInputDecoration(
              'Password',
              _obscurePassword,
              () => setState(() => _obscurePassword = !_obscurePassword),
            ),
            validator: (value) {
              if (value == null || value.isEmpty) return 'Please enter a password';
              if (value.length < 8) return 'Password must be at least 8 characters';
              final hasUppercase = RegExp(r'[A-Z]').hasMatch(value);
              final hasLowercase = RegExp(r'[a-z]').hasMatch(value);
              final hasDigits = RegExp(r'\d').hasMatch(value);
              final hasSpecial = RegExp(r'[@$!%*?&]').hasMatch(value);
              if (!hasUppercase || !hasLowercase || !hasDigits || !hasSpecial) {
                return 'Must contain uppercase, lowercase, number, special char';
              }
              return null;
            },
          ),
          const SizedBox(height: 16),

          // Confirm Password
          TextFormField(
            controller: _confirmPasswordController,
            obscureText: _obscureConfirmPassword,
            style: const TextStyle(color: Color(0xFF1D1B18), fontSize: 14),
            decoration: _buildPasswordInputDecoration(
              'Confirm Password',
              _obscureConfirmPassword,
              () => setState(() => _obscureConfirmPassword = !_obscureConfirmPassword),
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

  // Business Info Form
  Widget _buildBusinessInfoForm() {
    return Form(
      key: _formKey1,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Business Name
          TextFormField(
            controller: _businessNameController,
            style: const TextStyle(color: Color(0xFF1D1B18), fontSize: 14),
            decoration: _buildInputDecoration('Business Name', Icons.store_outlined),
            validator: (value) {
              if (value == null || value.trim().isEmpty) return 'Please enter business name';
              return null;
            },
          ),
          const SizedBox(height: 16),

          // Business Type Dropdown
          DropdownButtonFormField<String>(
            value: _businessType,
            style: const TextStyle(color: Color(0xFF1D1B18), fontSize: 14),
            decoration: _buildInputDecoration('Business Type', Icons.business_outlined),
            items: _businessTypes.map((type) {
              return DropdownMenuItem<String>(
                value: type,
                child: Text(type),
              );
            }).toList(),
            onChanged: (value) {
              setState(() {
                _businessType = value ?? 'Individual Seller';
              });
            },
          ),
        ],
      ),
    );
  }

  // Address Info Form
  Widget _buildAddressInfoForm(RegisterState state) {
    return Form(
      key: _formKey2,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // City
          TextFormField(
            controller: _cityController,
            style: const TextStyle(color: Color(0xFF1D1B18), fontSize: 14),
            decoration: _buildInputDecoration('City', Icons.location_city_outlined),
            validator: (value) {
              if (value == null || value.trim().isEmpty) return 'Please enter city';
              return null;
            },
          ),
          const SizedBox(height: 16),

          // State
          TextFormField(
            controller: _stateController,
            style: const TextStyle(color: Color(0xFF1D1B18), fontSize: 14),
            decoration: _buildInputDecoration('State', Icons.map_outlined),
            validator: (value) {
              if (value == null || value.trim().isEmpty) return 'Please enter state';
              return null;
            },
          ),
          const SizedBox(height: 16),

          // Pincode
          TextFormField(
            controller: _pincodeController,
            style: const TextStyle(color: Color(0xFF1D1B18), fontSize: 14),
            decoration: _buildInputDecoration('Pincode', Icons.pin_outlined),
            keyboardType: TextInputType.number,
            validator: (value) {
              if (value == null || value.trim().isEmpty) return 'Please enter pincode';
              if (!RegExp(r'^\d{4,10}$').hasMatch(value.trim())) return 'Enter a valid pincode';
              return null;
            },
          ),
          const SizedBox(height: 16),

          // GST Number (Optional)
          TextFormField(
            controller: _gstNumberController,
            style: const TextStyle(color: Color(0xFF1D1B18), fontSize: 14),
            decoration: _buildInputDecoration('GST Number (Optional)', Icons.description_outlined),
          ),
          const SizedBox(height: 16),

          // PAN Number (Optional)
          TextFormField(
            controller: _panNumberController,
            style: const TextStyle(color: Color(0xFF1D1B18), fontSize: 14),
            decoration: _buildInputDecoration('PAN Number (Optional)', Icons.payment_outlined),
          ),
        ],
      ),
    );
  }

  InputDecoration _buildInputDecoration(String labelText, IconData? icon) {
    return InputDecoration(
      labelText: labelText,
      labelStyle: const TextStyle(color: AppColors.textSecondaryLight, fontSize: 13),
      prefixIcon: icon != null ? Icon(icon, color: AppColors.textSecondaryLight, size: 20) : null,
      filled: true,
      fillColor: const Color(0xFFFFF9F2),
      contentPadding: const EdgeInsets.all(16),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFFF9DCC4)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFFF9DCC4)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.brandOrange, width: 1.5),
      ),
    );
  }

  InputDecoration _buildPasswordInputDecoration(
    String labelText,
    bool obscureText,
    VoidCallback toggleObscure,
  ) {
    return InputDecoration(
      labelText: labelText,
      labelStyle: const TextStyle(color: AppColors.textSecondaryLight, fontSize: 13),
      prefixIcon: const Icon(Icons.lock_outline, color: AppColors.textSecondaryLight, size: 20),
      suffixIcon: IconButton(
        icon: Icon(
          obscureText ? Icons.visibility_off_outlined : Icons.visibility_outlined,
          color: AppColors.textSecondaryLight,
          size: 18,
        ),
        onPressed: toggleObscure,
      ),
      filled: true,
      fillColor: const Color(0xFFFFF9F2),
      contentPadding: const EdgeInsets.all(16),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFFF9DCC4)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFFF9DCC4)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.brandOrange, width: 1.5),
      ),
    );
  }
}
