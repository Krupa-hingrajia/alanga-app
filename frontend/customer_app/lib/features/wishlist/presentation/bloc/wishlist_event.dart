import 'package:equatable/equatable.dart';

abstract class WishlistEvent extends Equatable {
  const WishlistEvent();

  @override
  List<Object?> get props => [];
}

class FetchWishlistEvent extends WishlistEvent {
  const FetchWishlistEvent();
}

class ToggleWishlistEvent extends WishlistEvent {
  final String productId;
  final String? productVariantId;

  const ToggleWishlistEvent({required this.productId, this.productVariantId});

  @override
  List<Object?> get props => [productId, productVariantId];
}

class RemoveWishlistItemEvent extends WishlistEvent {
  final String wishlistId;

  const RemoveWishlistItemEvent({required this.wishlistId});

  @override
  List<Object?> get props => [wishlistId];
}
