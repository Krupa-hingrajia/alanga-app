import 'package:equatable/equatable.dart';

abstract class SubCategoryEvent extends Equatable {
  const SubCategoryEvent();

  @override
  List<Object?> get props => [];
}

class FetchSubCategoriesEvent extends SubCategoryEvent {
  final bool isRefresh;
  const FetchSubCategoriesEvent({this.isRefresh = false});

  @override
  List<Object?> get props => [isRefresh];
}

class CreateSubCategorySubmittedEvent extends SubCategoryEvent {
  final String categoryId;
  final String name;
  final String? description;
  final String? image;

  const CreateSubCategorySubmittedEvent({
    required this.categoryId,
    required this.name,
    this.description,
    this.image,
  });

  @override
  List<Object?> get props => [categoryId, name, description, image];
}

class UpdateSubCategorySubmittedEvent extends SubCategoryEvent {
  final String id;
  final String categoryId;
  final String name;
  final String? description;
  final String? image;

  const UpdateSubCategorySubmittedEvent({
    required this.id,
    required this.categoryId,
    required this.name,
    this.description,
    this.image,
  });

  @override
  List<Object?> get props => [id, categoryId, name, description, image];
}

class DeleteSubCategoryEvent extends SubCategoryEvent {
  final String id;
  const DeleteSubCategoryEvent({required this.id});

  @override
  List<Object?> get props => [id];
}
