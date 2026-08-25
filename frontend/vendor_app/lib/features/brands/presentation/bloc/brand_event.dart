import 'package:equatable/equatable.dart';

abstract class BrandEvent extends Equatable {
  const BrandEvent();

  @override
  List<Object?> get props => [];
}

class FetchBrandsEvent extends BrandEvent {
  final bool isRefresh;
  const FetchBrandsEvent({this.isRefresh = false});

  @override
  List<Object?> get props => [isRefresh];
}

class CreateBrandSubmittedEvent extends BrandEvent {
  final String name;
  final String? description;
  final String? image;

  const CreateBrandSubmittedEvent({
    required this.name,
    this.description,
    this.image,
  });

  @override
  List<Object?> get props => [name, description, image];
}

class UpdateBrandSubmittedEvent extends BrandEvent {
  final String id;
  final String name;
  final String? description;
  final String? image;

  const UpdateBrandSubmittedEvent({
    required this.id,
    required this.name,
    this.description,
    this.image,
  });

  @override
  List<Object?> get props => [id, name, description, image];
}

class DeleteBrandEvent extends BrandEvent {
  final String id;
  const DeleteBrandEvent({required this.id});

  @override
  List<Object?> get props => [id];
}
