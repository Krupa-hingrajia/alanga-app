import 'package:equatable/equatable.dart';
import '../../data/models/cart_item_model.dart';
import '../../data/models/cart_summary_model.dart';

abstract class CartState extends Equatable {
  const CartState();

  @override
  List<Object?> get props => [];
}

class CartInitial extends CartState {}

class CartLoading extends CartState {}

class CartLoaded extends CartState {
  final List<CartItemModel> items;
  final CartSummaryModel summary;
  final String? message;

  const CartLoaded({
    required this.items,
    required this.summary,
    this.message,
  });

  @override
  List<Object?> get props => [items, summary, message];
}

class CartError extends CartState {
  final String message;

  const CartError({required this.message});

  @override
  List<Object?> get props => [message];
}
