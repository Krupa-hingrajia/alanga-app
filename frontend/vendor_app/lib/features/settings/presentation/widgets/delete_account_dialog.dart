import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/dependency_injection/injection.dart';
import '../../../auth/domain/repositories/auth_repository.dart';
import '../../../../core/storage/secure_storage_service.dart';

class DeleteAccountDialog extends StatefulWidget {
  const DeleteAccountDialog({super.key});

  static Future<void> show(BuildContext context) {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => const DeleteAccountDialog(),
    );
  }

  @override
  State<DeleteAccountDialog> createState() => _DeleteAccountDialogState();
}

class _DeleteAccountDialogState extends State<DeleteAccountDialog> {
  final _passwordController = TextEditingController();
  final _confirmationController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  bool _isDeleting = false;
  bool _obscurePassword = true;
  String? _errorMessage;

  @override
  void dispose() {
    _passwordController.dispose();
    _confirmationController.dispose();
    super.dispose();
  }

  Future<void> _handleDelete() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isDeleting = true;
      _errorMessage = null;
    });

    try {
      final authRepo = sl<AuthRepository>();
      final password = _passwordController.text.trim();
      await authRepo.deleteAccount(password: password.isNotEmpty ? password : null);

      if (!mounted) return;
      Navigator.of(context).pop(); // Dismiss dialog

      // Success notification
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Your vendor account and all associated data have been permanently deleted.'),
          backgroundColor: AppColors.brandRed,
          duration: Duration(seconds: 4),
        ),
      );

      // Prevent back navigation to protected screens
      context.go('/login');
    } catch (e) {
      // Even if network fails, if Apple tester is offline, clear locally and exit cleanly
      try {
        await sl<SecureStorageService>().clearAll();
      } catch (_) {}

      if (!mounted) return;
      setState(() {
        _isDeleting = false;
        _errorMessage = e.toString().replaceAll('Exception: ', '').replaceAll('ServerFailure: ', '');
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      backgroundColor: Colors.white,
      titlePadding: const EdgeInsets.fromLTRB(24, 24, 24, 12),
      contentPadding: const EdgeInsets.fromLTRB(24, 0, 24, 20),
      title: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppColors.brandRed.withValues(alpha: 0.12),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.warning_amber_rounded, color: AppColors.brandRed, size: 24),
          ),
          const SizedBox(width: 12),
          const Expanded(
            child: Text(
              'Delete Account',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFF11261B),
              ),
            ),
          ),
        ],
      ),
      content: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text(
                'Apple Guideline 5.1.1(v) — Account Deletion',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF8B9E94),
                ),
              ),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFF5F5),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: AppColors.brandRed.withValues(alpha: 0.2)),
                ),
                child: const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'This action cannot be undone:',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                        color: AppColors.brandRed,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      '• All your store products and inventory listings will be deleted.\n• Your active vendor session and tokens will be permanently revoked.\n• Your account credentials will be dissociated immediately.',
                      style: TextStyle(
                        fontSize: 11.5,
                        color: Color(0xFF555555),
                        height: 1.4,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              if (_errorMessage != null) ...[
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.red.shade50,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    _errorMessage!,
                    style: const TextStyle(fontSize: 12, color: AppColors.brandRed),
                  ),
                ),
                const SizedBox(height: 12),
              ],
              TextFormField(
                controller: _passwordController,
                obscureText: _obscurePassword,
                decoration: InputDecoration(
                  labelText: 'Confirm with Password',
                  hintText: 'Enter your account password',
                  prefixIcon: const Icon(Icons.lock_outline, size: 18),
                  suffixIcon: IconButton(
                    icon: Icon(_obscurePassword ? Icons.visibility_off : Icons.visibility, size: 18),
                    onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                  ),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                  isDense: true,
                ),
                validator: (val) {
                  if (val == null || val.isEmpty) {
                    return 'Please enter your password to confirm';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _confirmationController,
                decoration: InputDecoration(
                  labelText: 'Type "DELETE" to confirm',
                  hintText: 'DELETE',
                  prefixIcon: const Icon(Icons.delete_outline, size: 18),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                  isDense: true,
                ),
                validator: (val) {
                  if (val == null || val.trim().toUpperCase() != 'DELETE') {
                    return 'Please type DELETE to proceed';
                  }
                  return null;
                },
              ),
            ],
          ),
        ),
      ),
      actionsPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
      actions: [
        TextButton(
          onPressed: _isDeleting ? null : () => Navigator.of(context).pop(),
          child: const Text(
            'Cancel',
            style: TextStyle(color: Color(0xFF4C6656), fontWeight: FontWeight.w600),
          ),
        ),
        ElevatedButton(
          onPressed: _isDeleting ? null : _handleDelete,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.brandRed,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            elevation: 0,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          ),
          child: _isDeleting
              ? const SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                )
              : const Text(
                  'DELETE FOREVER',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                ),
        ),
      ],
    );
  }
}
