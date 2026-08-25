import 'package:equatable/equatable.dart';

abstract class ProductEvent extends Equatable {
  const ProductEvent();

  @override
  List<Object?> get props => [];
}

class FetchProductsEvent extends ProductEvent {
  final bool isRefresh;
  const FetchProductsEvent({this.isRefresh = false});

  @override
  List<Object?> get props => [isRefresh];
}
