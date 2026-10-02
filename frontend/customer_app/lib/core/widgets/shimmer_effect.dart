import 'package:flutter/material.dart';

class ShimmerEffect extends StatefulWidget {
  final double? width;
  final double? height;
  final ShapeBorder shapeBorder;
  final BorderRadiusGeometry? borderRadius;

  const ShimmerEffect.rectangular({
    super.key,
    this.width = double.infinity,
    required this.height,
    this.borderRadius,
  }) : shapeBorder = const RoundedRectangleBorder();

  const ShimmerEffect.circular({
    super.key,
    required this.width,
    required this.height,
  })  : shapeBorder = const CircleBorder(),
        borderRadius = null;

  @override
  State<ShimmerEffect> createState() => _ShimmerEffectState();
}

class _ShimmerEffectState extends State<ShimmerEffect>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    )..repeat();

    _animation = Tween<double>(begin: -1.5, end: 1.5).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOutSine),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Container(
          width: widget.width,
          height: widget.height,
          decoration: BoxDecoration(
            borderRadius: widget.shapeBorder is CircleBorder
                ? null
                : (widget.borderRadius ?? BorderRadius.circular(12)),
            shape: widget.shapeBorder is CircleBorder
                ? BoxShape.circle
                : BoxShape.rectangle,
            gradient: LinearGradient(
              begin: Alignment(_animation.value - 1.0, -0.3),
              end: Alignment(_animation.value + 1.0, 0.3),
              colors: const [
                Color(0xFFE3EAE6),
                Color(0xFFF7FAF8),
                Color(0xFFE3EAE6),
              ],
              stops: const [0.1, 0.5, 0.9],
            ),
          ),
        );
      },
    );
  }
}
