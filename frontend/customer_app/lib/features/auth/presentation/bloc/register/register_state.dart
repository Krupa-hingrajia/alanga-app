import 'package:equatable/equatable.dart';
import '../../../domain/entities/user_entity.dart';

abstract class RegisterState extends Equatable {
  const RegisterState();

  @override
  List<Object?> get props => [];
}

class RegisterInitial extends RegisterState {}

class RegisterLoading extends RegisterState {}

class RegisterSuccess extends RegisterState {
  final UserEntity user;

  const RegisterSuccess({required this.user});

  @override
  List<Object?> get props => [user];
}

class RegisterFailure extends RegisterState {
  final String errorMessage;

  const RegisterFailure({required this.errorMessage});

  @override
  List<Object?> get props => [errorMessage];
}
