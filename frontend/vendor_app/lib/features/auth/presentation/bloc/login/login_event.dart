import 'package:equatable/equatable.dart';

abstract class LoginEvent extends Equatable {
  const LoginEvent();

  @override
  List<Object?> get props => [];
}

class LoginSubmittedEvent extends LoginEvent {
  final String identifier;
  final String password;

  const LoginSubmittedEvent({required this.identifier, required this.password});

  @override
  List<Object?> get props => [identifier, password];
}
