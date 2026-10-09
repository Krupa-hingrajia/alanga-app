import 'package:flutter/material.dart';
import '../../../../core/dependency_injection/injection.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../auth/domain/entities/user_entity.dart';
import '../../../auth/domain/repositories/auth_repository.dart';

class FirstTimeStoreSetupSheet extends StatefulWidget {
  final String? initialFullName;
  final String? initialBusinessName;
  final String? initialEmail;
  final VoidCallback onUpdated;

  const FirstTimeStoreSetupSheet({
    super.key,
    this.initialFullName,
    this.initialBusinessName,
    this.initialEmail,
    required this.onUpdated,
  });

  static Future<void> show(
    BuildContext context, {
    String? initialFullName,
    String? initialBusinessName,
    String? initialEmail,
    required VoidCallback onUpdated,
  }) {
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => FirstTimeStoreSetupSheet(
        initialFullName: initialFullName,
        initialBusinessName: initialBusinessName,
        initialEmail: initialEmail,
        onUpdated: onUpdated,
      ),
    );
  }

  /// Checks if store profile is complete. If not, shows a dialog prompting the user to complete setup first.
  /// Returns true if profile is ready, false if blocked.
  static Future<bool> guardProductCreation(
    BuildContext context, {
    UserEntity? user,
    VoidCallback? onProfileUpdated,
  }) async {
    UserEntity? currentUser = user;
    if (currentUser == null) {
      try {
        currentUser = await sl<AuthRepository>().getCurrentUser();
      } catch (_) {}
    }

    if (currentUser != null && currentUser.isStoreProfileComplete) {
      return true;
    }

    final proceedToSetup = await showDialog<bool>(
      context: context,
      builder: (dialogCtx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: const Color(0xFFE8F5E9),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(Icons.storefront_rounded, color: Color(0xFF1A3827), size: 24),
            ),
            const SizedBox(width: 12),
            const Expanded(
              child: Text(
                'Store Setup Required',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF11261B)),
              ),
            ),
          ],
        ),
        content: const Text(
          'Please complete your store setup with a valid Store Name and Email Address before adding products. This ensures customers can identify your shop and you receive order invoices.',
          style: TextStyle(fontSize: 14, color: AppColors.textSecondaryLight, height: 1.4),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogCtx, false),
            child: const Text('Later', style: TextStyle(color: Colors.grey, fontWeight: FontWeight.w600)),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(dialogCtx, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF1A3827),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            child: const Text('Setup Store Now', style: TextStyle(fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );

    if (proceedToSetup == true && context.mounted) {
      await show(
        context,
        initialFullName: currentUser?.fullName,
        initialBusinessName: currentUser?.businessName,
        initialEmail: currentUser?.email,
        onUpdated: onProfileUpdated ?? () {},
      );
    }
    return false;
  }

  @override
  State<FirstTimeStoreSetupSheet> createState() => _FirstTimeStoreSetupSheetState();
}

