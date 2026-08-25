import 'package:equatable/equatable.dart';
import '../../data/models/sub_category_model.dart';

abstract class SubCategoryState extends Equatable {
  const SubCategoryState();

  @override
  List<Object?> get props => [];
}

class SubCategoryInitial extends SubCategoryState {}

class SubCategoryListLoading extends SubCategoryState {}

class SubCategoryListLoaded extends SubCategoryState {
  final List<SubCategoryModel> subCategories;
  const SubCategoryListLoaded({required this.subCategories});

  @override
  List<Object?> get props => [subCategories];
}

class SubCategoryListError extends SubCategoryState {
  final String message;
  const SubCategoryListError({required this.message});

  @override
  List<Object?> get props => [message];
}

class SubCategoryActionLoading extends SubCategoryState {}

class SubCategoryActionSuccess extends SubCategoryState {
  final SubCategoryModel subCategory;
  final String message;
  const SubCategoryActionSuccess({required this.subCategory, required this.message});

  @override
  List<Object?> get props => [subCategory, message];
}

class SubCategoryActionError extends SubCategoryState {
  final String message;
  const SubCategoryActionError({required this.message});

  @override
  List<Object?> get props => [message];
}

class SubCategoryDeleteSuccess extends SubCategoryState {
  final String message;
  const SubCategoryDeleteSuccess({required this.message});

  @override
  List<Object?> get props => [message];
}
