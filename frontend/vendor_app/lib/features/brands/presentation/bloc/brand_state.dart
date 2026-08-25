import 'package:equatable/equatable.dart';
import '../../data/models/brand_model.dart';

abstract class BrandState extends Equatable {
  const BrandState();

  @override
  List<Object?> get props => [];
}

class BrandInitial extends BrandState {}

class BrandListLoading extends BrandState {}

class BrandListLoaded extends BrandState {
  final List<BrandModel> brands;
  const BrandListLoaded({required this.brands});

  @override
  List<Object?> get props => [brands];
}

class BrandListError extends BrandState {
  final String message;
  const BrandListError({required this.message});

  @override
  List<Object?> get props => [message];
}

class BrandActionLoading extends BrandState {}

class BrandActionSuccess extends BrandState {
  final BrandModel brand;
  final String message;
  const BrandActionSuccess({required this.brand, required this.message});

  @override
  List<Object?> get props => [brand, message];
}

class BrandActionError extends BrandState {
  final String message;
  const BrandActionError({required this.message});

  @override
  List<Object?> get props => [message];
}

class BrandDeleteSuccess extends BrandState {
  final String message;
  const BrandDeleteSuccess({required this.message});

  @override
  List<Object?> get props => [message];
}