class _FirstTimeStoreSetupSheetState extends State<FirstTimeStoreSetupSheet> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _storeNameController;
  late final TextEditingController _ownerNameController;
  late final TextEditingController _emailController;

  bool _isLoading = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    final isPlaceholderEmail = (widget.initialEmail ?? '').contains('@alanga.com');
    final isPlaceholderName = (widget.initialFullName ?? '').startsWith('Vendor ');

    _storeNameController = TextEditingController(
      text: widget.initialBusinessName ?? '',
    );
    _ownerNameController = TextEditingController(
      text: isPlaceholderName ? '' : (widget.initialFullName ?? ''),
    );
    _emailController = TextEditingController(
      text: isPlaceholderEmail ? '' : (widget.initialEmail ?? ''),
    );
  }

  @override
  void dispose() {
    _storeNameController.dispose();
    _ownerNameController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final authRepo = sl<AuthRepository>();
      final storeName = _storeNameController.text.trim();
      final ownerName = _ownerNameController.text.trim();
      final email = _emailController.text.trim().toLowerCase();

      await authRepo.updateProfile(
        fullName: ownerName.isNotEmpty ? ownerName : storeName,
        businessName: storeName.isNotEmpty ? storeName : null,
        email: email.isNotEmpty ? email : null,
      );

      if (!mounted) return;
      widget.onUpdated();
      Navigator.of(context).pop();

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Store Profile updated successfully! 🎉'),
          backgroundColor: Color(0xFF1A3827),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
        _errorMessage = e.toString().replaceAll('Exception: ', '').replaceAll('ServerFailure: ', '');
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final viewInsets = MediaQuery.of(context).viewInsets;

    return Container(
      padding: EdgeInsets.fromLTRB(24, 20, 24, 24 + viewInsets.bottom),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Center(
                child: Container(
                  width: 44,
                  height: 4.5,
                  decoration: BoxDecoration(
                    color: const Color(0xFFD1DDD6),
                    borderRadius: BorderRadius.circular(3),
                  ),
                ),
              ),
              const SizedBox(height: 18),

              // Title Header
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: const Color(0xFF1A3827).withOpacity(0.08),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.storefront_rounded,
                      color: Color(0xFF1A3827),
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Complete Your Store Profile',
                          style: TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.w800,
                            color: Color(0xFF11261B),
                          ),
                        ),
                        SizedBox(height: 2),
                        Text(
                          'Add your store name & email for order alerts',
                          style: TextStyle(
                            fontSize: 12,
                            color: Color(0xFF7A9A86),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              if (_errorMessage != null) ...[
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFDE8E8),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: const Color(0xFFF87171)),
                  ),
                  child: Text(
                    _errorMessage!,
                    style: const TextStyle(fontSize: 12, color: AppColors.brandRed, fontWeight: FontWeight.w600),
                  ),
                ),
                const SizedBox(height: 14),
              ],

              // Store Name Field
              TextFormField(
                controller: _storeNameController,
                style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Color(0xFF11261B)),
                decoration: _inputDecoration('Store / Business Name *', Icons.store_mall_directory_outlined, 'e.g. Krupa Textiles'),
                validator: (val) {
                  if (val == null || val.trim().isEmpty) return 'Please enter your Store Name';
                  return null;
                },
              ),
              const SizedBox(height: 14),

              // Owner Full Name Field
              TextFormField(
                controller: _ownerNameController,
                style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Color(0xFF11261B)),
                decoration: _inputDecoration('Owner Full Name *', Icons.person_outline, 'e.g. Krupa Sharma'),
                validator: (val) {
                  if (val == null || val.trim().isEmpty) return 'Please enter Owner Full Name';
                  return null;
                },
              ),
              const SizedBox(height: 14),

              // Email Address Field
              TextFormField(
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Color(0xFF11261B)),
                decoration: _inputDecoration('Email Address *', Icons.email_outlined, 'e.g. owner@example.com'),
                validator: (val) {
                  if (val == null || val.trim().isEmpty) return 'Please enter email address for invoices';
                  final emailRegex = RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$');
                  if (!emailRegex.hasMatch(val.trim())) return 'Enter a valid email address';
                  return null;
                },
              ),
              const SizedBox(height: 22),

              // Action Buttons
              ElevatedButton(
                onPressed: _isLoading ? null : _saveProfile,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 15),
                  backgroundColor: const Color(0xFF1A3827),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 0,
                ),
                child: _isLoading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Text(
                        'SAVE & ACTIVATE STORE',
                        style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, letterSpacing: 0.5),
                      ),
              ),
              const SizedBox(height: 8),

              TextButton(
                onPressed: _isLoading ? null : () => Navigator.of(context).pop(),
                child: const Text(
                  'Skip for now',
                  style: TextStyle(color: Color(0xFF7A9A86), fontSize: 13, fontWeight: FontWeight.w600),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  InputDecoration _inputDecoration(String label, IconData icon, String hint) {
    return InputDecoration(
      labelText: label,
      hintText: hint,
      labelStyle: const TextStyle(color: AppColors.textSecondaryLight, fontSize: 13),
      hintStyle: const TextStyle(color: Color(0xFFB0C4B8), fontSize: 13),
      prefixIcon: Icon(icon, color: const Color(0xFF1A3827), size: 20),
      filled: true,
      fillColor: const Color(0xFFF1F5F2),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 15),
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
        borderSide: const BorderSide(color: Color(0xFF1A3827), width: 1.5),
      ),
    );
  }
}
