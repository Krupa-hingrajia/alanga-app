import 'package:equatable/equatable.dart';
import '../../../categories/data/models/category_model.dart';
import '../../../products/data/models/product_model.dart';

abstract class HomeState extends Equatable {
  const HomeState();

  @override
  List<Object?> get props => [];
}

class HomeInitial extends HomeState {}

class HomeLoading extends HomeState {}

class HomeLoaded extends HomeState {
  final List<CategoryModel> categories;
  final List<ProductModel> products;

  const HomeLoaded({
    required this.categories,
    required this.products,
  });

  @override
  List<Object?> get props => [categories, products];
}

class HomeError extends HomeState {
  final String message;
  const HomeError({required this.message});

  @override
  List<Object?> get props => [message];
}
