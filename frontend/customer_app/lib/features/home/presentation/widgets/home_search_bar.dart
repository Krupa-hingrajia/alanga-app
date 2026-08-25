import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';

class HomeSearchBar extends StatelessWidget {
  final TextEditingController? controller;
  final ValueChanged<String>? onSubmitted;
  final VoidCallback? onVoiceTap;
  final VoidCallback? onScanTap;

  const HomeSearchBar({
    super.key,
    this.controller,
    this.onSubmitted,
    this.onVoiceTap,
    this.onScanTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppColors.darkGreen.withValues(alpha: 0.08),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
        border: Border.all(color: const Color(0xFFE4ECE8), width: 1),
      ),
      child: TextField(
        controller: controller,
        textInputAction: TextInputAction.search,
        onSubmitted: onSubmitted,
        style: const TextStyle(fontSize: 14, color: AppColors.darkGreen),
        decoration: InputDecoration(
          hintText: 'Search Products, Brands...',
          hintStyle: const TextStyle(
            fontSize: 13,
            color: Color(0xFF8BA697),
            fontWeight: FontWeight.w400,
          ),
          prefixIcon: const Icon(
            Icons.search_rounded,
            color: AppColors.primaryGreen,
            size: 22,
          ),
          suffixIcon: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                icon: const Icon(
                  Icons.mic_none_rounded,
                  color: AppColors.brandOrange,
                  size: 20,
                ),
                onPressed: onVoiceTap ??
                    () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Voice Search coming soon!'),
                          behavior: SnackBarBehavior.floating,
                          duration: Duration(seconds: 2),
                        ),
                      );
                    },
                tooltip: 'Voice Search',
              ),
              Container(
                height: 20,
                width: 1,
                color: const Color(0xFFE4ECE8),
              ),
              IconButton(
                icon: const Icon(
                  Icons.qr_code_scanner_rounded,
                  color: AppColors.primaryGreen,
                  size: 20,
                ),
                onPressed: onScanTap ??
                    () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Barcode Scanner coming soon!'),
                          behavior: SnackBarBehavior.floating,
                          duration: Duration(seconds: 2),
                        ),
                      );
                    },
                tooltip: 'Scan Barcode',
              ),
            ],
          ),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(vertical: 14),
        ),
      ),
    );
  }
}
