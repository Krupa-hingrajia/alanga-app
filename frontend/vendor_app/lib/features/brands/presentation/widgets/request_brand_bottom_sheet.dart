import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/dependency_injection/injection.dart';
import '../../domain/repositories/brand_repository.dart';

class RequestBrandBottomSheet extends StatefulWidget {
  final VoidCallback? onRequestSubmitted;

  const RequestBrandBottomSheet({
    super.key,
    this.onRequestSubmitted,
  });

  static Future<void> show(
    BuildContext context, {
    VoidCallback? onRequestSubmitted,
  }) {
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => RequestBrandBottomSheet(
        onRequestSubmitted: onRequestSubmitted,
      ),
    );
  }

  @override
  State<RequestBrandBottomSheet> createState() => _RequestBrandBottomSheetState();
}

class _RequestBrandBottomSheetState extends State<RequestBrandBottomSheet> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _logoController = TextEditingController();
  final _descController = TextEditingController();

  bool _isSubmitting = false;
  String? _errorMessage;

  @override
  void dispose() {
    _nameController.dispose();
    _logoController.dispose();
    _descController.dispose();
    super.dispose();
  }

  Future<void> _submitRequest() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isSubmitting = true;
      _errorMessage = null;
    });

    try {
      await sl<BrandRepository>().requestBrand(
        name: _nameController.text.trim(),
        logo: _logoController.text.trim().isNotEmpty ? _logoController.text.trim() : null,
        description: _descController.text.trim().isNotEmpty ? _descController.text.trim() : null,
      );

      if (!mounted) return;
      Navigator.pop(context);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Your Brand request has been submitted for Admin approval.'),
          backgroundColor: AppColors.primaryGreen,
          duration: Duration(seconds: 4),
        ),
      );

      widget.onRequestSubmitted?.call();
    } catch (e) {
      if (!mounted) return;
      final errorMsg = e.toString().replaceAll('Exception:', '').replaceAll('ServerFailure:', '').trim();
      setState(() {
        _isSubmitting = false;
        _errorMessage = errorMsg.isNotEmpty ? errorMsg : 'Failed to submit brand request.';
      });
    }
  }

  InputDecoration _inputDecoration(String labelText, IconData icon) {
    return InputDecoration(
      labelText: labelText,
      labelStyle: const TextStyle(fontSize: 14, color: AppColors.textSecondaryLight),
      prefixIcon: Icon(icon, color: AppColors.primaryGreen, size: 20),
      filled: true,
      fillColor: const Color(0xFFF7FAF8),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: Color(0xFFD1DCD6)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: Color(0xFFD1DCD6)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: AppColors.primaryGreen, width: 1.5),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: AppColors.brandRed),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: EdgeInsets.only(
        top: 12,
        left: 20,
        right: 20,
        bottom: MediaQuery.of(context).viewInsets.bottom + 20,
      ),
      child: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Drag handle
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Title Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Row(
                    children: [
                      Icon(Icons.new_releases_outlined, color: AppColors.primaryGreen),
                      SizedBox(width: 8),
                      Text(
                        'Request New Brand',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF11261B),
                        ),
                      ),
                    ],
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close, color: Colors.grey),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              const Text(
                'Can\'t find your brand? Submit a request to Admin for verification and approval.',
                style: TextStyle(fontSize: 12, color: AppColors.textSecondaryLight),
              ),
              const SizedBox(height: 20),

              // Brand Name Input
              TextFormField(
                controller: _nameController,
                decoration: _inputDecoration('Brand Name *', Icons.label_outlined),
                validator: (val) {
                  if (val == null || val.trim().isEmpty) {
                    return 'Brand Name is required';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Brand Logo URL Input
              TextFormField(
                controller: _logoController,
                decoration: _inputDecoration('Brand Logo URL (Optional)', Icons.image_outlined),
              ),
              const SizedBox(height: 16),

              // Description Input
              TextFormField(
                controller: _descController,
                maxLines: 3,
                decoration: _inputDecoration('Description (Optional)', Icons.notes_outlined),
              ),
              const SizedBox(height: 24),

              // In-Modal Error Banner
              if (_errorMessage != null) ...[
                Container(
                  margin: const EdgeInsets.only(bottom: 16),
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFDE8E8),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: const Color(0xFFF98080), width: 1.2),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      const Icon(Icons.error_outline_rounded, color: Color(0xFFE02424), size: 18),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          _errorMessage!,
                          style: const TextStyle(
                            color: Color(0xFF9B1C1C),
                            fontSize: 12.5,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      GestureDetector(
                        onTap: () => setState(() => _errorMessage = null),
                        child: const Icon(Icons.close_rounded, color: Color(0xFF9B1C1C), size: 16),
                      ),
                    ],
                  ),
                ),
              ],

              // Submit Button
              ElevatedButton(
                onPressed: _isSubmitting ? null : _submitRequest,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF1A3827),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                  elevation: 0,
                ),
                child: _isSubmitting
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Text(
                        'Submit Brand Request',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
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
