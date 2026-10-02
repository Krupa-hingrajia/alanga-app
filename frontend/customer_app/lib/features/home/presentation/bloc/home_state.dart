import 'package:equatable/equatable.dart';
import '../../../categories/data/models/category_model.dart';
import '../../../products/data/models/product_model.dart';
import '../../../products/data/models/brand_model.dart';

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
  final List<BrandModel> brands;

  const HomeLoaded({
    required this.categories,
    required this.products,
    this.brands = const [],
  });

  @override
  List<Object?> get props => [categories, products, brands];
}

class HomeError extends HomeState {
  final String message;
  const HomeError({required this.message});

  @override
  List<Object?> get props => [message];
}
