import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _mobileController = TextEditingController();
  final _passwordController = TextEditingController();
  
  UserRole _selectedRole = UserRole.customer;
  bool _obscurePassword = true;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _mobileController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isTablet = size.width > 600;

    return BlocProvider(
      create: (_) => sl<RegisterBloc>(),
      child: Scaffold(
        backgroundColor: const Color(0xFFE6EFEA), // Solid clean light mint green background
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
            padding: const EdgeInsets.only(left: 24.0, right: 24.0, top: kToolbarHeight + 10.0, bottom: 24.0),
            child: ConstrainedBox(
              constraints: BoxConstraints(
                maxWidth: isTablet ? 420 : double.infinity,
              ),
              child: BlocConsumer<RegisterBloc, RegisterState>(
                listener: (context, state) {
                  if (state is RegisterSuccess) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Registration successful! Please login.'),
                        backgroundColor: AppColors.primaryGreen,
                      ),
                    );
                    context.go('/login');
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
                    padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 32),
                    decoration: BoxDecoration(
                      color: Colors.white, // Clean white card for premium contrast
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.06),
                          blurRadius: 20,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                    child: Form(
                      key: _formKey,
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
                                height: 64, // Small logo size
                                width: 64,
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                          const SizedBox(height: 12),
                          const Text(
                            'Register',
                            style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF0F2016), // Dark green text
                              letterSpacing: 1,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 4),
                          const Text(
                            'Fill in details to join the marketplace',
                            style: TextStyle(
                              fontSize: 11,
                              color: AppColors.textSecondaryLight,
                              fontWeight: FontWeight.w600,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 24),

                          // Full Name
                          TextFormField(
                            controller: _nameController,
                            style: const TextStyle(color: Color(0xFF0F2016), fontSize: 14),
                            decoration: InputDecoration(
                              labelText: 'Full Name',
                              labelStyle: const TextStyle(color: AppColors.textSecondaryLight, fontSize: 13),
                              prefixIcon: const Icon(Icons.person_outline, color: AppColors.textSecondaryLight, size: 20),
                              filled: true,
                              fillColor: const Color(0xFFF1F5F2),
                              contentPadding: const EdgeInsets.all(16),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: const BorderSide(color: Color(0xFFD1DDD6)),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: const BorderSide(color: Color(0xFFD1DDD6)),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: const BorderSide(color: Color(0xFF2E5E43), width: 1.5),
                              ),
                            ),
                            validator: (value) {
                              if (value == null || value.trim().isEmpty) return 'Enter your full name';
                              if (value.trim().length < 2) return 'Name must be at least 2 characters';
                              return null;
                            },
                          ),
                          const SizedBox(height: 16),

                          // Email Address
                          TextFormField(
                            controller: _emailController,
                            keyboardType: TextInputType.emailAddress,
                            style: const TextStyle(color: Color(0xFF0F2016), fontSize: 14),
                            decoration: InputDecoration(
                              labelText: 'Email Address',
                              labelStyle: const TextStyle(color: AppColors.textSecondaryLight, fontSize: 13),
                              prefixIcon: const Icon(Icons.email_outlined, color: AppColors.textSecondaryLight, size: 20),
                              filled: true,
                              fillColor: const Color(0xFFF1F5F2),
                              contentPadding: const EdgeInsets.all(16),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: const BorderSide(color: Color(0xFFD1DDD6)),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: const BorderSide(color: Color(0xFFD1DDD6)),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: const BorderSide(color: Color(0xFF2E5E43), width: 1.5),
                              ),
                            ),
                            validator: (value) {
                              if (value == null || value.trim().isEmpty) return 'Enter email address';
                              final emailRegex = RegExp(r'^[^@]+@[^@]+\.[^@]+');
                              if (!emailRegex.hasMatch(value)) return 'Enter a valid email address';
                              return null;
                            },
                          ),
                          const SizedBox(height: 16),

                          // Mobile Number Field
                          TextFormField(
                            controller: _mobileController,
                            keyboardType: TextInputType.phone,
                            style: const TextStyle(color: Color(0xFF0F2016), fontSize: 14),
                            inputFormatters: [
                              FilteringTextInputFormatter.digitsOnly,
                              LengthLimitingTextInputFormatter(10),
                            ],
                            decoration: InputDecoration(
                              labelText: 'Mobile Number',
                              labelStyle: const TextStyle(color: AppColors.textSecondaryLight, fontSize: 13),
                              prefixIcon: const Icon(Icons.phone_outlined, color: AppColors.textSecondaryLight, size: 20),
                              filled: true,
                              fillColor: const Color(0xFFF1F5F2),
                              counterText: "",
                              contentPadding: const EdgeInsets.all(16),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: const BorderSide(color: Color(0xFFD1DDD6)),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: const BorderSide(color: Color(0xFFD1DDD6)),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: const BorderSide(color: Color(0xFF2E5E43), width: 1.5),
                              ),
                            ),
                            validator: (value) {
                              if (value == null || value.trim().isEmpty) return 'Enter mobile number';
                              if (value.length != 10) {
                                  return 'Mobile number must be exactly 10 digits';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 16),

                          // Password Field
                          TextFormField(
                            controller: _passwordController,
                            obscureText: _obscurePassword,
                            style: const TextStyle(color: Color(0xFF0F2016), fontSize: 14),
                            decoration: InputDecoration(
                              labelText: 'Password',
                              labelStyle: const TextStyle(color: AppColors.textSecondaryLight, fontSize: 13),
                              prefixIcon: const Icon(Icons.lock_outline, color: AppColors.textSecondaryLight, size: 20),
                              suffixIcon: IconButton(
                                icon: Icon(
                                  _obscurePassword ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                                  color: AppColors.textSecondaryLight,
                                  size: 18,
                                ),
                                onPressed: () {
                                  setState(() {
                                    _obscurePassword = !_obscurePassword;
                                  });
                                },
                              ),
                              filled: true,
                              fillColor: const Color(0xFFF1F5F2),
                              contentPadding: const EdgeInsets.all(16),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: const BorderSide(color: Color(0xFFD1DDD6)),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: const BorderSide(color: Color(0xFFD1DDD6)),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: const BorderSide(color: Color(0xFF2E5E43), width: 1.5),
                              ),
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) return 'Enter password';
                              if (value.length < 8) return 'Password must be at least 8 characters';
                              final hasUppercase = value.contains(RegExp(r'[A-Z]'));
                              final hasLowercase = value.contains(RegExp(r'[a-z]'));
                              final hasDigits = value.contains(RegExp(r'[0-9]'));
                              final hasSpecial = value.contains(RegExp(r'[@$!%*?&]'));
                              if (!hasUppercase || !hasLowercase || !hasDigits || !hasSpecial) {
                                return 'Must contain uppercase, lowercase, digit, and special char (@\$!%*?&)';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 16),

                          // Role Dropdown
                          DropdownButtonFormField<UserRole>(
                            value: _selectedRole,
                            dropdownColor: Colors.white,
                            style: const TextStyle(color: Color(0xFF0F2016), fontSize: 14),
                            decoration: InputDecoration(
                              labelText: 'Account Role',
                              labelStyle: const TextStyle(color: AppColors.textSecondaryLight, fontSize: 13),
                              prefixIcon: const Icon(Icons.badge_outlined, color: AppColors.textSecondaryLight, size: 20),
                              filled: true,
                              fillColor: const Color(0xFFF1F5F2),
                              contentPadding: const EdgeInsets.all(16),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: const BorderSide(color: Color(0xFFD1DDD6)),
                              ),
                              enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: const BorderSide(color: Color(0xFFD1DDD6)),
                              ),
                              focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: const BorderSide(color: Color(0xFF2E5E43), width: 1.5),
                              ),
                            ),
                            items: const [
                              DropdownMenuItem(value: UserRole.customer, child: Text('Customer', style: TextStyle(color: Color(0xFF0F2016)))),
                              DropdownMenuItem(value: UserRole.vendor, child: Text('Vendor', style: TextStyle(color: Color(0xFF0F2016)))),
                              DropdownMenuItem(value: UserRole.admin, child: Text('Admin', style: TextStyle(color: Color(0xFF0F2016)))),
                            ],
                            onChanged: (role) {
                              if (role != null) {
                                setState(() {
                                  _selectedRole = role;
                                });
                              }
                            },
                          ),
                          const SizedBox(height: 32),

                          // Action Button using logo green
                          ElevatedButton(
                            onPressed: state is RegisterLoading
                                ? null
                                : () {
                                    if (_formKey.currentState!.validate()) {
                                      BlocProvider.of<RegisterBloc>(context).add(
                                        RegisterSubmittedEvent(
                                          fullName: _nameController.text.trim(),
                                          email: _emailController.text.trim(),
                                          countryCode: '+91', // Default Country Code
                                          mobileNumber: _mobileController.text.trim(),
                                          password: _passwordController.text,
                                          confirmPassword: _passwordController.text, // Duplicate password
                                          role: _selectedRole,
                                        ),
                                      );
                                    }
                                  },
                            style: ElevatedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              backgroundColor: AppColors.primaryGreen, // Logo green background
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              elevation: 0,
                            ),
                            child: state is RegisterLoading
                                ? const SizedBox(
                                    height: 20,
                                    width: 20,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      color: Colors.white,
                                    ),
                                  )
                                : const Text(
                                    'REGISTER',
                                    style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, letterSpacing: 1),
                                  ),
                          ),
                        ],
                      ),
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
}
