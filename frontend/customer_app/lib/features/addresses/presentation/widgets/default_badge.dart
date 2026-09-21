import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';

class DefaultBadge extends StatelessWidget {
  final bool compact;

  const DefaultBadge({super.key, this.compact = false});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: compact ? 6 : 8,
        vertical: compact ? 2 : 3,
      ),
      decoration: BoxDecoration(
        color: AppColors.primaryGreen.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(
          color: AppColors.primaryGreen.withValues(alpha: 0.4),
          width: 0.8,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.check_circle_rounded,
            size: compact ? 10 : 12,
            color: AppColors.primaryGreen,
          ),
          const SizedBox(width: 4),
          Text(
            'DEFAULT',
            style: TextStyle(
              color: AppColors.primaryGreen,
              fontSize: compact ? 9 : 10,
              fontWeight: FontWeight.w800,
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
    );
  }
}
