import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/dependency_injection/injection.dart';
import '../bloc/wishlist_bloc.dart';
import '../bloc/wishlist_event.dart';
import '../bloc/wishlist_state.dart';

class WishlistButton extends StatelessWidget {
  final String productId;
  final String? productVariantId;
  final bool initialIsWishlisted;
  final double size;
  final EdgeInsetsGeometry padding;

  const WishlistButton({
    super.key,
    required this.productId,
    this.productVariantId,
    this.initialIsWishlisted = false,
    this.size = 22.0,
    this.padding = const EdgeInsets.all(8),
  });

  @override
  Widget build(BuildContext context) {
    final wishlistBloc = sl<WishlistBloc>();

    return BlocConsumer<WishlistBloc, WishlistState>(
      bloc: wishlistBloc,
      listenWhen: (prev, curr) =>
          curr is WishlistActionSuccess && curr.productId.isNotEmpty && curr.productId == productId,
      listener: (context, state) {
        if (state is WishlistActionSuccess && state.productId == productId) {
          ScaffoldMessenger.of(context).hideCurrentSnackBar();
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: state.isWishlisted ? AppColors.primaryGreen : Colors.grey.shade800,
              duration: const Duration(seconds: 2),
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      },
      builder: (context, state) {
        bool isWishlisted = initialIsWishlisted;

        if (state is WishlistLoaded) {
          isWishlisted = state.wishlistedProductIds.contains(productId);
        }

        return InkWell(
          onTap: () {
            wishlistBloc.add(ToggleWishlistEvent(
              productId: productId,
              productVariantId: productVariantId,
            ));
          },
          borderRadius: BorderRadius.circular(20),
          child: Container(
            padding: padding,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.9),
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.08),
                  blurRadius: 6,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Icon(
              isWishlisted ? Icons.favorite_rounded : Icons.favorite_border_rounded,
              color: isWishlisted ? const Color(0xFFE53935) : const Color(0xFF5A7265),
              size: size,
            ),
          ),
        );
      },
    );
  }
}
