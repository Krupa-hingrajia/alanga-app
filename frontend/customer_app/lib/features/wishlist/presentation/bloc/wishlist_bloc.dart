import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/repositories/wishlist_repository.dart';
import 'wishlist_event.dart';
import 'wishlist_state.dart';

class WishlistBloc extends Bloc<WishlistEvent, WishlistState> {
  final WishlistRepository repository;
  final Set<String> _wishlistedProductIds = {};

  Set<String> get wishlistedProductIds => Set.unmodifiable(_wishlistedProductIds);

  WishlistBloc({required this.repository}) : super(WishlistInitial()) {
    on<FetchWishlistEvent>(_onFetchWishlist);
    on<ToggleWishlistEvent>(_onToggleWishlist);
    on<RemoveWishlistItemEvent>(_onRemoveWishlistItem);
  }

  Future<void> _onFetchWishlist(FetchWishlistEvent event, Emitter<WishlistState> emit) async {
    emit(WishlistLoading());
    try {
      final items = await repository.getWishlist();
      _wishlistedProductIds.clear();
      for (final item in items) {
        _wishlistedProductIds.add(item.productId);
      }

      emit(WishlistLoaded(
        items: items,
        wishlistedProductIds: Set.from(_wishlistedProductIds),
      ));
    } catch (e) {
      final errStr = e.toString();
      if (errStr.contains('401') || errStr.contains('Authentication token')) {
        // Guest/unauthenticated customer -> render clean empty wishlist
        _wishlistedProductIds.clear();
        emit(const WishlistLoaded(
          items: [],
          wishlistedProductIds: {},
        ));
      } else {
        emit(WishlistError(message: errStr));
      }
    }
  }

  Future<void> _onToggleWishlist(ToggleWishlistEvent event, Emitter<WishlistState> emit) async {
    emit(WishlistLoading());
    try {
      final res = await repository.toggleWishlist(
        productId: event.productId,
        productVariantId: event.productVariantId,
      );

      final isWishlisted = res['isWishlisted'] as bool? ?? false;
      final message = res['message'] as String? ?? (isWishlisted ? 'Product added to Wishlist.' : 'Product removed from Wishlist.');

      if (isWishlisted) {
        _wishlistedProductIds.add(event.productId);
      } else {
        _wishlistedProductIds.remove(event.productId);
      }

      emit(WishlistActionSuccess(
        message: message,
        isWishlisted: isWishlisted,
        productId: event.productId,
      ));

      // Refresh list to maintain consistency
      try {
        final items = await repository.getWishlist();
        _wishlistedProductIds.clear();
        for (final item in items) {
          _wishlistedProductIds.add(item.productId);
        }

        emit(WishlistLoaded(
          items: items,
          wishlistedProductIds: Set.from(_wishlistedProductIds),
        ));
      } catch (_) {
        emit(WishlistLoaded(
          items: const [],
          wishlistedProductIds: Set.from(_wishlistedProductIds),
        ));
      }
    } catch (e) {
      emit(WishlistError(message: e.toString()));
    }
  }

  Future<void> _onRemoveWishlistItem(RemoveWishlistItemEvent event, Emitter<WishlistState> emit) async {
    emit(WishlistLoading());
    try {
      await repository.removeFromWishlist(event.wishlistId);
      emit(WishlistActionSuccess(
        message: 'Product removed from Wishlist.',
        isWishlisted: false,
        productId: event.wishlistId,
      ));

      // Refresh wishlist items
      try {
        final items = await repository.getWishlist();
        _wishlistedProductIds.clear();
        for (final item in items) {
          _wishlistedProductIds.add(item.productId);
        }

        emit(WishlistLoaded(
          items: items,
          wishlistedProductIds: Set.from(_wishlistedProductIds),
        ));
      } catch (_) {
        emit(WishlistLoaded(
          items: const [],
          wishlistedProductIds: Set.from(_wishlistedProductIds),
        ));
      }
    } catch (e) {
      emit(WishlistError(message: e.toString()));
    }
  }
}
