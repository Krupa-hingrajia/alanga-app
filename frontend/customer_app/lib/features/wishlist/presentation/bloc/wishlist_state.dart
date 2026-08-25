import 'package:equatable/equatable.dart';
import '../../data/models/wishlist_item_model.dart';

abstract class WishlistState extends Equatable {
  const WishlistState();

  @override
  List<Object?> get props => [];
}

class WishlistInitial extends WishlistState {}

class WishlistLoading extends WishlistState {}

class WishlistLoaded extends WishlistState {
  final List<WishlistItemModel> items;
  final Set<String> wishlistedProductIds;

  const WishlistLoaded({
    required this.items,
    required this.wishlistedProductIds,
  });

  @override
  List<Object?> get props => [items, wishlistedProductIds];
}

class WishlistToggling extends WishlistState {
  final String productId;

  const WishlistToggling({required this.productId});

  @override
  List<Object?> get props => [productId];
}

class WishlistActionSuccess extends WishlistState {
  final String message;
  final bool isWishlisted;
  final String productId;

  const WishlistActionSuccess({
    required this.message,
    required this.isWishlisted,
    required this.productId,
  });

  @override
  List<Object?> get props => [message, isWishlisted, productId];
}

class WishlistError extends WishlistState {
  final String message;

  const WishlistError({required this.message});

  @override
  List<Object?> get props => [message];
}
