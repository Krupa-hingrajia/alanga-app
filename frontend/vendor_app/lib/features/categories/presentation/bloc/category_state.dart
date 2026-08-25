import 'package:equatable/equatable.dart';
import '../../data/models/category_model.dart';

abstract class CategoryState extends Equatable {
  const CategoryState();

  @override
  List<Object?> get props => [];
}

class CategoryInitial extends CategoryState {}

class CategoryListLoading extends CategoryState {}

class CategoryListLoaded extends CategoryState {
  final List<CategoryModel> categories;
  const CategoryListLoaded({required this.categories});

  @override
  List<Object?> get props => [categories];
}

class CategoryListError extends CategoryState {
  final String message;
  const CategoryListError({required this.message});

  @override
  List<Object?> get props => [message];
}

// Action loading/success/error
class CategoryActionLoading extends CategoryState {}

class CategoryActionSuccess extends CategoryState {
  final CategoryModel category;
  final String message;
  const CategoryActionSuccess({required this.category, required this.message});

  @override
  List<Object?> get props => [category, message];
}

class CategoryActionError extends CategoryState {
  final String message;
  const CategoryActionError({required this.message});

  @override
  List<Object?> get props => [message];
}

class CategoryDeleteSuccess extends CategoryState {
  final String message;
  const CategoryDeleteSuccess({required this.message});

  @override
  List<Object?> get props => [message];
}
