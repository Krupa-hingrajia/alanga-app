import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';

class AddressConfirmationDialog extends StatelessWidget {
  final String title;
  final String message;
  final String confirmText;
  final String cancelText;
  final VoidCallback onConfirm;
  final bool isDestructive;

  const AddressConfirmationDialog({
    super.key,
    required this.title,
    required this.message,
    this.confirmText = 'Delete',
    this.cancelText = 'Cancel',
    required this.onConfirm,
    this.isDestructive = true,
  });

  static Future<bool?> show(
    BuildContext context, {
    required String title,
    required String message,
    String confirmText = 'Delete',
    String cancelText = 'Cancel',
    bool isDestructive = true,
  }) {
    return showDialog<bool>(
      context: context,
      builder: (ctx) => AddressConfirmationDialog(
        title: title,
        message: message,
        confirmText: confirmText,
        cancelText: cancelText,
        isDestructive: isDestructive,
        onConfirm: () => Navigator.of(ctx).pop(true),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      backgroundColor: Colors.white,
      surfaceTintColor: Colors.transparent,
      title: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: (isDestructive ? AppColors.brandRed : AppColors.primaryGreen)
                  .withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              isDestructive ? Icons.delete_outline_rounded : Icons.info_outline_rounded,
              color: isDestructive ? AppColors.brandRed : AppColors.primaryGreen,
              size: 22,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              title,
              style: const TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.bold,
                color: Color(0xFF11261B),
              ),
            ),
          ),
        ],
      ),
      content: Text(
        message,
        style: const TextStyle(
          fontSize: 13,
          color: Color(0xFF4C6656),
          height: 1.4,
        ),
      ),
      actionsPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(false),
          style: TextButton.styleFrom(
            foregroundColor: const Color(0xFF4C6656),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          ),
          child: Text(cancelText, style: const TextStyle(fontWeight: FontWeight.w600)),
        ),
        ElevatedButton(
          onPressed: onConfirm,
          style: ElevatedButton.styleFrom(
            backgroundColor: isDestructive ? AppColors.brandRed : AppColors.primaryGreen,
            foregroundColor: Colors.white,
            elevation: 0,
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
          child: Text(confirmText, style: const TextStyle(fontWeight: FontWeight.bold)),
        ),
      ],
    );
  }
}
