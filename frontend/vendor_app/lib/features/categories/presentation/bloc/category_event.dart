import 'package:equatable/equatable.dart';

abstract class CategoryEvent extends Equatable {
  const CategoryEvent();

  @override
  List<Object?> get props => [];
}

class FetchCategoriesEvent extends CategoryEvent {
  final bool isRefresh;
  const FetchCategoriesEvent({this.isRefresh = false});

  @override
  List<Object?> get props => [isRefresh];
}

class CreateCategorySubmittedEvent extends CategoryEvent {
  final String name;
  final String? description;
  final String? image;

  const CreateCategorySubmittedEvent({
    required this.name,
    this.description,
    this.image,
  });

  @override
  List<Object?> get props => [name, description, image];
}

class UpdateCategorySubmittedEvent extends CategoryEvent {
  final String id;
  final String name;
  final String? description;
  final String? image;

  const UpdateCategorySubmittedEvent({
    required this.id,
    required this.name,
    this.description,
    this.image,
  });

  @override
  List<Object?> get props => [id, name, description, image];
}

class DeleteCategoryEvent extends CategoryEvent {
  final String id;
  const DeleteCategoryEvent({required this.id});

  @override
  List<Object?> get props => [id];
}
