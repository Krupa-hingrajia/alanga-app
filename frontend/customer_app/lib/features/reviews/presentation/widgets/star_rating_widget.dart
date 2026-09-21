import 'package:flutter/material.dart';

class StarRatingWidget extends StatelessWidget {
  final int rating;
  final double size;
  final ValueChanged<int>? onRatingChanged;
  final Color activeColor;
  final Color inactiveColor;
  final bool showLabel;

  const StarRatingWidget({
    super.key,
    required this.rating,
    this.size = 24.0,
    this.onRatingChanged,
    this.activeColor = const Color(0xFFF59E0B), // Warm amber
    this.inactiveColor = const Color(0xFFD1D5DB), // Light grey
    this.showLabel = false,
  });

  String get _ratingLabel {
    switch (rating) {
      case 1:
        return 'Terrible';
      case 2:
        return 'Poor';
      case 3:
        return 'Average';
      case 4:
        return 'Good';
      case 5:
        return 'Excellent!';
      default:
        return 'Select Rating';
    }
  }

  Color get _labelColor {
    switch (rating) {
      case 1:
      case 2:
        return const Color(0xFFEF4444);
      case 3:
        return const Color(0xFFF59E0B);
      case 4:
      case 5:
        return const Color(0xFF10B981);
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    final isInteractive = onRatingChanged != null;

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(5, (index) {
            final starIndex = index + 1;
            final isFilled = starIndex <= rating;

            final starIcon = Icon(
              isFilled ? Icons.star_rounded : Icons.star_outline_rounded,
              color: isFilled ? activeColor : inactiveColor,
              size: size,
            );

            if (!isInteractive) {
              return Padding(
                padding: const EdgeInsets.only(right: 2),
                child: starIcon,
              );
            }

            return InkWell(
              borderRadius: BorderRadius.circular(size),
              onTap: () => onRatingChanged!(starIndex),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 6),
                child: TweenAnimationBuilder<double>(
                  tween: Tween<double>(begin: 1.0, end: isFilled ? 1.15 : 1.0),
                  duration: const Duration(milliseconds: 200),
                  builder: (context, scale, child) {
                    return Transform.scale(
                      scale: scale,
                      child: child,
                    );
                  },
                  child: starIcon,
                ),
              ),
            );
          }),
        ),
        if (showLabel && isInteractive) ...[
          const SizedBox(height: 6),
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 250),
            child: Text(
              _ratingLabel,
              key: ValueKey<int>(rating),
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: _labelColor,
              ),
            ),
          ),
        ],
      ],
    );
  }
}
